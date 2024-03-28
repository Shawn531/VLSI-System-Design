 `include "AXI_define.svh"
module ROM_Wrapper (
  input clock,
	input reset,
  input clock2,
	input reset2,
     // READ ADDRESS
	input [`AXI_ID_BITS-1:0] ARID,//4
	input [`AXI_ADDR_BITS-1:0] ARADDR,//32
	input [`AXI_LEN_BITS-1:0] ARLEN,//4
	input [`AXI_SIZE_BITS-1:0] ARSIZE,//3
	input [1:0] ARBURST,//2
	input ARVALID,//1
	output ARREADY,//1
	// READ DATA
	output [`AXI_ID_BITS-1:0] RID,
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
// wire 2
logic [`AXI_ID_BITS-1:0] ARID_out;//4
logic [`AXI_ADDR_BITS-1:0] ARADDR_out;//32
logic [`AXI_LEN_BITS-1:0] ARLEN_out;//4
logic [`AXI_SIZE_BITS-1:0] ARSIZE_out;//3
logic [1:0] ARBURST_out;//2
logic ARVALID_out;//1
logic ARREADY_out;//1
// READ DATA
logic [`AXI_ID_BITS-1:0] RID_out;
logic [`AXI_DATA_BITS-1:0] RDATA_out;
logic [1:0] RRESP_out;
logic RLAST_out;
logic RVALID_out;
logic RREADY_out;

//logic

AR_wrapper AR(
        .clock(clock),
        .clock2(clock2),//
        .reset(~reset),
        .reset2(~reset2),//
        .ARID   (ARID),
        .ARADDR (ARADDR),
        .ARLEN  (ARLEN),
        .ARSIZE (ARSIZE),
        .ARBURST(ARBURST),
        .ARVALID(ARVALID),
        //
        .ARREADY_out(ARREADY),// from slave
        ////
        .ARID_out   (ARID_out),
        .ARADDR_out (ARADDR_out),
        .ARLEN_out  (ARLEN_out),
        .ARSIZE_out (ARSIZE_out),
        .ARBURST_out(ARBURST_out),
        .ARVALID_out(ARVALID_out),
        //
        .ARREADY(ARREADY_out)// from master
);

R_wrapper R(
        .clock(clock),
        .clock2(clock2),//
        .reset(~reset),
        .reset2(~reset2),//
        .RID    (RID_out),
        .RDATA  (RDATA_out),
        .RRESP  (RRESP_out),
        .RLAST  (RLAST_out),
        .RVALID (RVALID_out),
        //
        .RREADY_out (RREADY_out),
        ////
        .RID_out   (RID),
        .RDATA_out  (RDATA),
        .RRESP_out  (RRESP),
        .RLAST_out  (RLAST),
        .RVALID_out (RVALID),
        //
        .RREADY(RREADY)
);



Slave_Read_ROM SR(.ACLK(clock2), .ARESETn(~reset2),
            .ARID(ARID_out), .ARADDR(ARADDR_out), .ARLEN(ARLEN_out), .ARSIZE(ARSIZE_out), 
            .ARBURST(ARBURST_out), .ARVALID(ARVALID_out), .ARREADY(ARREADY_out),

            .RID(RID_out), .RDATA(RDATA_out), .RRESP(RRESP_out),
            .RLAST(RLAST_out), .RVALID(RVALID_out), .RREADY(RREADY_out),

            .address_out(address_out), .data_in(DO), .select(2'd1)
            );

always@(posedge clock2)begin
  if(!reset2) begin OE<=1'b0;CS<=1'b1; end
  else begin OE<=1'b1; CS<=1'b1; end
end


endmodule
