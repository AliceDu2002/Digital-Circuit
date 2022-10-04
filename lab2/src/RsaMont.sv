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
parameter S_DONE = 2'd2;

logic [1:0] state_r, state_w;
logic [7:0] counter_w, counter_r;
logic o_ready_r, o_ready_w;
logic [256:0] m_w, m_r; 
logic [255:0] N, a, b;

assign o_m = m_r[255:0];
assign o_output_ready = o_ready_r;

always_comb begin
    
    state_w = state_r;
    o_ready_w = o_ready_r;
    m_w = m_r;
    counter_w = counter_r;

    case(state_r)
    
    S_IDLE: begin
        m_w = 0;
        o_ready_w = 0;
        if(i_input_ready) begin
            counter_w = 0;
            state_w = S_PROC;
            N = i_N;
            a = i_a;
            b = i_b;
        end
    end
    
    S_PROC: begin 
        counter_w = counter_r + 1;
        if(a[counter_r] == 1) begin
            m_w = m_r + b;
        end

        if(m_w[0] == 1) begin
            m_w += N;
        end
	m_w = m_w >>> 1;
        
	if(counter_r == 255) begin
            if(m_w >= N) begin
                m_w -= N;
            end
            state_w = S_DONE;
        end
        
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
    if (!i_rst) begin
        m_r <= 0;
        state_r <= S_IDLE;
        counter_r <= 0;
        o_ready_r <= 0;
    end
    else begin
        m_r <= m_w;
        state_r <= state_w;
        counter_r <= counter_w;
        o_ready_r <= o_ready_w;
    end
end

endmodule

