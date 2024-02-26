// `include "AXI_define.svh"

module Sensor_wrapper (
    input clock,
	input reset,
    // READ ADDRESS
	input [`AXI_IDS_BITS-1:0] ARID,
	input [`AXI_ADDR_BITS-1:0] ARADDR,
	input [`AXI_LEN_BITS-1:0] ARLEN,
	input [`AXI_SIZE_BITS-1:0] ARSIZE,
	input [1:0] ARBURST,
	input ARVALID,
	output ARREADY,
	// READ DATA
	output [`AXI_IDS_BITS-1:0] RID,
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

    always@(posedge clock)begin
        if(reset) state<=SENSOR;
        else state<=nstate;
    end
    
    always@(*)begin
        case(state)
        SENSOR:begin
            if(sctrl_interrupt) nstate=WAIT_COPY;
            else nstate=SENSOR;
        end
        WAIT_COPY:begin
            if(AWVALID /*&& AWADDR == 32'h10002000 && WDATA!=32'b0*/ ) nstate=CLEAR;
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

    always@(posedge clock)begin
        if(reset) begin
            sctrl_out_reg <= 32'b0;
        end
        else begin
            if(RREADY&&~RLAST)   sctrl_out_reg <= sctrl_out;
            else    sctrl_out_reg <= sctrl_out_reg;
        end
    end

 
    Slave_Read SR(.ACLK(clock), .ARESETn(reset),
            .ARID(ARID), .ARADDR(ARADDR), .ARLEN(ARLEN), .ARSIZE(ARSIZE), 
            .ARBURST(ARBURST), .ARVALID(ARVALID), .ARREADY(ARREADY),

            .RID(RID), .RDATA(RDATA), .RRESP(RRESP),
            .RLAST(RLAST), .RVALID(RVALID), .RREADY(RREADY),

            .address_out(address_read), .data_in(sctrl_out_reg), .select(2'b0)
            );

    Slave_Write SW(.ACLK(clock), .ARESETn(reset),
            .AWID(AWID), .AWADDR(AWADDR), .AWLEN(AWLEN), .AWSIZE(AWSIZE), 
            .AWBURST(AWBURST), .AWVALID(AWVALID), .AWREADY(AWREADY),

            .WDATA(WDATA), .WSTRB(WSTRB), .WLAST(WLAST), .WVALID(WVALID), .WREADY(WREADY),

            .BID(BID), .BRESP(BRESP), .BVALID(BVALID), .BREADY(BREADY),

            .data_out(), .address_out(address_write), .w_en_out(w_en_out_M), 
            .isnot_FREE(), .select(2'b0)
            );
    assign sctrl_addr = address_read[7:2];
    sensor_ctrl controller
    (
        .clk(clock),
        .rst(reset),
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

endmodule
