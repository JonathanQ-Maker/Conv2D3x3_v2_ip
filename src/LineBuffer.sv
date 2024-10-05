
/*
    Description: 
    The LineBuffer is a special type of FIFO buffer. The LineBuffer 
    stores data and only outputs the data when the buffer is full
    depending on the depth loaded.

    NOTE: 
    The LineBuffer has to be initalized before writing can begin. 
    Initalize the LineBuffer by asserting "i_load_depth" to high,
    this will load in the value on "i_depth" as the maximum depth of 
    the LineBuffer. Reset (sync, active low) will automatically 
    default the depth to MAX_DEPTH. Before writing, initalze again
    to override this setting. 
*/
module LineBuffer #(parameter 
    WIDTH       = 8,
    MAX_DEPTH   = 512
    ) (
    input  logic             i_clk,
    input  logic             i_reset_n,

    // depth setting port
    input  logic             i_load_depth,
    input  logic [$clog2(MAX_DEPTH):0] i_depth,

    // write port
    input  logic             i_wr_valid,
    input  logic [WIDTH-1:0] i_wr_data,

    // read port
    output logic             o_rd_valid,
    output logic [WIDTH-1:0] o_rd_data
    );

    timeunit 1ns/1ps;

    // Validate parameters
    if (WIDTH < 1)
        $error("Invalid Parameter: WIDTH < 1");
    if (MAX_DEPTH < 2)
        $error("Invalid Parameter: MAX_DEPTH < 2");

    logic [$clog2(MAX_DEPTH-1)-1:0] r_wr_addr, r_rd_addr; // addresses
    logic [$clog2(MAX_DEPTH):0] r_count, r_depth;
    
    // the actual buffer
    logic [WIDTH-1:0] r_buf [MAX_DEPTH-2:0];
    logic [WIDTH-1:0] r_buf_stage_0, r_buf_stage_1;
    logic [WIDTH-1:0] r_stages [1:0];
    logic [1:0] r_sel;

    always_ff @(posedge i_clk) begin
        if (!i_reset_n) begin
            // synchronous reset logic
            r_wr_addr       <= 0;
            r_rd_addr       <= 0;
            r_count         <= MAX_DEPTH;
            r_depth         <= MAX_DEPTH;
            o_rd_valid      <= 0;
            r_sel           <= 0;
        end
        else if (i_load_depth) begin
            r_wr_addr       <= 0;
            r_rd_addr       <= 0;
            r_count         <= i_depth;
            r_depth         <= i_depth;
            o_rd_valid      <= 0;
            r_sel           <= 0;
        end
        else if (i_wr_valid) begin

            if (r_count != 0)
                r_count <= r_count - 1;

            // write data
            r_buf[r_wr_addr] <= i_wr_data;

            // update write address
            if (r_wr_addr == MAX_DEPTH-2)
                r_wr_addr <= 0;
            else
                r_wr_addr <= r_wr_addr + 1;

            // update read address
            if (r_count <= 2) begin
                if (r_rd_addr == MAX_DEPTH-2)
                    r_rd_addr <= 0;
                else
                    r_rd_addr <= r_rd_addr + 1;
            end

            o_rd_valid <= r_count <= 1;
            
            // read data
            r_buf_stage_0 <= r_buf[r_rd_addr];
            r_buf_stage_1 <= r_buf_stage_0;

            r_stages <= { r_stages[0], i_wr_data };
            r_sel <= r_depth == 2;

            // r_sel
            if (r_depth == 2)
                r_sel <= 1;
            if (r_depth > 2)
                r_sel <= 2;
        end
    
    end

    always_comb begin
        case (r_sel)
            2'b00   : o_rd_data = r_stages[0];
            2'b01   : o_rd_data = r_stages[1];
            2'b10   : o_rd_data = r_buf_stage_1;
            default : o_rd_data = r_buf_stage_1;
        endcase
    end

endmodule