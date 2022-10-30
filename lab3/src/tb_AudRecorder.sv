`timescale 1ns/100ps

module tb;
	localparam DACLRCK = 500;
	localparam HDACLRCK = DACLRCK/2;

    localparam BCLK = 10;
	localparam HBCLK = BCLK/2;
    
    logic rst_n;
    logic input_data;
    logic [15:0]data;
    logic adclrck, bclk;
	logic [19:0] addr;
	logic start, pause, stop;
	
    initial adclrck = 1;
	initial bclk = 0;
    always #HDACLRCK adclrck = ~adclrck;
    always #BCLK input_data = $random%2;
    always #HBCLK bclk = ~bclk;

    AudRecorder recorder(
		.i_rst_n(rst_n), 
		.i_clk(bclk),
		.i_lrc(adclrck),   // 1 start recording
		.i_start(start), // from Top, size not determined
		.i_pause(pause), // from Top, size not determined
		.i_stop(stop),  // from Top, size not determined
		.i_data(input_data),  // ADCDAT, data to store
		.o_address(addr), // to where in SRAM
		.o_data(data) // to SRAM
	);

	initial begin
		$fsdbDumpfile("AudRecorder.fsdb");
		$fsdbDumpvars;
		start = 0;
		pause = 0;
		stop = 0;
		rst_n = 0;
		#(2*BCLK)
		rst_n = 1;

		#(3*BCLK)
		start = 1;
		#(1*BCLK)
		start = 0;

        #(400*BCLK)
		pause = 1;
		#(1*BCLK)
		pause = 0;
		#(500*BCLK)
		start = 1;
		#(1*BCLK)
		start = 0;
		#(400*BCLK)
		stop = 1;
		#(3*BCLK)
		stop = 0;
		#(500*BCLK)
		start = 1;
		#(1*BCLK)
		start = 0;
		#(400*BCLK)
		$finish;
	end

endmodule