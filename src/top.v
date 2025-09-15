`timescale 1ns / 1ps

module top(
input clk,
input rst,
input start,
input cls,
//input pulso,  senal que por ahora esta simulada
input [7:0] set_pulso,
output alarm,
output en_count,
output en_cap,
output clear,
output [6:0] seg,
output [2:0] an
);
 
 wire w1;
 wire w2;
 wire [3:0] w3; 
 wire [3:0] w4_units;
 wire [3:0] w5_tens; 
 wire [3:0] w6_hund;
 wire [1:0] w7_selec;
 wire [7:0] w8_bin;
 wire [7:0] w9_capture;
 
 fsm fsm1 (
    .rst(rst),
    .clk(clk),
    .start(start),
    .cls(cls),
    .overflow(w1),
    .end_count(w2),
    .en_count(en_count),
    .alarm(alarm),
    .en_cap(en_cap),
    .clear(clear)
 );
 
comparador comp (
     .clk(clk),
    .in1(w8_bin),
    .in2(set_pulso),
    .over(w1)
 );
 
count_pulse2 Cpulse(
    .clk(clk),
    .rst(clear),
    .enable(en_count),
    .pulso(C_100mHz),
    .bin(w8_bin)
);

minuto min (
    .rst(clear),
    .en_cont(en_count),
    .clk(clk),
    .C_60s(w2)
);

reg_dato rd1 (
    .rst(rst),
    .enable(en_cap),
    .clk(clk),
    .data_in(w8_bin),
    .data_out(w9_capture)
);

BintoDec BtD (
    .clk(clk),
    .sw(w9_capture),
//    .enable(en_cap),
    .hund(w6_hund),
    .tens(w5_tens),
    .units(w4_units)
);

DelayCLK Dclk (
    .clk(clk), //Clock de entrada del FPGA de entrada (Pin 17).
    .C_1Hz(C_1Hz)
);

Mux mux1 (
    .clk(C_1Hz),
    .dato_In1(w4_units),
    .dato_In2(w5_tens),
    .dato_In3(w6_hund),
    .selec(w7_selec),
    .an(an),
    .dato_Out(w3)
    );
    
 Dec_7seg display (
    .dato_In(w3),
    .seg(seg)
    );
    
Selec_auto seleccion (
    .clk(C_1Hz),
    .rst(rst),
    .enable(en_count),
    .selec_mux(w7_selec)
    );
    
//Anodos anod (
//    .selec(selecW),
//    .an(an)
//    );   
    
// Instantiate the module
count2 count_2(
    .C_100Mhz(clk), 
    .C_100mHz(C_100mHz)
    );

endmodule
