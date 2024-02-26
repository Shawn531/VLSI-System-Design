// 2023/11/15 2:28 : Added S3 (sensor)
// 2023/11/16 19:25 : Added S4 (WDT)
// `include "AXI_define.svh"

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
    /////////////////////////////////////////////
//-----------slave1---------------//
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
	output logic BREADY_S1,

//-----------slave2---------------//
    output logic [`AXI_IDS_BITS-1:0] AWID_S2,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
	output logic [1:0] AWBURST_S2,
	output logic AWVALID_S2,
	input AWREADY_S2,
	// WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S2,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output logic WLAST_S2,
	output logic WVALID_S2,
	input WREADY_S2,
	// WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output logic BREADY_S2,
	
//-----------slave3---------------//
    output logic [`AXI_IDS_BITS-1:0] AWID_S3,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S3,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S3,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
	output logic [1:0] AWBURST_S3,
	output logic AWVALID_S3,
	input AWREADY_S3,
	// WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S3,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S3,
	output logic WLAST_S3,
	output logic WVALID_S3,
	input WREADY_S3,
	// WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S3,
	input [1:0] BRESP_S3,
	input BVALID_S3,
	output logic BREADY_S3,

//-----------slave4---------------//
    output logic [`AXI_IDS_BITS-1:0] AWID_S4,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
	output logic [1:0] AWBURST_S4,
	output logic AWVALID_S4,
	input AWREADY_S4,
	// WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S4,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output logic WLAST_S4,
	output logic WVALID_S4,
	input WREADY_S4,
	// WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S4,
	input [1:0] BRESP_S4,
	input BVALID_S4,
	output logic BREADY_S4,

//-----------slave5---------------//
    output logic [`AXI_IDS_BITS-1:0] AWID_S5,
	output logic [`AXI_ADDR_BITS-1:0] AWADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] AWLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] AWSIZE_S5,
	output logic [1:0] AWBURST_S5,
	output logic AWVALID_S5,
	input AWREADY_S5,
	// WRITE DATA1
	output logic [`AXI_DATA_BITS-1:0] WDATA_S5,
	output logic [`AXI_STRB_BITS-1:0] WSTRB_S5,
	output logic WLAST_S5,
	output logic WVALID_S5,
	input WREADY_S5,
	// WRITE RESPONSE1
	input [`AXI_IDS_BITS-1:0] BID_S5,
	input [1:0] BRESP_S5,
	input BVALID_S5,
	output logic BREADY_S5

);
localparam  FREE = 1'b0,
            DATA = 1'b1;
logic state, nstate;
logic [`AXI_LEN_BITS-1:0] ARLEN_Reg;
logic [`AXI_LEN_BITS-1:0] AWLEN_Reg;
always_ff@(posedge ACLK)begin
    if(!ARESETn)
    begin
        state <= FREE;
    end
	else begin
        state <= nstate;
    end
end

logic pstate;
always_ff@(posedge ACLK)begin
    if(!ARESETn)
    begin
        pstate<=1'b0;
    end
	else begin
        pstate <= state;
    end
end


always@(*)begin
    case(state)
    FREE:begin
        if(AWVALID_M1) //potential issue 
        begin
            nstate=DATA;
        end
        else 
        begin
            nstate=FREE;
        end
    end
    DATA:begin
        if (BREADY_M1&&BVALID_M1)//
            nstate=FREE;
        else
            nstate=DATA;
    end
    endcase
end
//??��??
always_ff@(posedge ACLK)begin
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
always_ff@(posedge ACLK)begin
    if(!ARESETn)
    begin
        WVALID_REG<=1'b0;
    end
	else begin
        WVALID_REG<=WVALID_M1;
    end
end

logic [31:0] awaddr_reg;
always@(posedge ACLK)begin
    if(!ARESETn)begin
        awaddr_reg<=32'b0;
    end
	else begin
        if(~state && nstate)begin //state: FREE nstate: DATA
            awaddr_reg<=AWADDR_M1;
        end
        else begin
            awaddr_reg<=awaddr_reg;
        end
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
        BREADY_S1 = 1'd0;
        ////S2
        AWID_S2 = 8'd0;
        AWADDR_S2 = 32'd0;
        AWLEN_S2 = 4'd0;
        AWSIZE_S2 = 3'd0;
        AWBURST_S2 = 2'd0;
        AWVALID_S2 = 1'd0;
        //
        WDATA_S2 = 32'd0;
        WSTRB_S2 = 4'd0;
        WLAST_S2 = 1'd0;
        WVALID_S2 = 1'd0;
        BREADY_S2 = 1'd0;
		////S3
        AWID_S3 = 8'd0;
        AWADDR_S3 = 32'd0;
        AWLEN_S3 = 4'd0;
        AWSIZE_S3 = 3'd0;
        AWBURST_S3 = 2'd0;
        AWVALID_S3 = 1'd0;
        //
        WDATA_S3 = 32'd0;
        WSTRB_S3 = 4'd0;
        WLAST_S3 = 1'd0;
        WVALID_S3 = 1'd0;
        BREADY_S3 = 1'd0;
        ////S4
        AWID_S4 = 8'd0;
        AWADDR_S4 = 32'd0;
        AWLEN_S4 = 4'd0;
        AWSIZE_S4 = 3'd0;
        AWBURST_S4 = 2'd0;
        AWVALID_S4 = 1'd0;
        //
        WDATA_S4 = 32'd0;
        WSTRB_S4 = 4'd0;
        WLAST_S4 = 1'd0;
        WVALID_S4 = 1'd0;
        BREADY_S4 = 1'd0;
        ////S5
        AWID_S5 = 8'd0;
        AWADDR_S5 = 32'd0;
        AWLEN_S5 = 4'd0;
        AWSIZE_S5 = 3'd0;
        AWBURST_S5 = 2'd0;
        AWVALID_S5 = 1'd0;
        //
        WDATA_S5 = 32'd0;
        WSTRB_S5 = 4'd0;
        WLAST_S5 = 1'd0;
        WVALID_S5 = 1'd0;
        BREADY_S5 = 1'd0;
    end
    DATA:begin
        // path from M1 to S1
        if(awaddr_reg[31:16]==16'h0001)
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
            BREADY_S1 = BREADY_M1;
            ////S2
            AWID_S2 = 8'd0;
            AWADDR_S2 = 32'd0;
            AWLEN_S2 = 4'd0;
            AWSIZE_S2 = 3'd0;
            AWBURST_S2 = 2'd0;
            AWVALID_S2 = 1'd0;
            //
            WDATA_S2 = 32'd0;
            WSTRB_S2 = 4'd0;
            WLAST_S2 = 1'd0;
            WVALID_S2 = 1'd0;
            BREADY_S2 = 1'd0;
			////S3
			AWID_S3 = 8'd0;
			AWADDR_S3 = 32'd0;
			AWLEN_S3 = 4'd0;
			AWSIZE_S3 = 3'd0;
			AWBURST_S3 = 2'd0;
			AWVALID_S3 = 1'd0;
			//
			WDATA_S3 = 32'd0;
			WSTRB_S3 = 4'd0;
			WLAST_S3 = 1'd0;
			WVALID_S3 = 1'd0;
			BREADY_S3 = 1'd0;
            ////S4
            AWID_S4 = 8'd0;
            AWADDR_S4 = 32'd0;
            AWLEN_S4 = 4'd0;
            AWSIZE_S4 = 3'd0;
            AWBURST_S4 = 2'd0;
            AWVALID_S4 = 1'd0;
            //
            WDATA_S4 = 32'd0;
            WSTRB_S4 = 4'd0;
            WLAST_S4 = 1'd0;
            WVALID_S4 = 1'd0;
            BREADY_S4 = 1'd0;
            ////S5
            AWID_S5 = 8'd0;
            AWADDR_S5 = 32'd0;
            AWLEN_S5 = 4'd0;
            AWSIZE_S5 = 3'd0;
            AWBURST_S5 = 2'd0;
            AWVALID_S5 = 1'd0;
            //
            WDATA_S5 = 32'd0;
            WSTRB_S5 = 4'd0;
            WLAST_S5 = 1'd0;
            WVALID_S5 = 1'd0;
            BREADY_S5 = 1'd0;
        end
        // path from M1 to S2
        else if(awaddr_reg[31:16]==16'h0002)
        begin
            //MASTER IO
            AWREADY_M1 = AWREADY_S2;
            //
            WREADY_M1 = WREADY_S2;
            //
            BID_M1 = BID_S2[3:0];
            BRESP_M1 = BRESP_S2;
            BVALID_M1 = BVALID_S2;
            ////////
            //SLAVE IO
            ////S2
			AWID_S2[7:4] = 4'b0;
            AWID_S2[3:0] = AWID_M1;
            AWADDR_S2 = AWADDR_M1;
            AWLEN_S2 = AWLEN_Reg;
            AWSIZE_S2 = AWSIZE_M1;
            AWBURST_S2 = AWBURST_M1;
            AWVALID_S2 = AWVALID_M1;
            //
			WDATA_S2 = WDATA_M1;
            WSTRB_S2 = WSTRB_M1;
            WLAST_S2 = WLAST_M1;
            WVALID_S2 = WVALID_M1;
            BREADY_S2 = BREADY_M1;
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
            BREADY_S1 = 1'd0;
			////S3
			AWID_S3 = 8'd0;
			AWADDR_S3 = 32'd0;
			AWLEN_S3 = 4'd0;
			AWSIZE_S3 = 3'd0;
			AWBURST_S3 = 2'd0;
			AWVALID_S3 = 1'd0;
			//
			WDATA_S3 = 32'd0;
			WSTRB_S3 = 4'd0;
			WLAST_S3 = 1'd0;
			WVALID_S3 = 1'd0;
			BREADY_S3 = 1'd0;
            ////S4
            AWID_S4 = 8'd0;
            AWADDR_S4 = 32'd0;
            AWLEN_S4 = 4'd0;
            AWSIZE_S4 = 3'd0;
            AWBURST_S4 = 2'd0;
            AWVALID_S4 = 1'd0;
            //
            WDATA_S4 = 32'd0;
            WSTRB_S4 = 4'd0;
            WLAST_S4 = 1'd0;
            WVALID_S4 = 1'd0;
            BREADY_S4 = 1'd0;
            ////S5
            AWID_S5 = 8'd0;
            AWADDR_S5 = 32'd0;
            AWLEN_S5 = 4'd0;
            AWSIZE_S5 = 3'd0;
            AWBURST_S5 = 2'd0;
            AWVALID_S5 = 1'd0;
            //
            WDATA_S5 = 32'd0;
            WSTRB_S5 = 4'd0;
            WLAST_S5 = 1'd0;
            WVALID_S5 = 1'd0;
            BREADY_S5 = 1'd0;
        end
		// path from M1 to S3
        else if(awaddr_reg[31:16]==16'h1000)
        begin
            //MASTER IO
            AWREADY_M1 = AWREADY_S3;
            //
            WREADY_M1 = WREADY_S3;
            //
            BID_M1 = BID_S3[3:0];
            BRESP_M1 = BRESP_S3;
            BVALID_M1 = BVALID_S3;
            ////////
            //SLAVE IO
            ////S3
			AWID_S3[7:4] = 4'b0;
            AWID_S3[3:0] = AWID_M1;
            AWADDR_S3 = AWADDR_M1;
            AWLEN_S3 = AWLEN_Reg;
            AWSIZE_S3 = AWSIZE_M1;
            AWBURST_S3 = AWBURST_M1;
            AWVALID_S3 = AWVALID_M1;
            //
			WDATA_S3 = WDATA_M1;
            WSTRB_S3 = WSTRB_M1;
            WLAST_S3 = WLAST_M1;
            WVALID_S3 = WVALID_M1;
            BREADY_S3 = BREADY_M1;
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
            BREADY_S1 = 1'd0;
			////S2
			AWID_S2 = 8'd0;
			AWADDR_S2 = 32'd0;
			AWLEN_S2 = 4'd0;
			AWSIZE_S2 = 3'd0;
			AWBURST_S2 = 2'd0;
			AWVALID_S2 = 1'd0;
			//
			WDATA_S2 = 32'd0;
			WSTRB_S2 = 4'd0;
			WLAST_S2 = 1'd0;
			WVALID_S2 = 1'd0;
			BREADY_S2 = 1'd0;
            ////S4
            AWID_S4 = 8'd0;
            AWADDR_S4 = 32'd0;
            AWLEN_S4 = 4'd0;
            AWSIZE_S4 = 3'd0;
            AWBURST_S4 = 2'd0;
            AWVALID_S4 = 1'd0;
            //
            WDATA_S4 = 32'd0;
            WSTRB_S4 = 4'd0;
            WLAST_S4 = 1'd0;
            WVALID_S4 = 1'd0;
            BREADY_S4 = 1'd0;
            ////S5
            AWID_S5 = 8'd0;
            AWADDR_S5 = 32'd0;
            AWLEN_S5 = 4'd0;
            AWSIZE_S5 = 3'd0;
            AWBURST_S5 = 2'd0;
            AWVALID_S5 = 1'd0;
            //
            WDATA_S5 = 32'd0;
            WSTRB_S5 = 4'd0;
            WLAST_S5 = 1'd0;
            WVALID_S5 = 1'd0;
            BREADY_S5 = 1'd0;
        end
        // path from M1 to S4
        else if(awaddr_reg[31:16]==16'h1001)
        begin
            //MASTER IO
            AWREADY_M1 = AWREADY_S4;
            //
            WREADY_M1 = WREADY_S4;
            //
            BID_M1 = BID_S4[3:0];
            BRESP_M1 = BRESP_S4;
            BVALID_M1 = BVALID_S4;
            ////////
            //SLAVE IO
            ////S4
			AWID_S4[7:4] = 4'b0;
            AWID_S4[3:0] = AWID_M1;
            AWADDR_S4 = AWADDR_M1;
            AWLEN_S4 = AWLEN_Reg;
            AWSIZE_S4 = AWSIZE_M1;
            AWBURST_S4 = AWBURST_M1;
            AWVALID_S4 = AWVALID_M1;
            //
			WDATA_S4 = WDATA_M1;
            WSTRB_S4 = WSTRB_M1;
            WLAST_S4 = WLAST_M1;
            WVALID_S4 = WVALID_M1;
            BREADY_S4 = BREADY_M1;
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
            BREADY_S1 = 1'd0;
			////S2
			AWID_S2 = 8'd0;
			AWADDR_S2 = 32'd0;
			AWLEN_S2 = 4'd0;
			AWSIZE_S2 = 3'd0;
			AWBURST_S2 = 2'd0;
			AWVALID_S2 = 1'd0;
			//
			WDATA_S2 = 32'd0;
			WSTRB_S2 = 4'd0;
			WLAST_S2 = 1'd0;
			WVALID_S2 = 1'd0;
			BREADY_S2 = 1'd0;
            ////S3
            AWID_S3 = 8'd0;
            AWADDR_S3 = 32'd0;
            AWLEN_S3 = 4'd0;
            AWSIZE_S3 = 3'd0;
            AWBURST_S3 = 2'd0;
            AWVALID_S3 = 1'd0;
            //
            WDATA_S3 = 32'd0;
            WSTRB_S3 = 4'd0;
            WLAST_S3 = 1'd0;
            WVALID_S3 = 1'd0;
            BREADY_S3 = 1'd0;
            ////S5
            AWID_S5 = 8'd0;
            AWADDR_S5 = 32'd0;
            AWLEN_S5 = 4'd0;
            AWSIZE_S5 = 3'd0;
            AWBURST_S5 = 2'd0;
            AWVALID_S5 = 1'd0;
            //
            WDATA_S5 = 32'd0;
            WSTRB_S5 = 4'd0;
            WLAST_S5 = 1'd0;
            WVALID_S5 = 1'd0;
            BREADY_S5 = 1'd0;
        end
        // path from M1 to S5
        else if(awaddr_reg[31:24]==8'h20)
        begin
            //MASTER IO
            AWREADY_M1 = AWREADY_S5;
            //
            WREADY_M1 = WREADY_S5;
            //
            BID_M1 = BID_S5[3:0];
            BRESP_M1 = BRESP_S5;
            BVALID_M1 = BVALID_S5;
            ////////
            //SLAVE IO
            ////S5
			AWID_S5[7:4] = 4'b0;
            AWID_S5[3:0] = AWID_M1;
            AWADDR_S5 = AWADDR_M1;
            AWLEN_S5 = AWLEN_Reg;
            AWSIZE_S5 = AWSIZE_M1;
            AWBURST_S5 = AWBURST_M1;
            AWVALID_S5 = AWVALID_M1;
            //
			WDATA_S5 = WDATA_M1;
            WSTRB_S5 = WSTRB_M1;
            WLAST_S5 = WLAST_M1;
            WVALID_S5 = WVALID_M1;
            BREADY_S5 = BREADY_M1;
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
            BREADY_S1 = 1'd0;
            ////S2
            AWID_S2 = 8'd0;
            AWADDR_S2 = 32'd0;
            AWLEN_S2 = 4'd0;
            AWSIZE_S2 = 3'd0;
            AWBURST_S2 = 2'd0;
            AWVALID_S2 = 1'd0;
            //
            WDATA_S2 = 32'd0;
            WSTRB_S2 = 4'd0;
            WLAST_S2 = 1'd0;
            WVALID_S2 = 1'd0;
            BREADY_S2 = 1'd0;
			////S3
			AWID_S3 = 8'd0;
			AWADDR_S3 = 32'd0;
			AWLEN_S3 = 4'd0;
			AWSIZE_S3 = 3'd0;
			AWBURST_S3 = 2'd0;
			AWVALID_S3 = 1'd0;
			//
			WDATA_S3 = 32'd0;
			WSTRB_S3 = 4'd0;
			WLAST_S3 = 1'd0;
			WVALID_S3 = 1'd0;
			BREADY_S3 = 1'd0;
            ////S4
            AWID_S4 = 8'd0;
            AWADDR_S4 = 32'd0;
            AWLEN_S4 = 4'd0;
            AWSIZE_S4 = 3'd0;
            AWBURST_S4 = 2'd0;
            AWVALID_S4 = 1'd0;
            //
            WDATA_S4 = 32'd0;
            WSTRB_S4 = 4'd0;
            WLAST_S4 = 1'd0;
            WVALID_S4 = 1'd0;
            BREADY_S4 = 1'd0;
        end
        else begin
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
        BREADY_S1 = 1'd0;
        ////S2
        AWID_S2 = 8'd0;
        AWADDR_S2 = 32'd0;
        AWLEN_S2 = 4'd0;
        AWSIZE_S2 = 3'd0;
        AWBURST_S2 = 2'd0;
        AWVALID_S2 = 1'd0;
        //
        WDATA_S2 = 32'd0;
        WSTRB_S2 = 4'd0;
        WLAST_S2 = 1'd0;
        WVALID_S2 = 1'd0;
        BREADY_S2 = 1'd0;
		////S3
        AWID_S3 = 8'd0;
        AWADDR_S3 = 32'd0;
        AWLEN_S3 = 4'd0;
        AWSIZE_S3 = 3'd0;
        AWBURST_S3 = 2'd0;
        AWVALID_S3 = 1'd0;
        //
        WDATA_S3 = 32'd0;
        WSTRB_S3 = 4'd0;
        WLAST_S3 = 1'd0;
        WVALID_S3 = 1'd0;
        BREADY_S3 = 1'd0;
        ////S4
        AWID_S4 = 8'd0;
        AWADDR_S4 = 32'd0;
        AWLEN_S4 = 4'd0;
        AWSIZE_S4 = 3'd0;
        AWBURST_S4 = 2'd0;
        AWVALID_S4 = 1'd0;
        //
        WDATA_S4 = 32'd0;
        WSTRB_S4 = 4'd0;
        WLAST_S4 = 1'd0;
        WVALID_S4 = 1'd0;
        BREADY_S4 = 1'd0;
        ////S5
        AWID_S5 = 8'd0;
        AWADDR_S5 = 32'd0;
        AWLEN_S5 = 4'd0;
        AWSIZE_S5 = 3'd0;
        AWBURST_S5 = 2'd0;
        AWVALID_S5 = 1'd0;
        //
        WDATA_S5 = 32'd0;
        WSTRB_S5 = 4'd0;
        WLAST_S5 = 1'd0;
        WVALID_S5 = 1'd0;
        BREADY_S5 = 1'd0;
	end
    end
    
    endcase
end

endmodule
