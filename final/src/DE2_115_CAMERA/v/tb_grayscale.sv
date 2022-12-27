`timescale 1ns/100ps

module tb;
    logic clk;
    localparam BCLK = 10;
	localparam HBCLK = BCLK/2;
    initial clk = 1;
    always #HBCLK clk = ~clk;
    logic rst_n;

    // input
    logic start;
    logic[9:0] red;
    logic[9:0] green;
    logic[9:0] blue;

    // output
    logic read_request;
    logic[9:0] color;
    logic[9:0] bw;
    logic valid;

    Grayscale grayscale(
        .i_clk(clk),
        .i_rst_n(rst_n),
        .i_start(start),
        .i_red(red),
        .i_green(green),
        .i_blue(blue),
        .read_request(read_request),
        .o_color(color),
        .o_bw(bw),
        .o_valid(valid)
    );

    initial begin
        $fsdbDumpfile("Grayscale.fsdb");
		$fsdbDumpvars;

        // reset
        rst_n = 0;
		#(2*BCLK)
		rst_n = 1;
        #(5*BCLK)

        // start
        start = 1;
        @(posedge read_request)
        #(BCLK)
        for(int i = 0; i < 170; i++) begin
                @(posedge clk)
                red = 82 + i;
                blue = 63 + i;
                green = 11 + i;
                @(valid)
                $display("red = %3d, blue = %3d, green = %3d", red, blue, green);
                $display("color = %3d, bw = %3d\n", color, bw);
        end
        $finish;
    end




endmodule