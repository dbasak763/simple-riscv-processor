#!/usr/bin/env python3
"""
VCD Waveform Analyzer for RISC-V CPU Project
A Python-based alternative to GTKWave that works on macOS 14+
Reads VCD files and generates waveform plots using matplotlib
"""

import sys
import matplotlib
matplotlib.use('Agg')  # Use non-interactive backend
import matplotlib.pyplot as plt
import re
from pathlib import Path

def read_vcd_file(vcd_path):
    """Simple VCD file parser - extracts basic signal information"""
    signals = {}
    var_map = {}
    
    try:
        with open(vcd_path, 'r') as f:
            lines = f.readlines()
        
        # Parse VCD header to get variable definitions
        in_header = True
        current_time = 0
        for line in lines:
            line = line.strip()
            
            if line.startswith('$var'):
                # $var wire 8 ! counter [7:0] $end
                parts = line.split()
                if len(parts) >= 5:
                    var_type = parts[1]
                    size = int(parts[2])
                    var_id = parts[3]
                    var_name = parts[4]
                    
                    var_map[var_id] = {
                        'name': var_name,
                        'size': size,
                        'times': [],
                        'values': []
                    }
            
            elif line.startswith('$enddefinitions'):
                in_header = False
            
            elif not in_header and line.startswith('#'):
                # Timestamp
                current_time = int(line[1:])
            
            elif not in_header and len(line) > 0 and not line.startswith('$'):
                # Value change: format can be "1!" or "b10101010 !"
                if line.startswith('b'):
                    # Binary value
                    parts = line.split()
                    if len(parts) == 2:
                        binary_val = parts[0][1:]  # Remove 'b' prefix
                        var_id = parts[1]
                        try:
                            value = int(binary_val, 2)
                        except:
                            value = 0
                else:
                    # Single bit value
                    if len(line) >= 2:
                        value = int(line[0])
                        var_id = line[1:]
                    else:
                        continue
                
                if var_id in var_map:
                    var_map[var_id]['times'].append(current_time)
                    var_map[var_id]['values'].append(value)
        
        return var_map
    
    except Exception as e:
        print(f"Error reading VCD file: {e}")
        return None

def plot_waveforms(signals, output_path=None, title="Waveform Analysis"):
    """Create matplotlib waveform plot"""
    
    if not signals:
        print("No signals to plot")
        return
    
    # Filter out internal signals, focus on our testbench signals
    main_signals = {}
    for ref, data in signals.items():
        name = data['name']
        if any(x in name.lower() for x in ['clk', 'reset', 'counter', 'blink']):
            main_signals[ref] = data
    
    if not main_signals:
        print("No relevant signals found for plotting")
        return
    
    fig, axes = plt.subplots(len(main_signals), 1, figsize=(12, 2*len(main_signals)), sharex=True)
    if len(main_signals) == 1:
        axes = [axes]
    
    colors = ['blue', 'red', 'green', 'orange', 'purple']
    
    for i, (ref, data) in enumerate(main_signals.items()):
        ax = axes[i]
        times = data['times']
        values = data['values']
        
        if not times:
            continue
            
        # Create step plot for digital signals
        if data['size'] == 1:  # Single-bit signal
            # Digital waveform
            plot_times = []
            plot_values = []
            
            for j in range(len(times)):
                if j == 0:
                    plot_times.extend([0, times[j]])
                    plot_values.extend([values[j], values[j]])
                else:
                    plot_times.extend([times[j-1], times[j]])
                    plot_values.extend([values[j], values[j]])
            
            ax.plot(plot_times, plot_values, color=colors[i % len(colors)], linewidth=2)
            ax.set_ylim(-0.5, 1.5)
            ax.set_yticks([0, 1])
            ax.grid(True, alpha=0.3)
        else:  # Multi-bit signal
            # Plot as analog-style for multi-bit
            ax.step(times, values, where='post', color=colors[i % len(colors)], linewidth=2)
            ax.grid(True, alpha=0.3)
        
        ax.set_ylabel(data['name'], rotation=0, ha='right', va='center')
        ax.set_title(f"{data['name']} ({data['size']} bit{'s' if data['size'] > 1 else ''})")
    
    plt.xlabel('Time (ps)')
    plt.suptitle(title, fontsize=14, fontweight='bold')
    plt.tight_layout()
    
    if output_path:
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
        print(f"Waveform plot saved to: {output_path}")
    
    plt.close()  # Close the plot instead of showing it

def analyze_counter_behavior(signals):
    """Analyze the blinking counter behavior"""
    print("\n=== Blinking Counter Analysis ===")
    
    # Find counter and blink signals
    counter_signal = None
    blink_signal = None
    reset_signal = None
    
    for ref, data in signals.items():
        name = data['name'].lower()
        if 'counter' in name and data['size'] > 1:
            counter_signal = data
        elif 'blink' in name:
            blink_signal = data
        elif 'reset' in name:
            reset_signal = data
    
    if not counter_signal:
        print("Counter signal not found")
        return
    
    print(f"Counter signal: {counter_signal['name']} ({counter_signal['size']} bits)")
    print(f"Counter range: 0 to {2**counter_signal['size'] - 1}")
    
    if counter_signal['values']:
        print(f"Counter values seen: {min(counter_signal['values'])} to {max(counter_signal['values'])}")
        print(f"Total counter changes: {len(counter_signal['values'])}")
    
    if blink_signal:
        print(f"Blink signal: {blink_signal['name']}")
        blink_transitions = 0
        prev_blink = None
        for val in blink_signal['values']:
            if prev_blink is not None and prev_blink != val:
                blink_transitions += 1
            prev_blink = val
        print(f"Blink transitions: {blink_transitions}")
    
    # Verify blink follows counter MSB
    if counter_signal and blink_signal and len(counter_signal['times']) == len(blink_signal['times']):
        errors = 0
        for i in range(len(counter_signal['values'])):
            counter_val = counter_signal['values'][i]
            blink_val = blink_signal['values'][i]
            expected_blink = 1 if counter_val >= 128 else 0
            
            if blink_val != expected_blink:
                errors += 1
        
        if errors == 0:
            print("✅ Blink signal correctly follows counter MSB")
        else:
            print(f"❌ Found {errors} blink signal errors")

def main():
    """Main function"""
    if len(sys.argv) != 2:
        print("Usage: python3 vcd_analyzer.py <vcd_file>")
        print("Example: python3 vcd_analyzer.py waveforms/blinking_counter.vcd")
        return 1
    
    vcd_path = Path(sys.argv[1])
    if not vcd_path.exists():
        print(f"Error: VCD file not found: {vcd_path}")
        return 1
    
    print(f"Analyzing VCD file: {vcd_path}")
    
    # Read VCD file
    signals = read_vcd_file(vcd_path)
    if not signals:
        return 1
    
    print(f"Found {len(signals)} signals")
    
    # Analyze behavior
    analyze_counter_behavior(signals)
    
    # Create waveform plot
    output_plot = vcd_path.parent / f"{vcd_path.stem}_waveform.png"
    plot_waveforms(signals, output_plot, f"Waveform Analysis: {vcd_path.name}")
    
    print(f"\n🎉 Analysis complete! Waveform plot saved as: {output_plot}")
    return 0

if __name__ == "__main__":
    sys.exit(main())
