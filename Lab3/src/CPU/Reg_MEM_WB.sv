module Reg_MEM_WB(
    input clk,
    input rst,
    input [31:0] alu_out,
    input [31:0] ld_data,
    output reg [31:0] alu_out_out,
    output logic [31:0] ld_data_RegW,

    output logic [31:0] ld_data_orignal,
    input stall_IF,
    input rvalid
);
always @(posedge clk ) begin
    if(rst)begin
        alu_out_out<=32'd0;
        ld_data_RegW<=32'b0;
        ld_data_orignal<=32'b0;
    end
    else begin
        if(stall_IF) begin
            if(rvalid)begin //由M1的rvalid去判斷要不要拿資料
                alu_out_out<=alu_out_out; //對稱姓 由27行得到
                ld_data_RegW<=ld_data;

                ld_data_orignal<=ld_data_orignal;
            end
            else begin
                alu_out_out<=alu_out_out;
                ld_data_RegW<=ld_data_RegW;

                ld_data_orignal<=ld_data_orignal;
            end
        end
        else begin
            alu_out_out<=alu_out;//拿新資料
            ld_data_RegW<=ld_data_RegW; //原本是要拿新資料，但是在stall_IF=1 and rvalid=1 先存到REG了
            
            ld_data_orignal<=ld_data_RegW;
        end
    end
end
endmodule
