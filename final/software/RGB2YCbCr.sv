module RGB2YCrCb (
    iCLK,
    iRESET,
   
    iRed,
    iGreen,
    iBlue,
    iDVAL,
    oY,
    oCb,
    oCr,
    oDVAL
  );
  //   Input
  input        iCLK,iRESET,iDVAL;
  input [11:0] iRed,iGreen,iBlue;
 
  //   Output
  output reg [11:0] oY,oCb,oCr;
  output reg oDVAL;
  //   Internal Registers/Wires
  reg     [3:0] oDVAL_d;
  reg   [15:0] tY_r,tU_r,tV_r;
  wire  [25:0] tY,tU,tV;

  always@(posedge iCLK)
  begin
    if(iRESET)
    begin
      oDVAL<=0;
      oDVAL_d<=0;
      oY <=0;
      oCr<=0;
      oCb<=0;
    end
    else
    begin
      // Red
      if(tY_r[15])
        oY<=0;
      else if(tY_r[14:0]>4095)
        oY<=4095;
      else
        oY<=tY_r[11:0];
     
      // Green
      if(tU_r[15])
        oCr<=0;
      else if(tU_r[14:0]>4095)
        oCr<=4095;
      else
        oCr<=tU_r[11:0];
     
      // Blue
      if(tV_r[15])
        oCb<=0;
      else if(tV_r[14:0]>4095)
        oCb<=4095;
      else
        oCb<=tV_r[11:0];
     
      // Control
      {oDVAL,oDVAL_d}<={oDVAL_d,iDVAL};
    end
  end

  always@(posedge iCLK)
  begin
    if(iRESET)
    begin
      tY_r <= 0;
      tU_r <= 0;
      tV_r <= 0;
    end
    else
    begin
      tY_r <= ( tY + 262144  ) >> 10;
      tU_r <= ( tU + 2097152 ) >> 10;
      tV_r <= ( tV + 2097152 ) >> 10;
    end
  end

// Y  << 10 =  (12'h107 * R) + (12'h204 * G) + (12'h064 * B) + 20'h04000
  MAC_3 u0(
      .aclr0   ( iRESET  ),
      .clock0  ( iCLK    ),
      .dataa_0 ( iRed    ),
      .dataa_1 ( iGreen  ),
      .dataa_2 ( iBlue   ),
      .datab_0 ( 12'h107 ),
      .datab_1 ( 12'h204 ),
      .datab_2 ( 12'h064 ),
      .result  ( tY      )      
  );
//  Cr << 10 =  (12'h1C2 * R) + (12'hE87 * G) + (12'hFB7 * B) + 20'h20000
  MAC_3 u1(
      .aclr0   ( iRESET  ),
      .clock0  ( iCLK    ),
      .dataa_0 ( iRed    ),
      .dataa_1 ( iGreen  ),
      .dataa_2 ( iBlue   ),
      .datab_0 ( 12'h1C2 ),
      .datab_1 ( 12'hE87 ),
      .datab_2 ( 12'hFB7 ),
      .result  ( tU      )      
  );
// Cb << 10 =  (12'hF68 * R) + (12'hED6 * G) + (12'h1C2 * B) + 20'h20000
  MAC_3 u2(
      .aclr0   ( iRESET  ),
      .clock0  ( iCLK    ),
      .dataa_0 ( iRed    ),
      .dataa_1 ( iGreen  ),
      .dataa_2 ( iBlue   ),
      .datab_0 ( 12'hF68 ),
      .datab_1 ( 12'hED6 ),
      .datab_2 ( 12'h1C2 ),
      .result  ( tV      )      
  );
endmodule