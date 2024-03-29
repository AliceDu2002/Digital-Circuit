// -------------------------------------------------------------
// 
// File Name: C:\Users\team06\Documents\MATLAB\Examples\R2022b\visionhdl\BlobAnalysisExample\verilog_hdl\BlobAnalysisHDL\SimpleDualPortRAM_singlebit.v
// Created: 2022-12-23 11:30:02
// 
// Generated by MATLAB 9.13 and HDL Coder 4.0
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: SimpleDualPortRAM_singlebit
// Source Path: BlobAnalysisHDL/BlobDetector/CCA_Algorithm/Closing/LineBuffer/DATA_MEMORY/SimpleDualPortRAM_singlebit
// Hierarchy Level: 3
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module SimpleDualPortRAM_singlebit
          (clk,
           enb,
           wr_din,
           wr_addr,
           wr_en,
           rd_addr,
           rd_dout);

  parameter integer AddrWidth  = 1;
  parameter integer DataWidth  = 1;

  input   clk;
  input   enb;
  input   wr_din;
  input   [AddrWidth - 1:0] wr_addr;  // parameterized width
  input   wr_en;  // ufix1
  input   [AddrWidth - 1:0] rd_addr;  // parameterized width
  output  rd_dout;


  reg   ram [2**AddrWidth - 1:0];
  reg   data_int;
  integer i;

  initial begin
    for (i=0; i<=2**AddrWidth - 1; i=i+1) begin
      ram[i] = 0;
    end
    data_int = 0;
  end


  always @(posedge clk)
    begin : SimpleDualPortRAM_singlebit_process
      if (enb == 1'b1) begin
        if (wr_en == 1'b1) begin
          ram[wr_addr] <= wr_din;
        end
        data_int <= ram[rd_addr];
      end
    end

  assign rd_dout = data_int;

endmodule  // SimpleDualPortRAM_singlebit

