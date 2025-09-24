# RISC-V CPU Design Project

A comprehensive 12-week project to design and implement a RISC-V CPU from scratch, showcasing RTL design, verification, debugging, and optimization skills.

## Project Overview

This project demonstrates key hardware engineering skills:
- **RTL Design** (Verilog, RISC-V) → Digital design and computer architecture
- **Debugging & Verification** → Hardware verification and testing methodologies
- **Power/Performance Analysis** → Low-power design and optimization techniques
- **Automation** (Python scripts) → Design automation and validation workflows

## Project Structure

RISC-V-CPU/
├── phase1_setup/          # Week 1: Tool setup and Hello World
├── phase2_rtl_foundation/ # Weeks 2-3: Basic RTL modules
├── phase3_cpu_core/       # Weeks 4-6: RISC-V CPU implementation
├── phase4_debugging/      # Weeks 7-8: Debugging and validation
├── phase5_power_performance/ # Weeks 9-10: Optimization analysis
├── phase6_portfolio/      # Weeks 11-12: Documentation and polish
├── scripts/               # Automation scripts
├── testbenches/          # Verilog testbenches
├── waveforms/            # Simulation waveforms
└── docs/                 # Documentation

## Development Environment

### Tools Installed
- **Icarus Verilog 12.0** - Open-source RTL simulator
- **Python Waveform Analyzer** - Custom waveform viewer and analysis tools
- **Python 3.9.13** - Scripting and automation

### Quick Start
```bash
# Run the Hello World simulation
./scripts/run_blinking_counter.sh

# View waveforms with Python analyzer
python3 scripts/vcd_analyzer.py waveforms/blinking_counter.vcd
```

## Project Phases

### Phase 1: Setup (Week 1) - COMPLETED
**Goal**: Install all free tools and create Hello World simulation

**Deliverables**:
- [x] Icarus Verilog installation
- [x] Python waveform analyzer setup  
- [x] Python environment setup
- [x] Working "Hello World" simulation (blinking counter)

**Files Created**:
- `phase1_setup/blinking_counter.v` - 8-bit counter with blink output
- `testbenches/tb_blinking_counter.v` - Comprehensive testbench
- `scripts/run_blinking_counter.sh` - Automated simulation script

### Phase 2: RTL Design Foundation (Weeks 2–3) - COMPLETED
**Goal**: Get comfortable writing and simulating small modules

**Deliverables**:
- [x] Basic ALU (add, sub, AND, OR, XOR, SLT, SLTU, SLL, SRL, SRA)
- [x] Register file (32 RISC-V registers with dual read ports)
- [x] Simple memory model (byte-addressable with word operations)
- [x] Comprehensive testbenches for each module (52 total tests)
- [x] Automated test suite with waveform generation

**Files Created**:
- `phase2_rtl_foundation/alu.v` - 32-bit ALU with 10 operations
- `phase2_rtl_foundation/register_file.v` - RISC-V register file
- `phase2_rtl_foundation/memory.v` - Byte-addressable memory
- `testbenches/tb_alu.v` - ALU test suite (23 tests)
- `testbenches/tb_register_file.v` - Register file tests (11 tests)
- `testbenches/tb_memory.v` - Memory tests (18 tests)
- `scripts/run_phase2_tests.sh` - Automated test runner

### Phase 3: Small CPU Core (Weeks 4–6)
**Goal**: Build a simple RISC-V subset CPU

**Planned Deliverables**:
- [ ] Single-cycle CPU (fetch, decode, execute, memory, writeback)
- [ ] Support for basic RISC-V instructions (add, sub, load, store, branch)
- [ ] Python scripts for test program generation
- [ ] CPU runs simple programs (Fibonacci numbers)

### Phase 4: Debugging & Validation (Weeks 7–8)
**Goal**: Show off debugging skills Intel values

**Planned Deliverables**:
- [ ] Fault injection testbench
- [ ] Python-based discrepancy checker
- [ ] Golden model comparison
- [ ] Bug detection and correction report

### Phase 5: Power/Performance Exploration (Weeks 9–10)
**Goal**: Highlight low-power design knowledge

**Planned Deliverables**:
- [ ] Naive vs. optimized CPU comparison
- [ ] Clock gating implementation
- [ ] IPC and power analysis
- [ ] Performance vs. power graphs


## Simulation Results

### Phase 1: Blinking Counter
- **Counter Range**: 0-255 (8-bit)
- **Blink Period**: Toggles every 128 clock cycles
- **Clock Frequency**: 100MHz (10ns period)
- **Reset Behavior**: Synchronous active-low reset
- **Waveform**: Available in `waveforms/blinking_counter.vcd`

### Phase 2: RTL Foundation Modules
- **ALU**: 23/23 tests passed - All arithmetic, logic, and shift operations verified
- **Register File**: 11/11 tests passed - Dual-port access, x0 hardwired zero confirmed
- **Memory**: 18/18 tests passed - Byte-addressable operations, word alignment verified
- **Total Test Coverage**: 52/52 tests passed (100% success rate)
- **Waveforms**: Available in `waveforms/alu_test.vcd`, `register_file_test.vcd`, `memory_test.vcd`

## Usage Instructions

### Running Simulations
```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run Phase 1 simulation
./scripts/run_blinking_counter.sh

# Run Phase 2 comprehensive test suite
./scripts/run_phase2_tests.sh
```

### Viewing Waveforms
```bash
# Open GTKWave with the generated waveform
gtkwave waveforms/blinking_counter.vcd
```

### Development Workflow
1. Write Verilog modules in appropriate phase directory
2. Create testbenches in `testbenches/` directory
3. Add simulation scripts to `scripts/` directory
4. Run simulations and save waveforms to `waveforms/`
5. Document results and learnings

## Skills Demonstrated

- **RTL Design**: Verilog coding, module hierarchy, timing considerations
- **Verification**: Testbench design, stimulus generation, result checking
- **Automation**: Shell scripting, simulation workflows
- **Documentation**: Clear project organization and documentation
- **Version Control**: Git-based project management

## Learning Objectives

This project serves as a comprehensive demonstration of hardware design skills covering the full spectrum from initial design through optimization and validation.


