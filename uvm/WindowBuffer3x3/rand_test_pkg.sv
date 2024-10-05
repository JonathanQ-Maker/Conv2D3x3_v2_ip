package rand_test_pkg;

    import seq_pkg::*;
    import env_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "definitions.svh"

    class rand_seq extends base_seq;
        `uvm_object_utils(rand_seq)

        function new(string name = "");
            super.new(name);
        endfunction

        task body;
            seq_item seq_item_h;
            int i = 0;
            seq_item_h = seq_item::type_id::create("seq_item_h");
            // random load transactions
            repeat(3000) begin
                start_item(seq_item_h);
                    assert(seq_item_h.randomize() with 
                    { 
                        i_width >= 3; 
                        i_width <= `MAX_IMG_WIDTH; 
                        i_height >= 3; 
                        i_height <= `MAX_IMG_HEIGHT; 
                        i_transfers >= 1; 
                        i_transfers <= `MAX_TRANSFERS;
                    });
                finish_item(seq_item_h);
            end
        endtask
    endclass : rand_seq

    class rand_test extends base_test;
        `uvm_component_utils(rand_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            base_seq::type_id::set_type_override(rand_seq::get_type());
            super.build_phase(phase);
        endfunction

    endclass

endpackage