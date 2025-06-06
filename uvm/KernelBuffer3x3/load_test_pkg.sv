package load_test_pkg;

    import seq_pkg::*;
    import env_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class load_seq extends base_seq;
        `uvm_object_utils(load_seq)

        function new(string name = "");
            super.new(name);
        endfunction

        task body;
            seq_item seq_item_h;
            int i = 0;
            seq_item_h = seq_item::type_id::create("seq_item_h");
            
            // reset
            start_item(seq_item_h);
                assert(seq_item_h.randomize() with {i_reset_n == 0;});
            finish_item(seq_item_h);

            // configure
            start_item(seq_item_h);
                assert(seq_item_h.randomize() with {i_reset_n == 1; i_load_param == 1; i_filters == 2; i_transfers == 1;});
            finish_item(seq_item_h);

            // random load
            while (i < 54) begin
                start_item(seq_item_h);
                    assert(seq_item_h.randomize() with {i_reset_n == 1; i_load_param == 0;});
                    if (seq_item_h.i_valid)
                        seq_item_h.i_data = i++;
                finish_item(seq_item_h);
            end

            i = 0;
            while (i < 54) begin
                start_item(seq_item_h);
                    assert(seq_item_h.randomize() with {i_reset_n == 1; i_load_param == 0;});
                    if (seq_item_h.i_valid) begin
                        i++;
                        seq_item_h.i_data = 0;
                    end
                finish_item(seq_item_h);
            end

            i = 0;
            while (i < 54) begin
                start_item(seq_item_h);
                    assert(seq_item_h.randomize() with {i_reset_n == 1; i_load_param == 0;});
                    if (seq_item_h.i_valid)
                        seq_item_h.i_data = i++;
                finish_item(seq_item_h);
            end
        endtask
    endclass : load_seq

    class load_test extends base_test;
        `uvm_component_utils(load_test)

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            base_seq::type_id::set_type_override(load_seq::get_type());
            super.build_phase(phase);
        endfunction

    endclass

endpackage