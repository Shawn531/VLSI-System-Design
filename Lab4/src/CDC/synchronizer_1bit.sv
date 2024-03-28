module synchronizer_1bit(
    input clk,
    input rst,
    input clk2,
    input rst2,
    input in,
    output logic out
);
logic tmp;

always@(posedge clk2  )begin
    if(rst2)begin
        tmp<=1'b0;
        out<=1'b0;
    end
    else begin
        tmp<=in;
        out<=tmp;
    end
end

endmodule
