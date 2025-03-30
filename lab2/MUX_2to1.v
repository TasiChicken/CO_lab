// 112550148
`timescale 1ns/1ps

module MUX_2to1(
	input      src1,
	input      src2,
	input	   select,
	output reg result
	);

	always @(*) begin
		result <= (select == 1'b0) ? src1 : src2;
	end
	//assign result = (select == 1'b0) ? src1 : src2;

endmodule

