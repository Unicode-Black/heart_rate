`default_nettype none

module tt_um_heart_rate (
    input  wire [7:0] ui_in,    // Entradas dedicadas (usadas para set_pulso[7:0])
    output wire [7:0] uo_out,   // Salidas dedicadas (usadas para seg[6:0] y alarm)
    input  wire [7:0] uio_in,   // UIO como entradas (uio_in[1:0] = {cls,start})
    output wire [7:0] uio_out,  // UIO como salidas (an[2:0], en_count, en_cap, clear)
    output wire [7:0] uio_oe,   // 1=output, 0=input por bit
    input  wire       ena,      // se puede ignorar (siempre 1 cuando energizado)
    input  wire       clk,      // reloj del chip
    input  wire       rst_n     // reset activo en bajo desde TT
);

    // ---- Mapeo de entradas ----
    wire        rst        = ~rst_n;     // tu top usa reset activo en alto
    wire        start      = uio_in[0];
    wire        cls        = uio_in[1];
    wire [7:0]  set_pulso  = ui_in;      // los 8 bits completos

    // ---- Señales de salida internas de tu top ----
    wire        alarm;
    wire        en_count;
    wire        en_cap;
    wire        clear;
    wire [6:0]  seg;
    wire [2:0]  an;

    // ---- Instancia de tu diseño ----
    top u_top (
        .clk       (clk),
        .rst       (rst),
        .start     (start),
        .cls       (cls),
        .set_pulso (set_pulso),
        .alarm     (alarm),
        .en_count  (en_count),
        .en_cap    (en_cap),
        .clear     (clear),
        .seg       (seg),
        .an        (an)
    );

    // ---- Dedicados: mostrar 7 segmentos y alarma ----
    assign uo_out[6:0] = seg;    // segmentos a, b, c, d, e, f, g
    assign uo_out[7]   = alarm;  // bit extra para alarma

    // ---- UIO: anodos y señales de estado ----
    // uio_in[1:0] son entradas (cls, start) => oe=0
    // el resto los usamos como salidas => oe=1
    assign uio_out[2:0] = an;        // anodos
    assign uio_out[3]   = en_count;  // enable contador
    assign uio_out[4]   = en_cap;    // enable captura
    assign uio_out[5]   = clear;     // clear interno
    assign uio_out[7:6] = 2'b00;     // libres

    assign uio_oe[1:0] = 2'b00;      // uio_in[1:0] = entradas (cls,start)
    assign uio_oe[5:2] = 4'b1111;    // uio_out[5:2] = salidas
    assign uio_oe[7:6] = 2'b11;      // uio_out[7:6] = salidas (aunque en 0)

    // Evitar warnings por 'ena' no usado
    wire _unused = &{ena, 1'b0};

endmodule
