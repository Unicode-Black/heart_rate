`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////
module fsm
(
    input clk,
    input rst,
    input start,
    input cls,                //  inicia el conteo
    input overflow,             // indica sobre pulsos
    input end_count,            //  fin del minuto
    output reg en_count,        //  inicio del minuto    
    output reg alarm,           //  genera la alarma
    output reg  en_cap,         //  muestra el conteo de pulsos 
    output reg clear            //  limpia los registros y regresa a escucha el sistema
);
   reg [3:0] state, next; 
   
   parameter Idle = 4'b0000;
   parameter Read = 4'b0001;
   parameter Alarm = 4'b0010;
   parameter Display = 4'b0011;
   parameter Delay = 4'b0100;
   parameter Clear = 4'b0101;

always @(posedge clk)
	if (rst)
		state <= Idle;
	else
		state <= next;

always @* 
begin
	next = state; //default condition
	case (state)
		Idle: if (start)
			     next = Read;
		Read: begin
		          if (overflow) 
		              next = Alarm;
		          if (end_count)
		              next = Display;
		         end 
		Alarm: if (end_count)
		          next = Display;
		Display: next = Delay;
		Delay: next = Clear;
		Clear: if (cls)
		          next = Idle; 
		default: next = Idle;     
	endcase
end

always @*
begin
	en_count = 0;
	en_cap = 0;
	alarm  = 0;
	clear = 0;
	
    case (state)
	   Idle: clear = 1; 
	   Read: en_count = 1;
	   Alarm: begin 
	               alarm = 1;
	               en_count = 1;
	           end
	   Display: en_cap = 1;
	   Delay: en_cap = 1;
	   Clear:  clear = 0;
    endcase
end
   
endmodule
