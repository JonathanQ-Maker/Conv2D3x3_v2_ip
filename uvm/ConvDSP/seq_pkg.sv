

package seq_pkg;
    import uvm_pkg::*;
    `include "definitions.svh"
    `include "uvm_macros.svh"

    class seq_item extends uvm_sequence_item;
        `uvm_object_utils(seq_item)

        rand bit i_reset_n;
        rand bit i_load_param;

        rand bit [`MAX_FILTERS:0] i_filters;
        rand bit [`MAX_TRANSFERS:0] i_transfers;
        
        rand bit i_valid;
        rand bit i_last_window;
        rand bit [`TRANSFER_WIDTH-1:0] i_window_00;
        rand bit [`TRANSFER_WIDTH-1:0] i_window_01;
        rand bit [`TRANSFER_WIDTH-1:0] i_window_02;

        rand bit [`TRANSFER_WIDTH-1:0] i_window_10;
        rand bit [`TRANSFER_WIDTH-1:0] i_window_11;
        rand bit [`TRANSFER_WIDTH-1:0] i_window_12;

        rand bit [`TRANSFER_WIDTH-1:0] i_window_20;
        rand bit [`TRANSFER_WIDTH-1:0] i_window_21;
        rand bit [`TRANSFER_WIDTH-1:0] i_window_22;


        rand bit [`TRANSFER_WIDTH-1:0] i_kernel_00;
        rand bit [`TRANSFER_WIDTH-1:0] i_kernel_01;
        rand bit [`TRANSFER_WIDTH-1:0] i_kernel_02;

        rand bit [`TRANSFER_WIDTH-1:0] i_kernel_10;
        rand bit [`TRANSFER_WIDTH-1:0] i_kernel_11;
        rand bit [`TRANSFER_WIDTH-1:0] i_kernel_12;

        rand bit [`TRANSFER_WIDTH-1:0] i_kernel_20;
        rand bit [`TRANSFER_WIDTH-1:0] i_kernel_21;
        rand bit [`TRANSFER_WIDTH-1:0] i_kernel_22;

        logic o_next_valid;
        logic o_last_window_result;
        logic [`WORD_WIDTH-1:0] o_data;


        function new(string name = "");
            super.new(name);
        endfunction

        function string convert2string;
            string s;
            s = super.convert2string();
            $sformat(s, "%s\n %s\n", s, this.get_name());

            $sformat(s, "%s i_reset_n \t%0d\n", s, i_reset_n);

            $sformat(s, "%s i_filters \t%0d\n", s, i_filters);
            $sformat(s, "%s i_transfers \t%0d\n", s, i_transfers);

            $sformat(s, "%s i_valid \t%0d\n", s, i_valid);
            $sformat(s, "%s i_last_window \t%0d\n", s, i_last_window);

            $sformat(s, "%s i_window_00 \t%0d\n", s, i_window_00);
            $sformat(s, "%s i_window_01 \t%0d\n", s, i_window_01);
            $sformat(s, "%s i_window_02 \t%0d\n", s, i_window_02);

            $sformat(s, "%s i_window_10 \t%0d\n", s, i_window_10);
            $sformat(s, "%s i_window_11 \t%0d\n", s, i_window_11);
            $sformat(s, "%s i_window_12 \t%0d\n", s, i_window_12);

            $sformat(s, "%s i_window_20 \t%0d\n", s, i_window_20);
            $sformat(s, "%s i_window_21 \t%0d\n", s, i_window_21);
            $sformat(s, "%s i_window_22 \t%0d\n", s, i_window_22);


            $sformat(s, "%s i_kernel_00 \t%0d\n", s, i_kernel_00);
            $sformat(s, "%s i_kernel_01 \t%0d\n", s, i_kernel_01);
            $sformat(s, "%s i_kernel_02 \t%0d\n", s, i_kernel_02);

            $sformat(s, "%s i_kernel_10 \t%0d\n", s, i_kernel_10);
            $sformat(s, "%s i_kernel_11 \t%0d\n", s, i_kernel_11);
            $sformat(s, "%s i_kernel_12 \t%0d\n", s, i_kernel_12);

            $sformat(s, "%s i_kernel_20 \t%0d\n", s, i_kernel_20);
            $sformat(s, "%s i_kernel_21 \t%0d\n", s, i_kernel_21);
            $sformat(s, "%s i_kernel_22 \t%0d\n", s, i_kernel_22);

            $sformat(s, "%s o_next_valid \t%0d\n", s, o_next_valid);
            $sformat(s, "%s o_last_window_result \t%0d\n", s, o_last_window_result);
            $sformat(s, "%s o_data \t%0d\n", s, o_data);

            return s;
        endfunction

        function void do_copy(uvm_object rhs);
            seq_item seq_item_h;
            $cast(seq_item_h, rhs);
            i_reset_n       = seq_item_h.i_reset_n;

            i_load_param       = seq_item_h.i_load_param;
            i_filters       = seq_item_h.i_filters;
            i_transfers       = seq_item_h.i_transfers;

            i_valid       = seq_item_h.i_valid;
            i_last_window     = seq_item_h.i_last_window;
            i_window_00       = seq_item_h.i_window_00;
            i_window_01       = seq_item_h.i_window_01;
            i_window_02       = seq_item_h.i_window_02;

            i_window_10       = seq_item_h.i_window_10;
            i_window_11       = seq_item_h.i_window_11;
            i_window_12       = seq_item_h.i_window_12;

            i_window_20       = seq_item_h.i_window_20;
            i_window_21       = seq_item_h.i_window_21;
            i_window_22       = seq_item_h.i_window_22;


            i_kernel_00       = seq_item_h.i_kernel_00;
            i_kernel_01       = seq_item_h.i_kernel_01;
            i_kernel_02       = seq_item_h.i_kernel_02;

            i_kernel_10       = seq_item_h.i_kernel_10;
            i_kernel_11       = seq_item_h.i_kernel_11;
            i_kernel_12       = seq_item_h.i_kernel_12;

            i_kernel_20       = seq_item_h.i_kernel_20;
            i_kernel_21       = seq_item_h.i_kernel_21;
            i_kernel_22       = seq_item_h.i_kernel_22;

            o_next_valid       = seq_item_h.o_next_valid;
            o_last_window_result = seq_item_h.o_last_window_result;
            o_data       = seq_item_h.o_data;
        endfunction
        
        function bit do_compare(uvm_object rhs, uvm_comparer comparer);
            seq_item seq_item_h;
            bit status;
            $cast(seq_item_h, rhs);
            status = 1;

            status &= (i_reset_n == seq_item_h.i_reset_n);

            status &= (i_load_param == seq_item_h.i_load_param);
            status &= (i_filters == seq_item_h.i_filters);
            status &= (i_transfers == seq_item_h.i_transfers);

            status &= (i_valid == seq_item_h.i_valid);
            status &= (i_last_window == seq_item_h.i_last_window);

            status &= (i_window_00 == seq_item_h.i_window_00);
            status &= (i_window_01 == seq_item_h.i_window_01);
            status &= (i_window_02 == seq_item_h.i_window_02);

            status &= (i_window_10 == seq_item_h.i_window_10);
            status &= (i_window_11 == seq_item_h.i_window_11);
            status &= (i_window_12 == seq_item_h.i_window_12);

            status &= (i_window_20 == seq_item_h.i_window_20);
            status &= (i_window_21 == seq_item_h.i_window_21);
            status &= (i_window_22 == seq_item_h.i_window_22);


            status &= (i_kernel_00 == seq_item_h.i_kernel_00);
            status &= (i_kernel_01 == seq_item_h.i_kernel_01);
            status &= (i_kernel_02 == seq_item_h.i_kernel_02);

            status &= (i_kernel_10 == seq_item_h.i_kernel_10);
            status &= (i_kernel_11 == seq_item_h.i_kernel_11);
            status &= (i_kernel_12 == seq_item_h.i_kernel_12);

            status &= (i_kernel_20 == seq_item_h.i_kernel_20);
            status &= (i_kernel_21 == seq_item_h.i_kernel_21);
            status &= (i_kernel_22 == seq_item_h.i_kernel_22);

            status &= (o_next_valid == seq_item_h.o_next_valid);
            status &= (o_data == seq_item_h.o_data);
            status &= (o_last_window_result == seq_item_h.o_last_window_result);

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