`timescale 1ns / 1ps

module minuto
(
input rst,
input en_cont,
input clk, 
output C_60s  
);

wire w1;

// Instantiate the module
C_1Hz count1(
    .clk(clk),
    .C_1Hz(w1)
    );

// Instantiate the module
C_60s cuount_2(
    .en_cont(en_cont),
    .rst(rst),
    .C_1Hz(w1), 
    .C_60s(C_60s)
    );
    
endmodule

