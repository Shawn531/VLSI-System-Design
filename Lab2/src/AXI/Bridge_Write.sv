`include "AXI_define.svh"

module Bridge_Write(

    input ACLK,
	input ARESETn,
    
    // Master
    // WRITE ADDRESS
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output logic AWREADY_M1,
	// WRITE DATA
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output logic WREADY_M1,
	// WRITE RESPONSE
	output logic [`AXI_ID_BITS-1:0] BID_M1,
	output logic [1:0] BRESP_M1,
	output logic BVALID_M1,
	input BREADY_M1,

    // Slave
    // WRITE ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] AWID_S0,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S0,
	output logic [1:0] AWBURST_S0,
	output logic AWVALID_S0,
	input AWREADY_S0,
	// WRITE DATA0
	output logic [`AXI_DATA_BITS-1:0] WDATA_S0,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S0,
	output logic WLAST_S0,
	output logic WVALID_S0,
	input WREADY_S0,
	// WRITE RESPONSE0
	input [`AXI_IDS_BITS-1:0] BID_S0,
	input [1:0] BRESP_S0,
	input BVALID_S0,
	output logic BREADY_S0,
	// WRITE ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] AWID_S1,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output logic [1:0] AWBURST_S1,
	output logic AWVALID_S1,
	input AWREADY_S1,
	// WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S1,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output logic WLAST_S1,
	output logic WVALID_S1,
	input WREADY_S1,
	// WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output logic BREADY_S1
);
localparam  FREE = 1'b0,
            DATA = 1'b1;
logic state, nstate;
logic [`AXI_LEN_BITS-1:0] ARLEN_Reg;
logic [`AXI_LEN_BITS-1:0] AWLEN_Reg;
always_ff@(posedge ACLK or negedge ARESETn)begin
    if(!ARESETn)
    begin
        state <= FREE;
    end
	else begin
        state <= nstate;
    end
end
logic slave_select;
logic slave_select_reg;
always_ff@(posedge ACLK or negedge ARESETn)begin
    if(!ARESETn)
    begin
        slave_select_reg <= 1'b0;
    end
	else begin
		if(state == FREE)
        slave_select_reg <= slave_select;
		else
		slave_select_reg <= slave_select_reg;
    end
end 
always@(*)begin
    case(state)
    FREE:begin
        if(AWVALID_M1&&AWREADY_S1) 
        begin
            nstate=DATA;
            slave_select = 1'b1;
        end
        else if(AWVALID_M1&&AWREADY_S0) 
        begin
            nstate=DATA;
            slave_select = 1'b0;
        end
        else 
        begin
            nstate=FREE;
			slave_select = 1'b0;
        end
    end
    DATA:begin
		slave_select = slave_select_reg;
        if (BREADY_M1&&BVALID_M1)//
            nstate=FREE;
        else
            nstate=DATA;
    end
    endcase
end
//數數
always_ff@(posedge ACLK or negedge ARESETn)begin
    if(!ARESETn)
    begin
        ARLEN_Reg <= 4'd0;
        AWLEN_Reg <= 4'd0;
    end
	else begin
        case(state)
    FREE:begin
        if(AWVALID_M1) 
        begin
            AWLEN_Reg <= AWLEN_M1;
        end
		else
			AWLEN_Reg <= AWLEN_Reg;
    end
    DATA:begin
        AWLEN_Reg<=AWLEN_Reg;
    end
    endcase
    end
end
logic WVALID_REG;
always_ff@(posedge ACLK or negedge ARESETn)begin
    if(!ARESETn)
    begin
        WVALID_REG<=1'b0;
    end
	else begin
        WVALID_REG<=WVALID_M1;
    end
end
always@(*)begin
    case(state)
    FREE:begin
        //MASTER IO
        AWREADY_M1 = 1'd0;
        //
        WREADY_M1 = 1'd0;
        //
        BID_M1 = 4'd0;
        BRESP_M1 = 2'd0;
        BVALID_M1 = 1'd0;
        ////////
        //SLAVE IO
        ////S0
        AWID_S0 = 8'd0;
        AWADDR_S0 = 32'd0;
        AWLEN_S0 = 4'd0;
        AWSIZE_S0 = 3'd0;
        AWBURST_S0 = 2'd0;
        AWVALID_S0 = 1'd0;
        //
        WDATA_S0 = 32'd0;
        WSTRB_S0 = 4'd0;
        WLAST_S0 = 1'd0;
        WVALID_S0 = 1'd0;
        //
        BREADY_S0 = 1'd0;
        ////S1
        AWID_S1 = 8'd0;
        AWADDR_S1 = 32'd0;
        AWLEN_S1 = 4'd0;
        AWSIZE_S1 = 3'd0;
        AWBURST_S1 = 2'd0;
        AWVALID_S1 = 1'd0;
        //
        WDATA_S1 = 32'd0;
        WSTRB_S1 = 4'd0;
        WLAST_S1 = 1'd0;
        WVALID_S1 = 1'd0;
        //
        BREADY_S1 = 1'd0;
    end
    DATA:begin
        if(~slave_select)
        begin
            //MASTER IO
            AWREADY_M1 = AWREADY_S0;
            //
            WREADY_M1 = WREADY_S0;
            //
            BID_M1 = BID_S0[3:0];
            BRESP_M1 = BRESP_S0;
            BVALID_M1 = BVALID_S0;
            ////////
            //SLAVE IO
            ////S0
			AWID_S0[7:4] = 4'b0;
            AWID_S0[3:0] = AWID_M1;
            AWADDR_S0 = AWADDR_M1;
            AWLEN_S0 = AWLEN_Reg;
            AWSIZE_S0 = AWSIZE_M1;
            AWBURST_S0 = AWBURST_M1;
            AWVALID_S0 = AWVALID_M1;
            //
			WDATA_S0 = WDATA_M1;
            //
            WSTRB_S0 = WSTRB_M1;

            WLAST_S0 = WLAST_M1;
            //
            WVALID_S0 = WVALID_M1;
            //
            BREADY_S0 = BREADY_M1;
            ////S1
            AWID_S1 = 8'd0;
            AWADDR_S1 = 32'd0;
            AWLEN_S1 = 4'd0;
            AWSIZE_S1 = 3'd0;
            AWBURST_S1 = 2'd0;
            AWVALID_S1 = 1'd0;
            //
            WDATA_S1 = 32'd0;
            WSTRB_S1 = 4'd0;
            WLAST_S1 = 1'd0;
            WVALID_S1 = 1'd0;
            //
            BREADY_S1 = 1'd0;
        end
        // path from M1 to S1
        else 
        begin
            //MASTER IO
            AWREADY_M1 = AWREADY_S1;
            //
            WREADY_M1 = WREADY_S1;
            //
            BID_M1 = BID_S1[3:0];
            BRESP_M1 = BRESP_S1;
            BVALID_M1 = BVALID_S1;
            ////////
            //SLAVE IO
            ////S0
            AWID_S0 = 8'd0;
            AWADDR_S0 = 32'd0;
            AWLEN_S0 = 4'd0;
            AWSIZE_S0 = 3'd0;
            AWBURST_S0 = 2'd0;
            AWVALID_S0 = 1'd0;
            //
            WDATA_S0 = 32'd0;
            WSTRB_S0 = 4'd0;
            WLAST_S0 = 1'd0;
            WVALID_S0 = 1'd0;
            //
            BREADY_S0 = 1'd0;
            ////S1
			AWID_S1[7:4] = 4'b0;
            AWID_S1[3:0] = AWID_M1;
            AWADDR_S1 = AWADDR_M1;
            AWLEN_S1 = AWLEN_Reg;
            AWSIZE_S1 = AWSIZE_M1;
            AWBURST_S1 = AWBURST_M1;
            AWVALID_S1 = AWVALID_M1;
            //
			WDATA_S1 = WDATA_M1;
            WSTRB_S1 = WSTRB_M1;
			
            WLAST_S1 = WLAST_M1;

            WVALID_S1 = WVALID_M1;
            //
            BREADY_S1 = BREADY_M1;
            ////
        end
        
    end
    
    endcase
end

endmodule
