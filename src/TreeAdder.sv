
/*
    Description: 
    The TreeAdder module is a pipelined tree adder that
    work with any number of input terms. The TreeAdder 
    sums all of the terms on the "i_terms" port into a single 
    number after ceil_log2(NUM_TERMS) clock cycles.
*/
module TreeAdder #(parameter 
    WORD_WIDTH  = 8, 
    NUM_TERMS   = 3
    ) (
    input  logic i_clk,
    input  logic [WORD_WIDTH*NUM_TERMS-1:0] i_terms,
    output logic [WORD_WIDTH-1:0]           o_sum
    );

    timeunit 1ns/1ps;

    // Validate parameters
    if (WORD_WIDTH < 1)
        $error("Invalid Parameter: WORD_WIDTH < 1");
    if (NUM_TERMS < 2)
        $error("Invalid Parameter: NUM_TERMS < 2");

    function automatic int f(int n);
        // function to compute the number of 
        // pipeline registers required for tree adder

        int t;
        t = n/2 + n % 2;
        if (t == 1)
            return 1;
        return f(t) + t;
    endfunction

    localparam RESIDUAL = NUM_TERMS % 2;
    localparam NUM_BASE_SUM = NUM_TERMS/2 + RESIDUAL;
    localparam NUM_REGISTERS = f(NUM_TERMS);

    logic [WORD_WIDTH-1:0] r_partial [NUM_REGISTERS-1:0];

    assign o_sum = r_partial[NUM_REGISTERS-1];

    always_ff @(posedge i_clk) begin
        for (int i = 0; i < NUM_BASE_SUM-RESIDUAL; i++) begin
            r_partial[i] <= i_terms[WORD_WIDTH*(i*2)+:WORD_WIDTH] + i_terms[WORD_WIDTH*(i*2+1)+:WORD_WIDTH];
        end

        if (RESIDUAL) begin
            r_partial[NUM_BASE_SUM-1] <= i_terms[WORD_WIDTH*(NUM_TERMS-1)+:WORD_WIDTH];
        end

        for (int l = NUM_BASE_SUM, n = 0; l > 1; l = $ceil(l/2.0)) begin
            for (int i = 0; i < l/2; i++) begin
                r_partial[i + l + n] <= r_partial[i*2 + n] + r_partial[i*2+1 + n];
            end

            if (l % 2 == 1) begin
                r_partial[l-1+int'($ceil(l/2.0))+n] <= r_partial[l-1+n];
            end
            n += l;
        end
    end

endmodule