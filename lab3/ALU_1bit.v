// 112550148
`timescale 1ns/1ps
`include "MUX_4to1.v"

module ALU_1bit(
	input				src1,       //1 bit source 1  (input)
	input				src2,       //1 bit source 2  (input)
	input				less,       //1 bit less      (input)
	input 				Ainvert,    //1 bit A_invert  (input)
	input				Binvert,    //1 bit B_invert  (input)
	input 				cin,        //1 bit carry in  (input)
	input 	    [2-1:0] operation,  //2 bit operation (input)
	output          	result,     //1 bit result    (output)
	output reg         	cout        //1 bit carry out (output)
	);

wire a, b;
assign a = Ainvert == 1'b0 ? src1 : ~src1;
assign b = Binvert == 1'b0 ? src2 : ~src2;

always @(*) begin
	cout <= (a & b) | (b & cin) | (cin & a);
end

MUX_4to1 mux_res (
	.src1(a & b),
	.src2(a | b),
	.src3(a ^ b ^ cin),
	.src4(less),
	.select(operation),
	.result(result)
);
	
endmodule
