module DFF_1(
    input clk,
    input rst,
    input in,
    output logic out
);


always@(posedge clk)begin
    if(rst)begin
        out<=1'b0;
    end
    else begin
        out<=in;
    end
end

endmodule
