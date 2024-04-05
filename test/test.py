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

  dut._log.info("Test")

  # write sine frequency setting to address 0
  freq = 10
  await i2c.write(0x50, [0, freq])
  await i2c.send_stop()

  # read back freq setting from address 0 and verify
  await i2c.write(0x50, [0])
  data = await i2c.read(0x50, 1)
  await i2c.send_stop()
  assert data[0] == freq

  # attempt to write to address 8 and verify that it does not exist
  await i2c.write(0x50, b'\x08\x42')
  await i2c.send_stop()

  await i2c.write(0x50, b'\x08')
  data = await i2c.read(0x50, 1)
  await i2c.send_stop()
  assert data[0] != 0x42

  await Timer(50, 'us')
