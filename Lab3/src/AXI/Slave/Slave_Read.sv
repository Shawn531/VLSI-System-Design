// `include "AXI_define.svh"
module Slave_Read(

	input ACLK,
	input ARESETn,

	//READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output logic ARREADY,
	
	//READ DATA
	output logic [`AXI_IDS_BITS-1:0] RID,
	output logic [`AXI_DATA_BITS-1:0] RDATA,
	output logic [1:0] RRESP,
	output logic RLAST,
	output logic RVALID,
	input RREADY,

    //Some output data to SRAM
    output logic [31:0] address_out,
    
    //Some input data from SRAM
    input [31:0] data_in,

	input logic[1:0] select
	
);

localparam  FREE = 3'b00,
            DATA_WAITSRAM = 3'b01,
            DATA = 3'b10;

logic [2:0] state, nstate, pstate;
logic [31:0] RDATA_reg;
logic [3:0] arlen_reg;

logic [7:0] RID_reg;


logic RLAST_reg;

always_ff@(posedge ACLK)begin
    if(ARESETn) pstate<=FREE;
    else pstate<=state;
end

//current state register
always_ff@(posedge ACLK)begin
    if(ARESETn) state <= FREE;
	else state <= nstate;
end

//next state logic(comb)
always@(*)begin
    case(state)
    FREE:begin
        if(ARVALID) begin
            if(ARREADY) nstate=DATA_WAITSRAM;
            else nstate=FREE;
        end
        else nstate=FREE;
    end
    DATA_WAITSRAM: begin
	nstate=DATA;
    end
    DATA:begin
        if(RLAST && RVALID && RREADY) nstate=FREE;
        else nstate=DATA;
    end
    
    default: nstate=FREE;

    endcase
end

always@(*)begin
    case(state)
    FREE:begin
        address_out=32'b0;
        //data
        RID=ARID;
        RDATA=32'b0;
        //control signal
        RRESP=2'b00;
        RLAST=1'b0;
        RVALID=1'b0;

		if(select==2'd3 ) ARREADY=1'b0;
		else ARREADY=1'b1;
    end
    DATA_WAITSRAM:begin
        address_out=ARADDR;
        //data
        RID=RID_reg;
        RDATA=32'b0;
        //control signal
        RRESP=2'b00;
        RLAST=1'b0;
        RVALID=1'b0;
        ARREADY=1'b0;
    end

    DATA:begin	
	RVALID=1'b1;
	if(RREADY && RVALID)begin //HS
		address_out=32'b0;
		//data
		if(pstate==DATA_WAITSRAM)begin
			RDATA=data_in;
			RID=RID_reg;
		end
		else begin
			RDATA=RDATA_reg;
			RID=RID_reg;
		end
		//control signal
		RRESP=2'b00;
		// RLAST=1'b1;
		// RVALID=1'b1;
		ARREADY=1'b0;
		if(arlen_reg==4'b1)begin
		    RLAST=1'b1;
		end
		else begin 
		    RLAST=1'b0/*RLAST_reg*/;
		end
		//RLAST=1'b1;
	end
	else begin //not HS yet
		address_out=32'b0;
		//data
		RID=RID_reg;
		if(pstate==DATA_WAITSRAM) RDATA=data_in;
		else RDATA=RDATA_reg;

		//control signal
		RRESP=2'b00;
		// RLAST=1'b1;
		// RVALID=1'b1;
		ARREADY=1'b0;
		if(arlen_reg==4'b1)begin
		    if(RVALID)	RLAST=1'b1;
			else RLAST=1'b0;
		end
		else begin 
		    RLAST=1'b0/*RLAST_reg*/;
		end
		//RLAST=RLAST_reg;
	end	
    end

 
    default: begin
	address_out=32'b0;
        //data
        RID=8'b0;
        RDATA=32'b0;
        //control signal
        RRESP=2'b00;
        RLAST=1'b0;
        RVALID=1'b0;
        ARREADY=1'b0;
    end
    endcase
end

always_ff@(posedge ACLK)begin
    if(ARESETn)begin
        RDATA_reg<=32'b0;
        arlen_reg<=4'b0;
	RID_reg<=8'b0;
	RLAST_reg<=1'b0;
    end
    else begin
    case(state)
	FREE: begin
		arlen_reg<=ARLEN+4'b1;
		RDATA_reg<=32'b0;
		RID_reg<=ARID;
		RLAST_reg<=1'b0;
	end

	DATA_WAITSRAM: begin
		arlen_reg<=arlen_reg;
		RDATA_reg<=32'b0;
		RID_reg<=RID_reg;
		RLAST_reg<=1'b0;
	end

    DATA: begin
	    if(RREADY && RVALID)begin
		    RID_reg<=RID_reg;
		    if(pstate==DATA_WAITSRAM)begin
			RDATA_reg<=data_in;
			RID_reg<=RID_reg;
		    end
		    else begin
			RDATA_reg<=RDATA_reg;
			RID_reg<=RID_reg;
		    end

		    if(arlen_reg==4'b1)begin
		        arlen_reg<=arlen_reg;
			RLAST_reg<=1'b0/*RLAST*/;
		    end
		    else begin
		        arlen_reg<=arlen_reg-4'b1;
			RLAST_reg<=1'b0/*RLAST*/;
		    end
		end
	    else begin
		    RID_reg<=RID_reg;
		    if(pstate==DATA_WAITSRAM)begin
			RDATA_reg<=data_in;
			RID_reg<=RID_reg;
		    end
		    else begin
			RDATA_reg<=RDATA_reg;
			RID_reg<=RID_reg;
		    end

		    if(arlen_reg==4'b1)begin
		        arlen_reg<=arlen_reg;
				RLAST_reg<=/*RLAST*/1'b0;
		    end
		    else begin
		        arlen_reg<=arlen_reg;
				RLAST_reg<=/*RLAST*/1'b0;
		    end
		end
	end

	default: ;
	endcase
	end
end

endmodule
//RRESP??��??�??????????�?
//RLAST�?寫counter??��?��?��??=0
//�?�????DATA_WAITMEM??��??SRAM
