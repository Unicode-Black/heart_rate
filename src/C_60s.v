`timescale 1ns / 1ps

module C_60s(C_1Hz, rst, en_cont, C_60s);
input wire rst;
input wire en_cont;
input wire C_1Hz; //Clock de entrada del FPGA de entrada (Pin 17).
output reg C_60s; //Seal de salida .

reg [5:0] contador; // Contador de 32 bits para contar los segundos

always @(posedge C_1Hz or posedge rst) begin
    if (rst) begin
        contador <= 0;  // Reinicia el contador en reset
        C_60s <= 1'b0;        // Apaga la salida en reset
    end else if (en_cont) begin
        if (contador < 40) begin
            contador <= contador + 1;  // Incrementa el contador
            C_60s <= 1'b0;                // Mantiene la salida encendida
        end else begin
            C_60s <= 1'b1;                // Apaga la salida después de 60 segundos
        end
    end else begin
        contador <= 0;  // Reinicia el contador si enable es desactivado
        C_60s <= 1'b0;        // Apaga la salida
    end
end

endmodule

