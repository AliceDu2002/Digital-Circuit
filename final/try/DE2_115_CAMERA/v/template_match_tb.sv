`timescale 1ns/100ps

module tb;
    localparam CLK = 10;
    localparam HCLK = 5;

    logic clk;
    logic rst;
    logic in_valid_1;
    logic in_valid_2;
    logic [14:0] out;
    logic input_1;
    logic input_2;
    always #(HCLK) clk = ~clk;
    always #CLK input_1 = $random%2;
    always #CLK input_2 = $random%2;
    logic [19:0] addr;
    logic [15:0] data_o, data_in;
    logic wr_enable;

    template_match inst(
        .clk(clk),
        .rst(rst),
        .mem_data(data_o),
        .start(in_valid_1),
        .mem_addr(addr)
    );
    Memory mem(
        .addr(addr),
        .data(data_in),
        .wr_enable(wr_enable),
        .data_o(data_o)
    );
    initial begin
        clk = 0;
        in_valid_1 = 0;
        in_valid_2 = 0;
        wr_enable = 1;
        for(int i=0;i<1048576;i = i+1) begin
            mem.mem[i] = $random%1000000;
            // $display("%d\n", mem.mem[i]);
        end
    end
    always #CLK clk = ~clk;
    
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
