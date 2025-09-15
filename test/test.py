# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

def bit(val, idx):
    return (int(val) >> idx) & 1

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # 100 MHz clock (10 ns period)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value    = 1
    dut.ui_in.value  = 0          # set_pulso
    dut.uio_in.value = 0          # {cls,start}=00
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1

    # Deja que se resuelvan señales internas (mux/display, etc.)
    await ClockCycles(dut.clk, 6000)   # ~60 us

    # uio_oe debe ser 0xFC: [1:0]=entradas, [5:2]=salidas, [7:6]=salidas
    assert int(dut.uio_oe.value) == 0xFC, f"uio_oe={int(dut.uio_oe.value):#04x}, expected 0xFC"

    # Configura umbral y arranca
    dut.ui_in.value = 16  # set_pulso = 16

    # Pulso de start (uio_in[0]) por 1 ciclo
    dut.uio_in.value = 0b0000_0001
    await RisingEdge(dut.clk)
    dut.uio_in.value = 0

    # Espera a que en_count (uio_out[3]) se ponga a 1
    en_seen = False
    for _ in range(2000):  # ~20 us @100 MHz
        await RisingEdge(dut.clk)
        if dut.uio_out[3].value.is_resolvable and bit(dut.uio_out.value, 3) == 1:
            en_seen = True
            break
    assert en_seen, "en_count (uio_out[3]) did not assert after start"

    dut._log.info("Basic behavior OK: uio_oe and en_count after start")
