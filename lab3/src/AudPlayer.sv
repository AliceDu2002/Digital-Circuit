module AudPlayer (
    input i_rst_n,
	input i_bclk,
	input i_daclrck,
	input i_en, // enable AudPlayer only when playing audio, work with AudDSP
	input[15:0] i_dac_data, //dac_data
	output o_aud_dacdat
);

// -----status-----
parameter S_IDLE = 3'd0;    // wait for i_en
parameter S_WAIT = 3'd1;  // wait for left channel signal and one clock
parameter S_SEND = 3'd2;  // send 16 bits 
parameter S_WAIT_L = 3'd3;

// -----logic-----
logic [2:0] state_r, state_w;
logic [4:0] count_r, count_w;
logic o_dac_dat_r, o_dac_dat_w;
logic [15:0] i_dac_dat_r, i_dac_dat_w;

// -----output-----
assign o_aud_dacdat = o_dac_dat_r;

always_comb begin
	// design your control here
    state_w = state_r;
    count_w = count_r;
    i_dac_dat_w = i_dac_dat_r;
    o_dac_dat_w = o_dac_dat_r;

    case(state_r) 
        S_IDLE: begin
            if(i_en) begin
                state_w = S_WAIT;
                i_dac_dat_w = i_dac_data;
            end
        end
        S_WAIT: begin 
            // extra wait might cause noise
            if(i_daclrck && !count_r) begin
                count_w = count_r + 1;
            end
            else if(i_daclrck && count_r) begin
                state_w = S_SEND;
                count_w = 15;
            end
        end
        S_SEND: begin
            o_dac_dat_w = i_dac_dat_r[count_r];
            count_w = count_r - 1;
            if(count_r == 0) begin
                state_w = S_WAIT_L;
                count_w = 0;
            end
        end
        S_WAIT_L: begin
             o_dac_dat_w = 0;
            if(!i_daclrck) begin
                state_w = S_IDLE;
            end
        end
    endcase
end

always_ff @(posedge i_bclk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= 2'd0;
        count_r <= 6'd0;
        i_dac_dat_r <= 16'd0;
        o_dac_dat_r <= 1'd0;
	end
	else begin
		state_r <= state_w;
        count_r <= count_w;
        i_dac_dat_r <= i_dac_dat_w;
        o_dac_dat_r <= o_dac_dat_w;
	end
end

endmodule