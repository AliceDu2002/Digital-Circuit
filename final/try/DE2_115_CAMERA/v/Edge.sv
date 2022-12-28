`define TEMPLATE_SIZE 3
`define PADDING 1
module Edge(
    input i_clk,
    input i_rst_n,

    // from Grayscale
    input i_start,
    input[9:0] i_color,

    // to further image process
    output o_valid,
    output[9:0] o_width,
    output[9:0] o_height,
    output[9:0] o_pixel
);

// === states ===
parameter S_IDLE = 0;
parameter S_FILL = 1; // only filling
parameter S_BOTH = 2; // filling + calculate
parameter S_CALC = 3; // only calculating

// === parameters ===
`ifdef VGA_640x480p60
parameter width = 640 + `PADDING * 2;
parameter height = 480 + `PADDING * 2;
parameter real_width = 640;
`else
parameter width = 800 + `PADDING * 2;
parameter height = 600 + `PADDING * 2;
parameter real_width = 800;
`endif
parameter o_w = (width - `TEMPLATE_SIZE) + 1;
parameter o_h = (height - `TEMPLATE_SIZE) + 1;
parameter o_size = o_w * o_h;
parameter data_size = (`TEMPLATE_SIZE - 1) * width + `TEMPLATE_SIZE - 1;
parameter start_process = width * `PADDING + `PADDING;
parameter integer weight_x [8:0] = {-1, 0, 1, -2, 0, 2, -1, 0, 1};
parameter integer weight_y [8:0] = {1, 2, 1, 0, 0, 0, -1, -2, -1};

logic[1:0] state_r, state_w;
logic[9:0] data_r[data_size:0];
logic[9:0] data_w[data_size:0];
logic valid_r, valid_w;
logic[9:0] pixel_r, pixel_w;
logic signed[10:0] x_temp, y_temp;
logic[9:0] x_r, x_w;
logic[9:0] y_r, y_w;
logic[20:0] count_r, count_w;
logic[9:0] count_width_r, count_width_w;

// === output ===
assign o_width = o_w;
assign o_height = o_h;
assign o_valid = valid_r;
assign o_pixel = pixel_r;

// === task ===
task flowing;
    input[9:0] update;
    begin
        if(count_width_r < real_width) begin
            for(integer i = 0; i < data_size; i = i+1) begin
                data_w[i] = data_r[i + 1];
            end
            data_w[data_size] = update;
            count_w = count_r + 1;
            count_width_w = count_width_r + 1;
        end
        else begin
            for(integer i = 0; i < data_size - 2; i = i+1) begin
                data_w[i] = data_r[i + 3];
            end
            data_w[data_size - 2] = 0;
            data_w[data_size - 1] = 0;
            data_w[data_size] = update;
            count_w = count_r + 1 + `PADDING * 2;
            count_width_w = 1;
        end
    end
endtask

task calculate;
    begin
        x_temp = data_r[0]*weight_x[0] + data_r[1]*weight_x[1] + data_r[2]*weight_x[2] +
                data_r[width]*weight_x[3] + data_r[width+1]*weight_x[4] + data_r[width+2]*weight_x[5] +
                data_r[2*width]*weight_x[6] + data_r[2*width+1]*weight_x[7] + data_r[2*width+2]*weight_x[8];
        y_temp = data_r[0]*weight_y[0] + data_r[1]*weight_y[1] + data_r[2]*weight_y[2] +
                data_r[width]*weight_y[3] + data_r[width+1]*weight_y[4] + data_r[width+2]*weight_y[5] +
                data_r[2*width]*weight_y[6] + data_r[2*width+1]*weight_y[7] + data_r[2*width+2]*weight_y[8];
        x_w = (x_temp[10] == 0) ? $unsigned(x_temp) : $unsigned(-1 * x_temp);
        y_w = (y_temp[10] == 0) ? $unsigned(y_temp) : $unsigned(-1 * y_temp);
        pixel_w = (x_w + y_w > 500) ? 255 : 0;
    end
endtask

always_comb begin
    // remember to update data_w[data_size]
    state_w = state_r;
    valid_w = valid_r;
    pixel_w = pixel_r;
    x_w = x_r;
    y_w = y_r;
    count_w = count_r;
    count_width_w = count_width_r;
    for(integer i = 0; i <= data_size; i = i+1) begin
        data_w[i] = data_r[i];
    end

    case(state_r)
        S_IDLE: begin
            if(i_start) begin
                state_w = S_FILL;
                count_w = start_process;
                count_width_w = 0;
            end
        end
        S_FILL: begin
            if(count_r == data_size) begin
                state_w = S_BOTH;
                valid_w = 1;
            end
            else begin
                state_w = S_FILL;
            end
            flowing(i_color);
        end
        S_BOTH: begin
            calculate();
            flowing(i_color);
            if(!i_start) begin
                state_w = S_CALC;
                count_w = 0;
            end
            else begin
                state_w = S_BOTH;
            end
        end
        S_CALC: begin
            if(count_r < start_process - 1) begin
                flowing(10'd0);
                calculate();
                state_w = S_CALC;
            end
            else begin
                flowing(10'd0);
                calculate();
                valid_w = 0;
                state_w = S_IDLE;
            end
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state_r <= 0;
        for(integer i = 0; i <= data_size; i = i+1) begin
            data_r[i] <= 0;
        end
        valid_r <= 0;
        pixel_r <= 0;
        x_r <= 0;
        y_r <= 0;
        count_r <= 0;
        count_width_r <= 0;
    end
    else begin
        state_r <= state_w;
        for(integer i = 0; i <= data_size; i = i+1) begin
            data_r[i] <= data_w[i];
        end
        valid_r <= valid_w;
        pixel_r <= pixel_w;
        x_r <= x_w;
        y_r <= y_w;
        count_r <= count_w;
        count_width_r <= count_width_w;
    end
end
endmodule