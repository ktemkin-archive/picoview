//
//  Mock of the phase-offeset clock generator for testing
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

    // For testing, we won't actually simulate a controllable delay.
    // If that becomes desireable, we can convert this to a process.
    //
    // For now, just hardcode a 180-degree phase shift just so we don't have
    // the ETS and main-clk in phase.
    assign ets_clk = ~clk;

endmodule
