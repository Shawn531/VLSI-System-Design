`include "AXI_define.svh"
module Master_Read(
	input ACLK,
	input ARESETn,

	//READ ADDRESS
	output logic [`AXI_ID_BITS-1:0] ARID,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR,
	output logic [`AXI_LEN_BITS-1:0] ARLEN,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE,
	output logic [1:0] ARBURST,
	output logic ARVALID,
	input  ARREADY,
	
	//READ DATA
	input  [`AXI_ID_BITS-1:0] RID,
	input  [`AXI_DATA_BITS-1:0] RDATA,
	input  [1:0] RRESP,
	input  RLAST,
	input  RVALID,
	output logic RREADY,

	//Some input signal from CPU
	input read_signal,
	input [31:0] address_in,
	input [`AXI_ID_BITS-1:0] id_in,

	//Some output data to CPU
	output logic [31:0] data_out,
	output logic stall_IF,
	output logic rvalid_out
);
localparam  FREE = 2'd0,
			WAIT_HS = 2'd1,
			SEND_ADDR = 2'd2;

logic [1:0] state, nstate;

logic [`AXI_ADDR_BITS-1:0] ARADDR_reg;
logic [`AXI_ID_BITS-1:0] ARID_reg;
logic ARVALID_reg;

assign rvalid_out=RVALID;

//current state register
always_ff@(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn) state <= FREE;
	else state <= nstate;
end

//next state logic(comb)
always@(*)begin
	case(state)
	FREE:begin
		if(ARVALID)begin
			if(ARREADY) nstate=SEND_ADDR;
			else nstate=WAIT_HS;
		end
		else begin
			nstate=FREE;
		end
	end
	WAIT_HS:begin
		if(ARREADY) nstate=SEND_ADDR;
		else nstate=WAIT_HS;
	end
	SEND_ADDR:begin
		if(RLAST && RVALID && RREADY)	nstate=FREE;
		else nstate=SEND_ADDR;
	end
	default: nstate=FREE;
	endcase
end

// output logic(comb(v) or registor?)		
always@(*)begin
	case(state)
	FREE:begin
		//data
		ARID=4'b0;
		ARADDR=address_in;
		//constant
		ARLEN=4'b0;
		ARSIZE=3'b010;
		ARBURST=2'b01;
		//control signal


		// if(opcode=LOAD) ARVALID=1'b0;
		// else ARVALID=read_signal;
		
		
		ARVALID=read_signal;
		RREADY=1'b0;
		data_out=RDATA;

		if(read_signal)	stall_IF=1'b1;
		else stall_IF=1'b0;

		// if(ARVALID==0)	stall_IF=1'b0;
		// else stall_IF=1'b1;

		// if(read_signal)	begin
		// 	if(ARVALID==0) stall_IF=1'b0;
		// 	else stall_IF=1'b1;
		// end
		// else stall_IF=1'b0;
	end
	WAIT_HS:begin
		//data
		ARID=4'b0;
		ARADDR=ARADDR_reg;
		//constant
		ARLEN=4'b0;
		ARSIZE=3'b010;
		ARBURST=2'b01;
		//control signal
		ARVALID=ARVALID_reg;
		RREADY=1'b0;
		data_out=RDATA;
		
		stall_IF=1'b1;
	end
	SEND_ADDR:begin
			//data
			ARID=ARID_reg;
			ARADDR=ARADDR_reg;
			//constant
			ARLEN=4'b0;
			ARSIZE=3'b010;
			ARBURST=2'b01;
			//control signal
			ARVALID=1'b0;
			RREADY=1'b1;
			data_out=RDATA;
			
			//可以多一個state
			if(RLAST) stall_IF=1'b0;
			else stall_IF=1'b1;

	end
	default: begin
		//data
		ARID=4'b0;
		ARADDR=32'b0;
		//constant
		ARLEN=4'b0;
		ARSIZE=3'b010;
		ARBURST=2'b01;
		//control signal
		ARVALID=1'b0;
		RREADY=1'b0;
		data_out=32'b0;
		
		stall_IF=1'b0;
	end
	endcase
end

//data sent back
always_ff@(posedge ACLK or negedge ARESETn) begin
	if(!ARESETn)begin
		ARID_reg<=4'b0;
		ARADDR_reg<=32'b0;
		ARVALID_reg<=1'b0;
	end
	else begin
		case(state)
		FREE: begin
			ARID_reg<=id_in;
			ARADDR_reg<=address_in;
			ARVALID_reg<=read_signal;
		end
		// WAIT_HS: ;
		// SEND_ADDR: ;
		default: ;
		endcase
	end
end
endmodule

//RRESP好像沒用到
//ARID=id_in
//output logic到底要用comb還是seq
//CPU接近來時 ARID ARADDR用reg存起來
//ARID用1 2表達 0為預設


// ARVALID開始stall
// RLAST結束stall
