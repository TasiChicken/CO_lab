// 112550148

`include "ProgramCounter.v"
`include "Instr_Memory.v"
`include "Reg_File.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "ALU.v"
`include "ALU_Ctrl.v"
`include "MUX_2to1.v"
`include "MUX_3to1.v"
`include "Sign_Extend.v"
`include "Adder.v"
`include "Shift_Left_Two_32.v"

module Simple_Single_CPU(
    clk_i,
	rst_i
);
		
// I/O port
input         clk_i;
input         rst_i;

// Internal Signals
wire [31:0] pc_addr;
wire [31:0] instr;
wire [31:0] RSdata;
wire [31:0] RTdata;
wire [31:0] ALU_src2;
wire [31:0] ALU_src1;
wire [2-1:0] ALU_op;
wire Jump, RegDst, ALUSrc, Link, Branch, MemRead, MemWrite, MemtoReg;
wire [31:0] IMME;
wire [4:0] ALUCtrl;
wire src_shamt;
wire [31:0] pc_inc;
wire [31:0] jump_addr;
wire [31:0] branch_target_addr;
wire [31:0] branch_addr;
wire [31:0] unmasked_jump_addr;
wire [31:0] branch_delta;
wire [31:0] alu_res;
wire alu_zero;
wire alu_overflow;
wire [31:0] pc_in;
wire [31:0] mem_data;
wire [31:0] wb_data;
wire RegWrite;
wire [4:0] RD_addr;
wire [31:0] RDdata;

// Components
ProgramCounter PC(
    .clk_i(clk_i),      
    .rst_i(rst_i),     
    .pc_in_i(pc_in),   
    .pc_out_o(pc_addr) 
);

Instr_Memory IM(
    .pc_addr_i(pc_addr),  
    .instr_o(instr)    
);

assign RD_addr = (Link == 1'b0) ? ((RegDst == 1'b0) ? instr[20:16] : instr[15:11]) : 5'd31;
assign RDdata = (Link == 1'b0) ? wb_data : pc_inc;

Reg_File Registers(
    .clk_i(clk_i),      
    .rst_i(rst_i),      
    .RSaddr_i(instr[25:21]),
    .RTaddr_i(instr[20:16]),
    .RDaddr_i(RD_addr), 
    .RDdata_i(RDdata),
    .RegWrite_i(RegWrite),
    .RSdata_o(RSdata),  
    .RTdata_o(RTdata) 
);

MUX_2to1 WB_MUX(
    .data0_i(alu_res),
    .data1_i(mem_data),
    .select_i(MemtoReg),
    .data_o(wb_data)
);

Data_Memory Data_Memory(
	.clk_i(clk_i), 
	.addr_i(alu_res), 
	.data_i(RTdata), 
	.MemRead_i(MemRead), 
	.MemWrite_i(MemWrite), 
	.data_o(mem_data)
);

Decoder Decoder(
	.instr_op_i(instr[31:26]),
    .instr_func_i(instr[5:0]),
	.ALU_op_o(ALU_op),
	.ALUSrc_o(ALUSrc),
	.RegWrite_o(RegWrite),
	.RegDst_o(RegDst),
	.Branch_o(Branch),
	.Jump_o(Jump),
	.MemRead_o(MemRead),
	.MemWrite_o(MemWrite),
	.MemtoReg_o(MemtoReg),
    .Link_o(Link)
);

Sign_Extend IMME_sign_extend(
    .data_i(instr[15:0]),
    .data_o(IMME)
);

ALU_Ctrl ALU_Ctrl(
    .funct_i(instr[5:0]),
    .ALUOp_i(ALU_op),
    .ALUCtrl_o(ALUCtrl),
    .src_shamt_o(src_shamt)
);

MUX_2to1 ALU_src2_MUX(
    .data0_i(RTdata),
    .data1_i(IMME),
    .select_i(ALUSrc),
    .data_o(ALU_src2)
);

MUX_2to1 ALU_src1_MUX(
    .data0_i(RSdata),
    .data1_i({27'b0, instr[10:6]}),
    .select_i(src_shamt),
    .data_o(ALU_src1)
);

ALU ALU(
    .src1_i(ALU_src1),
    .src2_i(ALU_src2),
    .ctrl_i(ALUCtrl),
    .result_o(alu_res),
    .zero_o(alu_zero),
    .overflow(alu_overflow)
);

Adder pc_inc_adder(
    .src1_i(pc_addr),
	.src2_i(32'h04),
	.sum_o(pc_inc)
);

Shift_Left_Two_32 jump_addr_sl(
    .data_i({6'b0, instr[25:0]}),
    .data_o(unmasked_jump_addr)
);

assign jump_addr = ((instr[31:26] == 6'b0) & (instr[5:0] == 6'b001000)) ?
                    RSdata : {pc_inc[31:28], unmasked_jump_addr[27:0]};

Adder pc_branch_adder(
    .src1_i(pc_inc),
	.src2_i(branch_delta),
	.sum_o(branch_target_addr)
);

Shift_Left_Two_32 branch_target_addr_sl(
    .data_i(IMME),
    .data_o(branch_delta)
);

MUX_2to1 branch_MUX(
    .data0_i(pc_inc),
    .data1_i(branch_target_addr),
    .select_i(Branch & (alu_zero ^ (instr[31:26] == 6'b000100))),
    .data_o(branch_addr)
);

MUX_2to1 pc_in_MUX(
    .data0_i(branch_addr),
    .data1_i(jump_addr),
    .select_i(Jump),
    .data_o(pc_in)
);

endmodule
