//
//  Sample combinational logic "device under test".
//
//  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
//  This will hopefully be replaced with an FOSS license soon.
//
//  Copyright (c) Assured Information Security, inc.
//  Author: Kyle J. Temkin
//

`default_nettype none

module dut(
    // XXX: Do not use clk-- you should only be testing combinational logic here!
    input wire clk,

    input wire [31:0] dut_input,
    input wire [31:0] dut_signal_select,

    output wire dut_output
);

    wire test_clk;
    reg [31:0] sample_computation;

    // Sample computation: add the two halves of our input.
    // Put the design you want to test here!
    assign dut_output = sample_computation[dut_signal_select];

    // With simple "hardware trojan".
    always @(*) begin
      if (dut_input == 32'hDEADBEEF)
          sample_computation <= 32'hDEADBEEF;
      else
          sample_computation <= dut_input[31:16] + dut_input[15:0];
    end


endmodule


