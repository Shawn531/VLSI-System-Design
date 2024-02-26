module synchronizer_32bit_logic(
    input clk,
    input rst,
    input clk2,
    input rst2,
    input data_enable_A,
    input [31:0] in,
    output logic [31:0] out
);
//DATA
logic [31:0] data_wire,data_wire_mux;
//ENABLE
logic data_enable_wire1,data_enable_wire2;
logic data_enable_B;

DFF databus_a(
        .clk(clk),
        .rst(rst),
        .in(in),
        .out(data_wire)
    );

DFF_1 FFA(
        .clk(clk),
        .rst(rst),
        .in(data_enable_A),
        .out(data_enable_wire1)
    );

DFF_1 FFB1(
        .clk(clk2),
        .rst(rst2),
        .in(data_enable_wire1),
        .out(data_enable_wire2)
    );


DFF_1 FFB2(
        .clk(clk2),
        .rst(rst2),
        .in(data_enable_wire2),
        .out(data_enable_B)
    );

    
//mux
assign data_wire_mux=(data_enable_B)?data_wire:out;

DFF databus_b(
        .clk(clk2),
        .rst(rst2),
        .in(data_wire_mux),
        .out(out)
    );


// always@(posedge clk2 or posedge rst2)begin
//     if(rst2)begin
//         tmp<=32'b0;
//         tmp1<=32'b0;
//         out<=32'b0;
//     end
//     else begin
//         tmp<=in;
//         tmp1<=tmp;
//         out<=tmp1;
//     end
// end

endmodule
