// --------------------------------------------------------------------
// Copyright (c) 2007 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	SEG7_LUT_8
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny FAN        :| 07/07/09  :| Initial Revision
// --------------------------------------------------------------------

module SEG7_LUT_8 (	oSEG0,oSEG1,oSEG2,oSEG3,oSEG6,oSEG7,iDIG,iCOLOR );
input	[31:0]	iDIG;
output	[6:0]	oSEG0,oSEG1,oSEG2,oSEG3,oSEG6,oSEG7;
input   [7:0]   iCOLOR;

SEG7_LUT	u0	(	oSEG0,iDIG[3:0]		);
SEG7_LUT	u1	(	oSEG1,iDIG[7:4]		);
SEG7_LUT	u2	(	oSEG2,iDIG[11:8]	);
SEG7_LUT	u3	(	oSEG3,iDIG[15:12]	);
SEG7_LUT	u6	(	oSEG6,iCOLOR[3:0]	);
SEG7_LUT	u7	(	oSEG7,iCOLOR[7:4]	);

endmodule