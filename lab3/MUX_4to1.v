// 112550148
`timescale 1ns/1ps

module MUX_4to1(
	input			src1,
	input			src2,
	input			src3,
	input			src4,
	input   [2-1:0] select,
	output reg 		result
	);

always @(*) begin
	result <= (select == 2'b00) ? src1 : 
				(select == 2'b01) ? src2 : 
				(select == 2'b10) ? src3 : 
									src4;	
end

endmodule

