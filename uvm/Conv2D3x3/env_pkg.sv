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
                @(posedge dut_vi.i_aclk);
                seq_item_h = seq_item::type_id::create("seq_item_h");
                seq_item_h.i_aresetn    = dut_vi.i_aresetn;
                seq_item_h.o_interrupt    = dut_vi.o_interrupt;

                seq_item_h.i_s_tvalid    = dut_vi.i_s_tvalid;
                seq_item_h.o_s_tready    = dut_vi.o_s_tready;
                seq_item_h.i_s_tdata    = dut_vi.i_s_tdata;

                seq_item_h.o_m_tvalid    = dut_vi.o_m_tvalid;
                seq_item_h.i_m_tready    = dut_vi.i_m_tready;
                seq_item_h.o_m_tdata    = dut_vi.o_m_tdata;

                seq_item_h.i_awvalid    = dut_vi.i_awvalid;
                seq_item_h.o_awready    = dut_vi.o_awready;
                seq_item_h.i_awaddr    = dut_vi.i_awaddr;

                seq_item_h.i_wvalid    = dut_vi.i_wvalid;
                seq_item_h.o_wready    = dut_vi.o_wready;
                seq_item_h.i_wstrb    = dut_vi.i_wstrb;

                seq_item_h.o_bvalid    = dut_vi.o_bvalid;
                seq_item_h.i_bready    = dut_vi.i_bready;
                seq_item_h.o_bresp    = dut_vi.o_bresp;

                seq_item_h.i_arvalid    = dut_vi.i_arvalid;
                seq_item_h.o_arready    = dut_vi.o_arready;
                seq_item_h.i_araddr    = dut_vi.i_araddr;

                seq_item_h.o_rvalid    = dut_vi.o_rvalid;
                seq_item_h.i_rready    = dut_vi.i_rready;
                seq_item_h.o_rdata    = dut_vi.o_rdata;
                seq_item_h.o_rresp    = dut_vi.o_rresp;
                
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
                @(posedge dut_vi.i_aclk);
                seq_item_port.get_next_item(seq_item_h);
                dut_vi.i_aresetn    = seq_item_h.i_aresetn;
                dut_vi.i_s_tvalid    = seq_item_h.i_s_tvalid;
                dut_vi.i_s_tdata    = seq_item_h.i_s_tdata;
                dut_vi.i_m_tready    = seq_item_h.i_m_tready;
                dut_vi.i_awvalid    = seq_item_h.i_awvalid;
                dut_vi.i_awaddr    = seq_item_h.i_awaddr;
                dut_vi.i_wvalid    = seq_item_h.i_wvalid;
                dut_vi.i_wdata    = seq_item_h.i_wdata;
                dut_vi.i_wstrb    = seq_item_h.i_wstrb;
                dut_vi.i_bready    = seq_item_h.i_bready;
                dut_vi.i_arvalid    = seq_item_h.i_arvalid;
                dut_vi.i_araddr    = seq_item_h.i_araddr;
                dut_vi.i_rready    = seq_item_h.i_rready;
                
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