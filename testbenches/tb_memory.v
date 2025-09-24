// Testbench for Memory module
// Tests read/write operations, byte enable functionality, and address handling

`timescale 1ns/1ps

module tb_memory;

    // Testbench signals
    reg clk, reset_n;
    reg [31:0] addr, write_data;
    reg mem_read, mem_write;
    reg [3:0] byte_enable;
    wire [31:0] read_data;
    wire ready;
    
    // Test tracking
    integer test_count = 0;
    integer pass_count = 0;
    
    // Instantiate memory module
    memory dut (
        .clk(clk),
        .reset_n(reset_n),
        .addr(addr),
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .byte_enable(byte_enable),
        .read_data(read_data),
        .ready(ready)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end
    
    // Task to check memory read
    task check_read;
        input [31:0] address;
        input [31:0] expected_data;
        input [8*30:1] test_name;
        begin
            test_count = test_count + 1;
            addr = address;
            mem_read = 1'b1;
            mem_write = 1'b0;
            @(posedge clk);
            #1; // Small delay for signals to settle
            
            if (read_data === expected_data && ready === 1'b1) begin
                $display("✅ PASS: %s", test_name);
                $display("   Read addr=%h -> data=%h", address, read_data);
                pass_count = pass_count + 1;
            end else begin
                $display("❌ FAIL: %s", test_name);
                $display("   Address: %h", address);
                $display("   Expected: data=%h, ready=1", expected_data);
                $display("   Got:      data=%h, ready=%b", read_data, ready);
            end
            
            mem_read = 1'b0;
            #1;
            $display("");
        end
    endtask
    
    // Task to write to memory
    task write_memory;
        input [31:0] address;
        input [31:0] data;
        input [3:0] be;
        begin
            addr = address;
            write_data = data;
            byte_enable = be;
            mem_read = 1'b0;
            mem_write = 1'b1;
            @(posedge clk);
            #1; // Allow write to complete
            mem_write = 1'b0;
            #1;
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("=== Memory Testbench Starting ===");
        $display("");
        
        // Initialize signals
        reset_n = 1'b0;
        addr = 32'h0;
        write_data = 32'h0;
        mem_read = 1'b0;
        mem_write = 1'b0;
        byte_enable = 4'b0000;
        
        // Reset sequence
        #50;
        reset_n = 1'b1;
        #20;
        
        // Test 1: Check that memory is zero after reset
        $display("--- Testing Reset Behavior ---");
        check_read(32'h00000000, 32'h00000000, "Reset: addr 0x00 should be zero");
        check_read(32'h00000100, 32'h00000000, "Reset: addr 0x100 should be zero");
        
        // Test 2: Basic word write/read
        $display("--- Testing Word Write/Read ---");
        write_memory(32'h00000000, 32'h12345678, 4'b1111);
        check_read(32'h00000000, 32'h12345678, "Word write/read at addr 0x00");
        
        write_memory(32'h00000004, 32'hDEADBEEF, 4'b1111);
        check_read(32'h00000004, 32'hDEADBEEF, "Word write/read at addr 0x04");
        
        // Test 3: Byte enable functionality
        $display("--- Testing Byte Enable ---");
        write_memory(32'h00000008, 32'h00000000, 4'b1111); // Clear first
        write_memory(32'h00000008, 32'hAABBCCDD, 4'b0001); // Write only byte 0
        check_read(32'h00000008, 32'h000000DD, "Byte enable [0] only");
        
        write_memory(32'h00000008, 32'hAABBCCDD, 4'b0010); // Write only byte 1
        check_read(32'h00000008, 32'h0000CCDD, "Byte enable [1] added");
        
        write_memory(32'h00000008, 32'hAABBCCDD, 4'b1100); // Write bytes 2,3
        check_read(32'h00000008, 32'hAABBCCDD, "Byte enable [3:2] added");
        
        // Test 4: Different addresses
        $display("--- Testing Address Decoding ---");
        write_memory(32'h00000010, 32'h11111111, 4'b1111);
        write_memory(32'h00000020, 32'h22222222, 4'b1111);
        write_memory(32'h00000030, 32'h33333333, 4'b1111);
        
        check_read(32'h00000010, 32'h11111111, "Address 0x10");
        check_read(32'h00000020, 32'h22222222, "Address 0x20");
        check_read(32'h00000030, 32'h33333333, "Address 0x30");
        
        // Test 5: Word alignment (addresses should be word-aligned)
        $display("--- Testing Word Alignment ---");
        write_memory(32'h00000040, 32'hABCDEF00, 4'b1111);
        check_read(32'h00000040, 32'hABCDEF00, "Aligned addr 0x40");
        check_read(32'h00000041, 32'hABCDEF00, "Unaligned 0x41 -> same word");
        check_read(32'h00000042, 32'hABCDEF00, "Unaligned 0x42 -> same word");
        check_read(32'h00000043, 32'hABCDEF00, "Unaligned 0x43 -> same word");
        
        // Test 6: Memory boundaries
        $display("--- Testing Memory Boundaries ---");
        write_memory(32'h000003FC, 32'hFFFFFFFF, 4'b1111); // Last word
        check_read(32'h000003FC, 32'hFFFFFFFF, "Last memory location");
        
        // Test 7: Overwrite existing data
        $display("--- Testing Data Overwrite ---");
        write_memory(32'h00000000, 32'h4E455756, 4'b1111);
        check_read(32'h00000000, 32'h4E455756, "Overwrite previous data");
        
        // Test 8: Partial byte writes
        $display("--- Testing Partial Byte Writes ---");
        write_memory(32'h00000050, 32'h00000000, 4'b1111); // Clear
        write_memory(32'h00000050, 32'hFF000000, 4'b1000); // Write byte 3 only
        check_read(32'h00000050, 32'hFF000000, "Byte 3 write only");
        
        write_memory(32'h00000050, 32'h00FF0000, 4'b0100); // Write byte 2 only
        check_read(32'h00000050, 32'hFFFF0000, "Byte 2 added");
        
        // Test Summary
        $display("=== Memory Test Summary ===");
        $display("Total tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", test_count - pass_count);
        
        if (pass_count == test_count) begin
            $display("🎉 ALL TESTS PASSED! Memory module is working correctly.");
        end else begin
            $display("❌ Some tests failed. Please review the Memory implementation.");
        end
        
        $finish;
    end
    
    // Generate VCD file for waveform analysis
    initial begin
        $dumpfile("memory_test.vcd");
        $dumpvars(0, tb_memory);
    end

endmodule
