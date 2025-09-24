// Simple Memory Module for RISC-V CPU
// Array-based memory with byte-addressable storage
// Supports word (32-bit) read/write operations

module memory (
    input clk,                    // Clock
    input reset_n,                // Active-low reset
    
    // Memory interface
    input  [31:0] addr,           // Memory address
    input  [31:0] write_data,     // Data to write
    input         mem_read,       // Memory read enable
    input         mem_write,      // Memory write enable
    input  [3:0]  byte_enable,    // Byte enable (for partial writes)
    output reg [31:0] read_data,  // Data read from memory
    output reg    ready           // Memory operation complete
);

    // Memory array - 1KB of memory (256 words)
    // In a real CPU, this would be much larger
    reg [31:0] mem_array [255:0];
    
    // Address calculation (word-aligned)
    wire [7:0] word_addr = addr[9:2];  // Use bits [9:2] for word addressing
    
    // Initialize memory
    integer i;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Clear memory on reset
            for (i = 0; i < 256; i = i + 1) begin
                mem_array[i] <= 32'h0;
            end
            read_data <= 32'h0;
            ready <= 1'b0;
        end else begin
            ready <= 1'b0;  // Default not ready
            
            if (mem_read) begin
                // Read operation
                read_data <= mem_array[word_addr];
                ready <= 1'b1;
            end else if (mem_write) begin
                // Write operation with byte enable support
                if (byte_enable[0]) mem_array[word_addr][7:0]   <= write_data[7:0];
                if (byte_enable[1]) mem_array[word_addr][15:8]  <= write_data[15:8];
                if (byte_enable[2]) mem_array[word_addr][23:16] <= write_data[23:16];
                if (byte_enable[3]) mem_array[word_addr][31:24] <= write_data[31:24];
                ready <= 1'b1;
            end
        end
    end

endmodule
