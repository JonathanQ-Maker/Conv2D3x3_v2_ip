

package seq_pkg;
    import uvm_pkg::*;
    `include "definitions.svh"
    `include "uvm_macros.svh"

    class seq_item extends uvm_sequence_item;
        `uvm_object_utils(seq_item)

        rand bit i_aresetn;
        logic o_interrupt;

        ///////////////////////////////////
        // Slave AXI4 Stream
        ///////////////////////////////////
        rand bit i_s_tvalid;
        logic o_s_tready;
        rand bit [`TRANSFER_WIDTH-1:0] i_s_tdata;

        ///////////////////////////////////
        // Master AXI4 Stream
        ///////////////////////////////////
        logic o_m_tvalid;
        rand bit i_m_tready;
        logic [`TRANSFER_WIDTH-1:0] o_m_tdata;

        ///////////////////////////////////
        // Slave AXI4 Lite
        ///////////////////////////////////
        // write addr
        rand bit i_awvalid;
        logic o_awready;
        rand bit [`ADDR_WIDTH-1:0] i_awaddr;

        // write data
        rand bit i_wvalid;
        logic o_wready;
        rand bit [31:0] i_wdata;
        rand bit [32/8-1:0] i_wstrb;

        // write response
        logic o_bvalid;
        rand bit i_bready;
        logic [1:0] o_bresp;

        // read addr
        rand bit i_arvalid;
        logic o_arready;
        rand bit [`ADDR_WIDTH-1:0] i_araddr;

        // read data
        logic o_rvalid;
        rand bit i_rready;
        logic [31:0] o_rdata;
        logic [1:0] o_rresp;


        function new(string name = "");
            super.new(name);
        endfunction

        function string convert2string;
            string s;
            s = super.convert2string();
            $sformat(s, "%s\n %s\n", s, this.get_name());

            $sformat(s, "%s i_aresetn \t%0d\n", s, i_aresetn);
            $sformat(s, "%s o_interrupt \t%0d\n", s, o_interrupt);

            $sformat(s, "%s i_s_tvalid \t%0d\n", s, i_s_tvalid);
            $sformat(s, "%s o_s_tready \t%0d\n", s, o_s_tready);
            $sformat(s, "%s i_s_tdata \t%0d\n", s, i_s_tdata);
            
            $sformat(s, "%s o_m_tvalid \t%0d\n", s, o_m_tvalid);
            $sformat(s, "%s i_m_tready \t%0d\n", s, i_m_tready);
            $sformat(s, "%s o_m_tdata \t%0d\n", s, o_m_tdata);

            $sformat(s, "%s i_awvalid \t%0d\n", s, i_awvalid);
            $sformat(s, "%s o_awready \t%0d\n", s, o_awready);
            $sformat(s, "%s i_awaddr \t%0d\n", s, i_awaddr);

            $sformat(s, "%s i_wvalid \t%0d\n", s, i_wvalid);
            $sformat(s, "%s o_wready \t%0d\n", s, o_wready);
            $sformat(s, "%s i_wdata \t%0d\n", s, i_wdata);
            $sformat(s, "%s i_wstrb \t%0d\n", s, i_wstrb);

            $sformat(s, "%s o_bvalid \t%0d\n", s, o_bvalid);
            $sformat(s, "%s i_bready \t%0d\n", s, i_bready);
            $sformat(s, "%s o_bresp \t%0d\n", s, o_bresp);
            
            $sformat(s, "%s i_arvalid \t%0d\n", s, i_arvalid);
            $sformat(s, "%s o_arready \t%0d\n", s, o_arready);
            $sformat(s, "%s i_araddr \t%0d\n", s, i_araddr);

            $sformat(s, "%s o_rvalid \t%0d\n", s, o_rvalid);
            $sformat(s, "%s i_rready \t%0d\n", s, i_rready);
            $sformat(s, "%s o_rdata \t%0d\n", s, o_rdata);
            $sformat(s, "%s o_rresp \t%0d\n", s, o_rresp);

            return s;
        endfunction

        function void do_copy(uvm_object rhs);
            seq_item seq_item_h;
            $cast(seq_item_h, rhs);
            i_aresetn       = seq_item_h.i_aresetn;
            o_interrupt       = seq_item_h.o_interrupt;

            i_s_tvalid       = seq_item_h.i_s_tvalid;
            o_s_tready       = seq_item_h.o_s_tready;
            i_s_tdata       = seq_item_h.i_s_tdata;

            o_m_tvalid       = seq_item_h.o_m_tvalid;
            i_m_tready       = seq_item_h.i_m_tready;
            o_m_tdata       = seq_item_h.o_m_tdata;

            i_awvalid       = seq_item_h.i_awvalid;
            o_awready       = seq_item_h.o_awready;
            i_awaddr       = seq_item_h.i_awaddr;

            i_wvalid       = seq_item_h.i_wvalid;
            o_wready       = seq_item_h.o_wready;
            i_wdata       = seq_item_h.i_wdata;
            i_wstrb       = seq_item_h.i_wstrb;

            o_bvalid       = seq_item_h.o_bvalid;
            i_bready       = seq_item_h.i_bready;
            o_bresp       = seq_item_h.o_bresp;

            i_arvalid       = seq_item_h.i_arvalid;
            o_arready       = seq_item_h.o_arready;
            i_araddr       = seq_item_h.i_araddr;

            o_rvalid       = seq_item_h.o_rvalid;
            i_rready       = seq_item_h.i_rready;
            o_rdata       = seq_item_h.o_rdata;
            o_rresp       = seq_item_h.o_rresp;
        endfunction
        
        function bit do_compare(uvm_object rhs, uvm_comparer comparer);
            seq_item seq_item_h;
            bit status;
            $cast(seq_item_h, rhs);
            status = 1;

            status &= (i_aresetn       == seq_item_h.i_aresetn);
            status &= (o_interrupt       == seq_item_h.o_interrupt);

            status &= (i_s_tvalid       == seq_item_h.i_s_tvalid);
            status &= (o_s_tready       == seq_item_h.o_s_tready);
            status &= (i_s_tdata       == seq_item_h.i_s_tdata);

            status &= (o_m_tvalid       == seq_item_h.o_m_tvalid);
            status &= (i_m_tready       == seq_item_h.i_m_tready);
            status &= (o_m_tdata       == seq_item_h.o_m_tdata);

            status &= (i_awvalid       == seq_item_h.i_awvalid);
            status &= (o_awready       == seq_item_h.o_awready);
            status &= (i_awaddr       == seq_item_h.i_awaddr);

            status &= (i_wvalid       == seq_item_h.i_wvalid);
            status &= (o_wready       == seq_item_h.o_wready);
            status &= (i_wdata       == seq_item_h.i_wdata);
            status &= (i_wstrb       == seq_item_h.i_wstrb);

            status &= (o_bvalid       == seq_item_h.o_bvalid);
            status &= (i_bready       == seq_item_h.i_bready);
            status &= (o_bresp       == seq_item_h.o_bresp);

            status &= (i_arvalid       == seq_item_h.i_arvalid);
            status &= (o_arready       == seq_item_h.o_arready);
            status &= (i_araddr       == seq_item_h.i_araddr);

            status &= (o_rvalid       == seq_item_h.o_rvalid);
            status &= (i_rready       == seq_item_h.i_rready);
            status &= (o_rdata       == seq_item_h.o_rdata);

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