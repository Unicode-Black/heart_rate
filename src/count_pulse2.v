`timescale 1ns / 1ps
/*
 * Module: count_pulse2
 * Description:
 *  This module counts external pulses when 'enable' is active.
 *  It uses two flip-flops to synchronize the asynchronous 'pulso'
 *  signal to the system clock and detect its rising edges.
 *
 * Operation:
 *  - On reset, the counter is cleared.
 *  - When 'enable' is high, each rising edge of 'pulso' increments 'bin'.
 */

module count_pulse2(
    input  wire clk,        // System clock
    input  wire rst,        // Active-high reset
    input  wire pulso,      // Asynchronous external pulse input
    input  wire enable,     // Enable counting
    output reg  [7:0] bin   // 8-bit pulse counter
);

    // Registers used for synchronization and edge detection
    reg pulso_sync;          // Synchronized pulse
    reg pulso_sync_prev;     // Delayed version to detect edges

    // Synchronize the pulse signal to the system clock
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pulso_sync       <= 1'b0;
            pulso_sync_prev  <= 1'b0;
        end else begin
            pulso_sync_prev  <= pulso_sync;
            pulso_sync       <= pulso;
        end
    end

    // Counter logic (increment on rising edge of pulse when enabled)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bin <= 8'b00000000;
        end else if (enable && pulso_sync && !pulso_sync_prev) begin
            bin <= bin + 1'b1;
        end
    end

endmodule
