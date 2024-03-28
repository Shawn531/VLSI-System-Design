module sync_r2w(
        output logic [4:0] rptr_wclk,
        input  logic [4:0] rptr,
        input  wclk, 
        input  wrst
);

logic [4:0] DFF_wire;

DFF_5 DFF_5_0(
        .clk(wclk),
        .rst(wrst),
        .in(rptr),
        .out(DFF_wire)
    );

DFF_5 DFF_5_1(
        .clk(wclk),
        .rst(wrst),
        .in(DFF_wire),
        .out(rptr_wclk)
    );

    

endmodule