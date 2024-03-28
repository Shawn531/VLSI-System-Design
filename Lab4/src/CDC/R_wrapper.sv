`include "AXI_define.svh"
module R_wrapper(
	//clk rst
    input clock,
    input clock2,
    input reset,
    input reset2,
	//
    output [`AXI_ID_BITS-1:0] RID_out,//4
	output [`AXI_DATA_BITS-1:0] RDATA_out,//32
	output [1:0] RRESP_out,//2
	output RLAST_out,//1
	output RVALID_out,//1
	input RREADY,

	input [`AXI_ID_BITS-1:0] RID,
	input [`AXI_DATA_BITS-1:0] RDATA,
	input [1:0] RRESP,
	input RLAST,
	input RVALID,
	output RREADY_out
);
localparam  wait_empty = 2'b00,
            pop = 2'b01;
logic RVALID_delay;
logic OUTOFAXI_AFIFO_empty;
logic OUTOFAXI_AFIFO_rpop;
logic [46:0] OUTOFAXI_AFIFO_wdata;
logic [46:0] OUTOFAXI_AFIFO_rdata;
logic [6:0] trash;

// assign RID_out=4'b0;

//WCLK
always@(posedge clock2 )begin
        if(reset2) RVALID_delay<=1'b0;
        else RVALID_delay<=RVALID;
end
// ======= OUTOFAXI =======
    logic [1:0] outofaxi_state;
    logic [1:0] outofaxi_nstate;
    logic [46:0] OUTOFAXI_AFIFO_rdata_reg;
    logic RVALID_temp;
    logic RVALID_temp_reg;
    assign RVALID_out = (RVALID_temp_reg^RVALID_temp)&&RVALID_temp;///////////////////////////////
    always_ff @(posedge clock )
    begin
        if (reset)
        begin
            RVALID_temp_reg <= 1'b0;
        end
        else 
        begin
            if(~OUTOFAXI_AFIFO_rpop)    RVALID_temp_reg <= RVALID_temp;
            else    RVALID_temp_reg <= RVALID_temp; //RVALID_temp_reg <= RVALID_temp_reg;
        end
    end
	// 47 - 44 = 3
    assign OUTOFAXI_AFIFO_wdata = {7'b0,4'b0,RDATA,RRESP,RLAST,RVALID};
    assign {trash,RID_out,RDATA_out,RRESP_out,RLAST_out,RVALID_temp/*RVALID_out*/} = OUTOFAXI_AFIFO_rdata_reg;
    always_ff @(posedge clock )
    begin
        if (reset)
        begin
            outofaxi_state <= wait_empty;
        end
        else 
        begin
            outofaxi_state <= outofaxi_nstate;
        end
    end
    // Next State Logic & Combination Output Logic
    always_comb 
    begin
        case(outofaxi_state)
        wait_empty:begin//
            if(~OUTOFAXI_AFIFO_empty) outofaxi_nstate = pop;
            else outofaxi_nstate = wait_empty;
            OUTOFAXI_AFIFO_rpop=1'b0;
        end
        pop:begin
            if(~OUTOFAXI_AFIFO_empty) outofaxi_nstate = pop;
            else outofaxi_nstate = wait_empty;
			// outofaxi_nstate = wait_empty;
            if(~OUTOFAXI_AFIFO_empty) OUTOFAXI_AFIFO_rpop=1'b1;
			else OUTOFAXI_AFIFO_rpop=1'b0;
        end
        default: begin
		outofaxi_nstate=wait_empty;
		OUTOFAXI_AFIFO_rpop=1'b0;
	  end
        endcase
    end
    //
    always_ff@(posedge clock )begin
        if (reset)begin
            OUTOFAXI_AFIFO_rdata_reg<=47'b0;
        end
        else begin
            if(outofaxi_state==pop) begin
				if(~OUTOFAXI_AFIFO_empty) OUTOFAXI_AFIFO_rdata_reg<=OUTOFAXI_AFIFO_rdata;
                else OUTOFAXI_AFIFO_rdata_reg<=OUTOFAXI_AFIFO_rdata_reg;
            end
            else begin
                OUTOFAXI_AFIFO_rdata_reg<=OUTOFAXI_AFIFO_rdata_reg;
            end
        end
    end
//#########OUTOFAXI##################################################
AFIFO_CDC_47bit outofaxi(
	.wclk(clock2),
    .wrst(reset2),
    .wpush(RVALID^RVALID_delay),
    .wdata(OUTOFAXI_AFIFO_wdata),
    .wfull(/**/),
    .rclk(clock),
    .rrst(reset),
    .rpop(OUTOFAXI_AFIFO_rpop),
    .rempty(OUTOFAXI_AFIFO_empty),
    .rdata(OUTOFAXI_AFIFO_rdata)
);
///////////////////////////////////////////////////////////////
logic RREADY_delay;
logic INTOAXI_AFIFO_empty;
logic INTOAXI_AFIFO_rpop;
//WCLK
always@(posedge clock )begin
        if(reset) RREADY_delay<=1'b0;
        else RREADY_delay<=RREADY;
end
// ======= INTOAXI =======
    logic [1:0] intoaxi_state;
    logic [1:0] intoaxi_nstate;
    logic INTOAXI_AFIFO_rdata;
    logic RREADY_out_reg;
    assign RREADY_out = RREADY_out_reg;
    always_ff @(posedge clock2 )
    begin
        if (reset2)
        begin
            intoaxi_state <= wait_empty;
        end
        else 
        begin
            intoaxi_state <= intoaxi_nstate;
        end
    end
    // Next State Logic & Combination Output Logic
    always_comb 
    begin
        case(intoaxi_state)
        wait_empty:begin//
            if(~INTOAXI_AFIFO_empty) intoaxi_nstate = pop;
            else intoaxi_nstate = wait_empty;
            INTOAXI_AFIFO_rpop=1'b0;
        end
        pop:begin
            // intoaxi_nstate = wait_empty;
			if(~INTOAXI_AFIFO_empty) intoaxi_nstate = pop;
            else intoaxi_nstate = wait_empty;
			if(~INTOAXI_AFIFO_empty) INTOAXI_AFIFO_rpop=1'b1;
            else INTOAXI_AFIFO_rpop=1'b0;
        end
        default: begin
		intoaxi_nstate=wait_empty;
		INTOAXI_AFIFO_rpop=1'b0;
	  end
        endcase
    end
    //
    always_ff@(posedge clock2  )begin
        if (reset2)begin
            RREADY_out_reg<=1'b0;
        end
        else begin
            if(intoaxi_state==pop) begin
				if(~INTOAXI_AFIFO_empty) RREADY_out_reg<=INTOAXI_AFIFO_rdata;
            	else RREADY_out_reg<=RREADY_out_reg;
                // RREADY_out_reg<=INTOAXI_AFIFO_rdata;
            end
            else begin
                RREADY_out_reg<=RREADY_out_reg;
            end
        end
    end
//#########INTOAXI##################################################
AFIFO_CDC_1bit intoaxi(
    .wclk(clock),
    .wrst(reset),
    .wpush(RREADY^RREADY_delay),
    .wdata(RREADY),
    .wfull(/**/),
    .rclk(clock2),
    .rrst(reset2),
    .rpop(INTOAXI_AFIFO_rpop),
    .rempty(INTOAXI_AFIFO_empty),
    .rdata(INTOAXI_AFIFO_rdata)
);

endmodule
