`include "AXI_define.svh"

module WDT_Wrapper (
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

    output interrupt_t
);
    logic WDEN, WDLIVE, WTO;
    logic [31:0] WTOCNT;
    
    logic [31:0] address_write;

    logic WDEN_out,WDLIVE_out/*,WTO_out*/;
    logic [31:0] WTOCNT_out;
    //
    logic [31:0] WTOCNT_reg;
    logic [4:0] WTOCNT_counter;
    logic [2:0] WTOCNT_en_counter;
    logic WTOCNT_en, WTOCNT_en_reg;
    //
    logic WDEN_reg;
    logic [4:0] WDEN_counter;
    logic WDEN_en, WDEN_en_reg;
    //
    logic WDLIVE_reg;
    logic [4:0] WDLIVE_counter;
    logic WDLIVE_en, WDLIVE_en_reg;


    always@(posedge clock )begin
        if(reset)begin
            WTOCNT_counter<=5'b0;
            WTOCNT_reg<=32'b0;
            WTOCNT_en_reg<=1'b0;
        end
        else begin
            if(WTOCNT_en&&WTOCNT_counter==5'b0&&~WTOCNT_en_reg)begin
                WTOCNT_counter<=WTOCNT_counter+5'b1;
                WTOCNT_reg<=WDATA;
                WTOCNT_en_reg<=WTOCNT_en;
            end
            else begin
                if(WTOCNT_counter==5'b0) begin
                    WTOCNT_counter<=WTOCNT_counter;
                    WTOCNT_reg<=WTOCNT_reg;
                    WTOCNT_en_reg<=WTOCNT_en_reg;
                end
                else begin
                    WTOCNT_counter<=WTOCNT_counter+5'b1;
                    WTOCNT_reg<=WTOCNT_reg;
                    WTOCNT_en_reg<=WTOCNT_en_reg;
                end
            end
        end
    end
	
	always@(posedge clock )begin
        if(reset)begin
            WDEN_counter<=5'b0;
            WDEN_reg<=1'b0;
            WDEN_en_reg<=1'b0;
        end
        else begin
            if(WDEN_en)begin
                WDEN_counter<=WDEN_counter+5'b1;
                WDEN_reg<=WDATA[0];
                WDEN_en_reg<=WDEN_en;
            end
            else begin
                if(WDEN_counter==5'b0) begin
                    WDEN_counter<=WDEN_counter;
                    WDEN_reg<=WDEN_reg;
                    WDEN_en_reg<=WDEN_en_reg;
                end
                else begin
                    WDEN_counter<=WDEN_counter+5'b1;
                    WDEN_reg<=WDEN_reg;
                    WDEN_en_reg<=WDEN_en_reg;
                end
            end
        end
    end
	
	always@(posedge clock  )begin
        if(reset)begin
            WDLIVE_counter<=5'b0;
            WDLIVE_reg<=1'b0;
            WDLIVE_en_reg<=1'b0;
        end
        else begin
            if(WDLIVE_en)begin
                WDLIVE_counter<=WDLIVE_counter+5'b1;
                WDLIVE_reg<=WDATA[0];
                WDLIVE_en_reg<=WDLIVE_en;
            end
            else begin
                if(WDLIVE_counter==5'b0) begin
                    WDLIVE_counter<=WDLIVE_counter;
                    WDLIVE_reg<=WDLIVE_reg;
                    WDLIVE_en_reg<=WDLIVE_en_reg;
                end
                else begin
                    WDLIVE_counter<=WDLIVE_counter+5'b1;
                    WDLIVE_reg<=WDLIVE_reg;
                    WDLIVE_en_reg<=WDLIVE_en_reg;
                end
            end
        end
    end
    
    assign interrupt_t=WTO/*_out*/;

    // not useful
    always@(posedge clock )begin
        if(reset) begin
            WDEN<=1'b0;
            WDLIVE<=1'b0;
            WTOCNT<=32'b0;
        end
        else begin
            if(/*WDATA!=32'b0&&*/WVALID&&AWADDR==32'h10010100) begin 
                WDEN<=WDATA[0];//
                WDLIVE<=WDLIVE;
                WTOCNT<=WTOCNT;
            end
            else if(WDATA!=32'b0&&WVALID&&AWADDR==32'h10010200) begin 
                WDEN<=WDEN;
                WDLIVE<=WDATA[0];//
                WTOCNT<=WTOCNT;
            end
            else if(/*WDATA!=32'b0&&*/WVALID&&AWADDR==32'h10010300) begin 
                WDEN<=WDEN;
                WDLIVE<=WDLIVE;
                WTOCNT<=WDATA;//
            end
            else begin
                WDEN<=WDEN;
                WDLIVE<=WDLIVE;
                WTOCNT<=WTOCNT;
            end
        end
    end

 
    Slave_Read SR(.ACLK(clock), .ARESETn(reset),
            .ARID(ARID), .ARADDR(ARADDR), .ARLEN(ARLEN), .ARSIZE(ARSIZE), 
            .ARBURST(ARBURST), .ARVALID(ARVALID), .ARREADY(ARREADY),

            .RID(RID), .RDATA(RDATA), .RRESP(RRESP),
            .RLAST(RLAST), .RVALID(RVALID), .RREADY(RREADY),

            .address_out(), .data_in(32'b0), .select(2'b0)
            );

    Slave_Write SW(.ACLK(clock), .ARESETn(reset),
            .AWID(AWID), .AWADDR(AWADDR), .AWLEN(AWLEN), .AWSIZE(AWSIZE), 
            .AWBURST(AWBURST), .AWVALID(AWVALID), .AWREADY(AWREADY),

            .WDATA(WDATA), .WSTRB(WSTRB), .WLAST(WLAST), .WVALID(WVALID), .WREADY(WREADY),

            .BID(BID), .BRESP(BRESP), .BVALID(BVALID), .BREADY(BREADY),

            .data_out(), .address_out(), .w_en_out(), 
            .isnot_FREE(), .select(2'b0)
            );

    assign WTOCNT_en=(WVALID&&AWADDR==32'h10010300)?1'b1:1'b0;
    assign WDLIVE_en=(WDATA!=32'b0&&WVALID&&AWADDR==32'h10010200)?1'b1:1'b0;
	assign WDEN_en=(WVALID&&AWADDR==32'h10010100)?1'b1:1'b0;
    WDT wdt(
        .clk(clock),
        .rst(reset),
        .clk2(clock2),
        .rst2(reset2),
        .WDEN(WDEN_out),
        .WDLIVE(WDLIVE_out),
        .WTOCNT(WTOCNT_out),
        .WTO(WTO)
    );
////////////////////////////////////////////////////////
    synchronizer_1bit_logic sync_WDEN(
        .clk(clock),
        .rst(reset),
        .clk2(clock2),
        .rst2(reset2),
        .data_enable_A(WDEN_en_reg),
        .in(WDEN_reg),
        .out(WDEN_out)
    );
    synchronizer_1bit_logic sync_WDLIVE(
        .clk(clock),
        .rst(reset),
        .clk2(clock2),
        .rst2(reset2),
        .data_enable_A(WDLIVE_en_reg),
        .in(WDLIVE_reg),
        .out(WDLIVE_out)
    );
    synchronizer_32bit_logic sync_WTOCNT(
        .clk(clock),
        .rst(reset),
        .clk2(clock2),
        .rst2(reset2),
        .data_enable_A(WTOCNT_en_reg),
        .in(WTOCNT_reg),
        .out(WTOCNT_out)
    );
    //because we connect wto to csr directly
    // synchronizer_1bit sync_WTO(
    //     .clk(clock2),
    //     .rst(reset2),
    //     .clk2(clock),
    //     .rst2(reset),
    //     .in(WTO),
    //     .out(WTO_out)
    // );

endmodule
