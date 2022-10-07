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
        m_w_1 = 0;
        m_w_2 = 0;
        o_ready_w = 0;
        counter_w = 7'd0;
        if(i_input_ready) begin
            state_w = S_PROC;
            N = i_N;
            a = i_a;
            b = i_b;
        end
        else begin
            state_w = S_IDLE;
            N = 0;
            a = 0;
            b = 0;
        end
    end
    S_PROC: begin 
        counter_w = counter_r + 1;
        if(a[counter_r] == 1) begin
            m_w = m_r + b;
        end
        if(m_w[0] == 1) begin
            m_w_1 = m_w + N;
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
        if(m_w >= N) begin
            m_w_2 = m_w - N;
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
    end
    else begin
        m_r <= m_w_2;
        state_r <= state_w;
        counter_r <= counter_w;
        o_ready_r <= o_ready_w;
    end
end

endmodule

