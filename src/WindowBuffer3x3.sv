(* use_dsp = "no" *)
module WindowBuffer3x3 #(parameter
    WORD_WIDTH          = 8,    // Width of each transfer
    MAX_IMG_WIDTH       = 128,  // Max width in pixels
    MAX_IMG_HEIGHT      = 128,  // Max height in pixels
    MAX_TRANSFERS       = 512,  // Max number of transfers to fill a pixel
    MAX_LINE_DEPTH      = 8192  // Max depth of each line buffer
    ) (
    input  logic i_clk,
    input  logic i_reset_n,

    // load parameter
    input  logic i_load_param,
    input  logic i_pad,
    input  logic [WORD_WIDTH-1 : 0] i_pad_val,
    input  logic [$clog2(MAX_IMG_WIDTH) : 0]  i_width,
    input  logic [$clog2(MAX_IMG_HEIGHT) : 0] i_height,
    input  logic [$clog2(MAX_TRANSFERS) : 0]  i_transfers,

    // flag signal
    output logic o_last_data,
    output logic o_last_window,

    // Input stream
    input  logic i_valid,
    input  logic [WORD_WIDTH-1 : 0] i_data,

    // Window output
    output logic o_next_window_valid,

    output logic [WORD_WIDTH-1 : 0] o_window_00,
    output logic [WORD_WIDTH-1 : 0] o_window_01,
    output logic [WORD_WIDTH-1 : 0] o_window_02,

    output logic [WORD_WIDTH-1 : 0] o_window_10,
    output logic [WORD_WIDTH-1 : 0] o_window_11,
    output logic [WORD_WIDTH-1 : 0] o_window_12,

    output logic [WORD_WIDTH-1 : 0] o_window_20,
    output logic [WORD_WIDTH-1 : 0] o_window_21,
    output logic [WORD_WIDTH-1 : 0] o_window_22
    );

    timeunit 1ns/1ps;

    // Validate parameters
    if (WORD_WIDTH < 1)
        $error("Invalid Parameter: WORD_WIDTH < 1");
    if (MAX_IMG_WIDTH < 3)
        $error("Invalid Parameter: MAX_IMG_WIDTH < 3");
    if (MAX_IMG_HEIGHT < 3)
        $error("Invalid Parameter: MAX_IMG_HEIGHT < 3");
    if (MAX_TRANSFERS < 1)
        $error("Invalid Parameter: MAX_TRANSFERS < 1");
    if (MAX_LINE_DEPTH < 3)
        $error("Invalid Parameter: MAX_LINE_DEPTH < 3");

    localparam MAX_ROW_DEPTH = MAX_TRANSFERS*2;


    // misc line wires
    logic w_wr_valid;
    assign w_wr_valid = i_valid; //&& !i_load_param && i_reset_n;


    ////////////////////////////////////////////////////////////////////////////
    // Line Buffers
    ////////////////////////////////////////////////////////////////////////////

    logic [$clog2(MAX_LINE_DEPTH) : 0] w_depth;
    logic [WORD_WIDTH-1 : 0] w_rd0_data;
    logic [WORD_WIDTH-1 : 0] w_rd1_data;
    assign w_depth = (i_transfers * i_width);

    LineBuffer #(.WIDTH(WORD_WIDTH), .MAX_DEPTH(MAX_LINE_DEPTH)) line0
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),

        .i_load_depth(i_load_param),
        .i_depth(w_depth),

        // write port
        .i_wr_valid(w_wr_valid),
        .i_wr_data(w_rd1_data),

        // read port
        .o_rd_valid(),
        .o_rd_data(w_rd0_data)
    );

    LineBuffer #(.WIDTH(WORD_WIDTH), .MAX_DEPTH(MAX_LINE_DEPTH)) line1
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),

        .i_load_depth(i_load_param),
        .i_depth(w_depth),

        // write port
        .i_wr_valid(w_wr_valid),
        .i_wr_data(i_data),

        // read port
        .o_rd_valid(),
        .o_rd_data(w_rd1_data)
    );


    ////////////////////////////////////////////////////////////////////////////
    // Row 0 Buffers
    ////////////////////////////////////////////////////////////////////////////

    logic [WORD_WIDTH-1 : 0] w_row00_data;
    logic [WORD_WIDTH-1 : 0] w_row01_data;

    LineBuffer #(.WIDTH(WORD_WIDTH), .MAX_DEPTH(MAX_TRANSFERS)) row_00
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),

        .i_load_depth(i_load_param),
        .i_depth(i_transfers),

        // write port
        .i_wr_valid(w_wr_valid),
        .i_wr_data(w_row01_data),

        // read port
        .o_rd_valid(),
        .o_rd_data(w_row00_data)
    );

    LineBuffer #(.WIDTH(WORD_WIDTH), .MAX_DEPTH(MAX_TRANSFERS)) row_01
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),

        .i_load_depth(i_load_param),
        .i_depth(i_transfers),

        // write port
        .i_wr_valid(w_wr_valid),
        .i_wr_data(w_rd0_data),

        // read port
        .o_rd_valid(),
        .o_rd_data(w_row01_data)
    );


    ////////////////////////////////////////////////////////////////////////////
    // Row 1 Buffers
    ////////////////////////////////////////////////////////////////////////////

    logic [WORD_WIDTH-1 : 0] w_row10_data;
    logic [WORD_WIDTH-1 : 0] w_row11_data;

    LineBuffer #(.WIDTH(WORD_WIDTH), .MAX_DEPTH(MAX_TRANSFERS)) row_10
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),

        .i_load_depth(i_load_param),
        .i_depth(i_transfers),

        // write port
        .i_wr_valid(w_wr_valid),
        .i_wr_data(w_row11_data),

        // read port
        .o_rd_valid(),
        .o_rd_data(w_row10_data)
    );

    LineBuffer #(.WIDTH(WORD_WIDTH), .MAX_DEPTH(MAX_TRANSFERS)) row_11
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),

        .i_load_depth(i_load_param),
        .i_depth(i_transfers),

        // write port
        .i_wr_valid(w_wr_valid),
        .i_wr_data(w_rd1_data),

        // read port
        .o_rd_valid(),
        .o_rd_data(w_row11_data)
    );

    ////////////////////////////////////////////////////////////////////////////
    // Row 2 Buffers
    ////////////////////////////////////////////////////////////////////////////

    logic [WORD_WIDTH-1 : 0] w_row20_data;
    logic [WORD_WIDTH-1 : 0] w_row21_data;

    LineBuffer #(.WIDTH(WORD_WIDTH), .MAX_DEPTH(MAX_TRANSFERS)) row_20
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),

        .i_load_depth(i_load_param),
        .i_depth(i_transfers),

        // write port
        .i_wr_valid(w_wr_valid),
        .i_wr_data(w_row21_data),

        // read port
        .o_rd_valid(),
        .o_rd_data(w_row20_data)
    );

    LineBuffer #(.WIDTH(WORD_WIDTH), .MAX_DEPTH(MAX_TRANSFERS)) row_21
    (
        .i_clk(i_clk),
        .i_reset_n(i_reset_n),

        .i_load_depth(i_load_param),
        .i_depth(i_transfers),

        // write port
        .i_wr_valid(w_wr_valid),
        .i_wr_data(i_data),

        // read port
        .o_rd_valid(),
        .o_rd_data(w_row21_data)
    );


    ////////////////////////////////////////////////////////////////////////////
    // Control Sequential Logic
    ////////////////////////////////////////////////////////////////////////////

    // param registers
    logic r_pad;
    logic [WORD_WIDTH-1 : 0] r_pad_val;
    logic [$clog2(MAX_IMG_WIDTH) : 0]  r_width;
    logic [$clog2(MAX_IMG_HEIGHT) : 0] r_height;
    logic [$clog2(MAX_TRANSFERS) : 0]  r_transfers;

    // control signals
    logic [$clog2(MAX_IMG_WIDTH) : 0]   r_width_count;
    logic [$clog2(MAX_IMG_HEIGHT) : 0]  r_height_count;
    logic [$clog2(MAX_TRANSFERS) : 0]   r_transfer_count;
    logic [1:0] r_width_full_count;
    logic [1:0] r_height_full_count;

    always_ff @(posedge i_clk) begin
        if (!i_reset_n) begin
            // sync reset logic
            r_width             <= 3;
            r_height            <= 3;
            r_transfers         <= 1;
            r_pad               <= 0;
            r_pad_val           <= 0;

            r_width_count       <= 3;
            r_height_count      <= 3;
            r_transfer_count    <= 1;

            r_width_full_count  <= 0;
            r_height_full_count <= 0;
        end
        else if (i_load_param) begin
            r_width             <= i_width;
            r_height            <= i_height;
            r_transfers         <= i_transfers;
            r_pad               <= i_pad;
            r_pad_val           <= i_pad_val;

            r_width_count       <= i_width;
            r_height_count      <= i_height;
            r_transfer_count    <= i_transfers;

            r_width_full_count  <= 0;
            r_height_full_count <= 0;

        end
        else if (i_valid) begin

            // counters
            if (r_transfer_count == 1)
                r_transfer_count <= r_transfers;
            else
                r_transfer_count <= r_transfer_count - 1;

            if (r_transfer_count == 1) begin
                if (r_width_count == 1) begin
                    r_width_count <= r_width;
                    r_width_full_count <= 0;
                end
                else begin
                    r_width_count <= r_width_count - 1;
                    if (r_width_full_count != 3)
                        r_width_full_count <= r_width_full_count + 1;
                end
            end

            if (r_width_count == 1 && r_transfer_count == 1) begin
                if (r_height_count == 1) begin
                    r_height_count <= r_height;
                    r_height_full_count <= 0;
                end
                else begin
                    r_height_count <= r_height_count - 1;
                    if (r_height_full_count != 3)
                        r_height_full_count <= r_height_full_count + 1;
                end
            end


        end
    end
    

    logic w_pad_00, w_pad_01, w_pad_02;
    assign w_pad_00 = r_pad && ((r_height_full_count == 1 && r_width_full_count != 0) || (r_height_full_count == 2 && r_width_full_count == 0) || r_width_full_count == 1);
    assign w_pad_01 = r_pad && ((r_height_full_count == 1 && r_width_full_count != 0) || (r_height_full_count == 2 && r_width_full_count == 0));
    assign w_pad_02 = r_pad && (r_height_full_count == 1 || r_width_full_count == 0);

    logic w_pad_10, w_pad_12;
    assign w_pad_10 = r_pad && (r_width_full_count == 1);
    assign w_pad_12 = r_pad && (r_width_full_count == 0);

    logic w_pad_20, w_pad_21, w_pad_22;
    assign w_pad_20 = r_pad && ((r_height_full_count == 0 && r_width_full_count != 0) || (r_height_full_count == 1 && r_width_full_count == 0) || r_width_full_count == 1);
    assign w_pad_21 = r_pad && ((r_height_full_count == 0 && r_width_full_count != 0) || (r_height_full_count == 1 && r_width_full_count == 0));
    assign w_pad_22 = r_pad && (r_height_full_count == 0 || (r_height_full_count == 1 && r_width_full_count == 0) || r_width_full_count == 0);

    always_ff @(posedge i_clk) begin
        if (!i_reset_n) begin
            o_next_window_valid  <= 0;
            o_last_data     <= 0;
            o_last_window   <= 0;
        end
        else if (i_load_param) begin
            o_next_window_valid  <= 0;
            o_last_data     <= 0;
            o_last_window   <= 0;
        end
        else if (i_valid) begin
            o_window_00 <= w_pad_00 ? r_pad_val : w_row00_data;
            o_window_01 <= w_pad_01 ? r_pad_val : w_row01_data;
            o_window_02 <= w_pad_02 ? r_pad_val : w_rd0_data;

            // row 1
            o_window_10 <= w_pad_10 ? r_pad_val : w_row10_data;
            o_window_11 <= w_row11_data;
            o_window_12 <= w_pad_12 ? r_pad_val : w_rd1_data;

            // row 2
            o_window_20 <= w_pad_20 ? r_pad_val : w_row20_data;
            o_window_21 <= w_pad_21 ? r_pad_val : w_row21_data;
            o_window_22 <= w_pad_22 ? r_pad_val : i_data;

            o_next_window_valid <= r_pad ? 
                o_next_window_valid || (r_transfer_count == 1 && r_height_full_count == 1) : 
                ((r_width_full_count == 1 && r_transfer_count == 1) || (r_width_full_count >= 2 && (r_width_count != 1 || r_transfer_count != 1)))
                && r_height_full_count >= 2;


            // flag indicating when module would recive last data for current image
            o_last_data <= ((r_width_count == 1 && r_transfers > 1) || (r_width_count == 2 && r_transfers == 1)) && 
                r_height_count == 1 && 
                (r_transfer_count == 2 || r_transfers == 1);

            // flag indicating when the module would output the last window for current image
            o_last_window <= r_pad ? 
                r_height_full_count == 1 && r_width_full_count == 0 && r_transfer_count == 1 && o_next_window_valid :
                r_height_count == 1 && r_width_count == 1 && r_transfer_count == 1;
        end
    end

    

endmodule