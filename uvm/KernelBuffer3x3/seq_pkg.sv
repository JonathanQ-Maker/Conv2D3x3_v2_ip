

package seq_pkg;
    import uvm_pkg::*;
    `include "definitions.svh"
    `include "uvm_macros.svh"

    class seq_item extends uvm_sequence_item;
        `uvm_object_utils(seq_item)

        rand bit i_reset_n;

        rand bit i_load_param;
        rand bit [$clog2(`MAX_DEPTH):0] i_filters;
        rand bit [$clog2(`MAX_DEPTH):0] i_transfers;

        rand bit i_valid;
        rand bit [`WORD_WIDTH-1 : 0] i_data;
        logic o_last_data;

        rand bit [$clog2(`MAX_DEPTH)-1 : 0] i_sel;

        logic [`WORD_WIDTH-1 : 0] o_kernel_00;
        logic [`WORD_WIDTH-1 : 0] o_kernel_01;
        logic [`WORD_WIDTH-1 : 0] o_kernel_02;

        logic [`WORD_WIDTH-1 : 0] o_kernel_10;
        logic [`WORD_WIDTH-1 : 0] o_kernel_11;
        logic [`WORD_WIDTH-1 : 0] o_kernel_12;

        logic [`WORD_WIDTH-1 : 0] o_kernel_20;
        logic [`WORD_WIDTH-1 : 0] o_kernel_21;
        logic [`WORD_WIDTH-1 : 0] o_kernel_22;



        function new(string name = "");
            super.new(name);
        endfunction

        function string convert2string;
            string s;
            s = super.convert2string();
            $sformat(s, "%s\n %s\n", s, this.get_name());

            $sformat(s, "%s i_reset_n \t%0d\n", s, i_reset_n);

            $sformat(s, "%s i_load_param \t%0d\n", s, i_load_param);
            $sformat(s, "%s i_filters \t%0d\n", s, i_filters);
            $sformat(s, "%s i_transfers \t%0d\n", s, i_transfers);

            $sformat(s, "%s i_valid \t%0d\n", s, i_valid);
            $sformat(s, "%s i_data \t%0d\n", s, i_data);
            $sformat(s, "%s o_last_data \t%0d\n", s, o_last_data);

            $sformat(s, "%s i_sel \t%0d\n", s, i_sel);

            $sformat(s, "%s o_kernel_00 \t%0d\n", s, o_kernel_00);
            $sformat(s, "%s o_kernel_01 \t%0d\n", s, o_kernel_01);
            $sformat(s, "%s o_kernel_02 \t%0d\n", s, o_kernel_02);

            $sformat(s, "%s o_kernel_10 \t%0d\n", s, o_kernel_10);
            $sformat(s, "%s o_kernel_11 \t%0d\n", s, o_kernel_11);
            $sformat(s, "%s o_kernel_12 \t%0d\n", s, o_kernel_12);

            $sformat(s, "%s o_kernel_20 \t%0d\n", s, o_kernel_20);
            $sformat(s, "%s o_kernel_21 \t%0d\n", s, o_kernel_21);
            $sformat(s, "%s o_kernel_22 \t%0d\n", s, o_kernel_22);
            


            return s;
        endfunction

        function void do_copy(uvm_object rhs);
            seq_item seq_item_h;
            $cast(seq_item_h, rhs);

            i_reset_n           = seq_item_h.i_reset_n;

            i_load_param        = seq_item_h.i_load_param;
            i_filters           = seq_item_h.i_filters;
            i_transfers         = seq_item_h.i_transfers;

            i_valid             = seq_item_h.i_valid;
            i_data              = seq_item_h.i_data;
            o_last_data              = seq_item_h.o_last_data;

            i_sel               = seq_item_h.i_sel;

            o_kernel_00         = seq_item_h.o_kernel_00;
            o_kernel_01         = seq_item_h.o_kernel_01;
            o_kernel_02         = seq_item_h.o_kernel_02;
            
            o_kernel_10         = seq_item_h.o_kernel_10;
            o_kernel_11         = seq_item_h.o_kernel_11;
            o_kernel_12         = seq_item_h.o_kernel_12;

            o_kernel_20         = seq_item_h.o_kernel_20;
            o_kernel_21         = seq_item_h.o_kernel_21;
            o_kernel_22         = seq_item_h.o_kernel_22;
        endfunction
        
        function bit do_compare(uvm_object rhs, uvm_comparer comparer);
            seq_item seq_item_h;
            bit status;
            $cast(seq_item_h, rhs);
            status = 1;

            status &= (i_reset_n    == seq_item_h.i_reset_n);

            status &= (i_load_param    == seq_item_h.i_load_param);
            status &= (i_filters    == seq_item_h.i_filters);
            status &= (i_transfers    == seq_item_h.i_transfers);

            status &= (i_valid     == seq_item_h.i_valid);
            status &= (i_data      == seq_item_h.i_data);
            status &= (o_last_data      == seq_item_h.o_last_data);

            status &= (i_sel        == seq_item_h.i_sel);

            status &= (o_kernel_00  == seq_item_h.o_kernel_00);
            status &= (o_kernel_01  == seq_item_h.o_kernel_01);
            status &= (o_kernel_02  == seq_item_h.o_kernel_02);
            
            status &= (o_kernel_10  == seq_item_h.o_kernel_10);
            status &= (o_kernel_11  == seq_item_h.o_kernel_11);
            status &= (o_kernel_12  == seq_item_h.o_kernel_12);

            status &= (o_kernel_20  == seq_item_h.o_kernel_20);
            status &= (o_kernel_21  == seq_item_h.o_kernel_21);
            status &= (o_kernel_22  == seq_item_h.o_kernel_22);

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