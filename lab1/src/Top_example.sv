module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

// ===== States =====
parameter S_IDLE = 1'b0;
parameter S_PROC = 1'b1;

logic [3:0] clock_count_r, clock_count_w;

// ===== Output Buffers =====
logic [3:0] o_random_out_r, o_random_out_w;

// ===== Registers & Wires =====
logic state_r, state_w;

// ===== Output Assignments =====
//assign o_random_out = o_random_out_r;
assign o_random_out = clock_count_r;

// ===== Combinational Circuits =====
always_comb begin
	// Default Values
	o_random_out_w = o_random_out_r;
	state_w        = state_r;
	clock_count_w = clock_count_r + 1;

	// FSM
	case(state_r)
	S_IDLE: begin
		if (i_start) begin
			state_w = S_PROC;
			o_random_out_w = 4'd15;
		end
	end

	S_PROC: begin
		if ((i_start) && (clock_count_r > 10'd10)) begin
			//state_w = (o_random_out_r == 4'd10) ? S_IDLE : state_w;
			//o_random_out_w = (o_random_out_r == 4'd10) ? 4'd1 : (o_random_out_r - 4'd1);
			o_random_out_w = (o_random_out_r * 1103515245 + 12345) % 16;
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
	end
	else begin
		clock_count_r <= clock_count_w;
		o_random_out_r <= o_random_out_w;
		state_r        <= state_w;
	end
end

endmodule
