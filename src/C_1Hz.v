`timescale 1ns / 1ps

module C_1Hz (clk,C_1Hz);
input clk; //Clock de entrada del FPGA de entrada (Pin 17).
output reg C_1Hz = 1; //Señal de salida (&lt;em&gt;Se debe asignar un estado lógico&lt;/em&gt;).

reg[25:0] contador = 0; //Variable Contador equivale a 25 millones de estados.

always @(posedge clk)
    begin
        contador = contador + 1; //0.5 segundos LED encendido
        if(contador == 49_999)
        begin
            contador = 0;
            C_1Hz = ~C_1Hz; //0.5 segundos LED apagado
        end
    end
endmodule