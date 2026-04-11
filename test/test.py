# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

# Test the Hammer18 & gPEAC scrambler & descrambler in direct, encoding and decoding modes.

enable_bypass = False
enable_loopback = False
enable_Hammer_encode = False
enable_Hammer_decode = False
enable_compare  = False # just a debug that worked for a while, no use for final circuit because it gets wired differenly
RB1_Encode = False
RB1_Decode = False
RB2_Encode = False
RB2_Decode = False
RB3_Encode = False
RB3_Decode = False
Hammer_gPEAC_Scrambling = True
Hammer_gPEAC_Descrambling = True

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
  if (val & 131072) != 0 and (mode & Encode) !=0:
    print(str(val)+" >= 131072, encoding lost")
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

RB3_vectors = [
[   1234,  113215],
[  38650,   79836],
[  76066,  230468],
[ 113482,   89606],
[  19826,  226419],
[  57242,   95327],
[  94658,  101049],
[   1002,  102721],
[  38418,  241186],
[  75834,  123209],
[ 113250,  143698],
[  19594,  173252],
[  57010,   96252],
[  94426,   48807],
[    770,   51404],
[  38186,  137627],
[  75602,  226447],
[ 113018,  143376],
[  19362,   18054],
[  56778,  198847],
[  94194,  254317],
[    538,  101394],
[  37954,  135014],
[  75370,   15711],
[ 112786,  188142],
[  19130,  110197],
[  56546,   77641],
[  93962,  225255],
[    306,  209240],
[  37722,  213797],
[  75138,  202340],
[ 112554,  195440],
[  18898,   46011],
[  56314,   20754],
[  93730,  104182],
[     74,   31280],
[  37490,  172878],
[  74906,  241574],
[ 112322,  193754],
[  18666,   83559],
[  56082,   56616],
[  93498,  177592],
[ 130914,   13510],
[  37258,   97447],
[  74674,  148373],
[ 112090,   25122],
[  18434,   79840],
[  55850,  142378],
[  93266,    1520],
[ 130682,  181315],
[  37026,   89179],
[  74442,   49796],
[ 111858,  176392],
[  18202,  132532],
[  55618,   88226],
[  93034,      61],
[ 130450,  125704],
[  36794,   32109],
[  74210,  195229],
[ 111626,    6640],
[  17970,  108214],
[  55386,  152270],
[  92802,   39786],
[ 130218,  229473],
[  36562,  175603],
[  73978,  184378],
[ 111394,  139284],
[  17738,  230007],
[  55154,  148593],
[  92570,  157903],
[ 129986,   85799],
[  36330,  150047],
[  73746,   15148],
[ 111162,  202612],
[  17506,  124104],
[  54922,  106018],
[  92338,    9425],
[ 129754,  152860],
[  36098,   68629],
[  73514,     791],
[ 110930,  106837],
[  17274,   13972],
[  54690,  158225],
[  92106,  209613],
[ 129522,  147140],
[  35866,    4984],
[  73282,  189541],
[ 110698,  231941],
[  17042,   69712],
[  54458,   80956],
[  91874,  188085],
[ 129290,   48343],
[  35634,  142773],
[  73050,  228532],
[ 110466,  150607],
[  16810,   27370],
[  54226,  215394],
[  91642,   22066],
[ 129058,   16763],
[  35402,  203288]
]

FullVectors=[
[113215, 225196],
[79836, 79672],
[230468, 261483],
[89606, 115502],
[226419, 97405],
[95327, 36297],
[101049, 19124],
[102721, 207453],
[241186, 188402],
[123209, 57904],
[143698, 116378],
[173252, 71957],
[96252, 167431],
[48807, 209556],
[51404, 184764],
[137627, 62930],
[226447, 96351],
[143376, 121429],
[18054, 81986],
[198847, 13429],
[254317, 193468],
[101394, 136089],
[135014, 112635],
[15711, 51274],
[188142, 152080],
[110197, 39515],
[77641, 61372],
[225255, 148283],
[209240, 8326],
[213797, 177943],
[202340, 124611],
[195440, 113318],
[46011, 88696],
[20754, 237117],
[104182, 60956],
[31280, 242610],
[172878, 128332],
[241574, 69359],
[193754, 189013],
[83559, 210744],
[56616, 37751],
[177592, 254814],
[13510, 136569],
[97447, 12351],
[148373, 113115],
[25122, 62210],
[79840, 91184],
[142378, 59348],
[1520, 62901],
[181315, 67972],
[89179, 128818],
[49796, 129100],
[176392, 78565],
[132532, 8063],
[88226, 81906],
[61, 148813],
[125704, 257050],
[32109, 117164],
[195229, 23579],
[6640, 167145],
[108214, 1826],
[152270, 79893],
[39786, 249775],
[229473, 96551],
[175603, 84440],
[184378, 253115],
[139284, 175762],
[230007, 242766],
[148593, 182501],
[157903, 197268],
[85799, 176033],
[150047, 221810],
[15148, 39760],
[202612, 5745],
[124104, 75757],
[106018, 167840],
[9425, 157601],
[152860, 130516],
[68629, 135888],
[791, 15539],
[106837, 161882],
[13972, 41640],
[158225, 58565],
[209613, 54140],
[147140, 24921],
[4984, 185536],
[189541, 199111],
[231941, 43369],
[69712, 68019],
[80956, 120051],
[188085, 26791],
[48343, 204918],
[142773, 115936],
[228532, 178671],
[150607, 155099],
[27370, 81434],
[215394, 24636],
[22066, 207748],
[16763, 128018],
[203288, 176617]
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
    for x in RB3_vectors:
      i = x[1]
      #print("testing      " + x[0]);
      await input_parameter(i, 0, dut)  # Encode = Decode = 0 => direct mode
      o = await output_parameter(dut)
      #print(" -found " + bin(o + (1 << 20)))
      assert i == o
    await ClockCycles(dut.clk, 6)

  # Test in mode=Loopback
  if enable_loopback == True:
    await reset_state(dut)
    dut._log.info("Starting Loopback Mode")
    for x in RB3_vectors:
      v = x[1] % 131072
      await input_parameter(v, Encode+Decode, dut)
      t = await output_parameter(dut)
      #print(str(v) + " -> " + str(t))
      assert t == v

  #########################"

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
      print(str(x[1]-o) + " - in: " + str(v) + "   found: " + str(o) + "   expected: " + str(x[1]))
      assert o == x[1]
    await ClockCycles(dut.clk, 6)

  if RB2_Decode == True:
    await reset_state(dut)
    dut._log.info("RB2 Descrambling Mode")
    for x in RB2_vectors:
      v = x[1]
      await input_parameter(v, Decode, dut)  # Decode mode
      o = await output_parameter(dut)
      print(str(x[0]-o) + " - in: " + str(v) + "   found: " + str(o) + "   expected: " + str(x[0]))
      assert o == x[0]
    await ClockCycles(dut.clk, 6)

  ###

  if RB3_Encode == True:
    await reset_state(dut)
    dut._log.info("RB3 Scrambling Mode")
    for x in RB3_vectors:
      v = x[0]
      await input_parameter(v, Encode, dut)  # Encode mode
      o = await output_parameter(dut)
      print(str(x[1]-o) + " - in: " + str(v) + "   found: " + str(o) + "   expected: " + str(x[1]))
      assert o == x[1]
    await ClockCycles(dut.clk, 6)

  if RB3_Decode == True:
    await reset_state(dut)
    dut._log.info("RB3 Descrambling Mode")
    for x in RB3_vectors:
      v = x[1]
      await input_parameter(v, Decode, dut)  # Decode mode
      o = await output_parameter(dut)
      print(str(x[0]-o) + " - in: " + str(v) + "   found: " + str(o) + "   expected: " + str(x[0]))
      assert o == x[0]
    await ClockCycles(dut.clk, 6)

  ######################################################################
  # The following code is used to test the whole Hammer+gPEAC circuit

  if Hammer_gPEAC_Scrambling == True:
    await reset_state(dut)
    dut._log.info("Scrambling Mode")
    for x in RB3_vectors: #FullVectors:
      v = x[1] & 131071
      await input_parameter(v, Encode, dut)  # Encode mode
      o = await output_parameter(dut)
      print("[" + str(v) + ", "+str(o)+"],")
      #assert x[1] == o
    await ClockCycles(dut.clk, 6)

  if Hammer_gPEAC_Descrambling == True:
    await reset_state(dut)
    dut._log.info("Descrambling Mode")
    for x in FullVectors:
      v = x[1]
      await input_parameter(v, Decode, dut)  # Decode mode
      o = await output_parameter(dut)
      print(str(x[0]-o) + " [" + str(v) + ", "+str(o)+"],")
      #assert x[0] == o
    await ClockCycles(dut.clk, 6)


  ######################################################################
  # very old code:
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
