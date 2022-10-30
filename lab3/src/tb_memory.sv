`timescale 1ns/100ps

module tb;
    localparam BCLK = 10;
	localparam HBCLK = BCLK/2;

	
    logic [19:0] addr;
    logic [15:0] data;
    logic wr_enable;
    logic [19:0] data_o;
    logic bclk;
    initial bclk = 0;
    always #HBCLK bclk = ~bclk;
    always #BCLK data = $random%10000;
    Memory mem(
        .addr(addr),
        .data(data),
        .wr_enable(wr_enable),
        .data_o(data_o)
    );
    initial begin
        $fsdbDumpfile("Memory.fsdb");
		$fsdbDumpvars;
        wr_enable = 1;
        #(30*BCLK)
        wr_enable = 0;
        addr = 3;
        #(2*BCLK)
        addr = 5;
        #(3*BCLK)
        wr_enable = 0;
        addr = 5;
        #(2*BCLK)
        addr = 3;
        #(1*BCLK)
        wr_enable = 1;
        #(20*BCLK)
        $finish;
    end
    

endmodule

    