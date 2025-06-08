// 112550148
module Hazard_Detection(
    memread,
    instr_i,
    idex_regt,
    branch,
    pcwrite,
    ifid_write,
    ifid_flush,
    idex_flush,
    exmem_flush
);

// TO DO
input           memread;
input  [4:0]    idex_regt;
input  [31:0]   instr_i;
input           branch;
output          pcwrite;
output          ifid_write;
output          ifid_flush;
output          idex_flush;
output          exmem_flush;

wire uses_rt;
wire stall;

assign uses_rt = (instr_i[31:26] == 6'b000000) || (instr_i[31:26] == 6'b000101) || (instr_i[31:26] == 6'b000100);
assign stall = memread && (idex_regt != 0) && 
                        ((idex_regt == instr_i[25:21]) || (uses_rt && (idex_regt == instr_i[20:16])));

assign pcwrite = ~stall;
assign ifid_write = ~stall;
assign ifid_flush = branch;
assign idex_flush = branch | stall;
assign exmem_flush = branch;

endmodule