module VGA_Blob_SYNC_Control (
    input i_clk,
    input i_rst_n,
    input i_oPROC_CCD,
    input i_VGA_VSYNC,
    input i_blob_end,
    output o_grayscale_start,
    output o_blob_end
);

parameter S_WAIT_OPROC = 0;
parameter S_WAIT_VSYNC_I = 1;
parameter S_WAIT_OPROC_N = 2;
parameter S_WAIT_VSYNC_II = 3;

logic [1:0] state_r;
logic [1:0] state_w;

logic o_grayscale_start_r;
logic o_grayscale_start_w;
assign o_grayscale_start = o_grayscale_start_r;

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

parameter S_WAIT_BLOB = 0;
parameter S_WAIT_VSYNC_I = 1;
parameter S_IDLE = 2;

logic[1:0] end_state_r, end_state_w;
logic o_blob_end_r, o_blob_end_w;
assign o_blob_end = o_blob_end_r;

always_comb begin
    end_state_w = end_state_r;
    o_blob_end_w = o_blob_end_r;
    case(end_state_r)
        S_WAIT_BLOB: begin
            if(i_VGA_VSYNC && i_blob_end) begin
                end_state_w = S_IDLE;
                o_blob_end_w = 1;
            end
            else if (i_blob_end) begin
                end_state_w = S_WAIT_VSYNC_I;
            end
        end
        S_WAIT_VSYNC_I: begin
            if(i_VGA_VSYNC) begin
                state_w = S_IDLE;
                o_blob_end_w = 1;
            end
        end
        S_IDLE: begin
            end_state_w = S_IDLE;
        end
    endcase
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n) begin
        state_r <= S_WAIT_OPROC;
        o_grayscale_start_r <= 0;
        end_state_r <= S_WAIT_BLOB;
        o_blob_end_r <= 0;
    end
    else begin
        state_r <= state_w;
        o_grayscale_start_r <= o_grayscale_start_w;
        end_state_r <= end_state_w;
        o_blob_end_r <= o_blob_end_w;

    end
end

endmodule