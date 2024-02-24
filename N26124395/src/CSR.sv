module CSR (
    input clk, rst,
    input [11:0] imm_ext,
    input [31:0] E_pc,
    input stall,
    input next_pc_sel,
    output logic [31:0] csr_o
);

//可以優化減少bits
parameter   RDINSTRETH = 12'b110010000010,
            RDINSTRET =  12'b110000000010,
            RDCYCLEH  =  12'b110010000000,
            RDCYCLE =    12'b110000000000;

logic [63:0] cycle,instret;

always @(posedge clk or posedge rst) begin
    if (rst) cycle<=64'b0;
    else cycle<=cycle+64'b1;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        instret<=64'b1;
    end
    else begin;
	if(E_pc!=32'b0)instret<=instret+64'b1;
    // if(stall==1'b0 && next_pc_sel==1'b0)instret<=instret+64'b1;
    end
end




always @(*) begin
    case (imm_ext)
        RDINSTRETH    : csr_o = instret[63:32];
        RDINSTRET     : csr_o = instret[31:0];
        RDCYCLEH    : csr_o = cycle[63:32];
        RDCYCLE    : csr_o = cycle[31:0];
        default: csr_o = 32'b0;

    endcase
end
endmodule
