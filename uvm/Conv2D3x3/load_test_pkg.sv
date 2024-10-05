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
                assert(seq_item_h.randomize() with {i_aresetn == 0;});
            finish_item(seq_item_h);

            // config
            start_item(seq_item_h);
                assert(seq_item_h.randomize() with { 
                    i_aresetn == 1; 

                    i_awvalid == 1; 
                    i_awaddr == 'h8; 
                    
                    i_wvalid == 1; 
                    i_wdata == {16'd4, 16'd2}; 
                    i_wstrb == 'b1111;

                    i_bready == 1;
                });
            finish_item(seq_item_h);

            start_item(seq_item_h);
                assert(seq_item_h.randomize() with { 
                    i_aresetn == 1; 

                    i_awvalid == 1; 
                    i_awaddr == 'h8; 
                    
                    i_wvalid == 1; 
                    i_wdata == {16'd4, 16'd2}; 
                    i_wstrb == 'b1111;

                    i_bready == 1;
                });
            finish_item(seq_item_h);

            // run
            start_item(seq_item_h);
                assert(seq_item_h.randomize() with { 
                    i_aresetn == 1; 

                    i_awvalid == 1; 
                    i_awaddr == 0; 
                    
                    i_wvalid == 1; 
                    i_wdata == 'b0111; 
                    i_wstrb == 'b1111;

                    i_bready == 1;
                });
            finish_item(seq_item_h);

            start_item(seq_item_h);
                assert(seq_item_h.randomize() with { 
                    i_aresetn == 1; 

                    i_awvalid == 1; 
                    i_awaddr == 0; 
                    
                    i_wvalid == 1; 
                    i_wdata == 'b0111; 
                    i_wstrb == 'b1111;

                    i_bready == 1;
                });
            finish_item(seq_item_h);


            for (int a = 0; a < 5; a++) begin
                start_item(seq_item_h);
                    assert(seq_item_h.randomize() with { 
                        i_aresetn == 1;
                        i_awvalid == 0;
                        i_s_tvalid == 0;
                    });
                finish_item(seq_item_h);
            end


            while (i < 4*2*9) begin
                start_item(seq_item_h);
                    assert(seq_item_h.randomize() with { 
                        i_aresetn == 1;
                        i_awvalid == 0;
                        i_s_tdata == 255;
                    });

                    if (seq_item_h.i_s_tvalid) begin
                        seq_item_h.i_s_tdata = i++;
                    end
                finish_item(seq_item_h);
            end

            i = 0;
            while (i < 126) begin
                start_item(seq_item_h);
                    assert(seq_item_h.randomize() with { 
                        i_aresetn == 1;
                        i_awvalid == 0;
                        i_s_tdata == 255;
                        i_m_tready == 1;
                        i_s_tvalid == 1;
                    });

                    if (seq_item_h.i_s_tvalid) begin
                        seq_item_h.i_s_tdata = i++;
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