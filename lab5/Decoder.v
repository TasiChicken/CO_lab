// 112550148
module Decoder( 
	instr_op_i, 
	ALUOp_o, 
	ALUSrc_o,
	RegWrite_o,	
	RegDst_o,
	BranchEQ_o,
	BranchNEQ_o,
	MemRead_o, 
	MemWrite_o, 
	MemtoReg_o
);
     
// I/O ports
input	[6-1:0] instr_op_i;

output reg [2-1:0] ALUOp_o;
output reg ALUSrc_o, RegWrite_o;
output RegDst_o, BranchEQ_o, BranchNEQ_o, MemRead_o, MemWrite_o, MemtoReg_o;

assign RegDst_o = instr_op_i == 6'b000000;
assign BranchEQ_o = instr_op_i == 6'b000101;
assign BranchNEQ_o = instr_op_i == 6'b000100;
assign MemRead_o = instr_op_i == 6'b101011;
assign MemtoReg_o = instr_op_i == 6'b101011;
assign MemWrite_o = instr_op_i == 6'b100011;

always @(*) begin
	case (instr_op_i)
		6'b000000: begin // R-type
			ALUOp_o = 2'b10;  
			RegWrite_o = 1'b1;   
			ALUSrc_o = 1'b0;   
		end
		6'b001000: begin // addi
			ALUOp_o = 2'b00;
			RegWrite_o = 1'b1;
			ALUSrc_o = 1'b1; 
		end
		6'b101011: begin // lw 
			ALUOp_o = 2'b00;
			RegWrite_o = 1'b1;
			ALUSrc_o = 1'b1;
		end
		6'b100011: begin // sw 
			ALUOp_o = 2'b00;
			RegWrite_o = 1'b0;
			ALUSrc_o = 1'b1;
		end
		6'b000101: begin // beq 
			ALUOp_o = 2'b01;
			RegWrite_o = 1'b0;
			ALUSrc_o = 1'b0;
		end
		6'b000100: begin // bne
			ALUOp_o = 2'b01;
			RegWrite_o = 1'b0;
			ALUSrc_o = 1'b0;
		end
	endcase
end

endmodule