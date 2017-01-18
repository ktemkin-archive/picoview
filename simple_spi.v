//
//  Simple barebones SPI command interfaces for PicoView testing.
//
//  UNCLASSIFIED // PROPRIETARY // GOV USE RIGHTS
//  This will hopefully be replaced with an FOSS license soon.
//
//  Copyright (c) Assured Information Security, inc.
//  Author: Kyle J. Temkin
//

`default_nettype none

module simple_spi(
    input clk,

    // Control interface
    input [WORD_SIZE:0] word_to_output,
    output reg [WORD_SIZE - 1:0] word_received,
    output reg [COMMAND_SIZE - 1:0] command,
    output reg command_ready,
    output reg word_rx_complete,

    // SPI
    input sck, sdi, cs,
    output reg sdo
);

    // Word size.
    parameter WORD_SIZE    = 32;
    parameter COMMAND_SIZE = 8;

    // State encoding.
    parameter STATE_RESET  = 6'b000000;
    parameter STATE_WAIT   = 6'b100000;
    parameter STATE_CMD    = 6'b010000;
    parameter STATE_STAGE1 = 6'b001000;
    parameter STATE_STAGE2 = 6'b000100;
    parameter STATE_DATA   = 6'b000010;
    parameter STATE_STALL  = 6'b000001;

    wire sck_rising_edge;
    reg  sck_last_cycle;

    // Counter for the total bits observed in the current command.
    reg [5:0] bit_count;
    reg clear_bit_count, increment_bit_count;

    // Command and staging registers register.
    reg [31:0] current_word;
    reg [7:0] current_command;

    // Control FSM signals.
    reg [5:0] state;

    //
    // Initialization (for simulation and non-lattice platforms)
    //
    initial begin
        state <= STATE_RESET;
    end

    //
    // Datapath
    //

    // Rising edge detector for SC.
    always @(posedge clk) begin
        sck_last_cycle <= sck;
    end

    assign sck_rising_edge = (!sck_last_cycle) & (sck);

    // SCK edge counter
    always @(posedge clk) begin
    if (clear_bit_count == 1)
        bit_count <= 0;
    else if(increment_bit_count == 1)
        bit_count <= bit_count + 1;
    end

    //
    // Control
    //
    always @(posedge clk) begin

        // Default our control signals to unasserted.
        clear_bit_count     <= 0;
        increment_bit_count <= 0;
        command_ready       <= 0;
        word_rx_complete    <= 0;

        case(state)
            // By default, start off in the "STALL" state
            // to prevent interaction with a half-executed transaction.
            STATE_RESET: begin
                state <= STATE_STALL;
            end

            // The stall state is entered when CS is low, but we can't handle new
            // bits (e.g. we were receiveing it as the device started up, or we've
            // recieved more than a command + a word.
            STATE_STALL: begin
                if (cs == 1)
                  state <= STATE_WAIT;
            end

            // The wait state is the state where we idle while the chip isn't
            // actively selected. We wait here for a new transaciton, doing nothing,
            // until CS goes low.
            STATE_WAIT: begin
                clear_bit_count <= 1;

                if (cs == 0)
                    state <= STATE_CMD;
            end

            // Once CS has gone low, we shift in our command byte.
            STATE_CMD: begin
                sdo <= 0;

                if (bit_count < COMMAND_SIZE) begin

                    // Shift in our command bits.
                    if (sck_rising_edge == 1) begin
                        increment_bit_count <= 1;
                        current_command <= {current_command, sdi};
                    end
                end
                else begin
                    state <= STATE_STAGE1;
                    command_ready <= 1;
                    command <= current_command;
                end
            end

            // Wait state that allows the external controller to get data
            // ready for us.
            STATE_STAGE1: begin
                state <= STATE_STAGE2;
            end

            // Allow the external controller to stage a response, if desired.
            STATE_STAGE2: begin
                current_word <= word_to_output;
                state <= STATE_DATA;
            end

            // Once we've recieved a command byte, we recieve a 32-bit data word
            // and shift in/out the current word.
            STATE_DATA: begin
                sdo <= current_word[WORD_SIZE - 1];

                if (bit_count < (COMMAND_SIZE + WORD_SIZE)) begin

                    // Shift in our command bits.
                    if (sck_rising_edge == 1) begin
                        increment_bit_count <= 1;
                        current_word <= {current_word, sdi};
                    end
                end
                else begin
                    state <= STATE_STALL;
                    word_received <= current_word;
                    word_rx_complete <= 1;
                end
            end

        endcase
    end

// Establish initial conditions for simulation.
`ifdef COCOTB_SIM
    initial begin
        $dumpfile ("simple_spi.vcd");
        $dumpvars;
        #1;
    end
`endif


endmodule
