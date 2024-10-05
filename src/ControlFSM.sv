module ControlFSM (
    input logic i_clk,
    input logic i_reset_n,

    input logic i_en,
    input logic i_flush,
    input logic i_param_valid,
    input logic i_full,
    input logic i_done,
    input logic i_IRQEn,
    input logic i_IRQ_reg,

    output logic o_validate_param,
    output logic o_clear_en,
    output logic o_load_param,
    output logic o_set_IRQ,
    output logic o_load_kernel,
    output logic o_next_load_kernel,
    output logic o_process,
    output logic o_next_process,
    output logic o_idle
    );

    typedef enum logic [2:0] { IDLE, VALID_PARAM, LOAD_PARAM, LOAD_KERNEL, PROCESS, IRQ } State;

    State r_curr_state, w_next_state;

    always_ff @(posedge i_clk) begin
        if (!i_reset_n) begin
            // reset logic
            r_curr_state <= IDLE;
        end
        else begin
            r_curr_state <= w_next_state;
        end
    end

    always_comb begin : NextState
        unique case (r_curr_state)
            IDLE : begin
                if (i_en)
                    w_next_state = VALID_PARAM;
                else
                    w_next_state = IDLE;
            end

            VALID_PARAM : begin
                if (i_param_valid)
                    w_next_state = LOAD_PARAM;
                else
                    w_next_state = IDLE;
            end

            LOAD_PARAM : begin
                w_next_state = LOAD_KERNEL;
            end

            LOAD_KERNEL : begin
                if (i_full)
                    w_next_state = PROCESS;
                else
                    w_next_state = LOAD_KERNEL;
            end

            PROCESS : begin
                if (i_done) begin
                    if (i_IRQEn) begin
                        w_next_state = IRQ;
                    end
                    else begin
                        if (!i_flush) begin
                            w_next_state = PROCESS;
                        end
                        else begin
                            w_next_state = IDLE;
                        end
                    end
                end
                else begin
                    w_next_state = PROCESS;
                end
            end

            IRQ : begin
                if (i_IRQ_reg) begin
                    w_next_state = IRQ;
                end
                else if (!i_flush) begin
                    w_next_state = PROCESS;
                end
                else begin
                    w_next_state = IDLE;
                end
            end

        endcase        
    end

    always_comb begin : DecodeState
        o_load_param        = r_curr_state == LOAD_PARAM;
        o_set_IRQ           = r_curr_state == PROCESS && w_next_state == IRQ;
        o_clear_en          = r_curr_state != IDLE && w_next_state == IDLE;
        o_load_kernel       = r_curr_state == LOAD_KERNEL;
        o_next_load_kernel  = w_next_state == LOAD_KERNEL;
        o_process           = r_curr_state == PROCESS;
        o_next_process      = w_next_state == PROCESS;
        o_idle              = r_curr_state == IDLE;
        o_validate_param    = w_next_state == VALID_PARAM;
    end

endmodule