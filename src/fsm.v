`timescale 1ns / 1ps
/*
 * Module: fsm
 * Description:
 *  Control state machine for the heart-rate/pulse counting flow.
 *  - IDLE    : wait for 'start' command (keeps system cleared)
 *  - READ    : enable counting window; may raise ALARM if 'overflow'
 *  - ALARM   : alarm stays asserted while counting continues
 *  - DISPLAY : capture the count for display
 *  - DELAY   : short hold to keep display stable (one cycle here)
 *  - CLEAR   : deassert 'clear' and wait for 'cls' to return to IDLE
 *
 * Notes:
 *  - Synchronous reset (active high) brings the FSM to IDLE.
 *  - Separate combinational blocks for next-state and output decode.
 *  - Verilator lint pragmas are used to silence CASEINCOMPLETE warnings,
 *    since we already provide a 'default' branch as safety net.
 */

module fsm (
    input  wire clk,         // System clock
    input  wire rst,         // Synchronous reset (active high)
    input  wire start,       // Start command
    input  wire cls,         // Clear/close command to return to IDLE
    input  wire overflow,    // Threshold exceeded indication
    input  wire end_count,   // Minute window done (60s)
    output reg  en_count,    // Enable counting window
    output reg  alarm,       // Alarm output
    output reg  en_cap,      // Enable capture/display of pulses
    output reg  clear        // Asserted to clear internal registers
);

    // --------------------------------------------------------------------
    // State encoding (4 bits as in original; 6 used states)
    // --------------------------------------------------------------------
    localparam Idle    = 4'b0000;
    localparam Read    = 4'b0001;
    localparam AlarmS  = 4'b0010;
    localparam Display = 4'b0011;
    localparam Delay   = 4'b0100;
    localparam ClearS  = 4'b0101;

    reg [3:0] state, next;

    // --------------------------------------------------------------------
    // Sequential state register (synchronous reset)
    // --------------------------------------------------------------------
    always @(posedge clk) begin
        if (rst)
            state <= Idle;
        else
            state <= next;
    end

    // --------------------------------------------------------------------
    // Next-state logic (combinational)
    // --------------------------------------------------------------------
    /* verilator lint_off CASEINCOMPLETE */
    always @* begin
        next = state;  // default stay
        case (state)
            Idle: begin
                if (start)
                    next = Read;
            end

            Read: begin
                // Priority: if both 'overflow' and 'end_count' happen,
                // ALARM takes precedence first in this cycle, then DISPLAY.
                if (overflow)
                    next = AlarmS;
                else if (end_count)
                    next = Display;
            end

            AlarmS: begin
                if (end_count)
                    next = Display;
            end

            Display: begin
                next = Delay;
            end

            Delay: begin
                next = ClearS;
            end

            ClearS: begin
                if (cls)
                    next = Idle;
            end

            default: begin
                next = Idle;
            end
        endcase
    end
    /* verilator lint_on CASEINCOMPLETE */

    // --------------------------------------------------------------------
    // Output decode (combinational)
    // --------------------------------------------------------------------
    /* verilator lint_off CASEINCOMPLETE */
    always @* begin
        // Safe defaults
        en_count = 1'b0;
        en_cap   = 1'b0;
        alarm    = 1'b0;
        clear    = 1'b0;

        case (state)
            Idle: begin
                // Keep the system cleared while idle
                clear = 1'b1;
            end

            Read: begin
                // Counting window active
                en_count = 1'b1;
            end

            AlarmS: begin
                // Alarm asserted while we keep counting until end_count
                alarm    = 1'b1;
                en_count = 1'b1;
            end

            Display: begin
                // Latch/capture the result for display
                en_cap = 1'b1;
            end

            Delay: begin
                // Hold capture one more cycle (simple stabilization)
                en_cap = 1'b1;
            end

            ClearS: begin
                // Deassert 'clear' (already 0 by default) and wait for 'cls'
                // Behavior preserved from original code.
            end

            default: begin
                // Already covered by defaults
            end
        endcase
    end
    /* verilator lint_on CASEINCOMPLETE */

endmodule
