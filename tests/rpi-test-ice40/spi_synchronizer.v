
module spi_synchronizer(
  input clk,
  input sck, sdi, cs,
  output sck_out, sdi_out, cs_out,
);

    parameter integer SYNC_STAGES = 2;
    parameter integer SYNC_MSB = SYNC_STAGES - 1;

    reg [SYNC_MSB:0] sck_sync;
    reg [SYNC_MSB:0] sdi_sync;
    reg [SYNC_MSB:0] cs_sync;

    assign sck_out = sck_sync[SYNC_MSB];
    assign sdi     = sdi_sync[SYNC_MSB];
    assign cs      =  cs_sync[SYNC_MSB];

    // Core synchronizer.
    always @(posedge clk)
    begin
        sck_sync = {sck_sync[SYNC_BITS - 1 : 0], sck};
        sdi_sync = {sdo_sync[SYNC_BITS - 1 : 0], sdi};
        cs_sync =  { cs_sync[SYNC_BITS - 1 : 0], cs};
    end

endmodule
