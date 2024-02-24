module Reg_MEM_WB(
    input clk,
    input rst,
    input [31:0] alu_out,
    input [31:0] ld_data,
    output reg [31:0] alu_out_out
);
always @(posedge clk or posedge rst) begin
    if(rst)begin
        alu_out_out<=32'd0;
    end
    else begin
        alu_out_out<=alu_out;
    end
end
endmodule
