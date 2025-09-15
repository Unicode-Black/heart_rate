# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

def bit(val, idx):
    return (int(val) >> idx) & 1

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Use a 100 MHz clock (10 ns period) to match the RTL assumptions
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # --- Reset ---
    dut._log.info("Reset")
    dut.ena.value    = 1
    dut.ui_in.value  = 0          # set_pulso
    dut.uio_in.value = 0          # {cls,start} = 00
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1
    await ClockCycles(dut.clk, 5)

    dut._log.info("Check wrapper I/O directions and idle state")

    # uio_oe should be 0xFC: [1:0]=inputs, [5:2]=outputs, [7:6]=outputs
    assert int(dut.uio_oe.value) == 0xFC, f"uio_oe={int(dut.uio_oe.value):#04x}, expected 0xFC"

    # In IDLE, clear (uio_out[5]) must be high
    assert bit(dut.uio_out.value, 5) == 1, "clear (uio_out[5]) should be 1 in IDLE"

    # --- Configure and start measurement window ---
    dut._log.info("Start measurement window")
    dut.ui_in.value = 16     # set_pulso = 16 (threshold)
    await ClockCycles(dut.clk, 2)

    # Pulse start: uio_in[0]=1 for one cycle
    dut.uio_in.value = 0b0000_0001
    await ClockCycles(dut.clk, 1)
    dut.uio_in.value = 0b0000_0000

    # Wait for en_count (uio_out[3]) to assert
    en_seen = False
    for _ in range(2000):    # ~20 us window @100 MHz (suficiente)
        await ClockCycles(dut.clk, 1)
        if bit(dut.uio_out.value, 3) == 1:
            en_seen = True
            break
    assert en_seen, "en_count (uio_out[3]) did not assert after start"

    dut._log.info("Basic behavior OK: uio_oe, clear in IDLE, en_count after start")

    # (Opcional) podrías verificar que en_cap (uio_out[4]) se active más adelante,
    # o que an/seg cambien, pero eso depende del multiplexer y del timing interno.
    # Evitamos comprobar 'alarm' aquí porque tu fuente de pulsos (C_100mHz) es lenta.
