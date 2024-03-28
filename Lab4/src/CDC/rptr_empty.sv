module rptr_empty(
        input   rclk,
        input   rrst,
        //
        input   logic [4:0] wptr_rclk,
        input   rpop,
        //
        output  logic [4:0] rptr,
        output  logic [3:0] raddr, 
        output  logic rempty
);

logic [4:0] rbin;
//
logic [4:0] rgray_next;
logic [4:0] rbin_next;
//
logic rempty_val;

always @(posedge rclk) begin
    if(rrst) begin
        rbin <= 5'b0;
        rptr <= 5'b0;
    end
    else begin
        rbin <= rbin_next;
        rptr <= rgray_next;
    end
end

assign raddr = rbin[3:0];
assign rbin_next = rbin+(rpop & ~rempty);
//
assign rgray_next = (rbin_next>>1) ^ rbin_next;// gray code 
//
assign rempty_val = (rgray_next==wptr_rclk);
//
always @(posedge rclk ) begin
    if(rrst) begin
        rempty <= 1'b1;
    end
    else begin
        rempty <= rempty_val;
    end
end

endmodule
