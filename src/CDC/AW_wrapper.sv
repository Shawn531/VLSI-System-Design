`include "AXI_define.svh"
module AW_wrapper(
    //clk rst
    input clock,
    input clock2,
    input reset,
    input reset2,
    //
    input [`AXI_IDS_BITS-1:0] AWID,//8
	input [`AXI_ADDR_BITS-1:0] AWADDR,//32
	input [`AXI_LEN_BITS-1:0] AWLEN,//4
	input [`AXI_SIZE_BITS-1:0] AWSIZE,//3
	input [1:0] AWBURST,//2
	input AWVALID,//1
	output logic AWREADY_out,//1

    output [`AXI_IDS_BITS-1:0] AWID_out,//8
	output [`AXI_ADDR_BITS-1:0] AWADDR_out,//32
	output [`AXI_LEN_BITS-1:0] AWLEN_out,//4
	output [`AXI_SIZE_BITS-1:0] AWSIZE_out,//3
	output [1:0] AWBURST_out,//2
	output AWVALID_out,//1
	input AWREADY//1
);
localparam  wait_empty = 2'b00,
            pop = 2'b01;
logic AWVALID_delay;
logic OUTOFAXI_AFIFO_empty;
logic OUTOFAXI_AFIFO_rpop;
logic [46:0] OUTOFAXI_AFIFO_wdata;
logic [46:0] OUTOFAXI_AFIFO_rdata;
logic  [4:0] trash;

assign AWID_out=8'b0;

//WCLK
always@(posedge clock )begin
        if(reset) AWVALID_delay<=1'b0;
        else AWVALID_delay<=AWVALID;
end
// ======= OUTOFAXI =======
    logic [1:0] outofaxi_state;
    logic [1:0] outofaxi_nstate;
    logic [46:0] OUTOFAXI_AFIFO_rdata_reg;
    assign OUTOFAXI_AFIFO_wdata = {5'b0/*,AWID*/,AWADDR,AWLEN,AWSIZE,AWBURST,AWVALID};
    assign {trash/*,AWID_out*/,AWADDR_out,AWLEN_out,AWSIZE_out,AWBURST_out,AWVALID_out} = OUTOFAXI_AFIFO_rdata_reg;
    always_ff @(posedge clock2 )
    begin
        if (reset2)
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
            // outofaxi_nstate = wait_empty;
            if(~OUTOFAXI_AFIFO_empty) outofaxi_nstate = pop;
            else outofaxi_nstate = wait_empty;
            OUTOFAXI_AFIFO_rpop=1'b1;
        end
        default: begin
		outofaxi_nstate=wait_empty;
		OUTOFAXI_AFIFO_rpop=1'b0;
	  end
        endcase
    end
    //
    always_ff@(posedge clock2  )begin
        if (reset2)begin
            OUTOFAXI_AFIFO_rdata_reg<=47'b0;
        end
        else begin
            if(outofaxi_state==pop) begin
                if(~OUTOFAXI_AFIFO_empty) OUTOFAXI_AFIFO_rdata_reg<=OUTOFAXI_AFIFO_rdata;
                else OUTOFAXI_AFIFO_rdata_reg<=OUTOFAXI_AFIFO_rdata_reg;
                // OUTOFAXI_AFIFO_rdata_reg<=OUTOFAXI_AFIFO_rdata;
            end
            else begin
                OUTOFAXI_AFIFO_rdata_reg<=OUTOFAXI_AFIFO_rdata_reg;
            end
        end
    end
logic OUTOFAXI_AFIFO_wfull;
AFIFO_CDC_47bit outofaxi(
    .wclk(clock),
    .wrst(reset),
    .wpush(AWVALID^AWVALID_delay),
    .wdata(OUTOFAXI_AFIFO_wdata),
    .wfull(OUTOFAXI_AFIFO_wfull),
    .rclk(clock2),
    .rrst(reset2),
    .rpop(OUTOFAXI_AFIFO_rpop),
    .rempty(OUTOFAXI_AFIFO_empty),
    .rdata(OUTOFAXI_AFIFO_rdata)
);
///////////////////////////////////////////////////////////////
logic AWREADY_delay;
logic INTOAXI_AFIFO_empty;
logic INTOAXI_AFIFO_rpop;
//WCLK
always@(posedge clock2  )begin
        if(reset2) AWREADY_delay<=1'b0;
        else AWREADY_delay<=AWREADY;
end

// ======= INTOAXI =======
    logic [1:0] intoaxi_state;
    logic [1:0] intoaxi_nstate;
    logic INTOAXI_AFIFO_rdata;
    logic AWREADY_out_reg;
    assign AWREADY_out = AWREADY_out_reg;
    always_ff @(posedge clock  )
    begin
        if (reset)
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
            INTOAXI_AFIFO_rpop=1'b1;
        end
        default: begin
		intoaxi_nstate=wait_empty;	
		INTOAXI_AFIFO_rpop=1'b0;
	  end
        endcase
    end
    //
    always_ff@(posedge clock  )begin
        if (reset)begin
            AWREADY_out_reg<=1'b0;
        end
        else begin
            if(intoaxi_state==pop) begin
                if(~INTOAXI_AFIFO_empty) AWREADY_out_reg<=INTOAXI_AFIFO_rdata;
                else AWREADY_out_reg<=AWREADY_out_reg;
                // AWREADY_out_reg<=INTOAXI_AFIFO_rdata;
            end
            else begin
                AWREADY_out_reg<=AWREADY_out_reg;
            end
        end
    end
//#########INTOAXI##################################################
logic INTOAXI_AFIFO_wfull;
AFIFO_CDC_1bit intoaxi(
    .wclk(clock2),
    .wrst(reset2),
    .wpush(AWREADY^AWREADY_delay),
    .wdata(AWREADY),
    .wfull(INTOAXI_AFIFO_wfull),
    .rclk(clock),
    .rrst(reset),
    .rpop(INTOAXI_AFIFO_rpop),
    .rempty(INTOAXI_AFIFO_empty),
    .rdata(INTOAXI_AFIFO_rdata)
);

endmodule
