/*
  gPEAC18.v
  generalised (non-binary) PEAC scrambler/checksum/error detector
  with modulus=258114 
  See  https://hackaday.io/project/178998

  version sam. 28 mars 2026 17:49:24 CET: coversion to CMOS5L
  version lun. 06 avril 2026 00:25:08 CEST : conversion to generic IHP gates
*/

/* This module compares a 18-bit number to the modulus.
   Compare a bitvector with the constant 258114 = 0x3F042 = 111111000001000010
   Any number equal or above raises X */
module Compare_modulus(
    input wire [17:0] A,
    output wire X
);
  wire t1, t2, t3, t4, t5, t6, t7, _unused;
  assign _unused = A[0]; // The LSB has no effect.
  // first layer
  sg13_nand3_1 L1a3_1(.Y(t1), .A(A[17]), .B(A[16]), .C(A[15]));
  sg13_nand3_1 L1a3_2(.Y(t2), .A(A[14]), .B(A[13]), .C(A[12]));
  sg13_or3_1   L1o3_1(.X(t3), .A(A[11]), .B(A[10]), .C(A[ 9]));
  sg13_or3_1   L1o3_2(.X(t4), .A(A[ 3]), .B(A[ 2]), .C(A[ 1]));
  // 2nd layer
  sg13_or3_1   L2o3_3(.X(t5), .A(t3),    .B(A[ 8]), .C(A[ 7]));
  sg13_or3_1   L2o3_4(.X(t6), .A(t4),    .B(A[ 5]), .C(A[ 4]));
  // 3rd layer
  sg13_a21oi_2 L3ao_1(.Y(t7), .A1(t6),   .A2(A[6]), .B1(t5));
  // Last stage
  sg13_nor3_1  L4a3_3(.Y( X), .A(t1),    .B(t2),    .C(t7));
endmodule

/* previous version, slightly larger & slower
module Compare_modulus_old(
    input wire [17:0] A,
    input wire En,
    output wire X
);
  wire t1, t2, t3, t4, t5, t6, t7, _unused;
  assign _unused = A[0]; // The LSB has no effect.
  // first layer
  sg13_and4_1 L1a3_1(.X(t1), .A(A[17]), .B(A[16]), .C(A[15]), .D(En));
  sg13_and3_1 L1a3_2(.X(t2), .A(A[14]), .B(A[13]), .C(A[12]));
  sg13_or3_1  L1o3_1(.X(t3), .A(A[11]), .B(A[10]), .C(A[ 9]));
  sg13_or3_1  L1o3_2(.X(t4), .A(A[ 3]), .B(A[ 2]), .C(A[ 1]));
  // 2nd layer
  sg13_or3_1  L2o3_3(.X(t5), .A(t3),    .B(A[ 8]), .C(A[ 7]));
  sg13_or3_1  L2o3_4(.X(t6), .A(t4),    .B(A[ 5]), .C(A[ 4]));
  // 3rd layer
  sg13_a21o_2 L3ao_1(.X(t7), .A1(t6),   .A2(A[6]), .B1(t5));
  // Last stage
  sg13_and3_1 L4a3_3(.X( X), .A(t1),    .B(t2),    .C(t7));
endmodule
*/


/* adjust : std_ulogic_vector(17 downto 0) := "000000111110111110"; -- 4030 = 262144 - modulus; */
module ConstAdjOrPass(
    input  wire [17:0] A,
    input  wire C,
    output wire [17:0] X  
);
  sg13_nor2b_1  cstxr(.Y(X[17]), .B_N(A[17]), .A(C));
  sg13_nor2b_1  cstxq(.Y(X[16]), .B_N(A[16]), .A(C));
  sg13_nor2b_1  cstxp(.Y(X[15]), .B_N(A[15]), .A(C));
  sg13_nor2b_1  cstxo(.Y(X[14]), .B_N(A[14]), .A(C));
  sg13_nor2b_1  cstxn(.Y(X[13]), .B_N(A[13]), .A(C));
  sg13_nor2b_1  cstxm(.Y(X[12]), .B_N(A[12]), .A(C));
  sg13_or2_1    cstxl(.X(X[11]), .A(  A[11]), .B(C));
  sg13_or2_1    cstxk(.X(X[10]), .A(  A[10]), .B(C));
  sg13_or2_1    cstxj(.X(X[ 9]), .A(  A[ 9]), .B(C));
  sg13_or2_1    cstxi(.X(X[ 8]), .A(  A[ 8]), .B(C));
  sg13_or2_1    cstxh(.X(X[ 7]), .A(  A[ 7]), .B(C));
  sg13_nor2b_1  cstxg(.Y(X[ 6]), .B_N(A[ 6]), .A(C));
  sg13_or2_1    cstxf(.X(X[ 5]), .A(  A[ 5]), .B(C));
  sg13_or2_1    cstxe(.X(X[ 4]), .A(  A[ 4]), .B(C));
  sg13_or2_1    cstxd(.X(X[ 3]), .A(  A[ 3]), .B(C));
  sg13_or2_1    cstxc(.X(X[ 2]), .A(  A[ 2]), .B(C));
  sg13_or2_1    cstxb(.X(X[ 1]), .A(  A[ 1]), .B(C));
  sg13_nor2b_1  cstxa(.Y(X[ 0]), .B_N(A[ 0]), .A(C));
endmodule

//  modulus: std_ulogic_vector(17 downto 0) := "111 111 00 000 1 0000 10"; -- 258114; 
module ConstModOrNeg(
    input  wire [17:0] A,
    input  wire C,
    output wire [17:0] Y
);
  sg13_nand2b_1 cstxr(.Y(Y[17]), .B(A[17]), .A_N(C));
  sg13_nand2b_1 cstxq(.Y(Y[16]), .B(A[16]), .A_N(C));
  sg13_nand2b_1 cstxp(.Y(Y[15]), .B(A[15]), .A_N(C));
  sg13_nand2b_1 cstxo(.Y(Y[14]), .B(A[14]), .A_N(C));
  sg13_nand2b_1 cstxn(.Y(Y[13]), .B(A[13]), .A_N(C));
  sg13_nand2b_1 cstxm(.Y(Y[12]), .B(A[12]), .A_N(C));
  sg13_nor2_1   cstxl(.Y(Y[11]), .B(A[11]), .A(  C));
  sg13_nor2_1   cstxk(.Y(Y[10]), .B(A[10]), .A(  C));
  sg13_nor2_1   cstxj(.Y(Y[ 9]), .B(A[ 9]), .A(  C));
  sg13_nor2_1   cstxi(.Y(Y[ 8]), .B(A[ 8]), .A(  C));
  sg13_nor2_1   cstxh(.Y(Y[ 7]), .B(A[ 7]), .A(  C));
  sg13_nand2b_1 cstxg(.Y(Y[ 6]), .B(A[ 6]), .A_N(C));
  sg13_nor2_1   cstxf(.Y(Y[ 5]), .B(A[ 5]), .A(  C));
  sg13_nor2_1   cstxe(.Y(Y[ 4]), .B(A[ 4]), .A(  C));
  sg13_nor2_1   cstxd(.Y(Y[ 3]), .B(A[ 3]), .A(  C));
  sg13_nor2_1   cstxc(.Y(Y[ 2]), .B(A[ 2]), .A(  C));  
  sg13_nand2b_1 cstxb(.Y(Y[ 1]), .B(A[ 1]), .A_N(C));
  sg13_nor2_1   cstxa(.Y(Y[ 0]), .B(A[ 0]), .A(  C));
endmodule

/* a 18-bit adder, I have no mapped/optimised version available (yet)
   and I have no time left for such detail */
module Add18(
    input  wire [17:0] A,
    input  wire [17:0] B,
    input  wire        Cin,
    output wire [17:0] S,
    output wire        Cout
);
  /* verilator lint_off UNUSEDSIGNAL */
  wire _unused;
  /* verilator lint_on UNUSEDSIGNAL */
  assign { Cout, S, _unused } = { 1'b0, A, 1'b1 } + { 1'b0, B, Cin};
endmodule

module Register_InitX(
  input  wire clk,
  input  wire rst,
  input  wire en,
  input  wire [17:0] D,
  output wire [17:0] Q
);
  wire [17:0] S, R;
  //  INIT_X = "1011 0110 1110 110 111" = 187319
  assign S = { rst,1'b1,rst, rst,   1'b1,rst,rst,1'b1,  rst, rst, rst, 1'b1,  rst, rst, 1'b1,  rst, rst, rst };
  assign R = { 1'b1,rst,1'b1,1'b1,  rst,1'b1,1'b1,rst,  1'b1,1'b1,1'b1,rst,   1'b1,1'b1,rst,   1'b1,1'b1,1'b1};
  dffen_rs_x18 register(.clk(clk), .rst(R), .set(S), .en(en), .D(D), .Q(Q));
endmodule

module Register_InitY(
  input  wire clk,
  input  wire rst,
  input  wire en,
  input  wire [17:0] D,
  output wire [17:0] Q
);
  wire [17:0] S, R;
  // Init_Y = "01 101 101 0 101 101 101" = 111981
  assign S = { 1'b1,rst,   rst, 1'b1,rst,   rst, 1'b1,rst,    1'b1,  rst, 1'b1,rst,   rst, 1'b1,rst,   rst, 1'b1,rst  };
  assign R = { rst, 1'b1,  1'b1,rst, 1'b1,  1'b1,rst, 1'b1,   rst,   1'b1,rst, 1'b1,  1'b1,rst, 1'b1,  1'b1,rst, 1'b1 };
  dffen_rs_x18 register(.clk(clk), .rst(R), .set(S), .en(en), .D(D), .Q(Q));
endmodule


////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

module gPEAC18_scrambler(
  input  wire clk,
  input  wire rst,
  input  wire Phase0,
  input  wire Phase1,
  input  wire [16:0] Message_in, // C/D bit as Message_in[8]
  output wire [17:0] X // 0 < data < modulus
);
  wire [17:0] Y;
  wire [17:0] OPM;
  wire [17:0] OPX;
  wire [17:0] OPY;
  wire [17:0] ResX;
  wire [17:0] ResY;
  wire CX, CY, newCX, newCY, CinX, CinY, CoutX, CoutY, EnX, EnY, phases;

  sg13_or2_1  OrPh(.X(phases), .A(Phase0), .B(Phase1));          //  phases = Phase0 or Phase1
  
  // X path:
  mux2_x18 mxX(.sel(Phase1), .if0({1'b0, Message_in}), .if1(X), .res(OPM));
  ConstAdjOrPass AdjY(.A(Y), .C(Phase1), .X(OPY));
  sg13_and2_1  AndX(.X(CinX), .A(Phase0), .B(CX));               // CinX = CX and Phase0;  ==> could be merged in the LSB of the adder !
  Add18 AddX(.A(OPM), .B(OPY), .Cin(CinX), .S(ResX), .Cout(CoutX));
  sg13_a21o_2 nCX(.X(newCX), .A1(CX), .A2(Phase1), .B1(CoutX));  //  newCX = CoutX or (CX and Phase1);  ==> A21O
  sg13_or2_1  OrX(.X(EnX), .A(Phase0), .B(newCX));               //  EnX = Phase0 or newCX
  Register_InitX RegX(.clk(clk), .rst(rst), .en(EnX), .D(ResX), .Q(X));
  sg13_sdfrbpq_1 dffX(.Q(CX), .D(CX), .SCD(newCX), .SCE(phases), .RESET_B(rst), .CLK(clk));

  // Y path:
  ConstAdjOrPass AdjX(.A(X), .C(Phase1), .X(OPX));
  sg13_and2_1  AndY(.X(CinY), .A(Phase0), .B(CY));               // CinY = CY and Phase0;
  Add18 AddY(.A(OPX), .B(Y), .Cin(CinY), .S(ResY), .Cout(CoutY));
  sg13_a21o_2 nCY(.X(newCY), .A1(CY), .A2(Phase1), .B1(CoutY));  //  newCY = CoutY or (CY and Phase1);  ==> A21O
  sg13_or2_1  OrY(.X(EnY), .A(Phase0), .B(newCY));               //  EnY = Phase0 or newCY
  Register_InitX RegY(.clk(clk), .rst(rst), .en(EnY), .D(ResY), .Q(Y));
  sg13_sdfrbpq_1 dffY(.Q(CY), .D(CY), .SCD(newCY), .SCE(phases), .RESET_B(rst), .CLK(clk));
endmodule

////////////////////////////////////////////////////////////////////

module gPEAC18_descrambler(
  input  wire clk,
  input  wire rst,
  input  wire Phase0,
  input  wire Phase1,
  input  wire [17:0] Scrambled_in, // 0 < data < modulus
  output wire [17:0] Message_out   // C/D bit as Message_out[8], [17] is error
);
  wire phases;
  sg13_or2_1  OrPh(.X(phases), .A(Phase0), .B(Phase1));          //  phases = Phase0 or Phase1

  wire [17:0] A;
  wire [17:0] B;
  wire [17:0] T;
  wire [17:0] OPM;
  wire [17:0] OPB;
  wire [17:0] OPT;
  wire [17:0] ResA;
  wire [17:0] ResB;
  wire CA, CAn,        CinA, CoutA, EnA,
       CB,      newCB, CinB, CoutB, EnB;

  // Sticky error flag : pull rst low to clear
  wire error_sum, error_Modulus, Error;
  Compare_modulus cmp(.A(Scrambled_in), .En(Phase0), .X(error_Modulus));
  sg13_or2_1  ErrCombo(.X(error_sum), .A(error_Modulus), .B(Error));
  sg13_dfrbpq_1 dffErr(.Q(Error), .D(error_sum), .RESET_B(rst), .CLK(clk));
  sg13_or2_1  ErrOut(.X(Message_out[17]), .A(A[17]), .B(Error));
  assign Message_out[16:0] = A[16:0];

  // A path:
  mux2_x18 mxA(.sel(Phase0), .if0(Scrambled_in), .if1(A), .res(OPM));
  ConstModOrNeg cmon(.A(B), .C(Phase1), .Y(OPB));
  sg13_and2_1  AndA(.X(CinA), .A(Phase0), .B(CAn));            // CinA = (not CA) and Phase0;  ==> could be merged in the LSB of the adder !
  Add18 AddA(.A(OPM), .B(OPB), .Cin(CinA), .S(ResA), .Cout(CoutA));
  // newCA = CoutA when phase0 => handled in the SDFF
  sg13_a21o_2 en_a(.X(EnA), .A1(CA), .A2(Phase1), .B1(Phase0));  // EnA = phase0 or (phase1 and CA)   ==> A21O
  dffen_x18 RegA(.clk(clk), .rst(rst), .en(EnA), .D(ResA), .Q(A));  // No RESET, init random value gets flushed (but sim fails otherwise)
  sg13_sdfrbp_1 dffA(.Q(CA), .Q_N(CAn), .D(CA), .SCD(CoutA), .SCE(Phase0), .RESET_B(rst), .CLK(clk)); // inverted output to save an inverter

  // B path:
  Register_InitX RegT( .clk(clk), .rst(rst), .en(Phase0), .D(Scrambled_in), .Q(T));
  ConstAdjOrPass AdjY(.A(T), .C(Phase1), .X(OPT));
  sg13_and2_1  AndB(.X(CinB), .A(Phase0), .B(CB));               // CinB = CB and Phase0;  ==> could be merged in the LSB of the adder !
  Add18 AddB(.A(OPT), .B(B), .Cin(CinB), .S(ResB), .Cout(CoutB));
  sg13_a21o_2 nCB(.X(newCB), .A1(CB), .A2(Phase1), .B1(CoutB));  // newCB = (phase1 and CB ) or CoutB  ==> A21O
  sg13_or2_1  OrB(.X(EnB), .A(Phase0), .B(newCB));               //  EnB = phase0 or newCB
  Register_InitX RegB(.clk(clk), .rst(rst), .en(EnB), .D(ResB), .Q(B));
  sg13_sdfrbpq_1 dffB(.Q(CB), .D(CB), .SCD(newCB), .SCE(phases), .RESET_B(rst), .CLK(clk));
endmodule

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

module gPEAC18_scrambler_RB1(
  input  wire clk,
  input  wire rst,
  input  wire Phase0,
  input  wire Phase1,
  input  wire [16:0] Message_in, // C/D bit as Message_in[8]
  output wire [17:0] X // 0 < data < modulus
);
  wire [17:0] Y;
  wire [17:0] OPM;
  wire [17:0] OPY2;
  wire [17:0] ResX;
  wire CX, CinX, CoutX;
  
  // X path:
  assign OPM = {1'b0, Message_in};
  assign OPY2 = {Y[16:0], 1'b0};
  assign CinX = CX;
  
  Add18 AddX(.A(OPM), .B(OPY2), .Cin(CinX), .S(ResX), .Cout(CoutX));

  Register_InitX RegX(.clk(clk), .rst(rst), .en(Phase0), .D(ResX), .Q(X));   // .D(Phase0) /!\
  sg13_sdfrbpq_1 dffX(.Q(CX), .D(CX), .SCD(CoutX), .SCE(Phase0), .RESET_B(rst), .CLK(clk));

  Register_InitY RegY(.clk(clk), .rst(rst), .en(Phase1), .D(Y), .Q(Y));   // .D(Y) /!\
endmodule

////////////////////////////////////////////////////////////////////

module gPEAC18_descrambler_RB1(
  input  wire clk,
  input  wire rst,
  input  wire Phase0,
  input  wire Phase1,
  input  wire [17:0] Scrambled_in, // 0 < data < modulus
  output wire [17:0] Message_out   // C/D bit as Message_out[8], [17] is error
);
  wire [17:0] A;
  wire [17:0] B;
  wire [17:0] OPM;
  wire [17:0] OPB2;
  wire [17:0] ResA;
  wire CA, CinA, CoutA;
  /* verilator lint_off UNUSEDSIGNAL */
  wire _unused;
  /* verilator lint_on UNUSEDSIGNAL */

  // A path:
  assign OPM = Scrambled_in;
  assign OPB2 = ~ {B[16:0], 1'b0};
  assign CinA = CA;

  Add18 AddA(.A(OPM), .B(OPB2), .Cin(CinA), .S(ResA), .Cout(CoutA));

  sg13_sdfbbp_1 dffX(.Q(CA), .D(CA), .SCD(CoutA), .SCE(Phase0), .RESET_B(1'b1), .SET_B(rst), .CLK(clk), .Q_N(_unused));
  dffen_x18 RegA(.clk(clk), .rst(rst), .en(Phase0), .D(ResA), .Q(A));  // No RESET, init random value gets flushed (but sim fails otherwise)
  assign Message_out = A;

  // B path:
  Register_InitY RegB(.clk(clk), .rst(rst), .en(Phase1), .D(B), .Q(B));   // /!\ loopback
endmodule


////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

module gPEAC18_scrambler_RB2(
  input  wire clk,
  input  wire rst,
  input  wire en,
  input  wire [16:0] Message_in, // C/D bit as Message_in[8]
  output wire [17:0] X // 0 < data < modulus
);
  wire [17:0] Y;
  wire [17:0] OPM;
  wire [17:0] OPY2;
  wire [17:0] ResX, ResX2, XM;
  wire CX, CinX, CoutX, CoutX2, newCX;

  // "X" path:
  assign OPM = {1'b0, Message_in};
  assign OPY2 = {Y[16:0], 1'b0};   // Y×2 during early tests
  assign CinX = CX;

  Add18 AddX(.A(OPM), .B(OPY2), .Cin(CinX), .S(ResX), .Cout(CoutX));
  Add18 AddAdj(.A(ResX), .B(18'd4030), .Cin(1'b0), .S(ResX2), .Cout(CoutX2));  // ADJUST
  sg13_or2_2  CombCoutX(.A(CoutX), .B(CoutX2), .X(newCX));
  sg13_sdfrbpq_1 dffX(.Q(CX), .D(CX), .SCD(newCX), .SCE(en), .RESET_B(rst), .CLK(clk));
  mux2_x18 selRes( .sel(newCX), .if0(ResX), .if1(ResX2), .res(XM));
  Register_InitX RegX(.clk(clk), .rst(rst), .en(en), .D(XM), .Q(X));

  // "Y" path:
  Register_InitY RegY(.clk(clk), .rst(rst), .en(en), .D(Y), .Q(Y));   // .D(Y) /!\
endmodule

////////////////////////////////////////////////////////////////////

module gPEAC18_descrambler_RB2(
  input  wire clk,
  input  wire rst,
  input  wire en,
  input  wire [17:0] Scrambled_in, // 0 < data < modulus
  output wire [17:0] Message_out   // C/D bit as Message_out[8], [17] is error
);
  wire [17:0] A;
  wire [17:0] B;
  wire [17:0] OPM;
  wire [17:0] OPB2;
  wire [17:0] ResA, ResA2, AM;
  wire CA, CinA, CoutA,
        error_Modulus, error;
  Compare_modulus cmp(.A(Scrambled_in), .X(error_Modulus));

  /* verilator lint_off UNUSEDSIGNAL */
  wire _unused, _unused2;
  /* verilator lint_on UNUSEDSIGNAL */

  // "A" path:
  assign OPM = Scrambled_in;
  assign OPB2 = ~ {B[16:0], 1'b0};  // Y×2 during early tests
  assign CinA = CA;

  Add18 AddA(.A(OPM), .B(OPB2), .Cin(CinA), .S(ResA), .Cout(CoutA));
  Add18 AddAM(.A(18'd258114), .B(ResA), .Cin(1'b0), .S(ResA2), .Cout(_unused2));
  mux2_x18 selRes( .sel(CoutA), .if0(ResA2), .if1(ResA), .res(AM));
  sg13_or2_1 CombErr(.A(error_Modulus), .B(AM[17]), .X(error));         // combine the 2 errors
  dffen_x18 RegA(.clk(clk), .rst(rst), .en(en), .D({error, AM[16:0]}), .Q(A));  // No RESET, the initial random value gets flushed (but sim fails otherwise)
  sg13_sdfbbp_1 dffCA(.Q(CA), .D(CA), .SCD(CoutA), .SCE(en), .RESET_B(1'b1), .SET_B(rst), .CLK(clk), .Q_N(_unused));
  assign Message_out = A;  // available during the next cycle

  // "B" path:
  Register_InitY RegB(.clk(clk), .rst(rst), .en(en), .D(B), .Q(B));   // /!\ loopback
endmodule

////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////

module gPEAC18_scrambler_RB3(
  input  wire clk,
  input  wire rst,
  input  wire en,
  input  wire [16:0] Message_in, // C/D bit as Message_in[8]
  output wire [17:0] X // 0 < data < modulus
);
  wire [17:0] Y, OpM, OpX, OpY, OpY2;
  wire [17:0] ResX, ResX2, XM;
  wire [17:0] ResY, ResY2, YM;
  wire CX, CinX, CoutX, CoutX2, newCX;
  wire CY, CinY, CoutY, CoutY2, newCY;

  // "X" path:
  assign OpM  = {1'b0, Message_in};
  assign OpY2 = Y;
  assign CinX = CX;
  Add18 AddX(.A(OpM), .B(OpY2), .Cin(CinX), .S(ResX), .Cout(CoutX));
  Add18 AddXAdj(.A(ResX), .B(18'd4030), .Cin(1'b0), .S(ResX2), .Cout(CoutX2));  // ADJUST
  sg13_or2_2  CombCoutX(.A(CoutX), .B(CoutX2), .X(newCX));
  sg13_sdfrbpq_1 dffCX(.Q(CX), .D(CX), .SCD(newCX), .SCE(en), .RESET_B(rst), .CLK(clk));
  mux2_x18 selResX( .sel(newCX), .if0(ResX), .if1(ResX2), .res(XM));
  Register_InitX RegX(.clk(clk), .rst(rst), .en(en), .D(XM), .Q(X));

  // "Y" path:
  assign OpX  = X;
  assign OpY  = Y;
  assign CinY = CY;
  Add18 AddY(.A(OpX), .B(OpY), .Cin(CinY), .S(ResY), .Cout(CoutY));
  Add18 AddYAdj(.A(ResY), .B(18'd4030), .Cin(1'b0), .S(ResY2), .Cout(CoutY2));  // ADJUST
  sg13_or2_2  CombCoutY(.A(CoutY), .B(CoutY2), .X(newCY));
  sg13_sdfrbpq_1 dffCY(.Q(CY), .D(CY), .SCD(newCY), .SCE(en), .RESET_B(rst), .CLK(clk));
  mux2_x18 selResY( .sel(newCY), .if0(ResY), .if1(ResY2), .res(YM));
  Register_InitY RegY(.clk(clk), .rst(rst), .en(en), .D(YM), .Q(Y));
endmodule

////////////////////////////////////////////////////////////////////

module gPEAC18_descrambler_RB3(
  input  wire clk,
  input  wire rst,
  input  wire en,
  input  wire [17:0] Scrambled_in, // 0 < data < modulus
  output wire [17:0] Message_out   // C/D bit as Message_out[8], [17] is error
);
  wire [17:0] A, B, T;
  wire [17:0] OpM, OpB2;
  wire [17:0] ResA, ResA2, AM;
  wire [17:0] ResB, ResB2, BM;
  wire CA, CinA, CoutA;
  wire CB, CinB, CoutB, CoutB2, newCB;
  /* verilator lint_off UNUSEDSIGNAL */
  wire _unused, _unused2;
  /* verilator lint_on UNUSEDSIGNAL */
  
  // "A" path:
  assign OpM = Scrambled_in;
  assign OpB2 = ~B;
  assign CinA = CA;

  Add18 AddA(.A(OpM), .B(OpB2), .Cin(CinA), .S(ResA), .Cout(CoutA));
  Add18 AddAM(.A(18'd258114), .B(ResA), .Cin(1'b0), .S(ResA2), .Cout(_unused2));
  mux2_x18 selRes( .sel(CoutA), .if0(ResA2), .if1(ResA), .res(AM));

  wire error_Modulus, error;
  Compare_modulus cmp(.A(Scrambled_in), .X(error_Modulus));
  sg13_or2_1 CombErr(.A(error_Modulus), .B(AM[17]), .X(error));         // combine the 2 errors

  dffen_x18 RegA(.clk(clk), .rst(rst), .en(en), .D({error, AM[16:0]}), .Q(A));  // No RESET, the initial random value gets flushed (but sim fails otherwise)
  sg13_sdfbbp_1 dffCA(.Q(CA), .D(CA), .SCD(CoutA), .SCE(en), .RESET_B(1'b1), .SET_B(rst), .CLK(clk), .Q_N(_unused));
  assign Message_out = A;  // available during the next cycle

  // "B" path:
  Register_InitX RegT(.clk(clk), .rst(rst), .en(en), .D(Scrambled_in), .Q(T));
  assign OpB  = B;
  assign OpT  = T;
  assign CinB = CB;
  
  Add18 AddB(.A(OpB), .B(OpT), .Cin(CinB), .S(ResB), .Cout(CoutB));
  Add18 AddBAdj(.A(ResB), .B(18'd4030), .Cin(1'b0), .S(ResB2), .Cout(CoutB2));  // ADJUST
  sg13_or2_2  CombCoutB(.A(CoutB), .B(CoutB2), .X(newCB));
  sg13_sdfrbpq_1 dffCB(.Q(CB), .D(CB), .SCD(newCB), .SCE(en), .RESET_B(rst), .CLK(clk));
  mux2_x18 selResB( .sel(newCB), .if0(ResB), .if1(ResB2), .res(BM));
  Register_InitY RegB(.clk(clk), .rst(rst), .en(en), .D(BM), .Q(B));
endmodule
