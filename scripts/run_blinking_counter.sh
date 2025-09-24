#!/bin/bash

# Script to compile and run the blinking counter simulation
# This demonstrates the basic Verilog simulation workflow

echo "=== RISC-V CPU Project - Phase 1: Hello World Simulation ==="
echo "Compiling blinking counter..."

# Change to project root directory
cd "$(dirname "$0")/.."

# Compile the Verilog files using Icarus Verilog
iverilog -o blinking_counter_sim \
    phase1_setup/blinking_counter.v \
    testbenches/tb_blinking_counter.v

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    echo "Running simulation..."
    
    # Run the simulation
    vvp blinking_counter_sim
    
    # Move the VCD file to waveforms directory
    if [ -f blinking_counter.vcd ]; then
        mv blinking_counter.vcd waveforms/
        echo "Waveform file saved to waveforms/blinking_counter.vcd"
        echo ""
        echo "To view waveforms, run:"
        echo "gtkwave waveforms/blinking_counter.vcd"
    fi
    
    # Clean up simulation executable
    rm -f blinking_counter_sim
    
    echo ""
    echo "Phase 1 Hello World simulation completed successfully! ✅"
else
    echo "Compilation failed! ❌"
    exit 1
fi
