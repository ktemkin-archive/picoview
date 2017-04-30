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
    wire [31:0] sample_computation;

    // Sample computation: add the two halves of our input.
    assign sample_computation = {test_clk, clk, !clk};//dut_input[31:16] * dut_input[15:0];
    assign dut_output = sample_computation[dut_signal_select];

    DCM_SP #(
        .CLKDV_DIVIDE(2),                   // CLKDV divide value
                                              // (1.5,2,2.5,3,3.5,4,4.5,5,5.5,6,6.5,7,7.5,8,9,10,11,12,13,14,15,16).
        .CLKFX_DIVIDE(1),                     // Divide value on CLKFX outputs - D - (1-32)
        .CLKFX_MULTIPLY(4),          // Multiply value on CLKFX outputs - M - (2-32)
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
        .CLKFX(test_clk),      // 1-bit output: 0 degree clock output
        .CLKFB(test_clk),      // 1-bit input: Clock feedback input
        .CLKIN(clk),           // 1-bit input: Clock input
        .DSSEN(0),             // 1-bit input: Unsupported, specify to GND.
        .RST(0)                // 1-bit input: Active high reset input
     );

endmodule


