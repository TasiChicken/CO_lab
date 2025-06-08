// 112550148
module FA_1bit(
	a,
	b,
    cin,
	sum,
    cout
	);
     
// I/O ports
input  a;
input  b;
input  cin;
output reg sum;
output reg cout;

// Internal Signals

// Main function
always @(*) begin
	cout <= (a & b) | (b & cin) | (cin & a);
	sum <= a ^ b ^ cin;
end

endmodule                  