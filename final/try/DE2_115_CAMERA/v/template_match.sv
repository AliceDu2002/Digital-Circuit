`define TEMPL_SIZE 64
`define IMG_ROW 480
`define IMG_COL 640
`define TEMPL_BASE 20'h40000
`define TEMPL_FETCH_CYCLES 256
`define IMG_BASE 20'h0
module template_match(
    input clk,
    input rst,
    input [15:0] mem_data,
    input start,
    output [19:0] mem_addr
);

logic [`TEMPL_SIZE*`TEMPL_SIZE-1:0] templ_arr;

logic [1:0] state_r;
logic [1:0] state_w;
parameter S_IDLE = 0;
parameter S_LD_TEMPL = 1; // load weight into the XOR array
parameter S_PROC = 2; // process the template matching

logic [19:0] counter_w, counter_r;
logic [19:0] mem_addr_r, mem_addr_w;

assign mem_addr = mem_addr_r;

always_comb begin
    state_w = state_r;
    counter_w = counter_r;
    case(state_r)
    S_IDLE: begin
        if(start) begin
            state_w = S_LD_TEMPL;
            mem_addr_w = `TEMPL_BASE;
            counter_w = 0;
        end
        else begin
            state_w = S_IDLE;
            counter_w = 0;
            mem_addr_w = 0;
        end
    end
    S_LD_TEMPL: begin
        if(counter_r == `TEMPL_FETCH_CYCLES-1) begin
            state_w = S_PROC;
            mem_addr_w = `IMG_BASE;
            counter_w = 0;
        end
        else begin
            state_w = S_LD_TEMPL;
            mem_addr_w = mem_addr_r+1;
            counter_w = counter_r+1;
        end
    end
    S_PROC: begin
        state_w = S_PROC;
        mem_addr_w = `IMG_BASE;
        counter_w = 0;
    end
    endcase
end
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        mem_addr_r <= 0;
        counter_r <= 0;
        state_r <= S_IDLE;
    end
    else begin
        templ_arr[(counter_r*16+15)-:16] <= mem_data;
        mem_addr_r <= mem_addr_w;
        counter_r <= counter_w;
        state_r <= state_w;
    end
end

endmodule
