// 112550148
`include "Adder.v"
`include "ALU_Ctrl.v"
`include "ALU.v"
`include "Reg_File.v"
`include "Data_Memory.v"
`include "Decoder.v"
`include "Instruction_Memory.v"
`include "MUX_2to1.v"
`include "Pipe_Reg.v"
`include "ProgramCounter.v"
`include "Shift_Left_Two_32.v"
`include "Sign_Extend.v"

`timescale 1ns / 1ps

module Pipe_CPU(
    clk_i,
    rst_i
    );

input clk_i;
input rst_i;

// exception
wire stall;

// IF
wire [31:0] IF_PC_in;
wire [31:0] IF_PC_out;
wire [31:0] IF_PC_plus4;
wire [31:0] IF_instr;

// ID
wire [31:0] ID_PC_plus4;
wire [31:0] ID_sign_ext;
wire [31:0] ID_instr;
wire [1:0]  ID_ALUOp;
wire        ID_ALUSrc;
wire        ID_RegWrite;
wire        ID_RegDst;
wire        ID_BranchEQ;
wire        ID_BranchNEQ;
wire        ID_MemRead;
wire        ID_MemWrite;
wire        ID_MemtoReg;
wire [31:0] ID_RSdata;
wire [31:0] ID_RTdata;

// EX
wire [4:0]  EX_RTaddr;
wire [4:0]  EX_RDaddr;
wire [1:0]  EX_ALUOp;
wire        EX_ALUSrc;
wire        EX_RegWrite;
wire        EX_RegDst;
wire        EX_BranchEQ;
wire        EX_BranchNEQ;
wire        EX_MemRead;
wire        EX_MemWrite;
wire        EX_MemtoReg;
wire [31:0] EX_PC_plus4;
wire [31:0] EX_sign_ext;
wire [31:0] EX_RSdata;
wire [31:0] EX_RTdata;

wire [3:0]  EX_ALUCtrl;
wire [31:0] EX_ALU_Src2;
wire [31:0] EX_ALU_res;
wire        EX_zero_flag;

wire [31:0] EX_PC_branch;
wire [4:0]  EX_WriteReg;

// MEM
wire        MEM_BranchEQ;
wire        MEM_BranchNEQ;
wire        MEM_MemRead;
wire        MEM_MemWrite;
wire        MEM_RegWrite;
wire        MEM_MemtoReg;
wire [31:0] MEM_PC_branch;
wire        MEM_zero_flag;
wire [31:0] MEM_ALU_res;
wire [31:0] MEM_RTdata;
wire [4:0]  MEM_WriteReg;

wire [31:0] MEM_MEMdata;
wire        MEM_PCSrc;

// WB
wire [4:0]  WB_WriteReg;
wire [31:0] WB_WriteData;
wire        WB_RegWrite;
wire        WB_MemtoReg;
wire [31:0] WB_MEMdata;
wire [31:0] WB_ALU_res;

// IF Stage
MUX_2to1 #(.size(32)) PC_SRC_MUX(
    .data0_i(IF_PC_plus4),
    .data1_i(MEM_PC_branch),
    .select_i(MEM_PCSrc),
    .data_o(IF_PC_in)
);

ProgramCounter PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .pc_in_i(stall ? IF_PC_out : IF_PC_in),
    .pc_out_o(IF_PC_out)
);

Adder PC_Plus4(
    .src1_i(IF_PC_out),
    .src2_i(32'd4),
    .sum_o(IF_PC_plus4)
);

Instruction_Memory IM(
    .addr_i(IF_PC_out),
    .instr_o(IF_instr)
);

Pipe_Reg #(.size(64)) IF_ID(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(stall ? {ID_PC_plus4, ID_instr} :
        ((MEM_PCSrc) ? 64'b0 :
        {IF_PC_plus4, IF_instr})),
    .data_o({ID_PC_plus4, ID_instr})
);

// ID stage
Decoder Control(
    .instr_op_i(ID_instr[31:26]),
    .ALUOp_o(ID_ALUOp),
    .ALUSrc_o(ID_ALUSrc),
    .RegWrite_o(ID_RegWrite),
    .RegDst_o(ID_RegDst),
    .BranchEQ_o(ID_BranchEQ),
    .BranchNEQ_o(ID_BranchNEQ),
    .MemRead_o(ID_MemRead),
    .MemWrite_o(ID_MemWrite),
    .MemtoReg_o(ID_MemtoReg)
);

Reg_File RF(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .RSaddr_i(ID_instr[25:21]),
    .RTaddr_i(ID_instr[20:16]),
    .RDaddr_i(WB_WriteReg),
    .RDdata_i(WB_WriteData),
    .RegWrite_i(WB_RegWrite),
    .RSdata_o(ID_RSdata),
    .RTdata_o(ID_RTdata)
);

Sign_Extend SE(
    .data_i(ID_instr[15:0]),
    .data_o(ID_sign_ext)
);

Pipe_Reg #(.size(148)) ID_EX(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i((MEM_PCSrc | stall) ? 148'b0 :
        {ID_RegDst, ID_ALUOp, ID_ALUSrc, 
        ID_BranchEQ, ID_BranchNEQ, ID_MemRead, ID_MemWrite, 
        ID_RegWrite, ID_MemtoReg, 
        ID_PC_plus4, ID_RSdata, ID_RTdata,
        ID_sign_ext, ID_instr[20:16], ID_instr[15:11]}),
    .data_o({EX_RegDst, EX_ALUOp, EX_ALUSrc, 
        EX_BranchEQ, EX_BranchNEQ, EX_MemRead, EX_MemWrite, 
        EX_RegWrite, EX_MemtoReg, 
        EX_PC_plus4, EX_RSdata, EX_RTdata,
        EX_sign_ext, EX_RTaddr, EX_RDaddr})
);

// EX stage
ALU_Ctrl ALU_Ctrl(
    .funct_i(EX_sign_ext[5:0]),
    .ALUOp_i(EX_ALUOp),
    .ALUCtrl_o(EX_ALUCtrl)
);

MUX_2to1 #(.size(32)) ALU_SRC2_MUX(
    .data0_i(EX_RTdata),
    .data1_i(EX_sign_ext),
    .select_i(EX_ALUSrc),
    .data_o(EX_ALU_Src2)
);

ALU ALU(
    .src1_i(EX_RSdata),
    .src2_i(EX_ALU_Src2),
    .ctrl_i(EX_ALUCtrl),
    .result_o(EX_ALU_res),
    .zero_o(EX_zero_flag)
);

Adder PC_Branch(
    .src1_i(EX_PC_plus4),
    .src2_i((EX_sign_ext << 2)),
    .sum_o(EX_PC_branch)
);

MUX_2to1 #(.size(5)) EX_WB_ADDR_MUX(
    .data0_i(EX_RTaddr),
    .data1_i(EX_RDaddr),
    .select_i(EX_RegDst),
    .data_o(EX_WriteReg)
);

Pipe_Reg #(.size(108)) EX_MEM(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i((MEM_PCSrc) ? 108'b0 :
        {EX_BranchEQ, EX_BranchNEQ, EX_MemRead, EX_MemWrite, 
        EX_RegWrite, EX_MemtoReg, 
        EX_PC_branch, EX_zero_flag, EX_ALU_res,
        EX_RTdata, EX_WriteReg}),
    .data_o({MEM_BranchEQ, MEM_BranchNEQ, MEM_MemRead, MEM_MemWrite, 
        MEM_RegWrite, MEM_MemtoReg, 
        MEM_PC_branch, MEM_zero_flag, MEM_ALU_res,
        MEM_RTdata, MEM_WriteReg})
);

// MEM stage
Data_Memory DM(
	.clk_i(clk_i), 
	.addr_i(MEM_ALU_res), 
	.data_i(MEM_RTdata), 
	.MemRead_i(MEM_MemRead), 
	.MemWrite_i(MEM_MemWrite), 
	.data_o(MEM_MEMdata)
);

assign MEM_PCSrc = (MEM_BranchEQ & MEM_zero_flag) | (MEM_BranchNEQ & ~MEM_zero_flag);

Pipe_Reg #(.size(71)) MEM_WB(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i({MEM_RegWrite, MEM_MemtoReg, 
        MEM_MEMdata, MEM_ALU_res, MEM_WriteReg}),
    .data_o({WB_RegWrite, WB_MemtoReg, 
        WB_MEMdata, WB_ALU_res, WB_WriteReg})
);

// WB stage
MUX_2to1 #(.size(32)) WB_DATA_MUX(
    .data0_i(WB_ALU_res),
    .data1_i(WB_MEMdata),
    .select_i(WB_MemtoReg),
    .data_o(WB_WriteData)
);

// stall
assign stall =
    (EX_RegWrite  & (EX_WriteReg  != 5'd0) & 
    ((EX_WriteReg  == ID_instr[25:21]) | 
    (EX_WriteReg  == ID_instr[20:16]))) ||
    (MEM_RegWrite  & (MEM_WriteReg  != 5'd0) & 
    ((MEM_WriteReg  == ID_instr[25:21]) | 
    (MEM_WriteReg  == ID_instr[20:16]))) ||
    (WB_RegWrite  & (WB_WriteReg  != 5'd0) & 
    ((WB_WriteReg  == ID_instr[25:21]) | 
    (WB_WriteReg  == ID_instr[20:16])));
endmodule