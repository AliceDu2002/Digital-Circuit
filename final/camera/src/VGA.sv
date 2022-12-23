module VGA(
    input i_clk; // 25k
    input i_rst_n;

    // from Camera
    input[7:0] red;
    input[7:0] green;
    input[7:0] blue;
    input[19:0] address;
    input start_frame;

    // to DE2_115 VGA Port
    output vga_hsync;
    output vga_vsync;
    output[7:0] vga_r;
    output[7:0] vga_g;
    output[7:0] vga_b;
    output vga_blank_N;
    output vga_sync_N;
    output vga_CLK;
);

// === states ===

// === parameter ===
param HPIXELS = 640,
param HA = HPIXELS - 1,									// Hor. active area (0 to 639 = 640 pixels)
param HFP = HA + 16,										// Hor. front porch end position
param HSYNC = HFP + 96,									// Hor. sync end position
param HBP = HSYNC + 48,									// Hor. back porch end position

param VPIXELS = 480,
param VA = VPIXELS - 1,									// Vert. active area (0 to 479 = 480 pixels)
param VFP = VA + 10,										// Vert. front porch end position
param VSYNC = VFP + 2,									// Vert. sync end position
param VBP = VSYNC + 33;									// Vert. back porch end 

logic hs_r, hs_w; // end of a row
logic vs_r, vs_w; // end of a frame
logic blank_n_r, blank_n_w;
logic sync_n_r, sync_n_w;
logic vclk_r, vclk_w;

// === outputs ===
assign vga_r = red;
assign vga_g = green;
assign vga_b = blue;

always_comb begin

end

always_ff @(posedge i_clk or negedge i_rst_n) begin

end

endmodule