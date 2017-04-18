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
    input wire baseclk,
    input wire [7:0] delay,
    output wire ref_clk,
    output wire ets_clk,
    output wire lock
);

	// XXX IMPLEMENT ME XXX
	assign ets_clk = baseclk;
	assign ref_clk = baseclk;


endmodule
