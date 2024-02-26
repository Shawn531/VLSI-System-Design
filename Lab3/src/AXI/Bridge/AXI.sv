//================================================
// Auther:      Chen Zhi-Yu (Willy)           
// Filename:    AXI.sv                            
// Description: Top module of AXI                  
// Version:     1.0 
//================================================
// 2023/11/15 2:28 : Added S3 (sensor)
// 2023/11/16 19:25 : Added S4 (WDT)
`include "AXI_define.svh"
// `include "Bridge_Read.sv"
// `include "Bridge_Write.sv"
module AXI(

	input ACLK,
	input ARESETn,

// ======= SLAVE INTERFACE FOR MASTERS =======

	// MASTER WRITE CHANNEL
	// WRITE ADDRESS M1 (Data)
	input [`AXI_ID_BITS-1:0] AWID_M1,
	input [`AXI_ADDR_BITS-1:0] AWADDR_M1,
	input [`AXI_LEN_BITS-1:0] AWLEN_M1,
	input [`AXI_SIZE_BITS-1:0] AWSIZE_M1,
	input [1:0] AWBURST_M1,
	input AWVALID_M1,
	output AWREADY_M1,
	// WRITE DATA M1 (Data)
	input [`AXI_DATA_BITS-1:0] WDATA_M1,
	input [`AXI_STRB_BITS-1:0] WSTRB_M1,
	input WLAST_M1,
	input WVALID_M1,
	output WREADY_M1,
	// WRITE RESPONSE M1 (Data)
	output [`AXI_ID_BITS-1:0] BID_M1,
	output [1:0] BRESP_M1,
	output BVALID_M1,
	input BREADY_M1,

	// MASTER READ CHANNEL
	// READ ADDRESS M0 (Instruction)
	input [`AXI_ID_BITS-1:0] ARID_M0,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M0,
	input [`AXI_LEN_BITS-1:0] ARLEN_M0,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M0,
	input [1:0] ARBURST_M0,
	input ARVALID_M0,
	output ARREADY_M0,
	// READ DATA M0 (Instruction)
	output [`AXI_ID_BITS-1:0] RID_M0,
	output [`AXI_DATA_BITS-1:0] RDATA_M0,
	output [1:0] RRESP_M0,
	output RLAST_M0,
	output RVALID_M0,
	input RREADY_M0,

	// READ ADDRESS M1 (Data)
	input [`AXI_ID_BITS-1:0] ARID_M1,
	input [`AXI_ADDR_BITS-1:0] ARADDR_M1,
	input [`AXI_LEN_BITS-1:0] ARLEN_M1,
	input [`AXI_SIZE_BITS-1:0] ARSIZE_M1,
	input [1:0] ARBURST_M1,
	input ARVALID_M1,
	output ARREADY_M1,
	// READ DATA M1 (Data)
	output [`AXI_ID_BITS-1:0] RID_M1,
	output [`AXI_DATA_BITS-1:0] RDATA_M1,
	output [1:0] RRESP_M1,
	output RLAST_M1,
	output RVALID_M1,
	input RREADY_M1,

// ======= MASTER INTERFACE FOR SLAVES =======

	// SLAVE WRITE CHANNEL
	
	// WRITE ADDRESS S1 (IM SRAM)
	output [`AXI_IDS_BITS-1:0] AWID_S1,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S1,
	output [`AXI_LEN_BITS-1:0] AWLEN_S1,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S1,
	output [1:0] AWBURST_S1,
	output AWVALID_S1,
	input AWREADY_S1,
	// WRITE DATA S1 (IM SRAM)
	output [`AXI_DATA_BITS-1:0] WDATA_S1,
	output [`AXI_STRB_BITS-1:0] WSTRB_S1,
	output WLAST_S1,
	output WVALID_S1,
	input WREADY_S1,
	// WRITE RESPONSE S1 (IM SRAM)
	input [`AXI_IDS_BITS-1:0] BID_S1,
	input [1:0] BRESP_S1,
	input BVALID_S1,
	output BREADY_S1,

	// WRITE ADDRESS S2 (DM SRAM)
	output [`AXI_IDS_BITS-1:0] AWID_S2,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S2,
	output [`AXI_LEN_BITS-1:0] AWLEN_S2,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S2,
	output [1:0] AWBURST_S2,
	output AWVALID_S2,
	input AWREADY_S2,
	// WRITE DATA S2 (DM SRAM)
	output [`AXI_DATA_BITS-1:0] WDATA_S2,
	output [`AXI_STRB_BITS-1:0] WSTRB_S2,
	output WLAST_S2,
	output WVALID_S2,
	input WREADY_S2,
	// WRITE RESPONSE S2 (DM SRAM)
	input [`AXI_IDS_BITS-1:0] BID_S2,
	input [1:0] BRESP_S2,
	input BVALID_S2,
	output BREADY_S2,
	
	// WRITE ADDRESS S3 (Sensor)
	output [`AXI_IDS_BITS-1:0] AWID_S3,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S3,
	output [`AXI_LEN_BITS-1:0] AWLEN_S3,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S3,
	output [1:0] AWBURST_S3,
	output AWVALID_S3,
	input AWREADY_S3,
	// WRITE DATA S3 (Sensor)
	output [`AXI_DATA_BITS-1:0] WDATA_S3,
	output [`AXI_STRB_BITS-1:0] WSTRB_S3,
	output WLAST_S3,
	output WVALID_S3,
	input WREADY_S3,
	// WRITE RESPONSE S3 (Sensor)
	input [`AXI_IDS_BITS-1:0] BID_S3,
	input [1:0] BRESP_S3,
	input BVALID_S3,
	output BREADY_S3,

	// WRITE ADDRESS S4 (WDT)
	output [`AXI_IDS_BITS-1:0] AWID_S4,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S4,
	output [`AXI_LEN_BITS-1:0] AWLEN_S4,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S4,
	output [1:0] AWBURST_S4,
	output AWVALID_S4,
	input AWREADY_S4,
	// WRITE DATA S4 (WDT)
	output [`AXI_DATA_BITS-1:0] WDATA_S4,
	output [`AXI_STRB_BITS-1:0] WSTRB_S4,
	output WLAST_S4,
	output WVALID_S4,
	input WREADY_S4,
	// WRITE RESPONSE S4 (WDT)
	input [`AXI_IDS_BITS-1:0] BID_S4,
	input [1:0] BRESP_S4,
	input BVALID_S4,
	output BREADY_S4,

	// WRITE ADDRESS S5 (DRAM)
	output [`AXI_IDS_BITS-1:0] AWID_S5,
	output [`AXI_ADDR_BITS-1:0] AWADDR_S5,
	output [`AXI_LEN_BITS-1:0] AWLEN_S5,
	output [`AXI_SIZE_BITS-1:0] AWSIZE_S5,
	output [1:0] AWBURST_S5,
	output AWVALID_S5,
	input AWREADY_S5,
	// WRITE DATA S5 (DRAM)
	output [`AXI_DATA_BITS-1:0] WDATA_S5,
	output [`AXI_STRB_BITS-1:0] WSTRB_S5,
	output WLAST_S5,
	output WVALID_S5,
	input WREADY_S5,
	// WRITE RESPONSE S5 (DRAM)
	input [`AXI_IDS_BITS-1:0] BID_S5,
	input [1:0] BRESP_S5,
	input BVALID_S5,
	output BREADY_S5,
	
	// SLAVE READ CHANNEL

	// READ ADDRESS S0 (ROM)
	output [`AXI_IDS_BITS-1:0] ARID_S0,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S0,
	output [`AXI_LEN_BITS-1:0] ARLEN_S0,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S0,
	output [1:0] ARBURST_S0,
	output ARVALID_S0,
	input ARREADY_S0,
	// READ DATA S0 (ROM)
	input [`AXI_IDS_BITS-1:0] RID_S0,
	input [`AXI_DATA_BITS-1:0] RDATA_S0,
	input [1:0] RRESP_S0,
	input RLAST_S0,
	input RVALID_S0,
	output RREADY_S0,

	// READ ADDRESS S1 (IM SRAM)
	output [`AXI_IDS_BITS-1:0] ARID_S1,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S1,
	output [`AXI_LEN_BITS-1:0] ARLEN_S1,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S1,
	output [1:0] ARBURST_S1,
	output ARVALID_S1,
	input ARREADY_S1,
	// READ DATA S1 (IM SRAM)
	input [`AXI_IDS_BITS-1:0] RID_S1,
	input [`AXI_DATA_BITS-1:0] RDATA_S1,
	input [1:0] RRESP_S1,
	input RLAST_S1,
	input RVALID_S1,
	output RREADY_S1,
	
	// READ ADDRESS S2 (DM SRAM)
	output [`AXI_IDS_BITS-1:0] ARID_S2,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S2,
	output [`AXI_LEN_BITS-1:0] ARLEN_S2,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S2,
	output [1:0] ARBURST_S2,
	output ARVALID_S2,
	input ARREADY_S2,
	// READ DATA S2 (DM SRAM)
	input [`AXI_IDS_BITS-1:0] RID_S2,
	input [`AXI_DATA_BITS-1:0] RDATA_S2,
	input [1:0] RRESP_S2,
	input RLAST_S2,
	input RVALID_S2,
	output RREADY_S2,
	
	// READ ADDRESS S3 (Sensor)
	output [`AXI_IDS_BITS-1:0] ARID_S3,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S3,
	output [`AXI_LEN_BITS-1:0] ARLEN_S3,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S3,
	output [1:0] ARBURST_S3,
	output ARVALID_S3,
	input ARREADY_S3,
	// READ DATA S3 (Sensor)
	input [`AXI_IDS_BITS-1:0] RID_S3,
	input [`AXI_DATA_BITS-1:0] RDATA_S3,
	input [1:0] RRESP_S3,
	input RLAST_S3,
	input RVALID_S3,
	output RREADY_S3,

	// READ ADDRESS S4 (WDT)
	output [`AXI_IDS_BITS-1:0] ARID_S4,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S4,
	output [`AXI_LEN_BITS-1:0] ARLEN_S4,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S4,
	output [1:0] ARBURST_S4,
	output ARVALID_S4,
	input ARREADY_S4,
	// READ DATA S4 (WDT)
	input [`AXI_IDS_BITS-1:0] RID_S4,
	input [`AXI_DATA_BITS-1:0] RDATA_S4,
	input [1:0] RRESP_S4,
	input RLAST_S4,
	input RVALID_S4,
	output RREADY_S4,


	// READ ADDRESS S5 (DRAM)
	output [`AXI_IDS_BITS-1:0] ARID_S5,
	output [`AXI_ADDR_BITS-1:0] ARADDR_S5,
	output [`AXI_LEN_BITS-1:0] ARLEN_S5,
	output [`AXI_SIZE_BITS-1:0] ARSIZE_S5,
	output [1:0] ARBURST_S5,
	output ARVALID_S5,
	input ARREADY_S5,
	// READ DATA S5 (DRAM)
	input [`AXI_IDS_BITS-1:0] RID_S5,
	input [`AXI_DATA_BITS-1:0] RDATA_S5,
	input [1:0] RRESP_S5,
	input RLAST_S5,
	input RVALID_S5,
	output RREADY_S5
);
    //---------- you should put your design here ----------//
Bridge_Write BW(.ACLK(ACLK), 
				.ARESETn(ARESETn),

				.AWID_M1(AWID_M1), 
				.AWADDR_M1(AWADDR_M1), .AWLEN_M1(AWLEN_M1), .AWSIZE_M1(AWSIZE_M1),
				.AWBURST_M1(AWBURST_M1), .AWVALID_M1(AWVALID_M1), .AWREADY_M1(AWREADY_M1),
				
				.WDATA_M1(WDATA_M1), .WSTRB_M1(WSTRB_M1), .WLAST_M1(WLAST_M1), .WVALID_M1(WVALID_M1), .WREADY_M1(WREADY_M1),

				.BID_M1(BID_M1), .BRESP_M1(BRESP_M1), .BVALID_M1(BVALID_M1), .BREADY_M1(BREADY_M1),

				.AWID_S1(AWID_S1), .AWADDR_S1(AWADDR_S1), .AWLEN_S1(AWLEN_S1), .AWSIZE_S1(AWSIZE_S1), 
				.AWBURST_S1(AWBURST_S1), .AWVALID_S1(AWVALID_S1), .AWREADY_S1(AWREADY_S1),

				.WDATA_S1(WDATA_S1), .WSTRB_S1(WSTRB_S1), .WLAST_S1(WLAST_S1), .WVALID_S1(WVALID_S1), .WREADY_S1(WREADY_S1),

				.BID_S1(BID_S1), .BRESP_S1(BRESP_S1), .BVALID_S1(BVALID_S1), .BREADY_S1(BREADY_S1),
				//
				.AWID_S2(AWID_S2), .AWADDR_S2(AWADDR_S2), .AWLEN_S2(AWLEN_S2), .AWSIZE_S2(AWSIZE_S2), 
				.AWBURST_S2(AWBURST_S2), .AWVALID_S2(AWVALID_S2), .AWREADY_S2(AWREADY_S2),

				.WDATA_S2(WDATA_S2), .WSTRB_S2(WSTRB_S2), .WLAST_S2(WLAST_S2), .WVALID_S2(WVALID_S2), .WREADY_S2(WREADY_S2),

				.BID_S2(BID_S2), .BRESP_S2(BRESP_S2), .BVALID_S2(BVALID_S2), .BREADY_S2(BREADY_S2),
				//
				.AWID_S3(AWID_S3), .AWADDR_S3(AWADDR_S3), .AWLEN_S3(AWLEN_S3), .AWSIZE_S3(AWSIZE_S3), 
				.AWBURST_S3(AWBURST_S3), .AWVALID_S3(AWVALID_S3), .AWREADY_S3(AWREADY_S3),

				.WDATA_S3(WDATA_S3), .WSTRB_S3(WSTRB_S3), .WLAST_S3(WLAST_S3), .WVALID_S3(WVALID_S3), .WREADY_S3(WREADY_S3),

				.BID_S3(BID_S3), .BRESP_S3(BRESP_S3), .BVALID_S3(BVALID_S3), .BREADY_S3(BREADY_S3),
				//
				.AWID_S4(AWID_S4), .AWADDR_S4(AWADDR_S4), .AWLEN_S4(AWLEN_S4), .AWSIZE_S4(AWSIZE_S4), 
				.AWBURST_S4(AWBURST_S4), .AWVALID_S4(AWVALID_S4), .AWREADY_S4(AWREADY_S4),

				.WDATA_S4(WDATA_S4), .WSTRB_S4(WSTRB_S4), .WLAST_S4(WLAST_S4), .WVALID_S4(WVALID_S4), .WREADY_S4(WREADY_S4),

				.BID_S4(BID_S4), .BRESP_S4(BRESP_S4), .BVALID_S4(BVALID_S4), .BREADY_S4(BREADY_S4),
				//
				.AWID_S5(AWID_S5), .AWADDR_S5(AWADDR_S5), .AWLEN_S5(AWLEN_S5), .AWSIZE_S5(AWSIZE_S5), 
				.AWBURST_S5(AWBURST_S5), .AWVALID_S5(AWVALID_S5), .AWREADY_S5(AWREADY_S5),

				.WDATA_S5(WDATA_S5), .WSTRB_S5(WSTRB_S5), .WLAST_S5(WLAST_S5), .WVALID_S5(WVALID_S5), .WREADY_S5(WREADY_S5),

				.BID_S5(BID_S5), .BRESP_S5(BRESP_S5), .BVALID_S5(BVALID_S5), .BREADY_S5(BREADY_S5)

				);
Bridge_Read BR
	(
		.ACLK(ACLK),
		.ARESETn(ARESETn),
		// Master
		// READ ADDRESS0
		.ARID_M0(ARID_M0),
		.ARADDR_M0(ARADDR_M0),
		.ARLEN_M0(ARLEN_M0),
		.ARSIZE_M0(ARSIZE_M0),
		.ARBURST_M0(ARBURST_M0),
		.ARVALID_M0(ARVALID_M0),
		.ARREADY_M0(ARREADY_M0),
		// READ DATA0
		.RID_M0(RID_M0),
		.RDATA_M0(RDATA_M0),
		.RRESP_M0(RRESP_M0),
		.RLAST_M0(RLAST_M0),
		.RVALID_M0(RVALID_M0),
		.RREADY_M0(RREADY_M0),
		// READ ADDRESS1
		.ARID_M1(ARID_M1),
		.ARADDR_M1(ARADDR_M1),
		.ARLEN_M1(ARLEN_M1),
		.ARSIZE_M1(ARSIZE_M1),
		.ARBURST_M1(ARBURST_M1),
		.ARVALID_M1(ARVALID_M1),
		.ARREADY_M1(ARREADY_M1),
		// READ DATA1
		.RID_M1(RID_M1),
		.RDATA_M1(RDATA_M1),
		.RRESP_M1(RRESP_M1),
		.RLAST_M1(RLAST_M1),
		.RVALID_M1(RVALID_M1),
		.RREADY_M1(RREADY_M1),

		// Slave
		// READ ADDRESS0
		.ARID_S0(ARID_S0),
		.ARADDR_S0(ARADDR_S0),
		.ARLEN_S0(ARLEN_S0),
		.ARSIZE_S0(ARSIZE_S0),
		.ARBURST_S0(ARBURST_S0),
		.ARVALID_S0(ARVALID_S0),
		.ARREADY_S0(ARREADY_S0),
		// READ DATA0
		.RID_S0(RID_S0),
		.RDATA_S0(RDATA_S0),
		.RRESP_S0(RRESP_S0),
		.RLAST_S0(RLAST_S0),
		.RVALID_S0(RVALID_S0),
		.RREADY_S0(RREADY_S0),
		// READ ADDRESS1
		.ARID_S1(ARID_S1),
		.ARADDR_S1(ARADDR_S1),
		.ARLEN_S1(ARLEN_S1),
		.ARSIZE_S1(ARSIZE_S1),
		.ARBURST_S1(ARBURST_S1),
		.ARVALID_S1(ARVALID_S1),
		.ARREADY_S1(ARREADY_S1),
		// READ DATA1
		.RID_S1(RID_S1),
		.RDATA_S1(RDATA_S1),
		.RRESP_S1(RRESP_S1),
		.RLAST_S1(RLAST_S1),
		.RVALID_S1(RVALID_S1),
		.RREADY_S1(RREADY_S1),
		// READ ADDRESS2
		.ARID_S2(ARID_S2),
		.ARADDR_S2(ARADDR_S2),
		.ARLEN_S2(ARLEN_S2),
		.ARSIZE_S2(ARSIZE_S2),
		.ARBURST_S2(ARBURST_S2),
		.ARVALID_S2(ARVALID_S2),
		.ARREADY_S2(ARREADY_S2),
		// READ DATA2
		.RID_S2(RID_S2),
		.RDATA_S2(RDATA_S2),
		.RRESP_S2(RRESP_S2),
		.RLAST_S2(RLAST_S2),
		.RVALID_S2(RVALID_S2),
		.RREADY_S2(RREADY_S2),
		// READ ADDRESS3
		.ARID_S3(ARID_S3),
		.ARADDR_S3(ARADDR_S3),
		.ARLEN_S3(ARLEN_S3),
		.ARSIZE_S3(ARSIZE_S3),
		.ARBURST_S3(ARBURST_S3),
		.ARVALID_S3(ARVALID_S3),
		.ARREADY_S3(ARREADY_S3),
		// READ DATA3
		.RID_S3(RID_S3),
		.RDATA_S3(RDATA_S3),
		.RRESP_S3(RRESP_S3),
		.RLAST_S3(RLAST_S3),
		.RVALID_S3(RVALID_S3),
		.RREADY_S3(RREADY_S3),
		// READ ADDRESS4
		.ARID_S4(ARID_S4),
		.ARADDR_S4(ARADDR_S4),
		.ARLEN_S4(ARLEN_S4),
		.ARSIZE_S4(ARSIZE_S4),
		.ARBURST_S4(ARBURST_S4),
		.ARVALID_S4(ARVALID_S4),
		.ARREADY_S4(ARREADY_S4),
		// READ DATA4
		.RID_S4(RID_S4),
		.RDATA_S4(RDATA_S4),
		.RRESP_S4(RRESP_S4),
		.RLAST_S4(RLAST_S4),
		.RVALID_S4(RVALID_S4),
		.RREADY_S4(RREADY_S4),
		// READ ADDRESS5
		.ARID_S5(ARID_S5),
		.ARADDR_S5(ARADDR_S5),
		.ARLEN_S5(ARLEN_S5),
		.ARSIZE_S5(ARSIZE_S5),
		.ARBURST_S5(ARBURST_S5),
		.ARVALID_S5(ARVALID_S5),
		.ARREADY_S5(ARREADY_S5),
		// READ DATA5
		.RID_S5(RID_S5),
		.RDATA_S5(RDATA_S5),
		.RRESP_S5(RRESP_S5),
		.RLAST_S5(RLAST_S5),
		.RVALID_S5(RVALID_S5),
		.RREADY_S5(RREADY_S5)
	);











endmodule