//????????·XE?????æ¶?D??
module CSR (
    input clk, rst,
    input [11:0] address,
    input [31:0] E_pc,
    input stall,
    input next_pc_sel,
    output logic [31:0] csr_o,
    input stall_IF,

    input intr_ex,      //interrupt external
    input intr_t,       //interrupt timer
    input intr_end_ex,  //interrupt end external 
    input intr_end_t,   //interrupt end timer 

    input [31:0] rs1_data,
    input [31:0] E_inst
);

localparam  MSTATUS = 12'h300,
            MIE = 12'h304,
            MTVEC = 12'h305,
            MEPC = 12'h341,
            MIP = 12'h344,
            MCYCLE = 12'hb00,
            MCYCLEH = 12'hb80,
            MINSTRET = 12'hb02,
            MINSTRETH = 12'hb82;   

localparam  CSRRW = 3'b001,
            CSRRS = 3'b010,
            CSRRC = 3'b011,
            CSRRWI = 3'b100,
            CSRRSI = 3'b110,
            CSRRCI = 3'b111;

logic [63:0] cycle,instret;
logic [31:0] mstatus, mie, mtvec, mepc, mip;
logic [31:0] mstatus_out, mie_out, mepc_out, csr_mux, csr_tmp, csr_forwirte;

//Read CSR
always @(*) begin
    case (E_inst[31:20])
        MSTATUS     : csr_o = mstatus;
        MIE         : csr_o = mie;
        MTVEC       : csr_o = mtvec;
        MEPC        : csr_o = mepc;
        MIP         : csr_o = mip;

        MINSTRETH    : csr_o = instret[63:32];
        MINSTRET     : csr_o = instret[31:0];
        MCYCLEH    : csr_o = cycle[63:32];
        MCYCLE    : csr_o = cycle[31:0];

        default: csr_o = 32'b0;
    endcase
end

//Write CSR (only mstatus, mie, mepc)
always@(posedge clk or posedge rst)begin
    if(rst) begin
        mstatus<=32'b0;
        mie<=32'b0;
        mepc<=32'b0;
    end
    else begin
        if((E_inst[6:0]==7'b1110011 && E_inst[14:12]!=3'b000) && {E_inst[19:15],E_inst[11:7]}!=10'b0)begin
            case(E_inst[31:20])
            MSTATUS:begin
                // mstatus<=csr_forwrite;
                // mstatus[3]<=rs1_data[3];//MIE
                // mstatus[7]<=rs1_data[7];//MPIE
                // mstatus[12:11]<=rs1_data[12:11];//MPP

                case(E_inst[14:12])
                    CSRRW: mstatus=rs1_data;                   
                    CSRRS: mstatus=mstatus|rs1_data;               
                    CSRRC: mstatus=mstatus&(~rs1_data);            
                    CSRRWI: mstatus={27'b0,rs1_data[19:15]};       
                    CSRRSI: mstatus=mstatus | {27'b0,rs1_data[19:15]};    
                    CSRRCI: mstatus=mstatus & ~{27'b0,rs1_data[19:15]};    
                endcase

            end
            MIE:begin
                // mie<=csr_forwrite;
                // mie[7]<=rs1_data[7];//MTIE
                // mie[11]<=rs1_data[11];//MEIE
                case(E_inst[14:12])
                    CSRRW: mie=rs1_data;                   
                    CSRRS: mie=mie|rs1_data;               
                    CSRRC: mie=mie&(~rs1_data);            
                    CSRRWI: mie={27'b0,rs1_data[19:15]};       
                    CSRRSI: mie=mie | {27'b0,rs1_data[19:15]};    
                    CSRRCI: mie=mie & ~{27'b0,rs1_data[19:15]};    
                endcase
            end
            MEPC:begin
                // mepc<=csr_forwrite;
                // mepc<=rs1_data;
                case(E_inst[14:12])
                    CSRRW: mepc=rs1_data;                   
                    CSRRS: mepc=mepc|rs1_data;               
                    CSRRC: mepc=mepc&(~rs1_data);            
                    CSRRWI: mepc={27'b0,rs1_data[19:15]};       
                    CSRRSI: mepc=mepc | {27'b0,rs1_data[19:15]};    
                    CSRRCI: mepc=mepc & ~{27'b0,rs1_data[19:15]};    
                endcase
            end
            default: ;
            endcase
        end
        else begin
            if(intr_ex)begin
                mstatus[3]<=mstatus[7];//MIE
                mstatus[7]<=1'b0;//MPIE
                mstatus[12:11]<=2'b11;//MPP
                mie<={20'b0,intr_ex,3'b0,intr_t,7'b0};
                mepc<=E_pc; //if WFI is currently executed, store the following instruction(not deal yet)
            end
            else if(intr_end_ex)begin
                mstatus[3]<=1'b1;
                mstatus[7]<=mstatus[3];
                mstatus[12:11]<=2'b11;
                mie<={20'b0,intr_ex,3'b0,intr_t,7'b0};
                mepc<=E_pc;
            end
            else begin
                mstatus[3]<=mstatus[3];
                mstatus[7]<=mstatus[7];
                mstatus[12:11]<=2'b11;
                mie<=mie;
                mepc<=mepc;
            end
        end
    end
end

// always@(*)begin
//     case(imm_ext)
//     MSTATUS: csr_tmp=mstatus;
//     MIE: csr_tmp=mie;
//     MEPC: csr_tmp=mepc;
//     default:;
//     endcase
// end
// CSR_ALU (.csr(csr_tmp), .rs1_data(rs1_data), .f3(E_f3), .csr_out(csr_forwirte));

assign mtvec=32'h0001_0000;


//cycle
always @(posedge clk or posedge rst) begin
    if (rst) cycle<=64'b0;
    else cycle<=cycle+64'b1;
end

//inst
always @(posedge clk or posedge rst) begin
    if (rst) begin
        instret<=64'b1;
    end
    else begin;
	if(E_pc!=32'b0 && ~stall_IF)instret<=instret+64'b1;
    // if(stall==1'b0 && next_pc_sel==1'b0)instret<=instret+64'b1;
    end
end
endmodule

// module CSR (
//     input clk, rst,
//     input [11:0] imm_ext,
//     input [31:0] E_pc,
//     input stall,
//     input next_pc_sel,
//     output logic [31:0] csr_o,
//     input stall_IF
// );

// //????­è?????????????????bits
// parameter   RDINSTRETH = 12'b110010000010,
//             RDINSTRET =  12'b110000000010,
//             RDCYCLEH  =  12'b110010000000,
//             RDCYCLE =    12'b110000000000;

// logic [63:0] cycle,instret;

// always @(posedge clk or posedge rst) begin
//     if (rst) cycle<=64'b0;
//     else cycle<=cycle+64'b1;
// end

// always @(posedge clk or posedge rst) begin
//     if (rst) begin
//         instret<=64'b1;
//     end
//     else begin;
// 	if(E_pc!=32'b0 && ~stall_IF)instret<=instret+64'b1;
//     // if(stall==1'b0 && next_pc_sel==1'b0)instret<=instret+64'b1;
//     end
// end




// always @(*) begin
//     case (imm_ext)
//         RDINSTRETH    : csr_o = instret[63:32];
//         RDINSTRET     : csr_o = instret[31:0];
//         RDCYCLEH    : csr_o = cycle[63:32];
//         RDCYCLE    : csr_o = cycle[31:0];
//         default: csr_o = 32'b0;

//     endcase
// end
// endmodule

