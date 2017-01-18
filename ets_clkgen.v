//
//  Text fixture for the Simple SPI interface on the raspi.
//
//  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
//  This will hopefully be replaced with an FOSS license soon.
//
//  Copyright (c) Assured Information Security, inc.
//  Author: Kyle J. Temkin
//

`default_nettype none

module ets_clkgen(
    input clk,
    input [7:0] delay,
    output ets_clk
);

  wire reset;

  // TODO: bring this signal out!
  assign reset = 1'b1;

  // Implement our PLL for testing.
  SB_PLL40_CORE #(

      // Use the feedback path that contains our delay elements (fine
      // adjustment) and the quadrature phase shift (coarse adjustment).
      .FEEDBACK_PATH("PHASE_AND_DELAY"),
      .DELAY_ADJUSTMENT_MODE_FEEDBACK("DYNAMIC"),
      .DELAY_ADJUSTMENT_MODE_RELATIVE("DYNAMIC"),

      // For now, output the clock with no phase delay.
      //.PLLOUT_SELECT("GENCLK"),
      // .PLLOUT_SELECT("GENCLK_HALF"),
      // .PLLOUT_SELECT("SHIFTREG_90deg"),
      .PLLOUT_SELECT("SHIFTREG_0deg"),

      .FDA_FEEDBACK(4'b1111),
      .FDA_RELATIVE(4'b1111),

      // Scale the PLL output to 200MHz, assuming a 100MHz input clock.
      .DIVR(4'b0000),
      .DIVF(7'b0000001),
      .DIVQ(3'b010),
      .FILTER_RANGE(3'b101),

      // TODO: Supoport power gating of the system.
      .ENABLE_ICEGATE(1'b0),

      // Don't enable the testing SPI interface.
      .TEST_MODE(1'b0)
    ) delayed (
      .REFERENCECLK   (clk),
      .PLLOUTCORE     (ets_clk),
      .DYNAMICDELAY   (delay),
      .RESETB         (reset),
    );


endmodule
