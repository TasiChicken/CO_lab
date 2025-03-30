// 112550148
`timescale 1ns/1ps
`include "ALU_1bit.v"

module ALU(
	input                   rst_n,         // negative reset            (input)
	input	     [32-1:0]	src1,          // 32 bits source 1          (input)
	input	     [32-1:0]	src2,          // 32 bits source 2          (input)
	input 	     [ 4-1:0] 	ALU_control,   // 4 bits ALU control input  (input)
	output       [32-1:0]	result,        // 32 bits result            (output)
	output reg              zero,          // 1 bit when the output is 0, zero must be set (output)
	output reg              cout,          // 1 bit carry out           (output)
	output reg              overflow       // 1 bit overflow            (output)
	);


	wire [31:0] internal_cout;
	always @(*) begin
		if (!rst_n) 
			cout <= 0;
		else if (ALU_control[1:0] != 2'b10)
			cout <= 0;
		else
			cout <= internal_cout[31];
	end

	always @(*) begin
		if (!rst_n) 
			overflow <= 0;
		else if (ALU_control[1:0] != 2'b10)
			overflow <= 0;
		else
			overflow <= internal_cout[30] ^ internal_cout[31];
	end

	always @(*) begin
		if (!rst_n) 
			zero <= 0;
		else
			zero <= ~|result;
	end


	genvar i;
	generate
		for(i = 0; i < 32; i = i + 1) begin : ALU_block
			if (i == 0) begin
				ALU_1bit alu (
					.src1(src1[i]),
					.src2(src2[i]),
					// consider overflowing
					.less(src1[31] ^ ~src2[31] ^ internal_cout[31]),
					.Ainvert(ALU_control[3]),
					.Binvert(ALU_control[2]),
					.cin(ALU_control[2]),
					.operation(ALU_control[1:0]),
					.result(result[i]),
					.cout(internal_cout[i]) 
				);
			end
			else begin
				ALU_1bit alu (
					.src1(src1[i]),
					.src2(src2[i]),
					.less(1'b0),
					.Ainvert(ALU_control[3]),
					.Binvert(ALU_control[2]),
					.cin(internal_cout[i - 1]),
					.operation(ALU_control[1:0]),
					.result(result[i]),
					.cout(internal_cout[i]) 
				);
			end
		end
	endgenerate
endmodule