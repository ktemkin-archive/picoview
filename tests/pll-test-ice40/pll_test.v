`default_nettype none

module pll_test(
    input clk,
    input [7:0] delay,
    output clk_delayed,
    output clk_passthrough,
    output [7:0] led
);

  wire reset;

  // Keep the PLL out of reset...
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

      // Scale the PLL output to 204MHz, assuming a 12MHz input clock.
      .DIVR(4'b0000),
      .DIVF(7'b0010000),
      .DIVQ(3'b010),
      .FILTER_RANGE(3'b001),

      // Don't set up clock gating-- we don't need the savings on this test.
      .ENABLE_ICEGATE(1'b0),

      // Don't enable the testing SPI interface.
      .TEST_MODE(1'b0)
    ) delayed (
      .REFERENCECLK   (clk),
      .PLLOUTCORE     (clk_delayed),
      .DYNAMICDELAY   (delay),
      .RESETB         (reset),
    );


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

      // Scale the PLL output to 204MHz, assuming a 12MHz input clock.
      .DIVR(4'b0000),
      .DIVF(7'b0010000),
      .DIVQ(3'b010),
      .FILTER_RANGE(3'b001),

      // Don't set up clock gating-- we don't need the savings on this test.
      .ENABLE_ICEGATE(1'b0),

      // Don't enable the testing SPI interface.
      .TEST_MODE(1'b0)
    )  reference (
      .REFERENCECLK   (clk),
      .PLLOUTCORE     (clk_passthrough),
      .DYNAMICDELAY   (8'b0),
      .RESETB         (reset),
    );

    // Display our test pattern to the LEDs.
    cylon eyes (clk, led);


endmodule
