module AFIFO_CDC_1bit(
        input   wclk,
        input   wrst,
        input   wpush,
        input   logic wdata,
        output  wfull,
        //
        input   rclk,
        input   rrst,
        input   rpop,
        output  rempty,
        output  logic rdata
);
//
logic error_w;
assign error_w = (wpush&&wfull);
logic error_r;
assign error_r = (rpop&&rempty);
logic wen_to_mem;
assign wen_to_mem = wpush&&~wfull;
logic [3:0] waddr_to_mem;
logic [3:0] raddr_to_mem;

logic [4:0] wptr_to_sync;
logic [4:0] rptr_to_sync;

logic [4:0] wptr_rclk;
logic [4:0] rptr_wclk;

logic rdata_reg;

always @(posedge rclk ) begin
        if(rrst) begin
                rdata_reg<=1'b0;
        end
        else begin
                rdata_reg <= rdata;
        end
end
wptr_full wptr_full0(
        .wclk(wclk),
        .wrst(wrst),
        //
        .rptr_wclk(rptr_wclk),
        .wpush(wpush),
        //
        .wptr(wptr_to_sync),
        .waddr(waddr_to_mem), 
        .wfull(wfull)
);

rptr_empty rptr_empty0(
        .rclk(rclk),
        .rrst(rrst),
        //
        .wptr_rclk(wptr_rclk),
        .rpop(rpop),
        //
        .rptr(rptr_to_sync),
        .raddr(raddr_to_mem), 
        .rempty(rempty)
);

FIFO_MEM_1bit FIFO_MEM_1bit0(
        .wclk(wclk),
        .wrst(wrst),
        .wen(wen_to_mem),
        .waddr(waddr_to_mem),
        .raddr(raddr_to_mem),
        .wdata(wdata),
        .rdata(rdata)
);

sync_r2w sync_r2w0(
        .rptr_wclk(rptr_wclk),
        .rptr(rptr_to_sync),
        .wclk(wclk), 
        .wrst(wrst)
);

sync_w2r sync_w2r0(
        .wptr_rclk(wptr_rclk),
        .wptr(wptr_to_sync),
        .rclk(rclk), 
        .rrst(rrst)
);

endmodule
