`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
module Mux
(
input clk,
input [3:0] dato_In1,
input [3:0] dato_In2,
input [3:0] dato_In3,
input [1:0] selec,
output reg [2:0] an,
output reg [3:0] dato_Out
);
    
always @(posedge clk)
      case (selec)
         2'b00: dato_Out <= dato_In1;
         2'b01: dato_Out <= dato_In2;
         2'b10: dato_Out <= dato_In3;
         default: dato_Out <= 4'b0000;
      endcase
      
   
always @(posedge clk)
      case (selec)
         2'b00: an <= 4'b1011;
         2'b01: an <= 4'b1101;
         2'b10: an <= 4'b1110;
         default: an <= 4'b1111;
      endcase
endmodule
      

