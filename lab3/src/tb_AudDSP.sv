`timescale 1ns/100ps

module tb;
	localparam CLK = 10;
	localparam HCLK = CLK/2;

	logic clk, rst, start, pause, stop, fast, slow_0, slow_1;
    logic [3:0] speed;
    logic [15:0] data;
    logic [19:0] addr;
	initial clk = 0;
	always #HCLK clk = ~clk;

	AudDSP dsp0(
        .i_rst_n(rst),
        .i_clk(),
        .i_start(start),
        .i_pause(pause),
        .i_stop(stop),
        .i_speed(speed),
        .i_fast(fast),
        .i_slow_0(slow_0), // constant interpolation
        .i_slow_1(slow_1), // linear interpolation
        .i_daclrck(clk),
        .i_sram_data(),
        .o_dac_data(data),
        .o_sram_addr(addr)
    );

	initial begin
		$fsdbDumpfile("AudDSP.fsdb");
		$fsdbDumpvars;
		rst = 0;
		#(2*CLK)
		rst = 1;

        speed = 0;
        fast = 0;
        slow_0 = 0;
        slow_1 = 0;
        //test normal speed
        start = 1;
		#(CLK)
		start = 0;
        #(30*CLK)
        stop = 1;
		#(CLK)
		stop = 0;

		// test 
		#(3*CLK)
		start = 1;
		fast = 1;
		speed = 3;
		#(CLK)
		start = 0;
		#(30*CLK)
        stop = 1;
		#(CLK)
		stop = 0;
		fast = 0;
		#(30*CLK)

		// test 
		#(3*CLK)
		start = 1;
		slow_0 = 1;
		speed = 3;
		#(CLK)
		start = 0;
		#(100*CLK)
        stop = 1;
		#(CLK)
		stop = 0;
		slow_0 = 0;
		#(30*CLK)
		

		// test 
		#(3*CLK)
		start = 1;
		slow_1 = 1;
		speed = 2;
		#(CLK)
		start = 0;
		#(30*CLK)
		pause = 1;
		
		#(20*CLK)
		pause = 0;
		start = 1;
		#(CLK)
		start = 0;
		#(30*CLK)

        stop = 1;
		#(CLK)
		stop = 0;
		#(30*CLK)
		slow_0 = 1;

		// for (int i = 0; i < 5; i++) begin
		// 	for (int j = 0; j < 10; j++) begin
		// 		@(posedge clk);
		// 	end
		// 	$fread(encrypted_data, fp_e);
		// 	$fread(golden, fp_d);
		// 	$display("=========");
		// 	$display("enc  %2d = %64x", i, encrypted_data);
		// 	$display("=========");
		// 	start_cal <= 1;
		// 	@(posedge clk)
		// 	encrypted_data <= 'x;
		// 	start_cal <= 0;
		// 	@(posedge fin)
		// 	$display("=========");
		// 	$display("dec  %2d = %64x", i, decrypted_data);
		// 	$display("gold %2d = %64x", i, golden);
		// 	$display("=========");
		// end
		$finish;
	end

endmodule