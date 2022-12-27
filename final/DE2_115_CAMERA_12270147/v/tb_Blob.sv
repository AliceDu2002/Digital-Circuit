`timescale 1ns/100ps

`define IMG_ROW 600
`define IMG_COL 800
`define BUF_SIZE 802
`define TABLE_ENTRY 100
`define TABLE_ENTRY_SIZE 7
`define BUF_ENTRY_SIZE 7
`define PIXEL_ENTRY_SIZE 16

module tb;
    localparam CLK = 10;
    localparam HCLK = 5;

    logic clk;
    logic rst_n;
    logic [7:0] count;
    logic i_valid, o_valid;
    logic seq;
    logic o_sdram_request;
    logic i_proc_ccd;
    logic data_valid;

    integer fp;
    always #(HCLK) clk = ~clk;
    Blob_pipeline blob(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_valid(i_valid),
        .i_seq(seq),
        .i_data_valid(data_valid),
        .i_proc_ccd(i_proc_ccd),
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
        i_proc_ccd = 1;
        data_valid = 1;
        for(int i=0; i<`IMG_ROW; i=i+1) begin
            for(int j=0; j<20; j=j+1) begin
                data_valid = 0;
                @(posedge clk);
            end
            for(int j=0; j<`IMG_COL; j=j+1) begin
                data_valid = 1;
                $fscanf(fp, "%d", seq);
                @(posedge clk);
            end
        end
        i_valid = 0;
        #(100000*CLK)
        i_proc_ccd = 0;
        switch = 1;
        #(CLK)
        switch = 0;
        #(100000*CLK)
        i_valid = 0;
        #(200*CLK)
        $finish;
    end
endmodule