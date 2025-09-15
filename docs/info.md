# Heart Rate Counter & Display (tt_um_heart_rate)

**Author:** Luis Vásquez  
**Brief:** Pulse counting and capture with threshold compare, 3-digit 7-segment display, and alarm.

---

## How it works
The design measures pulse events over time, compares the counted value against a user-set threshold, and displays the captured result on a multiplexed 3-digit 7-segment display.

1. **Clocking / Derived clocks**
   - The SoC clock `clk` (50 MHz) feeds two dividers:
     - `DelayCLK` → `C_1Hz` for display multiplexing and state timing.
     - `count2`  → `C_100mHz` (one pulse every 10 s) used to simulate/pace the input count when `enable` is active.

2. **Control FSM**
   - `fsm` drives the top-level enables:
     - `en_count`: enables counting window.
     - `en_cap`: latches/captures the measured value.
     - `clear`: clears counters and internal regs.
     - `alarm`: asserted when the measured value exceeds the threshold.

3. **Pulse counting and minute window**
   - `count_pulse2` receives `C_100mHz` as the pulse source (placeholder for a real sensor) and accumulates into `w8_bin`.
   - `minuto` asserts `C_60s`/`end_count` every 60 s to delimit the measurement window.

4. **Threshold compare and capture**
   - `comparador` compares `w8_bin` vs `set_pulso[7:0]` and raises `overflow` to the FSM.
   - On `en_cap`, `reg_dato` captures `w8_bin` into `w9_capture`.

5. **Binary-to-BCD and display**
   - `BintoDec` converts `w9_capture` to `{hund,tens,units}`.
   - `Selec_auto` and `Mux` (clocked by `C_1Hz`) scan the three digits and drive `an[2:0]` and `seg[6:0]`.
   - `seg[6:0]` is exported on `uo_out[6:0]`; `alarm` on `uo_out[7]`.

---

## Pinout

### Dedicated inputs `ui_in[7:0]` (threshold)
| Pin | Name          | Description                          |
|-----|---------------|--------------------------------------|
| ui[7:0] | SET_PULSO | 8-bit threshold for compare module  |

### Dedicated outputs `uo_out[7:0]`
| Pin | Name   | Description                          |
|-----|--------|--------------------------------------|
| uo[6:0] | SEG_A..SEG_G | 7-segment segment lines |
| uo[7]   | ALARM        | Alarm (1 = threshold exceeded) |

### Bidirectional `uio[7:0]`
| Pin  | Dir | Name      | Description                       |
|------|-----|-----------|-----------------------------------|
| uio[0] | IN  | START     | Start measurement                |
| uio[1] | IN  | CLS       | Clear/stop                       |
| uio[2] | OUT | AN0       | Anode select 0                   |
| uio[3] | OUT | EN_COUNT  | Counter enable (status)          |
| uio[4] | OUT | EN_CAP    | Capture enable (status)          |
| uio[5] | OUT | CLEAR     | Internal clear (status)          |
| uio[6] | OUT | (unused)  | —                                |
| uio[7] | OUT | (unused)  | —                                |

---

## Build & test
1. **Simulation (suggested):**
   - Provide `clk` and toggle `START`.  
   - Observe `en_count` high, pulses on `C_100mHz`, and `w8_bin` incrementing.  
   - After ~60 s (sim-scaled), `minuto` raises `end_count`; `reg_dato` captures into `w9_capture`.  
   - `BintoDec` updates digits; check `seg`/`an`.  
   - Set `SET_PULSO` below/above the measured value to see `ALARM` toggle.

2. **On silicon / TT board:**
   - Drive `ui_in[7:0]` via DIP-switches or host to set threshold.  
   - Provide `START` on `uio[0]`, `CLS` on `uio[1]`.  
   - Read display on `uo[6:0]` + `uio[2]` anodes.

---

## Resources / modules
- `top.v` (system integration and ports)  
- `fsm.v` (control flow)  
- `count_pulse2.v`, `count2.v`, `minuto.v` (pulse gen/count & timing)  
- `comparador.v`, `reg_dato.v` (compare & capture)  
- `BintoDec.v`, `Mux.v`, `Selec_auto.v`, `Dec_7seg.v` (display path)  
- `DelayCLK.v` (clock divider)

---

## Limitations
- `C_100mHz` is a placeholder pulse source for testing; replace with a real sensor input in future revisions.  
- Display refresh uses a low scan rate (`C_1Hz`) for simplicity; adjust if needed.

---

## License
SPDX-License-Identifier: Apache-2.0
