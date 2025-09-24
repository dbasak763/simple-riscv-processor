# RISC-V CPU Design Project

This is a 12-week project where I’m building a RISC-V CPU from the ground up. The goal is to practice RTL design, verification, debugging, and performance analysis while showing how these pieces fit together in a real hardware workflow.

Overview

The project highlights:

RTL Design in Verilog (ALU, register file, memory, CPU pipeline)

Verification & Debugging with automated testbenches and fault injection

Performance & Power Analysis using toggle activity and simple optimizations

Automation with Python scripts for simulation and waveform analysis

Repository Layout
RISC-V-CPU/
├── phase1_setup/              # Tool setup + hello world demo
├── phase2_rtl_foundation/     # Core building blocks
├── phase3_cpu_core/           # Single-cycle CPU (in progress)
├── phase4_debugging/          # Debugging + validation
├── phase5_power_performance/  # Power + performance tradeoffs
├── scripts/                   # Automation scripts
├── testbenches/               # Verification testbenches
├── waveforms/                 # Simulation results
└── docs/                      # Documentation

Development Environment

Icarus Verilog 12.0 – RTL simulation

GTKWave – Waveform viewing

Python 3.9 – Automation + waveform analysis

Quick Start
## Run the Phase 1 demo
./scripts/run_blinking_counter.sh

## Run Phase 2 test suite
./scripts/run_phase2_tests.sh

Progress
✅ Phase 1: Setup

Installed simulation tools and Python utilities

Implemented an 8-bit counter with blinking output

Verified functionality with a testbench and waveform dump

✅ Phase 2: RTL Foundation

Built a 32-bit ALU (10 operations)

Designed a dual-port register file with 32 registers

Implemented a byte-addressable memory module

Wrote 52 automated tests (all passing) with waveform validation

🚧 Phase 3: CPU Core (In Progress)

Goal: single-cycle RISC-V CPU supporting a small instruction subset

Will run simple programs (e.g., Fibonacci sequence)

Verification with Python-generated test programs

Results So Far

ALU: 23/23 tests passed

Register File: 11/11 tests passed (including x0 hardwired to zero)

Memory: 18/18 tests passed (alignment + load/store behavior)

Overall Coverage: 52/52 passing tests with waveforms saved

Skills Demonstrated

Verilog RTL design and simulation

Hardware verification and corner-case testing

Python scripting for batch simulation and result analysis

Clear documentation and project structure
