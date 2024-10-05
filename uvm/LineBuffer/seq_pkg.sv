

package seq_pkg;
    import uvm_pkg::*;
    `include "definitions.svh"
    `include "uvm_macros.svh"

    class seq_item extends uvm_sequence_item;
        `uvm_object_utils(seq_item)

        rand bit i_reset_n;

        rand bit i_load_depth;
        rand bit [$clog2(`MAX_DEPTH):0] i_depth;
        
        rand bit i_wr_valid;
        rand bit [`WIDTH-1:0] i_wr_data;

        logic o_rd_valid;
        logic [`WIDTH-1:0] o_rd_data;

        function new(string name = "");
            super.new(name);
        endfunction

        function string convert2string;
            string s;
            s = super.convert2string();
            $sformat(s, "%s\n %s\n i_reset_n \t%0d\n i_load_depth \t%0d\n i_depth \t%0d\n i_wr_valid \t%0d\n i_wr_data \t%0d\n o_rd_valid \t%0d\n o_rd_data \t%0d\n", 
                s, this.get_name(), i_reset_n, i_load_depth, i_depth, i_wr_valid, i_wr_data, o_rd_valid, o_rd_data);
            return s;
        endfunction

        function void do_copy(uvm_object rhs);
            seq_item seq_item_h;
            $cast(seq_item_h, rhs);
            i_reset_n       = seq_item_h.i_reset_n;

            i_load_depth    = seq_item_h.i_load_depth;
            i_depth         = seq_item_h.i_depth;

            i_wr_valid      = seq_item_h.i_wr_valid;
            i_wr_data       = seq_item_h.i_wr_data;

            o_rd_valid      = seq_item_h.o_rd_valid;
            o_rd_data       = seq_item_h.o_rd_data;

        endfunction
        
        function bit do_compare(uvm_object rhs, uvm_comparer comparer);
            seq_item seq_item_h;
            bit status;
            $cast(seq_item_h, rhs);
            status = 1;
            status &= (i_reset_n  == seq_item_h.i_reset_n);
            status &= (i_load_depth  == seq_item_h.i_load_depth);
            status &= (i_wr_valid  == seq_item_h.i_wr_valid);
            status &= (i_wr_data  == seq_item_h.i_wr_data);
            status &= (o_rd_valid  == seq_item_h.o_rd_valid);
            status &= (o_rd_data  == seq_item_h.o_rd_data);

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


    //////////////////////////////////////////
    // Sequences
    //////////////////////////////////////////

    // class load_seq extends base_seq;
    //     `uvm_object_utils(load_seq)

    //     function new(string name = "");
    //         super.new(name);
    //     endfunction

    //     task body;
    //         seq_item seq_item_h;
    //         seq_item_h = seq_item::type_id::create("seq_item_h");

    //         // reset
    //         start_item(seq_item_h);
    //             assert(seq_item_h.randomize() with { i_reset_n == 0;});
    //         finish_item(seq_item_h);

    //         // load depth
    //         start_item(seq_item_h);
    //             assert(seq_item_h.randomize() with { i_reset_n == 1; i_load_depth == 1; i_depth <= `MAX_DEPTH;});
    //         finish_item(seq_item_h);

    //         // random load transactions
    //         repeat(32) begin
    //             start_item(seq_item_h);
    //                 assert(seq_item_h.randomize() with { i_reset_n == 1; i_load_depth == 0;});
    //             finish_item(seq_item_h);
    //         end
    //     endtask
    // endclass : load_seq
endpackage