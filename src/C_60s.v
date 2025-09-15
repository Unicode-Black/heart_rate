`timescale 1ns / 1ps
/*
 * Module: C_60s
 * Description:
 *  This module counts seconds based on a 1 Hz clock input (`C_1Hz`).
 *  When the counter reaches 60 seconds, it asserts the output `C_60s`.
 *
 * Notes:
 *  - The counter resets on `rst` or when `en_cont` is low.
 *  - The current threshold is 40, but for 60 real seconds it should be 59.
 */

module C_60s(
    input  wire C_1Hz,      // 1 Hz clock input
    input  wire rst,         // Asynchronous reset (active high)
    input  wire en_cont,     // Enable signal for counting
    output reg  C_60s        // Output asserted after 60 seconds
);

    reg [5:0] contador = 6'd0; // 6-bit counter (0 to 59)

    always @(posedge C_1Hz or posedge rst) begin
        if (rst) begin
            contador <= 6'd0;
            C_60s <= 1'b0;
        end else if (en_cont) begin
            if (contador < 6'd59) begin
                contador <= contador + 6'd1;
                C_60s <= 1'b0;
            end else begin
                C_60s <= 1'b1; // Assert after 60 seconds
            end
        end else begin
            contador <= 6'd0;
            C_60s <= 1'b0;
        end
    end

endmodule
