package env_pkg;
    import uvm_pkg::*;
    import seq_pkg::*;
    import ref_model_pkg::*;
    `include "uvm_macros.svh"

    class monitor extends uvm_monitor;
        `uvm_component_utils(monitor)

        uvm_analysis_port #(seq_item) analysis_port;

        virtual dut_if dut_vi;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            analysis_port = new("analysis_port", this);
            if( !uvm_config_db #(virtual dut_if)::get(this, "", "dut_if_h", dut_vi) )
                `uvm_error("", "uvm_config_db::get failed")

        endfunction

        task run_phase(uvm_phase phase);
            forever begin
                seq_item seq_item_h;
                @(posedge dut_vi.i_clk);
                seq_item_h = seq_item::type_id::create("seq_item_h");
                

                seq_item_h.i_reset_n           = dut_vi.i_reset_n;

                seq_item_h.i_load_param        = dut_vi.i_load_param;
                seq_item_h.i_filters        = dut_vi.i_filters;
                seq_item_h.i_transfers        = dut_vi.i_transfers;

                seq_item_h.i_valid            = dut_vi.i_valid;
                seq_item_h.i_data             = dut_vi.i_data;
                seq_item_h.o_last_data             = dut_vi.o_last_data;

                seq_item_h.i_sel               = dut_vi.i_sel;

                seq_item_h.o_kernel_00         = dut_vi.o_kernel_00;
                seq_item_h.o_kernel_01         = dut_vi.o_kernel_01;
                seq_item_h.o_kernel_02         = dut_vi.o_kernel_02;
                
                seq_item_h.o_kernel_10         = dut_vi.o_kernel_10;
                seq_item_h.o_kernel_11         = dut_vi.o_kernel_11;
                seq_item_h.o_kernel_12         = dut_vi.o_kernel_12;

                seq_item_h.o_kernel_20         = dut_vi.o_kernel_20;
                seq_item_h.o_kernel_21         = dut_vi.o_kernel_21;
                seq_item_h.o_kernel_22         = dut_vi.o_kernel_22;
                
                analysis_port.write(seq_item_h);
            end
        endtask

    endclass : monitor

    class driver extends uvm_driver #(seq_item);
        `uvm_component_utils(driver)

        virtual dut_if dut_vi;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            // Get interface reference from config database
            if( !uvm_config_db #(virtual dut_if)::get(this, "", "dut_if_h", dut_vi) )
                `uvm_error("", "uvm_config_db::get failed")
        endfunction

        task run_phase(uvm_phase phase);
            forever begin
                seq_item seq_item_h;

                // Wiggle pins of DUT
                @(posedge dut_vi.i_clk);
                seq_item_port.get_next_item(seq_item_h);
                
                dut_vi.i_reset_n        = seq_item_h.i_reset_n;

                dut_vi.i_load_param     = seq_item_h.i_load_param;
                dut_vi.i_filters        = seq_item_h.i_filters;
                dut_vi.i_transfers      = seq_item_h.i_transfers;

                dut_vi.i_valid          = seq_item_h.i_valid;
                dut_vi.i_data           = seq_item_h.i_data;

                dut_vi.i_sel            = seq_item_h.i_sel;
                
                seq_item_port.item_done();
            end
        endtask

    endclass : driver
 
    class env extends uvm_env;
        `uvm_component_utils(env)
        
        ref_model_sub sub_h;
        driver driver_h;
        monitor monitor_h;
        sequencer sequencer_h;
        uvm_analysis_port #(seq_item) analysis_port;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            sub_h = ref_model_sub::type_id::create("sub_h", this);
            analysis_port = new("analysis_port", this);
            sequencer_h = sequencer::type_id::create("sequencer_h", this);
            driver_h = driver::type_id::create("driver_h", this);
            monitor_h = monitor::type_id::create("monitor_h", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            monitor_h.analysis_port.connect(analysis_port);
            driver_h.seq_item_port.connect(sequencer_h.seq_item_export);
            analysis_port.connect(sub_h.analysis_export);
        endfunction

    endclass : env

    class base_test extends uvm_test;
        `uvm_component_utils(base_test)

        env env_h;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            env_h = env::type_id::create("env_h", this);
            `uvm_info("User", "Build done", UVM_MEDIUM);
        endfunction

        task run_phase(uvm_phase phase);
            base_seq seq = base_seq::type_id::create("seq");
            phase.raise_objection(this);
                seq.start(env_h.sequencer_h);
            phase.drop_objection(this, $sformatf("Finished %d", this.get_name()));
        endtask

    endclass : base_test

endpackage