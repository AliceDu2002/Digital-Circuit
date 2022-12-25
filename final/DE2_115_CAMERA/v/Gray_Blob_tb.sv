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
    logic [9:0] seq_red, seq_green, seq_blue;
    logic start;


    integer fp, fp2;
    always #(HCLK) clk = ~clk;

    Grayscale gray(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_start(start),

        // communication with SDRAM
        .read_request(req),
        .i_red(seq_red),
        .i_green(seq_green),
        .i_blue(seq_blue),

        // communication with further image process
        .o_color(), // 0-255 precision
        .o_bw(seq), // binarized precision (white -> 0, black -> 1)
        .o_valid(i_valid)
    );
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
        fp = $fopen("imgrgb.txt", "r");
        fp2 = $fopen("dump.txt", "w");
        start = 0;
        $fsdbDumpfile("blob_gray.fsdb");
		$fsdbDumpvars;
        rst_n = 1;
        #(CLK)
        rst_n = 0;
        #(CLK) 
        rst_n = 1;
        #(20*CLK)
        start = 1;
        @(posedge req);
        for(int i=0; i<640*480; i=i+1) begin
            @(posedge clk);
            $fscanf(fp, "%d %d %d", seq_red, seq_green, seq_blue);
            $fwrite(fp2, "%d\n", gray.o_bw);
        end
        @(posedge clk);
        #(100000*CLK)
        $finish;
    end
endmodule