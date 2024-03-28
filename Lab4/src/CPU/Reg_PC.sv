module Reg_PC (
input clk,
input rst,
input stall,
input [31:0] next_pc,
output reg [31:0] current_pc,
input stall_IF,
input wfi_signal,
input intr_ex,
input intr_t,
input intr_end_ex,
input [31:0] pc_csr,
input [31:0] D_pc
);
logic [31:0] past_pc;
always @(posedge clk ) begin
    if(rst) begin
        current_pc<=32'd0;
        past_pc<=32'd0;
    end
    else begin
        past_pc<=current_pc;
        if(stall || stall_IF /*|| wfi_signal*/) current_pc<=current_pc;
        else if(wfi_signal) current_pc<=current_pc;
        else if(intr_ex || intr_end_ex || intr_t) current_pc<=pc_csr;
        else current_pc<=next_pc;
    end
end

endmodule
