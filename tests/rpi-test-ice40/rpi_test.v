`default_nettype none

module rpi_test(
  input clk,
  input sck_async, sdi_async, cs_async,
  output sdo,
  output [2:0] leds
);

  wire sck, sdi, cs;

  wire sck_rising_edge;
  reg  sck_last_cycle;

  // Counter for the total bits observed in the current command.
  reg [5:0] bit_count;
  reg clear_bit_count, increment_bit_count;

  // Command and staging registers register.
  reg [7:0] command;
  reg [31:0] current_word;


  //
  // Datapath
  //

  // Bring the SPI signals into our clock domain.
  spi_synchronizer main_sync (clk, sck_async, sdi_async, cs_async, sck, sdi, cs);

  // Rising edge detector for SC.
  always @(posedge clk)
    sck_last_cycle <= sck;
  assign sck_rising_edge = (!sck_last_cycle) & (sck);

  // SCK edge counter
  always @(posedge clk)
  begin
    if (clear_bit_count == 1)
        bit_count <= 0;
    else if(increment_bit_count == 1)
        bit_count <= bit_count + 1;
  end





  //
  // Control
  //



endmodule
