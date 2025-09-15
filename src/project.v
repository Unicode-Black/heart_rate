`timescale 1ns / 1ps
`default_nettype none
/*
 * Module: tt_um_heart_rate
 * Description:
 *  TinyTapeout wrapper for the 'top' design.
 *  - Maps TT dedicated inputs (ui_in) to 'set_pulso[7:0]'.
 *  - Uses UIO as: uio_in[0]=start, uio_in[1]=cls (inputs),
 *    and exports an[2:0], en_count, en_cap, clear on uio_out.
 *  - Exposes 7-seg segments on uo_out[6:0] and alarm on uo_out[7].
 */

module tt_um_heart_rate (
    input  wire [7:0] ui_in,    // Dedicated inputs -> set_pulso[7:0]
    output wire [7:0] uo_out,   // Dedicated outputs -> seg[6:0], alarm
    input  wire [7:0] uio_in,   // UIO inputs: uio_in[1:0] = {cls, start}
    output wire [7:0] uio_out,  // UIO outputs: an[2:0], en_count, en_cap, clear
    output wire [7:0] uio_oe,   // UIO direction: 1=output, 0=input (per bit)
    input  wire       ena,      // Always 1 when powered (can be ignored)
    input  wire       clk,      // Chip clock
    input  wire       rst_n     // Active-low reset from TT
);

    // ---- Input mapping ----
    wire       rst       = ~rst_n;   // Internal reset is active-high
    wire       start     = uio_in[0];
    wire       cls       = uio_in[1];
    wire [7:0] set_pulso = ui_in;    // Full 8-bit threshold/config

    // ---- Outputs from user 'top' design ----
    wire       alarm;
    wire       en_count;
    wire       en_cap;
    wire       clear;
    wire [6:0] seg;
    wire [2:0] an;

    // ---- Instantiate the user top module ----
    top u_top (
        .clk       (clk),
        .rst       (rst),
        .start     (start),
        .cls       (cls),
        .set_pulso (set_pulso),
        .alarm     (alarm),
        .en_count  (en_count),
        .en_cap    (en_cap),
        .clear     (clear),
        .seg       (seg),
        .an        (an)
    );

    // ---- Dedicated outputs (uo_out) ----
    assign uo_out[6:0] = seg;     // 7-seg segments a..g
    assign uo_out[7]   = alarm;   // Alarm flag

    // ---- UIO mapping ----
    // Inputs (cls,start) keep oe=0, the others are driven as outputs.
    assign uio_out[2:0] = an;         // Anode selects (active LOW externally)
    assign uio_out[3]   = en_count;   // Status: counting enabled
    assign uio_out[4]   = en_cap;     // Status: capture enabled
    assign uio_out[5]   = clear;      // Status: clear
    assign uio_out[7:6] = 2'b00;      // Unused

    assign uio_oe[1:0] = 2'b00;       // uio_in[1:0] are inputs (cls,start)
    assign uio_oe[5:2] = 4'b1111;     // Drive uio_out[5:2] as outputs
    assign uio_oe[7:6] = 2'b11;       // Drive (unused) as outputs to avoid float

    // Avoid 'unused' warnings (consume bits not used explicitly)
    wire _unused = &{ena, uio_in[7:2], 1'b0};

endmodule
