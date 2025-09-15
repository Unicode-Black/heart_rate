`timescale 1ns / 1ps
/*
 * Module: DelayCLK
 * Description:
 *  This module divides the input clock frequency to generate a slower clock pulse.
 *  It toggles the output signal `C_1Hz` after a certain number of input clock cycles.
 *
 * Parameters:
 *  - Assumes a 100 MHz input clock.
 *  - With the current compare value (10000), the output will be much faster than 1 Hz.
 *    For a true 1 Hz toggle, set the compare to 49_999_999.
 */

module DelayCLK (
    input  wire clk,        // Input clock (e.g. 100 MHz)
    output reg  C_1Hz = 1   // Output slow clock (~1 Hz after dividing)
);

    reg [25:0] contador = 0; // 26-bit counter register

    always @(posedge clk) begin
        contador <= contador + 1;
        if (contador == 10000) begin
            contador <= 0;
            C_1Hz <= ~C_1Hz;  // Toggle output
        end
    end

endmodule
