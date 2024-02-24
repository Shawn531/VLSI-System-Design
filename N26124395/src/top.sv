//V1.4
//V1.5 1. 調整MUL MODULE 2. 將alu csr mul MUX移至M STAGE 3. 調整MUX結構 4.ALU改CASE
//V1.6 MUL一部分移到M STAGE
//V1.7 將MUL移到MEM
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
`include "SRAM_wrapper.sv"
`include "wen_shift.sv"
`include "Adder.sv"

module top (
    input clk,
    input rst
);

logic [31:0] next_pc, pc_32, inst, sext_imme, jb_c, jb_pc, rs1_data, rs2_data, inst_memdelay, csr_RegM;
wire [31:0] alu_out_32, ld_data, ld_data_f, wb_data, operand1, operand2; 
// wire [15:0]  alu_out_16;
wire [4:0] rs1_index, rs2_index, rd_index, opcode, E_op;
wire [3:0] M_dm_w_en_out;
logic [2:0] func3, E_f3, W_f3, f3_new;
wire func7, E_f7, branch_en, next_pc_sel;
logic delay_en,csr_en, func7_mul;
logic mul_en, OE, OE1;
logic [31:0] csr_o, new_rs2_data_CSR, mul_out, rs2_data_RegM_out;
logic [63:0] mul_temp, mul_RegM;
logic [31:0] op1_RegM, op2_RegM;
logic [4:0] M_op;
logic E_f7_mul_new;

wire [31:0] pc_RegD, inst_RegD, rs1_data_mux, rs2_data_mux, pc_RegE, rs1_data_RegE, rs2_data_RegE, sext_imm_RegE;
wire [4:0] W_rd_index;
wire stall, D_rs1_data_sel, D_rs2_data_sel, E_jb_op1_sel, E_alu_op1_sel, E_alu_op2_sel;
wire [1:0] E_rs1_data_sel, E_rs2_data_sel;
wire [3:0] M_dm_w_en;

wire [31:0] alu_out_RegM, new_rs1_data, new_rs2_data, rs2_data_RegM, alu_out_RegW, /*ld_data_RegW,*/ alu_mul_csr;


Controller controller(.clk(clk), .rst(rst), .op(opcode), .f3(func3), .f7(func7), .f7_mul(func7_mul), .rd(rd_index), 
.rs1(rs1_index), .rs2(rs2_index), .branch_en(branch_en), 
.stall(stall), .next_pc_sel(next_pc_sel), .D_rs1_data_sel(D_rs1_data_sel), .D_rs2_data_sel(D_rs2_data_sel),
.E_rs1_data_sel(E_rs1_data_sel), .E_rs2_data_sel(E_rs2_data_sel), .E_jb_op1_sel(E_jb_op1_sel),
.E_alu_op1_sel(E_alu_op1_sel), .E_alu_op2_sel(E_alu_op2_sel), .E_op_out(E_op), .E_f3_out(E_f3), .E_f7_out(E_f7), .E_f7_out_mul(E_f7_mul),
.M_dm_w_en(M_dm_w_en),
.W_wb_en(W_wb_en), .W_rd_out(W_rd_index), .W_f3_out(W_f3), .W_wb_data_sel(W_wb_data_sel), .OE(OE), .OE1(OE1));

// Adder adder(.a(pc_32), .c(pc_plus4));
Mux mux_pc(.a(jb_pc), .b(pc_32+32'd4), .en(next_pc_sel), .c(next_pc));

Reg_PC regpc(.clk(clk), .rst(rst), .stall(stall), .next_pc(next_pc), .current_pc(pc_32));
//assign pc_16=pc_32[15:0];

SRAM_wrapper IM1(.CK(clk), .CS(1'b1), .OE(OE), .WEB(4'b1111), .A(pc_32[15:2]), .DI(32'b0), .DO(inst));

Reg_IF_ID reg_if_id(.clk(clk), .rst(rst), .stall(stall), .next_pc_sel(next_pc_sel), .pc(pc_32), .inst(inst), .pc_out(pc_RegD), .inst_out(inst_RegD));

// assign delay_en=(stall||next_pc_sel);
always@(posedge clk or posedge rst)begin
    if(rst) delay_en<=1'b0;
	else delay_en<=(stall||next_pc_sel);
end

// Mux mux_inst_zero(.a(32'b0), .b(inst), .en(next_pc_sel), .c(inst_z));//若jb則inst=0

MUX_fordelay mux_memdelay(.a(inst_RegD), .b(inst), .en(delay_en||(pc_32==32'b0)), .c(inst_memdelay));



// always@(posedge clk)begin
//     if(delay_en) inst_memdelay<=inst_RegD;
//     else inst_memdelay<=inst;
// end

Decoder decoder(.inst(inst_memdelay), .dc_out_opcode(opcode), .dc_out_func3(func3), .dc_out_func7(func7), 
.dc_out_rs1_index(rs1_index), .dc_out_rs2_index(rs2_index), .dc_out_rd_index(rd_index), .dc_out_func7_mul(func7_mul));

Imm_Ext imm_ext(.inst(inst_memdelay), .imm_ext_out(sext_imme));

RegFile regfile(.clk(clk), .rst(rst), .wb_en(W_wb_en), .wb_data(wb_data), .W_rd_index(W_rd_index), .rs1_index(rs1_index), 
.rs2_index(rs2_index), .rs1_data_out(rs1_data), .rs2_data_out(rs2_data));

Mux mux_rs1_fw(.a(wb_data), .b(rs1_data), .en(D_rs1_data_sel), .c(rs1_data_mux));
Mux mux_rs2_fw(.a(wb_data), .b(rs2_data), .en(D_rs2_data_sel), .c(rs2_data_mux));

Reg_ID_EXE reg_id_exe(.clk(clk), .rst(rst), .stall(stall), .next_pc_sel(next_pc_sel), .pc(pc_RegD), 
.rs1_data(rs1_data_mux), .rs2_data(rs2_data_mux), .sext_imm(sext_imme), .pc_out(pc_RegE), 
.rs1_data_out(rs1_data_RegE), .rs2_data_out(rs2_data_RegE), .sext_imm_out(sext_imm_RegE));

Mux_3 mux_3_rs1(.a(wb_data), .b(alu_mul_csr), .c(rs1_data_RegE), .en(E_rs1_data_sel), .d(new_rs1_data));
Mux_3 mux_3_rs2(.a(wb_data), .b(alu_mul_csr), .c(rs2_data_RegE), .en(E_rs2_data_sel), .d(new_rs2_data));

Mux mux_rs1_pc(.a(new_rs1_data), .b(pc_RegE), .en(E_alu_op1_sel), .c(operand1));
Mux mux_rs2_imm(.a(new_rs2_data), .b(sext_imm_RegE), .en(E_alu_op2_sel), .c(operand2)); 

Mux mux_jb(.a(pc_RegE), .b(new_rs1_data), .en(E_jb_op1_sel), .c(jb_c));

ALU alu(.opcode(E_op), .func3(E_f3), .func7(E_f7), .operand1(operand1), .operand2(operand2), .alu_out(alu_out_32));
// assign alu_out_16=alu_out_32[15:0];

// Mul mul(.opcode(E_op), .func3(E_f3), .func7_mul(E_f7_mul), .operand1(operand1), .operand2(operand2), .mul_temp(mul_temp));



JB_Unit jb_unit(.opcode(E_op), .operand1(jb_c), .operand2(sext_imm_RegE), .jb_out(jb_pc));

CSR csr(.clk(clk), .rst(rst), .imm_ext(sext_imm_RegE[11:0]), .E_pc(pc_RegE), .csr_o(csr_o), .stall(stall), .next_pc_sel(next_pc_sel));


// Mux mux_mul(.a(mul_out), .b(alu_out_32), .en(mul_en), .c(alu_mul)); 
// Mux mux_csr(.a(csr_o), .b(alu_mul), .en(csr_en), .c(alu_mul_csr));

// 0:alu 2:
// Mux_3 mux_new(.a(alu_out_32), .b(mul_out), .c(csr_o), .en({csr_en, mul_en}), .d(alu_mul_csr));

//alu_out改過 mul

// assign mul_en=((E_op==5'b01100) && E_f7_mul)?1:0;
// assign csr_en=(E_op==5'b11100)?1:0;

always@(posedge clk or posedge rst)begin
    if(rst)begin
        mul_en<=1'b0;
        csr_en<=1'b0;
        f3_new<=3'b0;
        E_f7_mul_new<=1'b0;
        M_op<=5'b0;
    end
    else begin
        mul_en<=((E_op==5'b01100) && E_f7_mul)?1'b1:1'b0;
        csr_en<=(E_op==5'b11100)?1'b1:1'b0;
        f3_new<=E_f3;
        E_f7_mul_new<=E_f7_mul;
        M_op<=E_op;
    end
end

Reg_EXE_MEM reg_exe_mem(.clk(clk), .rst(rst), .alu_out(alu_out_32), .rs2_data(new_rs2_data), .alu_out_out(alu_out_RegM), .rs2_data_out(rs2_data_RegM), .op1(operand1), .op2(operand2), .csr(csr_o), .op1_RegM(op1_RegM), .op2_RegM(op2_RegM), .csr_out(csr_RegM));

// always@(*)begin
//     case(f3_new)
//     3'b000: mul_out=mul_RegM[31:0];
//     default: mul_out=mul_RegM[63:32];
//     endcase
// end

Mul mul(.opcode(M_op), .func3(f3_new), .func7_mul(E_f7_mul_new), .operand1(op1_RegM), .operand2(op2_RegM), .mul_out(mul_out));

Mux_3 mux_new(.a(alu_out_RegM), .b(mul_out), .c(csr_RegM), .en({csr_en, mul_en}), .d(alu_mul_csr));


wen_shift wen_shift(.last_two(alu_mul_csr[1:0]), .w_en(M_dm_w_en), .wen_shift_out(M_dm_w_en_out), .mem_data(rs2_data_RegM), .mem_data_out(rs2_data_RegM_out));

SRAM_wrapper DM1(.CK(clk), .CS(1'b1), .OE(OE1), .WEB(~M_dm_w_en_out), .A(alu_mul_csr[15:2]), .DI(rs2_data_RegM_out), .DO(ld_data));

Reg_MEM_WB reg_mem_wb(.clk(clk), .rst(rst), .alu_out(alu_mul_csr), .ld_data(ld_data), .alu_out_out(alu_out_RegW));

LD_Filter ld_filter(.func3(W_f3), .ld_data(ld_data), .ld_data_f(ld_data_f));

Mux mux_ld_alu(.a(ld_data_f), .b(alu_out_RegW), .en(W_wb_data_sel), .c(wb_data));

assign branch_en=alu_out_32[0];





endmodule
