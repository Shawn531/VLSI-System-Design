module DFF_5(
    input clk,
    input rst,
    input [4:0] in,
    output logic [4:0] out
);


always@(posedge clk)begin
    if(rst)begin
        out<=5'b0;
    end
    else begin
        out<=in;
    end
end

endmodule
