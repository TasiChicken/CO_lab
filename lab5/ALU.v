// 112550148
module ALU(
    src1_i,
	src2_i,
	ctrl_i,
	result_o,
	zero_o
	);
     
// TO DO
input  wire [31:0] src1_i;
input  wire [31:0] src2_i;
input  wire [3:0]  ctrl_i;
output reg  [31:0] result_o;
output reg         zero_o;

always @(*) begin
	case (ctrl_i)
		4'b0010: result_o = src1_i + src2_i;               // add
		4'b0110: result_o = src1_i - src2_i;               // sub
		4'b0000: result_o = src1_i & src2_i;               // and
		4'b0001: result_o = src1_i | src2_i;               // or
		4'b0111: result_o = ($signed(src1_i) < $signed(src2_i)) ? 32'd1 : 32'd0; // slt
		4'b1100: result_o = ~(src1_i | src2_i);            // nor
	endcase

	zero_o = (result_o == 32'd0) ? 1'b1 : 1'b0;          // zero flag
end

endmodule