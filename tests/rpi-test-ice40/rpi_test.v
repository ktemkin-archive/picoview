module pll_test(
  input [7:0] gpio,
  output [7:0] led
);

  // Simple hack used to test the RPi-Lattice board GPIO connections
  // for the R0 (pre-icoboard).
  assign led = gpio;

endmodule
