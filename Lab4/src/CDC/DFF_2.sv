module DFF_2(
    input clk2,
    input rst2,
    input in,
    output logic out
);


always@(posedge clk2)begin
    if(rst2)begin
        out<=1'b0;
    end
    else begin
        out<=in;
    end
end

endmodule
