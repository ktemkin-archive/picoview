//
//  Simple synchronizer for SPI circuits.
//
//  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
//  This will hopefully be replaced with an FOSS license soon.
//
//  Copyright (c) Assured Information Security, inc.
//  Author: Kyle J. Temkin
//

`default_nettype none

module spi_synchronizer(
  input wire clk,
  input wire sck, sdi, cs,
  output wire sck_out, sdi_out, cs_out
);

    parameter integer SYNC_STAGES = 2;
    parameter integer SYNC_MSB = SYNC_STAGES - 1;

    reg [SYNC_MSB:0] sck_sync;
    reg [SYNC_MSB:0] sdi_sync;
    reg [SYNC_MSB:0] cs_sync;

    assign sck_out = sck_sync[SYNC_MSB];
    assign sdi_out = sdi_sync[SYNC_MSB];
    assign cs_out  =  cs_sync[SYNC_MSB];

    // Core synchronizer.
    always @(posedge clk)
    begin
        sck_sync = {sck_sync[SYNC_MSB - 1 : 0], sck};
        sdi_sync = {sdi_sync[SYNC_MSB - 1 : 0], sdi};
        cs_sync =  { cs_sync[SYNC_MSB - 1 : 0], cs};
    end

endmodule
