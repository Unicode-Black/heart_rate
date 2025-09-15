# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, ClockCycles

async def wait_resolved_bit(dut, vec, idx, max_cycles=20000):
    """Wait until vec[idx] is resolvable (no X/Z) or timeout."""
    for _ in range(max_cycles):
        if vec[idx].value.is_resolvable:
            return int(vec[idx].value)
        await RisingEdge(dut.clk)
    raise TimeoutError(f"Bit {idx} of {vec._name} did not resolve within {max_cycles} cycles")

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # 100 MHz clock (10 ns period) – consistente con tu RTL
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

    # Da tiempo a que la lógica interna salga de X (multiplexor/display, etc.)
    # (En tu strobe, clear=1 aparece ~50 us => 5000 ciclos a 100 MHz)
    await ClockCycles(dut.clk, 6000)

    # uio_oe debe ser 0xFC: [1:0]=entradas, [5:2]=salidas, [7:6]=salidas
    assert int(dut.uio_oe.value) == 0xFC, f"uio_oe={int(dut.uio_oe.value):#04x}, expected 0xFC"

    # En IDLE, clear (uio_out[5]) debería ser 1 (espera a que sea resoluble)
    clear_idle = await wait_resolved_bit(dut, dut.uio_out, 5, max_cycles=2000)
    assert clear_idle == 1, "clear (uio_out[5]) should be 1 in IDLE"

    # Configura umbral y arranca ventana de medida
    dut.ui_in.value = 16  # set_pulso = 16

    # Pulso de start (uio_in[0])
    dut.uio_in.value = 0b0000_0001
    await RisingEdge(dut.clk)
    dut.uio_in.value = 0b0000_0000

    # Espera a que en_count (uio_out[3]) se ponga a 1
    en_seen = False
    for _ in range(2000):  # ~20 us @100 MHz
        await RisingEdge(dut.clk)
        if dut.uio_out[3].value.is_resolvable and int(dut.uio_out[3].value) == 1:
            en_seen = True
            break
    assert en_seen, "en_count (uio_out[3]) did not assert after start"

    # (Opcional) Podrías comprobar en_cap (uio_out[4]) o alarm (uo_out[7]) con más espera.
    # Con tus divisores actuales, alarm puede tardar; si quieres probarlo, aumenta el timeout
    # o usa un divisor reducido solo en simulación con `ifdef COCOTB_SIM`.

    dut._log.info("Basic checks passed (uio_oe, clear in IDLE, en_count after start)")
