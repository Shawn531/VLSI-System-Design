module FIFO_MEM_1bit(
        input wclk,
        input wrst,
        input wen,
        //
        input logic [3:0] waddr,
        input logic [3:0] raddr,
        //
        input logic wdata,
        output logic rdata
);

    parameter   ADDRESS_WIDTH = 4;
    parameter   FIFO_DEPTH    = (1 << ADDRESS_WIDTH);


    reg   mem [0:FIFO_DEPTH-1];//memory
    
    assign rdata = mem[raddr];
    
    always @(posedge wclk) begin
	  if(wrst) begin
		for(int i=0;i<16;i++) mem[i]<=1'b0;
	  end
	  else begin
        	if(wen) mem[waddr] <= wdata;
	  	else mem<=mem;
	  end
    end

endmodule
