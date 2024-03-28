module wptr_full(
        input   wclk,
        input   wrst,
        //
        input   logic [4:0] rptr_wclk,
        input   wpush,
        //
        output  logic [4:0] wptr,
        output  logic [3:0] waddr, 
        output  logic wfull
);

logic [4:0] wbin;
//
logic [4:0] wgray_next;
logic [4:0] wbin_next;
//
logic wfull_val;

always @(posedge wclk) begin
    if(wrst) begin
        wbin <= 5'b0;
        wptr <= 5'b0;
    end
    else begin
        wbin <= wbin_next;
        wptr <= wgray_next;
    end
end

assign waddr = wbin[3:0];
assign wbin_next = wbin+(wpush & ~wfull);
//
//
always @(posedge wclk) begin
    if(wrst) begin
        wgray_next <= 5'b0;
    end
    else begin
        wgray_next <= (wbin_next>>1) ^ wbin_next;
    end
end
//assign wgray_next = (wbin_next>>1) ^ wbin_next;// gray code 
//
assign wfull_val = ((wgray_next[4:3]==~rptr_wclk[4:3])&&(wgray_next[2:0]==rptr_wclk[2:0]));
//
always @(posedge wclk) begin
    if(wrst) begin
        wfull <= 1'b0;
    end
    else begin
        wfull <= wfull_val;
    end
end

endmodule
