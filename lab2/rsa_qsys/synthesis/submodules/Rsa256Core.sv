// `include "RsaPrep.sv"
// `include "RsaMont.sv"

module RsaMont(
    input i_clk,
	input i_rst,
    input [255:0] i_N,
    input [255:0] i_a,
    input [255:0] i_b,
    input i_input_ready,
    output [255:0] o_m,
    output o_output_ready
);

parameter S_IDLE = 2'd0;
parameter S_PROC = 2'd1;
parameter S_PROC_RD_DONE = 2'd3;
parameter S_DONE = 2'd2;

logic [1:0] state_r, state_w;
logic [7:0] counter_w, counter_r;
logic o_ready_r, o_ready_w;
logic [260:0] m_w, m_w_1, m_w_2, m_r; 
logic [255:0] N_w, a_w, b_w;
logic [255:0] N_r, a_r, b_r;

assign o_m = m_r[255:0];
assign o_output_ready = o_ready_r;

always_comb begin
    
    state_w = state_r;
    o_ready_w = o_ready_r;
    m_w = m_r;
    counter_w = counter_r;

    N_w = N_r;
    a_w = a_r;
    b_w = b_r;
    m_w_2 = m_r;

    case(state_r)
    
    S_IDLE: begin
        m_w = 0;
        m_w_1 = 0;
        m_w_2 = 0;
        o_ready_w = 0;
        counter_w = 7'd0;
        if(i_input_ready) begin
            state_w = S_PROC;
            N_w = i_N;
            a_w = i_a;
            b_w = i_b;
        end
        else begin
            state_w = S_IDLE;
            N_w = 0;
            a_w = 0;
            b_w = 0;
        end
    end
    S_PROC: begin 
        counter_w = counter_r + 1;
        if(a_r[counter_r] == 1) begin
            m_w = m_r + b_r;
        end
        if(m_w[0] == 1) begin
            m_w_1 = m_w + N_r;
            m_w_2 = m_w_1 >>> 1;
        end
        else begin
            m_w_2 = m_w >>> 1;
            m_w_1 = m_w; // for avoiding latch only
        end
        if(counter_r == 255) begin
            state_w = S_PROC_RD_DONE;
        end
    end

    S_PROC_RD_DONE: begin // this state is just for passing mod N
        if(m_w >= N_r) begin
            m_w_2 = m_w - N_r;
            m_w_1 = 0;// for avoiding latch only
        end
        else begin
            m_w_2 = m_w;// for avoiding latch only
            m_w_1 = 0;// for avoiding latch only
        end
        state_w = S_DONE;
    end

    S_DONE: begin
        if (o_ready_r == 0) begin
            o_ready_w = 1;
        end
        else begin
            o_ready_w = 0;
            state_w = S_IDLE;
        end
    end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst) begin
    if (i_rst) begin
        m_r <= 0;
        state_r <= S_IDLE;
        counter_r <= 0;
        o_ready_r <= 0;
        N_r <= 0;
        a_r <= 0;
        b_r <= 0;
    end
    else begin
        m_r <= m_w_2;
        state_r <= state_w;
        counter_r <= counter_w;
        o_ready_r <= o_ready_w;
        N_r <= N_w;
        a_r <= a_w;
        b_r <= b_w;
    end
end

endmodule

module RsaPrep(
    input i_clk,
	input i_rst,
    input [256:0] i_N,
    input [256:0] i_a,
    input [256:0] i_b,
    input [8:0] i_k,
    input i_input_ready,
    output [255:0] o_m,
    output o_output_ready
);

// ===== States =====
parameter S_IDLE = 1'd0;
parameter S_PROC = 1'd1;

// ===== Output Buffers =====
logic [260:0] o_m_r, o_m_w;
logic o_output_ready_r, o_output_ready_w;

// ===== Registers & Wires =====
logic [1:0] state_r, state_w;
logic [8:0] count_r, count_w;
logic [260:0] t_r, t_w;
logic [260:0] N_r, N_w;
logic [256:0] A_r, A_w;

// ===== Output Assignments =====
assign o_m = o_m_r[255:0];
assign o_output_ready = o_output_ready_r;

// ===== Combinational Circuits =====
always_comb begin
    // Default Values
    o_m_w = o_m_r;
    o_output_ready_w = o_output_ready_r;
    state_w = state_r;
    count_w = count_r;
    t_w = t_r;
    N_w = N_r;
    A_w = A_r;

    // FSM
    case(state_r)
    S_IDLE: begin
        o_output_ready_w = 0;
        count_w = 0;
        o_m_w = 0;
        if (i_input_ready) begin
                N_w = i_N;
                A_w = i_a;
                t_w = i_b;
                state_w = S_PROC;
        end
    end

    S_PROC: begin
        if (count_r <= 256) begin
            if (A_r[count_r] == 1) begin
                if (o_m_r + t_r >= {5'd0, N_r}) begin
                    o_m_w = o_m_r + t_r - {5'd0, N_r};
                end
                else begin
                    o_m_w = o_m_r + t_r;
                end
            end
            if (t_r + t_r > N_r) begin
                t_w = t_r + t_r - {5'd0, N_r};
            end
            else begin
                t_w = t_r + t_r;
            end
            count_w = count_r + 1;
        end
        else begin
            o_output_ready_w = 1;
            state_w = S_IDLE;
        end
    end
    endcase

end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst) begin
    // reset
    if (i_rst) begin
        o_m_r            <= 0;
        o_output_ready_r <= 0;
        count_r          <= 0;
        state_r          <= S_IDLE;
    end
    else begin
        t_r              <= t_w;
        o_m_r            <= o_m_w;
        o_output_ready_r <= o_output_ready_w;
        count_r          <= count_w;
        state_r          <= state_w;
        N_r              <= N_w;
        A_r              <= A_w;
    end
end

endmodule

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
logic [255:0] o_a_pow, o_a_pow_r, o_a_pow_w;
logic o_finished_r, o_finished_w;

// ===== registers & wires =====
logic [2:0] state_r, state_w;
logic [255:0] t1, t2, t_r, t_w;
logic prep_ready_r, prep_ready_w;
logic mont_ready_m_r, mont_ready_m_w;
logic mont_ready_t_r, mont_ready_t_w;
logic prep_finished, prep_finished_r, prep_finished_w;
logic mont_finished_m, mont_finished_m_r, mont_finished_m_w;
logic mont_finished_t, mont_finished_t_r, mont_finished_t_w;
logic [8:0] count_r, count_w;
logic [255:0] a_w, a_r;
logic [255:0] d_w, d_r;
logic [255:0] n_w, n_r;

// ===== output assignment =====
assign o_a_pow_d = o_a_pow_r;
assign o_finished = o_finished_r;

RsaPrep Prep (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_N(n_r),
	.i_a(const_a),
	.i_b(a_r),
	.i_input_ready(prep_ready_r),
	.i_k(const_k),
	.o_m(t1),
	.o_output_ready(prep_finished)
);

RsaMont Montm (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_N(n_r),
	.i_a(o_a_pow_r),
	.i_b(t_r),
	.i_input_ready(mont_ready_m_r),
	.o_m(o_a_pow),
	.o_output_ready(mont_finished_m)
);

RsaMont Montt (
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_N(n_r),
	.i_a(t_r),
	.i_b(t_r),
	.i_input_ready(mont_ready_t_r),
	.o_m(t2),
	.o_output_ready(mont_finished_t)
);

// operations for RSA256 decryption
// namely, the Montgomery algorithm

always_comb begin
	// prep_finished_w = prep_finished;
	// mont_finished_m_w = mont_finished_m;
	// mont_finished_t_w = mont_finished_t;
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
	a_w = a_r;
	d_w = d_r;
	n_w = n_r;
	case(state_r)
	S_IDLE: begin
		o_finished_w = 0;
		if(i_start) begin
			t_w = 0;
			count_w = 0;
			state_w = S_PREP;
			prep_ready_w = 1;
			a_w = i_a;
			d_w = i_d;
			n_w = i_n;
		end
	end
	S_PREP: begin
		prep_ready_w = 0;
		if(prep_finished) begin
			t_w = t1;
			o_a_pow_w = 1;
			state_w = S_MONT;
		end
	end
	S_MONT: begin
		count_w = count_r + 1;
		if(d_r[count_r] == 1) begin
			mont_ready_m_w = 1;
		end
		else begin
			mont_finished_m_w = 1;
		end
		mont_ready_t_w = 1;
		state_w = S_WAIT;
	end
	S_WAIT: begin
		mont_ready_m_w = 0;
		mont_ready_t_w = 0;
		if(mont_finished_m) begin
			mont_finished_m_w = 1;
			o_a_pow_w = o_a_pow;
		end
		if(mont_finished_t) begin
			mont_finished_t_w = 1;
		end
		if(mont_finished_m_r && mont_finished_t_r) begin
			mont_finished_t_w = 0;
			mont_finished_m_w = 0;
			state_w = S_CALC;
			t_w = t2;
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
	if (i_rst) begin
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
		a_r <= 0;
		d_r <= 0;
		n_r <= 0;
	end
	else begin
		a_r <= a_w;
		n_r <= n_w;
		d_r <= d_w;
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
