/*
    Description:
    This multiplier module multiplies takes in a collection of 
    A terms and B terms to multiply in corresponding position.
    Furthermore, this multiplier uses DSP48E1 slices with 3 
    pipelined registers for maximum operating frequency.

    NOTE:
    The output "o_products" port reflects the product after
    3 clock cycles due to pipelining.

*/
(* use_dsp = "yes" *) // forces DSP slices
module MulDSP #(parameter
    WORD_WIDTH  = 8, 
    NUM_TERMS   = 72
    ) (
    input  logic i_clk,
    input  logic [WORD_WIDTH*NUM_TERMS-1:0] i_terms_a,
    input  logic [WORD_WIDTH*NUM_TERMS-1:0] i_terms_b,
    output logic [WORD_WIDTH*NUM_TERMS-1:0] o_products
    );

    timeunit 1ns/1ps;

    // Validate parameters
    if (WORD_WIDTH < 1)
        $error("Invalid Parameter: WORD_WIDTH < 1");
    if (NUM_TERMS < 1)
        $error("Invalid Parameter: NUM_TERMS < 1");

    logic [WORD_WIDTH-1:0] a0 [NUM_TERMS-1:0];
    logic [WORD_WIDTH-1:0] a1 [NUM_TERMS-1:0];
    logic [WORD_WIDTH-1:0] b0 [NUM_TERMS-1:0];
    logic [WORD_WIDTH-1:0] b1 [NUM_TERMS-1:0];

    always_ff @(posedge i_clk) begin
        for (int i = 0; i < NUM_TERMS; i++) begin
            // pipelined registers to allow the 
            // inference of full speed DSP slice
            a0[i] <= i_terms_a[(WORD_WIDTH*i)+: WORD_WIDTH];
            a1[i] <= a0[i];

            b0[i] <= i_terms_b[(WORD_WIDTH*i)+: WORD_WIDTH];
            b1[i] <= b0[i];

            // actual multiplication
            o_products[(WORD_WIDTH*i)+: WORD_WIDTH] <= a1[i] * b1[i];
        end
    end

endmodule