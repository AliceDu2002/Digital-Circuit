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

    AudPlayer player(
        .i_rst_n(rst_n),
        .i_bclk(bclk),
        .i_daclrck(adclrck),
        .i_en(en), // enable AudPlayer only when playing audio, work with AudDSP
        .i_dac_data(input_data), //dac_data
        .o_aud_dacdat(data)
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