module VGA(
    input i_clk; // 25k
    input i_rst_n;

    // from Camera
    input[7:0] red;
    input[7:0] green;
    input[7:0] blue;

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
logic hs_r, hs_w; // end of a row
logic vs_r, vs_w; // end of a frame
logic blank_n_r, blank_n_w;
logic sync_n_r, sync_n_w;
logic vclk_r, vcli=k_w;

// === outputs ===
assign vga_r = red;
assign vga_g = green;
assign vga_b = blue;

always_comb begin

end

always_ff @(posedge i_clk or negedge i_rst_n) begin

end

endmodule