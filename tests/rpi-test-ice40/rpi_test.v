//
//  Text fixture for the Simple SPI interface on the raspi.
//
//  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
//  This will hopefully be replaced with an FOSS license soon.
//
//  Copyright (c) Assured Information Security, inc.
//  Author: Kyle J. Temkin
//

`default_nettype none

module rpi_test(
  input clk,
  input sck_async, sdi_async, cs_async,
  output sdo,
  output [2:0] leds,

  // Debug outputs
  output mirror_sck, mirror_sdi, mirror_sdo, mirror_cs
);

    wire sck, sdi, cs, command_ready, word_rx_complete;
    wire [31:0] word_to_output;
    wire [31:0] word_received;
    wire [7:0] command;

    reg [31:0] r0;

    // Bring the SPI signals into our clock domain.
    spi_synchronizer main_sync (clk, sck_async, sdi_async, cs_async, sck, sdi, cs);

    // Instantiate a simple SPI reciever.
    simple_spi transceiver(clk, word_to_output, word_received, command,
        command_ready, word_rx_complete, sck, sdi, cs, sdo);

    // Test circuit behavior
    //  cmd 0 -- read the word in R0
    //  cmd 1 -- write a word to R0
    //  cmd 2 -- read the inverse of R0

    // Drive the word to be output.
    always @(*) begin
        if ((command == 0) || (command == 1))
            word_to_output = r0;
        else if(command == 2)
            word_to_output = ~r0;
        else
            word_to_output = 32'hDEADBEEF;
    end

    always @(posedge clk) begin
        if ((command == 1) && (word_rx_complete))
            r0 <= word_received;
    end

    //Debug outputs
    assign mirror_sck = sck;
    assign mirror_sdi = sdi;
    assign mirror_sdo = sdo;
    assign mirror_cs  = cs;
endmodule
