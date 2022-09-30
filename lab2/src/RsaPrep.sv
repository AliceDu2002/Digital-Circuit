module RsaPrep(
    input i_clk,
	input i_rst,
    input [255:0] i_N;
    input [255:0] i_a;
    input [255:0] i_b;
    input i_input_ready;
    input [7:0] i_k;
    output [255:0] o_m;
    output o_output_ready;
);

endmodule