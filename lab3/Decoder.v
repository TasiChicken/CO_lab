// 112550148
module Decoder( 
	instr_op_i,
	instr_func_i,
	ALU_op_o,
	ALUSrc_o,
	RegWrite_o,
	RegDst_o,
	Branch_o,
	Jump_o,
	MemRead_o,
	MemWrite_o,
	MemtoReg_o,
	Link_o
);

// I/O ports
input	[6-1:0] instr_op_i;
input	[6-1:0] instr_func_i;

output reg [2-1:0] ALU_op_o;
output reg ALUSrc_o, RegWrite_o;
output Jump_o, RegDst_o, Link_o, Branch_o, MemRead_o, MemWrite_o, MemtoReg_o;

// Internal Signals


// Main function
assign Jump_o = (instr_op_i == 6'b11) | (instr_op_i == 6'b10) | 
				((instr_op_i == 6'b0) & (instr_func_i == 6'b001000));
assign Link_o = (instr_op_i == 6'b000010);
assign RegDst_o = instr_op_i == 6'b0;
assign Branch_o = (instr_op_i == 6'b000101) | (instr_op_i == 6'b000100);
assign MemRead_o = (instr_op_i == 6'b101011);
assign MemtoReg_o = (instr_op_i == 6'b101011);
assign MemWrite_o = (instr_op_i == 6'b100011);


always @(*) begin
	// R type
	if (instr_op_i == 6'b0) begin
		ALU_op_o <= (instr_func_i == 6'b001000) ? 2'b00 : 2'b10;
		RegWrite_o <= (instr_func_i == 6'b001000) ? 1'b0 : 1'b1;;
		ALUSrc_o <= 1'b0;
	end
	// addi
	else if (instr_op_i == 6'b001000) begin
		ALU_op_o <= 2'b00;
		RegWrite_o <= 1'b1;
		ALUSrc_o <= 1'b1;
	end
	// lw
	else if (instr_op_i == 6'b101011) begin
		ALU_op_o <= 2'b00;
		RegWrite_o <= 1'b1;
		ALUSrc_o <= 1'b1;
	end
	// sw
	else if (instr_op_i == 6'b100011) begin
		ALU_op_o <= 2'b00;
		RegWrite_o <= 1'b0;
		ALUSrc_o <= 1'b1;
	end
	// beq
	else if (instr_op_i == 6'b000101) begin
		ALU_op_o <= 2'b01;
		RegWrite_o <= 1'b0;
		ALUSrc_o <= 1'b0;
	end
	// bne
	else if (instr_op_i == 6'b000100) begin
		ALU_op_o <= 2'b01;
		RegWrite_o <= 1'b0;
		ALUSrc_o <= 1'b0;
	end
	// j
	else if (instr_op_i == 6'b000011) begin
		ALU_op_o <= 2'b00;
		RegWrite_o <= 1'b0;
		ALUSrc_o <= 1'b0;
	end
	// jal
	else if (instr_op_i == 6'b000010) begin
		ALU_op_o <= 2'b00;
		RegWrite_o <= 1'b1;
		ALUSrc_o <= 1'b0;
	end
	else begin
		ALU_op_o <= 2'b00;
		RegWrite_o <= 1'b0;
		ALUSrc_o <= 1'b0;
	end
end

endmodule
                

