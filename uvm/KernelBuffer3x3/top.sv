`include "definitions.svh"
`include "uvm_macros.svh"

interface dut_if;

    logic i_clk;
    logic i_reset_n;

    logic i_load_param;
    logic [$clog2(`MAX_DEPTH):0] i_filters;
    logic [$clog2(`MAX_DEPTH):0] i_transfers;

    logic i_valid;
    logic [`WORD_WIDTH-1 : 0] i_data;
    logic o_last_data;

    logic [$clog2(`MAX_DEPTH)-1 : 0] i_sel;

    logic [`WORD_WIDTH-1 : 0] o_kernel_00; 
    logic [`WORD_WIDTH-1 : 0] o_kernel_01; 
    logic [`WORD_WIDTH-1 : 0] o_kernel_02;

    logic [`WORD_WIDTH-1 : 0] o_kernel_10; 
    logic [`WORD_WIDTH-1 : 0] o_kernel_11; 
    logic [`WORD_WIDTH-1 : 0] o_kernel_12;
    
    logic [`WORD_WIDTH-1 : 0] o_kernel_20; 
    logic [`WORD_WIDTH-1 : 0] o_kernel_21; 
    logic [`WORD_WIDTH-1 : 0] o_kernel_22;

endinterface

module top;
    import uvm_pkg::*;
    import rand_test_pkg::*;
    import load_test_pkg::*;

    dut_if dut_if_h();
    
    KernelBuffer3x3 #(.WORD_WIDTH(`WORD_WIDTH), .MAX_DEPTH(`MAX_DEPTH)) dut 
    (
        .i_clk(dut_if_h.i_clk),
        .i_reset_n(dut_if_h.i_reset_n),

        .i_load_param(dut_if_h.i_load_param),
        .i_filters(dut_if_h.i_filters),
        .i_transfers(dut_if_h.i_transfers),

        .i_valid(dut_if_h.i_valid),
        .i_data(dut_if_h.i_data),
        .o_last_data(dut_if_h.o_last_data),

        .i_sel(dut_if_h.i_sel),

        .o_kernel_00(dut_if_h.o_kernel_00),
        .o_kernel_01(dut_if_h.o_kernel_01),
        .o_kernel_02(dut_if_h.o_kernel_02),

        .o_kernel_10(dut_if_h.o_kernel_10),
        .o_kernel_11(dut_if_h.o_kernel_11),
        .o_kernel_12(dut_if_h.o_kernel_12),

        .o_kernel_20(dut_if_h.o_kernel_20),
        .o_kernel_21(dut_if_h.o_kernel_21),
        .o_kernel_22(dut_if_h.o_kernel_22)

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