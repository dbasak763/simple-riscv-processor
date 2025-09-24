// Blinking Counter - Hello World Verilog Module
// This is a simple 8-bit counter that increments on each clock cycle
// Perfect for demonstrating basic Verilog simulation and waveform generation

module blinking_counter (
    input wire clk,           // Clock input
    input wire reset_n,       // Active-low reset
    output reg [7:0] counter, // 8-bit counter output
    output wire blink         // Blink signal (MSB of counter)
);

    // Counter logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 8'b0;  // Reset counter to 0
        end else begin
            counter <= counter + 1;  // Increment counter
        end
    end
    
    // Blink output is the MSB of the counter
    // This creates a blinking pattern that toggles every 128 clock cycles
    assign blink = counter[7];

endmodule
