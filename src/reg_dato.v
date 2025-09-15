`timescale 1ns / 1ps
/*
 * Module: reg_dato
 * Description:
 *  This module acts as an 8-bit register that stores incoming data
 *  when 'enable' is active. On reset, the register clears to zero.
 */

module reg_dato(
    input clk,              // System clock
    input rst,               // Synchronous reset (active high)
    input enable,             // Enable signal to load data
    input [7:0] data_in,      // 8-bit input data
    output reg [7:0] data_out // 8-bit output register
);

    always @(posedge clk) begin
        if (rst) begin
            // Clear the register when reset is active
            data_out <= 8'b0;
        end else if (enable) begin
            // Load new data when enable is active
            data_out <= data_in;
        end
    end

endmodule
