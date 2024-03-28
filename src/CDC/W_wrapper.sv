`include "AXI_define.svh"
module W_wrapper(
    //clk rst
    input clock,
    input clock2,
    input reset,
    input reset2,
    //
    // WRITE DATA 36 + 2 = 38 , 47-38 = 9
	output [`AXI_DATA_BITS-1:0] WDATA_out,//32
	output [`AXI_STRB_BITS-1:0] WSTRB_out,//4
	output WLAST_out,//1
	output WVALID_out,//1
	input WREADY,//1
    //
    input [`AXI_DATA_BITS-1:0] WDATA,
	input [`AXI_STRB_BITS-1:0] WSTRB,
	input WLAST,
	input WVALID,
	output WREADY_out
);
localparam  wait_empty = 2'b00,
            pop = 2'b01;
logic WVALID_delay;
logic OUTOFAXI_AFIFO_empty;
logic OUTOFAXI_AFIFO_rpop;
logic [46:0] OUTOFAXI_AFIFO_wdata;
logic [46:0] OUTOFAXI_AFIFO_rdata;
logic [8:0] trash;

//WCLK
always@(posedge clock )begin
        if(reset) WVALID_delay<=1'b0;
        else WVALID_delay<=WVALID;
end
// ======= OUTOFAXI =======
    logic [1:0] outofaxi_state;
    logic [1:0] outofaxi_nstate;
    logic [46:0] OUTOFAXI_AFIFO_rdata_reg;
    logic [46:0] OUTOFAXI_AFIFO_rdata_reg_delay;
    assign OUTOFAXI_AFIFO_wdata = {9'b0,WDATA,WSTRB,WLAST,WVALID};//47-38 = 9
    //
    logic WVALID_temp;
    logic WVALID_temp_reg;
    assign WVALID_out = (WVALID_temp_reg^WVALID_temp)&&WVALID_temp;///////////////////////////////
    always_ff @(posedge clock2 )
    begin
        if (reset2)
        begin
            WVALID_temp_reg <= 1'b0;
        end
        else 
        begin
            if(~OUTOFAXI_AFIFO_rpop)    WVALID_temp_reg <= WVALID_temp;
            else    WVALID_temp_reg <= WVALID_temp_reg;
        end
    end
    //
    assign {trash,WDATA_out,WSTRB_out,WLAST_out,WVALID_temp} = OUTOFAXI_AFIFO_rdata_reg_delay;//
    always_ff @(posedge clock2  )
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
    always_ff@(posedge clock2  )begin
        if (reset2)begin
            OUTOFAXI_AFIFO_rdata_reg_delay<=47'b0;
        end
        else begin
            OUTOFAXI_AFIFO_rdata_reg_delay<=OUTOFAXI_AFIFO_rdata_reg;
        end
    end
logic OUTOFAXI_AFIFO_wfull;
AFIFO_CDC_47bit outofaxi(
    .wclk(clock),
    .wrst(reset),
    .wpush(WVALID^WVALID_delay),
    .wdata(OUTOFAXI_AFIFO_wdata),
    .wfull(OUTOFAXI_AFIFO_wfull),
    .rclk(clock2),
    .rrst(reset2),
    .rpop(OUTOFAXI_AFIFO_rpop),
    .rempty(OUTOFAXI_AFIFO_empty),
    .rdata(OUTOFAXI_AFIFO_rdata)
);
///////////////////////////////////////////////////////////////
logic WREADY_delay;
logic INTOAXI_AFIFO_empty;
logic INTOAXI_AFIFO_rpop;
//WCLK
always@(posedge clock2  )begin
        if(reset2) WREADY_delay<=1'b0;
        else WREADY_delay<=WREADY;
end

// ======= INTOAXI =======
    logic [1:0] intoaxi_state;
    logic [1:0] intoaxi_nstate;
    logic INTOAXI_AFIFO_rdata;
    logic WREADY_out_reg;
    assign WREADY_out = WREADY_out_reg;
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
		INTOAXI_AFIFO_rpop=1'b1;
	  end
        endcase
    end
    //
    always_ff@(posedge clock  )begin
        if (reset)begin
            WREADY_out_reg<=1'b0;
        end
        else begin
            if(intoaxi_state==pop) begin
                if(~INTOAXI_AFIFO_empty) WREADY_out_reg<=INTOAXI_AFIFO_rdata;
                else WREADY_out_reg<=WREADY_out_reg;
                // WREADY_out_reg<=INTOAXI_AFIFO_rdata;
            end
            else begin
                WREADY_out_reg<=WREADY_out_reg;
            end
        end
    end
//#########INTOAXI##################################################
logic INTOAXI_AFIFO_wfull;
AFIFO_CDC_1bit intoaxi(
    .wclk(clock2),
    .wrst(reset2),
    .wpush(WREADY^WREADY_delay),
    .wdata(WREADY),
    .wfull(INTOAXI_AFIFO_wfull),
    .rclk(clock),
    .rrst(reset),
    .rpop(INTOAXI_AFIFO_rpop),
    .rempty(INTOAXI_AFIFO_empty),
    .rdata(INTOAXI_AFIFO_rdata)
);

endmodule
