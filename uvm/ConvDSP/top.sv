`include "definitions.svh"
`include "uvm_macros.svh"

interface dut_if;

    logic i_clk;
    logic i_reset_n;
    logic i_load_param;

    logic [`MAX_FILTERS:0] i_filters;
    logic [`MAX_TRANSFERS:0] i_transfers;
    
    logic i_valid;
    logic i_last_window;
    logic [`TRANSFER_WIDTH-1:0] i_window_00;
    logic [`TRANSFER_WIDTH-1:0] i_window_01;
    logic [`TRANSFER_WIDTH-1:0] i_window_02;

    logic [`TRANSFER_WIDTH-1:0] i_window_10;
    logic [`TRANSFER_WIDTH-1:0] i_window_11;
    logic [`TRANSFER_WIDTH-1:0] i_window_12;

    logic [`TRANSFER_WIDTH-1:0] i_window_20;
    logic [`TRANSFER_WIDTH-1:0] i_window_21;
    logic [`TRANSFER_WIDTH-1:0] i_window_22;


    logic [`TRANSFER_WIDTH-1:0] i_kernel_00;
    logic [`TRANSFER_WIDTH-1:0] i_kernel_01;
    logic [`TRANSFER_WIDTH-1:0] i_kernel_02;

    logic [`TRANSFER_WIDTH-1:0] i_kernel_10;
    logic [`TRANSFER_WIDTH-1:0] i_kernel_11;
    logic [`TRANSFER_WIDTH-1:0] i_kernel_12;

    logic [`TRANSFER_WIDTH-1:0] i_kernel_20;
    logic [`TRANSFER_WIDTH-1:0] i_kernel_21;
    logic [`TRANSFER_WIDTH-1:0] i_kernel_22;

    logic o_next_valid;
    logic o_last_window_result;
    logic [`WORD_WIDTH-1:0] o_data;

endinterface

module top;
    import uvm_pkg::*;
    import rand_test_pkg::*;
    import load_test_pkg::*;

    dut_if dut_if_h();
    
    ConvDSP #(
        .TRANSFER_WIDTH(`TRANSFER_WIDTH), 
        .WORD_WIDTH(`WORD_WIDTH),
        .MAX_FILTERS(`MAX_FILTERS),
        .MAX_TRANSFERS(`MAX_TRANSFERS)
    ) dut 
    (
        .i_clk(dut_if_h.i_clk),
        .i_reset_n(dut_if_h.i_reset_n),

        .i_load_param(dut_if_h.i_load_param),
        .i_filters(dut_if_h.i_filters),
        .i_transfers(dut_if_h.i_transfers),

        .i_valid(dut_if_h.i_valid),
        .i_last_window(dut_if_h.i_last_window),
        .i_window_00(dut_if_h.i_window_00),
        .i_window_01(dut_if_h.i_window_01),
        .i_window_02(dut_if_h.i_window_02),

        .i_window_10(dut_if_h.i_window_10),
        .i_window_11(dut_if_h.i_window_11),
        .i_window_12(dut_if_h.i_window_12),

        .i_window_20(dut_if_h.i_window_20),
        .i_window_21(dut_if_h.i_window_21),
        .i_window_22(dut_if_h.i_window_22),


        .i_kernel_00(dut_if_h.i_kernel_00),
        .i_kernel_01(dut_if_h.i_kernel_01),
        .i_kernel_02(dut_if_h.i_kernel_02),

        .i_kernel_10(dut_if_h.i_kernel_10),
        .i_kernel_11(dut_if_h.i_kernel_11),
        .i_kernel_12(dut_if_h.i_kernel_12),

        .i_kernel_20(dut_if_h.i_kernel_20),
        .i_kernel_21(dut_if_h.i_kernel_21),
        .i_kernel_22(dut_if_h.i_kernel_22),
        
        .o_next_valid(dut_if_h.o_next_valid),
        .o_last_window_result(dut_if_h.o_last_window_result),
        .o_data(dut_if_h.o_data)
    );

    initial begin
        dut_if_h.i_clk = 0;
        forever #5 dut_if_h.i_clk = ~dut_if_h.i_clk;
    end

    initial begin
        uvm_config_db #(virtual dut_if)::set(null, "*", "dut_if_h", dut_if_h);
        uvm_top.finish_on_completion = 1; // call $finish() when objections drop

        run_test();
    end
endmodule