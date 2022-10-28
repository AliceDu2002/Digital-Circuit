`timescale 1ns/100ps

module tb;
	localparam DACLRCK = 500;
	localparam HDACLRCK = DACLRCK/2;

    localparam BCLK = 10;
	localparam HBCLK = BCLK/2;
    
    logic rst_n;
    logic en;
    logic [15:0] input_data;
    logic data;
    logic adclrck, bclk;
	
    initial adclrck = 0;
	initial bclk = 0;
    always #HDACLRCK adclrck = ~adclrck;
    always #HDACLRCK input_data = $random%10000;
    always #HBCLK bclk = ~bclk;

    AudRecorder recorder(
    .i_rst_n, 
	.i_clk,
    .i_lrc,   // 1 start recording
	.i_start, // from Top, size not determined
	.i_pause, // from Top, size not determined
	.i_stop,  // from Top, size not determined
	.i_data,  // ADCDAT, data to store
	.o_address, // to where in SRAM
	.o_data // to SRAM
);

	initial begin
		$fsdbDumpfile("AudPlayer.fsdb");
		$fsdbDumpvars;
		rst_n = 0;
		#(2*BCLK)
		rst_n = 1;

        #(10*BCLK)
        en = 1;
        #(2500*BCLK)
        en = 0;
		$finish;
	end

endmodule