`define IMG_ROW 480
`define IMG_COL 640
`define BUF_SIZE 642
`define TABLE_ENTRY 200
`define TABLE_ENTRY_SIZE 8
`define BUF_ENTRY_SIZE 8
`define PIXEL_TABLE_SIZE 15

module Blob(
    input i_clk,
    input i_rst,
    input i_valid,
    input i_seq,
    output o_valid,
    output [7:0] o_count
);

logic [`BUF_ENTRY_SIZE-1:0] buffer_r,buffer_w [`BUF_SIZE-1:0];
logic [`TABLE_ENTRY_SIZE-1:0] tisch_r [`TABLE_ENTRY-1:0];
logic [`TABLE_ENTRY_SIZE-1:0] tisch_w [`TABLE_ENTRY-1:0];

logic [`PIXEL_TABLE_SIZE-1:0] pixels_r [`TABLE_ENTRY-1:0];
logic [`PIXEL_TABLE_SIZE-1:0] pixels_w [`TABLE_ENTRY-1:0];

parameter S_IDLE = 0;
parameter S_PROC = 1;
parameter S_MERGE = 2;
parameter S_FINDMAX = 3;
parameter S_COUNT = 4;
parameter S_DONE = 5;

logic [2:0] state_r, state_w;
logic [9:0] counter_r, counter_w;
logic isFistRow_r, isFirstRow_w;
logic [`BUF_ENTRY_SIZE-1:0] category_w;
logic [`BUF_ENTRY_SIZE-1:0] curcat_r, curcat_w;


// Combinantial
always_comb begin
    // Default Values
    state_w = state_r
    counter_w = counter_r
    isFirstRow_w = isFirstRow_r;

    case(state_r)
        S_IDLE: begin
            if (i_valid) begin
                state_w = S_PROC
            end
        end

        S_PROC: begin
            if (counter_r < 640 && isFirstRow_r) begin      // Ignore first row
                counter_w = counter_r + 1;
            end
            else if (isFirstRow_r) begin                    // First row finished
                counter_w = 0;
                isFirstRow_w = 0;
            end
            else begin                                      // Start blob algorithm
                if (counter_r == 0 || !i_seq) begin                   // left side
                    category_w = 0;
                    counter_w = counter_r + 1;
                end
                else if (counter_r == 639) begin            // right side
                    category_w = 0;
                    counter_w = 0;
                end
                else begin
                    if (buffer_r[`BUF_SIZE-1] > 0) begin
                        category_w = buffer_r[`BUF_SIZE-1];
                        pixels_w[buffer_r[`BUF_SIZE-1]] = pixels_r[buffer_r[`BUF_SIZE-1]] + 1;
                        if (buffer_r[1]>0 && buffer_r[1]!=buffer[`BUF_SIZE-1]) begin
                            if (tisch_r[buffer_r[`BUF_SIZE-1]] > tisch_r[buffer_r[1]]) begin
                                tisch_w[tisch_r[buffer_r[`BUF_SIZE-1]]] = tisch_r[buffer_r[1]];
                            end
                            else if (tisch_r[buffer_r[`BUF_SIZE-1]] > tisch_r[buffer_r[1]]) begin
                                tisch_w[tisch_r[buffer_r[1]]] = tisch_r[buffer_r[`BUF_SIZE-1]];
                            end
                        end
                    end
                    else if (buffer_r[1] > 0) begin
                        pixels_w[buffer_r[1]] = pixels_r[buffer_r[1]] + 1;
                        category_w = buffer_r[1];
                    end
                    else if (buffer_r[2] > 0) begin
                        pixels_w[buffer_r[2]] = pixels_r[buffer_r[2]] + 1;
                        category_w = buffer_r[2];
                    end
                    else begin
                        category_w = curcat_r + 1;
                        curcat_w = curcat_r + 1;
                        tisch_w[curcat_r+1] = curcat_r+1;
                    end
                end
            end
        end

    endcase
end

endmodule

