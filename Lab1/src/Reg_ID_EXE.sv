module Reg_ID_EXE(
    input clk,
    input rst,
    input stall,
    input next_pc_sel, //不確定    
    input [31:0] pc,
    input [31:0] rs1_data,
    input [31:0] rs2_data,
    input [31:0] sext_imm,
    output reg [31:0] pc_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] sext_imm_out
);
always@(posedge clk or posedge rst)begin
    if(rst)begin
        pc_out<=32'd0;
        rs1_data_out<=32'd0;
        rs2_data_out<=32'd0;
        sext_imm_out<=32'd0;
    end
    else begin
        if(stall || next_pc_sel)begin
            pc_out<=32'd0;
            rs1_data_out<=32'd0;
            rs2_data_out<=32'd0;
            sext_imm_out<=32'd0;
        end
        else begin
            pc_out<=pc;
            rs1_data_out<=rs1_data;
            rs2_data_out<=rs2_data;
            sext_imm_out<=sext_imm;
        end
    end
end
endmodule
