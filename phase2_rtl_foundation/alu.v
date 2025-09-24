// Basic ALU for RISC-V CPU
// Supports fundamental arithmetic and logic operations
// 32-bit operands to match RISC-V architecture

module alu (
    input  [31:0] a,           // First operand
    input  [31:0] b,           // Second operand
    input  [3:0]  alu_op,      // ALU operation selector
    output reg [31:0] result,  // ALU result
    output zero,               // Zero flag (result == 0)
    output overflow,           // Overflow flag for signed operations
    output carry               // Carry flag for unsigned operations
);

    // ALU operation codes
    localparam ALU_ADD  = 4'b0000;  // Addition
    localparam ALU_SUB  = 4'b0001;  // Subtraction
    localparam ALU_AND  = 4'b0010;  // Bitwise AND
    localparam ALU_OR   = 4'b0011;  // Bitwise OR
    localparam ALU_XOR  = 4'b0100;  // Bitwise XOR
    localparam ALU_SLT  = 4'b0101;  // Set Less Than (signed)
    localparam ALU_SLTU = 4'b0110;  // Set Less Than Unsigned
    localparam ALU_SLL  = 4'b0111;  // Shift Left Logical
    localparam ALU_SRL  = 4'b1000;  // Shift Right Logical
    localparam ALU_SRA  = 4'b1001;  // Shift Right Arithmetic

    // Internal signals for flag generation
    wire [32:0] add_result;     // 33-bit for carry detection
    wire [32:0] sub_result;     // 33-bit for borrow detection
    wire        a_sign, b_sign, result_sign;
    
    // Extended addition and subtraction for flag calculation
    assign add_result = {1'b0, a} + {1'b0, b};
    assign sub_result = {1'b0, a} - {1'b0, b};
    
    // Sign bits for overflow detection
    assign a_sign = a[31];
    assign b_sign = b[31];
    assign result_sign = result[31];

    // Main ALU logic
    always @(*) begin
        case (alu_op)
            ALU_ADD:  result = a + b;
            ALU_SUB:  result = a - b;
            ALU_AND:  result = a & b;
            ALU_OR:   result = a | b;
            ALU_XOR:  result = a ^ b;
            ALU_SLT:  result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0;
            ALU_SLTU: result = (a < b) ? 32'h1 : 32'h0;
            ALU_SLL:  result = a << b[4:0];  // Only use lower 5 bits for shift amount
            ALU_SRL:  result = a >> b[4:0];
            ALU_SRA:  result = $signed(a) >>> b[4:0];  // Arithmetic right shift
            default:  result = 32'h0;
        endcase
    end

    // Flag generation
    assign zero = (result == 32'h0);
    
    // Carry flag: set for unsigned overflow in addition or underflow in subtraction
    assign carry = (alu_op == ALU_ADD) ? add_result[32] :
                   (alu_op == ALU_SUB) ? sub_result[32] : 1'b0;
    
    // Overflow flag: set for signed overflow in addition or subtraction
    assign overflow = (alu_op == ALU_ADD) ? (a_sign == b_sign) && (result_sign != a_sign) :
                      (alu_op == ALU_SUB) ? (a_sign != b_sign) && (result_sign != a_sign) : 1'b0;

endmodule
