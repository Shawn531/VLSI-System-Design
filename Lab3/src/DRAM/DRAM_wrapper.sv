// `include "AXI_define.svh"
module DRAM_wrapper (
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
	input BREADY,
	//#################################################################
    // DRAM from top_tb
    output logic CS,
    output logic RAS,
    output logic CAS,
    output logic [3:0] WEB,
    output logic [10:0] A,
    output logic [`AXI_DATA_BITS-1:0] DI,
    input [`AXI_DATA_BITS-1:0] DO,
    input logic valid
);

assign CS=1'b0;

localparam  PRE = 2'b00,
            ROW = 2'b01,
			COL = 2'b10;
// Register
logic [1:0] state;
logic [1:0] nstate;
logic [2:0] pre_counter;
logic [2:0] row_counter;
logic [2:0] col_counter;
logic read_or_write_reg;

logic write_complete;// TO AXI SLAVE new!!
logic valid_reg;
logic arvalid_reg, arready_reg;
logic awvalid_reg, awready_reg;


// logic RASn, CASn;
// logic [3:0] WEn;

logic [31:0] address;
logic [31:0] address_w, address_r;

logic [10:0]row_address_reg;

logic [3:0] WEB_wire;


// DRAM Controller
// State Register
always_ff @(posedge clock)
begin
	if (!reset)
	begin
		state <= PRE;
	end
	else 
	begin
		state <= nstate;
	end
end

// record register �?�???��??READ or WRITE
always_ff @(posedge clock)//ARADDR
begin
	if (!reset)
	begin
		read_or_write_reg <= 1'b0;
	end
	else 
	begin
		if(state==COL) begin
			if((ARVALID&&ARREADY)||(arready_reg&&arvalid_reg)) begin
				read_or_write_reg <= 1'b0;
			end
			else if((AWVALID&&AWREADY)||(awready_reg&&awvalid_reg))begin
				read_or_write_reg <= 1'b1;
			end
			else
				read_or_write_reg <= 1'b0;
		end
		else read_or_write_reg<=read_or_write_reg;
	end
end

// Next State Logic & Combination Output Logic
always_comb 
begin
	case(state)
	PRE:begin//??��?��?��?�已�? precharge�????�???��????��?? precharge
		if(pre_counter==3'd4) nstate=ROW;
		else nstate=PRE;
	end
	ROW:begin
		if(row_counter==3'd4) nstate=COL;
		else nstate=ROW;
	end
	COL:begin
		if((ARREADY && ARVALID)||(arready_reg&&arvalid_reg)) begin //read
			if((ARREADY && ARVALID)||(arready_reg&&arvalid_reg))begin
				if(address[22:12]==row_address_reg) nstate=COL;
				else begin
					if(col_counter==3'd4) nstate=PRE;
					else nstate=COL;
				end
			end
			else nstate=COL;
		end
		else begin //write
			if((AWREADY && AWVALID)||(awready_reg&&awvalid_reg))begin
				if(address[22:12]==row_address_reg) nstate=COL;
				else begin
					if(col_counter==3'd4) nstate=PRE;
					else nstate=COL;
				end
			end
			else nstate=COL;
			//
		end
	end
	default: nstate=COL;
	endcase
end

//output logic
always_comb begin
	case(state)
	PRE:begin
		if(pre_counter!=3'b0) 				begin
								RAS=1'b1;
								WEB=4'hf;
								end
					else 		begin
							RAS=1'b0;
							WEB=4'h0;
							end
		CAS=1'b1;
		
		//valid=1'd0;
		A=row_address_reg;
		write_complete=1'b0;
	end
	ROW:begin
		if(row_counter!=3'b0) RAS=1'b1;
					else RAS=1'b0;
		CAS=1'b1;
		WEB=4'hf;
		//valid=1'd0;
		A=address[22:12];
		write_complete=1'b0;
	end
	COL:begin
		if((ARREADY && ARVALID)||(arready_reg&&arvalid_reg)) begin //read
			if((ARREADY && ARVALID)||(arready_reg&&arvalid_reg)) begin
				if(address[22:12]==row_address_reg) begin
					if(col_counter!=3'b0) CAS=1'b1;
					else CAS=valid;//1'b0;    modified by LU at 2023/11/14
				end
				else CAS=1'b1;
			end
			else CAS=1'b1;
			RAS=1'b1;
			WEB=4'hf;
			// if(col_counter==3'd4) valid=1'd1;// 0 1 2 3 4 5
			// else valid=1'd0;
			A=address[12:2];
			write_complete=1'b0;
		end
		else if((AWREADY && AWVALID)||(awready_reg&&awvalid_reg))begin //write
			if((AWREADY && AWVALID)||(awready_reg&&awvalid_reg)) begin
				if(address[22:12]==row_address_reg) begin
					if(col_counter!=3'b0) CAS=1'b1;
					else CAS=1'b0;
				end
				else CAS=1'b1;
			end
			else CAS=1'b1;
			RAS=1'b1;
			WEB=WEB_wire;// new!!
			// valid=1'd0;
			if((address[22:12]==row_address_reg)&&(col_counter==3'd4)) write_complete=1'd1;//((address[22:12]==row_address_reg)&&(col_counter==3'd4))
			else write_complete=1'd0;
			A=address[12:2];
		end 
		else begin
			CAS=1'b1;
			RAS=1'b1;
			WEB=4'hf;
			write_complete=1'd0;
			A=11'b0;
		end
	end
	default: begin
		CAS=1'b1;
		RAS=1'b1;
		WEB=4'hf;
		write_complete=1'd0;
		A=11'b0;	
	end
	endcase
end

always@(posedge clock)begin
	if(~reset) valid_reg<=1'b0;
	else valid_reg<=valid;
end

always@(posedge clock)begin
	if(~reset)begin
		//
		pre_counter<=3'd0;
		row_counter<=3'd0;
		col_counter<=3'd0;
		arvalid_reg<=1'b0;
		arready_reg<=1'b0;
		awready_reg<=1'b0;
		awvalid_reg<=1'b0;
		row_address_reg<=11'h0;
	end
	else begin
		case(state)
		PRE:begin
			if(pre_counter==3'd4) pre_counter<=3'd0;
			else pre_counter<=pre_counter+3'd1;
			row_address_reg<=row_address_reg;

			row_counter<=3'd0;
			col_counter<=3'd0;

			arvalid_reg<=arvalid_reg;
			arready_reg<=arready_reg;
			awvalid_reg<=awvalid_reg;
			awready_reg<=awready_reg;
		end
		ROW:begin
			if(row_counter==3'd4) row_counter<=3'd0;
			else row_counter<=row_counter+3'd1;
			row_address_reg<=address[22:12];

			pre_counter<=3'd0;
			col_counter<=3'd0;

			arvalid_reg<=arvalid_reg;
			arready_reg<=arready_reg;
			awvalid_reg<=awvalid_reg;
			awready_reg<=awready_reg;
		end
		COL:begin
			if((ARREADY && ARVALID)||(arready_reg&&arvalid_reg)) begin //read
				if((ARREADY && ARVALID)||(arready_reg&&arvalid_reg))begin
					if(col_counter==3'd4) col_counter<=3'd0;
					else begin
						if(!valid)	col_counter<=col_counter+3'd1;
						else col_counter<=col_counter;
					end
				end
				else begin
					col_counter<=3'd0;
				end
				row_address_reg<=row_address_reg;

				row_counter<=3'd0;
				pre_counter<=3'd0;

				//COL
				if((ARVALID&&ARREADY))begin
					arvalid_reg<=ARVALID;
					arready_reg<=ARREADY;
				end
				else if (valid)begin
					arvalid_reg<=ARVALID;
					arready_reg<=ARREADY;
				end
				else begin
					arvalid_reg<=arvalid_reg;
					arready_reg<=arready_reg;
				end
			end
			else begin //write
				if((AWREADY && AWVALID)||(awready_reg&&awvalid_reg))begin
					if(col_counter==3'd4) col_counter<=3'd0;
					else col_counter<=col_counter+3'd1;
				end
				else begin
					col_counter<=3'd0;
				end
				row_address_reg<=row_address_reg;

				row_counter<=3'd0;
				pre_counter<=3'd0;
				//COL
				if((AWVALID&&AWREADY))begin
					awvalid_reg<=AWVALID;
					awready_reg<=AWREADY;
				end
				else if (write_complete)begin
					awvalid_reg<=AWVALID;
					awready_reg<=AWREADY;
				end
				else begin
					awvalid_reg<=awvalid_reg;
					awready_reg<=awready_reg;
				end
			end

		end
		default: ;
		endcase
	end
end

assign address=((AWVALID&&AWREADY)||(awready_reg&&awvalid_reg))?address_w:address_r;

Slave_Read_DRAM slaveReadDRAM
(
	.ACLK(clock),
	.ARESETn(~reset),
	// READ ADDRESS
	.ARID(ARID),
	.ARADDR(ARADDR),
	.ARLEN(ARLEN),
	.ARSIZE(ARSIZE),
	.ARBURST(ARBURST),
	.ARVALID(ARVALID),
	.ARREADY(ARREADY),
	// READ DATA
	.RID(RID),
	.RDATA(RDATA),
	.RRESP(RRESP),
	.RLAST(RLAST),
	.RVALID(RVALID),
	.RREADY(RREADY),

	.address_out(address_r),
	.data_in(DO),
	.select(2'b0),
	.valid_dram(valid)
);

Slave_Write_DRAM slaveWriteDRAM
(
	.ACLK(clock),
	.ARESETn(~reset),
	// WRITE ADDRESS
	.AWID(AWID),
	.AWADDR(AWADDR),
	.AWLEN(AWLEN),
	.AWSIZE(AWSIZE),
	.AWBURST(AWBURST),
	.AWVALID(AWVALID),
	.AWREADY(AWREADY),
	// WRITE DATA
	.WDATA(WDATA),
	.WSTRB(WSTRB),
	.WLAST(WLAST),
	.WVALID(WVALID),
	.WREADY(WREADY),
	// WRITE RESPONSE
	.BID(BID),
	.BRESP(BRESP),
	.BVALID(BVALID),
	.BREADY(BREADY),

	.data_out(DI),
	.address_out(address_w),
	.select(2'b0),
	.dram_complete(write_complete),
	.w_en_out(WEB_wire)
);


endmodule
