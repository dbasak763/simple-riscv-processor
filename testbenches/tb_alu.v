// Testbench for ALU module
// Comprehensive testing of all ALU operations and flag generation

`timescale 1ns/1ps

module tb_alu;

    // Testbench signals
    reg  [31:0] a, b;
    reg  [3:0]  alu_op;
    wire [31:0] result;
    wire zero, overflow, carry;
    
    // Test result tracking
    integer test_count = 0;
    integer pass_count = 0;
    
    // Instantiate ALU
    alu dut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero),
        .overflow(overflow),
        .carry(carry)
    );
    
    // ALU operation codes (matching the module)
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLT  = 4'b0101;
    localparam ALU_SLTU = 4'b0110;
    localparam ALU_SLL  = 4'b0111;
    localparam ALU_SRL  = 4'b1000;
    localparam ALU_SRA  = 4'b1001;
    
    // Task to check ALU result
    task check_result;
        input [31:0] expected_result;
        input expected_zero;
        input expected_overflow;
        input expected_carry;
        input [8*20:1] test_name;
        begin
            test_count = test_count + 1;
            #1; // Small delay for signals to settle
            
            if (result === expected_result && 
                zero === expected_zero && 
                overflow === expected_overflow && 
                carry === expected_carry) begin
                $display("✅ PASS: %s", test_name);
                $display("   A=%h, B=%h, Op=%b -> Result=%h, Z=%b, V=%b, C=%b", 
                         a, b, alu_op, result, zero, overflow, carry);
                pass_count = pass_count + 1;
            end else begin
                $display("❌ FAIL: %s", test_name);
                $display("   A=%h, B=%h, Op=%b", a, b, alu_op);
                $display("   Expected: Result=%h, Z=%b, V=%b, C=%b", 
                         expected_result, expected_zero, expected_overflow, expected_carry);
                $display("   Got:      Result=%h, Z=%b, V=%b, C=%b", 
                         result, zero, overflow, carry);
            end
            $display("");
        end
    endtask
    
    // Main test sequence
    initial begin
        $display("=== ALU Testbench Starting ===");
        $display("");
        
        // Test Addition
        $display("--- Testing Addition ---");
        a = 32'h00000005; b = 32'h00000003; alu_op = ALU_ADD;
        check_result(32'h00000008, 1'b0, 1'b0, 1'b0, "ADD: 5 + 3 = 8");
        
        a = 32'hFFFFFFFF; b = 32'h00000001; alu_op = ALU_ADD;
        check_result(32'h00000000, 1'b1, 1'b0, 1'b1, "ADD: -1 + 1 = 0 (carry)");
        
        a = 32'h7FFFFFFF; b = 32'h00000001; alu_op = ALU_ADD;
        check_result(32'h80000000, 1'b0, 1'b1, 1'b0, "ADD: overflow test");
        
        // Test Subtraction
        $display("--- Testing Subtraction ---");
        a = 32'h00000008; b = 32'h00000003; alu_op = ALU_SUB;
        check_result(32'h00000005, 1'b0, 1'b0, 1'b0, "SUB: 8 - 3 = 5");
        
        a = 32'h00000003; b = 32'h00000008; alu_op = ALU_SUB;
        check_result(32'hFFFFFFFB, 1'b0, 1'b0, 1'b1, "SUB: 3 - 8 = -5 (borrow)");
        
        a = 32'h80000000; b = 32'h00000001; alu_op = ALU_SUB;
        check_result(32'h7FFFFFFF, 1'b0, 1'b1, 1'b0, "SUB: overflow test");
        
        // Test Bitwise AND
        $display("--- Testing Bitwise AND ---");
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; alu_op = ALU_AND;
        check_result(32'h00000000, 1'b1, 1'b0, 1'b0, "AND: F0F0F0F0 & 0F0F0F0F");
        
        a = 32'hFFFFFFFF; b = 32'h12345678; alu_op = ALU_AND;
        check_result(32'h12345678, 1'b0, 1'b0, 1'b0, "AND: FFFFFFFF & 12345678");
        
        // Test Bitwise OR
        $display("--- Testing Bitwise OR ---");
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; alu_op = ALU_OR;
        check_result(32'hFFFFFFFF, 1'b0, 1'b0, 1'b0, "OR: F0F0F0F0 | 0F0F0F0F");
        
        a = 32'h00000000; b = 32'h00000000; alu_op = ALU_OR;
        check_result(32'h00000000, 1'b1, 1'b0, 1'b0, "OR: 0 | 0 = 0");
        
        // Test Bitwise XOR
        $display("--- Testing Bitwise XOR ---");
        a = 32'hF0F0F0F0; b = 32'h0F0F0F0F; alu_op = ALU_XOR;
        check_result(32'hFFFFFFFF, 1'b0, 1'b0, 1'b0, "XOR: F0F0F0F0 ^ 0F0F0F0F");
        
        a = 32'h12345678; b = 32'h12345678; alu_op = ALU_XOR;
        check_result(32'h00000000, 1'b1, 1'b0, 1'b0, "XOR: same values = 0");
        
        // Test Set Less Than (signed)
        $display("--- Testing Set Less Than (Signed) ---");
        a = 32'h00000005; b = 32'h00000008; alu_op = ALU_SLT;
        check_result(32'h00000001, 1'b0, 1'b0, 1'b0, "SLT: 5 < 8 = true");
        
        a = 32'h00000008; b = 32'h00000005; alu_op = ALU_SLT;
        check_result(32'h00000000, 1'b1, 1'b0, 1'b0, "SLT: 8 < 5 = false");
        
        a = 32'hFFFFFFFF; b = 32'h00000001; alu_op = ALU_SLT;
        check_result(32'h00000001, 1'b0, 1'b0, 1'b0, "SLT: -1 < 1 = true");
        
        // Test Set Less Than Unsigned
        $display("--- Testing Set Less Than (Unsigned) ---");
        a = 32'hFFFFFFFF; b = 32'h00000001; alu_op = ALU_SLTU;
        check_result(32'h00000000, 1'b1, 1'b0, 1'b0, "SLTU: 0xFFFFFFFF < 1 = false");
        
        a = 32'h00000001; b = 32'hFFFFFFFF; alu_op = ALU_SLTU;
        check_result(32'h00000001, 1'b0, 1'b0, 1'b0, "SLTU: 1 < 0xFFFFFFFF = true");
        
        // Test Shift Left Logical
        $display("--- Testing Shift Left Logical ---");
        a = 32'h00000001; b = 32'h00000004; alu_op = ALU_SLL;
        check_result(32'h00000010, 1'b0, 1'b0, 1'b0, "SLL: 1 << 4 = 16");
        
        a = 32'h12345678; b = 32'h00000008; alu_op = ALU_SLL;
        check_result(32'h34567800, 1'b0, 1'b0, 1'b0, "SLL: 0x12345678 << 8");
        
        // Test Shift Right Logical
        $display("--- Testing Shift Right Logical ---");
        a = 32'h00000010; b = 32'h00000004; alu_op = ALU_SRL;
        check_result(32'h00000001, 1'b0, 1'b0, 1'b0, "SRL: 16 >> 4 = 1");
        
        a = 32'h80000000; b = 32'h00000001; alu_op = ALU_SRL;
        check_result(32'h40000000, 1'b0, 1'b0, 1'b0, "SRL: 0x80000000 >> 1");
        
        // Test Shift Right Arithmetic
        $display("--- Testing Shift Right Arithmetic ---");
        a = 32'h80000000; b = 32'h00000001; alu_op = ALU_SRA;
        check_result(32'hC0000000, 1'b0, 1'b0, 1'b0, "SRA: 0x80000000 >>> 1 (sign extend)");
        
        a = 32'h40000000; b = 32'h00000001; alu_op = ALU_SRA;
        check_result(32'h20000000, 1'b0, 1'b0, 1'b0, "SRA: 0x40000000 >>> 1");
        
        // Test Summary
        $display("=== ALU Test Summary ===");
        $display("Total tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);
        $display("Failed:      %0d", test_count - pass_count);
        
        if (pass_count == test_count) begin
            $display("🎉 ALL TESTS PASSED! ALU is working correctly.");
        end else begin
            $display("❌ Some tests failed. Please review the ALU implementation.");
        end
        
        $finish;
    end
    
    // Generate VCD file for waveform analysis
    initial begin
        $dumpfile("alu_test.vcd");
        $dumpvars(0, tb_alu);
    end

endmodule
