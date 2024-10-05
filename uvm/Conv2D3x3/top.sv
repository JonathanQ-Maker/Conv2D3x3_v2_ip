`include "definitions.svh"
`include "uvm_macros.svh"

interface dut_if;

    logic i_aclk;
    logic i_aresetn;
    logic o_interrupt;

    ///////////////////////////////////
    // Slave AXI4 Stream
    ///////////////////////////////////
    logic i_s_tvalid;
    logic o_s_tready;
    logic [`TRANSFER_WIDTH-1:0] i_s_tdata;

    ///////////////////////////////////
    // Master AXI4 Stream
    ///////////////////////////////////
    logic o_m_tvalid;
    logic i_m_tready;
    logic [`TRANSFER_WIDTH-1:0] o_m_tdata;

    ///////////////////////////////////
    // Slave AXI4 Lite
    ///////////////////////////////////
    // write addr
    logic i_awvalid;
    logic o_awready;
    logic [`ADDR_WIDTH-1:0] i_awaddr;

    // write data
    logic i_wvalid;
    logic o_wready;
    logic [31:0] i_wdata;
    logic [32/8-1:0] i_wstrb;

    // write response
    logic o_bvalid;
    logic i_bready;
    logic [1:0] o_bresp;

    // read addr
    logic i_arvalid;
    logic o_arready;
    logic [`ADDR_WIDTH-1:0] i_araddr;

    // read data
    logic o_rvalid;
    logic i_rready;
    logic [31:0] o_rdata;
    logic [1:0] o_rresp;

endinterface

module top;
    import uvm_pkg::*;
    import rand_test_pkg::*;
    import load_test_pkg::*;

    dut_if dut_if_h();
    
    Conv2D3x3 #(
        .TRANSFER_WIDTH(`TRANSFER_WIDTH), 
        .WORD_WIDTH(`WORD_WIDTH),

        .MAX_IMG_WIDTH(`MAX_IMG_WIDTH),
        .MAX_IMG_HEIGHT(`MAX_IMG_HEIGHT),
        .MAX_TRANSFERS(`MAX_TRANSFERS),

        .MAX_LINE_DEPTH(`MAX_LINE_DEPTH),
        .MAX_KERNEL_DEPTH(`MAX_KERNEL_DEPTH),
        
        .ADDR_WIDTH(`ADDR_WIDTH)
    ) dut 
    (
        .i_aclk(dut_if_h.i_aclk),
        .i_aresetn(dut_if_h.i_aresetn),
        .o_interrupt(dut_if_h.o_interrupt),

        .i_s_tvalid(dut_if_h.i_s_tvalid),
        .o_s_tready(dut_if_h.o_s_tready),
        .i_s_tdata(dut_if_h.i_s_tdata),

        .o_m_tvalid(dut_if_h.o_m_tvalid),
        .i_m_tready(dut_if_h.i_m_tready),
        .o_m_tdata(dut_if_h.o_m_tdata),

        .i_awvalid(dut_if_h.i_awvalid),
        .o_awready(dut_if_h.o_awready),
        .i_awaddr(dut_if_h.i_awaddr),

        .i_wvalid(dut_if_h.i_wvalid),
        .o_wready(dut_if_h.o_wready),
        .i_wdata(dut_if_h.i_wdata),
        .i_wstrb(dut_if_h.i_wstrb),

        .o_bvalid(dut_if_h.o_bvalid),
        .i_bready(dut_if_h.i_bready),
        .o_bresp(dut_if_h.o_bresp),

        .i_arvalid(dut_if_h.i_arvalid),
        .o_arready(dut_if_h.o_arready),
        .i_araddr(dut_if_h.i_araddr),

        .o_rvalid(dut_if_h.o_rvalid),
        .i_rready(dut_if_h.i_rready),
        .o_rdata(dut_if_h.o_rdata),
        .o_rresp(dut_if_h.o_rresp)
    );

    initial begin
        dut_if_h.i_aclk = 0;
        forever #5 dut_if_h.i_aclk = ~dut_if_h.i_aclk;
    end

    initial begin
        uvm_config_db #(virtual dut_if)::set(null, "*", "dut_if_h", dut_if_h);
        uvm_top.finish_on_completion = 1; // call $finish() when objections drop

        run_test();
    end
endmodule