`include "definitions.svh"
`include "uvm_macros.svh"

interface dut_if;
    logic i_clk;
    logic i_reset_n;
    
    logic i_load_depth;
    logic [$clog2(`MAX_DEPTH):0] i_depth;

    // write port
    logic i_wr_valid;
    logic [`WIDTH-1:0] i_wr_data;

    // read port
    logic o_rd_valid;
    logic [`WIDTH-1:0] o_rd_data;

endinterface

module top;
    import uvm_pkg::*;
    import rand_test_pkg::*;
    import load_test_pkg::*;

    dut_if dut_if_h();
    
    LineBuffer #(.WIDTH(`WIDTH), .MAX_DEPTH(`MAX_DEPTH)) dut 
    (
        .i_clk(dut_if_h.i_clk),
        .i_reset_n(dut_if_h.i_reset_n),

        // depth setting port
        .i_load_depth(dut_if_h.i_load_depth),
        .i_depth(dut_if_h.i_depth),

        // write port
        .i_wr_valid(dut_if_h.i_wr_valid),
        .i_wr_data(dut_if_h.i_wr_data),

        // read port
        .o_rd_valid(dut_if_h.o_rd_valid),
        .o_rd_data(dut_if_h.o_rd_data)
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