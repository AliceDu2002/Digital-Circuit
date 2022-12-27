`timescale 1ns/100ps

module tb;
    localparam BCLK = 10;

	logic [4095:0] regs_in;
    logic [13:0] regs_out;
    logic clk;
    logic rst;
    initial clk = 0;
    always #BCLK clk = ~clk;
    adder_tree Tree(
        .clk(clk),
        .rst(rst),
        .idata(regs_in),
        .odata(regs_out)
    );
    initial begin
        $fsdbDumpfile("AdderTree.fsdb");
		$fsdbDumpvars;
        regs_in = 0;
        rst = 1;
        #(3*BCLK)
        rst = 0;
        #(5*BCLK)
        regs_in[13] = 1;
        regs_in[19] = 1;
        #(5000*BCLK)
        
        #(20*BCLK)
        $finish;
    end
    

endmodule
