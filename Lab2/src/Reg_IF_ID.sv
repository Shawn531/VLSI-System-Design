module Reg_IF_ID(
    input clk,
    input rst,
    input stall,
    input next_pc_sel, //不確定    
    input [31:0] pc,
    input [31:0] inst,
    output reg [31:0] pc_out,
    output reg [31:0] inst_out,
    input stall_IF

);
always@(posedge clk or posedge rst)begin
    if(rst)begin
        pc_out<=32'd0;
        inst_out<=32'd0;
    end
    else begin
        // if(stall || stall_IF)begin
        //     pc_out<=pc_out;
        //     // inst_out<=inst_out;
        //     inst_out<=inst;
        // end
        // else if(next_pc_sel)begin
        //     pc_out<=32'd0;
        //     inst_out<=32'd0; //寫在外面 不然會delay
        // end
        // else begin
        //     pc_out<=pc;
        //     inst_out<=inst;
        // end

        if(stall_IF)begin
            pc_out<=pc_out;
            // inst_out<=inst_out;
            inst_out<=inst_out;
        end
        else begin
            if(stall)begin
                pc_out<=pc_out;
                // inst_out<=inst_out;
                inst_out<=inst_out;
            end
            else if(next_pc_sel)begin
                pc_out<=32'd0;
                inst_out<=32'd0;
            end
            else begin
                pc_out<=pc;
                inst_out<=inst;
            end
        end
    end
end

endmodule
