 `include "AXI_define.svh"

module Sensor_wrapper (
    input clock,
	input reset,
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

    // Sensor
    // Sensor inputs
    input sensor_ready,
    input [31:0] sensor_out,
    // Sensor outputs
    output sensor_en,
    // Core outputs
    output sctrl_interrupt
);

////////////////////////////////////////////////////////////////
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
//////////////////////////////////////////////////////////
    // Register
    logic [9:0] AddressReg;
    logic       EnableReg;
    // Wire
    // AXI Slave
    logic [13:0] Address;
    logic ReadEnable;
    logic [`AXI_DATA_BITS-1:0] DataRead;
    logic [3:0] WriteEnable;
    logic [`AXI_DATA_BITS-1:0] DataWrite;
    // Sensor
    logic sctrl_en;
    logic sctrl_clear;
    logic [5:0] sctrl_addr;
    logic [31:0] sctrl_out;
    logic [31:0] sctrl_out_reg;
    logic [31:0] address_read,address_write;

    // logic state, nstate;
    // localparam IDLE=1'd0, BUSY=1'd1;
    // localparam READ=2'd1, WRITE=2'd2, FREE=2'd0, WRONG=2'd3;

    // logic[1:0] select, select_reg;
    // logic [31:0] data_out_W;
    logic [3:0] w_en_out_M;
    // logic isnot_FREE;

    localparam SENSOR=2'b0,
                WAIT_COPY=2'b1,
                CLEAR=2'b11;

    logic [1:0] state, nstate;

    always@(posedge clock2 )begin
        if(reset2) state<=SENSOR;
        else state<=nstate;
    end
    
    always@(*)begin
        case(state)
        SENSOR:begin
            if(sctrl_interrupt) nstate=WAIT_COPY;
            else nstate=SENSOR;
        end
        WAIT_COPY:begin
            if(AWVALID_out /*&& AWADDR == 32'h10002000 && WDATA!=32'b0*/ ) nstate=CLEAR;
            else nstate=WAIT_COPY;
        end
        CLEAR:begin
            if(~sctrl_interrupt) nstate=SENSOR;//something wierd
            else nstate=CLEAR;
        end
	default: nstate=SENSOR;
        endcase
    end

    always@(*)begin
        case(state)
        SENSOR:begin
            sctrl_en=1'b1;
            sctrl_clear=1'b0;
        end
        WAIT_COPY:begin
            sctrl_en=1'b1;
            sctrl_clear=1'b0;

        end
        CLEAR:begin
            sctrl_en=1'b0;
            sctrl_clear=1'b1;
        end
	default: begin
	    sctrl_en=1'b0;
	    sctrl_clear=1'b0;
	end
        endcase
    end

    always@(posedge clock2 )begin
        if(reset2) begin
            sctrl_out_reg <= 32'b0;
        end
        else begin
            if(RREADY_out&&~RLAST_out)   sctrl_out_reg <= sctrl_out;
            else    sctrl_out_reg <= sctrl_out_reg;
        end
    end

 
    Slave_Read SR(.ACLK(clock2), .ARESETn(reset2),
            .ARID(ARID_out), .ARADDR(ARADDR_out), .ARLEN(ARLEN_out), .ARSIZE(ARSIZE_out), 
            .ARBURST(ARBURST_out), .ARVALID(ARVALID_out), .ARREADY(ARREADY_out),

            .RID(RID_out), .RDATA(RDATA_out), .RRESP(RRESP_out),
            .RLAST(RLAST_out), .RVALID(RVALID_out), .RREADY(RREADY_out),

            .address_out(address_read), .data_in(sctrl_out/*_reg*/), .select(2'b0)
            );

    Slave_Write SW(.ACLK(clock2), .ARESETn(reset2),
            .AWID(AWID_out), .AWADDR(AWADDR_out), .AWLEN(AWLEN_out), .AWSIZE(AWSIZE_out), 
            .AWBURST(AWBURST_out), .AWVALID(AWVALID_out), .AWREADY(AWREADY_out),

            .WDATA(WDATA_out), .WSTRB(WSTRB_out), .WLAST(WLAST_out), .WVALID(WVALID_out), .WREADY(WREADY_out),

            .BID(BID_out), .BRESP(BRESP_out), .BVALID(BVALID_out), .BREADY(BREADY_out),

            .data_out(), .address_out(address_write), .w_en_out(w_en_out_M), 
            .isnot_FREE(), .select(2'b0)
            );
    assign sctrl_addr = address_read[7:2];
    sensor_ctrl controller
    (
        .clk(clock2),
        .rst(reset2),
        // Core inputs
        .sctrl_en(sctrl_en),
        .sctrl_clear(sctrl_clear),
        .sctrl_addr(sctrl_addr),
        // Sensor inputs
        .sensor_ready(sensor_ready),
        .sensor_out(sensor_out),
        // Core outputs
        .sctrl_interrupt(sctrl_interrupt),
        .sctrl_out(sctrl_out),
        // Sensor outputs
        .sensor_en(sensor_en)
    );

///////////////////////afifo////////////////////////////////////////
/////AR channel
AR_wrapper AR(
        .clock(clock),
        .clock2(clock2),//
        .reset(reset),
        .reset2(reset2),//
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
/////R channel
R_wrapper R(
        .clock(clock),
        .clock2(clock2),//
        .reset(reset),
        .reset2(reset2),//
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

/////AW channel
AW_wrapper AW(
        .clock(clock),
        .clock2(clock2),//
        .reset(reset),
        .reset2(reset2),//
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
/////W channel
W_wrapper W(
        .clock(clock),
        .clock2(clock2),//
        .reset(reset),
        .reset2(reset2),//
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
/////B channel
B_wrapper B(
        .clock(clock),
        .clock2(clock2),//
        .reset(reset),
        .reset2(reset2),//
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

////////////////////////////////////////////////////////////////////    

endmodule
