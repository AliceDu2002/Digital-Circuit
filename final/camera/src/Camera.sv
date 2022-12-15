module Camera (
    input i_clk_50; // controller
    input i_rst_n; // key[0]

    // for initializer
    output ov7670_xclk;
    output ov7670_sioc;
    inout ov7670_siod;
    output ov7670_pwdn;
    output ov7670_reset;

    // for capture (no module -> faster?)
    input ov7670_pclk;
    input ov7670_vsync;
    input ov7670_href;
    input[7:0] ov7670_data; // get RGB data

    // to SDRAM
    output address; // length?
    inout[23:0] data; // a pixel

    // to VGA
    output[7:0] vga_red;
    output[7:0] vga_green;
    output[7:0] vga_blue;

);

//=== states ===

//=== parameters ===

//=== submodule ===
Intializer initializer();
Frame_Buffer frame_buffer(); // create buffer for pixel data ??
Address_Generator address_generator();

always_comb begin

end

always_ff @(posedge i_clk or negedge i_rst_n) begin

end

endmodule


