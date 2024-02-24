module LD_Filter (
input [2:0] func3,
input [31:0] ld_data,
output reg [31:0] ld_data_f
);
//常數部分為 sign-extended 12-bit，載入位址則為 rs1暫存器加上 sign-extended 12-bit，
//LW為載入 32-bit資料寫入 rd暫存器，LH/LHU為載入 16-bit資料分別做 unsigned/signed extension成 32-bit後寫入 rd暫存器，
//LB/LBU為載入 8-bit資料分別做 unsigned/signed extension成 32-bit後寫入 rd暫存器

always @(*) begin
    case(func3)
        //LW
        3'b010: ld_data_f=ld_data;
        //LH
        3'b001: ld_data_f={{16{ld_data[15]}},ld_data[15:0]};
        //LB
        3'b000: ld_data_f={{24{ld_data[7]}},ld_data[7:0]};
        //LHU
        3'b101: ld_data_f={16'b0,ld_data[15:0]};
        //LBU
        3'b100: ld_data_f={24'b0,ld_data[7:0]};
        default: ld_data_f=32'b0;
    endcase
end

endmodule