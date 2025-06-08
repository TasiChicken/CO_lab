// 112550148
module ALU_Ctrl(
        funct_i,
        ALUOp_i,
        ALUCtrl_o,
        src_shamt_o
        );
          
// I/O ports 
input      [6-1:0] funct_i;
input      [2-1:0] ALUOp_i;

output reg [5-1:0] ALUCtrl_o;
output reg src_shamt_o;
     
// Internal Signals


// Main function
always @(*) begin
        // I type
        if (ALUOp_i == 2'b00) //add
                {src_shamt_o, ALUCtrl_o} <= 6'b000010;
        else if(ALUOp_i == 2'b01) //sub
                {src_shamt_o, ALUCtrl_o} <= 6'b000110;
        // R type
        else if(funct_i == 6'b100010) //add
                {src_shamt_o, ALUCtrl_o} <= 6'b000010;
        else if(funct_i == 6'b100000) //sub
                {src_shamt_o, ALUCtrl_o} <= 6'b000110;
        else if(funct_i == 6'b100101) //and
                {src_shamt_o, ALUCtrl_o} <= 6'b000000;
        else if(funct_i == 6'b100100) //or
                {src_shamt_o, ALUCtrl_o} <= 6'b000001;
        else if(funct_i == 6'b101010) //nor
                {src_shamt_o, ALUCtrl_o} <= 6'b001100;
        else if(funct_i == 6'b100111) //slt
                {src_shamt_o, ALUCtrl_o} <= 6'b000111;
        
        else if(funct_i == 6'b000000) //sll
                {src_shamt_o, ALUCtrl_o} <= 6'b110000;
        else if(funct_i == 6'b000010) //srl
                {src_shamt_o, ALUCtrl_o} <= 6'b110001;
        else if(funct_i == 6'b000100) //sllv
                {src_shamt_o, ALUCtrl_o} <= 6'b010000;
        else if(funct_i == 6'b000110) //srlv
                {src_shamt_o, ALUCtrl_o} <= 6'b010001;
end  

endmodule