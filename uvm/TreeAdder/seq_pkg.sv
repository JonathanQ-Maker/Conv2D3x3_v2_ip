

package seq_pkg;
    import uvm_pkg::*;
    `include "definitions.svh"
    `include "uvm_macros.svh"

    class seq_item extends uvm_sequence_item;
        `uvm_object_utils(seq_item)

        rand bit [`WORD_WIDTH*`NUM_TERMS-1:0] i_terms;
        logic [`WORD_WIDTH-1:0] o_sum;


        function new(string name = "");
            super.new(name);
        endfunction

        function string convert2string;
            string s;
            s = super.convert2string();
            $sformat(s, "%s\n %s\n", s, this.get_name());

            $sformat(s, "%s o_sum \t%0d\n", s, o_sum);

            for (int i = 0; i < `NUM_TERMS; i++) begin
                $sformat(s, "%s i_terms[%2d] \t%0d\n", s, i, i_terms[(i*`WORD_WIDTH)+:`WORD_WIDTH]);
            end

            return s;
        endfunction

        function void do_copy(uvm_object rhs);
            seq_item seq_item_h;
            $cast(seq_item_h, rhs);
            i_terms       = seq_item_h.i_terms;
            o_sum         = seq_item_h.o_sum;
        endfunction
        
        function bit do_compare(uvm_object rhs, uvm_comparer comparer);
            seq_item seq_item_h;
            bit status;
            $cast(seq_item_h, rhs);
            status = 1;
            status &= (i_terms  == seq_item_h.i_terms);
            status &= (o_sum  == seq_item_h.o_sum);

            return status;
        endfunction

    endclass : seq_item

    typedef uvm_sequencer #(seq_item) sequencer;

    class base_seq extends uvm_sequence #(seq_item);
        `uvm_object_utils(base_seq)

        function new(string name = "");
            super.new(name);
        endfunction

        task body;
            
        endtask
    endclass : base_seq


endpackage