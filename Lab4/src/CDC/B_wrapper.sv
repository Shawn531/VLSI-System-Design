`include "AXI_define.svh"
module B_wrapper(
	//clk rst
    input clock,
    input clock2,
    input reset,
    input reset2,
	//
    output [`AXI_IDS_BITS-1:0] BID_out,//8
	output [1:0] BRESP_out,//2
	output BVALID_out,//1
	input BREADY,
    //
    input [`AXI_IDS_BITS-1:0] BID,//8
	input [1:0] BRESP,//2
	input BVALID,//1
	output BREADY_out
);
localparam  wait_empty = 2'b00,
            pop = 2'b01;
logic BVALID_delay;
logic OUTOFAXI_AFIFO_empty;
logic OUTOFAXI_AFIFO_rpop;
logic [46:0] OUTOFAXI_AFIFO_wdata;
logic [46:0] OUTOFAXI_AFIFO_rdata;
//47-11=36
logic [43:0] trash;

assign BID_out=8'b0;

//WCLK
always@(posedge clock2  )begin
        if(reset2) BVALID_delay<=1'b0;
        else BVALID_delay<=BVALID;
end
// ======= OUTOFAXI =======
    logic [1:0] outofaxi_state;
    logic [1:0] outofaxi_nstate;
    logic [46:0] OUTOFAXI_AFIFO_rdata_reg;
    logic BVALID_temp;
    logic BVALID_temp_reg;
    assign BVALID_out = (BVALID_temp_reg^BVALID_temp)&&BVALID_temp;///////////////////////////////
    always_ff @(posedge clock  )
    begin
        if (reset)
        begin
            BVALID_temp_reg <= 1'b0;
        end
        else 
        begin
            if(~OUTOFAXI_AFIFO_rpop)    BVALID_temp_reg <= BVALID_temp;
            else    BVALID_temp_reg <= BVALID_temp_reg;
        end
    end
	// 47 - 11 = 36
    assign OUTOFAXI_AFIFO_wdata = {36'b0,8'b0,BRESP,BVALID};
    assign {trash,BRESP_out,BVALID_temp} = OUTOFAXI_AFIFO_rdata_reg;
    always_ff @(posedge clock  )
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
    always_ff@(posedge clock  )begin
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
    .wpush(BVALID^BVALID_delay),
    .wdata(OUTOFAXI_AFIFO_wdata),
    .wfull(/**/),
    .rclk(clock),
    .rrst(reset),
    .rpop(OUTOFAXI_AFIFO_rpop),
    .rempty(OUTOFAXI_AFIFO_empty),
    .rdata(OUTOFAXI_AFIFO_rdata)
);
///////////////////////////////////////////////////////////////
logic BREADY_delay;
logic INTOAXI_AFIFO_empty;
logic INTOAXI_AFIFO_rpop;
//WCLK
always@(posedge clock  )begin
        if(reset) BREADY_delay<=1'b0;
        else BREADY_delay<=BREADY;
end
// ======= INTOAXI =======
    logic [1:0] intoaxi_state;
    logic [1:0] intoaxi_nstate;
    logic INTOAXI_AFIFO_rdata;
    logic BREADY_out_reg;
    assign BREADY_out = BREADY_out_reg;
    always_ff @(posedge clock2  )
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
            BREADY_out_reg<=1'b0;
        end
        else begin
            if(intoaxi_state==pop) begin
				if(~INTOAXI_AFIFO_empty) BREADY_out_reg<=INTOAXI_AFIFO_rdata;
            	else BREADY_out_reg<=BREADY_out_reg;
                // BREADY_out_reg<=INTOAXI_AFIFO_rdata;
            end
            else begin
                BREADY_out_reg<=BREADY_out_reg;
            end
        end
    end
//#########INTOAXI##################################################
AFIFO_CDC_1bit intoaxi(
    .wclk(clock),
    .wrst(reset),
    .wpush(BREADY^BREADY_delay),
    .wdata(BREADY),
    .wfull(/**/),
    .rclk(clock2),
    .rrst(reset2),
    .rpop(INTOAXI_AFIFO_rpop),
    .rempty(INTOAXI_AFIFO_empty),
    .rdata(INTOAXI_AFIFO_rdata)
);

endmodule
