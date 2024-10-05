package ref_model_pkg;
    import uvm_pkg::*;
    import seq_pkg::*;

    `include "definitions.svh"
    `include "uvm_macros.svh"

    class ref_model_sub extends uvm_subscriber #(seq_item);
        `uvm_component_utils(ref_model_sub)

        int transactions, correct;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        logic [$clog2(`MAX_IMG_WIDTH) : 0] width;
        logic [$clog2(`MAX_IMG_HEIGHT) : 0] height;
        logic [$clog2(`MAX_TRANSFERS) : 0] transfers;

        logic window_valid;

        logic [`WORD_WIDTH-1:0] window_00;
        logic [`WORD_WIDTH-1:0] window_01;
        logic [`WORD_WIDTH-1:0] window_02;

        logic [`WORD_WIDTH-1:0] window_10;
        logic [`WORD_WIDTH-1:0] window_11;
        logic [`WORD_WIDTH-1:0] window_12;

        logic [`WORD_WIDTH-1:0] window_20;
        logic [`WORD_WIDTH-1:0] window_21;
        logic [`WORD_WIDTH-1:0] window_22;

        logic [`WORD_WIDTH-1:0] buffer [`MAX_IMG_WIDTH*`MAX_TRANSFERS*2 + `MAX_TRANSFERS*3-1:0];
        
        int img_count, valid_count;

        function void predict(seq_item t);
            string s;
            if (!t.i_reset_n) begin
                width       = `MAX_IMG_WIDTH;
                height      = `MAX_IMG_HEIGHT;
                transfers   = `MAX_TRANSFERS;

                img_count       = 0;
                valid_count     = 0;
                window_valid    = 0;
            end
            else if (t.i_load_param) begin
                width       = t.i_width;
                height      = t.i_height;
                transfers   = t.i_transfers;

                img_count       = 0;
                valid_count     = 0;
                window_valid    = 0;
            end
            else if (t.i_valid) begin

                buffer = { buffer[`MAX_IMG_WIDTH*`MAX_TRANSFERS*2 + `MAX_TRANSFERS*3-2:0], t.i_data };

                if (valid_count == width*transfers*3)
                    valid_count = width*transfers*2 + 1;
                else
                    valid_count++;

                if (img_count == width*height*transfers) begin
                    img_count = 1;
                    valid_count = 1;
                end
                else
                    img_count++;

                window_valid = (valid_count >= width*transfers*2 + transfers*2 + 1) && width >= 3 && height >= 3 && transfers >= 1;
            end

            window_20 = buffer[transfers*2];
            window_21 = buffer[transfers];
            window_22 = buffer[0];

            window_10 = buffer[width*transfers + transfers*2];
            window_11 = buffer[width*transfers + transfers];
            window_12 = buffer[width*transfers];

            window_00 = buffer[width*transfers*2 + transfers*2];
            window_01 = buffer[width*transfers*2 + transfers];
            window_02 = buffer[width*transfers*2];

        endfunction

        function void verify(seq_item t);
            bit matched = 1;
            if (window_valid != t.o_next_window_valid) begin
                matched = 0;
                `uvm_error("ref_model", $sformatf("\n o_next_window_valid missmatch %d != %d", t.o_next_window_valid, window_valid));
            end

            
            if (window_valid) begin
                

                if (window_00 != t.o_window_00) begin
                    matched = 0;
                    `uvm_error("ref_model", $sformatf("\n o_window_00 missmatch %d != %d", t.o_window_00, window_00));
                end

                if (window_01 != t.o_window_01) begin
                    matched = 0;
                    `uvm_error("ref_model", $sformatf("\n o_window_01 missmatch %d != %d", t.o_window_01, window_01));
                end

                if (window_02 != t.o_window_02) begin
                    matched = 0;
                    `uvm_error("ref_model", $sformatf("\n o_window_02 missmatch %d != %d", t.o_window_02, window_02));
                end



                if (window_10 != t.o_window_10) begin
                    matched = 0;
                    `uvm_error("ref_model", $sformatf("\n o_window_10 missmatch %d != %d", t.o_window_10, window_10));
                end

                if (window_11 != t.o_window_11) begin
                    matched = 0;
                    `uvm_error("ref_model", $sformatf("\n o_window_11 missmatch %d != %d", t.o_window_11, window_11));
                end

                if (window_12 != t.o_window_12) begin
                    matched = 0;
                    `uvm_error("ref_model", $sformatf("\n o_window_12 missmatch %d != %d", t.o_window_12, window_12));
                end



                if (window_20 != t.o_window_20) begin
                    matched = 0;
                    `uvm_error("ref_model", $sformatf("\n o_window_20 missmatch %d != %d", t.o_window_20, window_20));
                end

                if (window_21 != t.o_window_21) begin
                    matched = 0;
                    `uvm_error("ref_model", $sformatf("\n o_window_21 missmatch %d != %d", t.o_window_21, window_21));
                end

                if (window_22 != t.o_window_22) begin
                    matched = 0;
                    `uvm_error("ref_model", $sformatf("\n o_window_22 missmatch %d != %d", t.o_window_22, window_22));
                end
            end

            // record matches
            transactions++;
            if (matched)
                correct++;
        endfunction
        
        function void write(seq_item t);
            verify(t);
            predict(t);
            `uvm_info("ref_model", t.convert2string(), UVM_MEDIUM);
        endfunction

        function void report_phase(uvm_phase phase);
            `uvm_info("ref_model", $sformatf("\n\n--- REFERENCE MODEL MATCHES: (%0d/%0d) ---\n\n", correct, transactions), UVM_MEDIUM);
        endfunction

    endclass : ref_model_sub

endpackage