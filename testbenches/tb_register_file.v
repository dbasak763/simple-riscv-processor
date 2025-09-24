// Testbench for Register File module
// Tests dual read ports, write functionality, and x0 hardwired zero

`timescale 1ns/1ps

module tb_register_file;

    // Testbench signals
    reg clk, reset_n;
    reg [4:0] rs1_addr, rs2_addr, rd_addr;
    reg [31:0] rd_data;
    reg wr_enable;
    wire [31:0] rs1_data, rs2_data;
    
    // Test tracking
    integer test_count = 0;
    integer pass_count = 0;
    integer j, k, errors;
    
    // Instantiate register file
    register_file dut (
        .clk(clk),
        .reset_n(reset_n),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_addr(rd_addr),
        .rd_data(rd_data),
        .wr_enable(wr_enable)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns period
    end
    
    // Task to check register read
    task check_read;
        input [4:0] addr1, addr2;
        input [31:0] expected1, expected2;
        input [8*30:1] test_name;
        begin
            test_count = test_count + 1;
            rs1_addr = addr1;
            rs2_addr = addr2;
            #1; // Small delay for combinational logic
            
            if (rs1_data === expected1 && rs2_data === expected2) begin
                $display("✅ PASS: %s", test_name);
                $display("   Read x%0d=%h, x%0d=%h", addr1, rs1_data, addr2, rs2_data);
                pass_count = pass_count + 1;
            end else begin
                $display("❌ FAIL: %s", test_name);
                $display("   Expected: x%0d=%h, x%0d=%h", addr1, expected1, addr2, expected2);
                $display("   Got:      x%0d=%h, x%0d=%h", addr1, rs1_data, addr2, rs2_data);
            end
            $display("");
        end
    endtask
    
    // Task to write to register
    task write_register;
        input [4:0] addr;
        input [31:0] data;
        begin
            rd_addr = addr;
            rd_data = data;
            wr_enable = 1'b1;
            #10; // Wait for clock edge
            wr_enable = 1'b0;
            #10; // Allow write to complete
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("=== Register File Testbench Starting ===");
        $display("");
        
        // Initialize signals
        reset_n = 1'b0;
        rs1_addr = 5'h0;
        rs2_addr = 5'h0;
        rd_addr = 5'h0;
        rd_data = 32'h0;
        wr_enable = 1'b0;
        
        // Reset sequence
        #50;
        reset_n = 1'b1;
        #20;
        
        // Test 1: Check that all registers are zero after reset
        $display("--- Testing Reset Behavior ---");
        check_read(5'h0, 5'h1, 32'h0, 32'h0, "Reset: x0 and x1 should be zero");
        check_read(5'h1F, 5'h1E, 32'h0, 32'h0, "Reset: x31 and x30 should be zero");
        
        // Test 2: Write to various registers and read back
        $display("--- Testing Write/Read Operations ---");
        write_register(5'h1, 32'h12345678);
        check_read(5'h1, 5'h0, 32'h12345678, 32'h0, "Write x1=0x12345678");
        
        write_register(5'h2, 32'hDEADBEEF);
        check_read(5'h2, 5'h1, 32'hDEADBEEF, 32'h12345678, "Write x2=0xDEADBEEF");
        
        write_register(5'h1F, 32'hCAFEBABE);
        check_read(5'h1F, 5'h2, 32'hCAFEBABE, 32'hDEADBEEF, "Write x31=0xCAFEBABE");
        
        // Test 3: Verify x0 is always zero (hardwired)
        $display("--- Testing x0 Hardwired Zero ---");
        write_register(5'h0, 32'hFFFFFFFF);
        check_read(5'h0, 5'h1, 32'h0, 32'h12345678, "x0 should remain zero after write");
        
        // Test 4: Test dual read ports with same address
        $display("--- Testing Dual Read Ports ---");
        check_read(5'h1, 5'h1, 32'h12345678, 32'h12345678, "Dual read same register");
        
        // Test 5: Write and read in same cycle
        $display("--- Testing Write/Read Timing ---");
        write_register(5'h3, 32'h87654321);
        check_read(5'h3, 5'h2, 32'h87654321, 32'hDEADBEEF, "Immediate read after write");
        
        // Test 6: Write enable functionality
        $display("--- Testing Write Enable ---");
        rd_addr = 5'h4;
        rd_data = 32'hABCDEF00;
        wr_enable = 1'b0;  // Write disabled
        @(posedge clk);
        check_read(5'h4, 5'h0, 32'h0, 32'h0, "Write disabled - x4 should remain zero");
        
        // Test 7: Overwrite existing register
        $display("--- Testing Register Overwrite ---");
        write_register(5'h1, 32'h11111111);
        check_read(5'h1, 5'h2, 32'h11111111, 32'hDEADBEEF, "Overwrite x1 with new value");
        
        // Test 8: Test all register addresses
        $display("--- Testing All Register Addresses ---");
        // Write unique pattern to each register
        for (j = 1; j < 32; j = j + 1) begin
            write_register(j[4:0], 32'h1000_0000 | j);
        end
        
        // Read back and verify
        errors = 0;
        for (k = 1; k < 32; k = k + 1) begin
            rs1_addr = k[4:0];
            rs2_addr = 5'h0;
            #1;
            if (rs1_data !== (32'h1000_0000 | k)) begin
                errors = errors + 1;
                $display("❌ Register x%0d: expected %h, got %h", k, 32'h1000_0000 | k, rs1_data);
            end
        end
        
        test_count = test_count + 1;
        if (errors == 0) begin
            $display("✅ PASS: All 31 registers store/retrieve correctly");
            pass_count = pass_count + 1;
        end else begin
            $display("❌ FAIL: %0d registers had errors", errors);
        end
        $display("");
        
        // Test Summary
        $display("=== Register File Test Summary ===");
        $display("Total tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", test_count - pass_count);
        
        if (pass_count == test_count) begin
            $display("🎉 ALL TESTS PASSED! Register File is working correctly.");
        end else begin
            $display("❌ Some tests failed. Please review the Register File implementation.");
        end
        
        $finish;
    end
    
    // Generate VCD file for waveform analysis
    initial begin
        $dumpfile("register_file_test.vcd");
        $dumpvars(0, tb_register_file);
    end

endmodule
