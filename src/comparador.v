`timescale 1ns / 1ps
/*
 * Module: comparador
 * Description:
 *  This module compares two 8-bit input values (in1 and in2).
 *  On each rising clock edge, it sets 'over' to 1 if in1 > in2,
 *  otherwise sets it to 0.
 */

module comparador(
    input  wire       clk,     // System clock
    input  wire [7:0] in1,     // First 8-bit input
    input  wire [7:0] in2,     // Second 8-bit input
    output reg        over    // Output: 1 if in1 > in2, else 0
);

    always @(posedge clk) begin
        if (in1 > in2)
            over <= 1'b1;
        else
            over <= 1'b0;
    end

endmodule
