module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

// ===== States =====
parameter S_IDLE = 2'd0;
parameter S_PROC = 2'd1;
parameter S_GRAB = 2'd2;
parameter S_STOP = 2'd3;

// ===== Output Buffers =====
logic [3:0] o_random_out_r, o_random_out_w;

// ===== Registers & Wires =====
logic [1:0] state_r, state_w;
logic [31:0] seed_r, seed_w;
logic [31:0] count_r, count_w;
logic [31:0] duration_r, duration_w;

logic [31:0] random_r, random_w;

// ===== Output Assignments =====
assign o_random_out = o_random_out_r;

// ===== Combinational Circuits =====
always_comb begin
	// Default Values
	o_random_out_w = o_random_out_r;
	state_w        = state_r;
	seed_w         = seed_r + 1;
	duration_w     = duration_r;
	count_w        = count_r;
	random_w       = random_r;

	// FSM
	case(state_r)
	S_IDLE: begin
		if (i_start) begin
			state_w = S_PROC;
			random_w = seed_r % 1073741823;
			o_random_out_w = random_r % 16;
		end
	end

	S_PROC: begin
		count_w = count_r + 1;
		random_w = (random_r * 32'd1103515245 + 32'd12345 ) % 1073741823
		if (count_w > duration_r) begin
			state_w = S_GRAB;
		end
	end
	
	S_GRAB: begin
		o_random_out_w = random_r % 16;
		count_w = 0;
		duration_w = duration_r + 32'd108107;
		if (duration_r > 32'd5000000) begin
			state_w = S_STOP;
		end
		else begin
			state_w = S_PROC;
		end
	end

	S_STOP: begin
		duration_w = 32'd1000000;
		if(i_start) begin
			state_w = S_PROC;
		end
	end

	endcase
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n) begin
		o_random_out_r <= 4'd0;
		state_r        <= S_IDLE;
		seed_r         <= 32'd0;
		duration_r     <= 32'd1000000;
		count_r	       <= 32'd0;   
		random_r       <= 32'd0;
	end
	else begin
		o_random_out_r <= o_random_out_w;
		state_r        <= state_w;
		seed_r	       <= seed_w;
		count_r	       <= count_w;
		duration_r     <= duration_w;
		random_r       <= random_w;
	end
end

endmodule