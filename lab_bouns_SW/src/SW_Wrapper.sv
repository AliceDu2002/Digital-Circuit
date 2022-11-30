
`define REF_MAX_LENGTH              128
`define READ_MAX_LENGTH             128

`define REF_LENGTH                  128
`define READ_LENGTH                 128

//* Score parameters
`define DP_SW_SCORE_BITWIDTH        10

`define CONST_MATCH_SCORE           1
`define CONST_MISMATCH_SCORE        -4
`define CONST_GAP_OPEN              -6
`define CONST_GAP_EXTEND            -1

module SW_Wrapper (
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest
);

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// Feel free to design your own FSM!
localparam S_RX   = 3'd0;
localparam S_GET  = 3'd1;
localparam S_CALC = 3'd2;
localparam S_TX   = 3'd3;
localparam S_SEND = 3'd4;

// wire and register
logic [2:0] state_w, state_r;
logic [255:0] sref_w, sref_r; // i_sequence_ref
logic [255:0] sread_w, sread_r; // i_sequence_read
logic [4:0] avm_address_r, avm_address_w; // avm_address
logic avm_read_r, avm_read_w; // avm_read
logic avm_write_r, avm_write_w; // avm_write
logic [63:0] score, column, row; // get from Core
logic [247:0] writedata_r, writedata_w; // output sequence
logic [20:0] count_r, count_w; // automatically read next sequences
logic i_valid_r, i_valid_w, i_ready_r, i_ready_w;
logic [6:0] bytes_counter_r, bytes_counter_w;
logic read_key_r, read_key_w;

// output
assign avm_address = avm_address_r;
assign avm_read = avm_read_r;
assign avm_write = avm_write_r;
assign avm_writedata = writedata_r[247-:8];

// Remember to complete the port connection
SW_core sw_core(
    .clk				(avm_clk),
    .rst				(avm_rst),

	.o_ready			(out_ready),
    .i_valid			(i_valid_r),
    .i_sequence_ref		(sref_r),
    .i_sequence_read	(sread_r),
    .i_seq_ref_length	(8'd128),
    .i_seq_read_length	(8'd128),
    
    .i_ready			(i_ready_r),
    .o_valid			(out_valid),
    .o_alignment_score	(score),
    .o_column			(column),
    .o_row				(row)
);

task StartRead;
    input [4:0] addr;
    begin
        avm_read_w = 1;
        avm_write_w = 0;
        avm_address_w = addr;
    end
endtask
task StartWrite;
    input [4:0] addr;
    begin
        avm_read_w = 0;
        avm_write_w = 1;
        avm_address_w = addr;
    end
endtask
task GoQuery;
    begin
        StartRead(STATUS_BASE);
        state_w = S_RX;
        bytes_counter_w = bytes_counter_r - 7'd1;
    end
endtask

// TODO
always_comb begin
    state_w = state_r;
    sref_w = sref_r;
    sread_w = sread_r;
    avm_address_w = avm_address_r;
    avm_read_w = avm_read_r;
    avm_write_w = avm_write_r;
    writedata_w = writedata_r;
    count_w = count_r;
    i_valid_w = i_valid_r;
    i_ready_w = i_ready_r;
    bytes_counter_w = bytes_counter_r;
    read_key_w = read_key_r;

    case(state_r)
        S_RX: begin
            StartRead(STATUS_BASE);
            count_w = count_r + 21'd1;
            if(!avm_waitrequest && avm_readdata[RX_OK_BIT]) begin
                StartRead(RX_BASE);
                state_w = S_GET;
            end
            else begin
                state_w = S_RX;
                if(count_r >= 50000 && !read_key_r) begin
                    read_key_w = 1;
                    bytes_counter_w = 63;
                end
            end            
        end
        S_GET: begin
            count_w = 0;
            read_key_w = 1;
            if(!avm_waitrequest) begin
                if(bytes_counter_r >= 32) begin
                    sref_w[8*(bytes_counter_r - 32)+:8] = avm_readdata[7:0];
                    GoQuery();
                end
                else if(bytes_counter_r > 0) begin
                    sread_w[8*(bytes_counter_r)+:8] = avm_readdata[7:0];
                    GoQuery();
                end
                else begin
                    sread_w[8*(bytes_counter_r)+:8] = avm_readdata[7:0];
                    state_w = S_CALC;
                    StartRead(STATUS_BASE);
                    i_valid_w = 1;
                    i_ready_w = 1;
                end
            end
        end
        S_CALC: begin
            i_valid_w = 0;
            state_w = S_CALC;
            StartRead(STATUS_BASE);
            if(out_valid) begin
                writedata_w[63:0] = score;
                writedata_w[127:64] = row;
                writedata_w[191:128] = column;
                writedata_w[247:192] = 0; // NULL???
                state_w = S_TX;
                StartRead(STATUS_BASE);
                bytes_counter_w = 30;
            end

            // test
            // writedata_w = 247'd912837;
            // state_w = S_TX;
            // StartRead(STATUS_BASE);
            // bytes_counter_w = 31;
        end
        S_TX: begin
            StartRead(STATUS_BASE);
            if(!avm_waitrequest && avm_readdata[TX_OK_BIT]) begin
                StartWrite(TX_BASE);
                state_w = S_SEND;
            end
            else begin
                state_w = S_TX;
            end
        end
        S_SEND: begin
            if(!avm_waitrequest) begin
                writedata_w = writedata_r << 8;
                StartRead(STATUS_BASE);
                state_w = S_TX;
                bytes_counter_w = bytes_counter_r - 1;
                if(bytes_counter_r == 0) begin
                    i_ready_w = 0;
                    state_w = S_RX;
                    StartRead(STATUS_BASE);
                    count_w = 0;
                    read_key_w = 0;
                    bytes_counter_w = 63;
                end
            end
        end
    endcase
end

// TODO
always_ff @(posedge avm_clk or posedge avm_rst) begin
    if (avm_rst) begin
    	state_r <= S_RX;
        sref_r <= 256'd0;
        sread_r <= 256'd0;
        avm_address_r <= STATUS_BASE;
        avm_read_r <= 1;
        avm_write_r <= 0;
        writedata_r <= 248'd0;
        count_r <= 21'd0;
        i_ready_r <= 0;
        i_valid_r <= 0;
        bytes_counter_r <= 63;
        read_key_r <= 1;
    end
	else begin
    	state_r <= state_w;
        sref_r <= sref_w;
        sread_r <= sread_w;
        avm_address_r <= avm_address_w;
        avm_read_r <= avm_read_w;
        avm_write_r <= avm_write_w;
        writedata_r <= writedata_w;
        count_r <= count_w;
        i_ready_r <= i_ready_w;
        i_valid_r <= i_valid_w;
        bytes_counter_r <= bytes_counter_w;
        read_key_r <= read_key_w;
    end
end

endmodule
