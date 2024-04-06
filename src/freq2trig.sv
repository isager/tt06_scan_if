/* Copyright 2024 Mogens Isager
 * SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
 * 
 * Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may
 * not use this file except in compliance with the License, or, at your option,
 * the Apache License version 2.0. You may obtain a copy of the License at
 * 
 * https://solderpad.org/licenses/SHL-2.1/
 * 
 * Unless required by applicable law or agreed to in writing, any work
 * distributed under the License is distributed on an “AS IS” BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */

module freq2trig #(
  parameter WL = 16) (
  input [7:0] freq, // desired sine frequency divided buy 100, eg. 6000 Hz -> 60
  output reg signed [WL-1:0] cosW,  // cos(2*Pi*freq/48000) as s0.{WL-1} fixed point value
  output reg signed [WL-1:0] sinW); // sin(2*Pi*freq/48000) as s0.{WL-1} fixed point value
  
  wire signed [WL-1:0] trig [0:120];

  // # python code for generating cosine table from desired sine generator frequency
  // import math
  // WL = 16
  // table = []
  // for i in range(121):
  //     c = int(2**(WL-1)*math.cos(2*math.pi*i/480))
  //     table.append(c)
  //     print(f'  assign trig[{i}] = {c};')

  assign trig[0] = 32767;
  assign trig[1] = 32765;
  assign trig[2] = 32756;
  assign trig[3] = 32742;
  assign trig[4] = 32723;
  assign trig[5] = 32697;
  assign trig[6] = 32666;
  assign trig[7] = 32630;
  assign trig[8] = 32588;
  assign trig[9] = 32540;
  assign trig[10] = 32487;
  assign trig[11] = 32428;
  assign trig[12] = 32364;
  assign trig[13] = 32294;
  assign trig[14] = 32219;
  assign trig[15] = 32138;
  assign trig[16] = 32051;
  assign trig[17] = 31960;
  assign trig[18] = 31862;
  assign trig[19] = 31759;
  assign trig[20] = 31651;
  assign trig[21] = 31537;
  assign trig[22] = 31418;
  assign trig[23] = 31294;
  assign trig[24] = 31164;
  assign trig[25] = 31029;
  assign trig[26] = 30888;
  assign trig[27] = 30742;
  assign trig[28] = 30591;
  assign trig[29] = 30435;
  assign trig[30] = 30273;
  assign trig[31] = 30106;
  assign trig[32] = 29935;
  assign trig[33] = 29758;
  assign trig[34] = 29575;
  assign trig[35] = 29388;
  assign trig[36] = 29196;
  assign trig[37] = 28999;
  assign trig[38] = 28797;
  assign trig[39] = 28589;
  assign trig[40] = 28377;
  assign trig[41] = 28161;
  assign trig[42] = 27939;
  assign trig[43] = 27712;
  assign trig[44] = 27481;
  assign trig[45] = 27245;
  assign trig[46] = 27004;
  assign trig[47] = 26759;
  assign trig[48] = 26509;
  assign trig[49] = 26255;
  assign trig[50] = 25996;
  assign trig[51] = 25733;
  assign trig[52] = 25465;
  assign trig[53] = 25193;
  assign trig[54] = 24916;
  assign trig[55] = 24636;
  assign trig[56] = 24351;
  assign trig[57] = 24062;
  assign trig[58] = 23769;
  assign trig[59] = 23471;
  assign trig[60] = 23170;
  assign trig[61] = 22865;
  assign trig[62] = 22556;
  assign trig[63] = 22242;
  assign trig[64] = 21926;
  assign trig[65] = 21605;
  assign trig[66] = 21281;
  assign trig[67] = 20953;
  assign trig[68] = 20621;
  assign trig[69] = 20286;
  assign trig[70] = 19947;
  assign trig[71] = 19605;
  assign trig[72] = 19260;
  assign trig[73] = 18911;
  assign trig[74] = 18559;
  assign trig[75] = 18204;
  assign trig[76] = 17846;
  assign trig[77] = 17485;
  assign trig[78] = 17121;
  assign trig[79] = 16754;
  assign trig[80] = 16384;
  assign trig[81] = 16011;
  assign trig[82] = 15635;
  assign trig[83] = 15257;
  assign trig[84] = 14876;
  assign trig[85] = 14492;
  assign trig[86] = 14106;
  assign trig[87] = 13718;
  assign trig[88] = 13327;
  assign trig[89] = 12934;
  assign trig[90] = 12539;
  assign trig[91] = 12142;
  assign trig[92] = 11743;
  assign trig[93] = 11341;
  assign trig[94] = 10938;
  assign trig[95] = 10532;
  assign trig[96] = 10125;
  assign trig[97] = 9717;
  assign trig[98] = 9306;
  assign trig[99] = 8894;
  assign trig[100] = 8480;
  assign trig[101] = 8065;
  assign trig[102] = 7649;
  assign trig[103] = 7231;
  assign trig[104] = 6812;
  assign trig[105] = 6392;
  assign trig[106] = 5971;
  assign trig[107] = 5549;
  assign trig[108] = 5126;
  assign trig[109] = 4701;
  assign trig[110] = 4277;
  assign trig[111] = 3851;
  assign trig[112] = 3425;
  assign trig[113] = 2998;
  assign trig[114] = 2570;
  assign trig[115] = 2143;
  assign trig[116] = 1714;
  assign trig[117] = 1286;
  assign trig[118] = 857;
  assign trig[119] = 428;
  assign trig[120] = 0;

  // reconstruct cosine and sine values from table
  always_comb
    if (freq <= 120)
      begin
        cosW = trig[freq];
        sinW = trig[120-freq];
      end
    else if (freq <= 240)
      begin
        cosW = -trig[240-freq];
        sinW = trig[freq-120];
      end
    else
      begin
        cosW = trig[0];
        sinW = trig[120];
      end
  
endmodule
