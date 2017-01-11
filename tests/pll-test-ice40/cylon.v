`default_nettype none

`define LEFT  0
`define RIGHT 1

module cylon(
    input clk,

    // The output of the cyclon eyes.
    output [7:0] leds
);

    reg [17:0] slow_count;

    reg direction = 1'b0;
    reg [7:0] eyes = 8'b1;

    // Always display the cyclon eye on the LEDs.
    assign leds = eyes;

    // Shift the cyclon eyes on each tick of the slower clock.
    always @(posedge clk) begin

        slow_count = slow_count + 1;

        // If the slower clock has reached a high value, 
        if (slow_count == 0) begin

            if (direction == `LEFT) begin
                if (eyes[7] == 1) begin
                  direction = `RIGHT;
                end
                else begin
                  eyes = eyes << 1;
                end
            end
            else begin
                if (eyes[0] == 1) begin
                  direction = `LEFT;
                end
                else begin
                  eyes = eyes >> 1;
                end
            end
        end

    end


endmodule
