// 112550148
module ALU_Ctrl(
    funct_i,
    ALUOp_i,
    ALUCtrl_o
);
          
// TO DO
input      [6-1:0] funct_i;
input      [2-1:0] ALUOp_i;

output reg [4-1:0] ALUCtrl_o;

always @(*) begin
    case (ALUOp_i)
        2'b00: ALUCtrl_o = 4'b0010; // lw sw / add
        2'b01: ALUCtrl_o = 4'b0110; // beq bne / sub
        2'b10: begin                // R-type
            case (funct_i)
                6'b100010: ALUCtrl_o = 4'b0010; // add
                6'b100000: ALUCtrl_o = 4'b0110; // sub
                6'b100101: ALUCtrl_o = 4'b0000; // and
                6'b100100: ALUCtrl_o = 4'b0001; // or
                6'b101010: ALUCtrl_o = 4'b1100; // nor
                6'b100111: ALUCtrl_o = 4'b0111; // slt
            endcase
        end
    endcase
end

endmodule
