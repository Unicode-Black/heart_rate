`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module comparador(

input clk,
input [7:0] in1,
input [7:0] in2,
output reg over
    );
    
always @(posedge clk)
      if (in1 > in2)
         over <= 1'b1;
      else
         over <= 1'b0;    
endmodule

