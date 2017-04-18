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

module picoview(
    input wire baseclk,

    // SPI interface for communcation with the RPi
    input wire sck_async, sdi_async, cs_async,
    output wire sdo,

    output wire [2:0] leds,

    // Debug outputs
    output wire ets_clk, clk_out
);

    localparam DEVICE_ID = 32'hC001CAFE;

    // Register number definitions
    localparam REG_CONTROL        = 0;
    localparam REG_RESULT         = 1;
    localparam REG_SIGNAL_INDEX   = 2;
    localparam REG_TIMING_CONTROL = 3;
    localparam REG_ITER_COUNT     = 4;
    localparam REG_PRE_INPUT      = 5;
    localparam REG_POST_INPUT     = 6;
    localparam NUM_REGS           = 7;

    // These aren't real registers, and thus aren't counted in NUM_REGS.
    localparam REG_ID             = 7'b1111111;

    // Bits of the control register
    localparam CONTROL_BIT_RUN    = 0;
    localparam CONTROL_BIT_STATUS = 1;

    wire sck, sdi, cs, command_ready, word_rx_complete;
    reg [31:0] word_to_output;
    wire [31:0] word_received;

    reg request_run;
    wire result_ready;
    wire test_running;
    wire [31:0] test_result;

    // Command control...
    wire [7:0] command;
    wire is_write;
    wire [6:0] target_register;

    // Data registers.
    reg [31:0] registers[NUM_REGS-1:1];

    // Alias the command register to its component parts.
    assign is_write        = command[7];
    assign target_register = command[6:0];

    wire clk;
    wire locked;

    // Create our main system clock.
    ets_clkgen clkgen(baseclk, registers[REG_TIMING_CONTROL], clk, ets_clk, locked);
    assign clk_out = clk;

    // Bring the SPI signals into our clock domain.
    spi_synchronizer main_sync (clk, sck_async, sdi_async, cs_async, sck, sdi, cs);

    // Instantiate a simple SPI reciever.
    simple_spi transceiver(clk, word_to_output, word_received, command,
        command_ready, word_rx_complete, sck, sdi, cs, sdo);

    // Instatiate the picoview ETS sampling core.
    offset_sampler dut (
        .clk                      (clk),
        .ets_clk                  (ets_clk),
        .request_run              (request_run),
        .pre_value                (registers[REG_PRE_INPUT]),
        .post_value               (registers[REG_POST_INPUT]),
        .dut_signal_select        (registers[REG_SIGNAL_INDEX]),
        .total_cycles             (registers[REG_ITER_COUNT]),
        .result_ready             (result_ready),
        .running                  (test_running),
        .result                   (test_result)
    );

    // Manage register interactions.
    always @(posedge clk) begin

        // Assume any per-cycle control instructions are zero
        // unless explicitly asserted.
        request_run <= 0;

        // If we've just received a new command, update our knowldegde of
        // the current command, and read back the current register.
        if (command_ready) begin
            case(target_register)

                // If the user has requested the control/status register,
                // compose a value from the current status.
                REG_CONTROL: begin
                    word_to_output <= {test_running, 0};
                end

                // If the user has requested the result resiger, respond
                // back with the last result.
                REG_RESULT: begin
                    word_to_output <= test_result;
                end

                // If the user has requested the device's ID, return
                // it.
                REG_ID: begin
                    word_to_output <= DEVICE_ID;
                end

                // For all other registers, perform a trivial read.
                default: begin
                    word_to_output <= registers[target_register];
                end

            endcase
        end

        // If we've just received a _write_ command, use its data.
        if (word_rx_complete && is_write) begin

            case(target_register)

                // If we're writing to the control register, apply any
                // event inputs provided to us.
                REG_CONTROL: begin
                    request_run <= word_received[CONTROL_BIT_RUN];
                end

                // Ignore writes to the "result" register.
                REG_RESULT:;

                // Ignore writes to the "ID" psuedo-register.
                REG_ID:;

                // For all other registers, use simple write semantics.
                default: begin
                    registers[target_register] <=  word_received;
                end

            endcase
        end
    end

    //
    // Diagnostic displays
    //
    assign leds[0] = test_running;
    assign leds[1] = locked;
    assign leds[2] = sck;

endmodule
