// 112550148
`include "FA_1bit.v"

module Adder(
	src1_i,
	src2_i,
	sum_o
	);
     
// I/O ports
input  [32-1:0]  src1_i;
input  [32-1:0]	 src2_i;

output [32-1:0]	 sum_o;

// Internal Signals
wire [31:0] internal_cout; 

// Main function
FA_1bit FAs[31:0](
	.a(src1_i),
	.b(src2_i),
    .cin({internal_cout[30:0], 1'b0}),
	.sum(sum_o),
    .cout(internal_cout)
);

endmodule                  