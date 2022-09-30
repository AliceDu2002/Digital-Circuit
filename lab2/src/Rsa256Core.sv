module Rsa256Core (
	input          i_clk,
	input          i_rst,
	input          i_start,
	input  [255:0] i_a, // cipher text y
	input  [255:0] i_d, // private key
	input  [255:0] i_n,
	output [255:0] o_a_pow_d, // plain text x
	output         o_finished
);

// ===== states =====
parameter S_IDLE = 3'd0;
parameter S_PREP = 3'd1;
parameter S_MONT = 3'd2;
parameter S_CALC = 3'd3;
parameter S_WAIT = 3'd4;
parameter [256:0] const_a = {1'd1, 256'd0};
parameter [8:0] const_k = {1'd1, 8'd0};

// ===== output buffers =====
logic [255:0] o_a_pow_r, o_a_pow_w;
logic o_finished_r, o_finished_w;

// ===== registers & wires =====
logic [1:0] state_r, state_w;
logic [255:0] t, t_r, t_w;
logic prep_ready_r, prep_ready_w;
logic mont_ready_m_r, mont_ready_m_w;
logic mont_ready_t_r, mont_ready_t_w;
logic prep_finished_r, prep_finished_w;
logic mont_finished_m_r, mont_finished_m_w;
logic mont_finished_t_r, mont_finished_t_w;
logic [7:0] count_r, count_w;

// ===== output assignment =====
assign o_a_pow_d = o_a_pow_r;
assign o_finished = o_a_pow_r;

RsaPrep Prep (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_N(i_n),
	.i_a(const_a),
	.i_b(i_a),
	.i_input_ready(prep_ready_r),
	.i_k(const_k),
	.o_m(t),
	.o_output_ready(prep_finished_w)
);

RsaMont Montm (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_N(i_n),
	.i_a(o_a_pow_r),
	.i_b(t_r),
	.i_input_ready(mont_ready_m_r),
	.o_m(o_a_pow_w),
	.o_output_ready(mont_finished_m_w)
);

RsaMont Montt (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_N(i_n),
	.i_a(t_r),
	.i_b(t_r),
	.i_input_ready(mont_ready_t_r),
	.o_m(t_w),
	.o_output_ready(mont_finished_t_w)
);

// operations for RSA256 decryption
// namely, the Montgomery algorithm

always_comb begin
	state_w = state_r;
	o_a_pow_w = o_a_pow_r;
	o_finished_w = o_finished_r;
	t_w = t_r;
	count_w = count_r;
	prep_ready_w = prep_ready_r;
	prep_finished_w = prep_finished_r;
	mont_ready_m_w = mont_ready_m_r;
	mont_ready_t_w = mont_ready_t_r;
	mont_finished_m_w = mont_finished_m_r;
	mont_finished_t_w = mont_finished_t_r;
	case(state_r)
	S_IDLE: begin
		if(i_start) begin
			state_w = S_PREP;
			prep_ready_w = 1;
		end
	end
	S_PREP: begin
		prep_ready_w = 0;
		if(prep_finished_r) begin
			t_w = t;
			o_a_pow_w = 1;
			state_w = S_MONT;
			prep_ready_w = 1;
		end
	end
	S_MONT: begin
		prep_ready_w = 0;
		count_w = count_r + 1;
		if(i_d[count_r] == 1) begin
			mont_ready_m_w = 1;
		end
		mont_ready_t_w = 1;
		state_w = S_WAIT;
	end
	S_WAIT: begin
		if(mont_finished_m_r && mont_finished_t_r) begin
			state_w = S_CALC;
		end
	end	
	S_CALC: begin
		if(count_r < 256) begin
			state_w = S_MONT;
		end	
		else begin
			o_finished_w = 1;
			state_w = S_IDLE;
		end
	end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst) begin
	if (!i_rst) begin
		state_r <= 0;
		o_a_pow_r <= 1;
		o_finished_r <= 0;
		t_r <= 0;
		count_r <= 0;
		prep_ready_r <= 0;
		prep_finished_r <= 0;
		mont_ready_m_r <= 0;
		mont_ready_t_r <= 0;
		mont_finished_m_r <= 0;
		mont_finished_t_r <= 0;
	end
	else begin
		state_r <= state_w;
		o_a_pow_r <= o_a_pow_w;
		o_finished_r <= o_finished_w;
		t_r <= t_w;
		count_r <= count_w;
		prep_ready_r <= prep_ready_w;
		prep_finished_r <= prep_finished_w;
		mont_ready_m_r <= mont_ready_m_w;
		mont_ready_t_r <= mont_ready_t_w;
		mont_finished_m_r <= mont_finished_m_w;
		mont_finished_t_r <= mont_finished_t_w;
	end
end
endmodule