`timescale 1ns / 1ps
/*
 * Module: top
 * Description:
 *  Top-level integration for the heart-rate / pulse counter design.
 *  - FSM controls the measurement window (en_count), capture (en_cap), clear, and alarm.
 *  - count_pulse2 counts rising edges of a (simulated) slow pulse (C_100mHz).
 *  - minuto generates a 60-second window based on a 1 Hz tick.
 *  - reg_dato captures the measured binary count.
 *  - BintoDec converts the captured binary value into BCD digits.
 *  - Mux + Dec_7seg drive a 3-digit multiplexed 7-seg display.
 *  - DelayCLK creates a low-frequency scan clock for the display (C_1Hz).
 *  - count2 creates a very slow pulse source (C_100mHz) for test/demo.
 *
 * Notes:
 *  - All resets are active-high.
 *  - C_1Hz and C_100mHz are internal derived clocks; declare them explicitly to avoid IMPLICIT warnings.
 */

module top(
    input  wire       clk,        // System clock
    input  wire       rst,        // Active-high reset
    input  wire       start,      // Start command
    input  wire       cls,        // Clear/close command to return to IDLE
    //input  wire       pulso,    // External pulse (currently simulated by C_100mHz)
    input  wire [7:0] set_pulso,  // Threshold/compare value
    output wire       alarm,      // Alarm asserted when overflow condition met
    output wire       en_count,   // Enable counting window
    output wire       en_cap,     // Enable capture/display
    output wire       clear,      // Clear internal registers
    output wire [6:0] seg,        // 7-seg segments a..g
    output wire [2:0] an          // 3-digit anode select (active LOW)
);

    // --------------------------------------------------------------------
    // Internal wires
    // --------------------------------------------------------------------
    wire        w1;           // overflow from comparador
    wire        w2;           // end_count (60s) from minuto
    wire [3:0]  w3;           // selected nibble to 7-seg decoder
    wire [3:0]  w4_units;     // BCD units
    wire [3:0]  w5_tens;      // BCD tens
    wire [3:0]  w6_hund;      // BCD hundreds
    wire [1:0]  w7_selec;     // digit select for Mux
    wire [7:0]  w8_bin;       // live binary counter value
    wire [7:0]  w9_capture;   // captured binary value (latched)
    wire        C_1Hz;        // scan/timing clock for display path
    wire        C_100mHz;     // very slow simulated pulse source

    // --------------------------------------------------------------------
    // Control FSM
    // --------------------------------------------------------------------
    fsm fsm1 (
        .rst       (rst),
        .clk       (clk),
        .start     (start),
        .cls       (cls),
        .overflow  (w1),        // from comparador
        .end_count (w2),        // from minuto (60s pulse)
        .en_count  (en_count),
        .alarm     (alarm),
        .en_cap    (en_cap),
        .clear     (clear)
    );

    // --------------------------------------------------------------------
    // Compare current count vs. threshold
    // --------------------------------------------------------------------
    comparador comp (
        .clk  (clk),
        .in1  (w8_bin),      // measured count
        .in2  (set_pulso),   // threshold
        .over (w1)           // overflow flag
    );

    // --------------------------------------------------------------------
    // Pulse counter (counts rising edges on C_100mHz when enabled)
    // --------------------------------------------------------------------
    count_pulse2 Cpulse (
        .clk    (clk),
        .rst    (clear),     // clear resets the counter
        .enable (en_count),
        .pulso  (C_100mHz),  // simulated external pulse
        .bin    (w8_bin)
    );

    // --------------------------------------------------------------------
    // 60-second window generator (end_of_count pulse)
    // --------------------------------------------------------------------
    minuto min (
        .rst     (clear),     // reset counter window when clear is asserted
        .en_cont (en_count),
        .clk     (clk),
        .C_60s   (w2)         // raises after 60 seconds
    );

    // --------------------------------------------------------------------
    // Latch/capture the measured count at end of window
    // --------------------------------------------------------------------
    reg_dato rd1 (
        .rst      (rst),
        .enable   (en_cap),
        .clk      (clk),
        .data_in  (w8_bin),
        .data_out (w9_capture)
    );

    // --------------------------------------------------------------------
    // Binary to BCD (hundreds / tens / units)
    // --------------------------------------------------------------------
    BintoDec BtD (
        .clk   (clk),
        .sw    (w9_capture),
        //.enable(en_cap),    // optional if your BintoDec supports enable
        .hund  (w6_hund),
        .tens  (w5_tens),
        .units (w4_units)
    );

    // --------------------------------------------------------------------
    // Low-frequency clock for display scan/timing
    // (Adjust compare value inside DelayCLK to achieve desired scan rate)
    // --------------------------------------------------------------------
    DelayCLK Dclk (
        .clk   (clk),
        .C_1Hz (C_1Hz)
    );

    // --------------------------------------------------------------------
    // 3-digit multiplexing: selects which BCD nibble is shown
    // --------------------------------------------------------------------
    Mux mux1 (
        .clk      (C_1Hz),
        .dato_In1 (w4_units),
        .dato_In2 (w5_tens),
        .dato_In3 (w6_hund),
        .selec    (w7_selec),
        .an       (an),
        .dato_Out (w3)
    );

    // --------------------------------------------------------------------
    // 7-segment decoder
    // --------------------------------------------------------------------
    Dec_7seg display (
        .dato_In (w3),
        .seg     (seg)
    );

    // --------------------------------------------------------------------
    // Auto select / scan counter for the 3 digits
    // --------------------------------------------------------------------
    Selec_auto seleccion (
        .clk       (C_1Hz),
        .rst       (rst),
        .enable    (en_count),
        .selec_mux (w7_selec)
    );

    // --------------------------------------------------------------------
    // Very slow pulse source (simulated external pulse)
    // --------------------------------------------------------------------
    count2 count_2 (
        .C_100Mhz (clk),
        .C_100mHz (C_100mHz)
    );

endmodule
