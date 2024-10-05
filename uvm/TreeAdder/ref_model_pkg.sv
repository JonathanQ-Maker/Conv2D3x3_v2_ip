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

        logic [`WORD_WIDTH-1:0] stage_sum [$clog2(`NUM_TERMS)-1:0];

        function void predict(seq_item t);
            // no predict
            logic [`WORD_WIDTH-1:0] sum = 0;
            string s = "";
            for (int i = 0; i < `NUM_TERMS; i++) begin
                sum += t.i_terms[(i*`WORD_WIDTH)+:`WORD_WIDTH];
            end

            for (int i = 0; i < $clog2(`NUM_TERMS); i++) begin
                $sformat(s, "%s %0d:%0d", s, i, stage_sum[i]);
            end
            $sformat(s, "%s\n", s);
            $sformat(s, "%s%d\n", s, sum);
            `uvm_info("ref_model", s, UVM_MEDIUM);

            for (int i = 0; i < $clog2(`NUM_TERMS)-1; i++) begin
                stage_sum[i] = stage_sum[i+1];
            end
            stage_sum[$clog2(`NUM_TERMS)-1] = sum;

            
        endfunction

        function void verify(seq_item t);
            bit matched = 1;

            if (stage_sum[0] != t.o_sum) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf("o_sum missmatch %d != %d", t.o_sum, stage_sum[0]));
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