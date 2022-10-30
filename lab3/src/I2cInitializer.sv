module I2cInitializer(
    input i_rst_n,
    input i_clk,
    input i_start,
    output o_finished,
    output o_sclk,              // I2c clock
    output o_sdat,              // I2c data
    output o_oen                // output enable
);

// ===== WM8731 Register Map =====
parameter LLI = 24'b00110100_00000000_10010111;
parameter RLI = 24'b00110100_00000010_10010111;
parameter LHO = 24'b00110100_00000100_01111001;
parameter RHO = 24'b00110100_00000110_01111001;
parameter AAPC = 24'b00110100_00001000_00010101;
parameter DAPC = 24'b00110100_00001010_00000000;
parameter PDC = 24'b00110100_00001100_00000000;
parameter DAIF = 24'b00110100_00001110_01000010;
parameter SC = 24'b00110100_00010000_00011001;
parameter AC = 24'b00110100_00010010_00000001;

// ===== States =====
parameter S_IDLE = 3'd0;
parameter S_TRANSFER = 3'd1;
parameter S_OUTPUT = 3'd2;
parameter S_ACK = 3'd3;
parameter S_STOP = 3'd4;

// ===== Output Buffers =====
logic o_finished_r, o_finished_w;
logic o_sclk_r, o_sclk_w;
logic o_sdat_r, o_sdat_w;
logic o_oen_r, o_oen_w;

// ===== Registers & Wires =====
logic [2:0] state_r, state_w;
logic [3:0] count_r, count_w;
logic [3:0] wmindex_r, wmindex_w;
logic [4:0] bitindex_r, bitindex_w;

// ===== Array =====
logic [0:23] WMarray [9:0];

// ===== Output Assignments =====
assign o_finished = o_finished_r;
assign o_sclk = o_sclk_r;
assign o_sdat = o_sdat_r;
assign o_oen = o_oen_r;

// ===== Array Assignments =====
assign WMarray[9] = LLI;
assign WMarray[8] = RLI;
assign WMarray[7] = LHO;
assign WMarray[6] = RHO;
assign WMarray[5] = AAPC;
assign WMarray[4] = DAPC;
assign WMarray[3] = PDC;
assign WMarray[2] = DAIF;
assign WMarray[1] = SC;
assign WMarray[0] = AC;

// ===== Combinantial Circuit =====
always_comb begin
    // Default Values
    state_w = state_r;
    count_w = count_r;
    wmindex_w = wmindex_r;
    bitindex_w = bitindex_r;
    o_finished_w = o_finished_r;
    o_sclk_w = o_sclk_r;
    o_sdat_w = o_sdat_r;
    o_oen_w = o_oen_r;

    // FSM
    case(state_r)
        S_IDLE: begin
            if (i_start) begin
                o_sdat_w = 0;                   // pull down SDA, while SCL remains high
                state_w = S_TRANSFER;
            end
        end

        S_TRANSFER: begin
            if (o_sclk_r) begin
                o_sclk_w = 0;                   // pull down SCL to set the transferred bit
            end
            else begin
                if (!count_r && bitindex_r == 24) begin
                    o_oen_w = 1;
                    state_w = S_STOP;
                end
                else if (count_r != 8) begin
                    o_oen_w = 1;
                    o_sdat_w = WMarray[wmindex_r][bitindex_r];
                    state_w = S_OUTPUT;
                end
                else begin                      // every 8 bits, acknoledge bit is transmitted
                    o_oen_w = 0;
                    o_sdat_w = 0;
                    state_w = S_ACK;
                end
            end
        end

        S_OUTPUT: begin
            o_sclk_w = 1;                       // data is sampled when SCL rises
            count_w = count_r + 1;
            bitindex_w = bitindex_r + 1;
            state_w = S_TRANSFER;
        end

        S_ACK: begin
            o_sclk_w = 1;
            count_w = 0;
            state_w = S_TRANSFER;
        end

        S_STOP: begin
            if (!o_sclk_r) begin
                o_sclk_w = 1;
            end
            else begin
                o_sdat_w = 1;
                if (wmindex_r != 9) begin
                    if (o_sdat_r) begin
                        wmindex_w = wmindex_r + 1;
                        o_sdat_w = 0;
                        bitindex_w = 0;
                        state_w = S_TRANSFER;
                    end
                end
                else begin
                    o_finished_w = 1;           // if all 10 24-bit data in the register map are sent, finish the process
                end
            end
        end
    endcase
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
    // reset
    if (!i_rst_n) begin
        state_r         <= S_IDLE;
        o_sdat_r        <= 1'd1;
        o_sclk_r        <= 1'd1;
        count_r         <= 3'd0;
        bitindex_r      <= 5'd0;
        wmindex_r       <= 4'd0;
        o_oen_r         <= 1;
        o_finished_r    <= 0;
    end
    else begin
        state_r         <= state_w;
        o_sdat_r        <= o_sdat_w;
        o_sclk_r        <= o_sclk_w;
        count_r         <= count_w;
        bitindex_r      <= bitindex_w;
        wmindex_r       <= wmindex_w;
        o_oen_r         <= o_oen_w;
        o_finished_r    <= o_finished_w;     
    end
end

endmodule