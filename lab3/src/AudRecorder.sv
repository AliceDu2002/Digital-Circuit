module AudRecorder {
    input i_rst_n, 
	input i_clk,
    input i_lrc,   // 1 start recording
	input i_start, // from Top, size not determined
	input i_pause, // from Top, size not determined
	input i_stop,  // from Top, size not determined
	input i_data,  // ADCDAT, data to store
	output[19:0] o_address, // to where in SRAM
	output[15:0] o_data, // to SRAM
};

always_comb begin
	// design your control here
end

always_ff @(posedge i_AUD_BCLK or negedge i_rst_n) begin
	if (!i_rst_n) begin
		
	end
	else begin
		
	end
end

endmodule