
(* use_dsp = "yes" *)
module ConvDSP #(parameter
    TRANSFER_WIDTH  = 8,
    WORD_WIDTH      = 8,
    MAX_FILTERS     = 512,
    MAX_TRANSFERS   = 512
    ) (
    input  logic i_clk,
    input  logic i_reset_n,
    
    input  logic i_load_param,
    input  logic [$clog2(MAX_FILTERS):0] i_filters,
    input  logic [$clog2(MAX_TRANSFERS):0] i_transfers,

    // input stream
    input  logic i_valid,
    // window input
    input  logic i_last_window,
    input  logic [TRANSFER_WIDTH-1:0] i_window_00,
    input  logic [TRANSFER_WIDTH-1:0] i_window_01,
    input  logic [TRANSFER_WIDTH-1:0] i_window_02,

    input  logic [TRANSFER_WIDTH-1:0] i_window_10,
    input  logic [TRANSFER_WIDTH-1:0] i_window_11,
    input  logic [TRANSFER_WIDTH-1:0] i_window_12,

    input  logic [TRANSFER_WIDTH-1:0] i_window_20,
    input  logic [TRANSFER_WIDTH-1:0] i_window_21,
    input  logic [TRANSFER_WIDTH-1:0] i_window_22,

    // kernel input
    input  logic [TRANSFER_WIDTH-1:0] i_kernel_00,
    input  logic [TRANSFER_WIDTH-1:0] i_kernel_01,
    input  logic [TRANSFER_WIDTH-1:0] i_kernel_02,

    input  logic [TRANSFER_WIDTH-1:0] i_kernel_10,
    input  logic [TRANSFER_WIDTH-1:0] i_kernel_11,
    input  logic [TRANSFER_WIDTH-1:0] i_kernel_12,

    input  logic [TRANSFER_WIDTH-1:0] i_kernel_20,
    input  logic [TRANSFER_WIDTH-1:0] i_kernel_21,
    input  logic [TRANSFER_WIDTH-1:0] i_kernel_22,

    output logic o_next_valid,
    output logic o_last_window_result,
    output logic [WORD_WIDTH-1:0] o_data
    );

    if (TRANSFER_WIDTH % WORD_WIDTH != 0)
        $error("Invalid Parameter: TRANSFER_WIDTH % WORD_WIDTH != 0");

    function automatic int f(int n);
        // function to compute the number of 
        // pipeline registers required for tree adder

        int t;
        t = n/2 + n % 2;
        if (t == 1)
            return 1;
        return f(t) + t;
    endfunction

    localparam WORDS = TRANSFER_WIDTH / WORD_WIDTH;
    localparam PRODUCTS = 9*WORDS;

    localparam RESIDUAL = PRODUCTS % 2;
    localparam NUM_BASE_SUM = PRODUCTS/2 + RESIDUAL;
    localparam NUM_SUM_REG = f(PRODUCTS);

    localparam PIPELINE_STAGES = $clog2(PRODUCTS) + 3;

    // A register set
    logic [TRANSFER_WIDTH-1:0] r_a_00 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_a_01 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_a_02 [1:0];

    logic [TRANSFER_WIDTH-1:0] r_a_10 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_a_11 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_a_12 [1:0];

    logic [TRANSFER_WIDTH-1:0] r_a_20 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_a_21 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_a_22 [1:0];

    // B register set
    logic [TRANSFER_WIDTH-1:0] r_b_00 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_b_01 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_b_02 [1:0];

    logic [TRANSFER_WIDTH-1:0] r_b_10 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_b_11 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_b_12 [1:0];

    logic [TRANSFER_WIDTH-1:0] r_b_20 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_b_21 [1:0];
    logic [TRANSFER_WIDTH-1:0] r_b_22 [1:0];

    // Product register set
    logic [WORD_WIDTH-1:0] r_products [PRODUCTS-1:0];

    // Partial register set;
    logic [WORD_WIDTH-1:0] r_partial [NUM_SUM_REG-1:0];

    // r_partial[NUM_SUM_REG-1] // final sum

    always_ff @(posedge i_clk) begin
        if (i_valid) begin
            // shift A register set
            r_a_00 <= { r_a_00[0], i_window_00 };
            r_a_01 <= { r_a_01[0], i_window_01 };
            r_a_02 <= { r_a_02[0], i_window_02 };

            r_a_10 <= { r_a_10[0], i_window_10 };
            r_a_11 <= { r_a_11[0], i_window_11 };
            r_a_12 <= { r_a_12[0], i_window_12 };

            r_a_20 <= { r_a_20[0], i_window_20 };
            r_a_21 <= { r_a_21[0], i_window_21 };
            r_a_22 <= { r_a_22[0], i_window_22 };

            // shift B register set
            r_b_00 <= { r_b_00[0], i_kernel_00 };
            r_b_01 <= { r_b_01[0], i_kernel_01 };
            r_b_02 <= { r_b_02[0], i_kernel_02 };

            r_b_10 <= { r_b_10[0], i_kernel_10 };
            r_b_11 <= { r_b_11[0], i_kernel_11 };
            r_b_12 <= { r_b_12[0], i_kernel_12 };

            r_b_20 <= { r_b_20[0], i_kernel_20 };
            r_b_21 <= { r_b_21[0], i_kernel_21 };
            r_b_22 <= { r_b_22[0], i_kernel_22 };

            // Multiply
            for (int i = 0; i < WORDS; i++) begin
                r_products[i*9+0] <= r_a_00[1][(WORD_WIDTH*i)+: WORD_WIDTH] * r_b_00[1][(WORD_WIDTH*i)+: WORD_WIDTH];
                r_products[i*9+1] <= r_a_01[1][(WORD_WIDTH*i)+: WORD_WIDTH] * r_b_01[1][(WORD_WIDTH*i)+: WORD_WIDTH];
                r_products[i*9+2] <= r_a_02[1][(WORD_WIDTH*i)+: WORD_WIDTH] * r_b_02[1][(WORD_WIDTH*i)+: WORD_WIDTH];

                r_products[i*9+3] <= r_a_10[1][(WORD_WIDTH*i)+: WORD_WIDTH] * r_b_10[1][(WORD_WIDTH*i)+: WORD_WIDTH];
                r_products[i*9+4] <= r_a_11[1][(WORD_WIDTH*i)+: WORD_WIDTH] * r_b_11[1][(WORD_WIDTH*i)+: WORD_WIDTH];
                r_products[i*9+5] <= r_a_12[1][(WORD_WIDTH*i)+: WORD_WIDTH] * r_b_12[1][(WORD_WIDTH*i)+: WORD_WIDTH];

                r_products[i*9+6] <= r_a_20[1][(WORD_WIDTH*i)+: WORD_WIDTH] * r_b_20[1][(WORD_WIDTH*i)+: WORD_WIDTH];
                r_products[i*9+7] <= r_a_21[1][(WORD_WIDTH*i)+: WORD_WIDTH] * r_b_21[1][(WORD_WIDTH*i)+: WORD_WIDTH];
                r_products[i*9+8] <= r_a_22[1][(WORD_WIDTH*i)+: WORD_WIDTH] * r_b_22[1][(WORD_WIDTH*i)+: WORD_WIDTH];
            end

            // Tree Adder
            for (int i = 0; i < NUM_BASE_SUM-RESIDUAL; i++) begin
                r_partial[i] <= r_products[i*2] + r_products[i*2+1];
            end

            if (RESIDUAL) begin
                r_partial[NUM_BASE_SUM-1] <= r_products[PRODUCTS-1];
            end

            for (int l = NUM_BASE_SUM, n = 0; l > 1; l = $ceil(l/2.0)) begin
                for (int i = 0; i < l/2; i++) begin
                    r_partial[i + l + n] <= r_partial[i*2 + n] + r_partial[i*2+1 + n];
                end

                if (l % 2 == 1) begin
                    r_partial[l-1+int'($ceil(l/2.0))+n] <= r_partial[l-1+n];
                end
                n += l;
            end

        end
    end


    // control logic

    logic [$clog2(MAX_TRANSFERS):0] r_transfers, r_transfer_count;
    logic [$clog2(MAX_FILTERS):0] r_filters, r_filter_count;

    logic [WORD_WIDTH-1:0] r_results [MAX_FILTERS-1:0];
    logic [$clog2(MAX_FILTERS)-1:0] r_write_addr, r_read_addr;
    logic r_first_transfer;
    logic [$clog2(PIPELINE_STAGES):0] r_pipe_stges;
    logic [PIPELINE_STAGES-1:0] r_last_window_pipe;
    logic r_last_window_result;


    always_ff @(posedge i_clk) begin
        if (!i_reset_n) begin
            r_filters   <= MAX_FILTERS;
            r_filter_count <= MAX_FILTERS;

            r_transfers <= 1;
            r_transfer_count <= 1;
            
            r_pipe_stges <= PIPELINE_STAGES-1;
            r_last_window_pipe <= 0;
            r_write_addr <= 0;
            r_read_addr <= 0;
            r_first_transfer <= 1;
            r_last_window_result <= 0;
            o_last_window_result <= 0;
            o_next_valid <= 0;
        end
        else if (i_load_param) begin
            r_filters   <= i_filters;
            r_filter_count <= i_filters;

            r_transfers <= i_transfers;
            r_transfer_count <= i_transfers;

            r_pipe_stges <= PIPELINE_STAGES;
            r_last_window_pipe <= 0;
            r_write_addr <= 0;
            r_read_addr <= 0;
            r_first_transfer <= 1;
            r_last_window_result <= 0;
            o_last_window_result <= 0;
            o_next_valid <= 0;
        end
        else if (i_valid) begin
            if (r_pipe_stges != 0) begin
                r_pipe_stges <= r_pipe_stges - 1;
            end

            r_last_window_pipe <= { i_last_window, r_last_window_pipe[PIPELINE_STAGES-1:1] };

            if (r_pipe_stges == 0) begin
                if (r_filter_count == 1) begin
                    r_filter_count <= r_filters;
                    r_write_addr <= 0;

                    if (r_transfer_count == 1) begin
                        r_transfer_count <= r_transfers;
                        r_first_transfer <= 1;
                    end
                    else begin
                        r_transfer_count <= r_transfer_count - 1;
                        r_first_transfer <= 0;
                    end
                end
                else begin
                    r_filter_count <= r_filter_count - 1;
                    r_write_addr <= r_write_addr + 1;
                end
            end

            o_next_valid <= r_transfer_count == 1 && r_pipe_stges <= 1;
            r_last_window_result <= r_last_window_pipe[0] && r_transfer_count == 1 && r_filter_count == 1;
            o_last_window_result <= r_last_window_result;

            if (o_next_valid) begin
                if (r_first_transfer)
                    r_read_addr <= 0;
                else
                    r_read_addr <= r_read_addr + 1;
            end

            r_results[r_write_addr] <= r_first_transfer ? r_partial[NUM_SUM_REG-1] : r_results[r_write_addr] + r_partial[NUM_SUM_REG-1];

            o_data <= o_next_valid ? r_results[r_read_addr] : 0;
        end
    end
    
endmodule