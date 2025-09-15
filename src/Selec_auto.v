`timescale 1ns / 1ps
/*
 * Module: Selec_auto
 * Description:
 *  This module generates a 2-bit selection signal (selec_mux) that cycles
 *  through 0 → 1 → 2 → 0 ... whenever 'enable' is active.
 *  It resets back to 0 on 'rst'.
 *
 * Notes:
 *  - Uses only non-blocking assignments (<=) in sequential logic.
 *  - Avoids mixed assignment types to prevent synthesis errors.
 */

module Selec_auto(
    input  wire clk,            // System clock
    input  wire rst,             // Active-high reset
    input  wire enable,          // Enable counting
    output wire [1:0] selec_mux  // Output selection value
);

    reg [1:0] count = 2'd0;

    always @(posedge clk) begin
        if (rst) begin
            count <= 2'd0;
        end else if (enable) begin
            if (count == 2'd2)
                count <= 2'd0;
            else
                count <= count + 2'd1;
        end
    end

    assign selec_mux = count;

endmodule
