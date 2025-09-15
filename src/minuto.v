`timescale 1ns / 1ps
/*
 * Module: minuto
 * Description:
 *  This module generates a 60-second pulse (C_60s) by cascading:
 *   - A 1 Hz clock divider (C_1Hz)
 *   - A 60-second counter (C_60s)
 *  It counts seconds only when 'en_cont' is active.
 */

module minuto (
    input  wire rst,        // Active-high synchronous reset
    input  wire en_cont,    // Enable counting
    input  wire clk,        // System clock input
    output wire C_60s       // Output pulse every 60 seconds
);

    // Internal 1 Hz signal
    wire w1;

    // 1 Hz divider from system clock
    C_1Hz count1 (
        .clk(clk),
        .C_1Hz(w1)
    );

    // 60-second counter, triggered by 1 Hz pulses
    C_60s count_2 (
        .en_cont(en_cont),
        .rst(rst),
        .C_1Hz(w1),
        .C_60s(C_60s)
    );

endmodule
