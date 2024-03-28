module sync_w2r(
        output logic [4:0] wptr_rclk,
        input  logic [4:0] wptr,
        input  rclk, 
        input  rrst
);

logic [4:0] DFF_wire;

DFF_5 DFF_5_0(
        .clk(rclk),
        .rst(rrst),
        .in(wptr),
        .out(DFF_wire)
    );

DFF_5 DFF_5_1(
        .clk(rclk),
        .rst(rrst),
        .in(DFF_wire),
        .out(wptr_rclk)
    );

    

endmodule