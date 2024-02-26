// `include "AXI_define.svh"
module ROM_Wrapper (
    input clock,
	input reset,
     // READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output ARREADY,
	// READ DATA
	output [`AXI_IDS_BITS-1:0] RID,
	output [`AXI_DATA_BITS-1:0] RDATA,
	output [1:0] RRESP,
	output RLAST,
	output RVALID,
	input RREADY,
    // ROM
    input [`AXI_DATA_BITS-1:0] DO,
    output logic CS,
    output logic OE,
    output logic [11:0] A
);

// Wire
logic [31:0] address_out;

assign A = address_out[13:2];

Slave_Read_ROM SR(.ACLK(clock), .ARESETn(~reset),
            .ARID(ARID), .ARADDR(ARADDR), .ARLEN(ARLEN), .ARSIZE(ARSIZE), 
            .ARBURST(ARBURST), .ARVALID(ARVALID), .ARREADY(ARREADY),

            .RID(RID), .RDATA(RDATA), .RRESP(RRESP),
            .RLAST(RLAST), .RVALID(RVALID), .RREADY(RREADY),

            .address_out(address_out), .data_in(DO), .select(2'd1)
            );

always@(posedge clock)begin
  if(!reset) begin OE<=1'b0;CS<=1'b1; end
  else begin OE<=1'b1; CS<=1'b1; end
end


endmodule
