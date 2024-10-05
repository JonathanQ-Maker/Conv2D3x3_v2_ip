module test #(parameter 
    WIDTH  = 8
    ) (
    input  logic i_clk,
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b, 
    output logic [WIDTH-1:0] out
    );

    localparam TERMS = 72;

    logic [TERMS*WIDTH-1:0] terms_a, terms_b, products;

    always_ff @(posedge i_clk) begin
        terms_a <= { a, terms_a[TERMS*WIDTH-1:WIDTH]};
        terms_b <= { b, terms_b[TERMS*WIDTH-1:WIDTH]};
    end

    MulDSP #(.WORD_WIDTH(WIDTH), .NUM_TERMS(TERMS)) mul
    (
        .i_clk(i_clk),
        .i_terms_a(terms_a),
        .i_terms_b(terms_b),
        .o_products(products)
    );

    TreeAdder #(.WORD_WIDTH(WIDTH), .NUM_TERMS(TERMS)) dsp 
    (
        .i_clk(i_clk),
        .i_terms(products),
        .o_sum(out)
    );

endmodule