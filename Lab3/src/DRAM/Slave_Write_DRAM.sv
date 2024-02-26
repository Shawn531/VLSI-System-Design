// `include "AXI_define.svh"
module Slave_Write_DRAM(
    input ACLK,
	input ARESETn,
    // WRITE ADDRESS
	input [`AXI_IDS_BITS-1:0] AWID,
	input [`AXI_ADDR_BITS-1:0] AWADDR,
	input [`AXI_LEN_BITS-1:0] AWLEN,
	input [`AXI_SIZE_BITS-1:0] AWSIZE,
	input [1:0] AWBURST,
	input AWVALID,
	output logic AWREADY,
	// WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output logic WREADY,
	// WRITE RESPONSE
	output logic [`AXI_IDS_BITS-1:0] BID,
	output logic [1:0] BRESP,
	output logic BVALID,
	input BREADY,

    output logic [31:0] data_out, address_out,
    output logic [3:0] w_en_out,
    output logic isnot_FREE,

	input logic [1:0] select,
    input dram_complete
);

localparam  FREE = 2'd0,
            SEND_DATA = 2'd1,
            Wait_dram = 2'd2,// new!!!
            SEND_B = 2'd3;

logic [1:0] state, nstate;

logic [7:0] BID_reg;

logic [31:0] WDATA_reg;
logic [3:0] WSTRB_reg;

assign isnot_FREE=state[0];

always@(posedge ACLK)begin
    if(ARESETn) state<=FREE;
    else state<=nstate;
end

//next state logic
always@(*)begin
    case(state)
    FREE:begin
        if(AWVALID) nstate=SEND_DATA;
        else nstate=FREE;
    end
    SEND_DATA:begin
        if(WLAST && WVALID && WREADY) nstate=Wait_dram;
        else nstate=SEND_DATA;
    end
    Wait_dram:begin // new!!!
	if(dram_complete) nstate=SEND_B;
	else nstate=Wait_dram;
    end
    SEND_B:begin
	if(BREADY && BVALID) nstate=FREE;
	else nstate=SEND_B;
    end
    endcase
end

//output logic
always@(*)begin
    case(state)
    FREE:begin

	if(select==2'd3) AWREADY=1'b0;
	else AWREADY=1'b1;

	//AWREADY=1'b1;

        WREADY=1'b0;

        BID=AWID;
        BRESP=2'b0;
        BVALID=1'b0;

        data_out=32'b0;
        address_out=AWADDR;

        
        w_en_out=~WSTRB;
   
    end
    SEND_DATA:begin 
        AWREADY=1'b1;

        WREADY=1'b1;

        BID=BID_reg;
        //resp???????
        BRESP=2'b0;
        BVALID=1'b0;

        data_out=WDATA;
        address_out=AWADDR;

        w_en_out=WSTRB_reg;
    end
    Wait_dram:begin // new!!!

        AWREADY=1'b1;

        WREADY=1'b1;

        BID=BID_reg;
        //resp???????
        BRESP=2'b0;
        BVALID=1'b0;

        data_out=WDATA_reg;
        address_out=AWADDR;

        w_en_out=WSTRB_reg;
    end
    SEND_B:begin

        AWREADY=1'b1;

        WREADY=1'b1;

        BID=BID_reg;
        //resp???????
        BRESP=2'b0;
        BVALID=1'b1;

        data_out=WDATA_reg;
        address_out=AWADDR;

        w_en_out=WSTRB_reg;
    end
    endcase
end

always_ff@(posedge ACLK)begin
	if(ARESETn)begin
		BID_reg<=8'b0;
        WDATA_reg<=32'b0;
        WSTRB_reg<=4'b0;
	end
	else begin
		case(state)
		FREE: begin
			BID_reg<=AWID;
            WDATA_reg<=WDATA_reg;
            WSTRB_reg<=~WSTRB;
		end	
		SEND_DATA: begin
			BID_reg<=BID_reg;
            WDATA_reg<=WDATA;
            WSTRB_reg<=WSTRB_reg;
		end
        Wait_dram: begin	
			BID_reg<=BID_reg;
            WDATA_reg<=WDATA_reg;
            WSTRB_reg<=WSTRB_reg;
		end
		SEND_B: begin	
			BID_reg<=BID_reg;
            WDATA_reg<=WDATA_reg;
            WSTRB_reg<=WSTRB_reg;
		end
		endcase
	end

end



endmodule
