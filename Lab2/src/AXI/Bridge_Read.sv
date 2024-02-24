`include "AXI_define.svh"

module Bridge_Read(

    input ACLK,
	input ARESETn,

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
	output logic RREADY_S1
);

localparam  FREE = 1'b0,
            DATA = 1'b1;

logic state, nstate;
logic PREVIOUS_TAKEOVER_MASTER;// 1'b0 -> M0 , 1'b1 -> M1
logic TAKEOVER_MASTER;
logic WRONG_ADDRESS;
logic [`AXI_LEN_BITS-1:0] ARLEN_Reg;
always_ff@(posedge ACLK or negedge ARESETn)begin
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

always_ff@(posedge ACLK or negedge ARESETn)begin
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
        else if(ARVALID_M1 && ARREADY_S0 || ARVALID_M1 && ARREADY_S1) 
        begin
            TAKEOVER_MASTER<=1'b1;
            ARLEN_Reg <= ARLEN_M1;
        end
        else if(ARVALID_M0 && ARREADY_S0 || ARVALID_M0 && ARREADY_S1) 
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
//next state logic(comb)
always@(*)begin
    case(state)
    FREE:begin

        if(ARVALID_M0 && ARVALID_M1) 
        begin
            if(ARREADY_S0) 
            begin
                nstate=DATA;
                slave_select = 1'b0;
            end
            else if(ARREADY_S1) 
            begin
                nstate=DATA;//
                slave_select = 1'b1;
            end
			else
			begin
                nstate=FREE;//
                slave_select = 1'b0;
            end
        end
        else if(ARVALID_M0 && ARREADY_S0) 
        begin
            nstate=DATA;
            slave_select = 1'b0;
        end
        else if(ARVALID_M0 && ARREADY_S1) 
        begin
            nstate=DATA;//
            slave_select = 1'b1;
        end//////////////////////////////
        else if(ARVALID_M1 && ARREADY_S0) 
        begin
            nstate=DATA;//
            slave_select = 1'b0;
        end
        else if(ARVALID_M1 && ARREADY_S1) 
        begin
            nstate=DATA;
            slave_select = 1'b1;
        end
        else 
        begin
            nstate=FREE;
            slave_select = 1'b0;
        end
    end
    DATA:begin
		slave_select = slave_select_reg;
        //判斷 TAKEOVER_MASTER ， 再判斷 RLAST ...
        if (TAKEOVER_MASTER == 1'b0)
        begin
            if (RREADY_S0&&RVALID_S0&&RLAST_M0||RREADY_S1&&RVALID_S1&&RLAST_M0)//RLAST_S0
                nstate=FREE;
            else
                nstate=DATA;
        end
        else
        begin
            if (RREADY_S1&&RVALID_S1&&RLAST_M1||RREADY_S0&&RVALID_S0&&RLAST_M1)
                nstate=FREE;
            else
                nstate=DATA;
        end
    end
    endcase
end
logic rid_counter;
always_ff@(posedge ACLK or negedge ARESETn)
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
logic [31:0] ARADDR_M1_reg;
logic RVALID_M1_reg;
always_ff@(posedge ACLK or negedge ARESETn)begin
    if(!ARESETn)
    begin
        RVALID_M1_reg <= 1'b0;
    end
	else begin
        RVALID_M1_reg <= RVALID_M1;
      end
end 
always_ff@(posedge ACLK or negedge ARESETn)begin
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
logic [3:0] RID1_reg;
logic [3:0] RID2_reg;

always@(*)begin
    case(state)
    FREE:begin
        WRONG_ADDRESS = 1'd0;
        ARREADY_M0 = 1'd0;
        ARREADY_M1 = 1'd0;

        RREADY_S0 = 1'd0;
        RREADY_S1 = 1'd0;
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
        // end
        
    end
    DATA:begin
        if (TAKEOVER_MASTER == 1'b0)
        begin
            if(~slave_select)
            begin
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
                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;
                //end
                
            end
            else //if((~|(ARADDR_M0[31:15])) & ARADDR_M0[14])//M0 + S1
            begin
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
                ARID_S0 = 8'd0;
                ARADDR_S0 = 32'd0;
                ARLEN_S0 = 4'd0;
                ARSIZE_S0 = 3'd0;
                ARBURST_S0 = 2'd0;
                ARVALID_S0 = 1'd0;
                //end
                
            end
        end
        else//M1 take over
        begin
            //
            if(~|(ARADDR_M1_reg2[31:14])) // M1 + S0
            //if(~slave_select)                              // VIP 會換地址，
            begin
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
                ARID_S1 = 8'd0;
                ARADDR_S1 = 32'd0;
                ARLEN_S1 = 4'd0;
                ARSIZE_S1 = 3'd0;
                ARBURST_S1 = 2'd0;
                ARVALID_S1 = 1'd0;
            end
            else 
            begin
                WRONG_ADDRESS = 1'b0;
					ARID_S1[7:4] = 4'b0;
                    ARID_S1[3:0] = ARID_M1;
                    ARADDR_S1 = ARADDR_M1_reg2;
                    ARLEN_S1 = ARLEN_M1;
                    ARSIZE_S1 = ARSIZE_M1;
                    ARBURST_S1 = ARBURST_M1;
                    ARVALID_S1 = ARVALID_M1;
                
                ARREADY_M1 = ARREADY_S1;
                    ARID_S0 = 8'd0;
                    ARADDR_S0 = 32'd0;
                    ARLEN_S0 = 4'd0;
                    ARSIZE_S0 = 3'd0;
                    ARBURST_S0 = 2'd0;
                    ARVALID_S0 = 1'd0;
                ARREADY_M0 = 1'd0;
                RID_M0 = 4'd0;
                RDATA_M0 = 32'd0;
                RRESP_M0 = 2'd0;
                RLAST_M0 = 1'd0;
                RVALID_M0 = 1'd0;

                RREADY_S0 = 1'd0;
                
                RID_M1 = RID_S1[3:0];
                RDATA_M1 = RDATA_S1;
                RRESP_M1 = 2'b00;
                if (ARLEN_Reg == 4'd0) 
                RLAST_M1 = RLAST_S1;
                else
                RLAST_M1 = 1'b0;
                //end
                RVALID_M1 = RVALID_S1;

                RREADY_S1 = RREADY_M1;
                
            end
        end
    end
    endcase
end

endmodule