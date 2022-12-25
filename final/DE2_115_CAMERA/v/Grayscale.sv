`define SIZE 640*480-1
`define THRESHOLD 20
module Grayscale (
    // input i_clk,
    // input i_rst_n,
    // input i_start,

    // communication with SDRAM
    // output read_request,
    input[9:0] i_red,
    input[9:0] i_green,
    input[9:0] i_blue,

    // communication with further image process
    output[9:0] o_color,
    output o_bw,
    output o_valid,
    output[9:0] o_red,
    output[9:0] o_green,
    output[9:0] o_blue,
    output o_vga
);

// === states ===
parameter S_IDLE = 0;
parameter S_COLOR = 1;
parameter S_WAIT = 2;

// === parameters ===
parameter weight_red = 5'b10011; // 0.010011
parameter weight_green = 7'b1001011; // 0.1001011
parameter weight_blue = 6'b100101; // 0.00100101
parameter shift_red = 6;
parameter shift_green = 7;
parameter shift_blue = 8;
parameter num_pixel = `SIZE;
logic[1:0] state_r, state_w;
logic[20:0] red_r, red_w;
logic[20:0] green_r, green_w;
logic[20:0] blue_r, blue_w;
logic read_request_r, read_request_w; 
logic[19:0] count_r, count_w;
logic valid_r, valid_w;
logic vga_start_r, vga_start_w;
logic first_frame_r, first_frame_w;
logic[10:0] color_w;

// === outputs ===
assign o_bw = (color_w > `THRESHOLD) ? 10'b111111 : 0;
assign o_color = color_w[10:1];
assign o_red = i_red;
assign o_green = i_green;
assign o_blue = i_blue;
assign o_valid = valid_r;
assign o_vga = vga_start_r;

always_comb begin
    red_w = (i_red*weight_red) >> shift_red;
    green_w = (i_green*weight_green) >> shift_green;
    blue_w = (i_blue*weight_blue) >> shift_blue;
    color_w = (red_w + green_w + blue_w);

//     state_w = state_r;
//     red_w = red_r;
//     green_w = green_r;
//     blue_w = blue_r;
//     read_request_w = read_request_r;
//     count_w = count_r;
//     valid_w = valid_r;
//     vga_start_w = vga_start_r;
//     first_frame_w = first_frame_r;

//     case(state_r)
//     S_IDLE: begin
//         if(i_start) begin
//             read_request_w = 1;
//             if(first_frame_r) begin
//                 vga_start_w = 1;
//             end
//             state_w = S_COLOR;
//             count_w = 0;
//         end

//     end
//     S_COLOR: begin
//         read_request_w = 0;
//         vga_start_w = 0;
//         count_w = count_r + 1;
//         valid_w = 1;
//         // red_w = (i_red*weight_red) >> shift_red;;
//         // green_w = (i_green*weight_green) >> shift_green;
//         // blue_w = (i_blue*weight_blue) >> shift_blue;
//         red_w[9:0] = i_red;
//         green_w[9:0] = i_green;
//         blue_w[9:0] = i_blue;
//         state_w = S_COLOR;
//         if(count_r >= `SIZE) begin
//             state_w = S_IDLE;
//             valid_w = 0;
//             first_frame_w = 0;
//         end
//     end
//     S_WAIT: begin
//         if(!i_start) begin
//             state_w = S_IDLE;
//         end
//     end
//     endcase
end

// always_ff @(posedge i_clk or negedge i_rst_n) begin
//     if(!i_rst_n) begin
//         state_r <= 0;
//         red_r <= 0;
//         green_r <= 0;
//         blue_r <= 0;
//         read_request_r <= 0;
//         count_r <= 0;
//         valid_r <= 0;
//         vga_start_r <= 0;
//         first_frame_r <= 1;
//     end
//     else begin
//         state_r <= state_w;
//         red_r <= red_w;
//         green_r <= green_w;
//         blue_r <= blue_w;
//         read_request_r <= read_request_w;
//         count_r <= count_w;
//         valid_r <= valid_w;
//         vga_start_r <= vga_start_w;
//         first_frame_r <= first_frame_w;
//     end
// end

endmodule