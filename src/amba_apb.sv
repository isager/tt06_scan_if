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

module amba_apb #(
  parameter PADDR_WL = 4,
  parameter PDATA_WC = 2**PADDR_WL,
  parameter PDATA_WL = 8
) (
  input                     clk, reset_b,

  input [PDATA_WL-1:0]      pwdata,
  input [PADDR_WL-1:0]      paddr,
  input                     penable, psel, pwrite,
  output                    pready,
  output reg [PDATA_WL-1:0] prdata,

  output reg [PDATA_WL*PDATA_WC-1:0] data
);

//  integer                   i;

  assign pready = psel && penable;

  always @(posedge clk or negedge reset_b)
    if (! reset_b)
      begin
	data <= 0;
	prdata <= 0;
      end
    else if (psel && !penable)
      begin
        integer i, j;
        j = paddr*PDATA_WL;
        
	if (pwrite && paddr < PDATA_WC)
          for (i = 0; i < PDATA_WL; i = i+1)
            begin
	      data[j] <= pwdata[i];
              j = j+1;
            end
        else if (!pwrite)
          if (paddr < PDATA_WC)
            for (i = 0; i < PDATA_WL; i = i+1)
              begin
	        prdata[i] <= data[j];
                j = j+1;
              end
	  else
	    prdata <= 0;
      end

endmodule

