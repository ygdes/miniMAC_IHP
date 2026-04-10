/*  project.v
 * Copyright (c) 2026 Yann Guidon / whygee@f-cpu.org
 * SPDX-License-Identifier: Apache-2.0
 *
 *   Instantiate the Hammer18 Hamming Distance Maximiser and the gPEAC18 scrambler/checksum
 *   version sam. 28 mars 2026 01:23:55 CET : conversion to iHP SG2CMOS5L
 *   version lun. 06 avril 2026 00:22:25 CEST : conversion to generic IHP names
 */

`default_nettype none

module tt_um_miniMAC (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // IO config & misc.
  assign uio_oe  = 8'b00001111; // port uio : 4 LSB go out

  // aliasing
  wire QEN, CLK_out, Zero, Encode, Decode, DEN;
  wire [8:0] Din9, Dout9;
  assign uo_out     = Dout9[7:0];
  assign Din9[7:0]  = ui_in;

  assign uio_out[0] = Dout9[8];
  assign uio_out[1] = QEN;
  assign uio_out[2] = CLK_out;
  assign uio_out[3] = Zero;
  assign DEN        = uio_in[4];
  assign Encode     = uio_in[5];
  assign Decode     = uio_in[6];
  assign Din9[8]    = uio_in[7];

  // All output pins must be assigned. If not used, assign to 0.
  assign uio_out[7:4] = 4'b0000;

  // List all unused inputs to prevent warnings
  wire _unused = &{uio_in[0], uio_in[1], uio_in[2], uio_in[3], 1'b0};

/////////////////////////////////////////////////////////////////////////////

  // ring oscillator anyone ?
  sg13_inv_1 negClkOut(.Y(CLK_out), .A(clk));

  // resynch the reset signal
  wire INT_RESET;
  sg13_dfrbpq_1 DFF_reset(.Q(INT_RESET), .D(ena), .RESET_B(rst_n), .CLK(clk));

  // Pipeline management
  wire Din_OK, Dout_OK;
  wire [17:0] FirstWord;
  wire [17:0] LastWord;

  input_demux dmx(
    .clk(clk), .rst(INT_RESET), .DEN(DEN), .Din9(Din9),
    .Din_OK(Din_OK), .FirstWord(FirstWord));

  pipe_full pipe(
    .clk(clk), .rst(INT_RESET),
    .Encode(Encode), .Decode(Decode),
    .Din_OK(Din_OK), .FirstWord(FirstWord),
    .Dout_OK(Dout_OK), .LastWord(LastWord));

  output_muxer mxr(
    .clk(clk), .rst(INT_RESET), .Dout_OK(Dout_OK), .LastWord(LastWord),
    .Zero(Zero), .QEN(QEN), .Dout9(Dout9));
endmodule
