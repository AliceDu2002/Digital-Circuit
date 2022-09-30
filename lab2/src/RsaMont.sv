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

parameter S_IDLE = 1'd0;
parameter S_PROC = 1'd1;

always_comb begin

end

always_ff @(posedge i_clk or negedge i_rst_n) begin

end

endmodule