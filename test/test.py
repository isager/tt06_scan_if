# SPDX-FileCopyrightText: © 2023 Uri Shaked <uri@tinytapeout.com>
# SPDX-License-Identifier: MIT

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import Timer
from i2c import I2cMaster

@cocotb.test()
async def test_sine(dut):

  print(dut.uio_in[2])
  print(dut.scl)
  
  i2c = I2cMaster(sda=dut.sda, sda_o=dut.sda_tb,
                  scl=dut.scl, scl_o=dut.scl_tb, speed=400e3)

  dut._log.info("Start")
  
  # Our example module doesn't use clock and reset, but we show how to use them here anyway.
  clock = Clock(dut.clk, 20, units="ns")
  cocotb.start_soon(clock.start())

  # Reset
  dut._log.info("Reset")
  dut.ena.value = 1
  dut.ui_in.value = 0
  #dut.uio_in.value = 0
  dut.rst_n.value = 0
  await ClockCycles(dut.clk, 10)
  dut.rst_n.value = 1
  await ClockCycles(dut.clk, 10)

  await i2c.write(0x50, b'\x00\x10')
  await i2c.send_stop()

  #await Timer(100, 'us')

  # Set the input values, wait one clock cycle, and check the output
  dut._log.info("Test")
  dut.ui_in.value = 20

  await Timer(1, 'ms')
 # await ClockCycles(dut.clk, 1000)

  #assert dut.uo_out.value == 50
