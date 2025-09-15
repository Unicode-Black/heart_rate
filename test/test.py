# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

def any_x(val) -> bool:
    """Return True if BinaryValue has any X/Z."""
    s = val.binstr
    return ("x" in s) or ("z" in s) or ("X" in s) or ("Z" in s)

async def wait_resolved(sig, timeout_cycles=10000, clk=None, name="signal"):
    """Wait until a vector has no X/Z (or timeout)."""
    for _ in range(timeout_cycles):
        if not any_x(sig.value):
            return
        if clk is not None:
            await RisingEdge(clk)
        else:
            return
    raise AssertionError(f"{name} didn't resolve (still has X/Z)")

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # 100 MHz clock (10 ns)
    clock = Clock(dut.clk, 10, units="ns")
    cocotb.start_soon(clock.start())

    # Reset & idle
    dut.ena.value    = 1
    dut.ui_in.value  = 0          # set_pulso
    dut.uio_in.value = 0          # {cls,start}=00
    dut.rst_n.value  = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value  = 1

    # Deja que se asienten divisores/mux
    await ClockCycles(dut.clk, 6000)   # ~60 us

    # uio_oe debe ser 0xFC cuando esté resuelto
    await wait_resolved(dut.uio_oe, clk=dut.clk, name="uio_oe")
    uio_oe_int = int(dut.uio_oe.value)
    assert uio_oe_int == 0xFC, f"uio_oe={uio_oe_int:#04x}, expected 0xFC"

    # set_pulso = 16 y pulso de start (uio_in[0]) 1 ciclo
    dut.ui_in.value = 16
    dut.uio_in.value = 0b0000_0001
    await RisingEdge(dut.clk)
    dut.uio_in.value = 0

    # Espera a que en_count (uio_out[3]) se ponga a 1 sin forzar conversión de todo el bus
    en_seen = False
    for _ in range(20000):  # ~200 us @100 MHz
        await RisingEdge(dut.clk)
        # lee solo el bit 3; si está resuelto y vale 1, listo
        if getattr(dut.uio_out[3].value, "is_resolvable", False) and dut.uio_out[3].value.is_resolvable:
            if int(dut.uio_out[3].value) == 1:
                en_seen = True
                break
    assert en_seen, "en_count (uio_out[3]) did not assert after start"

    dut._log.info("Basic behavior OK: uio_oe resolved and en_count asserted after start")
