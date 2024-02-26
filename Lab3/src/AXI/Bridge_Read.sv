// 2023/11/15 2:28 : Added S3 (sensor)
// 2023/11/16 19:25 : Added S4 (WDT)
// `include "AXI_define.svh"

module Bridge_Read(

    input ACLK,
	input ARESETn,
//-----------MASTER0&1---------------//
    // Master
    // READ ADDRESS0
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output logic ARREADY_M0,

	// READ DATA0
	output logic [`AXI_ID_BITS-1:0] RID_M0,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M0,
	output logic [1:0] RRESP_M0,
	output logic RLAST_M0,
	output logic RVALID_M0,
	input RREADY_M0,

//-----------slave0---------------//
	// READ ADDRESS1
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output logic ARREADY_M1,

	// READ DATA1
	output logic [`AXI_ID_BITS-1:0] RID_M1,
	output logic [`AXI_DATA_BITS-1:0] RDATA_M1,
	output logic [1:0] RRESP_M1,
	output logic RLAST_M1,
	output logic RVALID_M1,
	input RREADY_M1,

    // Slave
    // READ ADDRESS0
	output logic [`AXI_IDS_BITS-1:0] ARID_S0,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output logic [1:0] ARBURST_S0,
	output logic ARVALID_S0,
	input ARREADY_S0,

	// READ DATA0
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output logic RREADY_S0,
//-----------slave1---------------//
	// READ ADDRESS1
	output logic [`AXI_IDS_BITS-1:0] ARID_S1,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output logic [1:0] ARBURST_S1,
	output logic ARVALID_S1,
	input ARREADY_S1,

	// READ DATA1
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output logic RREADY_S1,
//-----------slave2---------------//
    // READ ADDRESS2
	output logic [`AXI_IDS_BITS-1:0] ARID_S2,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S2,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S2,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
	output logic [1:0] ARBURST_S2,
	output logic ARVALID_S2,
	input ARREADY_S2,

	// READ DATA2
	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	output logic RREADY_S2,

//-----------slave3---------------//
    // READ ADDRESS3
	output logic [`AXI_IDS_BITS-1:0] ARID_S3,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S3,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S3,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
	output logic [1:0] ARBURST_S3,
	output logic ARVALID_S3,
	input ARREADY_S3,

	// READ DATA2
	input [`AXI_IDS_BITS-1:0] RID_S3,
	input [`AXI_DATA_BITS-1:0] RDATA_S3,
	input [1:0] RRESP_S3,
	input RLAST_S3,
	input RVALID_S3,
	output logic RREADY_S3,
//-----------slave4---------------//
    // READ ADDRESS4
	output logic [`AXI_IDS_BITS-1:0] ARID_S4,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S4,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S4,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
	output logic [1:0] ARBURST_S4,
	output logic ARVALID_S4,
	input ARREADY_S4,

	// READ DATA2
	input [`AXI_IDS_BITS-1:0] RID_S4,
	input [`AXI_DATA_BITS-1:0] RDATA_S4,
	input [1:0] RRESP_S4,
	input RLAST_S4,
	input RVALID_S4,
	output logic RREADY_S4,
//-----------slave5---------------//
    // READ ADDRESS5
	output logic [`AXI_IDS_BITS-1:0] ARID_S5,
	output logic [`AXI_ADDR_BITS-1:0] ARADDR_S5,
	output logic [`AXI_LEN_BITS-1:0] ARLEN_S5,
	output logic [`AXI_SIZE_BITS-1:0] ARSIZE_S5,
	output logic [1:0] ARBURST_S5,
	output logic ARVALID_S5,
	input ARREADY_S5,

	// READ DATA5
	input [`AXI_IDS_BITS-1:0] RID_S5,
	input [`AXI_DATA_BITS-1:0] RDATA_S5,
	input [1:0] RRESP_S5,
	input RLAST_S5,
	input RVALID_S5,
	output logic RREADY_S5
);

localparam  FREE = 1'b0,
            DATA = 1'b1;

logic state, nstate;
logic PREVIOUS_TAKEOVER_MASTER;// 1'b0 -> M0 , 1'b1 -> M1
logic TAKEOVER_MASTER;
logic WRONG_ADDRESS;
logic [`AXI_LEN_BITS-1:0] ARLEN_Reg;
always_ff@(posedge ACLK)begin
    if(!ARESETn)
    begin
        state <= FREE;
        PREVIOUS_TAKEOVER_MASTER<=1'b1;
    end
	else begin
        state <= nstate;
        if(nstate==DATA) 
        begin
            PREVIOUS_TAKEOVER_MASTER<=TAKEOVER_MASTER;
        end
        /*else if(state==DATA)
        begin
            PREVIOUS_TAKEOVER_MASTER<=PREVIOUS_TAKEOVER_MASTER;
        end*/
		else
			PREVIOUS_TAKEOVER_MASTER<=PREVIOUS_TAKEOVER_MASTER;
    end
end

always_ff@(posedge ACLK)begin
    if(!ARESETn)
    begin
        TAKEOVER_MASTER<=1'b0;
        ARLEN_Reg <= 4'd0;
    end
	else begin
        case(state)
    FREE:begin
        if(ARVALID_M0 && ARVALID_M1 /*&& ARREADY_S0 && ARREADY_S1*/) 
        begin
            TAKEOVER_MASTER<=~PREVIOUS_TAKEOVER_MASTER;
            if(PREVIOUS_TAKEOVER_MASTER) 
            begin
                ARLEN_Reg <= ARLEN_M0;//+4'b1;
            end
            else
            begin
                ARLEN_Reg <= ARLEN_M1;//+4'b1;
            end
        end
        else if((ARVALID_M1 && ARREADY_S0)||(ARVALID_M1 && ARREADY_S1)||(ARVALID_M1 && ARREADY_S2)||(ARVALID_M1 && ARREADY_S3)||(ARVALID_M1 && ARREADY_S4)||(ARVALID_M1 && ARREADY_S5)) 
        begin
            TAKEOVER_MASTER<=1'b1;
            ARLEN_Reg <= ARLEN_M1;
        end
        else if((ARVALID_M0 && ARREADY_S0)||(ARVALID_M0 && ARREADY_S1)||(ARVALID_M0 && ARREADY_S2)||(ARVALID_M0 && ARREADY_S3)||(ARVALID_M0 && ARREADY_S4)||(ARVALID_M0 && ARREADY_S5)) 
        begin
            TAKEOVER_MASTER<=1'b0;
            ARLEN_Reg <= ARLEN_M0;
        end
        
        else 
        begin
            TAKEOVER_MASTER<=1'b0;
            ARLEN_Reg <= ARLEN_M0;
        end
    end
    DATA:begin
        TAKEOVER_MASTER<=TAKEOVER_MASTER;
        if (ARLEN_Reg != 4'd0)
            begin
                ARLEN_Reg <= ARLEN_Reg - 4'b1;
            end
        else 
            begin
                ARLEN_Reg <= ARLEN_Reg;
            end
    end
    endcase
    end
end

//next state logic(comb)
always@(*)begin
    case(state)
    FREE:begin

        if((ARVALID_M0 && ARREADY_S0)||(ARVALID_M0 && ARREADY_S1)||(ARVALID_M0 && ARREADY_S2)||(ARVALID_M0 && ARREADY_S3)||(ARVALID_M0 && ARREADY_S4)||(ARVALID_M0 && ARREADY_S5)) 
        begin
            nstate=DATA;
        end//////////////////////////////
        else if((ARVALID_M1 && ARREADY_S0)||(ARVALID_M1 && ARREADY_S1)||(ARVALID_M1 && ARREADY_S2)||(ARVALID_M1 && ARREADY_S3)||(ARVALID_M1 && ARREADY_S4)||(ARVALID_M1 && ARREADY_S5)) 
        begin
            nstate=DATA;//
        end
        else 
        begin
            nstate=FREE;
        end
    end
    DATA:begin
        //??��?? TAKEOVER_MASTER �? ?????��?? RLAST ...
        if (TAKEOVER_MASTER == 1'b0)
        begin
            if ((RREADY_S0&&RVALID_S0&&RLAST_M0)||(RREADY_S1&&RVALID_S1&&RLAST_M0)||(RREADY_S2&&RVALID_S2&&RLAST_M0)||(RREADY_S3&&RVALID_S3&&RLAST_M0)||(RREADY_S4&&RVALID_S4&&RLAST_M0)||(RREADY_S5&&RVALID_S5&&RLAST_M0))//RLAST_S0
                nstate=FREE;
            else
                nstate=DATA;
        end
        else
        begin
            if ((RREADY_S1&&RVALID_S1&&RLAST_M1)||(RREADY_S0&&RVALID_S0&&RLAST_M1)||(RREADY_S2&&RVALID_S2&&RLAST_M1)||(RREADY_S3&&RVALID_S3&&RLAST_M1)||(RREADY_S4&&RVALID_S4&&RLAST_M1)||(RREADY_S5&&RVALID_S5&&RLAST_M1))
                nstate=FREE;
            else
                nstate=DATA;
        end
    end
    endcase
end
logic rid_counter;
always_ff@(posedge ACLK)
begin
    if(!ARESETn)
    begin
        rid_counter <= 1'b0;
    end
    else begin
      if(state==FREE) begin
	rid_counter <= 1'b0;
	end
	else /*if(state==DATA)*/ begin
	rid_counter <= 1'b1;
	end
    end
end 

//M1 register decision maker
logic [31:0] ARADDR_M1_reg;
logic RVALID_M1_reg;
always_ff@(posedge ACLK)begin
    if(!ARESETn)
    begin
        RVALID_M1_reg <= 1'b0;
    end
	else begin
        RVALID_M1_reg <= RVALID_M1;
      end
end 
always_ff@(posedge ACLK)begin
    if(!ARESETn)
    begin
        ARADDR_M1_reg <= 32'b0;
    end
	else begin
        if(state==DATA)begin
        	if(rid_counter/*RVALID_M1_reg||RVALID_M1*/)
        	ARADDR_M1_reg <= ARADDR_M1_reg;
        	else
        	ARADDR_M1_reg <= ARADDR_M1;
        end
        else
        ARADDR_M1_reg <= ARADDR_M1;
	end
end 

//M0 register decision maker
logic [31:0] ARADDR_M0_reg;
logic RVALID_M0_reg;
always_ff@(posedge ACLK)begin
    if(!ARESETn)
    begin
        RVALID_M0_reg <= 1'b0;
    end
	else begin
        RVALID_M0_reg <= RVALID_M0;
      end
end 
always_ff@(posedge ACLK)begin
    if(!ARESETn)
    begin
        ARADDR_M0_reg <= 32'b0;
    end
	else begin
        if(state==DATA)begin
        	if(rid_counter/*RVALID_M0_reg||RVALID_M0*/)
        	ARADDR_M0_reg <= ARADDR_M0_reg;
        	else
        	ARADDR_M0_reg <= ARADDR_M0;
        end
        else
        ARADDR_M0_reg <= ARADDR_M0;
	end
end 
//########################################################################################################################################
logic [31:0] ARADDR_M1_reg2;
always@(*)begin
	if(state==FREE)
	ARADDR_M1_reg2 = ARADDR_M1;
	else /*if(state==DATA)*/ begin
		if(RVALID_M1_reg)
		ARADDR_M1_reg2 = ARADDR_M1_reg;
		else begin
            if(~rid_counter)
            ARADDR_M1_reg2 = ARADDR_M1;
            else
            ARADDR_M1_reg2 = ARADDR_M1_reg;
		end
	end
end
logic [31:0] ARADDR_M0_reg2;
always@(*)begin
	if(state==FREE) ARADDR_M0_reg2 = ARADDR_M0;
	else /*if(state==DATA)*/ begin
		if(RVALID_M0_reg)
		ARADDR_M0_reg2 = ARADDR_M0_reg;
		else begin
		if(~rid_counter)
		ARADDR_M0_reg2 = ARADDR_M0;
		else
		ARADDR_M0_reg2 = ARADDR_M0_reg;
		end
	end
end
logic [3:0] RID1_reg;
logic [3:0] RID2_reg;

always@(*)begin
    case(state)
    FREE:begin
        // $display("FREE");
        WRONG_ADDRESS = 1'd0;
        ARREADY_M0 = 1'd0;
        ARREADY_M1 = 1'd0;

        ////
        RID_M0 = 4'd0;
        RDATA_M0 = 32'd0;
        RRESP_M0 = 2'd0;
        RLAST_M0 = 1'd0;
        RVALID_M0 = 1'd0;
        //
        RID_M1 = 4'd0;
        RDATA_M1 = 32'd0;
        RRESP_M1 = 2'd0;
        RLAST_M1 = 1'd0;
        RVALID_M1 = 1'd0;
        /////////////////////////
        RREADY_S0 = 1'd0;
        RREADY_S1 = 1'd0;
        RREADY_S2 = 1'd0;
		RREADY_S3 = 1'd0;
        RREADY_S4 = 1'd0;
        RREADY_S5 = 1'd0;
        /////////////////////////
        //////
        ARID_S0 = 8'd0;
        ARADDR_S0 = 32'd0;
        ARLEN_S0 = 4'd0;
        ARSIZE_S0 = 3'd0;
        ARBURST_S0 = 2'd0;
        ARVALID_S0 = 1'd0;

        ARID_S1 = 8'd0;
        ARADDR_S1 = 32'd0;
        ARLEN_S1 = 4'd0;
        ARSIZE_S1 = 3'd0;
        ARBURST_S1 = 2'd0;
        ARVALID_S1 = 1'd0;

        ARID_S2 = 8'd0;
        ARADDR_S2 = 32'd0;
        ARLEN_S2 = 4'd0;
        ARSIZE_S2 = 3'd0;
        ARBURST_S2 = 2'd0;
        ARVALID_S2 = 1'd0;
		
		ARID_S3 = 8'd0;
        ARADDR_S3 = 32'd0;
        ARLEN_S3 = 4'd0;
        ARSIZE_S3 = 3'd0;
        ARBURST_S3 = 2'd0;
        ARVALID_S3 = 1'd0;

        ARID_S4 = 8'd0;
        ARADDR_S4 = 32'd0;
        ARLEN_S4 = 4'd0;
        ARSIZE_S4 = 3'd0;
        ARBURST_S4 = 2'd0;
        ARVALID_S4 = 1'd0;

        ARID_S5 = 8'd0;
        ARADDR_S5 = 32'd0;
        ARLEN_S5 = 4'd0;
        ARSIZE_S5 = 3'd0;
        ARBURST_S5 = 2'd0;
        ARVALID_S5 = 1'd0;        
    end

    DATA:begin
        if (TAKEOVER_MASTER == 1'b0) begin
            if(ARADDR_M0_reg2[31:16]==16'h0000) begin//M0+S0
                ARID_S0[7:4] = 4'b0;
                ARID_S0[3:0] = ARID_M0;
                ARADDR_S0 = ARADDR_M0;
                ARLEN_S0 = ARLEN_M0;
                ARSIZE_S0 = ARSIZE_M0;
                ARBURST_S0 = ARBURST_M0;
                ARVALID_S0 = ARVALID_M0;
                //end
                ARREADY_M0 = ARREADY_S0;
                WRONG_ADDRESS = 1'b0;
                
                RID_M0 = RID_S0[3:0];
                RDATA_M0 = RDATA_S0;
                RRESP_M0 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M0 = RLAST_S0;
                else
                RLAST_M0 = 1'b0;
                //end
                RVALID_M0 = RVALID_S0;
                RREADY_S0 = RREADY_M0;
                //

                ARREADY_M1 = 1'd0;
                RID_M1 = 4'd0;
                RDATA_M1 = 32'd0;
                RRESP_M1 = 2'd0;
                RLAST_M1 = 1'd0;
                RVALID_M1 = 1'd0;

                
                RREADY_S1 = 1'd0;
                RREADY_S2 = 1'd0;
				RREADY_S3 = 1'd0;
                RREADY_S4 = 1'd0;
                RREADY_S5 = 1'd0;
                //////

                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;

                ARID_S2 = 8'd0;
                ARADDR_S2 = 32'd0;
                ARLEN_S2 = 4'd0;
                ARSIZE_S2 = 3'd0;
                ARBURST_S2 = 2'd0;
                ARVALID_S2 = 1'd0;
				
				ARID_S3 = 8'd0;
                ARADDR_S3 = 32'd0;
                ARLEN_S3 = 4'd0;
                ARSIZE_S3 = 3'd0;
                ARBURST_S3 = 2'd0;
                ARVALID_S3 = 1'd0;

                ARID_S4 = 8'd0;
                ARADDR_S4 = 32'd0;
                ARLEN_S4 = 4'd0;
                ARSIZE_S4 = 3'd0;
                ARBURST_S4 = 2'd0;
                ARVALID_S4 = 1'd0;

                ARID_S5 = 8'd0;
                ARADDR_S5 = 32'd0;
                ARLEN_S5 = 4'd0;
                ARSIZE_S5 = 3'd0;
                ARBURST_S5 = 2'd0;
                ARVALID_S5 = 1'd0;
                //end
                
            end
            else if(ARADDR_M0_reg2[31:16]==16'b1)begin//M0 + S1
                WRONG_ADDRESS = 1'b0;
                ARID_S1[7:4] = 4'b0;
                ARID_S1[3:0] = ARID_M0;
                ARADDR_S1 = ARADDR_M0;
                ARLEN_S1 = ARLEN_M0;
                ARSIZE_S1 = ARSIZE_M0;
                ARBURST_S1 = ARBURST_M0;
                ARVALID_S1 = ARVALID_M0;
                //end
                ARREADY_M0 = ARREADY_S1;
                RID_M0 = RID_S1[3:0];
                RDATA_M0 = RDATA_S1;
                RRESP_M0 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M0 = RLAST_S1;
                else
                RLAST_M0 = 1'b0;
                //end
                RVALID_M0 = RVALID_S1;
                RREADY_S1 = RREADY_M0;
                //
                ARREADY_M1 = 1'd0;
                RID_M1 = 4'd0;
                RDATA_M1 = 32'd0;
                RRESP_M1 = 2'd0;
                RLAST_M1 = 1'd0;
                RVALID_M1 = 1'd0;

                //if(ARREADY_S0) 
                //begin
                
                RREADY_S0 = 1'd0;
                RREADY_S2 = 1'd0;
				RREADY_S3 = 1'd0;
                RREADY_S4 = 1'd0;
                RREADY_S5 = 1'd0;
                //////
                ARID_S0 = 8'd0;
                ARADDR_S0 = 32'd0;
                ARLEN_S0 = 4'd0;
                ARSIZE_S0 = 3'd0;
                ARBURST_S0 = 2'd0;
                ARVALID_S0 = 1'd0;

                ARID_S2 = 8'd0;
                ARADDR_S2 = 32'd0;
                ARLEN_S2 = 4'd0;
                ARSIZE_S2 = 3'd0;
                ARBURST_S2 = 2'd0;
                ARVALID_S2 = 1'd0;
				
				ARID_S3 = 8'd0;
                ARADDR_S3 = 32'd0;
                ARLEN_S3 = 4'd0;
                ARSIZE_S3 = 3'd0;
                ARBURST_S3 = 2'd0;
                ARVALID_S3 = 1'd0;

                ARID_S4 = 8'd0;
                ARADDR_S4 = 32'd0;
                ARLEN_S4 = 4'd0;
                ARSIZE_S4 = 3'd0;
                ARBURST_S4 = 2'd0;
                ARVALID_S4 = 1'd0;

                ARID_S5 = 8'd0;
                ARADDR_S5 = 32'd0;
                ARLEN_S5 = 4'd0;
                ARSIZE_S5 = 3'd0;
                ARBURST_S5 = 2'd0;
                ARVALID_S5 = 1'd0;
                //end
            end
            else if(ARADDR_M0_reg2[31:16]==16'h0002)begin//M0+S2
                ARID_S2[7:4] = 4'b0;
                ARID_S2[3:0] = ARID_M0;
                ARADDR_S2 = ARADDR_M0;
                ARLEN_S2 = ARLEN_M0;
                ARSIZE_S2 = ARSIZE_M0;
                ARBURST_S2 = ARBURST_M0;
                ARVALID_S2 = ARVALID_M0;
                //end
                ARREADY_M0 = ARREADY_S2;
                WRONG_ADDRESS = 1'b0;
                
                RID_M0 = RID_S2[3:0];
                RDATA_M0 = RDATA_S2;
                RRESP_M0 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M0 = RLAST_S2;
                else
                RLAST_M0 = 1'b0;
                //end
                RVALID_M0 = RVALID_S2;
                RREADY_S2 = RREADY_M0;
                //
                ARREADY_M1 = 1'd0;
                RID_M1 = 4'd0;
                RDATA_M1 = 32'd0;
                RRESP_M1 = 2'd0;
                RLAST_M1 = 1'd0;
                RVALID_M1 = 1'd0;

                RREADY_S0 = 1'd0;
                RREADY_S1 = 1'd0;
				RREADY_S3 = 1'd0;
                RREADY_S4 = 1'd0;
                RREADY_S5 = 1'd0;
                //////
                ARID_S0 = 8'd0;
                ARADDR_S0 = 32'd0;
                ARLEN_S0 = 4'd0;
                ARSIZE_S0 = 3'd0;
                ARBURST_S0 = 2'd0;
                ARVALID_S0 = 1'd0;

                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;
				
				ARID_S3 = 8'd0;
                ARADDR_S3 = 32'd0;
                ARLEN_S3 = 4'd0;
                ARSIZE_S3 = 3'd0;
                ARBURST_S3 = 2'd0;
                ARVALID_S3 = 1'd0;

                ARID_S4 = 8'd0;
                ARADDR_S4 = 32'd0;
                ARLEN_S4 = 4'd0;
                ARSIZE_S4 = 3'd0;
                ARBURST_S4 = 2'd0;
                ARVALID_S4 = 1'd0;

                ARID_S5 = 8'd0;
                ARADDR_S5 = 32'd0;
                ARLEN_S5 = 4'd0;
                ARSIZE_S5 = 3'd0;
                ARBURST_S5 = 2'd0;
                ARVALID_S5 = 1'd0;
            end
			else if(ARADDR_M0_reg2[31:16]==16'h1000)begin//M0+S3
                ARID_S3[7:4] = 4'b0;
                ARID_S3[3:0] = ARID_M0;
                ARADDR_S3 = ARADDR_M0;
                ARLEN_S3 = ARLEN_M0;
                ARSIZE_S3 = ARSIZE_M0;
                ARBURST_S3 = ARBURST_M0;
                ARVALID_S3 = ARVALID_M0;
                //end
                ARREADY_M0 = ARREADY_S3;
                WRONG_ADDRESS = 1'b0;
                
                RID_M0 = RID_S3[3:0];
                RDATA_M0 = RDATA_S3;
                RRESP_M0 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M0 = RLAST_S3;
                else
                RLAST_M0 = 1'b0;
                //end
                RVALID_M0 = RVALID_S3;
                RREADY_S3 = RREADY_M0;
                //
                ARREADY_M1 = 1'd0;
                RID_M1 = 4'd0;
                RDATA_M1 = 32'd0;
                RRESP_M1 = 2'd0;
                RLAST_M1 = 1'd0;
                RVALID_M1 = 1'd0;

                RREADY_S0 = 1'd0;
                RREADY_S1 = 1'd0;
				RREADY_S2 = 1'd0;
                RREADY_S4 = 1'd0;
                RREADY_S5 = 1'd0;
                //////
                ARID_S0 = 8'd0;
                ARADDR_S0 = 32'd0;
                ARLEN_S0 = 4'd0;
                ARSIZE_S0 = 3'd0;
                ARBURST_S0 = 2'd0;
                ARVALID_S0 = 1'd0;

                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;
				
				ARID_S2 = 8'd0;
                ARADDR_S2 = 32'd0;
                ARLEN_S2 = 4'd0;
                ARSIZE_S2 = 3'd0;
                ARBURST_S2 = 2'd0;
                ARVALID_S2 = 1'd0;

                ARID_S4 = 8'd0;
                ARADDR_S4 = 32'd0;
                ARLEN_S4 = 4'd0;
                ARSIZE_S4 = 3'd0;
                ARBURST_S4 = 2'd0;
                ARVALID_S4 = 1'd0;

                ARID_S5 = 8'd0;
                ARADDR_S5 = 32'd0;
                ARLEN_S5 = 4'd0;
                ARSIZE_S5 = 3'd0;
                ARBURST_S5 = 2'd0;
                ARVALID_S5 = 1'd0;
            end
            else if(ARADDR_M0_reg2[31:16]==16'h1001)begin//M0+S4
                ARID_S4[7:4] = 4'b0;
                ARID_S4[3:0] = ARID_M0;
                ARADDR_S4 = ARADDR_M0;
                ARLEN_S4 = ARLEN_M0;
                ARSIZE_S4 = ARSIZE_M0;
                ARBURST_S4 = ARBURST_M0;
                ARVALID_S4 = ARVALID_M0;
                //end
                ARREADY_M0 = ARREADY_S4;
                WRONG_ADDRESS = 1'b0;
                
                RID_M0 = RID_S4[3:0];
                RDATA_M0 = RDATA_S4;
                RRESP_M0 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M0 = RLAST_S4;
                else
                RLAST_M0 = 1'b0;
                //end
                RVALID_M0 = RVALID_S4;
                RREADY_S4 = RREADY_M0;
                //
                ARREADY_M1 = 1'd0;
                RID_M1 = 4'd0;
                RDATA_M1 = 32'd0;
                RRESP_M1 = 2'd0;
                RLAST_M1 = 1'd0;
                RVALID_M1 = 1'd0;

                RREADY_S0 = 1'd0;
                RREADY_S1 = 1'd0;
				RREADY_S2 = 1'd0;
                RREADY_S3 = 1'd0;
                RREADY_S5 = 1'd0;
                //////
                ARID_S0 = 8'd0;
                ARADDR_S0 = 32'd0;
                ARLEN_S0 = 4'd0;
                ARSIZE_S0 = 3'd0;
                ARBURST_S0 = 2'd0;
                ARVALID_S0 = 1'd0;

                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;
				
				ARID_S2 = 8'd0;
                ARADDR_S2 = 32'd0;
                ARLEN_S2 = 4'd0;
                ARSIZE_S2 = 3'd0;
                ARBURST_S2 = 2'd0;
                ARVALID_S2 = 1'd0;

                ARID_S3 = 8'd0;
                ARADDR_S3 = 32'd0;
                ARLEN_S3 = 4'd0;
                ARSIZE_S3 = 3'd0;
                ARBURST_S3 = 2'd0;
                ARVALID_S3 = 1'd0;

                ARID_S5 = 8'd0;
                ARADDR_S5 = 32'd0;
                ARLEN_S5 = 4'd0;
                ARSIZE_S5 = 3'd0;
                ARBURST_S5 = 2'd0;
                ARVALID_S5 = 1'd0;
            end

            else if(ARADDR_M0_reg2[31:24]==8'h20)begin//M0+S5
                ARID_S5[7:4] = 4'b0;
                ARID_S5[3:0] = ARID_M0;
                ARADDR_S5 = ARADDR_M0;
                ARLEN_S5 = ARLEN_M0;
                ARSIZE_S5 = ARSIZE_M0;
                ARBURST_S5 = ARBURST_M0;
                ARVALID_S5 = ARVALID_M0;
                //end
                ARREADY_M0 = ARREADY_S5;
                WRONG_ADDRESS = 1'b0;
                
                RID_M0 = RID_S5[3:0];
                RDATA_M0 = RDATA_S5;
                RRESP_M0 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M0 = RLAST_S5;
                else
                RLAST_M0 = 1'b0;
                //end
                RVALID_M0 = RVALID_S5;
                RREADY_S5 = RREADY_M0;
                //
                ARREADY_M1 = 1'd0;
                RID_M1 = 4'd0;
                RDATA_M1 = 32'd0;
                RRESP_M1 = 2'd0;
                RLAST_M1 = 1'd0;
                RVALID_M1 = 1'd0;

                RREADY_S0 = 1'd0;
                RREADY_S1 = 1'd0;
				RREADY_S3 = 1'd0;
                RREADY_S4 = 1'd0;
                RREADY_S2 = 1'd0;
                //////
                ARID_S0 = 8'd0;
                ARADDR_S0 = 32'd0;
                ARLEN_S0 = 4'd0;
                ARSIZE_S0 = 3'd0;
                ARBURST_S0 = 2'd0;
                ARVALID_S0 = 1'd0;

                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;

                ARID_S2 = 8'd0;
                ARADDR_S2 = 32'd0;
                ARLEN_S2 = 4'd0;
                ARSIZE_S2 = 3'd0;
                ARBURST_S2 = 2'd0;
                ARVALID_S2 = 1'd0;
				
				ARID_S3 = 8'd0;
                ARADDR_S3 = 32'd0;
                ARLEN_S3 = 4'd0;
                ARSIZE_S3 = 3'd0;
                ARBURST_S3 = 2'd0;
                ARVALID_S3 = 1'd0;

                ARID_S4 = 8'd0;
                ARADDR_S4 = 32'd0;
                ARLEN_S4 = 4'd0;
                ARSIZE_S4 = 3'd0;
                ARBURST_S4 = 2'd0;
                ARVALID_S4 = 1'd0;
            end
	    else begin
WRONG_ADDRESS = 1'd0;
        ARREADY_M0 = 1'd0;
        ARREADY_M1 = 1'd0;

        ////
        RID_M0 = 4'd0;
        RDATA_M0 = 32'd0;
        RRESP_M0 = 2'd0;
        RLAST_M0 = 1'd0;
        RVALID_M0 = 1'd0;
        //
        RID_M1 = 4'd0;
        RDATA_M1 = 32'd0;
        RRESP_M1 = 2'd0;
        RLAST_M1 = 1'd0;
        RVALID_M1 = 1'd0;
        /////////////////////////
        RREADY_S0 = 1'd0;
        RREADY_S1 = 1'd0;
        RREADY_S2 = 1'd0;
		RREADY_S3 = 1'd0;
        RREADY_S4 = 1'd0;
        RREADY_S5 = 1'd0;
        /////////////////////////
        //////
        ARID_S0 = 8'd0;
        ARADDR_S0 = 32'd0;
        ARLEN_S0 = 4'd0;
        ARSIZE_S0 = 3'd0;
        ARBURST_S0 = 2'd0;
        ARVALID_S0 = 1'd0;

        ARID_S1 = 8'd0;
        ARADDR_S1 = 32'd0;
        ARLEN_S1 = 4'd0;
        ARSIZE_S1 = 3'd0;
        ARBURST_S1 = 2'd0;
        ARVALID_S1 = 1'd0;

        ARID_S2 = 8'd0;
        ARADDR_S2 = 32'd0;
        ARLEN_S2 = 4'd0;
        ARSIZE_S2 = 3'd0;
        ARBURST_S2 = 2'd0;
        ARVALID_S2 = 1'd0;
		
		ARID_S3 = 8'd0;
        ARADDR_S3 = 32'd0;
        ARLEN_S3 = 4'd0;
        ARSIZE_S3 = 3'd0;
        ARBURST_S3 = 2'd0;
        ARVALID_S3 = 1'd0;

        ARID_S4 = 8'd0;
        ARADDR_S4 = 32'd0;
        ARLEN_S4 = 4'd0;
        ARSIZE_S4 = 3'd0;
        ARBURST_S4 = 2'd0;
        ARVALID_S4 = 1'd0;

        ARID_S5 = 8'd0;
        ARADDR_S5 = 32'd0;
        ARLEN_S5 = 4'd0;
        ARSIZE_S5 = 3'd0;
        ARBURST_S5 = 2'd0;
        ARVALID_S5 = 1'd0;  
	    end
        end
        ///////////////////////////////////////////////////////
        else begin//M1 take over
            if(ARADDR_M1_reg2[31:16]==16'h0000) begin// M1 + S0
                WRONG_ADDRESS = 1'b0;
                ARID_S0[7:4] = 4'b0;
                ARID_S0[3:0] = ARID_M1;
                ARADDR_S0 = ARADDR_M1_reg2;
                ARLEN_S0 = ARLEN_M1;
                ARSIZE_S0 = ARSIZE_M1;
                ARBURST_S0 = ARBURST_M1;
                ARVALID_S0 = ARVALID_M1;

                ARREADY_M1 = ARREADY_S0;
                RID_M1 = RID_S0[3:0];
                RDATA_M1 = RDATA_S0;
                RRESP_M1 = 2'b00;

                if (ARLEN_Reg == 4'd0) 
                RLAST_M1 = RLAST_S0;
                else
                RLAST_M1 = 1'b0;
                RVALID_M1 = RVALID_S0;
                RREADY_S0 = RREADY_M1;
                //
                ARREADY_M0 = 1'd0;
                RID_M0 = 4'd0;
                RDATA_M0 = 32'd0;
                RRESP_M0 = 2'd0;
                RLAST_M0 = 1'd0;
                RVALID_M0 = 1'd0;

                RREADY_S1 = 1'd0;
                RREADY_S2 = 1'd0;
				RREADY_S3 = 1'd0;
                RREADY_S4 = 1'd0;
                RREADY_S5 = 1'd0;
                //////

                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;

                ARID_S2 = 8'd0;
                ARADDR_S2 = 32'd0;
                ARLEN_S2 = 4'd0;
                ARSIZE_S2 = 3'd0;
                ARBURST_S2 = 2'd0;
                ARVALID_S2 = 1'd0;
				
				ARID_S3 = 8'd0;
                ARADDR_S3 = 32'd0;
                ARLEN_S3 = 4'd0;
                ARSIZE_S3 = 3'd0;
                ARBURST_S3 = 2'd0;
                ARVALID_S3 = 1'd0;

                ARID_S4 = 8'd0;
                ARADDR_S4 = 32'd0;
                ARLEN_S4 = 4'd0;
                ARSIZE_S4 = 3'd0;
                ARBURST_S4 = 2'd0;
                ARVALID_S4 = 1'd0;

                ARID_S5 = 8'd0;
                ARADDR_S5 = 32'd0;
                ARLEN_S5 = 4'd0;
                ARSIZE_S5 = 3'd0;
                ARBURST_S5 = 2'd0;
                ARVALID_S5 = 1'd0;
            end
            else if(ARADDR_M1_reg2[31:16]==16'h0001) begin//M1+S1
                WRONG_ADDRESS = 1'b0;
                ARID_S1[7:4] = 4'b0;
                ARID_S1[3:0] = ARID_M1;
                ARADDR_S1 = ARADDR_M1_reg2;
                ARLEN_S1 = ARLEN_M1;
                ARSIZE_S1 = ARSIZE_M1;
                ARBURST_S1 = ARBURST_M1;
                ARVALID_S1 = ARVALID_M1;
                ARREADY_M1 = ARREADY_S1;

                ARREADY_M0 = 1'd0;
                RID_M0 = 4'd0;
                RDATA_M0 = 32'd0;
                RRESP_M0 = 2'd0;
                RLAST_M0 = 1'd0;
                RVALID_M0 = 1'd0;

                RID_M1 = RID_S1[3:0];
                RDATA_M1 = RDATA_S1;
                RRESP_M1 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M1 = RLAST_S1;
                else
                RLAST_M1 = 1'b0;
                //end
                RVALID_M1 = RVALID_S1;

                RREADY_S0 = 1'd0;
                RREADY_S1 = RREADY_M1;
                RREADY_S2 = 1'd0;
				RREADY_S3 = 1'd0;
                RREADY_S4 = 1'd0;
                RREADY_S5 = 1'd0;
                //////
                ARID_S0 = 8'd0;
                ARADDR_S0 = 32'd0;
                ARLEN_S0 = 4'd0;
                ARSIZE_S0 = 3'd0;
                ARBURST_S0 = 2'd0;
                ARVALID_S0 = 1'd0;

                ARID_S2 = 8'd0;
                ARADDR_S2 = 32'd0;
                ARLEN_S2 = 4'd0;
                ARSIZE_S2 = 3'd0;
                ARBURST_S2 = 2'd0;
                ARVALID_S2 = 1'd0;
				
				ARID_S3 = 8'd0;
                ARADDR_S3 = 32'd0;
                ARLEN_S3 = 4'd0;
                ARSIZE_S3 = 3'd0;
                ARBURST_S3 = 2'd0;
                ARVALID_S3 = 1'd0;

                ARID_S4 = 8'd0;
                ARADDR_S4 = 32'd0;
                ARLEN_S4 = 4'd0;
                ARSIZE_S4 = 3'd0;
                ARBURST_S4 = 2'd0;
                ARVALID_S4 = 1'd0;

                ARID_S5 = 8'd0;
                ARADDR_S5 = 32'd0;
                ARLEN_S5 = 4'd0;
                ARSIZE_S5 = 3'd0;
                ARBURST_S5 = 2'd0;
                ARVALID_S5 = 1'd0;
                
            end
            else if(ARADDR_M1_reg2[31:16]==16'h0002)begin//M1+S2
                WRONG_ADDRESS = 1'b0;
                ARID_S2[7:4] = 4'b0;
                ARID_S2[3:0] = ARID_M1;
                ARADDR_S2 = ARADDR_M1_reg2;
                ARLEN_S2 = ARLEN_M1;
                ARSIZE_S2 = ARSIZE_M1;
                ARBURST_S2 = ARBURST_M1;
                ARVALID_S2 = ARVALID_M1;
                
                ARREADY_M1 = ARREADY_S2;
                //
                ARREADY_M0 = 1'd0;
                RID_M0 = 4'd0;
                RDATA_M0 = 32'd0;
                RRESP_M0 = 2'd0;
                RLAST_M0 = 1'd0;
                RVALID_M0 = 1'd0;
                //
                RID_M1 = RID_S2[3:0];
                RDATA_M1 = RDATA_S2;
                RRESP_M1 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M1 = RLAST_S2;
                else
                RLAST_M1 = 1'b0;
                //end
                RVALID_M1 = RVALID_S2;

                RREADY_S2 = RREADY_M1;
                RREADY_S0 = 1'd0;
                RREADY_S1 = 1'd0;
				RREADY_S3 = 1'd0;
                RREADY_S4 = 1'd0;
                RREADY_S5 = 1'd0;
                //////
                ARID_S0 = 8'd0;
                ARADDR_S0 = 32'd0;
                ARLEN_S0 = 4'd0;
                ARSIZE_S0 = 3'd0;
                ARBURST_S0 = 2'd0;
                ARVALID_S0 = 1'd0;

                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;
				
				ARID_S3 = 8'd0;
                ARADDR_S3 = 32'd0;
                ARLEN_S3 = 4'd0;
                ARSIZE_S3 = 3'd0;
                ARBURST_S3 = 2'd0;
                ARVALID_S3 = 1'd0;

                ARID_S4 = 8'd0;
                ARADDR_S4 = 32'd0;
                ARLEN_S4 = 4'd0;
                ARSIZE_S4 = 3'd0;
                ARBURST_S4 = 2'd0;
                ARVALID_S4 = 1'd0;

                ARID_S5 = 8'd0;
                ARADDR_S5 = 32'd0;
                ARLEN_S5 = 4'd0;
                ARSIZE_S5 = 3'd0;
                ARBURST_S5 = 2'd0;
                ARVALID_S5 = 1'd0;
            end
			else if(ARADDR_M1_reg2[31:16]==16'h1000)begin//M1+S3
                WRONG_ADDRESS = 1'b0;
                ARID_S3[7:4] = 4'b0;
                ARID_S3[3:0] = ARID_M1;
                ARADDR_S3 = ARADDR_M1_reg2;
                ARLEN_S3 = ARLEN_M1;
                ARSIZE_S3 = ARSIZE_M1;
                ARBURST_S3 = ARBURST_M1;
                ARVALID_S3 = ARVALID_M1;
                
                ARREADY_M1 = ARREADY_S3;
                //
                ARREADY_M0 = 1'd0;
                RID_M0 = 4'd0;
                RDATA_M0 = 32'd0;
                RRESP_M0 = 2'd0;
                RLAST_M0 = 1'd0;
                RVALID_M0 = 1'd0;
                //
                RID_M1 = RID_S3[3:0];
                RDATA_M1 = RDATA_S3;
                RRESP_M1 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M1 = RLAST_S3;
                else
                RLAST_M1 = 1'b0;
                //end
                RVALID_M1 = RVALID_S3;

                RREADY_S3 = RREADY_M1;
                RREADY_S0 = 1'd0;
                RREADY_S1 = 1'd0;
				RREADY_S2 = 1'd0;
                RREADY_S4 = 1'd0;
                RREADY_S5 = 1'd0;
                //////
                ARID_S0 = 8'd0;
                ARADDR_S0 = 32'd0;
                ARLEN_S0 = 4'd0;
                ARSIZE_S0 = 3'd0;
                ARBURST_S0 = 2'd0;
                ARVALID_S0 = 1'd0;

                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;
				
				ARID_S2 = 8'd0;
                ARADDR_S2 = 32'd0;
                ARLEN_S2 = 4'd0;
                ARSIZE_S2 = 3'd0;
                ARBURST_S2 = 2'd0;
                ARVALID_S2 = 1'd0;

                ARID_S4 = 8'd0;
                ARADDR_S4 = 32'd0;
                ARLEN_S4 = 4'd0;
                ARSIZE_S4 = 3'd0;
                ARBURST_S4 = 2'd0;
                ARVALID_S4 = 1'd0;

                ARID_S5 = 8'd0;
                ARADDR_S5 = 32'd0;
                ARLEN_S5 = 4'd0;
                ARSIZE_S5 = 3'd0;
                ARBURST_S5 = 2'd0;
                ARVALID_S5 = 1'd0;
            end
            else if(ARADDR_M1_reg2[31:16]==16'h1001)begin//M1+S4
                WRONG_ADDRESS = 1'b0;
                ARID_S4[7:4] = 4'b0;
                ARID_S4[3:0] = ARID_M1;
                ARADDR_S4 = ARADDR_M1_reg2;
                ARLEN_S4 = ARLEN_M1;
                ARSIZE_S4 = ARSIZE_M1;
                ARBURST_S4 = ARBURST_M1;
                ARVALID_S4 = ARVALID_M1;
                
                ARREADY_M1 = ARREADY_S4;
                //
                ARREADY_M0 = 1'd0;
                RID_M0 = 4'd0;
                RDATA_M0 = 32'd0;
                RRESP_M0 = 2'd0;
                RLAST_M0 = 1'd0;
                RVALID_M0 = 1'd0;
                //
                RID_M1 = RID_S4[3:0];
                RDATA_M1 = RDATA_S4;
                RRESP_M1 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M1 = RLAST_S4;
                else
                RLAST_M1 = 1'b0;
                //end
                RVALID_M1 = RVALID_S4;

                RREADY_S4 = RREADY_M1;
                RREADY_S0 = 1'd0;
                RREADY_S1 = 1'd0;
				RREADY_S2 = 1'd0;
                RREADY_S3 = 1'd0;
                RREADY_S5 = 1'd0;
                //////
                ARID_S0 = 8'd0;
                ARADDR_S0 = 32'd0;
                ARLEN_S0 = 4'd0;
                ARSIZE_S0 = 3'd0;
                ARBURST_S0 = 2'd0;
                ARVALID_S0 = 1'd0;

                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;
				
				ARID_S2 = 8'd0;
                ARADDR_S2 = 32'd0;
                ARLEN_S2 = 4'd0;
                ARSIZE_S2 = 3'd0;
                ARBURST_S2 = 2'd0;
                ARVALID_S2 = 1'd0;

                ARID_S3 = 8'd0;
                ARADDR_S3 = 32'd0;
                ARLEN_S3 = 4'd0;
                ARSIZE_S3 = 3'd0;
                ARBURST_S3 = 2'd0;
                ARVALID_S3 = 1'd0;

                ARID_S5 = 8'd0;
                ARADDR_S5 = 32'd0;
                ARLEN_S5 = 4'd0;
                ARSIZE_S5 = 3'd0;
                ARBURST_S5 = 2'd0;
                ARVALID_S5 = 1'd0;
            end
            else if(ARADDR_M1_reg2[31:24]==8'h20)begin//M1+S5
                WRONG_ADDRESS = 1'b0;
                ARID_S5[7:4] = 4'b0;
                ARID_S5[3:0] = ARID_M1;
                ARADDR_S5 = ARADDR_M1_reg2;
                ARLEN_S5 = ARLEN_M1;
                ARSIZE_S5 = ARSIZE_M1;
                ARBURST_S5 = ARBURST_M1;
                ARVALID_S5 = ARVALID_M1;
                
                ARREADY_M1 = ARREADY_S5;
                //
                ARREADY_M0 = 1'd0;
                RID_M0 = 4'd0;
                RDATA_M0 = 32'd0;
                RRESP_M0 = 2'd0;
                RLAST_M0 = 1'd0;
                RVALID_M0 = 1'd0;
                //

                RID_M1 = RID_S5[3:0];
                RDATA_M1 = RDATA_S5;
                RRESP_M1 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M1 = RLAST_S5;
                else
                RLAST_M1 = 1'b0;
                //end
                RVALID_M1 = RVALID_S5;

                RREADY_S0 = 1'd0;
                RREADY_S1 = 1'd0;
                RREADY_S2 = 1'd0;
				RREADY_S3 = 1'd0;
                RREADY_S4 = 1'd0;
                RREADY_S5 = RREADY_M1;
                //////
                ARID_S0 = 8'd0;
                ARADDR_S0 = 32'd0;
                ARLEN_S0 = 4'd0;
                ARSIZE_S0 = 3'd0;
                ARBURST_S0 = 2'd0;
                ARVALID_S0 = 1'd0;

                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;

                ARID_S2 = 8'd0;
                ARADDR_S2 = 32'd0;
                ARLEN_S2 = 4'd0;
                ARSIZE_S2 = 3'd0;
                ARBURST_S2 = 2'd0;
                ARVALID_S2 = 1'd0;
				
				ARID_S3 = 8'd0;
                ARADDR_S3 = 32'd0;
                ARLEN_S3 = 4'd0;
                ARSIZE_S3 = 3'd0;
                ARBURST_S3 = 2'd0;
                ARVALID_S3 = 1'd0;

                ARID_S4 = 8'd0;
                ARADDR_S4 = 32'd0;
                ARLEN_S4 = 4'd0;
                ARSIZE_S4 = 3'd0;
                ARBURST_S4 = 2'd0;
                ARVALID_S4 = 1'd0;
            end
	    else begin
	WRONG_ADDRESS = 1'd0;
        ARREADY_M0 = 1'd0;
        ARREADY_M1 = 1'd0;

        ////
        RID_M0 = 4'd0;
        RDATA_M0 = 32'd0;
        RRESP_M0 = 2'd0;
        RLAST_M0 = 1'd0;
        RVALID_M0 = 1'd0;
        //
        RID_M1 = 4'd0;
        RDATA_M1 = 32'd0;
        RRESP_M1 = 2'd0;
        RLAST_M1 = 1'd0;
        RVALID_M1 = 1'd0;
        /////////////////////////
        RREADY_S0 = 1'd0;
        RREADY_S1 = 1'd0;
        RREADY_S2 = 1'd0;
		RREADY_S3 = 1'd0;
        RREADY_S4 = 1'd0;
        RREADY_S5 = 1'd0;
        /////////////////////////
        //////
        ARID_S0 = 8'd0;
        ARADDR_S0 = 32'd0;
        ARLEN_S0 = 4'd0;
        ARSIZE_S0 = 3'd0;
        ARBURST_S0 = 2'd0;
        ARVALID_S0 = 1'd0;

        ARID_S1 = 8'd0;
        ARADDR_S1 = 32'd0;
        ARLEN_S1 = 4'd0;
        ARSIZE_S1 = 3'd0;
        ARBURST_S1 = 2'd0;
        ARVALID_S1 = 1'd0;

        ARID_S2 = 8'd0;
        ARADDR_S2 = 32'd0;
        ARLEN_S2 = 4'd0;
        ARSIZE_S2 = 3'd0;
        ARBURST_S2 = 2'd0;
        ARVALID_S2 = 1'd0;
		
		ARID_S3 = 8'd0;
        ARADDR_S3 = 32'd0;
        ARLEN_S3 = 4'd0;
        ARSIZE_S3 = 3'd0;
        ARBURST_S3 = 2'd0;
        ARVALID_S3 = 1'd0;

        ARID_S4 = 8'd0;
        ARADDR_S4 = 32'd0;
        ARLEN_S4 = 4'd0;
        ARSIZE_S4 = 3'd0;
        ARBURST_S4 = 2'd0;
        ARVALID_S4 = 1'd0;

        ARID_S5 = 8'd0;
        ARADDR_S5 = 32'd0;
        ARLEN_S5 = 4'd0;
        ARSIZE_S5 = 3'd0;
        ARBURST_S5 = 2'd0;
        ARVALID_S5 = 1'd0;  
	    end
        end
        end
	
    endcase
end

endmodule
