# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

# Test the Hammer18 & gPEAC scrambler & descrambler in direct, encoding and decoding modes.

enable_bypass = True
enable_loopback = False
enable_Hammer_encode = False
enable_Hammer_decode = False
enable_compare  = False # just a debug that worked for a while, no use for final circuit because it gets wired differenly
RB1_Encode = False
RB1_Decode = False
RB2_Encode = True
RB2_Decode = False
Scrambling_gPEAC_direct = False
Scrambling_loopback = False

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

# outputs:
Dout_8     =   1
QEN        =   2
CLK_out    =   4
Zero       =   8
#inputs:
DEN        =  16
Encode     =  32
Decode     =  64
Din_8      = 128

async def reset_state(dut):
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, 3)
  dut.rst_n.value = 1
  await ClockCycles(dut.clk, 3)

async def input_parameter(val, mode, dut):
  dut.ui_in.value = val & 255
  # MSB and DEN set
  dut.uio_in.value = mode | DEN | (Din_8 & (val >> 1))
  await ClockCycles(dut.clk, 1)
  dut.ui_in.value = (val >> 9) & 255
  # clear DEN, set MSB
  dut.uio_in.value = mode | (Din_8 & (val >> 10))
  await ClockCycles(dut.clk, 1)

async def output_parameter(dut):
  timeout = 0
  while (int(dut.uio_out.value[1])) != 1:
    timeout = timeout + 1
    if timeout > 10:
      print("timeout !")
      assert false
      return -1
    await ClockCycles(dut.clk, 1)
  #print("waited " + str(timeout))  
  # LSB first:
  #print("phase0: " + str(dut.uio_out.value[0]) + " : " + str(dut.uo_out.value))
  val = int(dut.uo_out.value) + (int(dut.uio_out.value[0]) << 8)
  #print("uo=" + bin(int(dut.uo_out.value)) + "   uio=" + bin(int(dut.uio_out.value))  + "   QEN=" + str(dut.uio_out.value[1]))
  await ClockCycles(dut.clk, 1)
  # print("phase1: " + str(dut.uio_out.value) + " : " + str(dut.uo_out.value))
  assert dut.uio_out.value[1] == 0
  #print("uo=" + bin(int(dut.uo_out.value)) + "   uio=" + bin(int(dut.uio_out.value))  + "   QEN=" + str(dut.uio_out.value[1]))
  return val + (( int(dut.uo_out.value) + (int(dut.uio_out.value[0])<<8)) << 9)


# Test vectors for a direct Hammer18 lookup.
vectors = [
["111111111111111111", "101011111000110100"],
["000000000000000000", "000000000000000000"],
["000000000000000001", "110111011111011001"],
["000000000000000010", "110111011111011111"],
["000000000000000100", "110111101111011111"],
["000000000000001000", "110111101110011111"],
["000000000000010000", "010111100110110101"],
["000000000000100000", "110001101011001010"],
["000000000001000000", "000000011111111000"],
["000000000010000000", "101110111001000000"],
["000000000100000000", "111111000010100000"],
["000000001000000000", "111111011111111001"],
["000000010000000000", "111110111111111001"],
["000000100000000000", "111110111111110101"],
["000001000000000000", "001101111111010101"],
["000010000000000000", "000111100010110101"],
["000100000000000000", "110111000000100110"],
["001000000000000000", "111111000000101100"],
["010000000000000000", "100001001101110000"],
["100000000000000000", "000000011111111010"],
["111111111000000000", "011100010000010101"],
["000000000111111111", "110111101000100001"],
["101010101010101010", "100110111110100101"],
["010101010101010101", "001101000110010001"],
["110111011111011001", "011011011100100111"],
["110001101011001010", "000011011010101011"],
["000000011111111010", "110110111000100111"],
["011011011100100111", "101100110110001111"],
["001101111111010101", "111100010010000001"],
["011011010110110101", "011101101001011100"],
["100100101001001010", "110110010001101000"],
["110110010001101000", "101001010101001101"],
["111100010010000001", "001110001011100000"],
["110110111000100111", "101000101011111111"],
["100110111110100101", "101111000010110000"],
["000011011010101011", "100011000001110011"],
["101000101011111111", "110110010101011011"],
["100011000001110011", "101100010000011011"],
["001110001011100000", "101111110000110100"]]

Hammer18_sequence = [ # for the Hammer18 tests
 10,      # index=10  ( out=in because the delay register is cleared)
 3147,
 228245,
 77,
 227223,
 227216,
 86,
 96676,
 134782,
 134777 ]  # index=19

# "Golden" values output by VHDL when encoding 0

# ./gpeac18_scrambler_vectors --vcd=vectors.vcd -gPASSTHROUGH=1 -gvectors=30 |sed 's/.*: //'
gPEAC_vectors=[
"011011010101101101", 
"001010000011100010", 
"100101011001010000", 
"101111011100110010", 
"010101110101000000", 
"000110010000110001", 
"011100000101110010", 
"100010010110100011", 
"111110011100010101", 
"100001110001110110", 
"100001001101001010", 
"000011111101111111", 
"100101001011001010", 
"101001001001001001", 
"001111010011010001", 
"111000011100011011", 
"001000101110101010", 
"000010001010000100", 
"001010111000101111", 
"001101000010110011", 
"010111111011100010", 
"100100111110010101", 
"111100111001110111", 
"100010110111001010", 
"100000110000000000", 
"000100100110001001", 
"100101010110001010", 
"101001111100010011", 
"010000010001011011", 
"111010001101101111"
];

Scrambler_vectors=[
"011011010101101101",
"011001000100101100",
"110101101001100100",
"000011100101110110",
"111000000111010000",
"100010111111100110",
"000011001010111110",
"100101010100100001",
"100111001110001111",
"100110110101010000",
"001010001111101110",
"001110101110110001",
"001001011000111110",
"000010100001000001",
"000010000010010101",
"001010100001011100",
"001000010110000000",
"011100001011001110",
"101011010011111100",
"111011010101010011",
"011010110000000100",
"101111100011111011",
"110010010100001101",
"100101000111100001",
"110110011000011011",
"000100111001111111",
"111101100011111111",
"111100101001000011",
"110101001010111110",
"000101101000110010",
"100011000110110110",
"010100000010000101",
"101011001110011111",
"100111001111110000",
"111100101010100101",
"101101101101110001",
"001110101100111101",
"011111011011001010",
"001101110111010111",
"010001011110100010",
"011110100110010100",
"001011001000110001",
"111110010101000111",
"001010111011010100",
"111101101010010111",
"001110110111010111",
"001100011011111010",
"011000011000011001",
"110111110001111001",
"100010110000101111"]

RB1_vectors=[
[     42,  224004],
[  24455,  248417],
[  48868,   10686],
[  73281,   35100],
[  97694,   59513],
[ 122107,   83926],
[  15448,  239411],
[  39861,    1679],
[  64274,   26093],
[  88687,   50506],
[ 113100,   74919],
[   6441,  230404],
[  30854,  254816],
[  55267,   17085],
[  79680,   41499],
[ 104093,   65912],
[ 128506,   90325],
[  21847,  245810],
[  46260,    8078],
[  70673,   32492],
[  95086,   56905],
[ 119499,   81318],
[  12840,  236803],
[  37253,  261215],
[  61666,   23484],
[  86079,   47898],
[ 110492,   72311],
[   3833,  227796],
[  28246,  252208],
[  52659,   14477]
]

RB2_vectors=[
[   1234,  225196],
[  38650,    4498],
[  76066,   41915],
[ 113482,   79331],
[  19826,  243789],
[  57242,   23090],
[  94658,   60507],
[   1002,  224965],
[  38418,    4266],
[  75834,   41683],
[ 113250,   79099],
[  19594,  243557],
[  57010,   22858],
[  94426,   60275],
[    770,  224733],
[  38186,    4034],
[  75602,   41451],
[ 113018,   78867],
[  19362,  243325],
[  56778,   22626],
[  94194,   60043],
[    538,  224501],
[  37954,    3802],
[  75370,   41219],
[ 112786,   78635],
[  19130,  243093],
[  56546,   22394],
[  93962,   59811],
[    306,  224269],
[  37722,    3570],
[  75138,   40987],
[ 112554,   78403],
[  18898,  242861],
[  56314,   22162],
[  93730,   59579],
[     74,  224037],
[  37490,    3338],
[  74906,   40755],
[ 112322,   78171],
[  18666,  242629],
[  56082,   21930],
[  93498,   59347],
[ 130914,   96763],
[  37258,    3107],
[  74674,   40523],
[ 112090,   77939],
[  18434,  242397],
[  55850,   21698],
[  93266,   59115],
[ 130682,   96531],
[  37026,    2875],
[  74442,   40291],
[ 111858,   77707],
[  18202,  242165],
[  55618,   21466],
[  93034,   58883],
[ 130450,   96299],
[  36794,    2643],
[  74210,   40059],
[ 111626,   77475],
[  17970,  241933],
[  55386,   21234],
[  92802,   58651],
[ 130218,   96067],
[  36562,    2411],
[  73978,   39827],
[ 111394,   77243],
[  17738,  241701],
[  55154,   21002],
[  92570,   58419],
[ 129986,   95835],
[  36330,    2179],
[  73746,   39595],
[ 111162,   77011],
[  17506,  241469],
[  54922,   20770],
[  92338,   58187],
[ 129754,   95603],
[  36098,    1947],
[  73514,   39363],
[ 110930,   76779],
[  17274,  241237],
[  54690,   20538],
[  92106,   57955],
[ 129522,   95371],
[  35866,    1715],
[  73282,   39131],
[ 110698,   76547],
[  17042,  241005],
[  54458,   20306],
[  91874,   57723],
[ 129290,   95139],
[  35634,    1483],
[  73050,   38899],
[ 110466,   76315],
[  16810,  240773],
[  54226,   20074],
[  91642,   57491],
[ 129058,   94907],
[  35402,    1251]
]



@cocotb.test()
async def test_project(dut):
  dut._log.info("Start")

  # Set the clock period to 10 us (100 KHz)
  clock = Clock(dut.clk, 10, unit="us")
  cocotb.start_soon(clock.start())

  # Reset
  dut._log.info("Reset")
  dut.ena.value = 1
  dut.ui_in.value = 0
  dut.uio_in.value = 0
  
  # Test bypass mode (mode=0)
  if enable_bypass == True:
    await reset_state(dut)  
    dut._log.info("Starting bypass Mode")
    for x in vectors:
      i = int(x[0],2)
      #print("testing      " + x[0]);
      await input_parameter(i, 0, dut)  # Encode = Decode = 0 => direct mode
      o = await output_parameter(dut)
      #print(" -found " + bin(o + (1 << 20)))
      assert i == o
    await ClockCycles(dut.clk, 6)

  # Test Hammer in mode=Loopback
  if enable_loopback == True:
    await reset_state(dut)  
    dut._log.info("Starting Loopback Mode")
    for x in Scrambler_vectors:
      v = (int(x,2)) % 131072
      await input_parameter(v, Encode+Decode, dut)
      t = await output_parameter(dut)
      print(str(v) + " -> " + str(t))
      assert t == v

  #  Test Hammer in encode mode
  if enable_Hammer_encode == True:
    await reset_state(dut)  
    dut._log.info("Starting Hammer Encode Mode")
    i = 10
    for x in Hammer18_sequence:
      await input_parameter(i, Encode, dut)
      t = await output_parameter(dut)
      print(str(i) + " : " + str(t) + "   expected "+ str(x))
      assert t == x
      i = i+1

  # Test Hammer in mode=Decode
  if enable_Hammer_decode == True:
    await reset_state(dut)  
    dut._log.info("Starting Hammer Decode Mode")
    i = 10
    for x in Hammer18_sequence:
      await input_parameter(x, Decode, dut)
      t = await output_parameter(dut)
      print(str(i) + " : " + str(t))
      assert t == i
      i = i+1

  # mode=loopback but testing the comparator   /!\  Modulus Comparator is not exposed anymore   /!\
  if enable_compare == True:
    await ClockCycles(dut.clk, 6)
    dut._log.info("Starting Comparator Mode")
    await reset_state(dut)
    for i in range(256000, 262144, 2):
      await input_parameter(i, Decode+Encode, dut)
      print(str(i) + " : " + str(dut.uio_out.value[3]))
      # the Zero flag should be 1 when i >= 258144
      # but there is a delay so it's checked in the VCD
      # ænyway it's only a temporary test that will not work later
    await ClockCycles(dut.clk, 6)

  ######################################################################
  # Testing intermediary versions of gPEAC

  if RB1_Encode == True:
    await reset_state(dut)  
    dut._log.info("RB1 Scrambling Mode")
    for x in RB1_vectors:
      v = x[0]
      await input_parameter(v, Encode, dut)  # Encode mode
      o = await output_parameter(dut)
      print(" - in: " + str(v) + "   found: " + str(o) + "   expected: " + str(x[1]))
      assert o == x[1]
    await ClockCycles(dut.clk, 6)

  if RB1_Decode == True:
    await reset_state(dut)  
    dut._log.info("RB1 Descrambling Mode")
    for x in RB1_vectors:
      v = x[1]
      await input_parameter(v, Decode, dut)  # Decode mode
      o = await output_parameter(dut)
      print(" - in: " + str(v) + "   found: " + str(o) + "   expected: " + str(x[0]))
      assert o == x[0]
    await ClockCycles(dut.clk, 6)

  ###

  if RB2_Encode == True:
    await reset_state(dut)
    dut._log.info("RB2 Scrambling Mode")
    for x in RB2_vectors:
      v = x[0]
      await input_parameter(v, Encode, dut)  # Encode mode
      o = await output_parameter(dut)
      print(" - in: " + str(v) + "   found: " + str(o) + "   expected: " + str(x[1]))
      assert o == x[1]
    await ClockCycles(dut.clk, 6)

  if RB2_Decode == True:
    await reset_state(dut)
    dut._log.info("RB2 Descrambling Mode")
    for x in RB2_vectors:
      v = x[1]
      await input_parameter(v, Decode, dut)  # Decode mode
      o = await output_parameter(dut)
      print(" - in: " + str(v) + "   found: " + str(o) + "   expected: " + str(x[0]))
      #assert o == x[0]
    await ClockCycles(dut.clk, 6)

  ######################################################################
  # The following code is used to test the whole Hammer+gPEAC circuit

  if Scrambling_gPEAC_direct == True:
    await reset_state(dut)  
    dut._log.info("Scrambling Mode")
    for x in gPEAC_vectors:
      v = int(x,2)
      print("expected " + bin(v + (1 << 20)))
      await input_parameter(0, Encode, dut)  # Encode mode
      o = await output_parameter(dut)
      print(" - found " + bin(o + (1 << 20)))
      #assert v == o
    await ClockCycles(dut.clk, 6)

  if Scrambling_loopback == True:
    await reset_state(dut)  
    dut._log.info("Scrambling/descrambling Mode")
    for x in range(0, 20):
      #v = int(x,2)
      #print("testing " + x[0] + " => " + x[1]);
      await input_parameter(0, 0, dut)  # loopback mode
      o = await output_parameter(dut)
      print("found " + bin(o + (1 << 20)))
      #assert v == o
    await ClockCycles(dut.clk, 6)

  
  await ClockCycles(dut.clk, 6)
  dut._log.info("Done.")
