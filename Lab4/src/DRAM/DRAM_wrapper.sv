 `include "AXI_define.svh"
module DRAM_wrapper (
    input clock,//
	input reset,//
	input clock2,
	input reset2,
    // READ ADDRESS
	input [`AXI_ID_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output ARREADY,
	// READ DATA
	output [`AXI_ID_BITS-1:0] RID,
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

//
logic [`AXI_ID_BITS-1:0] ARID_out;
logic [`AXI_ADDR_BITS-1:0] ARADDR_out;
logic [`AXI_LEN_BITS-1:0] ARLEN_out;
logic [`AXI_SIZE_BITS-1:0] ARSIZE_out;
logic [1:0] ARBURST_out;
logic ARVALID_out;
logic ARREADY_out;
// READ DATA
logic [`AXI_ID_BITS-1:0] RID_out;
logic [`AXI_DATA_BITS-1:0] RDATA_out;
logic [1:0] RRESP_out;
logic RLAST_out;
logic RVALID_out;
logic RREADY_out;
// WRITE ADDRESS
logic [`AXI_IDS_BITS-1:0] AWID_out;
logic [`AXI_ADDR_BITS-1:0] AWADDR_out;
logic [`AXI_LEN_BITS-1:0] AWLEN_out;
logic [`AXI_SIZE_BITS-1:0] AWSIZE_out;
logic [1:0] AWBURST_out;
logic AWVALID_out;
logic AWREADY_out;
// WRITE DATA
logic [`AXI_DATA_BITS-1:0] WDATA_out;
logic [`AXI_STRB_BITS-1:0] WSTRB_out;
logic WLAST_out;
logic WVALID_out;
logic WREADY_out;
// BBBBB
logic [`AXI_IDS_BITS-1:0] BID_out;
logic [1:0] BRESP_out;
logic BVALID_out;
logic BREADY_out;

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
logic [2:0] valid_counter;
logic read_or_write_reg;

logic write_complete;// TO AXI SLAVE new!!
logic valid_reg;
logic arvalid_reg, arready_reg;
logic awvalid_reg, awready_reg;

logic past_awvalid_reg;

// // stupid code
// logic [`AXI_DATA_BITS-1:0] WDATA_out_reg;
// logic [`AXI_STRB_BITS-1:0] WSTRB_out_reg;
// logic WLAST_out_reg;
// logic WVALID_out_reg;
// always_ff @(posedge clock2)
// begin
// 	if (!reset2)
// 	begin
// 		WDATA_out_reg<=32'b0;
// 		WSTRB_out_reg<=4'b0;
// 		WLAST_out_reg<=1'b0;
// 		WVALID_out_reg<=1'b0;
// 	end
// 	else 
// 	begin
// 		if(WVALID_out) begin
// 			WDATA_out_reg<=WDATA_out;
// 			WSTRB_out_reg<=WSTRB_out;
// 			WLAST_out_reg<=WLAST_out;
// 			WVALID_out_reg<=WVALID_out;
// 		end
// 		else begin
// 			WDATA_out_reg<=WDATA_out_reg;
// 			WSTRB_out_reg<=WSTRB_out_reg;
// 			WLAST_out_reg<=WLAST_out_reg;
// 			WVALID_out_reg<=WVALID_out_reg;
// 		end
// 	end
// end
//
// logic [`AXI_DATA_BITS-1:0] WDATA_out_delay;
// logic [`AXI_STRB_BITS-1:0] WSTRB_out_delay;
// logic WLAST_out_delay;
// logic WVALID_out_mux;

// logic RASn, CASn;
// logic [3:0] WEn;

logic [31:0] address;
logic [31:0] address_w, address_r;

logic [10:0]row_address_reg;

logic [3:0] WEB_wire;
//???
logic JUST_PRE;
always_ff @(posedge clock2)
begin
	if (!reset2)
	begin
		JUST_PRE<=1'b0;
	end
	else 
	begin
		if(awvalid_reg&&awready_reg) begin
			if(nstate==2'b0 && col_counter==3'd4) JUST_PRE <= 1'b1;
			else if(nstate==2'h2 && col_counter==3'd4) JUST_PRE <= 1'b0;
			else JUST_PRE <= JUST_PRE;
		end
	end
end
// DRAM Controller
// State Register
always_ff @(posedge clock2)
begin
	if (!reset2)
	begin
		state <= PRE;
	end
	else 
	begin
		state <= nstate;
	end
end
//對時序
always_ff @(posedge clock2)
begin
	if (!reset2)
	begin
		past_awvalid_reg <= 1'b0;
	end
	else 
	begin
		past_awvalid_reg <= AWVALID_out;
	end
end
always_ff @(posedge clock2)
begin
	if (!reset2)
	begin
		valid_counter <= 3'b0;
	end
	else 
	begin
		if(((ARVALID_out&&ARREADY_out)||(arready_reg&&arvalid_reg))&&valid) begin
			if(valid_counter==3'h3) begin
				valid_counter <= 3'h0;
			end
			else begin
				valid_counter <= valid_counter+3'b1;
			end
		end
		else begin
			if((ARVALID_out&&ARREADY_out))begin
				valid_counter <= 3'h0;
			end
			else
			valid_counter <= valid_counter;
		end
	end
end

// record register �??�????��??READ or WRITE
always_ff @(posedge clock2)//ARADDR
begin
	if (!reset2)
	begin
		read_or_write_reg <= 1'b0;
	end
	else 
	begin
		if(state==COL) begin
			if((ARVALID_out&&ARREADY_out)||(arready_reg&&arvalid_reg)) begin
				read_or_write_reg <= 1'b0;
			end
			else if((AWVALID_out&&AWREADY_out)||(awready_reg&&awvalid_reg))begin
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
	PRE:begin//??��?��?��?�已�?? precharge�?????�????��????��?? precharge
		if(pre_counter==3'd4) nstate=ROW;
		else nstate=PRE;
	end
	ROW:begin
		if(row_counter==3'd4) nstate=COL;
		else nstate=ROW;
	end
	COL:begin
		if((ARREADY_out && ARVALID_out)||(arready_reg&&arvalid_reg)) begin //read
			if((ARREADY_out && ARVALID_out)||(arready_reg&&arvalid_reg))begin
				if(address[22:12]==row_address_reg) nstate=COL;
				else begin
					if(col_counter==3'd4) nstate=PRE;
					else nstate=COL;
				end
			end
			else nstate=COL;
		end
		else begin //write
			if((AWREADY_out && AWVALID_out)||(awready_reg&&awvalid_reg))begin
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
		if((ARREADY_out && ARVALID_out)||(arready_reg&&arvalid_reg)) begin //read
			if((ARREADY_out && ARVALID_out)||(arready_reg&&arvalid_reg)) begin
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
		else if((AWREADY_out && AWVALID_out)||(awready_reg&&awvalid_reg))begin //write
			if((AWREADY_out && AWVALID_out)||(awready_reg&&awvalid_reg)) begin
				if(address[22:12]==row_address_reg) begin
					if(~JUST_PRE)	CAS = ~WVALID_out;
					else if(col_counter!=3'h2) CAS=1'b1;
					else CAS=1'b0;
					// if(col_counter!=3'h2) CAS=1'b1;
					// else CAS=1'b0;
				end
				else CAS=1'b1;
			end
			else CAS=1'b1;
			RAS=1'b1;
			//對時序
			if(~JUST_PRE) WEB=~WSTRB_out;
			else WEB=WEB_wire;
			// WEB=WEB_wire;//~WSTRB;//WEB_wire;// new!!
			// valid=1'd0;
			if((address[22:12]==row_address_reg)&&(col_counter==3'd5)) write_complete=1'd1;//((address[22:12]==row_address_reg)&&(col_counter==3'd4))
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

always@(posedge clock2)begin
	if(~reset2) valid_reg<=1'b0;
	else valid_reg<=valid;
end

always@(posedge clock2)begin
	if(~reset2)begin
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
			if((ARREADY_out && ARVALID_out)||(arready_reg&&arvalid_reg)) begin //read
				if((ARREADY_out && ARVALID_out)||(arready_reg&&arvalid_reg))begin
					if(col_counter==3'd5) col_counter<=3'd0;//
					else begin
						col_counter<=col_counter+3'd1;
						// if(!valid)	col_counter<=col_counter+3'd1;//valid
						// else col_counter<=col_counter;
					end
					// else begin////////////////////////////////// maybe error
					// 	if(!valid)	col_counter<=col_counter+3'd1;//valid is low
					// 	else if(valid_counter==3'h3) col_counter<=3'd0;
					// 	else col_counter<=col_counter;
					// end
				end
				else begin
					col_counter<=3'd0;
				end
				row_address_reg<=row_address_reg;

				row_counter<=3'd0;
				pre_counter<=3'd0;

				//COL
				if((ARVALID_out&&ARREADY_out))begin
					arvalid_reg<=ARVALID_out;
					arready_reg<=ARREADY_out;
				end
				else if (valid&&valid_counter==3'h3)begin
					arvalid_reg<=ARVALID_out;
					arready_reg<=ARREADY_out;
				end
				else begin
					arvalid_reg<=arvalid_reg;
					arready_reg<=arready_reg;
				end
			end
			else begin 
				if((AWREADY_out && AWVALID_out)||(awready_reg&&awvalid_reg))begin //write
					if(col_counter==3'd6) col_counter<=3'd0;
					else col_counter<=col_counter+3'd1;
				end
				else begin
					col_counter<=3'd0;
				end
				row_address_reg<=row_address_reg;

				row_counter<=3'd0;
				pre_counter<=3'd0;
				//COL
				if((AWVALID_out&&AWREADY_out))begin
					awvalid_reg<=AWVALID_out;
					awready_reg<=AWREADY_out;
				end
				else if (write_complete)begin
					awvalid_reg<=AWVALID_out;
					awready_reg<=AWREADY_out;
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

assign address=((AWVALID_out&&AWREADY_out)||(awready_reg&&awvalid_reg))?address_w:address_r;


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


Slave_Read_DRAM slaveReadDRAM
(
	.ACLK(clock2),
	.ARESETn(~reset2),
	// READ ADDRESS
	.ARID(ARID_out),
	.ARADDR(ARADDR_out),
	.ARLEN(ARLEN_out),
	.ARSIZE(ARSIZE_out),
	.ARBURST(ARBURST_out),
	.ARVALID(ARVALID_out),
	.ARREADY(ARREADY_out),
	// READ DATA
	.RID(RID_out),
	.RDATA(RDATA_out),
	.RRESP(RRESP_out),
	.RLAST(RLAST_out),
	.RVALID(RVALID_out),
	.RREADY(RREADY_out),

	.address_out(address_r),
	.data_in(DO),
	.select(2'b0),
	.valid_dram(valid)
);


AW_wrapper AW(
        .clock(clock),
        .clock2(clock2),//
        .reset(~reset),
        .reset2(~reset2),//
        .AWID   (AWID),
        .AWADDR (AWADDR),
        .AWLEN  (AWLEN),
        .AWSIZE (AWSIZE),
        .AWBURST(AWBURST),
        .AWVALID(AWVALID),
        //
        .AWREADY_out(AWREADY),// from slave
        ////
        .AWID_out   (AWID_out),
        .AWADDR_out (AWADDR_out),
        .AWLEN_out  (AWLEN_out),
        .AWSIZE_out (AWSIZE_out),
        .AWBURST_out(AWBURST_out),
        .AWVALID_out(AWVALID_out),
        //
        .AWREADY(AWREADY_out)// from master
);

W_wrapper W(
        .clock(clock),
        .clock2(clock2),//
        .reset(~reset),
        .reset2(~reset2),//
		//
        .WDATA  (WDATA),
        .WSTRB  (WSTRB),
        .WLAST  (WLAST),
        .WVALID (WVALID),
        .WREADY_out (WREADY),//
		////
		.WDATA_out  (WDATA_out),
        .WSTRB_out  (WSTRB_out),
        .WLAST_out  (WLAST_out),
        .WVALID_out (WVALID_out),
        .WREADY (WREADY_out)//
);

B_wrapper B(
        .clock(clock),
        .clock2(clock2),//
        .reset(~reset),
        .reset2(~reset2),//
		//
		.BID    (BID_out),
        .BRESP  (BRESP_out),
        .BVALID (BVALID_out),
        .BREADY_out (BREADY_out),
		////
		.BID_out    (BID),
        .BRESP_out  (BRESP),
        .BVALID_out (BVALID),
        .BREADY (BREADY)
);
Slave_Write_DRAM slaveWriteDRAM
(
	.ACLK(clock2),
	.ARESETn(~reset2),
	// WRITE ADDRESS
	.AWID(AWID_out),
	.AWADDR(AWADDR_out),
	.AWLEN(AWLEN_out),
	.AWSIZE(AWSIZE_out),
	.AWBURST(AWBURST_out),
	.AWVALID(AWVALID_out),
	.AWREADY(AWREADY_out),
	// WRITE DATA
	.WDATA(WDATA_out),
	.WSTRB(WSTRB_out),
	.WLAST(WLAST_out),
	.WVALID(WVALID_out),
	.WREADY(WREADY_out),
	// WRITE RESPONSE
	.BID(BID_out),
	.BRESP(BRESP_out),
	.BVALID(BVALID_out),
	.BREADY(BREADY_out),

	.data_out(DI),
	.address_out(address_w),
	.select(2'b0),
	.dram_complete(write_complete),
	.w_en_out(WEB_wire)
);


endmodule
