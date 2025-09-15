`timescale 1ns / 1ps

module count_pulse2(

    input wire clk,           // Senal de reloj
    input wire rst,           // Senal de reset
    input wire pulso,      // Entrada del pulso externo
    input wire enable,        // Senal de habilitación
    output reg [7:0] bin    // Salida del contador (8 bits)
);
    // Registros para la sincronización y detección del flanco
    reg pulso_sync;
    reg pulso_sync_prev;

    // Sincronización del pulso
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pulso_sync <= 1'b0;
            pulso_sync_prev <= 1'b0;
        end else begin
            pulso_sync_prev <= pulso_sync;
            pulso_sync <= pulso;
        end
    end
    // Contador activado por el pulso con enable
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            bin <= 8'b00000000;
        end else if (enable && pulso_sync && !pulso_sync_prev) begin
            // Detecta el flanco de subida del pulso si enable está activo
            bin <= bin + 1;
        end
    end
endmodule
