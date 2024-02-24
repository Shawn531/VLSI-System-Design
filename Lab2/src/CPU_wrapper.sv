//V1.4
//V1.5 1. 調整MUL MODULE 2. 將alu csr mul MUX移至M STAGE 3. 調整MUX結構 4.ALU改CASE
`include "ALU.sv"
`include "Controller.sv"
`include "CSR.sv"
`include "Decoder.sv"
`include "Imm_Ext.sv"
`include "JB_Unit.sv"
`include "LD_Filter.sv"
`include "Mul.sv"
`include "Mux_3.sv"
`include "MUX_fordelay.sv"
`include "Mux.sv"
`include "Reg_EXE_MEM.sv"
`include "Reg_ID_EXE.sv"
`include "Reg_IF_ID.sv"
`include "Reg_MEM_WB.sv"
`include "Reg_PC.sv"
`include "RegFile.sv"
// `include "SRAM_wrapper.sv"
`include "wen_shift.sv"
`include "Adder.sv"
// `include "Slave_Read.sv"
`include "Master_Read.sv"
//`include "Bridge_Read.sv"
`include "Master_Write.sv"
// `include "Slave_Write.sv"
//`include "Bridge_Write.sv"

module CPU_wrapper (
    input clk,
    input rst,

    output [`AXI_ID_BITS-1:0]   AWID_M1,
	output [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	output [`AXI_LEN_BITS-1:0]  AWLEN_M1,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	output [1:0]                AWBURST_M1,
	output                      AWVALID_M1,
	input                       AWREADY_M1,
	//WRITE DATA
	output [`AXI_DATA_BITS-1:0] WDATA_M1,
	output [`AXI_STRB_BITS-1:0] WSTRB_M1,
	output                      WLAST_M1,
	output                      WVALID_M1,
	input                       WREADY_M1,
	//WRITE RESPONSE
	input [`AXI_ID_BITS-1:0]    BID_M1, 
	input [1:0]                 BRESP_M1,
	input                       BVALID_M1,
	output                      BREADY_M1,

	//READ ADDRESS0
	output [`AXI_ID_BITS-1:0]   ARID_M0,
	output [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	output [`AXI_LEN_BITS-1:0]  ARLEN_M0,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	output [1:0]                ARBURST_M0,
	output                      ARVALID_M0,
	input                       ARREADY_M0,
	//READ DATA0
	input [`AXI_ID_BITS-1:0]    RID_M0,
	input [`AXI_DATA_BITS-1:0]  RDATA_M0,
	input [1:0]                 RRESP_M0,
	input                       RLAST_M0,
	input                       RVALID_M0,
	output                      RREADY_M0,
	//READ ADDRESS1
	output [`AXI_ID_BITS-1:0]   ARID_M1,
	output [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	output [`AXI_LEN_BITS-1:0]  ARLEN_M1,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	output [1:0]                ARBURST_M1,
	output                      ARVALID_M1,
	input                       ARREADY_M1,
	//READ DATA1
	input [`AXI_ID_BITS-1:0]    RID_M1,
	input [`AXI_DATA_BITS-1:0]  RDATA_M1,
	input [1:0]                 RRESP_M1,
	input                       RLAST_M1,
	input                       RVALID_M1,
	output                      RREADY_M1
);

logic [31:0] next_pc, pc_32, inst, sext_imme, jb_c, jb_pc, rs1_data, rs2_data, inst_memdelay, mul_RegM, csr_RegM;
wire [31:0] alu_out_32, ld_data, ld_data_f, wb_data, operand1, operand2; 
// wire [15:0]  alu_out_16;
wire [4:0] rs1_index, rs2_index, rd_index, opcode, E_op;
wire [3:0] M_dm_w_en_out;
wire [2:0] func3, E_f3, W_f3;
logic func7, E_f7, branch_en, next_pc_sel;
logic delay_en,csr_en, func7_mul;
logic mul_en, OE, OE1;
logic [31:0] csr_o, new_rs2_data_CSR, mul_out, rs2_data_RegM_out;
logic rvalid_out0, rvalid_out1;

wire [31:0] pc_RegD, inst_RegD, rs1_data_mux, rs2_data_mux, pc_RegE, rs1_data_RegE, rs2_data_RegE, sext_imm_RegE;
wire [4:0] W_rd_index;
wire stall, D_rs1_data_sel, D_rs2_data_sel, E_jb_op1_sel, E_alu_op1_sel, E_alu_op2_sel;
wire [1:0] E_rs1_data_sel, E_rs2_data_sel;
wire [3:0] M_dm_w_en;

wire [31:0] alu_out_RegM, new_rs1_data, new_rs2_data, rs2_data_RegM, alu_out_RegW, alu_mul_csr;

logic [31:0] ld_data_RegW, ld_data_orignal, ld_data_mux;
logic [4:0] M_op;
logic [1:0] M_op_last2;
logic [1:0] op_last2;


logic [13:0]                address_in_W; 
logic [3:0]                 w_en_W;
logic [`AXI_DATA_BITS-1:0]  data_in_W;          
logic [`AXI_ID_BITS-1:0]  id_in_W;      
logic write_signal;

logic stall_W;

logic [31:0] data_out_W, address_out_W;
logic [3:0] w_en_out_M;

logic stall_IF, stall_DM, stall_IM;

logic read_signal; logic [13:0] address_in; logic[3:0] id_in;
logic [31:0] data_out;

logic [13:0] address_out; logic [31:0] data_in;

logic [31:0] address_out_DM;

logic [31:0] address_into_sram;

logic [31:0] rs1_reg, rs2_reg, rs1_data_out, rs2_data_out;
logic stall_IFD;

logic stall_MEM;
logic [31:0] ld_data_temp;
logic isnot_FREE_W;

logic read_signal_IM;


/*logic state, nstate;
localparam IDLE=1'd0, BUSY=1'd1;
localparam READ=2'd1, WRITE=2'd2, FREE=2'd0, WRONG=2'd3;

logic [1:0] select, select_reg;

/////////for vip check
always_ff@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn) state<=IDLE;
	else state<=nstate;
end
always@(*)begin
	case(state)
	IDLE:begin
		if(RVALID_M0|| BVALID_M1) nstate=BUSY;
		else nstate=IDLE;
	end
	BUSY:begin
		if(RLAST || (BVALID_M1 && BREADY_M1)) nstate=IDLE;
		else nstate=BUSY;
	end
	endcase
end
always@(*)begin
	case(state)
	IDLE:begin
		if(BVALID_M1) begin
			if(~RVALID)select=WRITE;
			else select=WRONG;
		end
		else if(RVALID) begin
			if(~BVALID_M1) select=READ;
			else select=WRONG;
		end
		else begin
			select=FREE;
		end
	end
	BUSY:begin
		select=select_reg;
	end
	endcase
end
always_ff@(posedge ACLK or negedge ARESETn)begin
	if(~ARESETn) begin
		select_reg=2'd0;
	end
	else begin
		case(state)
		IDLE: select_reg=select;
		BUSY: select_reg=select_reg;
		endcase
	end
end*/
////////


always@(posedge clk or posedge rst) begin
	if(rst) read_signal_IM<=1'b0;
	else read_signal_IM<=1'b1;
end


Controller controller(.clk(clk), .rst(rst), .op(opcode), .f3(func3), .f7(func7), .f7_mul(func7_mul), .rd(rd_index), 
.rs1(rs1_index), .rs2(rs2_index), .branch_en(branch_en), 
.stall(stall), .next_pc_sel(next_pc_sel), .D_rs1_data_sel(D_rs1_data_sel), .D_rs2_data_sel(D_rs2_data_sel),
.E_rs1_data_sel(E_rs1_data_sel), .E_rs2_data_sel(E_rs2_data_sel), .E_jb_op1_sel(E_jb_op1_sel),
.E_alu_op1_sel(E_alu_op1_sel), .E_alu_op2_sel(E_alu_op2_sel), .E_op_out(E_op), .E_f3_out(E_f3), .E_f7_out(E_f7), .E_f7_out_mul(E_f7_mul),
.M_dm_w_en(M_dm_w_en), .M_op(M_op), .M_op_last2(M_op_last2),
.W_wb_en(W_wb_en), .W_rd_out(W_rd_index), .W_f3_out(W_f3), .W_wb_data_sel(W_wb_data_sel), .OE(OE), .OE1(OE1),
.stall_IF(stall_IF), .op_last2(op_last2), .rvalid(rvalid_out1));

Mux mux_pc(.a(jb_pc), .b(pc_32+32'd4), .en(next_pc_sel), .c(next_pc));

Reg_PC regpc(.clk(clk), .rst(rst), .stall(stall), .next_pc(next_pc), .current_pc(pc_32), .stall_IF(stall_IF));




Master_Read MR(.ACLK(clk), .ARESETn(~rst),
            .ARID(ARID_M0), .ARADDR(ARADDR_M0), .ARLEN(ARLEN_M0), .ARSIZE(ARSIZE_M0), 
            .ARBURST(ARBURST_M0), .ARVALID(ARVALID_M0), .ARREADY(ARREADY_M0),

            .RID(RID_M0), .RDATA(RDATA_M0), .RRESP(RRESP_M0),
            .RLAST(RLAST_M0), .RVALID(RVALID_M0), .RREADY(RREADY_M0),

            .read_signal(/*(pc_32[6:0]!=7'b0000000)*//*1'b1*/read_signal_IM), .address_in({18'b0,pc_32[15:2]}), .id_in(4'b1),
            .data_out(inst), .stall_IF(stall_IM), .rvalid_out(rvalid_out0)
            );

assign stall_IF=stall_IM & stall_W;
			



Reg_IF_ID reg_if_id(.clk(clk), .rst(rst), .stall(stall), .next_pc_sel(next_pc_sel), .pc(pc_32), .inst(inst), .pc_out(pc_RegD), .inst_out(inst_RegD), .stall_IF(stall_IF));


always@(posedge clk or posedge rst)begin
	if(rst) delay_en<=1'b0;
    else begin
        if(stall_IF) delay_en<=delay_en;
        else delay_en<=(stall||next_pc_sel);
    end
end


MUX_fordelay mux_memdelay(.a(inst_RegD), .b(inst), .en(/*delay_en||(pc_32==32'b0)*/1'b1), .c(inst_memdelay));

Decoder decoder(.inst(inst_memdelay), .dc_out_opcode(opcode), .dc_out_func3(func3), .dc_out_func7(func7), 
.dc_out_rs1_index(rs1_index), .dc_out_rs2_index(rs2_index), .dc_out_rd_index(rd_index), .dc_out_func7_mul(func7_mul), .dc_out_last2(op_last2));

Imm_Ext imm_ext(.inst(inst_memdelay), .imm_ext_out(sext_imme));

RegFile regfile(.clk(clk), .rst(rst), .wb_en(W_wb_en), .wb_data(wb_data), .W_rd_index(W_rd_index), .rs1_index(rs1_index), 
.rs2_index(rs2_index), .rs1_data_out(rs1_data), .rs2_data_out(rs2_data));


//stall_IFD會有問題


always@(posedge clk or posedge rst)begin
	if(rst)begin
		rs1_reg<=32'b0;
		rs2_reg<=32'b0;
	end
	else begin
		// rs1_reg<=rs1_data;
		// rs2_reg<=rs2_data;
		if(~stall_IFD)begin
			rs1_reg<=rs1_data;
			rs2_reg<=rs2_data;
		end
		else begin
			rs1_reg<=rs1_reg;
			rs2_reg<=rs2_reg;
		end
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		stall_IFD<=1'b0;
	end
	else begin
		stall_IFD<=stall_IF;
	end
end

assign rs1_data_out=(~stall_IFD)?rs1_data:rs1_reg;
assign rs2_data_out=(~stall_IFD)?rs2_data:rs2_reg;

Mux mux_rs1_fw(.a(wb_data), .b(rs1_data_out), .en(D_rs1_data_sel), .c(rs1_data_mux));
Mux mux_rs2_fw(.a(wb_data), .b(rs2_data_out), .en(D_rs2_data_sel), .c(rs2_data_mux));

Reg_ID_EXE reg_id_exe(.clk(clk), .rst(rst), .stall(stall), .next_pc_sel(next_pc_sel), .pc(pc_RegD), 
.rs1_data(rs1_data_mux), .rs2_data(rs2_data_mux), .sext_imm(sext_imme), .pc_out(pc_RegE), 
.rs1_data_out(rs1_data_RegE), .rs2_data_out(rs2_data_RegE), .sext_imm_out(sext_imm_RegE),
.stall_IF(stall_IF));

Mux_3 mux_3_rs1(.a(wb_data), .b(alu_mul_csr), .c(rs1_data_RegE), .en(E_rs1_data_sel), .d(new_rs1_data));
Mux_3 mux_3_rs2(.a(wb_data), .b(alu_mul_csr), .c(rs2_data_RegE), .en(E_rs2_data_sel), .d(new_rs2_data));

Mux mux_rs1_pc(.a(new_rs1_data), .b(pc_RegE), .en(E_alu_op1_sel), .c(operand1));
Mux mux_rs2_imm(.a(new_rs2_data), .b(sext_imm_RegE), .en(E_alu_op2_sel), .c(operand2)); 

Mux mux_jb(.a(pc_RegE), .b(new_rs1_data), .en(E_jb_op1_sel), .c(jb_c));

ALU alu(.opcode(E_op), .func3(E_f3), .func7(E_f7), .operand1(operand1), .operand2(operand2), .alu_out(alu_out_32));
// assign alu_out_16=alu_out_32[15:0];

Mul mul(.opcode(E_op), .func3(E_f3), .func7_mul(E_f7_mul), .operand1(operand1), .operand2(operand2), .mul_out(mul_out));



JB_Unit jb_unit(.opcode(E_op), .operand1(jb_c), .operand2(sext_imm_RegE), .jb_out(jb_pc));

CSR csr(.clk(clk), .rst(rst), .imm_ext(sext_imm_RegE[11:0]), .E_pc(pc_RegE), .csr_o(csr_o), .stall(stall), .next_pc_sel(next_pc_sel), .stall_IF(stall_IF));


always@(posedge clk or posedge rst)begin
    if(rst)begin
        mul_en<=1'b0;
        csr_en<=1'b0;
    end
    else begin
        if(stall_IF)begin
            mul_en<=mul_en;
            csr_en<=csr_en;
        end
        else begin
            mul_en<=((E_op==5'b01100) && E_f7_mul)?1'b1:1'b0;
            csr_en<=(E_op==5'b11100)?1'b1:1'b0;
        end
    end
end

Reg_EXE_MEM reg_exe_mem(.clk(clk), .rst(rst), .alu_out(alu_out_32), .rs2_data(new_rs2_data), 
.alu_out_out(alu_out_RegM), .rs2_data_out(rs2_data_RegM), .mul(mul_out), 
.csr(csr_o), .mul_out(mul_RegM), .csr_out(csr_RegM), .stall_IF(stall_IF));

Mux_3 mux_new(.a(alu_out_RegM), .b(mul_RegM), .c(csr_RegM), .en({csr_en, mul_en}), .d(alu_mul_csr));


wen_shift wen_shift(.last_two(alu_mul_csr[1:0]), .w_en(M_dm_w_en), .wen_shift_out(M_dm_w_en_out), .mem_data(rs2_data_RegM), .mem_data_out(rs2_data_RegM_out));

assign read_signal=({M_op, M_op_last2}==7'b0000011);

Master_Read MR1(.ACLK(clk), .ARESETn(~rst),
            .ARID(ARID_M1), .ARADDR(ARADDR_M1), .ARLEN(ARLEN_M1), .ARSIZE(ARSIZE_M1), 
            .ARBURST(ARBURST_M1), .ARVALID(ARVALID_M1), .ARREADY(ARREADY_M1),

            .RID(RID_M1), .RDATA(RDATA_M1), .RRESP(RRESP_M1),
            .RLAST(RLAST_M1), .RVALID(RVALID_M1), .RREADY(RREADY_M1),

            .read_signal(read_signal), .address_in({17'b0,alu_mul_csr[16:2]}), .id_in(4'd2),
            .data_out(ld_data), .stall_IF(stall_DM), .rvalid_out(rvalid_out1)
            );



assign write_signal=(M_op==5'b01000)?1'b1:1'b0;
assign id_in_W=4'b0;


Master_Write MW(.ACLK(clk), .ARESETn(~rst),
				.AWID(AWID_M1), .AWADDR(AWADDR_M1), .AWLEN(AWLEN_M1), .AWSIZE(AWSIZE_M1),
				.AWBURST(AWBURST_M1), .AWVALID(AWVALID_M1), .AWREADY(AWREADY_M1),
				
				.WDATA(WDATA_M1), .WSTRB(WSTRB_M1), .WLAST(WLAST_M1), .WVALID(WVALID_M1), .WREADY(WREADY_M1),

				.BID(BID_M1), .BRESP(BRESP_M1), .BVALID(BVALID_M1), .BREADY(BREADY_M1), 

				.address_in({18'b0,alu_mul_csr[15:2]}), .w_en(M_dm_w_en_out), .data_in(rs2_data_RegM_out), .id_in(id_in_W), .write_signal(write_signal),

				.stall_W(stall_W)
				);


Reg_MEM_WB reg_mem_wb(.clk(clk), .rst(rst), .alu_out(alu_mul_csr), .ld_data(ld_data), .alu_out_out(alu_out_RegW), .ld_data_RegW(ld_data_RegW), .stall_IF(stall_IF), .rvalid(rvalid_out1), .ld_data_orignal(ld_data_orignal));

assign ld_data_mux=(stall_IFD)?ld_data_orignal:ld_data_RegW;

LD_Filter ld_filter(.func3(W_f3), .ld_data(ld_data_mux), .ld_data_f(ld_data_f));

Mux mux_ld_alu(.a(ld_data_f), .b(alu_out_RegW), .en(W_wb_data_sel), .c(wb_data));

assign branch_en=alu_out_32[0];

endmodule
