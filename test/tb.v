`default_nettype none
`timescale 1ns / 1ps
/*
 * Testbench for tt_um_heart_rate
 * - Instantiates the TinyTapeout wrapper
 * - Generates a 100 MHz clock and active-low reset
 * - Drives ui_in (set_pulso) and uio_in[1:0] = {cls,start}
 * - Dumps VCD for waveform inspection
 */

module tb ();

  // -------------------------------
  // VCD dump
  // -------------------------------
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // -------------------------------
  // TT-style IO
  // -------------------------------
  reg         clk   = 1'b0;     // 100 MHz clock (10 ns period)
  reg         rst_n = 1'b0;     // Active-low reset
  reg         ena   = 1'b1;     // Always enabled in TT

  reg  [7:0]  ui_in   = 8'h00;  // Dedicated inputs  -> set_pulso
  wire [7:0]  uo_out;           // Dedicated outputs -> seg[6:0], alarm
  reg  [7:0]  uio_in  = 8'h00;  // UIO inputs: [1]=cls, [0]=start
  wire [7:0]  uio_out;          // UIO outputs: an[2:0], en_count, en_cap, clear
  wire [7:0]  uio_oe;           // UIO direction

`ifdef GL_TEST
  // Power pins for gate-level sim
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // 100 MHz clock
  always #5 clk = ~clk;

  // -------------------------------
  // Device Under Test
  // -------------------------------
  tt_um_heart_rate user_project (
`ifdef GL_TEST
      .VPWR  (VPWR),
      .VGND  (VGND),
`endif
      .ui_in  (ui_in),
      .uo_out (uo_out),
      .uio_in (uio_in),
      .uio_out(uio_out),
      .uio_oe (uio_oe),
      .ena    (ena),
      .clk    (clk),
      .rst_n  (rst_n)
  );

  // -------------------------------
  // Stimulus (based on your original test)
  // ui_in      = set_pulso
  // uio_in[0]  = start
  // uio_in[1]  = cls
  // -------------------------------
  initial begin
    // Initial conditions
    rst_n    = 1'b0;
    ui_in    = 8'd16;        // set_pulso = 16
    uio_in   = 8'b0000_0000; // {cls,start}=00

    // Hold reset for a few cycles
    repeat (5) @(posedge clk);
    rst_n = 1'b1;

    // Small delay then pulse start
    repeat (1) @(posedge clk);
    uio_in[0] = 1'b1;        // start = 1
    @(posedge clk);
    uio_in[0] = 1'b0;        // start = 0

    // Let the design run for a while to see counting/capture
    // (Your dividers are reduced, so this completes quickly in sim)
    repeat (100000) @(posedge clk);

    // Pulse cls to return to IDLE
    uio_in[1] = 1'b1;        // cls = 1
    @(posedge clk);
    uio_in[1] = 1'b0;        // cls = 0

    // Run a little longer and finish
    repeat (1000) @(posedge clk);
    $finish;
  end

  // -------------------------------
  // Console monitor (optional)
  // uo_out[7]   = alarm
  // uo_out[6:0] = seg
  // uio_out[2:0]= an, [3]=en_count, [4]=en_cap, [5]=clear
  // -------------------------------
  always @(posedge clk) begin
    if (rst_n) begin
      $strobe("t=%0t | alarm=%0b en_count=%0b en_cap=%0b clear=%0b | an=%b seg=%b",
               $time, uo_out[7], uio_out[3], uio_out[4], uio_out[5],
               uio_out[2:0], uo_out[6:0]);
    end
  end

endmodule
