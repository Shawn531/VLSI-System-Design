//`include "/home/user2/vsd23/vsd2329/N26124395/sim/SRAM/SRAM.v"
//`include "Bridge_Read.sv"
//`include "Bridge_Write.sv"
// `include "AXI_define.svh"
module SRAM_wrapper (
  input ACLK,
	input ARESETn,
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
    // WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST,
	input AWVALID,
	output AWREADY,
	// WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output WREADY,
	// WRITE RESPONSE
	output [`AXI_IDS_BITS-1:0] BID,
	output [1:0] BRESP,
	output BVALID,
	input BREADY
);

logic CS;
logic OE;
logic [3:0] WEB;
logic [13:0] A;
logic [31:0] DI;
logic [31:0] DO;

logic [31:0] address_out, data_in;
logic [31:0] data_out_W, address_out_W;
logic [3:0] w_en_out_M;
logic isnot_FREE;
logic [1:0] select;
logic [1:0] select_reg;
Slave_Read SR(.ACLK(ACLK), .ARESETn(ARESETn),
            .ARID(ARID), .ARADDR(ARADDR), .ARLEN(ARLEN), .ARSIZE(ARSIZE), 
            .ARBURST(ARBURST), .ARVALID(ARVALID), .ARREADY(ARREADY),

            .RID(RID), .RDATA(RDATA), .RRESP(RRESP),
            .RLAST(RLAST), .RVALID(RVALID), .RREADY(RREADY),

            .address_out(address_out), .data_in(data_in), .select(select)
            );

Slave_Write SW(.ACLK(ACLK), .ARESETn(ARESETn),
            .AWID(AWID), .AWADDR(AWADDR), .AWLEN(AWLEN), .AWSIZE(AWSIZE), 
            .AWBURST(AWBURST), .AWVALID(AWVALID), .AWREADY(AWREADY),

            .WDATA(WDATA), .WSTRB(WSTRB), .WLAST(WLAST), .WVALID(WVALID), .WREADY(WREADY),

            .BID(BID), .BRESP(BRESP), .BVALID(BVALID), .BREADY(BREADY),

            .data_out(data_out_W), .address_out(address_out_W), .w_en_out(w_en_out_M), .isnot_FREE(isnot_FREE), .select(select)
            );
///////for vip checking
logic state, nstate;
localparam IDLE=1'd0, BUSY=1'd1;
localparam READ=2'd1, WRITE=2'd2, FREE=2'd0, WRONG=2'd3;


always_ff@(posedge ACLK)begin
	if(ARESETn) state<=IDLE;
	else state<=nstate;
end
always@(*)begin
	case(state)
	IDLE:begin
		if(ARVALID || AWVALID) nstate=BUSY;
		else nstate=IDLE;
	end
	BUSY:begin
		if(RLAST || WLAST) nstate=IDLE;
		else nstate=BUSY;
	end
	endcase
end
always@(*)begin
	case(state)
	IDLE:begin
		if(AWVALID) begin
			if(~ARVALID)select=WRITE;
			else select=WRONG;
		end
		else if(ARVALID) begin
			if(~AWVALID) select=READ;
			else select=WRONG;
		end
		else begin
			select=FREE;
		end
	end
	BUSY:begin
		select=select_reg;
	end
	endcase
end
always_ff@(posedge ACLK)begin
	if(ARESETn) begin
		select_reg<=2'd0;
	end
	else begin
		case(state)
		IDLE: select_reg<=select;
		BUSY: select_reg<=select_reg;
		endcase
	end
end
//////////



assign A=(isnot_FREE)?address_out_W[15:2]:address_out[15:2];


assign WEB=~w_en_out_M;
assign DI=data_out_W;
assign data_in=DO;

always@(posedge ACLK)begin
  if(ARESETn) begin OE<=1'b0;CS<=1'b1; end
  else begin OE<=1'b1; CS<=1'b1; end
end

SRAM i_SRAM (
  .A0   (A[0]  ),
  .A1   (A[1]  ),
  .A2   (A[2]  ),
  .A3   (A[3]  ),
  .A4   (A[4]  ),
  .A5   (A[5]  ),
  .A6   (A[6]  ),
  .A7   (A[7]  ),
  .A8   (A[8]  ),
  .A9   (A[9]  ),
  .A10  (A[10] ),
  .A11  (A[11] ),
  .A12  (A[12] ),
  .A13  (A[13] ),
  .DO0  (DO[0] ),
  .DO1  (DO[1] ),
  .DO2  (DO[2] ),
  .DO3  (DO[3] ),
  .DO4  (DO[4] ),
  .DO5  (DO[5] ),
  .DO6  (DO[6] ),
  .DO7  (DO[7] ),
  .DO8  (DO[8] ),
  .DO9  (DO[9] ),
  .DO10 (DO[10]),
  .DO11 (DO[11]),
  .DO12 (DO[12]),
  .DO13 (DO[13]),
  .DO14 (DO[14]),
  .DO15 (DO[15]),
  .DO16 (DO[16]),
  .DO17 (DO[17]),
  .DO18 (DO[18]),
  .DO19 (DO[19]),
  .DO20 (DO[20]),
  .DO21 (DO[21]),
  .DO22 (DO[22]),
  .DO23 (DO[23]),
  .DO24 (DO[24]),
  .DO25 (DO[25]),
  .DO26 (DO[26]),
  .DO27 (DO[27]),
  .DO28 (DO[28]),
  .DO29 (DO[29]),
  .DO30 (DO[30]),
  .DO31 (DO[31]),
  .DI0  (DI[0] ),
  .DI1  (DI[1] ),
  .DI2  (DI[2] ),
  .DI3  (DI[3] ),
  .DI4  (DI[4] ),
  .DI5  (DI[5] ),
  .DI6  (DI[6] ),
  .DI7  (DI[7] ),
  .DI8  (DI[8] ),
  .DI9  (DI[9] ),
  .DI10 (DI[10]),
  .DI11 (DI[11]),
  .DI12 (DI[12]),
  .DI13 (DI[13]),
  .DI14 (DI[14]),
  .DI15 (DI[15]),
  .DI16 (DI[16]),
  .DI17 (DI[17]),
  .DI18 (DI[18]),
  .DI19 (DI[19]),
  .DI20 (DI[20]),
  .DI21 (DI[21]),
  .DI22 (DI[22]),
  .DI23 (DI[23]),
  .DI24 (DI[24]),
  .DI25 (DI[25]),
  .DI26 (DI[26]),
  .DI27 (DI[27]),
  .DI28 (DI[28]),
  .DI29 (DI[29]),
  .DI30 (DI[30]),
  .DI31 (DI[31]),
  .CK   (ACLK  ),
  .WEB0 (WEB[0]),
  .WEB1 (WEB[1]),
  .WEB2 (WEB[2]),
  .WEB3 (WEB[3]),
  .OE   (OE    ),
  .CS   (CS    )
);
endmodule
