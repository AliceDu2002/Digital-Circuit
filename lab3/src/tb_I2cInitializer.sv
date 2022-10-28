`timescale 1ns/100ps

module tb;
    localparam CLK = 100;
    localparam HCLK = 50;
    
    logic ret_n;
    logic start;
    logic finished;
    logic sclk;
    logic sdat;
    logic oen;
    logic clk;

    initial clk = 0;
    always #HCLK clk = ~clk;

    I2cInitializer init0(
        .i_rst_n(rst_n),
        .i_clk(clk),
        .i_start(start),
        .o_finished(finished),
        .o_sclk(sclk),
        .o_sdat(sdat),
        .o_oen(oen)
    );

    initial begin
        $fsdbDumpfile("I2cInit.fsdb");
		$fsdbDumpvars;
		rst_n = 0;
		#(2*CLK)
		rst_n = 1;

        #(5*CLK)
        start = 1;
        #(1*CLK)
        start = 0;
        $finish;
    end
endmodule