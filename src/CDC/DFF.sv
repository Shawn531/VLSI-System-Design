module DFF(
    input clk,
    input rst,
    input [31:0] in,
    output logic [31:0] out
);


always@(posedge clk)begin
    if(rst)begin
        out<=32'b0;
    end
    else begin
        out<=in;
    end
end

endmodule
