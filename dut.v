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
    input [31:0] dut_input,
    input [31:0] dut_signal_select,

    output dut_output
);

    wire [31:0] sample_computation;

    // Sample computation: add the two halves of our input.
    assign sample_computation = dut_input[31:16] + dut_input[15:0];
    assign dut_output = sample_computation[dut_signal_select];

endmodule


