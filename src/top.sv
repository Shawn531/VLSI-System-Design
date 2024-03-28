`include "AXI/Bridge/AXI.sv"
`include "AXI/Bridge/Bridge_Read.sv"
`include "AXI/Bridge/Bridge_Write.sv"
`include "AXI/Master/Master_Read.sv"
`include "AXI/Master/Master_Write.sv"
`include "AXI/Slave/Slave_Read.sv"
`include "AXI/Slave/Slave_Write.sv"
`include "DRAM/DRAM_wrapper.sv"
`include "DRAM/Slave_Read_DRAM.sv"
`include "DRAM/Slave_Write_DRAM.sv"
`include "ROM/ROM_Wrapper.sv"
`include "ROM/Slave_Read_ROM.sv"
`include "SRAM/SRAM_wrapper.sv"
`include "CPU/CPU_wrapper.sv"
`include "CPU/CPU.sv"
`include "CPU/ALU.sv"
`include "CPU/Controller.sv"
`include "CPU/CSR.sv"
`include "CPU/Decoder.sv"
`include "CPU/Imm_Ext.sv"
`include "CPU/JB_Unit.sv"
`include "CPU/LD_Filter.sv"
`include "CPU/Mul.sv"
`include "CPU/Mux_3.sv"
`include "CPU/MUX_fordelay.sv"
`include "CPU/Mux.sv"
`include "CPU/Reg_EXE_MEM.sv"
`include "CPU/Reg_ID_EXE.sv"
`include "CPU/Reg_IF_ID.sv"
`include "CPU/Reg_MEM_WB.sv"
`include "CPU/Reg_PC.sv"
`include "CPU/RegFile.sv"
`include "CPU/wen_shift.sv"
`include "CPU/INTR_CONTROLLER.sv"
`include "CPU/Cache/data_array_wrapper.sv"
`include "CPU/Cache/tag_array_wrapper.sv"
`include "CPU/Cache/L1C_data.sv"
`include "CPU/Cache/L1C_inst.sv"

`include "SENSOR/sensor_ctrl.sv"
`include "SENSOR/Sensor_wrapper.sv"

`include "WDT/WDT.sv"
`include "WDT/WDT_Wrapper.sv"

//`include "CDC/synchronizer_1bit.sv"
//`include "CDC/synchronizer_1bit_3.sv"
`include "CDC/synchronizer_32bit_logic.sv"
`include "CDC/synchronizer_1bit_logic.sv"

`include "CDC/DFF.sv"
`include "CDC/DFF_1.sv"
// `include "CDC/DFF_2.sv"
`include "CDC/DFF_5.sv"

`include "CDC/AFIFO_CDC_1bit.sv"
`include "CDC/AFIFO_CDC_47bit.sv"
`include "CDC/AR_wrapper.sv"
`include "CDC/R_wrapper.sv"
`include "CDC/AW_wrapper.sv"
`include "CDC/W_wrapper.sv"
`include "CDC/B_wrapper.sv"

`include "CDC/FIFO_MEM_1bit.sv"
`include "CDC/FIFO_MEM_47bit.sv"

`include "CDC/rptr_empty.sv"
`include "CDC/wptr_full.sv"
`include "CDC/sync_r2w.sv"
`include "CDC/sync_w2r.sv"


module top(
  input  logic           cpu_clk,
  input  logic           axi_clk,
  input  logic           rom_clk,
  input  logic           dram_clk,
  input  logic           sram_clk,
  input  logic           cpu_rst,
  input  logic           axi_rst,
  input  logic           rom_rst,
  input  logic           dram_rst,
  input  logic           sram_rst,
  input  logic           sensor_ready,
  input  logic [   31:0] sensor_out,
  output logic           sensor_en,
  input  logic [   31:0] ROM_out,
  input  logic [   31:0] DRAM_Q,
  output logic           ROM_read,
  output logic           ROM_enable,
  output logic [   11:0] ROM_address,
  output logic           DRAM_CSn,
  output logic [    3:0] DRAM_WEn,
  output logic           DRAM_RASn,
  output logic           DRAM_CASn,
  output logic [   10:0] DRAM_A,
  output logic [   31:0] DRAM_D,
  input  logic           DRAM_valid
);



  
// ---------------------------------master--------------------------------- //
    // ---------master0------------ //
    // Read address channel signals
    logic    [`AXI_ID_BITS-1:0]      arid_m0;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    araddr_m0;    // Read address
    logic    [`AXI_LEN_BITS-1:0]     arlen_m0;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]    arsize_m0;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0]   arburst_m0;   // Read address burst type
    logic                        arvalid_m0;   // Read address valid
    logic                        arready_m0;   // Read address ready

    // Read data channel signals
    logic    [`AXI_ID_BITS-1:0]      rid_m0;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]    rdata_m0;     // Read data
    logic                        rlast_m0;     // Read last
    logic                        rvalid_m0;    // Read valid
    logic                        rready_m0;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]   rresp_m0;     // Read response

    // ----------master1---------- //
    // Write address channel signals
    logic    [`AXI_IDS_BITS-1:0]      awid_m1;      // Write address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    awaddr_m1;    // Write address
    logic    [`AXI_LEN_BITS-1:0]     awlen_m1;     // Write address burst length
    logic    [`AXI_SIZE_BITS-1:0]    awsize_m1;    // Write address burst size
    logic    [`AXI_BURST_BITS-1:0]   awburst_m1;   // Write address burst type
    logic                        awvalid_m1;   // Write address valid
    logic                        awready_m1;   // Write address ready

    // Write data channel signals
    logic    [`AXI_DATA_BITS-1:0]    wdata_m1;     // Write data
    logic    [`AXI_STRB_BITS-1:0]  wstrb_m1;     // Write strobe
    logic                        wlast_m1;     // Write last
    logic                        wvalid_m1;    // Write valid
    logic                        wready_m1;    // Write ready
    // Write response channel signals
    logic    [`AXI_IDS_BITS-1:0]      bid_m1;       // Write response ID tag
    logic    [`AXI_RESP_BITS-1:0]   bresp_m1;     // Write response
    logic                        bvalid_m1;    // Write response valid
    logic                        bready_m1;    // Write response ready
    // Read address channel signals
    logic    [`AXI_ID_BITS-1:0]      arid_m1;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    araddr_m1;    // Read address
    logic    [`AXI_LEN_BITS-1:0]     arlen_m1;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]    arsize_m1;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0]   arburst_m1;   // Read address burst type
    logic                        arvalid_m1;   // Read address valid
    logic                        arready_m1;   // Read address ready

    // Read data channel signals
    logic    [`AXI_ID_BITS-1:0]      rid_m1;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]    rdata_m1;     // Read data
    logic                        rlast_m1;     // Read last
    logic                        rvalid_m1;    // Read valid
    logic                        rready_m1;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]   rresp_m1;     // Read response


// ---------------------------------slave--------------------------------- //
    // ----------slave0---------- //
    // Read address channel signals
    logic    [`AXI_ID_BITS-1:0]      arid_s0;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    araddr_s0;    // Read address
    logic    [`AXI_LEN_BITS-1:0]     arlen_s0;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]    arsize_s0;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0]   arburst_s0;   // Read address burst type
    logic                        arvalid_s0;   // Read address valid
    logic                        arready_s0;   // Read address ready
    // Read data channel signals
    logic    [`AXI_ID_BITS-1:0]      rid_s0;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]    rdata_s0;     // Read data
    logic                       rlast_s0;     // Read last
    logic                       rvalid_s0;    // Read valid
    logic                        rready_s0;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]    rresp_s0;     // Read response

    // ----------slave1---------- //
    logic    [`AXI_IDS_BITS-1:0]      awid_s1;      // Write address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    awaddr_s1;    // Write address
    logic    [`AXI_LEN_BITS-1:0]     awlen_s1;     // Write address burst length
    logic    [`AXI_SIZE_BITS-1:0]    awsize_s1;    // Write address burst size
    logic    [`AXI_BURST_BITS-1:0]   awburst_s1;   // Write address burst type

    logic                        awvalid_s1;   // Write address valid
    logic                        awready_s1;   // Write address ready
    // Write data channel signals
    logic    [`AXI_DATA_BITS-1:0]    wdata_s1;     // Write data
    logic    [`AXI_STRB_BITS-1:0]  wstrb_s1;     // Write strobe
    logic                        wlast_s1;     // Write last
    logic                        wvalid_s1;    // Write valid
    logic                        wready_s1;    // Write ready
    // Write response channel signals
    logic    [`AXI_IDS_BITS-1:0]      bid_s1;       // Write response ID tag
    logic    [`AXI_RESP_BITS-1:0]    bresp_s1;     // Write response
    logic                        bvalid_s1;    // Write response valid
    logic                       bready_s1;    // Write response ready
    // Read address channel signals
    logic    [`AXI_ID_BITS-1:0]      arid_s1;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    araddr_s1;    // Read address
    logic    [`AXI_LEN_BITS-1:0]     arlen_s1;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]    arsize_s1;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0]   arburst_s1;   // Read address burst type
    logic                        arvalid_s1;   // Read address valid
    logic                        arready_s1;   // Read address ready
    // Read data channel signals
    logic    [`AXI_ID_BITS-1:0]      rid_s1;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]    rdata_s1;     // Read data
    logic                       rlast_s1;     // Read last
    logic                       rvalid_s1;    // Read valid
    logic                        rready_s1;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]    rresp_s1;     // Read response

    // ----------slave2---------- //
    logic    [`AXI_IDS_BITS-1:0]      awid_s2;      // Write address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    awaddr_s2;    // Write address
    logic    [`AXI_LEN_BITS-1:0]     awlen_s2;     // Write address burst length
    logic    [`AXI_SIZE_BITS-1:0]    awsize_s2;    // Write address burst size
    logic    [`AXI_BURST_BITS-1:0]   awburst_s2;   // Write address burst type

    logic                        awvalid_s2;   // Write address valid
    logic                        awready_s2;   // Write address ready
    // Write data channel signals
    logic    [`AXI_DATA_BITS-1:0]    wdata_s2;     // Write data
    logic    [`AXI_STRB_BITS-1:0]  wstrb_s2;     // Write strobe
    logic                        wlast_s2;     // Write last
    logic                        wvalid_s2;    // Write valid
    logic                        wready_s2;    // Write ready
    // Write response channel signals
    logic    [`AXI_IDS_BITS-1:0]      bid_s2;       // Write response ID tag
    logic    [`AXI_RESP_BITS-1:0]    bresp_s2;     // Write response
    logic                        bvalid_s2;    // Write response valid
    logic                       bready_s2;    // Write response ready
    // Read address channel signals
    logic    [`AXI_ID_BITS-1:0]      arid_s2;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    araddr_s2;    // Read address
    logic    [`AXI_LEN_BITS-1:0]     arlen_s2;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]    arsize_s2;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0]   arburst_s2;   // Read address burst type
    logic                        arvalid_s2;   // Read address valid
    logic                        arready_s2;   // Read address ready
    // Read data channel signals
    logic    [`AXI_ID_BITS-1:0]      rid_s2;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]    rdata_s2;     // Read data
    logic                       rlast_s2;     // Read last
    logic                       rvalid_s2;    // Read valid
    logic                        rready_s2;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]    rresp_s2;     // Read response

    // ----------slave3---------- //
    logic    [`AXI_IDS_BITS-1:0]   awid_s3;      // Write address ID tag
    logic    [`AXI_ADDR_BITS-1:0]  awaddr_s3;    // Write address
    logic    [`AXI_LEN_BITS-1:0]   awlen_s3;     // Write address burst length
    logic    [`AXI_SIZE_BITS-1:0]  awsize_s3;    // Write address burst size
    logic    [`AXI_BURST_BITS-1:0] awburst_s3;   // Write address burst type
    logic                          awvalid_s3;   // Write address valid
    logic                          awready_s3;   // Write address ready
    // Write data channel signals
    logic    [`AXI_DATA_BITS-1:0]  wdata_s3;     // Write data
    logic    [`AXI_STRB_BITS-1:0]  wstrb_s3;     // Write strobe
    logic                          wlast_s3;     // Write last
    logic                          wvalid_s3;    // Write valid
    logic                          wready_s3;    // Write ready
    // Write response channel signals
    logic    [`AXI_IDS_BITS-1:0]   bid_s3;       // Write response ID tag
    logic    [`AXI_RESP_BITS-1:0]  bresp_s3;     // Write response
    logic                          bvalid_s3;    // Write response valid
    logic                          bready_s3;    // Write response ready
    // Read address channel signals
    logic    [`AXI_ID_BITS-1:0]   arid_s3;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]  araddr_s3;    // Read address
    logic    [`AXI_LEN_BITS-1:0]   arlen_s3;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]  arsize_s3;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0] arburst_s3;   // Read address burst type
    logic                          arvalid_s3;   // Read address valid
    logic                          arready_s3;   // Read address ready
    // Read data channel signals
    logic    [`AXI_ID_BITS-1:0]   rid_s3;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]  rdata_s3;     // Read data
    logic                          rlast_s3;     // Read last
    logic                          rvalid_s3;    // Read valid
    logic                          rready_s3;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]  rresp_s3;     // Read response

    // ----------slave4---------- //
    logic    [`AXI_IDS_BITS-1:0]   awid_s4;      // Write address ID tag
    logic    [`AXI_ADDR_BITS-1:0]  awaddr_s4;    // Write address
    logic    [`AXI_LEN_BITS-1:0]   awlen_s4;     // Write address burst length
    logic    [`AXI_SIZE_BITS-1:0]  awsize_s4;    // Write address burst size
    logic    [`AXI_BURST_BITS-1:0] awburst_s4;   // Write address burst type
    logic                          awvalid_s4;   // Write address valid
    logic                          awready_s4;   // Write address ready
    // Write data channel signals
    logic    [`AXI_DATA_BITS-1:0]  wdata_s4;     // Write data
    logic    [`AXI_STRB_BITS-1:0]  wstrb_s4;     // Write strobe
    logic                          wlast_s4;     // Write last
    logic                          wvalid_s4;    // Write valid
    logic                          wready_s4;    // Write ready
    // Write response channel signals
    logic    [`AXI_IDS_BITS-1:0]   bid_s4;       // Write response ID tag
    logic    [`AXI_RESP_BITS-1:0]  bresp_s4;     // Write response
    logic                          bvalid_s4;    // Write response valid
    logic                          bready_s4;    // Write response ready
    // Read address channel signals
    logic    [`AXI_ID_BITS-1:0]   arid_s4;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]  araddr_s4;    // Read address
    logic    [`AXI_LEN_BITS-1:0]   arlen_s4;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]  arsize_s4;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0] arburst_s4;   // Read address burst type
    logic                          arvalid_s4;   // Read address valid
    logic                          arready_s4;   // Read address ready
    // Read data channel signals
    logic    [`AXI_ID_BITS-1:0]   rid_s4;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]  rdata_s4;     // Read data
    logic                          rlast_s4;     // Read last
    logic                          rvalid_s4;    // Read valid
    logic                          rready_s4;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]  rresp_s4;     // Read response

	
	// ----------slave4---------- //
    logic    [`AXI_IDS_BITS-1:0]      awid_s5;      // Write address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    awaddr_s5;    // Write address
    logic    [`AXI_LEN_BITS-1:0]     awlen_s5;     // Write address burst length
    logic    [`AXI_SIZE_BITS-1:0]    awsize_s5;    // Write address burst size
    logic    [`AXI_BURST_BITS-1:0]   awburst_s5;   // Write address burst type

    logic                        awvalid_s5;   // Write address valid
    logic                        awready_s5;   // Write address ready
    // Write data channel signals
    logic    [`AXI_DATA_BITS-1:0]    wdata_s5;     // Write data
    logic    [`AXI_STRB_BITS-1:0]  wstrb_s5;     // Write strobe
    logic                        wlast_s5;     // Write last
    logic                        wvalid_s5;    // Write valid
    logic                        wready_s5;    // Write ready
    // Write response channel signals
    logic    [`AXI_IDS_BITS-1:0]      bid_s5;       // Write response ID tag
    logic    [`AXI_RESP_BITS-1:0]    bresp_s5;     // Write response
    logic                        bvalid_s5;    // Write response valid
    logic                       bready_s5;    // Write response ready
    // Read address channel signals
    logic    [`AXI_ID_BITS-1:0]      arid_s5;      // Read address ID tag
    logic    [`AXI_ADDR_BITS-1:0]    araddr_s5;    // Read address
    logic    [`AXI_LEN_BITS-1:0]     arlen_s5;     // Read address burst length
    logic    [`AXI_SIZE_BITS-1:0]    arsize_s5;    // Read address burst size
    logic    [`AXI_BURST_BITS-1:0]   arburst_s5;   // Read address burst type
    logic                        arvalid_s5;   // Read address valid
    logic                        arready_s5;   // Read address ready
    // Read data channel signals
    logic    [`AXI_ID_BITS-1:0]      rid_s5;       // Read ID tag
    logic    [`AXI_DATA_BITS-1:0]    rdata_s5;     // Read data
    logic                       rlast_s5;     // Read last
    logic                       rvalid_s5;    // Read valid
    logic                        rready_s5;    // Read ready
    logic    [`AXI_RESP_BITS-1:0]    rresp_s5;     // Read response

    logic interrupt_e, interrupt_t;
    
    //for delay issue
    logic [31:0] sensor_out_reg;
    logic [31:0] ROM_out_reg;
    logic [31:0] DRAM_Q_reg;
    logic DRAM_valid_reg;
    logic sensor_ready_reg;
	logic counter_for_sensor_ready;
    always@(posedge cpu_clk)begin
        if(cpu_rst)begin
            sensor_out_reg<=32'b0;
            sensor_ready_reg<=1'b0;
			counter_for_sensor_ready<=1'b0;
        end
        else begin
			if(counter_for_sensor_ready==1'b1) begin
				counter_for_sensor_ready<=counter_for_sensor_ready;
				sensor_ready_reg<=sensor_ready;
			end
			else begin
				counter_for_sensor_ready<=counter_for_sensor_ready+1'b1;
				sensor_ready_reg<=1'b0;
			end
            sensor_out_reg<=sensor_out;
            
        end
    end
    always@(posedge rom_clk)begin
        if(rom_rst)begin
            ROM_out_reg<=32'b0;
        end
        else begin
            ROM_out_reg<=ROM_out;
        end
    end

    always@(posedge dram_clk)begin
        if(dram_rst)begin
            DRAM_Q_reg<=32'b0;
            DRAM_valid_reg<=1'b0;
        end
        else begin
            DRAM_Q_reg<=DRAM_Q;
            DRAM_valid_reg<=DRAM_valid;
        end
    end


    

// ---------------------------------PORT--------------------------------- //
    // CPU
    CPU_wrapper cpu(
        .clk(cpu_clk),
        .rst(cpu_rst),
        .clk2(axi_clk),
        .rst2(axi_rst),

        .AWID_M1(awid_m1),
        .AWADDR_M1(awaddr_m1),
        .AWLEN_M1(awlen_m1),
        .AWSIZE_M1(awsize_m1),
        .AWBURST_M1(awburst_m1),
        .AWVALID_M1(awvalid_m1),
        .AWREADY_M1(awready_m1),

        .WDATA_M1(wdata_m1),
        .WSTRB_M1(wstrb_m1),
        .WLAST_M1(wlast_m1),
        .WVALID_M1(wvalid_m1),
        .WREADY_M1(wready_m1),

        .BID_M1(bid_m1),
        .BRESP_M1(bresp_m1),
        .BVALID_M1(bvalid_m1),
        .BREADY_M1(bready_m1),

        .ARID_M0(arid_m0),
        .ARADDR_M0(araddr_m0),
        .ARLEN_M0(arlen_m0),
        .ARSIZE_M0(arsize_m0),
        .ARBURST_M0(arburst_m0),
        .ARVALID_M0(arvalid_m0),
        .ARREADY_M0(arready_m0),

        .RID_M0(rid_m0),
        .RDATA_M0(rdata_m0),
        .RRESP_M0(rresp_m0),
        .RLAST_M0(rlast_m0),
        .RVALID_M0(rvalid_m0),
        .RREADY_M0(rready_m0),

        .ARID_M1(arid_m1),
        .ARADDR_M1(araddr_m1),
        .ARLEN_M1(arlen_m1),
        .ARSIZE_M1(arsize_m1),
        .ARBURST_M1(arburst_m1),
        .ARVALID_M1(arvalid_m1),
        .ARREADY_M1(arready_m1),

        .RID_M1(rid_m1),
        .RDATA_M1(rdata_m1),
        .RRESP_M1(rresp_m1),
        .RLAST_M1(rlast_m1),
        .RVALID_M1(rvalid_m1),
        .RREADY_M1(rready_m1),

        .interrupt_e(interrupt_e),
        .interrupt_t(interrupt_t)
    );

    // Bridge
AXI axi_duv_bridge(
        .ACLK       (axi_clk ),
        .ARESETn    (~axi_rst ),
        // MASTER WRITE CHANNEL
	    // WRITE M1 (Data)
        .AWID_M1    (awid_m1   ),
        .AWADDR_M1  (awaddr_m1 ),
        .AWLEN_M1   (awlen_m1  ),
        .AWSIZE_M1  (awsize_m1 ),
        .AWBURST_M1 (awburst_m1),
        .AWVALID_M1 (awvalid_m1),
        .AWREADY_M1 (awready_m1),
        .WDATA_M1   (wdata_m1  ),
        .WSTRB_M1   (wstrb_m1  ),
        .WLAST_M1   (wlast_m1  ),
        .WVALID_M1  (wvalid_m1 ),
        .WREADY_M1  (wready_m1 ),
        .BID_M1     (bid_m1    ),
        .BRESP_M1   (bresp_m1  ),
        .BVALID_M1  (bvalid_m1 ),
        .BREADY_M1  (bready_m1 ),
        // MASTER READ CHANNEL
	    // READ M0 (Instruction)
        .ARID_M0    (arid_m0   ),
        .ARADDR_M0  (araddr_m0 ),
        .ARLEN_M0   (arlen_m0  ),
        .ARSIZE_M0  (arsize_m0 ),
        .ARBURST_M0 (arburst_m0),
        .ARVALID_M0 (arvalid_m0),
        .ARREADY_M0 (arready_m0),
        .RID_M0     (rid_m0    ),
        .RDATA_M0   (rdata_m0  ),
        .RRESP_M0   (rresp_m0  ),
        .RLAST_M0   (rlast_m0  ),
        .RVALID_M0  (rvalid_m0 ),
        .RREADY_M0  (rready_m0 ),
        // READ M1 (Data)
        .ARID_M1    (arid_m1   ),
        .ARADDR_M1  (araddr_m1 ),
        .ARLEN_M1   (arlen_m1  ),
        .ARSIZE_M1  (arsize_m1 ),
        .ARBURST_M1 (arburst_m1),
        .ARVALID_M1 (arvalid_m1),
        .ARREADY_M1 (arready_m1),
        .RID_M1     (rid_m1    ),
        .RDATA_M1   (rdata_m1  ),
        .RRESP_M1   (rresp_m1  ),
        .RLAST_M1   (rlast_m1  ),
        .RVALID_M1  (rvalid_m1 ),
        .RREADY_M1  (rready_m1 ),
        // SLAVE WRITE CHANNEL

        // WRITE S1 (IM SRAM)
        .AWID_S1    (awid_s1   ),
        .AWADDR_S1  (awaddr_s1 ),
        .AWLEN_S1   (awlen_s1  ),
        .AWSIZE_S1  (awsize_s1 ),
        .AWBURST_S1 (awburst_s1),
        .AWVALID_S1 (awvalid_s1),
        .AWREADY_S1 (awready_s1),
        .WDATA_S1   (wdata_s1  ),
        .WSTRB_S1   (wstrb_s1  ),
        .WLAST_S1   (wlast_s1  ),
        .WVALID_S1  (wvalid_s1 ),
        .WREADY_S1  (wready_s1 ),
        .BID_S1     (bid_s1    ),
        .BRESP_S1   (bresp_s1  ),
        .BVALID_S1  (bvalid_s1 ),
        .BREADY_S1  (bready_s1 ),
        // WRITE S2 (DM SRAM)
        .AWID_S2    (awid_s2   ),
        .AWADDR_S2  (awaddr_s2 ),
        .AWLEN_S2   (awlen_s2  ),
        .AWSIZE_S2  (awsize_s2 ),
        .AWBURST_S2 (awburst_s2),
        .AWVALID_S2 (awvalid_s2),
        .AWREADY_S2 (awready_s2),
        .WDATA_S2   (wdata_s2  ),
        .WSTRB_S2   (wstrb_s2  ),
        .WLAST_S2   (wlast_s2  ),
        .WVALID_S2  (wvalid_s2 ),
        .WREADY_S2  (wready_s2 ),
        .BID_S2     (bid_s2    ),
        .BRESP_S2   (bresp_s2  ),
        .BVALID_S2  (bvalid_s2 ),
        .BREADY_S2  (bready_s2 ),
		
		// WRITE S3 (Sensor)
        .AWID_S3    (awid_s3   ),
        .AWADDR_S3  (awaddr_s3 ),
        .AWLEN_S3   (awlen_s3  ),
        .AWSIZE_S3  (awsize_s3 ),
        .AWBURST_S3 (awburst_s3),
        .AWVALID_S3 (awvalid_s3),
        .AWREADY_S3 (awready_s3),
        .WDATA_S3   (wdata_s3  ),
        .WSTRB_S3   (wstrb_s3  ),
        .WLAST_S3   (wlast_s3  ),
        .WVALID_S3  (wvalid_s3 ),
        .WREADY_S3  (wready_s3 ),
        .BID_S3     (bid_s3    ),
        .BRESP_S3   (bresp_s3  ),
        .BVALID_S3  (bvalid_s3 ),
        .BREADY_S3  (bready_s3 ),

        // WRITE S4(WDT)
        .AWID_S4    (awid_s4   ),
        .AWADDR_S4  (awaddr_s4 ),
        .AWLEN_S4   (awlen_s4  ),
        .AWSIZE_S4  (awsize_s4 ),
        .AWBURST_S4 (awburst_s4),
        .AWVALID_S4 (awvalid_s4),
        .AWREADY_S4 (awready_s4),
        .WDATA_S4   (wdata_s4  ),
        .WSTRB_S4   (wstrb_s4  ),
        .WLAST_S4   (wlast_s4  ),
        .WVALID_S4  (wvalid_s4 ),
        .WREADY_S4  (wready_s4 ),
        .BID_S4     (bid_s4    ),
        .BRESP_S4   (bresp_s4  ),
        .BVALID_S4  (bvalid_s4 ),
        .BREADY_S4  (bready_s4 ),

        // WRITE S5 (DRAM)
        .AWID_S5    (awid_s5   ),
        .AWADDR_S5  (awaddr_s5 ),
        .AWLEN_S5   (awlen_s5  ),
        .AWSIZE_S5  (awsize_s5 ),
        .AWBURST_S5 (awburst_s5),
        .AWVALID_S5 (awvalid_s5),
        .AWREADY_S5 (awready_s5),
        .WDATA_S5   (wdata_s5  ),
        .WSTRB_S5   (wstrb_s5  ),
        .WLAST_S5   (wlast_s5  ),
        .WVALID_S5  (wvalid_s5 ),
        .WREADY_S5  (wready_s5 ),
        .BID_S5     (bid_s5    ),
        .BRESP_S5   (bresp_s5  ),
        .BVALID_S5  (bvalid_s5 ),
        .BREADY_S5  (bready_s5 ),
        // SLAVE READ CHANNEL
        // READ S0 (ROM)
        .ARID_S0    (arid_s0   ),
        .ARADDR_S0  (araddr_s0 ),
        .ARLEN_S0   (arlen_s0  ),
        .ARSIZE_S0  (arsize_s0 ),
        .ARBURST_S0 (arburst_s0),
        .ARVALID_S0 (arvalid_s0),
        .ARREADY_S0 (arready_s0),
        .RID_S0     (rid_s0    ),
        .RDATA_S0   (rdata_s0  ),
        .RRESP_S0   (rresp_s0  ),
        .RLAST_S0   (rlast_s0  ),
        .RVALID_S0  (rvalid_s0 ),
        .RREADY_S0  (rready_s0 ),
        // READ S1 (IM SRAM)
        .ARID_S1    (arid_s1   ),
        .ARADDR_S1  (araddr_s1 ),
        .ARLEN_S1   (arlen_s1  ),
        .ARSIZE_S1  (arsize_s1 ),
        .ARBURST_S1 (arburst_s1),
        .ARVALID_S1 (arvalid_s1),
        .ARREADY_S1 (arready_s1),
        .RID_S1     (rid_s1    ),
        .RDATA_S1   (rdata_s1  ),
        .RRESP_S1   (rresp_s1  ),
        .RLAST_S1   (rlast_s1  ),
        .RVALID_S1  (rvalid_s1 ),
        .RREADY_S1  (rready_s1 ),
        // READ S2 (DM SRAM)
        .ARID_S2    (arid_s2   ),
        .ARADDR_S2  (araddr_s2 ),
        .ARLEN_S2   (arlen_s2  ),
        .ARSIZE_S2  (arsize_s2 ),
        .ARBURST_S2 (arburst_s2),
        .ARVALID_S2 (arvalid_s2),
        .ARREADY_S2 (arready_s2),
        .RID_S2     (rid_s2    ),
        .RDATA_S2   (rdata_s2  ),
        .RRESP_S2   (rresp_s2  ),
        .RLAST_S2   (rlast_s2  ),
        .RVALID_S2  (rvalid_s2 ),
        .RREADY_S2  (rready_s2 ),

		// READ S3 (Sensor)
        .ARID_S3    (arid_s3   ),
        .ARADDR_S3  (araddr_s3 ),
        .ARLEN_S3   (arlen_s3  ),
        .ARSIZE_S3  (arsize_s3 ),
        .ARBURST_S3 (arburst_s3),
        .ARVALID_S3 (arvalid_s3),
        .ARREADY_S3 (arready_s3),
        .RID_S3     (rid_s3    ),
        .RDATA_S3   (rdata_s3  ),
        .RRESP_S3   (rresp_s3  ),
        .RLAST_S3   (rlast_s3  ),
        .RVALID_S3  (rvalid_s3 ),
        .RREADY_S3  (rready_s3 ),

        // READ S4 (WDT)
        .ARID_S4    (arid_s4   ),
        .ARADDR_S4  (araddr_s4 ),
        .ARLEN_S4   (arlen_s4  ),
        .ARSIZE_S4  (arsize_s4 ),
        .ARBURST_S4 (arburst_s4),
        .ARVALID_S4 (arvalid_s4),
        .ARREADY_S4 (arready_s4),
        .RID_S4     (rid_s4    ),
        .RDATA_S4   (rdata_s4  ),
        .RRESP_S4   (rresp_s4  ),
        .RLAST_S4   (rlast_s4  ),
        .RVALID_S4  (rvalid_s4 ),
        .RREADY_S4  (rready_s4 ),
		
        // READ S5 (DRAM)
        .ARID_S5    (arid_s5   ),
        .ARADDR_S5  (araddr_s5 ),
        .ARLEN_S5   (arlen_s5  ),
        .ARSIZE_S5  (arsize_s5 ),
        .ARBURST_S5 (arburst_s5),
        .ARVALID_S5 (arvalid_s5),
        .ARREADY_S5 (arready_s5),
        .RID_S5     (rid_s5    ),
        .RDATA_S5   (rdata_s5  ),
        .RRESP_S5   (rresp_s5  ),
        .RLAST_S5   (rlast_s5  ),
        .RVALID_S5  (rvalid_s5 ),
        .RREADY_S5  (rready_s5 )
	);

    //ROM
    ROM_Wrapper ROM(
        .clock  (axi_clk),
        .reset  (~axi_rst),
        .clock2  (rom_clk),
        .reset2  (~rom_rst),
            // READ ADDRESS
        .ARID   (arid_s0),
        .ARADDR (araddr_s0),
        .ARLEN  (arlen_s0),
        .ARSIZE (arsize_s0),
        .ARBURST(arburst_s0),
        .ARVALID(arvalid_s0),
        .ARREADY(arready_s0),
        // READ DATA
        .RID    (rid_s0),
        .RDATA  (rdata_s0),
        .RRESP  (rresp_s0),
        .RLAST  (rlast_s0),
        .RVALID (rvalid_s0),
        .RREADY (rready_s0),
        // ROM
        .DO(ROM_out_reg),
        .CS(ROM_enable),
        .OE(ROM_read),
        .A (ROM_address)
    );

    // IM1
    SRAM_wrapper IM1(
        .ACLK  (axi_clk),
        .ARESETn  (axi_rst),
        .ACLK2  (sram_clk),
        .ARESETn2  (sram_rst),
            // READ ADDRESS
        .ARID   (arid_s1),
        .ARADDR (araddr_s1),
        .ARLEN  (arlen_s1),
        .ARSIZE (arsize_s1),
        .ARBURST(arburst_s1),
        .ARVALID(arvalid_s1),
        .ARREADY(arready_s1),
        // READ DATA
        .RID    (rid_s1),
        .RDATA  (rdata_s1),
        .RRESP  (rresp_s1),
        .RLAST  (rlast_s1),
        .RVALID (rvalid_s1),
        .RREADY (rready_s1),
            // WRITE ADDRESS
        .AWID   (awid_s1),
        .AWADDR (awaddr_s1),
        .AWLEN  (awlen_s1),
        .AWSIZE (awsize_s1),
        .AWBURST(awburst_s1),
        .AWVALID(awvalid_s1),
        .AWREADY(awready_s1),
        // WRITE DATA
        .WDATA  (wdata_s1),
        .WSTRB  (wstrb_s1),
        .WLAST  (wlast_s1),
        .WVALID (wvalid_s1),
        .WREADY (wready_s1),
        // WRITE RESPONSEcomplete
        .BID    (bid_s1),
        .BRESP  (bresp_s1),
        .BVALID (bvalid_s1),
        .BREADY (bready_s1)
    );

    // DM1
    SRAM_wrapper DM1(
        .ACLK  (axi_clk),
        .ARESETn  (axi_rst),
        .ACLK2  (sram_clk),
        .ARESETn2  (sram_rst),
            // READ ADDRESS
        .ARID   (arid_s2),
        .ARADDR (araddr_s2),
        .ARLEN  (arlen_s2),
        .ARSIZE (arsize_s2),
        .ARBURST(arburst_s2),
        .ARVALID(arvalid_s2),
        .ARREADY(arready_s2),
        // READ DATA
        .RID    (rid_s2),
        .RDATA  (rdata_s2),
        .RRESP  (rresp_s2),
        .RLAST  (rlast_s2),
        .RVALID (rvalid_s2),
        .RREADY (rready_s2),
            // WRITE ADDRESS
        .AWID   (awid_s2),
        .AWADDR (awaddr_s2),
        .AWLEN  (awlen_s2),
        .AWSIZE (awsize_s2),
        .AWBURST(awburst_s2),
        .AWVALID(awvalid_s2),
        .AWREADY(awready_s2),
        // WRITE DATA
        .WDATA  (wdata_s2),
        .WSTRB  (wstrb_s2),
        .WLAST  (wlast_s2),
        .WVALID (wvalid_s2),
        .WREADY (wready_s2),
        // WRITE RESPONSE
        .BID    (bid_s2),
        .BRESP  (bresp_s2),
        .BVALID (bvalid_s2),
        .BREADY (bready_s2)
    );
	
	
	Sensor_wrapper SENSOR
    (
        .clock  (axi_clk),
        .reset  (axi_rst),
        .clock2 (cpu_clk),
        .reset2 (cpu_rst),
        // READ ADDRESS
        .ARID   (arid_s3),
        .ARADDR (araddr_s3),
        .ARLEN  (arlen_s3),
        .ARSIZE (arsize_s3),
        .ARBURST(arburst_s3),
        .ARVALID(arvalid_s3),
        .ARREADY(arready_s3),
        // READ DATA
        .RID    (rid_s3),
        .RDATA  (rdata_s3),
        .RRESP  (rresp_s3),
        .RLAST  (rlast_s3),
        .RVALID (rvalid_s3),
        .RREADY (rready_s3),
        // WRITE ADDRESS
        .AWID   (awid_s3),
        .AWADDR (awaddr_s3),
        .AWLEN  (awlen_s3),
        .AWSIZE (awsize_s3),
        .AWBURST(awburst_s3),
        .AWVALID(awvalid_s3),
        .AWREADY(awready_s3),
        // WRITE DATA
        .WDATA  (wdata_s3),
        .WSTRB  (wstrb_s3),
        .WLAST  (wlast_s3),
        .WVALID (wvalid_s3),
        .WREADY (wready_s3),
        // WRITE RESPONSE
        .BID    (bid_s3),
        .BRESP  (bresp_s3),
        .BVALID (bvalid_s3),
        .BREADY (bready_s3),
        // Sensor
        // Sensor inputs
        .sensor_ready(sensor_ready_reg),
        .sensor_out  (sensor_out_reg),
        // Sensor outputs
        .sensor_en   (sensor_en),
        // Core outputs
        .sctrl_interrupt(interrupt_e)
    );

    //WDT
   	WDT_Wrapper WDT
    (
        .clock  (axi_clk),
        .reset  (axi_rst),
        .clock2 (cpu_clk),
        .reset2  (cpu_rst),
        // READ ADDRESS
        .ARID   (arid_s4),
        .ARADDR (araddr_s4),
        .ARLEN  (arlen_s4),
        .ARSIZE (arsize_s4),
        .ARBURST(arburst_s4),
        .ARVALID(arvalid_s4),
        .ARREADY(arready_s4),
        // READ DATA
        .RID    (rid_s4),
        .RDATA  (rdata_s4),
        .RRESP  (rresp_s4),
        .RLAST  (rlast_s4),
        .RVALID (rvalid_s4),
        .RREADY (rready_s4),
        // WRITE ADDRESS
        .AWID   (awid_s4),
        .AWADDR (awaddr_s4),
        .AWLEN  (awlen_s4),
        .AWSIZE (awsize_s4),
        .AWBURST(awburst_s4),
        .AWVALID(awvalid_s4),
        .AWREADY(awready_s4),
        // WRITE DATA
        .WDATA  (wdata_s4),
        .WSTRB  (wstrb_s4),
        .WLAST  (wlast_s4),
        .WVALID (wvalid_s4),
        .WREADY (wready_s4),
        // WRITE RESPONSE
        .BID    (bid_s4),
        .BRESP  (bresp_s4),
        .BVALID (bvalid_s4),
        .BREADY (bready_s4),
        
        .interrupt_t(interrupt_t)
    );
	
    // DRAM
    DRAM_wrapper DRAM(
        .clock  (axi_clk),
        .reset  (~axi_rst),
        .clock2  (dram_clk),
        .reset2  (~dram_rst),
        // READ ADDRESS
        .ARID   (arid_s5),
        .ARADDR (araddr_s5),
        .ARLEN  (arlen_s5),
        .ARSIZE (arsize_s5),
        .ARBURST(arburst_s5),
        .ARVALID(arvalid_s5),
        .ARREADY(arready_s5),
        // READ DATA
        .RID    (rid_s5),
        .RDATA  (rdata_s5),
        .RRESP  (rresp_s5),
        .RLAST  (rlast_s5),
        .RVALID (rvalid_s5),
        .RREADY (rready_s5),
        // WRITE ADDRESS
        .AWID   (awid_s5),
        .AWADDR (awaddr_s5),
        .AWLEN  (awlen_s5),
        .AWSIZE (awsize_s5),
        .AWBURST(awburst_s5),
        .AWVALID(awvalid_s5),
        .AWREADY(awready_s5),
        // WRITE DATA
        .WDATA  (wdata_s5),
        .WSTRB  (wstrb_s5),
        .WLAST  (wlast_s5),
        .WVALID (wvalid_s5),
        .WREADY (wready_s5),
        // WRITE RESPONSE
        .BID    (bid_s5),
        .BRESP  (bresp_s5),
        .BVALID (bvalid_s5),
        .BREADY (bready_s5),
        // DRAM
        .CS   (DRAM_CSn),
        .RAS  (DRAM_RASn),
        .CAS  (DRAM_CASn),
        .WEB  (DRAM_WEn),
        .A    (DRAM_A),
        .DI   (DRAM_D),
        .DO   (DRAM_Q_reg),
        .valid(DRAM_valid_reg)
    );
	
	

    
endmodule
