module RGB2YCrCb(
    input i_clk,
    input i_rst,
    input [7:0] i_red,
    input [7:0] i_green,
    input [7:0] i_blue,
    input i_valid,
    output [7:0] o_Y,
    output [7:0] o_Cb,
    output [7:0] o_Cr,
    output o_valid
)

logic o_valid_r;
logic [7:0] o_Y_r, o_Cb_r, o_Cr_r;

assign o_valid = o_valid_r;
assign o_Cb = o_Cb_r;
assign o_Cr = o_Cr_r;
assign o_Y = o_Y_r;

always_comb begin
    
end

always_ff @(posedge clk or posedge i_rst) begin
    if(i_rst) begin
        o_Y_r <= 0;
        o_Cb_r <= 0;
        o_Cr_r <= 0;
        o_valid_r <= 0;
    end
    else begin
        
    end
end