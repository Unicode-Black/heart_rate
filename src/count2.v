`timescale 1ns / 1ps
/*
 * Module: count2
 * Description:
 *  This module divides a 100 MHz input clock down to ~1 Hz (actually 0.5 Hz toggle,
 *  which results in a full period of 1 second). It uses a 26-bit counter and toggles
 *  the output every 50 million cycles.
 *
 * Operation:
 *  - At 100 MHz, 50,000,000 cycles = 0.5 seconds
 *  - Output 'C_100mHz' toggles every 0.5 seconds
 *  - Therefore, full period = 1 second (1 Hz square wave)
 */

module count2 (
    input  wire C_100Mhz,    // 100 MHz system clock input
    output reg  C_100mHz = 1 // Divided clock output (~1 Hz)
);

    // 26-bit counter to reach 50,000,000 cycles
    reg [25:0] contador = 26'd0;

    always @(posedge C_100Mhz) begin
        // Use non-blocking assignments for sequential logic
        contador <= contador + 1'b1;

        if (contador == 26'd49_999_999) begin
            contador  <= 26'd0;
            C_100mHz  <= ~C_100mHz; // Toggle output every 0.5s
        end
    end

endmodule
