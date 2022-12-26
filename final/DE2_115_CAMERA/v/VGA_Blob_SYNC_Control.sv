module VAG_Blob_SYNC_Control (
    input i_clk,
    input i_rst_n,
    input i_oPROC_CCD,
    input i_VGA_VSYNC,
    output o_grayscale_start
);

parameter S_WAIT_OPROC = 0;
parameter S_WAIT_VSYNC_I = 1;
parameter S_WAIT_OPROC_N = 2;
parameter S_WAIT_VSYNC_II = 3;

logic [1:0] state_r;
logic [1:0] state_w;

logic o_grayscale_start_r;
logic o_grayscale_start_w;

always_comb begin
    o_grayscale_start_w = o_grayscale_start_r;
    state_w = state_r;
    case(state_r)
        S_WAIT_OPROC: begin
            if(i_VGA_VSYNC && i_oPROC_CCD) begin
                state_w = S_WAIT_OPROC_N;
                o_grayscale_start_w = 1;
            end
            else if (i_oPROC_CCD) begin
                state_w = S_WAIT_VSYNC_I;
            end
        end
        S_WAIT_VSYNC_I: begin
            if(i_VGA_VSYNC) begin
                state_w = S_WAIT_OPROC_N;
                o_grayscale_start_w = 1;
            end
        end
        S_WAIT_OPROC_N: begin
            if(~i_oPROC_CCD && i_VGA_VSYNC) begin
                state_w = S_WAIT_OPROC;
                o_grayscale_start_w = 0;
            end
            else if (~i_oPROC_CCD) begin
                state_w = S_WAIT_VSYNC_II;
                o_grayscale_start_w = 1;
            end
            else begin
                o_grayscale_start_w = 1;
                state_w = S_WAIT_OPROC_N;
            end

        end
        S_WAIT_VSYNC_II: begin
            if(i_VGA_VSYNC) begin
                state_w = S_WAIT_OPROC;
                o_grayscale_start_w = 0;
            end
            else begin
                state_w = S_WAIT_VSYNC_II;
                o_grayscale_start_w = 1;
            end
        end
    endcase
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        state_r <= S_WAIT_OPROC;
        o_grayscale_start_r <= 0;
    end
    else begin
        state_r <= state_w;
        o_grayscale_start_r <= o_grayscale_start_w;
    end
end

endmodule