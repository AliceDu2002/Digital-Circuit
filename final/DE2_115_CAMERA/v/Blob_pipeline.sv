`define IMG_ROW 480
`define IMG_COL 640
`define BUF_SIZE 642
`define TABLE_ENTRY 128
`define TABLE_ENTRY_SIZE 7
`define BUF_ENTRY_SIZE 7
`define PIXEL_ENTRY_SIZE 15

module Blob_pipeline(
    input i_clk,
    input i_rst_n,
    input i_valid,
    input i_seq,
    output o_valid,
    output [7:0] o_count
);

logic [`BUF_ENTRY_SIZE-1:0] buffer_r [`BUF_SIZE-1:0];
logic [`BUF_ENTRY_SIZE-1:0] buffer_w [`BUF_SIZE-1:0];
logic [`TABLE_ENTRY_SIZE-1:0] tisch_r [`TABLE_ENTRY-1:0];
logic [`TABLE_ENTRY_SIZE-1:0] tisch_w [`TABLE_ENTRY-1:0];

logic [`PIXEL_ENTRY_SIZE-1:0] pixels_r [`TABLE_ENTRY-1:0];
logic [`PIXEL_ENTRY_SIZE-1:0] pixels_w [`TABLE_ENTRY-1:0];

parameter S_IDLE = 0;
parameter S_PROC = 1;
parameter S_MERGE = 2;
parameter S_FINDMAX = 3;
parameter S_COUNT = 4;
parameter S_OUTPUT = 5;
parameter S_DONE = 6;

logic [2:0] state_r, state_w;
logic [9:0] counter_r, counter_w;
logic [18:0] isEnd_r, isEnd_w;

logic isFirstRow_r, isFirstRow_w;
logic isNew_r, isNew_w;
logic [9:0] ptr_r, ptr_w;
logic [`BUF_ENTRY_SIZE-1:0] category_w;
logic [`BUF_ENTRY_SIZE-1:0] curcat_r, curcat_w;
logic [`PIXEL_ENTRY_SIZE-1:0] largest_category_r, largest_category_w; 
logic [7:0] final_count_r, final_count_w;
logic o_valid_r, o_valid_w;

assign o_count = final_count_r;
assign o_valid = o_valid_r;

// combinantial
always_comb begin
    
    for(int i=0; i<`TABLE_ENTRY; i=i+1) begin
        tisch_w[i] = tisch_r[i];
        pixels_w[i] = pixels_r[i];
    end
    for(int i=0; i<`BUF_SIZE; i=i+1) begin
        buffer_w[i] = buffer_r[i];
    end
    state_w = state_r;
    largest_category_w = largest_category_r;
    final_count_w = final_count_r;
    counter_w = counter_r;
    isFirstRow_w = isFirstRow_r;
    curcat_w = curcat_r;
    category_w = 0;
    o_valid_w = o_valid_r;
    isNew_w = isNew_r;
    ptr_w = ptr_r;
    isEnd_w = isEnd_r;

    case(state_r)
        S_IDLE: begin
            if(i_valid) begin
                state_w = S_PROC;
                isFirstRow_w = 1;
            end
            largest_category_w = 0;
        end
        S_PROC: begin
            if (isEnd_r == `IMG_COL*`IMG_ROW) begin
                state_w = S_MERGE;
                counter_w = `TABLE_ENTRY-1;
            end
            if (counter_r < `IMG_COL && isFirstRow_r) begin      // Ignore first row
                counter_w = counter_r + 1;
                isEnd_w = isEnd_r + 1;
            end
            else if (isFirstRow_r) begin                    // First row finished
                counter_w = 0;
                isFirstRow_w = 0;
                isEnd_w = isEnd_r + 1;
            end
            else if (counter_r == `IMG_COL-1) begin            // right side
                isEnd_w = isEnd_r + 1;
                category_w = 0;
                counter_w = 0;
                ptr_w = 0;
            end
            else if (counter_r == 10'd0) begin
                isEnd_w = isEnd_r + 1;
                category_w = 0;
                counter_w = counter_r + 1;
                ptr_w = 0;
            end
            else if (!i_seq) begin                   // left side
                isEnd_w = isEnd_r + 1;
                category_w = 0;
                counter_w = counter_r +1;
                ptr_w = 0;
            end
            else if (i_seq && buffer_r[`BUF_SIZE-1] != 0) begin
                isEnd_w = isEnd_r + 1;
                counter_w = counter_r + 1;
                category_w = buffer_r[`BUF_SIZE-1];
                if (ptr_r < `BUF_SIZE) begin
                    ptr_w = ptr_r + 1;
                end
                pixels_w[buffer_r[`BUF_SIZE-1]] = pixels_r[buffer_r[`BUF_SIZE-1]] + 1;
                if (buffer_r[2] != 0 && (buffer_r[2]!=buffer_r[`BUF_SIZE-1])) begin
                    if (tisch_r[buffer_r[`BUF_SIZE-1]] > tisch_r[buffer_r[2]] && isNew_r == 0) begin
                        category_w = buffer_r[`BUF_SIZE-1];
                        tisch_w[buffer_r[`BUF_SIZE-1]] = buffer_r[2];
                    end
                    else if (tisch_r[buffer_r[`BUF_SIZE-1]] > tisch_r[buffer_r[2]]) begin
                        isNew_w = 0;
                        for (int i=0; i<200; i=i+1) begin
                            if(i<ptr_r+1) begin
                                buffer_w[`BUF_SIZE-1-i] = buffer_r[2];
                            end
                        end
                        pixels_w[buffer_r[2]] = pixels_r[buffer_r[2]] + ptr_r + 2;
                        pixels_w[curcat_r] = 0;
                        curcat_w = curcat_r - 1;
                        tisch_w[curcat_r] = 0;
                        category_w = buffer_r[2];
                    end
                    else if (tisch_r[buffer_r[`BUF_SIZE-1]] < tisch_r[buffer_r[2]]) begin
                        tisch_w[buffer_r[2]] = buffer_r[`BUF_SIZE-1];
                        isNew_w = 0;
                    end
                end
            end
            else if (i_seq && buffer_r[1] != 0) begin
                isEnd_w = isEnd_r + 1;
                counter_w = counter_r + 1;
                pixels_w[buffer_r[1]] = pixels_r[buffer_r[1]] + 1;
                category_w = buffer_r[1];
                isNew_w = 0;
                ptr_w = 0;
            end
            else if (i_seq && buffer_r[2] != 0) begin
                isEnd_w = isEnd_r + 1;
                counter_w = counter_r + 1;
                pixels_w[buffer_r[2]] = pixels_r[buffer_r[2]] + 1;
                category_w = buffer_r[2];
                isNew_w = 0;
                ptr_w = 0;
            end
            else if (i_seq) begin
                isEnd_w = isEnd_r + 1;
                counter_w = counter_r + 1;
                category_w = curcat_r + 1;
                curcat_w = curcat_r + 1;
                pixels_w[curcat_r+1] = 1;
                tisch_w[curcat_r+1] = curcat_r+1;
                ptr_w = 0;
                isNew_w = 1;
            end
        end
        S_MERGE: begin
            if(counter_r != 0) begin
                if(counter_r != tisch_r[counter_r] && (tisch_r[counter_r] != 0)) begin
                    // tisch_r[counter_r] must be the destination, since it is smaller
                    pixels_w[tisch_r[counter_r]] = pixels_r[tisch_r[counter_r]] + pixels_r[counter_r];
                    pixels_w[counter_r] = 0;
                end
                counter_w = counter_r-1;
                state_w = S_MERGE;
            end
            else begin
                // no need to process in 0th table entry (it is the most special one)
                counter_w = 0;
                state_w = S_FINDMAX;
            end
        end
        S_FINDMAX: begin
            if(counter_r != `TABLE_ENTRY) begin
                if(largest_category_r<pixels_r[counter_r]) begin
                    largest_category_w = pixels_r[counter_r];
                end
                state_w = S_FINDMAX;
                counter_w = counter_r+1;
            end
            else begin
                counter_w = 0;
                state_w = S_COUNT;
            end
        end
        S_COUNT: begin
            if(counter_r != `TABLE_ENTRY) begin
                if(pixels_r[counter_r] > largest_category_r>>3) begin
                    final_count_w = final_count_r+1;
                end
                counter_w = counter_r+1;
            end
            else begin
                state_w = S_OUTPUT;
            end
        end
        S_OUTPUT: begin
            o_valid_w = 1;
            state_w = S_DONE;
        end
        S_DONE: begin
            o_valid_w = 0;
            state_w = S_IDLE;
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        state_r <= S_IDLE;
        for(int i=0; i<`BUF_SIZE; i=i+1) begin
            buffer_r[i] <= 0;
        end
        for(int i=0; i<`TABLE_ENTRY; i=i+1) begin
            tisch_r[i] <= 0;
            pixels_r[i] <= 0;
        end
        largest_category_r <= 0;
        final_count_r <= 0;
        isFirstRow_r <= 0;
        curcat_r <= 0;
        counter_r <= 0;
        o_valid_r <= 0;
        isNew_r <= 0;
        ptr_r <= 0; 
        isEnd_r <= 0;
    end
    else begin
        largest_category_r <= largest_category_w;
        for(int i=0; i<`BUF_SIZE-1; i=i+1) begin
            buffer_r[i] <= buffer_w[i+1];
        end
        buffer_r[`BUF_SIZE-1] <= category_w; 
        for(int i=0; i<`TABLE_ENTRY; i=i+1) begin
            tisch_r[i] <= tisch_w[i];
            pixels_r[i] <= pixels_w[i];
        end
        state_r <= state_w;
        final_count_r <= final_count_w;
        isFirstRow_r <= isFirstRow_w;
        curcat_r <= curcat_w;
        counter_r <= counter_w;
        o_valid_r <= o_valid_w;
        isNew_r <= isNew_w;
        ptr_r <= ptr_w;
        isEnd_r <= isEnd_w;
    end
end
endmodule

