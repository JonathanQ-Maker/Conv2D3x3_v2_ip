`include "definitions.svh"
`include "uvm_macros.svh"

interface dut_if;

    logic i_clk;
    logic [`WORD_WIDTH*`NUM_TERMS-1:0] i_terms;
    logic [`WORD_WIDTH-1:0]           o_sum;

endinterface

module top;
    import uvm_pkg::*;
    import rand_test_pkg::*;

    dut_if dut_if_h();
    
    TreeAdder #(.WORD_WIDTH(`WORD_WIDTH), .NUM_TERMS(`NUM_TERMS)) dut 
    (
        .i_clk(dut_if_h.i_clk),
        .i_terms(dut_if_h.i_terms),
        .o_sum(dut_if_h.o_sum)
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