//
//  Phase-offset clock generator
//
//  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
//  This will hopefully be replaced with an FOSS license soon.
//
//  Copyright (c) Assured Information Security, inc.
//  Author: K. Temkin
//

`default_nettype none

module ets_clkgen(
    input wire reset,
    input wire baseclk,
    input wire [7:0] delay,

    input wire hacktick,

    output wire ref_clk,
    output wire ets_clk,
    output wire lock
);

  localparam DIVISOR = 8.0;
  localparam MULTIPLIER = 2;

  localparam PHASE_SHIFT_CALIBRATION = -80;

  // DCM_SP: Digital Clock Manager
  //         Spartan-6
  // Xilinx HDL Language Template, version 14.7
  wire local_gnd;
  wire [7:0] status;
  assign local_gnd = 0;
  assign lock = !status[0];

  DCM_SP #(
      .CLKDV_DIVIDE(DIVISOR),               // CLKDV divide value
                                            // (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      .CLKFX_DIVIDE(1),                     // Divide value on CLKFX outputs - D - (1-32)
      .CLKFX_MULTIPLY(MULTIPLIER),          // Multiply value on CLKFX outputs - M - (2-32)
      .CLKIN_DIVIDE_BY_2("FALSE"),          // CLKIN divide by two (TRUE/FALSE)
      .CLKIN_PERIOD(31.25),                 // Input clock period specified in nS

      .CLKOUT_PHASE_SHIFT("VARIABLE"),      // Output phase shift (NONE, FIXED, VARIABLE)
      .PHASE_SHIFT(PHASE_SHIFT_CALIBRATION),                    // Amount of fixed phase shift (-255 to 255)

      .CLK_FEEDBACK("1X"),                  // Feedback source (NONE, 1X, 2X)
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      .DFS_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DLL_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DSS_MODE("NONE"),                    // Unsupported - Do not change value
      .DUTY_CYCLE_CORRECTION("TRUE"),       // Unsupported - Do not change value
      .FACTORY_JF(16'hc080),                // Unsupported - Do not change value

      .STARTUP_WAIT("FALSE")                // Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
   )
   DCM_SP_ets (
      .CLK0(ets_clk),        // 1-bit output: 0 degree clock output
      //.LOCKED(lock),       // 1-bit output: DCM_SP Lock Output
      .STATUS(status),
      .CLKFB(ets_clk),       // 1-bit input: Clock feedback input
      .CLKIN(ref_clk),       // 1-bit input: Clock input
      .DSSEN(local_gnd),     // 1-bit input: Unsupported, specify to GND.
      .PSCLK(ref_clk),       // 1-bit input: Phase shift clock input
      .PSEN(hacktick),       // 1-bit input: Phase shift enable
      .PSINCDEC(delay[0]),   // 1-bit input: Phase shift increment/decrement input
      .RST(reset)            // 1-bit input: Active high reset input
   );


  DCM_SP #(
      .CLKDV_DIVIDE(DIVISOR),                   // CLKDV divide value
                                            // (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
      .CLKFX_DIVIDE(1),                     // Divide value on CLKFX outputs - D - (1-32)
      .CLKFX_MULTIPLY(MULTIPLIER),          // Multiply value on CLKFX outputs - M - (2-32)
      .CLKIN_DIVIDE_BY_2("FALSE"),          // CLKIN divide by two (TRUE/FALSE)
      .CLKIN_PERIOD(31.25),                 // Input clock period specified in nS
      .CLKOUT_PHASE_SHIFT("FIXED"),         // Output phase shift (NONE, FIXED, VARIABLE)
      .PHASE_SHIFT(0),                      // Amount of fixed phase shift (-255 to 255)
      .CLK_FEEDBACK("1X"),                  // Feedback source (NONE, 1X, 2X)
      .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
      .DFS_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DLL_FREQUENCY_MODE("LOW"),           // Unsupported - Do not change value
      .DSS_MODE("NONE"),                    // Unsupported - Do not change value
      .DUTY_CYCLE_CORRECTION("TRUE"),       // Unsupported - Do not change value
      .FACTORY_JF(16'hc080),                // Unsupported - Do not change value
      .STARTUP_WAIT("FALSE")                // Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
   )
   DCM_SP_ref (
      .CLKFX(ref_clk),      // 1-bit output: 0 degree clock output
      .CLKFB(ref_clk),     // 1-bit input: Clock feedback input
      .CLKIN(baseclk),     // 1-bit input: Clock input
      .DSSEN(local_gnd),   // 1-bit input: Unsupported, specify to GND.
      .PSEN(local_gnd),   // 1-bit input: Unsupported, specify to GND.
      .RST(reset)            // 1-bit input: Active high reset input
   );


endmodule
