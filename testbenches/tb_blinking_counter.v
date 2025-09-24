// Testbench for Blinking Counter
// This testbench generates clock and reset signals to test our blinking counter
// It will run for enough cycles to see the blink signal toggle

`timescale 1ns/1ps

module tb_blinking_counter;

    // Testbench signals
    reg clk;
    reg reset_n;
    wire [7:0] counter;
    wire blink;
    
    // Instantiate the Device Under Test (DUT)
    blinking_counter dut (
        .clk(clk),
        .reset_n(reset_n),
        .counter(counter),
        .blink(blink)
    );
    
    // Clock generation - 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // Toggle every 5ns
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        reset_n = 0;
        
        // Wait for a few clock cycles in reset
        #20;
        
        // Release reset
        reset_n = 1;
        
        // Run simulation for enough time to see blink toggle
        // Counter goes 0-255, so blink toggles every 128 cycles
        // Let's run for 300 cycles to see multiple toggles
        #3000;
        
        // Display final results
        $display("Simulation completed!");
        $display("Final counter value: %d", counter);
        $display("Final blink state: %b", blink);
        
        // End simulation
        $finish;
    end
    
    // Monitor changes for debugging
    initial begin
        $monitor("Time: %0t | Reset: %b | Counter: %3d | Blink: %b", 
                 $time, reset_n, counter, blink);
    end
    
    // Generate VCD file for GTKWave
    initial begin
        $dumpfile("blinking_counter.vcd");
        $dumpvars(0, tb_blinking_counter);
    end

endmodule
