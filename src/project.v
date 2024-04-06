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

`define default_netname none

module tt_um_sine_gen (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  localparam WL = 16;
  localparam PADDR_WL = 8;
  localparam PADDR_CFG_WL = 2;
  localparam PDATA_WL = 8;
  localparam PDATA_CFG_WC = 2**PADDR_CFG_WL;
  
  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = sine[WL-1:WL-8];
  
  reg  ena_prev;
  wire load = ena ^ ena_prev;
  wire [PDATA_WL-1:0] freq;
  wire signed [WL-1:0] sine, cosW, sinW;
  

  freq2trig #(
    .WL(WL))
  f2t_inst (
    .freq(freq),
    .cosW(cosW),
    .sinW(sinW));

  sine_gen #(
    .WL(WL))
  sine_gen_inst (
    .clk(clk),
    .reset_b(rst_n),
    .en(ena),
    .load(pready),
    .cosW(cosW),
    .sinW(sinW),
    .sine(sine));

  always @(posedge clk, negedge rst_n)
    if (! rst_n)
      ena_prev <= 0;
    else
      ena_prev <= ena;

  // hook up I2C IOs, refer to https://tinytapeout.com/specs/pinouts/#i2c-optional-interrupt-and-reset
  wire       scl_in = uio_in[2];
  wire       sda_in = uio_in[3];
  assign uio_out[2] = 1'b0; // scl
  assign uio_out[3] = 1'b0; // sda
  assign uio_oe[2]  = ~scl_out;
  assign uio_oe[3]  = ~sda_out;

  // unused bidirs
  assign uio_out[1:0] = 0;
  assign uio_out[7:4] = 0;
  assign uio_oe[1:0] = 0;
  assign uio_oe[7:4] = 0;
                      
  wire [PADDR_WL-1:0]  paddr;
  wire [PDATA_WL-1:0]  prdata;   
  wire [PDATA_WL-1:0]  pwdata;
  wire [PDATA_WL*PDATA_CFG_WC-1:0] cfg;

  i2c_slave #(
    .PADDR_WL(PADDR_WL))
  i2c_inst (
    .clk(clk),
    .reset_b(rst_n),
    .pready(pready),
    .prdata(prdata),
    .pwdata(pwdata),
    .paddr(paddr),
    .penable(penable),
    .psel(psel),
    .pwrite(pwrite),
    .device_address(7'b1010000),
    .scl_in(scl_in),
    .sda_in(sda_in),
    .scl_out(scl_out),
    .sda_out(sda_out));

  // avoid aliasing by only asserting psel when unused bits are zero
  wire psel_cfg = psel && paddr[PADDR_WL-1:PADDR_CFG_WL] == 0;

  amba_apb #(
    .PADDR_WL(PADDR_CFG_WL))
  apb_cfg_inst (
    .clk(clk),
    .reset_b(rst_n),
    .pwdata(pwdata),
    .paddr(paddr[PADDR_CFG_WL-1:0]),
    .penable(penable),
    .psel(psel_cfg),
    .pwrite(pwrite),
    .pready(pready),
    .prdata(prdata),
    .data(cfg));

  localparam FREQ_IDX = 0;
  
  assign freq = cfg[(FREQ_IDX+1)*PDATA_WL-1:FREQ_IDX*PDATA_WL];

endmodule
