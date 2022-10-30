module Memory(
    input [19:0] addr,
    input [15:0] data,
    input wr_enable,
    output [15:0] data_o
);

logic [1048:0] mem [15:0];
assign data_o = mem[addr];
always @(*) begin
    if(wr_enable) begin
        mem[addr] = data;
    end
end
endmodule