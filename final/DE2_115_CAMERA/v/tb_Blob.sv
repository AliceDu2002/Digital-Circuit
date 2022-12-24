`timescale 1ns/100ps
module tb;
    localparam CLK = 10;
    localparam HCLK = 5;

    logic clk;
    logic rst;
    logic [7:0] count;
    logic i_valid, o_valid;
    logic seq;

    integer fp;
    always #(HCLK) clk = ~clk;
    Blob blob(
        .i_clk(clk),
        .i_rst(rst),
        .i_valid(i_valid),
        .i_seq(seq),
        .o_valid(o_valid),
        .o_count(count)
    );
    initial begin
        clk = 0;
        fp = $fopen("sequence.txt", "r");
        $fsdbDumpfile("blob.fsdb");
		$fsdbDumpvars;
        rst = 0;
        #(CLK)
        rst = 1;
        #(CLK) 
        rst = 0;
        #(20*CLK)
        i_valid = 1;
        for(int i=0; i<640*480; i=i+1) begin
            $fscanf(fp, "%d", seq);
            @(posedge clk);
        end
        i_valid = 0;

        #(100000*CLK)
        $finish;
    end
endmodule