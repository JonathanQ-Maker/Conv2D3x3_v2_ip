
// REQUIRED: i_filters * i_transfers <= MAX_DEPTH
module KernelBuffer3x3 #(parameter 
    WORD_WIDTH  = 8,
    MAX_DEPTH   = 512
    ) (
    input  logic i_clk,
    input  logic i_reset_n,

    // load parameter
    input  logic i_load_param,
    input  logic [$clog2(MAX_DEPTH):0] i_filters,
    input  logic [$clog2(MAX_DEPTH):0] i_transfers,

    // Input stream
    input  logic                    i_valid,
    input  logic [WORD_WIDTH-1 : 0] i_data,
    output logic o_last_data,
    
    // kernel control
    input  logic i_sel_valid,
    input  logic [$clog2(MAX_DEPTH)-1 : 0] i_sel,

    // kernel output
    output logic [WORD_WIDTH-1 : 0] o_kernel_00, 
    output logic [WORD_WIDTH-1 : 0] o_kernel_01, 
    output logic [WORD_WIDTH-1 : 0] o_kernel_02,

    output logic [WORD_WIDTH-1 : 0] o_kernel_10, 
    output logic [WORD_WIDTH-1 : 0] o_kernel_11, 
    output logic [WORD_WIDTH-1 : 0] o_kernel_12,
    
    output logic [WORD_WIDTH-1 : 0] o_kernel_20, 
    output logic [WORD_WIDTH-1 : 0] o_kernel_21, 
    output logic [WORD_WIDTH-1 : 0] o_kernel_22
    );

    timeunit 1ns/1ps;
    
    // Validate parameters
    if (WORD_WIDTH < 1)
        $error("Invalid Parameter: WORD_WIDTH < 1");
    if (MAX_DEPTH < 1)
        $error("Invalid Parameter: MAX_DEPTH < 1");
    
    logic [$clog2(MAX_DEPTH)-1 : 0] r_sel;      // select used during filling
    logic [$clog2(MAX_DEPTH): 0] r_filters, r_transfers;
    logic [$clog2(MAX_DEPTH): 0] r_filter_count, r_down_filter_count, r_transfers_count;

    logic [3:0] r_9_counter;

    logic [WORD_WIDTH-1 : 0] r_buf_00[MAX_DEPTH-1 : 0];
    logic [WORD_WIDTH-1 : 0] r_buf_01[MAX_DEPTH-1 : 0];
    logic [WORD_WIDTH-1 : 0] r_buf_02[MAX_DEPTH-1 : 0];

    logic [WORD_WIDTH-1 : 0] r_buf_10[MAX_DEPTH-1 : 0];
    logic [WORD_WIDTH-1 : 0] r_buf_11[MAX_DEPTH-1 : 0];
    logic [WORD_WIDTH-1 : 0] r_buf_12[MAX_DEPTH-1 : 0];

    logic [WORD_WIDTH-1 : 0] r_buf_20[MAX_DEPTH-1 : 0];
    logic [WORD_WIDTH-1 : 0] r_buf_21[MAX_DEPTH-1 : 0];
    logic [WORD_WIDTH-1 : 0] r_buf_22[MAX_DEPTH-1 : 0];


    always_ff @(posedge i_clk) begin
        if (i_sel_valid) begin
            o_kernel_00 <= r_buf_00[i_sel];
            o_kernel_01 <= r_buf_01[i_sel];
            o_kernel_02 <= r_buf_02[i_sel];
            o_kernel_10 <= r_buf_10[i_sel];
            o_kernel_11 <= r_buf_11[i_sel];
            o_kernel_12 <= r_buf_12[i_sel];
            o_kernel_20 <= r_buf_20[i_sel];
            o_kernel_21 <= r_buf_21[i_sel];
            o_kernel_22 <= r_buf_22[i_sel];
        end
    end

    always_ff @(posedge i_clk) begin
        if (!i_reset_n) begin
            r_9_counter         <= 0;
            r_sel               <= 0;

            r_filters           <= MAX_DEPTH;
            r_transfers         <= 1;

            r_filter_count      <= 0;
            r_down_filter_count <= MAX_DEPTH;
            r_transfers_count   <= 1;
            o_last_data              <= 0;
        end
        else if (i_load_param) begin
            r_9_counter         <= 0;
            r_sel               <= 0;

            r_filters           <= i_filters;
            r_transfers         <= i_transfers;

            r_filter_count      <= 0;
            r_down_filter_count <= i_filters;
            r_transfers_count   <= i_transfers;
            o_last_data              <= 0;
        end
        else if (i_valid) begin

            o_last_data <= r_down_filter_count == 1 
                && ((r_transfers_count == 2 && r_9_counter == 8) || (r_transfers == 1 && r_9_counter == 7));

            if (r_transfers_count == 1) begin
                r_transfers_count <= r_transfers;

                if (r_9_counter == 8) begin
                    r_9_counter <= 0;
                    if (r_down_filter_count == 1) begin
                        r_sel <= 0;
                        r_filter_count <= 0;
                        r_down_filter_count <= r_filters;
                    end
                    else begin
                        r_sel <= r_filter_count + 1;
                        r_filter_count <= r_filter_count + 1;
                        r_down_filter_count <= r_down_filter_count - 1;
                    end
                end
                else begin
                    r_9_counter <= r_9_counter + 1;
                    r_sel <= r_filter_count;
                end
            end
            else begin
                r_transfers_count <= r_transfers_count - 1;
                r_sel <= r_sel + r_filters;
            end

            // fill into 9 BRAMs
            if (r_9_counter == 0)
                r_buf_00[r_sel] <= i_data;
            if (r_9_counter == 1)
                r_buf_01[r_sel] <= i_data;
            if (r_9_counter == 2)
                r_buf_02[r_sel] <= i_data;
            if (r_9_counter == 3)
                r_buf_10[r_sel] <= i_data;
            if (r_9_counter == 4)
                r_buf_11[r_sel] <= i_data;
            if (r_9_counter == 5)
                r_buf_12[r_sel] <= i_data;
            if (r_9_counter == 6)
                r_buf_20[r_sel] <= i_data;
            if (r_9_counter == 7)
                r_buf_21[r_sel] <= i_data;
            if (r_9_counter == 8)
                r_buf_22[r_sel] <= i_data;
        end
    end

endmodule