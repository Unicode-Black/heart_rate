`timescale 1ns / 1ps

module Selec_auto(
input clk,
input rst,
input enable,
output [1:0] selec_mux
);

reg [1:0] count = 0;

always @(posedge clk)
    if (rst)
        count <= 0;
    else if (enable) begin
        if (count == 2)
         count <= 0;
        else 
        count = count + 1;
    end                     
assign selec_mux = count;

endmodule