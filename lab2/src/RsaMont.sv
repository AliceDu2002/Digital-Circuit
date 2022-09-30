module RsaMont(
    input i_clk,
	input i_rst,
    input [255:0] i_N;
    input [255:0] i_a;
    input [255:0] i_b;
    input i_input_ready;
    output [255:0] o_m;
    output o_output_ready;
);

parameter S_IDLE = 2'd0;
parameter S_PROC = 2'd1;
parameter S_DONE = 2'd2;

logic [1:0] state_r, state_w;
logic [7:0] counter_w; counter_r;
logic o_ready_r, o_ready_w;
logic [255:0] m_w, m_r; 
logic [255:0] N, a, b;

assign o_m = m_r;
assign o_output_ready = o_ready_r;

ProcessM ProcM(
    .m(m_r);
    .N(N);
    .a(a);
    .b(b);
    .counter(counter_r);
    .state(state_w);
    .m_out(m_w);
)


always_comb begin
    
    state_w = state_r;
    o_ready_w = o_ready_r;

    case(state_r)
    
    S_IDLE: begin
        m_w = 255'd0;
        o_ready_w = 0;
        if(i_input_ready) begin
            counter_r = 0;
            counter_w = 0;
            state_w = S_PROC;
            N = i_N;
            a = i_a;
            b = i_b;
        end
    end
    
    S_PROC: begin 
        counter_w = counter_r + 1;
        /*if(a[counter_r] == 1) begin
            m_w = m_r + b;
        end

        if(m_r[0] == 1) begin
            m_w = m_w + N;
        end

        if(counter_r == 8'd255) begin
            if(m_r >= N) begin
                m_w = m_w - N;
            end
            state_w = S_DONE;
        end
        m_w = m_w >>> 1;*/
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

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        m_r <= 0;
        state_r <= S_IDLE;
        counter_r <= 8'd0;
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

module ProcessM (
    input [255:0] m;
    input [255:0] N;
    input [255:0] a;
    input [255:0] b;
    input [7:0] counter;
    output [1:0] state;
    output [255:0] m_out;
)

always_comb begin
    if(state_r == S_PROC) begin
        logic m_proc[0:3][0:255];
        assign m_proc[0] = m;
        assign m_out = m_proc[3];
        
        if(counter == 8'd255) begin
            if(m_proc[0] >= N) begin
                m_proc[3] = m_proc[0] - N;
            end
            state = S_DONE;
        end
        else begin
            if(a[counter_r] == 1) begin
                m_proc[1] = m[0] + b;
            end
            if(m_proc[0] == 1) begin
                m_proc[2] = m_proc[1] + N;
            end
            m_w = m_w >>> 1;
            state = S_PROC;
        end
    end
end
endmodule