// 112550148
module Shift_Left_Two_32(
    data_i,
    data_o
    );

// I/O ports                    
input [32-1:0] data_i;

output reg [32-1:0] data_o;

// Internal Signals


// Main function
always @(*) begin
    data_o <= data_i << 2;
end
     
endmodule
