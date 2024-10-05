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

        function void predict(seq_item t);
            
        endfunction

        function void verify(seq_item t);
            bit matched = 1;

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