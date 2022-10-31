module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0, // stop
	input i_key_1, // play
	input i_key_2, // recd
	 // key 3 is reset
	input [2:0] i_speed, // design how user can decide mode on your own

	input i_fast,
	input i_interpolation,
	
	// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT,

	// SEVENDECODER (optional display)
	output [5:0] o_record_time,
	output [5:0] o_play_time,

	// LCD (optional display)
	// input        i_clk_800k,
	// inout  [7:0] o_LCD_DATA,
	// output       o_LCD_EN,
	// output       o_LCD_RS,
	// output       o_LCD_RW,
	// output       o_LCD_ON,
	// output       o_LCD_BLON,

	// LED
	// output  [8:0] o_ledg,
	// output [17:0] o_ledr
);

// design the FSM and states as you like

parameter S_I2C	       = 0;
parameter S_IDLE       = 1;
parameter S_RECD       = 2;
parameter S_RECD_PAUSE = 3;
parameter S_PLAY       = 4;
parameter S_PLAY_PAUSE = 5;

logic i2c_oen, i2c_sdat;
logic i2c_start_r, i2c_start_w, i2c_finished_r, i2c_finished_w;
logic play_start_r, play_start_w, play_pause_r, play_pause_w;
logic rec_start_r, rec_start_w, rec_pause_r, rec_pause_w;
logic [2:0] state_r, state_w;
logic [19:0] addr_record, addr_play;
logic [15:0] data_record, data_play, dac_data;
logic [5:0] play_time, record_time;

assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;

assign o_SRAM_ADDR = (state_r == S_RECD) ? addr_record : addr_play[19:0];
assign io_SRAM_DQ  = (state_r == S_RECD) ? data_record : 16'dz; // sram_dq as output
assign data_play   = (state_r != S_RECD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

assign o_record_time = record_time;
assign o_play_time = play_time;

// below is a simple example for module division
// you can design these as you like

// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_start(i2c_start_r),
	.o_finished(i2c_finished_w),
	.o_sclk(o_I2C_SCLK),
	.o_sdat(i2c_sdat),
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_AUD_BCLK),
	.i_start(play_start_r),
	.i_pause(play_pause_r),
	.i_stop(i_key_0 || (addr_play > addr_record)),
	.i_speed(i_speed),
	.i_fast(i_fast && i_speed),
	.i_slow_0(!i_fast & !i_interpolation && i_speed), // constant interpolation
	.i_slow_1(!i_fast & i_interpolation && i_speed), // linear interpolation
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(data_play),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play),
	.o_second(play_time);
);

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_en(state_r == S_PLAY), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(o_AUD_DACDAT)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and save to SRAM
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(rec_start_r),
	.i_pause(rec_pause_r),
	.i_stop(i_key_0 || (addr_record > 20'b11111111111111111100)),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record),
	.o_data(data_record),
	.o_second(record_time)
);
/*
parameter S_I2C	       = 0;
parameter S_IDLE       = 1;
parameter S_RECD       = 2;
parameter S_RECD_PAUSE = 3;
parameter S_PLAY       = 4;
parameter S_PLAY_PAUSE = 5;
*/
always_comb begin
	// design your control here
	play_start_w = play_start_r;
	rec_start_w = rec_start_r;
	play_pause_w = play_pause_r;
	rec_pause_w = rec_pause_r;
	state_w = state_r;
	i2c_start_w = i2c_start_r;
	case(state_r)
	S_I2C: begin
		if(i_rst_n) begin
			// not in reset
			i2c_start_w = i2c_start_r? 0:1;
		end
		if(i2c_finished_r) begin
			state_w = S_IDLE;
		end
	end
	S_IDLE: begin
		if(i_key_1) begin
			state_w = S_PLAY;
			play_start_w = 1;
		end
		if(i_key_2) begin
			state_w = S_RECD;
			rec_start_w = 1;
		end
		if(i_key_0) begin
			state_w = S_IDLE;
		end
	end
	S_PLAY: begin
		play_start_w = 0;
		if(i_key_1) begin
			play_pause_w = 1;
			state_w = S_PLAY_PAUSE;
		end
		else if(i_key_0) begin
			state_w = S_IDLE;
		end
		else if(addr_play > addr_record) begin
			state_w = S_IDLE;
		end
		else begin 
			state_w = S_PLAY;
		end
	end
	S_PLAY_PAUSE: begin
		play_pause_w = 0;
		if(i_key_1) begin
			play_start_w = 1;
			state_w = S_PLAY;
		end
		if(i_key_0) begin
			state_w = S_IDLE;
		end
	end
	S_RECD: begin
		rec_start_w = 0;
		if(i_key_2) begin
			rec_pause_w = 1;
			state_w = S_RECD_PAUSE;
		end
		if(addr_record > 20'b11111111111111111100) begin
			state_w = S_IDLE;
		end
		if(i_key_0) begin
			state_w = S_IDLE;
		end
	end
	S_RECD_PAUSE: begin
		rec_pause_w = 0;
		if(i_key_2) begin
			rec_start_w = 1;
			state_w = S_RECD;
		end
		if(i_key_0) begin
			state_w = S_IDLE;
		end
	end
	endcase
end

always_ff @(negedge i_AUD_BCLK or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= 3'd0;
		rec_start_r <= 0;
		rec_pause_r <= 0;
		play_pause_r <= 0;
		play_start_r <= 0;
	end
	else begin
		state_r <= state_w;
		rec_start_r <= rec_start_w;
		rec_pause_r <= rec_pause_w;
		play_pause_r <= play_pause_w;
		play_start_r <= play_start_w;
	end
end

always @(posedge i_clk_100k or negedge i_rst_n) begin
	if (!i_rst_n) begin
		i2c_finished_r <= 0;
		i2c_start_r <= 0;
	end
	else begin
		i2c_finished_r <= i2c_finished_w;
		i2c_start_r <= i2c_start_w;
	end
end

endmodule