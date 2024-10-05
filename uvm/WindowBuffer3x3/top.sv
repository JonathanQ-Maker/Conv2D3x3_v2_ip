`include "definitions.svh"
`include "uvm_macros.svh"

interface dut_if;

    logic i_clk;
    logic i_reset_n;

    logic i_load_param;
    logic i_pad;
    logic [`WORD_WIDTH-1 : 0] i_pad_val;
    logic [$clog2(`MAX_IMG_WIDTH) : 0] i_width;
    logic [$clog2(`MAX_IMG_HEIGHT) : 0] i_height;
    logic [$clog2(`MAX_TRANSFERS) : 0] i_transfers;

    logic i_valid;
    logic o_ready;
    logic [`WORD_WIDTH-1 : 0] i_data;

    logic o_next_window_valid;
    logic i_window_ready;

    logic [`WORD_WIDTH-1 : 0] o_window_00;
    logic [`WORD_WIDTH-1 : 0] o_window_01;
    logic [`WORD_WIDTH-1 : 0] o_window_02;

    logic [`WORD_WIDTH-1 : 0] o_window_10;
    logic [`WORD_WIDTH-1 : 0] o_window_11;
    logic [`WORD_WIDTH-1 : 0] o_window_12;

    logic [`WORD_WIDTH-1 : 0] o_window_20;
    logic [`WORD_WIDTH-1 : 0] o_window_21;
    logic [`WORD_WIDTH-1 : 0] o_window_22;

endinterface

module top;
    import uvm_pkg::*;
    import rand_test_pkg::*;
    import load_test_pkg::*;

    dut_if dut_if_h();
    
    WindowBuffer3x3 #(
        .WORD_WIDTH(`WORD_WIDTH), 
        .MAX_IMG_WIDTH(`MAX_IMG_WIDTH), 
        .MAX_IMG_HEIGHT(`MAX_IMG_HEIGHT), 
        .MAX_TRANSFERS(`MAX_TRANSFERS)) dut 
    (
        .i_clk(dut_if_h.i_clk),
        .i_reset_n(dut_if_h.i_reset_n),

        .i_load_param(dut_if_h.i_load_param),
        .i_pad(dut_if_h.i_pad),
        .i_pad_val(dut_if_h.i_pad_val),
        .i_width(dut_if_h.i_width),
        .i_height(dut_if_h.i_height),
        .i_transfers(dut_if_h.i_transfers),

        .i_valid(dut_if_h.i_valid),
        .i_data(dut_if_h.i_data),

        .o_next_window_valid(dut_if_h.o_next_window_valid),

        .o_window_00(dut_if_h.o_window_00),
        .o_window_01(dut_if_h.o_window_01),
        .o_window_02(dut_if_h.o_window_02),

        .o_window_10(dut_if_h.o_window_10),
        .o_window_11(dut_if_h.o_window_11),
        .o_window_12(dut_if_h.o_window_12),

        .o_window_20(dut_if_h.o_window_20),
        .o_window_21(dut_if_h.o_window_21),
        .o_window_22(dut_if_h.o_window_22)
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