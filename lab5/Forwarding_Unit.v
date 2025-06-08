// 112550148
module Forwarding_Unit(
    regwrite_mem,
    regwrite_wb,
    idex_regs,
    idex_regt,
    exmem_regd,
    memwb_regd,
    forwarda,
    forwardb
);

// TO DO
input           regwrite_mem;
input           regwrite_wb;
input  [4:0]   idex_regs;
input  [4:0]   idex_regt;
input  [4:0]    exmem_regd;
input  [4:0]    memwb_regd;
output reg [1:0] forwarda;
output reg [1:0] forwardb;

always @(*) begin
    if (regwrite_mem && (exmem_regd != 5'd0) && (exmem_regd == idex_regs))
        forwarda = 2'b01;
    else if (regwrite_wb && (memwb_regd != 5'd0) && (memwb_regd == idex_regs))
        forwarda = 2'b10;
    else
        forwarda = 2'b00;

    if (regwrite_mem && (exmem_regd != 5'd0) && (exmem_regd == idex_regt))
        forwardb = 2'b01;
    else if (regwrite_wb && (memwb_regd != 5'd0) && (memwb_regd == idex_regt))
        forwardb = 2'b10;
    else
        forwardb = 2'b00;
end

endmodule