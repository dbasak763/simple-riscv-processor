// Register File for RISC-V CPU
// 32 general-purpose registers (x0-x31)
// x0 is hardwired to zero
// Dual read ports, single write port

module register_file (
    input clk,                    // Clock
    input reset_n,                // Active-low reset
    
    // Read ports
    input  [4:0]  rs1_addr,       // Read address 1 (source register 1)
    input  [4:0]  rs2_addr,       // Read address 2 (source register 2)
    output [31:0] rs1_data,       // Read data 1
    output [31:0] rs2_data,       // Read data 2
    
    // Write port
    input  [4:0]  rd_addr,        // Write address (destination register)
    input  [31:0] rd_data,        // Write data
    input         wr_enable       // Write enable
);

    // Register array - 32 registers of 32 bits each
    reg [31:0] registers [31:0];
    
    // Initialize registers
    integer i;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset all registers to zero
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0;
            end
        end else if (wr_enable && rd_addr != 5'h0) begin
            // Write to register (except x0 which is always zero)
            registers[rd_addr] <= rd_data;
        end
    end
    
    // Read operations (combinational)
    // x0 is always zero, other registers read from array
    assign rs1_data = (rs1_addr == 5'h0) ? 32'h0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'h0) ? 32'h0 : registers[rs2_addr];

endmodule
