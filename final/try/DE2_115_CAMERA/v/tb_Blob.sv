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
    logic switch;
    logic o_sdram_request;
    logic [7:0] smaller;
    logic [7:0] bigger;

    integer fp;
    always #(HCLK) clk = ~clk;
    Blob_pipeline blob(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_valid(i_valid),
        .i_seq(seq),
        // .i_switch(switch),
        .o_valid(o_valid),
        .o_count(count),
        .o_sdram_request(o_sdram_request)
        // .o_smaller(smaller),
        // .o_bigger(bigger)
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
        for(int i=0; i<`IMG_ROW*`IMG_COL; i=i+1) begin
            @(posedge clk);
            $fscanf(fp, "%d", seq);
        end
        #(100000*CLK)
        // i_valid = 0;
        // #(250000*CLK)
        // i_valid = 1;
        // $fseek(fp, 0, 0);
        // for(int i=0; i<`IMG_ROW*`IMG_COL; i=i+1) begin
        //     @(posedge clk);
        //     $fscanf(fp, "%d", seq);
        // end
        // i_valid = 0;
        // for(int i=0; i<`TABLE_ENTRY; i++) begin
        //     $display("%d\n", blob.pixels_r[i]);
        //     $display("%d\n", blob.tisch_r[i]);
        // end

        switch = 1;
        #(CLK)
        switch = 0;
        #(100000*CLK)
        i_valid = 0;
        #(200*CLK)
        $finish;
    end
endmodule