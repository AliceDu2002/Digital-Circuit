`define SIZE 169
module Grayscale (
    input i_clk,
    input i_rst_n,
    input i_start,

    // communication with SDRAM
    output read_request,
    input[9:0] i_red,
    input[9:0] i_green,
    input[9:0] i_blue,

    // communication with further image process
    output[9:0] o_color,
    output[9:0] o_bw,
    output o_valid
);

// === states ===
parameter S_IDLE = 0;
parameter S_COLOR = 1;

// === parameters ===
parameter weight_red = 8'b10011001;
parameter weight_green = 10'b1001011001;
parameter weight_blue = 6'b100101;
parameter threshold = 125;
parameter shift_red = 9;
parameter shift_green = 10;
parameter shift_blue = 8;
parameter num_pixel = `SIZE;
logic state_r, state_w;
logic[20:0] red_r, red_w;
logic[20:0] green_r, green_w;
logic[20:0] blue_r, blue_w;
logic read_request_r, read_request_w; 
logic[19:0] count_r, count_w;
logic valid_r, valid_w;

// === outputs ===
assign o_bw = (red_r[9:0] + green_r[9:0] + blue_r[9:0] > threshold) ? 255 : 0;
assign o_color = red_r[9:0] + green_r[9:0] + blue_r[9:0];
assign read_request = read_request_r;
assign o_valid = valid_r;

always_comb begin
    state_w = state_r;
    red_w = red_r;
    green_w = green_r;
    blue_w = blue_r;
    read_request_w = read_request_r;
    count_w = count_r;
    valid_w = valid_r;

    case(state_r)
    S_IDLE: begin
        if(i_start) begin
            read_request_w = 1;
            state_w = S_COLOR;
            count_w = 0;
        end

    end
    S_COLOR: begin
        read_request_w = 0;
        count_w = count_r + 1;
        valid_w = 1;
        red_w = (i_red*weight_red) >> shift_red;;
        green_w = (i_green*weight_green) >> shift_green;
        blue_w = (i_blue*weight_blue) >> shift_blue;
        state_w = S_COLOR;
        if(count_r >= num_pixel) begin
            state_w = S_IDLE;
            valid_w = 0;
        end
    end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r <= 0;
        red_r <= 0;
        green_r <= 0;
        blue_r <= 0;
        read_request_r <= 0;
        count_r <= 0;
        valid_r <= 0;
    end
    else begin
        state_r <= state_w;
        red_r <= red_w;
        green_r <= green_w;
        blue_r <= blue_w;
        read_request_r <= read_request_w;
        count_r <= count_w;
        valid_r <= valid_w;
    end
end

endmodule