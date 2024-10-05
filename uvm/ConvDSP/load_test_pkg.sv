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
                assert(seq_item_h.randomize() with {i_reset_n == 1; i_load_param == 1; i_filters == 4; i_transfers == 2;});
            finish_item(seq_item_h);

            // random load
            while (i < 32) begin
                start_item(seq_item_h);
                    assert(seq_item_h.randomize() with {i_reset_n == 1; i_load_param == 0; i_last_window == (i == 7+8); });
                    if (seq_item_h.i_valid) begin
                        seq_item_h.i_window_00 = i % 3 + 1;
                        seq_item_h.i_window_01 = i % 3 + 1;
                        seq_item_h.i_window_02 = i % 3 + 1;

                        seq_item_h.i_window_10 = i % 3 + 1;
                        seq_item_h.i_window_11 = i % 3 + 1;
                        seq_item_h.i_window_12 = i % 3 + 1;

                        seq_item_h.i_window_20 = i % 3 + 1;
                        seq_item_h.i_window_21 = i % 3 + 1;
                        seq_item_h.i_window_22 = i % 3 + 1;


                        seq_item_h.i_kernel_00 = i*9;
                        seq_item_h.i_kernel_01 = i*9+1;
                        seq_item_h.i_kernel_02 = i*9+2;

                        seq_item_h.i_kernel_10 = i*9+3;
                        seq_item_h.i_kernel_11 = i*9+4;
                        seq_item_h.i_kernel_12 = i*9+5;

                        seq_item_h.i_kernel_20 = i*9+6;
                        seq_item_h.i_kernel_21 = i*9+7;
                        seq_item_h.i_kernel_22 = i*9+8;
                        i++;
                    end
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