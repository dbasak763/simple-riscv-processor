#!/bin/bash

# Phase 2 RTL Foundation - Automated Test Suite
# Tests all basic RTL modules: ALU, Register File, and Memory

echo "=== RISC-V CPU Project - Phase 2: RTL Foundation Tests ==="
echo ""

# Change to project root directory
cd "$(dirname "$0")/.."

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0

# Function to run a test
run_test() {
    local module_name=$1
    local verilog_files=$2
    local testbench=$3
    local sim_name=$4
    
    echo -e "${BLUE}Testing $module_name...${NC}"
    
    # Compile
    if iverilog -o $sim_name $verilog_files $testbench 2>/dev/null; then
        echo "✅ Compilation successful"
        
        # Run simulation and capture output
        if output=$(vvp $sim_name 2>&1); then
            # Check if all tests passed
            if echo "$output" | grep -q "ALL TESTS PASSED"; then
                echo -e "${GREEN}✅ $module_name: ALL TESTS PASSED${NC}"
                PASSED_TESTS=$((PASSED_TESTS + 1))
                
                # Extract test statistics
                if echo "$output" | grep -q "Total tests:"; then
                    stats=$(echo "$output" | grep "Total tests:" | tail -1)
                    echo "   $stats"
                fi
            else
                echo -e "${RED}❌ $module_name: SOME TESTS FAILED${NC}"
                echo "$output" | grep -E "(FAIL|ERROR)"
            fi
        else
            echo -e "${RED}❌ $module_name: Simulation failed${NC}"
        fi
        
        # Clean up
        rm -f $sim_name
    else
        echo -e "${RED}❌ $module_name: Compilation failed${NC}"
    fi
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo ""
}

# Test ALU
run_test "ALU" \
    "phase2_rtl_foundation/alu.v" \
    "testbenches/tb_alu.v" \
    "alu_test_sim"

# Test Register File
run_test "Register File" \
    "phase2_rtl_foundation/register_file.v" \
    "testbenches/tb_register_file.v" \
    "regfile_test_sim"

# Test Memory
run_test "Memory" \
    "phase2_rtl_foundation/memory.v" \
    "testbenches/tb_memory.v" \
    "memory_test_sim"

# Move VCD files to waveforms directory
echo "Moving waveform files..."
if [ -f alu_test.vcd ]; then
    mv alu_test.vcd waveforms/
    echo "✅ ALU waveform saved to waveforms/alu_test.vcd"
fi

if [ -f register_file_test.vcd ]; then
    mv register_file_test.vcd waveforms/
    echo "✅ Register File waveform saved to waveforms/register_file_test.vcd"
fi

if [ -f memory_test.vcd ]; then
    mv memory_test.vcd waveforms/
    echo "✅ Memory waveform saved to waveforms/memory_test.vcd"
fi

echo ""
echo "=== Phase 2 Test Summary ==="
echo "Modules tested: $TOTAL_TESTS"
echo "Modules passed: $PASSED_TESTS"
echo "Modules failed: $((TOTAL_TESTS - PASSED_TESTS))"

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "${GREEN}🎉 Phase 2 RTL Foundation: ALL MODULES WORKING!${NC}"
    echo ""
    echo "✅ ALU: Arithmetic and logic operations"
    echo "✅ Register File: 32 RISC-V registers with dual read ports"
    echo "✅ Memory: Byte-addressable memory with word operations"
    echo ""
    echo "Ready to proceed to Phase 3: CPU Core Implementation"
else
    echo -e "${RED}❌ Phase 2: Some modules need attention${NC}"
    exit 1
fi
