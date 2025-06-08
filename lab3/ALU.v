// 112550148
`timescale 1ns/1ps
`include "ALU_1bit.v"

module ALU(
	input	     [32-1:0]	src1_i,         // 32 bits source 1          (input)
	input	     [32-1:0]	src2_i,         // 32 bits source 2          (input)
	input 	     [4:0] 		ctrl_i,   		// 5 bits ALU control input  (input)
	output reg   [32-1:0]	result_o,       // 32 bits result            (output)
	output reg              zero_o,         // 1 bit when the output is 0, zero must be set (output)
	output reg              overflow       	// 1 bit overflow            (output)
	);


wire [31:0] 	internal_cout;
wire [32-1:0]	internal_res;

always @(*) begin
	if (ctrl_i[1:0] != 2'b10)
		overflow <= 0;
	else
		overflow <= internal_cout[30] ^ internal_cout[31];
end

always @(*) begin
	zero_o <= ~|internal_res;
end

wire [32-1:0] test = src2_i << src1_i;

always @(*) begin
	if (ctrl_i == 5'b10000) //sllbe
		result_o <= src2_i << src1_i;
	else if (ctrl_i == 5'b10001) //srl
		result_o <= src2_i >> src1_i;
	else
		result_o <= internal_res;
end


genvar i;
generate
	for(i = 0; i < 32; i = i + 1) begin : ALU_block
		if (i == 0) begin
			ALU_1bit alu (
				.src1(src1_i[i]),
				.src2(src2_i[i]),
				// consider overflowing
				.less(src1_i[31] ^ ~src2_i[31] ^ internal_cout[31]),
				.Ainvert(ctrl_i[3]),
				.Binvert(ctrl_i[2]),
				.cin(ctrl_i[2]),
				.operation(ctrl_i[1:0]),
				.result(internal_res[i]),
				.cout(internal_cout[i]) 
			);
		end
		else begin
			ALU_1bit alu (
				.src1(src1_i[i]),
				.src2(src2_i[i]),
				.less(1'b0),
				.Ainvert(ctrl_i[3]),
				.Binvert(ctrl_i[2]),
				.cin(internal_cout[i - 1]),
				.operation(ctrl_i[1:0]),
				.result(internal_res[i]),
				.cout(internal_cout[i]) 
			);
		end
	end
endgenerate
endmodule