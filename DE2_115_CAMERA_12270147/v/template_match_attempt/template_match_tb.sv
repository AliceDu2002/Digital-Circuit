`timescale 1ns/100ps

module tb;
    localparam CLK = 10;

    logic clk;
    logic rst;
    logic in_valid_1;
    logic in_valid_2;
    logic [14:0] out;
    logic input_1;
    logic input_2;
    always #CLK input_1 = $random%2;
    always #CLK input_2 = $random%2;
    initial begin
        clk = 0;
        in_valid_1 = 0;
        in_valid_2 = 0;
    end
    always #CLK clk = ~clk;
    template_match inst(
        .clk(clk),
        .rst(rst),
        .templ_content(input_1),
        .templ_in_valid(in_valid_1),
        .img_content(input_2),
        .img_in_valid(in_valid_2),
        .data(out)
    );
    initial begin
        $fsdbDumpfile("template_match.fsdb");
		$fsdbDumpvars;
        rst = 1;
        #(3*CLK)
        rst = 0;
        #(5*CLK)
        in_valid_1 = 1;
        #(2*CLK)
        in_valid_1 = 0;
        #(10000*CLK)
        in_valid_2 = 1;
        #(2*CLK)
        in_valid_2 = 0;
        #(500000*CLK)
        
        #(20*CLK)
        $finish;
    end
    

endmodule
