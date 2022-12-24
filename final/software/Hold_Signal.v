// -------------------------------------------------------------
// 
// File Name: C:\Users\team06\Documents\MATLAB\Examples\R2022b\visionhdl\BlobAnalysisExample\verilog_hdl\BlobAnalysisHDL\Hold_Signal.v
// Created: 2022-12-23 11:30:02
// 
// Generated by MATLAB 9.13 and HDL Coder 4.0
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: Hold_Signal
// Source Path: BlobAnalysisHDL/BlobDetector/CCA_Algorithm/cca/Hold Signal
// Hierarchy Level: 3
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module Hold_Signal
          (clk,
           reset,
           enb,
           triggerStart,
           triggerEnd,
           Signal);


  input   clk;
  input   reset;
  input   enb;
  input   triggerStart;
  input   triggerEnd;
  output  Signal;


  wire Logical_Operator1_out1;
  wire Logical_Operator_out1;
  wire Constant6_out1;
  wire Constant5_out1;
  wire Switch3_out1;
  reg  Delay6_out1;
  wire Switch4_out1;


  assign Logical_Operator1_out1 =  ~ triggerStart;



  assign Logical_Operator_out1 = triggerEnd & Logical_Operator1_out1;



  assign Constant6_out1 = 1'b1;



  assign Constant5_out1 = 1'b0;



  always @(posedge clk or posedge reset)
    begin : Delay6_process
      if (reset == 1'b1) begin
        Delay6_out1 <= 1'b0;
      end
      else begin
        if (enb) begin
          Delay6_out1 <= Switch3_out1;
        end
      end
    end



  assign Switch4_out1 = (triggerStart == 1'b0 ? Delay6_out1 :
              Constant6_out1);



  assign Switch3_out1 = (Logical_Operator_out1 == 1'b0 ? Switch4_out1 :
              Constant5_out1);



  assign Signal = Switch3_out1;

endmodule  // Hold_Signal

