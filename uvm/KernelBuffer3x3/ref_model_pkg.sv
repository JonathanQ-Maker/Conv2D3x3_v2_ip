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

        logic [`WORD_WIDTH-1:0] buffer [9*`MAX_DEPTH-1:0];
        logic [$clog2(9*`MAX_DEPTH)-1:0] wr_idx;

        logic [`WORD_WIDTH-1:0] kernel_00;
        logic [`WORD_WIDTH-1:0] kernel_01;
        logic [`WORD_WIDTH-1:0] kernel_02;

        logic [`WORD_WIDTH-1:0] kernel_10;
        logic [`WORD_WIDTH-1:0] kernel_11;
        logic [`WORD_WIDTH-1:0] kernel_12;

        logic [`WORD_WIDTH-1:0] kernel_20;
        logic [`WORD_WIDTH-1:0] kernel_21;
        logic [`WORD_WIDTH-1:0] kernel_22;

        function void predict(seq_item t);

            kernel_00 = buffer[t.i_sel*9];
            kernel_01 = buffer[t.i_sel*9 + 1];
            kernel_02 = buffer[t.i_sel*9 + 2];

            kernel_10 = buffer[t.i_sel*9 + 3];
            kernel_11 = buffer[t.i_sel*9 + 4];
            kernel_12 = buffer[t.i_sel*9 + 5];

            kernel_20 = buffer[t.i_sel*9 + 6];
            kernel_21 = buffer[t.i_sel*9 + 7];
            kernel_22 = buffer[t.i_sel*9 + 8];

            if (!t.i_reset_n) begin
                wr_idx = 0;
            end
            else if (t.i_valid) begin

                buffer[wr_idx] = t.i_data;


                if (wr_idx == 9*`MAX_DEPTH-1)
                    wr_idx = 0;
                else
                    wr_idx = wr_idx + 1;
            end

        endfunction

        function void verify(seq_item t);
            bit matched = 1;

            if (t.o_kernel_00 != kernel_00) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf(" o_kernel_00 %d != %d", t.o_kernel_00, kernel_00));
            end

            if (t.o_kernel_01 != kernel_01) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf(" o_kernel_01 %d != %d", t.o_kernel_01, kernel_01));
            end

            if (t.o_kernel_02 != kernel_02) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf(" o_kernel_02 %d != %d", t.o_kernel_02, kernel_02));
            end


            if (t.o_kernel_10 != kernel_10) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf(" o_kernel_10 %d != %d", t.o_kernel_10, kernel_10));
            end

            if (t.o_kernel_11 != kernel_11) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf(" o_kernel_11 %d != %d", t.o_kernel_11, kernel_11));
            end

            if (t.o_kernel_12 != kernel_12) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf(" o_kernel_12 %d != %d", t.o_kernel_12, kernel_12));
            end


            if (t.o_kernel_20 != kernel_20) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf(" o_kernel_20 %d != %d", t.o_kernel_20, kernel_20));
            end

            if (t.o_kernel_21 != kernel_21) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf(" o_kernel_21 %d != %d", t.o_kernel_21, kernel_21));
            end

            if (t.o_kernel_22 != kernel_22) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf(" o_kernel_22 %d != %d", t.o_kernel_22, kernel_22));
            end




            // record matches
            transactions++;
            if (matched)
                correct++;
        endfunction
        
        function void write(seq_item t);
            verify(t);
            predict(t);
            `uvm_info("ref_model", t.convert2string(), UVM_MEDIUM);
        endfunction

        function void report_phase(uvm_phase phase);
            `uvm_info("ref_model", $sformatf("\n\n--- REFERENCE MODEL MATCHES: (%0d/%0d) ---\n\n", correct, transactions), UVM_MEDIUM);
        endfunction

    endclass : ref_model_sub

endpackage