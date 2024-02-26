module WDT(
    input clk,rst,
    input clk2,rst2,
    input WDEN,WDLIVE,
    input [31:0]WTOCNT,
    output logic WTO
);
  
logic [31:0] count;
logic WDEN_reg, WDLIVE_reg;
logic [31:0] WTOCNT_reg;

always_ff@(posedge clk2)begin
	if (rst2)begin
		WDEN_reg<=1'b0;
		WDLIVE_reg<=1'b0;
		WTOCNT_reg<=32'b0;
	end
	else begin
		WDEN_reg<=WDEN;
		WDLIVE_reg<=WDLIVE;
		WTOCNT_reg<=WTOCNT;
	end
end

always_ff@(posedge clk2)begin
    if(rst2)begin
        count<=32'b0;
    end
    else begin
	WTO<=(count>=WTOCNT_reg && WDEN_reg)?1'b1:1'b0;
        if(WDEN_reg)begin
            if(WDLIVE_reg)count<=32'b0;
            else begin
                if(count<WTOCNT_reg) count<=count+32'b1;
                else count<=32'b0; //full then clear
            end
        end
        else begin
            if(WDLIVE_reg)count<=32'b0;
            else count<=count;
        end
    end
end

//assign WTO=(count>=WTOCNT && WDEN)?1'b1:1'b0;

//There is an issue: When count is full, it will be counted continuesly because of WDEN=1. 
//However, We want it hold at zero. Then count after next WDEN=1.

endmodule
