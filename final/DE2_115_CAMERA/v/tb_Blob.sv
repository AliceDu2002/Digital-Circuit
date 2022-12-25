`timescale 1ns/100ps

`define IMG_ROW 480
`define IMG_COL 640
`define BUF_SIZE 642
`define TABLE_ENTRY 256
`define TABLE_ENTRY_SIZE 8
`define BUF_ENTRY_SIZE 8
`define PIXEL_ENTRY_SIZE 15
module tb;
    localparam CLK = 10;
    localparam HCLK = 5;

    logic clk;
    logic rst_n;
    logic [7:0] count;
    logic i_valid, o_valid;
    logic seq;

    integer fp;
    always #(HCLK) clk = ~clk;
    Blob blob(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_valid(i_valid),
        .i_seq(seq),
        .o_valid(o_valid),
        .o_count(count)
    );
    initial begin
        clk = 1;
        fp = $fopen("sequence.txt", "r");
        $fsdbDumpfile("blob.fsdb");
		$fsdbDumpvars;
        rst_n = 1;
        #(CLK)
        rst_n = 0;
        #(CLK) 
        rst_n = 1;
        #(20*CLK)
        i_valid = 1;
        for(int i=0; i<640*480; i=i+1) begin
            @(posedge clk);
            $fscanf(fp, "%d", seq);
        end
        @(posedge clk);
        i_valid = 0;
        for(int i=0; i<`TABLE_ENTRY; i++) begin
            $display("%d\n", blob.pixels_r[i]);
            $display("%d\n", blob.tisch_r[i]);
        end
        #(100000*CLK)
        $finish;
    end
endmodule