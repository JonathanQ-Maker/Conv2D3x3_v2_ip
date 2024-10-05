package ref_model_pkg;
    import uvm_pkg::*;
    import seq_pkg::*;

    `include "definitions.svh"
    `include "uvm_macros.svh"

    class ref_model_sub extends uvm_subscriber #(seq_item);
        `uvm_component_utils(ref_model_sub)

        int transactions, correct;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        bit [$clog2(`MAX_DEPTH):0] depth;
        logic [`WIDTH-1:0] buffer [`MAX_DEPTH-1:0];
        logic [$clog2(`MAX_DEPTH)-1:0] wr_addr, rd_addr;
        logic [$clog2(`MAX_DEPTH):0] counter;
        
        logic [`WIDTH-1:0] rd_data;
        logic rd_valid;

        function void predict(seq_item t);
            if (!t.i_reset_n) begin
                wr_addr = 0;
                rd_addr = 0;
                counter = 0;
                rd_valid = 0;
                depth = `MAX_DEPTH;
            end
            else if (t.i_load_depth) begin
                depth = t.i_depth;
                counter = 0;
                rd_valid = 0;
            end
            else if (t.i_wr_valid) begin

                if (counter != depth)
                    counter++;
                else
                    rd_addr = (rd_addr + 1) % `MAX_DEPTH;

                rd_data = buffer[rd_addr];

                buffer[wr_addr] = t.i_wr_data;
                wr_addr = (wr_addr + 1) % `MAX_DEPTH;
                rd_valid = counter == depth;
            end
            
            
        endfunction

        function void verify(seq_item t);
            bit matched = 1;
            if(t.o_rd_valid != rd_valid) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf("o_rd_valid missmatch %d != %d", t.o_rd_valid, rd_valid));
            end

            if(t.o_rd_data != rd_data) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf("o_rd_data missmatch %d != %d", t.o_rd_data, rd_data));
            end

            transactions++;
            if (matched)
                correct++;
        endfunction
        
        function void write(seq_item t);
            `uvm_info("ref_model", t.convert2string(), UVM_MEDIUM);
            verify(t);
            predict(t);
        endfunction

        function void report_phase(uvm_phase phase);
            `uvm_info("ref_model", $sformatf("matches: %d/%d", correct, transactions), UVM_MEDIUM);
        endfunction

    endclass : ref_model_sub

endpackage