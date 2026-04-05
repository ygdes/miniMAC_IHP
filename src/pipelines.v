/*
    pipelines.v
    created sam. 28 mars 2026 04:07:10 CET by whygee@f-cpu.org

    This file is a collection of "pipelines" of various characteristics,
    easily swappable so it's integrated in project.v
    
    version lun. 06 avril 2026 00:25:08 CEST : conversion to generic IHP gates
*/

/* Short circuit config : */
module pipe_empty(
  input wire clk,
  input wire rst,
  input wire Encode,
  input wire Decode,
  input wire Din_OK,
  input wire [17:0] FirstWord,
  output wire Dout_OK,
  output wire [17:0] LastWord 
);
  wire _unused = &{ Encode, Decode, clk, rst, 1'b0};
  
  assign LastWord = FirstWord;
  assign Dout_OK = Din_OK;
endmodule

module pipe_encode_Hammer(
  input wire clk,
  input wire rst,
  input wire Encode,
  input wire Decode,
  input wire Din_OK,
  input wire [17:0] FirstWord,
  output wire Dout_OK,
  output wire [17:0] LastWord 
);
  wire _unused = &{ Decode, 1'b0};

  wire [17:0] HammerEnc_result;
  Encode_Hamming_early Henc(
      .clk(clk), .rst(rst), .HammEn(Din_OK),
      .HammIn(FirstWord), .HammOut(HammerEnc_result) );

  // Mux
  mux2_x18 selEnc( .sel(Encode), .if0(FirstWord), .if1(HammerEnc_result), .res(LastWord) );

  assign Dout_OK = Din_OK;
endmodule

module pipe_encode_decode_Hammer(
  input wire clk,
  input wire rst,
  input wire Encode,
  input wire Decode,
  input wire Din_OK,
  input wire [17:0] FirstWord,
  output wire Dout_OK,
  output wire [17:0] LastWord 
);
  wire _unused = &{ Decode, 1'b0};

  wire [17:0] HammerEnc_result, tmpSel;
  Encode_Hamming_early Henc(
      .clk(clk), .rst(rst), .HammEn(Din_OK),
      .HammIn(FirstWord), .HammOut(HammerEnc_result) );
  mux2_x18 selEnc( .sel(Encode), .if0(FirstWord), .if1(HammerEnc_result), .res(tmpSel) );

  wire [17:0] HammerDec_result;
  Decode_Hamming_early Hdec(
      .clk(clk), .rst(rst), .HammEn(Din_OK),
      .HammIn(FirstWord), .HammOut(HammerDec_result) );
  mux2_x18 selDec( .sel(Decode), .if0(tmpSel), .if1(HammerDec_result), .res(LastWord) );

  assign Dout_OK = Din_OK;
endmodule

module pipe_encode_decode_loopback_Hammer(
  input wire clk,
  input wire rst,
  input wire Encode,
  input wire Decode,
  input wire Din_OK,
  input wire [17:0] FirstWord,
  output wire Dout_OK,
  output wire [17:0] LastWord 
);
  wire [17:0] HammerEnc_result, tmpSel;
  Encode_Hamming_early Henc(
      .clk(clk), .rst(rst), .HammEn(Din_OK),
      .HammIn(FirstWord), .HammOut(HammerEnc_result) );
  mux2_x18 selEnc( .sel(Encode), .if0(FirstWord), .if1(HammerEnc_result), .res(tmpSel) );

  wire [17:0] HammerDec_result, HammerDec_operand;
  wire DecOpSel;
  sg13_and2_1 AndSel(.A(Encode), .B(Decode), .X(DecOpSel));
  mux2_x18 selOpDec( .sel(DecOpSel), .if0(FirstWord), .if1(HammerEnc_result), .res(HammerDec_operand) );
  Decode_Hamming_early Hdec(
      .clk(clk), .rst(rst), .HammEn(Din_OK),
      .HammIn(HammerDec_operand), .HammOut(HammerDec_result) );

  mux2_x18 selDec( .sel(Decode), .if0(tmpSel), .if1(HammerDec_result), .res(LastWord) );

  assign Dout_OK = Din_OK;
endmodule

module pipe_sans_Hammer(
  input wire clk,
  input wire rst,
  input wire Encode,
  input wire Decode,
  input wire Din_OK,
  input wire [17:0] FirstWord,
  output wire Dout_OK,
  output wire [17:0] LastWord 
);
  wire [17:0] HammerEnc_result, tmpSel;
  Encode_Hamming_empty Henc(
      .clk(clk), .rst(rst), .HammEn(Din_OK),
      .HammIn(FirstWord), .HammOut(HammerEnc_result) );
  mux2_x18 selEnc( .sel(Encode), .if0(FirstWord), .if1(HammerEnc_result), .res(tmpSel) );

  wire [17:0] HammerDec_result, HammerDec_operand;
  wire DecOpSel;
  sg13_and2_1 AndSel(.A(Encode), .B(Decode), .X(DecOpSel));
  mux2_x18 selOpDec( .sel(DecOpSel), .if0(FirstWord), .if1(HammerEnc_result), .res(HammerDec_operand) );
  Decode_Hamming_empty Hdec(
      .clk(clk), .rst(rst), .HammEn(Din_OK),
      .HammIn(HammerDec_operand), .HammOut(HammerDec_result) );

  mux2_x18 selDec( .sel(Decode), .if0(tmpSel), .if1(HammerDec_result), .res(LastWord) );

  assign Dout_OK = Din_OK;
endmodule


module pipe_sans_Hammer_gPEACencode(
  input wire clk,
  input wire rst,
  input wire Encode,
  input wire Decode,
  input wire Din_OK,
  input wire [17:0] FirstWord,
  output wire Dout_OK,
  output wire [17:0] LastWord 
);

// Encoding
  wire [17:0] HammerEnc_result, gPEACenc_result, tmpSel;
  wire emPEAC_phase1, emPEAC_phase2;

  // pipeline : Din_OK---[]---emPEAC_phase1---[]---emPEAC_phase2
  //              \__phase0       \__phase1
  sg13_dfrbpq_1 dff_enc1(.Q(emPEAC_phase1), .D(Din_OK       ), .RESET_B(rst), .CLK(clk));
  sg13_dfrbpq_1 dff_enc2(.Q(emPEAC_phase2), .D(emPEAC_phase1), .RESET_B(rst), .CLK(clk));
  gPEAC18_scrambler emPEAC(
      .clk(clk), .rst(rst), .Phase0(Din_OK), .Phase1(emPEAC_phase1),
      .Message_in(FirstWord[16:0]), .X(gPEACenc_result));

  Encode_Hamming_empty Henc(
      .clk(clk), .rst(rst), .HammEn(emPEAC_phase2),
      .HammIn(gPEACenc_result), .HammOut(HammerEnc_result) );
  
  mux2_x18 selEnc( .sel(Encode), .if0(FirstWord), .if1(HammerEnc_result), .res(tmpSel) );
  sg13_mux2_2 selEncEn(.S(Encode), .A0(Din_OK), .A1(emPEAC_phase2), .X(Dout_OK));

// Decoding
  wire [17:0] HammerDec_result, HammerDec_operand;
  wire DecOpSel;
  sg13_and2_1 AndSel(.A(Encode), .B(Decode), .X(DecOpSel));
  mux2_x18 selOpDec( .sel(DecOpSel), .if0(FirstWord), .if1(HammerEnc_result), .res(HammerDec_operand) );
  Decode_Hamming_early Hdec(
      .clk(clk), .rst(rst), .HammEn(Din_OK),
      .HammIn(HammerDec_operand), .HammOut(HammerDec_result) );

  mux2_x18 selDec( .sel(Decode), .if0(tmpSel), .if1(HammerDec_result), .res(LastWord) );

//  assign Dout_OK = Din_OK;
endmodule
