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
