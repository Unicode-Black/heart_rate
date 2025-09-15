`timescale 1ns / 1ps
/*
 * Module: C_1Hz
 * Description:
 *  This module divides the input clock (`clk`) to generate a 1 Hz output signal.
 *  The output toggles every 0.5 seconds, resulting in a full period of 1 second.
 *
 * Notes:
 *  - The counter threshold must be adjusted depending on the input clock frequency.
 *  - This example assumes a 100 MHz input clock. 
 */

module C_1Hz(
    input  wire clk,       // Input clock (e.g., 100 MHz FPGA clock)
    output reg  C_1Hz = 1  // Output 1 Hz clock signal
);

    reg [25:0] contador = 26'd0;  // 26-bit counter (can count up to 67M)

    always @(posedge clk) begin
        contador <= contador + 1; // Increment counter
        if (contador == 26'd49_999_999) begin // 50M cycles -> 0.5 seconds at 100 MHz
            contador <= 26'd0;
            C_1Hz <= ~C_1Hz; // Toggle output every 0.5 seconds
        end
    end

endmodule
