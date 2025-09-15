`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
 
 module BintoDec(
    input clk,
    input [7:0] sw,
    output reg [3:0] hund,
    output reg [3:0] tens,
    output reg [3:0] units
//    output reg flag
);
    reg [11:0] digits = 0;
    reg [7:0] cachedValue = 0;
    reg [3:0] stepCounter = 0;
    reg [3:0] state = 0;
    
    
    localparam START_STATE = 0;
    localparam ADD3_STATE = 1;
    localparam SHIFT_STATE = 2;
    localparam DONE_STATE = 3;

    always @(posedge clk) begin
        case (state)
           START_STATE: begin
            cachedValue <= sw;
            stepCounter <= 0;
            digits <= 0;
            state <= ADD3_STATE;
//            flag <= 0;
            end
           ADD3_STATE: begin
            digits <= digits + 
            ((digits[3:0] >= 5) ? 12'd3 : 12'd0) + 
            ((digits[7:4] >= 5) ? 12'd48 : 12'd0) + 
            ((digits[11:8] >= 5) ? 12'd768 : 12'd0);
            state <= SHIFT_STATE;
            end 
           SHIFT_STATE: begin
            digits <= {digits[10:0],cachedValue[7]};
            cachedValue <= {cachedValue[6:0],1'b0};
            if (stepCounter == 7)
                state <= DONE_STATE;
            else begin
                state <= ADD3_STATE;
                stepCounter <= stepCounter + 1;
                end
            end
           DONE_STATE: begin
            hund <= digits[11:8];
            tens <=  digits[7:4];
            units <= digits[3:0];
            state <= START_STATE;
//            flag <= 1;
            end
         endcase
    end
endmodule   

    
    

