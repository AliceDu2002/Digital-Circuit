module AudRecorder (
    input i_rst_n, 
	input i_clk,
    input i_lrc,   // 1 start recording
	input i_start, // from Top, size not determined
	input i_pause, // from Top, size not determined
	input i_stop,  // from Top, size not determined
	input i_data,  // ADCDAT, data to store
	output[19:0] o_address, // to where in SRAM
	output[15:0] o_data // to SRAM
);

parameter S_IDLE = 3'd0;
parameter S_RECD = 3'd1;
parameter S_WAIT = 3'd2;
parameter S_READ = 3'd3;
parameter S_STORE = 3'd4;
parameter S_PAUSE = 3'd5;
parameter S_WAIT_L = 3'd6;

logic[3:0] state_r, state_w;
logic[4:0] count_r, count_w; // count and read 16 bits
logic[15:0] data_w, data_r; // get data from i_data bits by bits
logic[19:0] addr_w, addr_r; // address to store 
logic[15:0] final_data_w, final_data_r; // data connect to output
logic stop_r, stop_w;
logic pause_r, pause_w;
logic[30:0] length_r, length_w;

assign o_data = final_data_r;
assign o_address = addr_r;

always_comb begin
	// design your control here
	count_w = count_r;
	data_w = data_r;
	addr_w = addr_r;
	final_data_w = final_data_r;
	state_w = state_r;
	stop_w = stop_r;
	pause_w = pause_r;

	case(state_r)
		S_IDLE: begin
			if(i_start) begin
				addr_w = 0;
				state_w = S_WAIT_L;
			end
		end
		S_RECD: begin
			if(i_stop || stop_r) begin
				state_w = S_IDLE;
				stop_w = 0;
			end
			else if(i_pause || pause_r) begin
				state_w = S_PAUSE;
				pause_w = 0;
			end
			else if(addr_r == 20'b11111111111111111111) begin
				state_w = S_IDLE;
			end
			else begin
				state_w = S_WAIT;
			end
		end
		S_WAIT: begin
			if(i_stop) begin
				stop_w = 1;
			end
			if(i_pause) begin
				pause_w = 1;
			end
            if(i_lrc) begin
                state_w = S_READ;
                count_w = 15;
            end
		end
		S_READ: begin
			if(i_stop) begin
				stop_w = 1;
			end
			if(i_pause) begin
				pause_w = 1;
			end
			data_w[count_r] = i_data;
			count_w = count_r - 1;
			if(!count_r) begin
				state_w = S_STORE;
			end
		end
		S_STORE: begin
			if(i_stop) begin
				stop_w = 1;
			end
			if(i_pause) begin
				pause_w = 1;
			end
			final_data_w = data_r;
			addr_w = addr_r + 1;
			state_w = S_WAIT_L;
		end
		S_WAIT_L: begin
			if(i_stop) begin
				stop_w = 1;
			end
			if(i_pause) begin
				pause_w = 1;
			end
			if(!i_lrc) begin
				state_w = S_RECD;
			end
		end
		S_PAUSE: begin
			if(i_start) begin
				state_w = S_WAIT_L;
			end
			else if(i_stop) begin
				state_w = S_IDLE;
			end
			else begin
				state_w = S_PAUSE;
			end	
		end
	endcase
end

always_ff @(negedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		count_r <= 5'd15;
		data_r <= 15'd0;
		addr_r <= 20'b0;
		final_data_r <= 15'd0;
		state_r <= 0;
		stop_r <= 0;
		pause_r <= 0;
		length_r <= 0;
	end
	else begin
		count_r <= count_w;
		data_r <= data_w;
		addr_r <= addr_w;
		final_data_r <= final_data_w;
		state_r <= state_w;
		stop_r <= stop_w;
		pause_r <= pause_w;
		length_r <= length_w;
	end
end

endmodule