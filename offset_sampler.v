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

module offset_sampler(
    input clk,
    input request_run,

    // Input charactersitics
    input [31:0] pre_value,
    input [31:0] post_value,

    // Timing characteristics
    input [31:0] delay_characteristics_in,
    input [31:0] dut_signal_select,
    input [31:0] total_cycles,

    // Output
    output reg running,
    output reg result_ready,
    output reg [31:0] result
);

    // Define our FSM states.
    localparam STATE_RESET   = 8'b00000000;
    localparam STATE_WAIT    = 8'b00000001;
    localparam STATE_PREPARE = 8'b00000010;
    localparam STATE_PRIME   = 8'b00000100;
    localparam STATE_SAMPLE  = 8'b00001000;
    localparam STATE_COUNT   = 8'b00010000;
    localparam STATE_BUBBLE1 = 8'b00100000;
    localparam STATE_BUBBLE2 = 8'b01000000;
    localparam STATE_OUTPUT  = 8'b10000000;
    reg [7:0] state;


    // Latched version of our inputs.
    reg [31:0] delay_characteristics;

    // I/O for the device under test.
    reg dut_load_pre;
    reg dut_load_post;
    reg [31:0] dut_input_buffer;
    wire dut_output;

    // !!! Signals in the ETS clock domain.
    wire ets_clk;
    reg ets_offset_sample;
    reg [1:0] sample_request_synchronizer;
    // </ets-domain>

    reg count_sample;
    reg [1:0] sample_synchronizer;

    // The number of ones observed on the output sample.
    reg clear_one_count;
    reg increment_one_count;
    reg [31:0] one_count;

    // The number of test iterations that have been performed thus far.
    reg clear_iter_count;
    reg increment_iter_count;
    reg [31:0] iter_count;

    // Generate the clock to be used for offset sampling.
    ets_clkgen clkgen(clk, delay_characteristics, ets_clk);

    //
    // Datapath
    //

    assign running = (state != STATE_WAIT);

    // Input register for the DUT.
    always @(posedge clk) begin
        if (dut_load_pre)
            dut_input_buffer <= pre_value;
        else if (dut_load_post)
            dut_input_buffer <= post_value;
    end

    // Core device under test.
    dut sample_dut (dut_input_buffer, dut_signal_select, dut_output);

    // Offset sampling register for the DUT output.
    always @(posedge ets_clk)
        ets_offset_sample <= dut_output;

    // Synchronizer to bring ETS-domain samples back into the main clock domain.
    always @(posedge clk)
        sample_synchronizer <= {sample_synchronizer[0], ets_offset_sample};


    // One-counter for the captured ETS results.
    // Counts the total number of post-synchronized samples that are '1'
    // when count_sample is high.
    always @(posedge clk) begin
        if (clear_one_count)
            one_count <= 0;
        else if (sample_synchronizer[1] && count_sample)
            one_count <= one_count + 1;
    end

    // Iteration counter
    always @(posedge clk) begin
        if (clear_iter_count)
            iter_count <= 0;
        else if(increment_iter_count)
            iter_count <= iter_count + 1;
    end

    //
    // Control
    //
    always @(posedge clk) begin

        // Default our control signals to unasserted.
        dut_load_pre         <= 0;
        dut_load_post        <= 0;
        clear_one_count      <= 0;
        result_ready         <= 0;
        clear_iter_count     <= 0;
        increment_iter_count <= 0;
        count_sample         <= 0;

        case(state)

            // On reset, wait for the run signal to be asserted.
            STATE_RESET: begin
                state <= STATE_WAIT;
            end

            // Don't perform any tests until the run signal has been asserted.
            STATE_WAIT: begin
                clear_one_count <= 1;
                clear_iter_count <= 1;

                if (request_run)
                    state <= STATE_PREPARE;
            end

            // Prepare state: prepare the test by applying the "before" input
            // value to the DUT inputs.
            STATE_PREPARE: begin
                dut_load_pre <= 1;
                state <= STATE_PRIME;

            end

            // Prime state: prime the test by the post-clock stimulus.
            STATE_PRIME: begin
                dut_load_post <= 1;
                state <= STATE_SAMPLE;
            end

            // Sample state-- give the circuit time to sample.
            STATE_SAMPLE: begin
                increment_iter_count <= 1;
                state <= STATE_BUBBLE1;
            end

            // Bubble state: wait for the sample result to synchronize
            // back to our clock domain.
            STATE_BUBBLE1: begin
                state <= STATE_BUBBLE2;
            end

            // Bubble state: wait for the sample result to synchronize
            // back to our clock domain.
            STATE_BUBBLE2: begin
                state <= STATE_COUNT;
            end

            // Count state: tally the synchronized result.
            STATE_COUNT: begin
                count_sample <= 1;

                // If we've completed our run, move to the output state.
                // Otherwise, continue to another iteration.
                if (iter_count >= total_cycles)
                    state <= STATE_OUTPUT;
                else
                    state <= STATE_PREPARE;
            end

            // Output state: output the value achieved during this run.
            STATE_OUTPUT: begin
                result_ready <= 1;
                result <= one_count;
                state <= STATE_WAIT;
            end
        endcase
    end
endmodule
