`timescale 1ns/100ps

module tb;
	localparam DACLRCK = 500;
	localparam HDACLRCK = DACLRCK/2;

    localparam BCLK = 10;
	localparam HBCLK = BCLK/2;

    reg adclrck_r, bclk_r;
    wire adclrck, bclk;
    logic rst_n;
    logic key_0, key_1, key_2;
    logic [2:0] speed;
    logic fast, interpolation;

    logic [19:0] sram_ADDR;
    wire [15:0] sram_dq;
    logic sram_we_n;
    logic output_data;
    logic input_data; // random sequence
    always #BCLK input_data = $random%2;
    
    initial adclrck_r = 1;
	initial bclk_r = 0;
    assign adclrck = adclrck_r;
    assign bclk = bclk_r;

    always #HDACLRCK adclrck_r = ~adclrck_r;
    always #HBCLK bclk_r = ~bclk_r;

    Memory mem(
        .addr(sram_ADDR),
        .data(sram_dq),
        .wr_enable(sram_we_n),
        .data_o(sram_dq)
    );
    Top top(
        .i_rst_n(rst_n),
        .i_clk(bclk),
        .i_key_0(key_0),
        .i_key_1(key_1),
        .i_key_2(key_2),
        .i_speed(speed), // design how user can decide mode on your own

        .i_fast(fast),
        .i_interpolation(interpolation),
        
        // AudDSP and SRAM
        .o_SRAM_ADDR(sram_ADDR),
        .io_SRAM_DQ(sram_dq),
        .o_SRAM_WE_N(sram_we_n),
        .o_SRAM_CE_N(),
        .o_SRAM_OE_N(),
        .o_SRAM_LB_N(),
        .o_SRAM_UB_N(),
        
        // I2C
        .i_clk_100k(adclrck),
        .o_I2C_SCLK(),
        .io_I2C_SDAT(),
        
        // AudPlayer
        .i_AUD_ADCDAT(input_data),
        .i_AUD_ADCLRCK(adclrck),
        .i_AUD_BCLK(bclk),
        .i_AUD_DACLRCK(adclrck),
        .o_AUD_DACDAT(output_data)
    );
    initial begin
        $fsdbDumpfile("Top.fsdb");
		$fsdbDumpvars;
        rst_n = 0;
        #(2*BCLK)
        rst_n = 1;
        #(2500*BCLK)
        $finish;
    end


endmodule