`timescale 1ns / 1ps

module count2(C_100Mhz,C_100mHz);
input C_100Mhz; //Clock de entrada del FPGA de entrada (Pin 17).
output reg C_100mHz = 1; //Senal de salida (&lt;em&gt;Se debe asignar un estado lógico&lt;/em&gt;).

reg[25:0] contador = 0; //Variable Contador equivale a 25 millones de estados.

always @(posedge C_100Mhz)
    begin
        contador = contador + 1; //0.5 segundos LED encendido
        if(contador == 49_999_999)
        begin
            contador = 0;
            C_100mHz = ~C_100mHz; //0.5 segundos LED apagado
        end
    end
endmodule
