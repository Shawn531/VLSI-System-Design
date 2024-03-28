module synchronizer_1bit_3(
    input clk,
    input rst,
    input clk2,
    input rst2,
    input in,
    output logic out
);
logic tmp, tmp1;

always@(posedge clk2 )begin
    if(rst2)begin
        tmp<=1'b0;
        tmp1<=1'b0;
        out<=1'b0;
    end
    else begin
        tmp<=in;
        tmp1<=tmp;
        out<=tmp1;
    end
end

endmodule
