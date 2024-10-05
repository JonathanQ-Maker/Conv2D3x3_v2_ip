module Conv2D3x3 #(parameter
    // Global Parameters
    TRANSFER_WIDTH      = 8,
    WORD_WIDTH          = 8,

    // Window parameters
    MAX_IMG_WIDTH       = 128,
    MAX_IMG_HEIGHT      = 128,
    MAX_TRANSFERS       = 512,

    MAX_LINE_DEPTH      = 8192,
    MAX_KERNEL_DEPTH    = 512, // NOTE: Also max filters

    // AIX4 Lite parameters
    ADDR_WIDTH          = 32
    ) (
    input  logic i_aclk,
    input  logic i_aresetn,
    output logic o_interrupt,

    ///////////////////////////////////
    // Slave AXI4 Stream
    ///////////////////////////////////
    input  logic i_s_tvalid,
    output logic o_s_tready,
    input  logic [TRANSFER_WIDTH-1:0] i_s_tdata,

    ///////////////////////////////////
    // Master AXI4 Stream
    ///////////////////////////////////
    output logic o_m_tvalid,
    input  logic i_m_tready,
    output logic [WORD_WIDTH-1:0] o_m_tdata,

    ///////////////////////////////////
    // Slave AXI4 Lite
    ///////////////////////////////////
    // write addr
    input  logic i_awvalid,
    output logic o_awready,
    input  logic [ADDR_WIDTH-1:0] i_awaddr,

    // write data
    input  logic i_wvalid,
    output logic o_wready,
    input  logic [31:0] i_wdata,
    input  logic [32/8-1:0] i_wstrb,

    // write response
    output logic o_bvalid,
    input  logic i_bready,
    output logic [1:0] o_bresp,

    // read addr
    input  logic i_arvalid,
    output logic o_arready,
    input  logic [ADDR_WIDTH-1:0] i_araddr,

    // read data
    output logic o_rvalid,
    input  logic i_rready,
    output logic [31:0] o_rdata,
    output logic [1:0] o_rresp
    );

    logic w_kernel_last_data;
    logic w_load_param;
    logic w_kernel_tvalid;
    logic w_window_tvalid;
    logic w_next_window_valid;
    logic w_last_window;
    logic w_window_last_data;
    logic w_pad;
    logic [15:0] w_width;
    logic [15:0] w_height;
    logic [15:0] w_transfers;
    logic [15:0] w_filters;
    logic [$clog2(MAX_KERNEL_DEPTH)-1:0] w_sel;
    logic w_dsp_in_valid;
    logic w_dsp_out_valid;
    logic w_sel_valid;
    logic w_last_window_result;


    Controller #(
        .MAX_IMG_WIDTH(MAX_IMG_WIDTH), 
        .MAX_IMG_HEIGHT(MAX_IMG_HEIGHT),
        .MAX_TRANSFERS(MAX_TRANSFERS),
        .MAX_LINE_DEPTH(MAX_LINE_DEPTH),
        .MAX_KERNEL_DEPTH(MAX_KERNEL_DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) controller 
    (
        // global signal
        .i_aclk(i_aclk),
        .i_aresetn(i_aresetn),
        .o_interrupt(o_interrupt),

        // slave AXI4 stream
        .i_s_tvalid(i_s_tvalid),
        .o_s_tready(o_s_tready),

        // Master AXI4 stream
        .o_m_tvalid(o_m_tvalid),
        .i_m_tready(i_m_tready),

        // Slave AXI4 lite
        .i_awvalid(i_awvalid),
        .o_awready(o_awready),
        .i_awaddr(i_awaddr),

        .i_wvalid(i_wvalid),
        .o_wready(o_wready),
        .i_wdata(i_wdata),
        .i_wstrb(i_wstrb),

        .o_bvalid(o_bvalid),
        .i_bready(i_bready),
        .o_bresp(o_bresp),

        .i_arvalid(i_arvalid),
        .o_arready(o_arready),
        .i_araddr(i_araddr),

        .o_rvalid(o_rvalid),
        .i_rready(i_rready),
        .o_rdata(o_rdata),
        .o_rresp(o_rresp),

        // Other signals
        .i_kernel_last_data(w_kernel_last_data),
        .o_load_param(w_load_param),
        .o_kernel_tvalid(w_kernel_tvalid),
        .o_window_tvalid(w_window_tvalid),
        .i_next_window_valid(w_next_window_valid),
        .i_last_window(w_last_window),
        .i_window_last_data(w_window_last_data),
        .o_pad(w_pad),
        .o_width(w_width),
        .o_height(w_height),
        .o_transfers(w_transfers),
        .o_filters(w_filters),
        .o_sel(w_sel),
        .o_dsp_in_valid(w_dsp_in_valid),
        .i_dsp_out_valid(w_dsp_out_valid),
        .o_sel_valid(w_sel_valid),
        .i_last_window_result(w_last_window_result)
    );


    logic [TRANSFER_WIDTH-1:0] w_window_00;
    logic [TRANSFER_WIDTH-1:0] w_window_01;
    logic [TRANSFER_WIDTH-1:0] w_window_02;

    logic [TRANSFER_WIDTH-1:0] w_window_10;
    logic [TRANSFER_WIDTH-1:0] w_window_11;
    logic [TRANSFER_WIDTH-1:0] w_window_12;

    logic [TRANSFER_WIDTH-1:0] w_window_20;
    logic [TRANSFER_WIDTH-1:0] w_window_21;
    logic [TRANSFER_WIDTH-1:0] w_window_22;

    WindowBuffer3x3 #(
        .WORD_WIDTH(TRANSFER_WIDTH), 
        .MAX_IMG_WIDTH(MAX_IMG_WIDTH),
        .MAX_IMG_HEIGHT(MAX_IMG_HEIGHT),
        .MAX_TRANSFERS(MAX_TRANSFERS),
        .MAX_LINE_DEPTH(MAX_LINE_DEPTH)
    ) window_buf
    (
        // global signal
        .i_clk(i_aclk),
        .i_reset_n(i_aresetn),

        // load parameter
        .i_load_param(w_load_param),
        .i_pad(w_pad),
        .i_pad_val({TRANSFER_WIDTH{1'b0}}),  // zero pad
        .i_width(w_width[$clog2(MAX_IMG_WIDTH):0]),
        .i_height(w_height[$clog2(MAX_IMG_HEIGHT):0]),
        .i_transfers(w_transfers[$clog2(MAX_TRANSFERS):0]),

        // flag signal
        .o_last_data(w_window_last_data),
        .o_last_window(w_last_window),

        // Input stream
        .i_valid(w_window_tvalid),
        .i_data(i_s_tdata),

        // Window output
        .o_next_window_valid(w_next_window_valid),

        .o_window_00(w_window_00),
        .o_window_01(w_window_01),
        .o_window_02(w_window_02),

        .o_window_10(w_window_10),
        .o_window_11(w_window_11),
        .o_window_12(w_window_12),

        .o_window_20(w_window_20),
        .o_window_21(w_window_21),
        .o_window_22(w_window_22)
    );



    logic [TRANSFER_WIDTH-1:0] w_kernel_00;
    logic [TRANSFER_WIDTH-1:0] w_kernel_01;
    logic [TRANSFER_WIDTH-1:0] w_kernel_02;

    logic [TRANSFER_WIDTH-1:0] w_kernel_10;
    logic [TRANSFER_WIDTH-1:0] w_kernel_11;
    logic [TRANSFER_WIDTH-1:0] w_kernel_12;

    logic [TRANSFER_WIDTH-1:0] w_kernel_20;
    logic [TRANSFER_WIDTH-1:0] w_kernel_21;
    logic [TRANSFER_WIDTH-1:0] w_kernel_22;

    KernelBuffer3x3 #(
        .WORD_WIDTH(TRANSFER_WIDTH),
        .MAX_DEPTH(MAX_KERNEL_DEPTH)
    ) kernel_buf
    (
        .i_clk(i_aclk),
        .i_reset_n(i_aresetn),

        // load param
        .i_load_param(w_load_param),
        .i_filters(w_filters[$clog2(MAX_KERNEL_DEPTH):0]),
        .i_transfers(w_transfers[$clog2(MAX_KERNEL_DEPTH):0]),

        // input
        .i_valid(w_kernel_tvalid),
        .i_data(i_s_tdata),
        .o_last_data(w_kernel_last_data),

        // output
        .i_sel_valid(w_sel_valid),
        .i_sel(w_sel),

        .o_kernel_00(w_kernel_00),
        .o_kernel_01(w_kernel_01),
        .o_kernel_02(w_kernel_02),

        .o_kernel_10(w_kernel_10),
        .o_kernel_11(w_kernel_11),
        .o_kernel_12(w_kernel_12),

        .o_kernel_20(w_kernel_20),
        .o_kernel_21(w_kernel_21),
        .o_kernel_22(w_kernel_22)
    );


    ConvDSP #(
        .TRANSFER_WIDTH(TRANSFER_WIDTH),
        .WORD_WIDTH(WORD_WIDTH),
        .MAX_FILTERS(MAX_KERNEL_DEPTH),
        .MAX_TRANSFERS(MAX_TRANSFERS)
    ) dsp
    (
        .i_clk(i_aclk),
        .i_reset_n(i_aresetn),
        
        // load param
        .i_load_param(w_load_param),
        .i_filters(w_filters[$clog2(MAX_KERNEL_DEPTH):0]),
        .i_transfers(w_transfers[$clog2(MAX_TRANSFERS):0]),

        // window input
        .i_valid(w_dsp_in_valid),
        .i_last_window(w_last_window),

        .i_window_00(w_window_00),
        .i_window_01(w_window_01),
        .i_window_02(w_window_02),

        .i_window_10(w_window_10),
        .i_window_11(w_window_11),
        .i_window_12(w_window_12),

        .i_window_20(w_window_20),
        .i_window_21(w_window_21),
        .i_window_22(w_window_22),

        // kernel input
        .i_kernel_00(w_kernel_00),
        .i_kernel_01(w_kernel_01),
        .i_kernel_02(w_kernel_02),

        .i_kernel_10(w_kernel_10),
        .i_kernel_11(w_kernel_11),
        .i_kernel_12(w_kernel_12),

        .i_kernel_20(w_kernel_20),
        .i_kernel_21(w_kernel_21),
        .i_kernel_22(w_kernel_22),

        // output
        .o_next_valid(w_dsp_out_valid),
        .o_last_window_result(w_last_window_result),
        .o_data(o_m_tdata)
    );
    
endmodule