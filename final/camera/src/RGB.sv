module RGB(
    input i_clk;
    input i_rst_n;

    input start;
    output finish;

    input[4:0] red;
    input[4:0] green;
    input[4:0] blue;
    output[7:0] red;
    output[7:0] green;
    output[7:0] blue;
);

always_comb begin

end

always_ff @(posedge i_clk or negedge i_rst_n) begin

end

endmodule