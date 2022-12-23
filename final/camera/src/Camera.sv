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
    output[19:0] address; // length?
    inout[23:0] data; // a pixel

    // to VGA
    output[7:0] vga_red;
    output[7:0] vga_green;
    output[7:0] vga_blue;

    // communication with NIOS
    input capture;
    input nios_finish;

);

//=== states ===
parameter S_IDLE = 0;
parameter S_INIT = 1;
parameter S_IMAGE = 2;
parameter S_ROW = 3;
parameter S_PIXEL = 4;
parameter S_RGB = 5;
parameter S_CAPT = 6;

//=== parameters ===
logic[2:0] state_r, state_w;
logic[11:0] rgb4_r, rgb4_w;
logic[23:0] rgb8_r, rgb8_w;
logic initial_ready_r, initial_ready_w, initial_finish;
logic address_r, address_w;// address
logic count_byte_r, count_byte_w;
logic[8:0] count_row_r, count_row_w;
logic[9:0] count_col_r, count_col_w; 
logic capture_r, capture_w;

//=== output ===
assign vga_red = rgb8_r[23:16];
assign vga_green = rgb8_r[15:8];
assign vga_blue = rgb8_r[7:0];
assign data = rgb8_r;
assign address = address_r;

//=== submodule ===
Intializer initializer();

always_comb begin
    rgb4_w = rgb4_r;
    rgb8_w = rgb8_r;
    inital_ready_w = inital_ready_r;
    address_w = address_r;
    state_w = state_r;
    count_byte_w = count_byte_r;
    count_row_w = count_row_r;
    count_col_w = count_col_r;
    capture_w = capture_r;
    case(state_r)
        S_IDLE: begin
            initial_ready_w = 1;
            state_w = S_INIT;
        end
        S_INIT: begin
            inital_ready_w = 0;
            if(initial_finish) begin
                state_w = S_IMAGE;
            end
        end
        S_IMAGE: begin
            if(ov7670_vsync) begin
                state_w = S_ROW;
                address_w = 0;
            end
            if(capture || capture_r) begin
                state_w = S_CAPT;
            end
        end
        S_ROW: begin
            if(capture) begin capture_w = 1; end
            if(!ov7670_vsync) begin
                if(count_row_r < 480) begin
                    if(ov7670_href) begin
                        state_w = S_PIXEL;
                    end
                end
                else begin
                    state_w = S_IMAGE;
                end
            end
        end
        S_PIXEL: begin
            if(capture) begin capture_w = 1; end
            if(count_col_r < 639) begin
                if(!count_byte_r)   begin 
                    rgb4_w[11:8] = ov7670_data[3:0];
                    count_byte_w = count_byte_r + 1;  
                end
                else if(count_byte_r)    begin 
                    count_byte_w = count_byte_r + 1;
                    count_col_w = count_col_r + 1;
                    address_w = address_r + 1;
                    rgb8_w[23:20] = rgb4_r[11:8];
                    rgb8_w[19:16] = 4'd0;
                    rgb8_w[15:13] = ov7670_data[7:4];
                    rgb8_w[12:8] = 4'd0;
                    rgb8_w[7:4] = ov7670_data[3:0];
                    rgb8_w[4:0] = 4'd0;
                end
                state_w = S_PIXEL;
            end
            else if(count_col_r == 639) begin
                if(!count_byte_r)   begin 
                    rgb4_w[11:8] = ov7670_data[3:0];
                    count_byte_w = count_byte_r + 1;
                end
                if(count_byte_r)    begin 
                    count_byte_w = count_byte_r + 1;
                    count_col_w = count_col_r + 1;
                    address_w = address_r + 1;
                    rgb8_w[23:20] = rgb4_r[11:8];
                    rgb8_w[19:16] = 4'd0;
                    rgb8_w[15:13] = ov7670_data[7:4];
                    rgb8_w[12:8] = 4'd0;
                    rgb8_w[7:4] = ov7670_data[3:0];
                    rgb8_w[4:0] = 4'd0;
                end
                if(!ov7670_href) begin
                    count_row_w = count_row_r + 1;
                    state_w = S_ROW;
                end
            end
        end
        S_CAPT: begin
            if(nios_finish) begin
                if(!ov7670_vsync) begin state_w = S_IMAGE; end
            end
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        rgb4_r <= 0;
        rgb8_r <= 0;
        inital_ready_r <= 0;
        address_r <= 0;
        state_r <= 0;    
        count_byte_r <= 0;
        count_row_r <= 0;
        count_col_r <= 0; 
        capture_r <= 0;  
    end
    else begin
        rgb4_r <= rgb4_w;
        rgb8_r <= rgb8_w;
        inital_ready_r <= inital_ready_w;
        address_r <= address_w;
        state_r <= state_w;
        count_byte_r <= count_byte_w;
        count_row_r <= count_row_w;
        count_col_r <= count_col_w;
        capture_w <= 0;
    end
end

endmodule


