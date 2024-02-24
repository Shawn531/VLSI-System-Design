module Reg_EXE_MEM(
    input clk,
    input rst,
    input [31:0] alu_out,
    input [31:0] rs2_data,
    input [31:0] csr,
    input [31:0] op1,
    input [31:0] op2,
    output reg [31:0] alu_out_out,
    output reg [31:0] rs2_data_out,
    output logic [31:0] op1_RegM,
    output logic [31:0] op2_RegM,
    output logic [31:0] csr_out
);
always @(posedge clk or posedge rst) begin
    if(rst)begin
        alu_out_out<=32'd0;
        rs2_data_out<=32'd0;
        op1_RegM<=32'b0;
        op2_RegM<=32'b0;
        csr_out<=32'd0;
    end
    else begin
        alu_out_out<=alu_out;
        rs2_data_out<=rs2_data;
        op1_RegM<=op1;
        op2_RegM<=op2;
        csr_out<=csr;
    end
end
endmodule
