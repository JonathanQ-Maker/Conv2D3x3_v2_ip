
module Controller #(parameter
    MAX_IMG_WIDTH       = 128,
    MAX_IMG_HEIGHT      = 128,
    MAX_TRANSFERS       = 512,
    MAX_LINE_DEPTH      = 8192,
    MAX_KERNEL_DEPTH    = 512,

    // AIX4 Lite parameters
    AXI_WIDTH = 32
    ) (
    input  logic i_aclk,
    input  logic i_aresetn,
    output logic o_interrupt,

    ///////////////////////////////////
    // Slave AXI4 Stream
    ///////////////////////////////////
    input  logic i_s_tvalid,
    output logic o_s_tready,

    ///////////////////////////////////
    // Master AXI4 Stream
    ///////////////////////////////////
    output  logic o_m_tvalid,
    input  logic i_m_tready,

    ///////////////////////////////////
    // Slave AXI4 Lite
    ///////////////////////////////////
    // write addr
    input  logic i_awvalid,
    output logic o_awready,
    input  logic [AXI_WIDTH-1:0] i_awaddr,

    // write data
    input  logic i_wvalid,
    output logic o_wready,
    input  logic [AXI_WIDTH-1:0] i_wdata,
    input  logic [AXI_WIDTH/8-1:0] i_wstrb,

    // write response
    output logic o_bvalid,
    input  logic i_bready,
    output logic [1:0] o_bresp,

    // read addr
    input  logic i_arvalid,
    output logic o_arready,
    input  logic [AXI_WIDTH-1:0] i_araddr,

    // read data
    output logic o_rvalid,
    input  logic i_rready,
    output logic [AXI_WIDTH-1:0] o_rdata,
    output logic [1:0] o_rresp,


    ///////////////////////////////////
    // Other signals
    ///////////////////////////////////

    input  logic i_kernel_last_data,
    output logic o_load_param,
    output logic o_kernel_tvalid,
    output logic o_window_tvalid,
    input  logic i_next_window_valid,
    input  logic i_last_window,
    input  logic i_window_last_data,
    output logic o_pad,
    output logic [15:0] o_width,
    output logic [15:0] o_height,
    output logic [15:0] o_transfers,
    output logic [15:0] o_filters,
    output logic [$clog2(MAX_KERNEL_DEPTH)-1:0] o_sel,
    output logic o_dsp_in_valid,
    input  logic i_dsp_out_valid,
    output logic o_sel_valid,
    input  logic i_last_window_result
    );

    timeunit 1ns/1ps;
    
    ///////////////////////////////////
    // Slave AXI4 Lite
    ///////////////////////////////////

    localparam AXI_RANGE = 4;

    // Validate parameters
    if (AXI_WIDTH != 32 && AXI_WIDTH != 64)
        $error("Invalid Parameter: AXI_WIDTH != 32 && AXI_WIDTH != 64");

    localparam ADDR_SHIFT = $clog2(AXI_WIDTH/8);
    localparam MEM_ADDR_BITS = $clog2(AXI_RANGE);

    // addresses
    logic [MEM_ADDR_BITS-1:0] w_araddr, w_awaddr;
    assign w_araddr  = i_araddr[ADDR_SHIFT+: MEM_ADDR_BITS];
    assign w_awaddr  = i_awaddr[ADDR_SHIFT+: MEM_ADDR_BITS];

    // backpressure
    logic w_backpressure;
    assign w_backpressure = !i_bready && o_bvalid;

    // ready
    logic r_awready, r_wready;
    assign o_awready = r_awready && !w_backpressure;
    assign o_wready  = r_wready && !w_backpressure;

    // resp
    assign o_bresp = 0;
    assign o_rresp = 0;

    // write/read
    logic w_axi_write, w_axi_read;
    assign w_axi_write = !(r_awready || r_wready);
    assign w_axi_read = i_arvalid && o_arready;

    // write buffer
    logic [MEM_ADDR_BITS-1:0] r_awaddr;
    logic [AXI_WIDTH-1:0] r_wdata;
    logic [AXI_WIDTH/8-1:0] r_wstrb;

    logic w_addr_data_ready;
    assign w_addr_data_ready = (i_awvalid && o_awready && !r_wready) || (i_wvalid && o_wready && !r_awready) || (i_awvalid && o_awready && i_wvalid && o_wready);

    always_ff @( posedge i_aclk) begin : Control
        if (!i_aresetn) begin
            o_rvalid <= 0;
            o_bvalid <= 0;
            r_awready <= 1;
            r_wready  <= 1;
            o_arready <= 1;
        end
        else begin
            
            // Write Addr
            if (i_awvalid && o_awready) begin
                r_awready <= 0;
                r_awaddr  <= w_awaddr;
            end

            // Write Data
            if (i_wvalid && o_wready) begin
                r_wready  <= 0;
                r_wdata   <= i_wdata;
                r_wstrb   <= i_wstrb;
            end

            // Write Response
            if (o_bvalid && i_bready) begin
                o_bvalid <= 0;
            end

            if (w_addr_data_ready) begin
                o_bvalid <= 1;
            end

            // Read Addr
            if (i_arvalid && o_arready) begin
                o_arready <= 0;
                o_rvalid <= 1;
            end

            // Read Response
            if (o_rvalid && i_rready) begin
                o_rvalid <= 0;
                o_arready <= 1;
            end

            if (w_axi_write) begin
                r_awready <= 1; 
                r_wready  <= 1;
            end

        end
    end : Control




    ///////////////////////////////
    // Actual Write Read blocks
    ///////////////////////////////

    function [AXI_WIDTH-1:0] apply_wstrb(
        input logic [AXI_WIDTH-1:0] prior_data,
        input logic [AXI_WIDTH-1:0] new_data,
        input logic [AXI_WIDTH/8-1:0] wstrb
        );

		for(int i = 0; i < AXI_WIDTH/8; i++) begin
			apply_wstrb[i*8 +: 8] = wstrb[i] ? new_data[i*8 +: 8] : prior_data[i*8 +: 8];
		end
	endfunction



    /////////////////////////////////////////
    // registers
    /////////////////////////////////////////

    /*
     * Register Definitions (r_control)
     * Read/Write
     *
     * Offset: 0x0
     * Bit [0] (Enable):
     *  0: Disable
     *  1: Enable
     * Bit [1] (Zero Pad):
     *  0: No pad
     *  1: Pad
     * Bit [2] (Cyclic Mode):
     *  0: Disable
     *  1: Enable
     * Bit [3] (Interrupt Enable):
     *  0: Disable
     *  1: Enable
    */
    logic [31:0] r_control;

    /*
     * Register Definitions (r_dim)
     * Read/Write
     * 
     * Offset: 0x4
     * Bits [15:0]: Image Width (REQUIRED: 3 <= width <= MAX_IMG_WIDTH)
     * Bits [31:16]: Image Height (REQUIRED: 3 <= height <= MAX_IMG_HEIGHT) 
    */
    logic [31:0] r_dim;
    logic [15:0] w_width, w_height;

    assign w_width  = r_dim[15:0];
    assign w_height = r_dim[31:16];

    /*
     * Register Definitions (r_sizes)
     * Read/Write
     * 
     * Offset: 0x8
     * Bits [15:0]: Number of image channels (REQUIRED: 1 <= transfers <= MAX_IMG_TRANSFERS) 
     * Bits [31:16]: Number of kernel filters 
    */
    logic [31:0] r_sizes;
    logic [15:0] w_transfers, w_filters;

    assign w_transfers = r_sizes[15:0];
    assign w_filters = r_sizes[31:16];

    /*
     * Register Definitions (r_status)
     * Read Only
     * 
     * Offset: 0x12
     * Bits [0] (Idle):
     *  0: Not Idle
     *  1: Idle
     * Bits [1] (Width Error):
     *  0: No Error
     *  1: Error
     * Bits [2] (Height Error):
     *  0: No Error
     *  1: Error
     * Bits [3] (Number of Transfers Error):
     *  0: No Error
     *  1: Error
     * Bits [4] (Number of Filters Error):
     *  0: No Error
     *  1: Error
     * Bits [5] (Image buffer Overflow Error):
     *  0: No Error
     *  1: Error
     * Bits [6] (Kernel buffer Overflow Error):
     *  0: No Error
     *  1: Error
     * Bits [8] (Interrupt):
     *  0: No Interrupt
     *  1: Interrupt was generated
     *  NOTE: Read and Write Clear
     *
    */
    logic [31:0] r_status;

    // Copied registers to prevent unsafe toggling during execution
    logic r_cyclic, r_enable;
    logic w_idle;

    always_ff @(posedge i_aclk) begin
        if (!i_aresetn) begin


        end
        else begin
            if (w_axi_write) begin
                case(r_awaddr) 
                    2'd0 : begin
                        if (i_wstrb[0]) begin
                            r_control[3:0] <= r_wdata[3:0];
                            
                            if (!r_wdata[0]) begin
                                r_enable <= 0;
                            end
                        end
                    end

                    2'd1 : r_dim <= apply_wstrb(r_dim, r_wdata, r_wstrb);
                    2'd2 : r_sizes <= apply_wstrb(r_sizes, r_wdata, r_wstrb);
                    2'd3 : if (r_wstrb[1]) r_status[8] <= 0;
                endcase
            end

            if (w_axi_read) begin
                case(w_araddr) 
                    2'd0 : o_rdata <= r_control;
                    2'd1 : o_rdata <= r_dim;
                    2'd2 : o_rdata <= r_sizes;
                    2'd3 : o_rdata <= { r_status[31:1], w_idle };
                endcase
            end
        end

    end





    ///////////////////////////////////
    // Control Logic
    ///////////////////////////////////

    assign o_interrupt = r_status[8];

    logic w_done;
    logic w_clear_en;
    logic w_load_param;
    logic w_set_IRQ;
    logic w_load_kernel, w_next_load_kernel;
    logic w_process, w_next_process;
    logic w_validate_param;

    logic r_param_valid;
    logic [$clog2(MAX_KERNEL_DEPTH):0] r_sel_filter, r_filter_count;
    logic [$clog2(MAX_KERNEL_DEPTH):0] r_sel_transfer;
    logic [$clog2(MAX_KERNEL_DEPTH)-1 : 0] r_sel;
    logic r_s_tready;
    logic r_flush;

    assign o_load_param = w_load_param;

    ControlFSM fsm (
        .i_clk(i_aclk),
        .i_reset_n(i_aresetn),
        .i_en(r_control[0]),
        .i_flush(r_flush),
        .i_param_valid(r_param_valid),
        .i_full(i_kernel_last_data && o_kernel_tvalid),
        .i_done(w_done),
        .i_IRQEn(r_control[3]),
        .i_IRQ_reg(r_status[8]),

        .o_validate_param(w_validate_param),
        .o_clear_en(w_clear_en),
        .o_load_param(w_load_param),
        .o_set_IRQ(w_set_IRQ),
        .o_load_kernel(w_load_kernel),
        .o_next_load_kernel(w_next_load_kernel),
        .o_process(w_process),
        .o_next_process(w_next_process),
        .o_idle(w_idle)
    );

    logic w_width_valid;
    assign w_width_valid = w_width >= 3 && w_width <= MAX_IMG_WIDTH;

    logic w_height_valid;
    assign w_height_valid = w_height >= 3 && w_height <= MAX_IMG_HEIGHT;

    logic w_transfers_valid;
    assign w_transfers_valid = w_transfers > 0;

    logic w_filters_valid;
    assign w_filters_valid = w_filters > 0;

    logic w_img_buf_valid;
    assign w_img_buf_valid = w_width * w_transfers <= MAX_LINE_DEPTH;

    logic w_kernel_buf_valid;
    assign w_kernel_buf_valid = w_filters * w_transfers <= MAX_KERNEL_DEPTH;


    always_ff @(posedge i_aclk) begin
        if (!i_aresetn) begin
            r_control       <= 0;
            r_dim           <= { 16'd3, 16'd3 };
            r_sizes         <= { 16'd1, 16'd1 };
            r_status        <= 0;
            r_cyclic        <= 0;
            r_enable        <= 0;
        end
        else begin
            if (w_validate_param) begin
                // save parameters
                o_filters   <= w_filters;
                o_transfers <= w_transfers;
                o_width     <= w_width;
                o_height    <= w_height;

                o_pad       <= r_control[1];
                r_cyclic    <= r_control[2];
                r_enable    <= 1;

                // validate parameters
                r_param_valid <= w_width_valid
                    && w_height_valid
                    && w_transfers_valid
                    && w_filters_valid
                    && w_img_buf_valid
                    && w_kernel_buf_valid;

                r_status[1] <= !w_width_valid;
                r_status[2] <= !w_height_valid;
                r_status[3] <= !w_transfers_valid;
                r_status[4] <= !w_filters_valid;
                r_status[5] <= !w_img_buf_valid;
                r_status[6] <= !w_kernel_buf_valid;
            end

            if (w_clear_en && !w_axi_write && r_awaddr == 2'd0) begin
                r_control[0] <= 0;
            end
            
            if (w_set_IRQ && !w_axi_write && r_awaddr == 2'd3)
                r_status[8] <= 1;
        end
    end



    logic r_window_valid;
    logic r_first_process;

    logic w_back_pressure;
    assign w_back_pressure  = o_m_tvalid && !i_m_tready;

    logic w_next_clk_window_ready;
    assign w_next_clk_window_ready = (o_window_tvalid && i_next_window_valid) || (r_window_valid && !o_window_tvalid);

    logic w_next_clk_last_filter;
    assign w_next_clk_last_filter = (o_dsp_in_valid && r_filter_count == 2) || o_filters == 1 || (!o_dsp_in_valid && r_filter_count == 1);
    
    assign o_sel            = r_sel;
    assign o_kernel_tvalid  = w_load_kernel && (i_s_tvalid && o_s_tready);
    assign o_window_tvalid  = w_process && ((i_s_tvalid && o_s_tready) || (!w_back_pressure && r_flush && r_filter_count == 1 && o_pad));
    assign w_done           = i_last_window_result && o_m_tvalid && i_m_tready;

    assign o_dsp_in_valid   = r_window_valid && !w_back_pressure && (r_filter_count != 1 || o_window_tvalid || r_flush) && w_process;

    assign o_sel_valid      = o_dsp_in_valid || r_first_process;

    assign o_s_tready       = r_s_tready && !w_back_pressure;

    always_ff @(posedge i_aclk) begin
        if (!i_aresetn) begin
            r_s_tready      <= 0;
            o_m_tvalid      <= 0;
        end
        else if (w_load_param) begin
            r_window_valid <= 0;
            o_m_tvalid <= 0;
            r_first_process <= 0;
            r_flush <= 0;
        end
        else begin

            // r_s_tready
            if (w_next_load_kernel)
                r_s_tready <= 1;
            else if (w_next_process)
                r_s_tready <= (!w_next_clk_window_ready || w_next_clk_last_filter) && !r_flush;
            else
                r_s_tready <= 0;

            // r_window_valid
            if (o_window_tvalid)
                r_window_valid <= i_next_window_valid;

            // o_m_tvalid
            if (o_dsp_in_valid)
                o_m_tvalid <= i_dsp_out_valid;
            else if (i_m_tready)
                o_m_tvalid <= 0;

            // r_first_process
            r_first_process <= w_next_process && w_load_kernel;

            // r_flush
            if (o_window_tvalid && i_window_last_data && !(r_enable && r_cyclic))
                r_flush <= 1;
        end
    end

    always_ff @(posedge i_aclk) begin
        if (!i_aresetn) begin

        end 
        else if (w_load_param) begin
            r_filter_count      <= o_filters;

            r_sel_filter        <= o_filters;
            r_sel_transfer      <= o_transfers;

            r_sel               <= 0;
        end
        else begin

            // Kernel select pre-updater
            if (o_sel_valid) begin
                if (r_sel_filter == 1) begin
                    r_sel_filter <= o_filters;
                    if (r_sel_transfer == 1) begin
                        r_sel_transfer <= o_transfers;
                        r_sel <= 0;
                    end
                    else begin
                        r_sel <= r_sel + 1;
                        r_sel_transfer <= r_sel_transfer - 1;
                    end
                end
                else begin
                    r_sel <= r_sel + 1;
                    r_sel_filter <= r_sel_filter - 1;
                end
            end

            // Filter to be inserted updater
            if (o_dsp_in_valid) begin
                if (r_filter_count == 1) begin
                    r_filter_count <= o_filters;
                end
                else begin
                    r_filter_count <= r_filter_count - 1;
                end
            end


        end
    end



endmodule