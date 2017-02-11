//
//  Phase-offset clock generator
//
//  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
//  This will hopefully be replaced with an FOSS license soon.
//
//  Copyright (c) Assured Information Security, inc.
//  Author: Kyle J. Temkin
//

`default_nettype none

module ets_clkgen(
    input baseclk,
    input [7:0] delay,
    output ref_clk,
    output ets_clk,
    output lock
);

  wire reset;

  // TODO: bring this signal out!
  assign reset = 1'b1;

  // Implement our PLL for testing.
  SB_PLL40_2F_PAD #(

      // Use the feedback path that contains our delay elements (fine
      // adjustment) and the quadrature phase shift (coarse adjustment).
      .FEEDBACK_PATH("PHASE_AND_DELAY"),
      .DELAY_ADJUSTMENT_MODE_FEEDBACK("DYNAMIC"),
      .DELAY_ADJUSTMENT_MODE_RELATIVE("DYNAMIC"),

      // For now, output the clock with no phase delay.
      //.PLLOUT_SELECT("GENCLK"),
      // .PLLOUT_SELECT("GENCLK_HALF"),
      //.PLLOUT_SELECT("SHIFTREG_90deg"),
      .PLLOUT_SELECT_PORTA("SHIFTREG_0deg"),
      .PLLOUT_SELECT_PORTB("SHIFTREG_0deg"),

      .FDA_FEEDBACK(4'b0),
      .FDA_RELATIVE(4'b0),

      // Scale the PLL output to unity.
      .DIVR(4'b0000),
      .DIVF(7'b0000000),
      .DIVQ(3'b011),
      .FILTER_RANGE(3'b101),

      // TODO: Support power gating of the system.
      .ENABLE_ICEGATE_PORTA(1'b0),
      .ENABLE_ICEGATE_PORTB(1'b0),

      // Don't enable the testing SPI interface.
      .TEST_MODE(1'b0)
    ) delayed (
      .PACKAGEPIN     (baseclk),
      .PLLOUTGLOBALA  (ref_clk),
      .PLLOUTGLOBALB  (ets_clk),

      //.REFERENCECLK   (baseclk),
      //.PLLOUTCOREA    (ref_clk),
      //.PLLOUTCOREB    (ets_clk),

      .DYNAMICDELAY   (delay),
      .RESETB         (reset),
      .LOCK           (lock)
    );


endmodule
