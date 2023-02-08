//------------------------------------------------------------------------------
// File       : tri_mode_ethernet_mac_0_example_design.v
// Author     : Xilinx Inc.
// -----------------------------------------------------------------------------
// (c) Copyright 2004-2013 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// -----------------------------------------------------------------------------
// Description:  This is the Verilog example design for the Tri-Mode
//               Ethernet MAC core. It is intended that this example design
//               can be quickly adapted and downloaded onto an FPGA to provide
//               a real hardware test environment.
//
//               This level:
//
//               * Instantiates the FIFO Block wrapper, containing the
//                 block level wrapper and an RX and TX FIFO with an
//                 AXI-S interface;
//
//               * Instantiates a simple AXI-S example design,
//                 providing an address swap and a simple
//                 loopback function;
//
//               * Instantiates transmitter clocking circuitry
//                   -the User side of the FIFOs are clocked at gtx_clk
//                    at all times
//
//               * Instantiates a state machine which drives the AXI Lite
//                 interface to bring the TEMAC up in the correct state
//
//               * Serializes the Statistics vectors to prevent logic being
//                 optimized out
//
//               * Ties unused inputs off to reduce the number of IO
//
//               Please refer to the Datasheet, Getting Started Guide, and
//               the Tri-Mode Ethernet MAC User Gude for further information.
//
//    --------------------------------------------------
//    | EXAMPLE DESIGN WRAPPER                         |
//    |                                                |
//    |                                                |
//    |   -------------------     -------------------  |
//    |   |                 |     |                 |  |
//    |   |    Clocking     |     |     Resets      |  |
//    |   |                 |     |                 |  |
//    |   -------------------     -------------------  |
//    |           -------------------------------------|
//    |           |FIFO BLOCK WRAPPER                  |
//    |           |                                    |
//    |           |                                    |
//    |           |              ----------------------|
//    |           |              | SUPPORT LEVEL       |
//    | --------  |              |                     |
//    | |      |  |              |                     |
//    | | AXI  |->|------------->|                     |
//    | | LITE |  |              |                     |
//    | |  SM  |  |              |                     |
//    | |      |<-|<-------------|                     |
//    | |      |  |              |                     |
//    | --------  |              |                     |
//    |           |              |                     |
//    | --------  |  ----------  |                     |
//    | |      |  |  |        |  |                     |
//    | |      |->|->|        |->|                     |
//    | | PAT  |  |  |        |  |                     |
//    | | GEN  |  |  |        |  |                     |
//    | |(ADDR |  |  |  AXI-S |  |                     |
//    | | SWAP)|  |  |  FIFO  |  |                     |
//    | |      |  |  |        |  |                     |
//    | |      |  |  |        |  |                     |
//    | |      |  |  |        |  |                     |
//    | |      |<-|<-|        |<-|                     |
//    | |      |  |  |        |  |                     |
//    | --------  |  ----------  |                     |
//    |           |              |                     |
//    |           |              ----------------------|
//    |           -------------------------------------|
//    --------------------------------------------------

//------------------------------------------------------

`timescale 1 ps/1 ps


//------------------------------------------------------------------------------
// The module declaration for the example_design level wrapper.
//------------------------------------------------------------------------------

(* DowngradeIPIdentifiedWarnings = "yes" *)
module tri_mode_ethernet_mac_0_example_design
   (
      // asynchronous reset
      input         glbl_rst,

      // 100MHz clock input from board
      input         clk_in,

      // 125 MHz clock from MMCM
      output        gtx_clk_bufg_out,
      output        mii_to_rmii_ref_clk,

      output        phy_resetn,


      // MII Interface
      //---------------
      output [3:0]  mii_txd,
      output        mii_tx_en,
      output        mii_tx_er,
      input  [3:0]  mii_rxd,
      input         mii_rx_dv,
      input         mii_rx_er,
      input         mii_rx_clk,
      input         mii_tx_clk,

      
      // MDIO Interface
      //---------------
      inout         mdio,
      output        mdc,
      
      output                              axis_clk,
      output                              axis_resetn,  
      // data from the RX data path
      output       [7:0]                  rx_axis_tdata,
      output                              rx_axis_tvalid,
      output                              rx_axis_tlast,
      input                               rx_axis_tready,

      // data TO the TX data path
      input      [7:0]                    tx_axis_tdata,
      input                               tx_axis_tvalid,
      input                               tx_axis_tlast,
      output                              tx_axis_tready,

      output        s_axi_aclk_out,
      output        s_axi_resetn_out,

      input  [11:0] s_axi_awaddr,
      input         s_axi_awvalid,
      output        s_axi_awready,

      input  [31:0] s_axi_wdata,
      input         s_axi_wvalid,
      output        s_axi_wready,

      output [1:0]  s_axi_bresp,
      output        s_axi_bvalid,
      input         s_axi_bready,

      input  [11:0] s_axi_araddr,
      input         s_axi_arvalid,
      output        s_axi_arready,

      output [31:0] s_axi_rdata,
      output [1:0]  s_axi_rresp,
      output        s_axi_rvalid,
      input         s_axi_rready

    );

   //----------------------------------------------------------------------------
   // internal signals used in this top level wrapper.
   //----------------------------------------------------------------------------

   // example design clocks
   wire                 gtx_clk_bufg;
   
   wire                 s_axi_aclk;
   wire                 rx_mac_aclk;
   wire                 tx_mac_aclk;
   // resets (and reset generation)
   wire                 s_axi_resetn;
   
   wire                 gtx_resetn;
   
   wire                 rx_reset;
   wire                 tx_reset;

   wire                 dcm_locked;
   wire                 glbl_rst_intn;


   // USER side RX AXI-S interface
   wire                 rx_fifo_clock;
   wire                 rx_fifo_resetn;

   // USER side TX AXI-S interface
   wire                 tx_fifo_clock;
   wire                 tx_fifo_resetn;
   
   
   assign s_axi_aclk_out = s_axi_aclk;
   assign s_axi_resetn_out = s_axi_resetn;       

  //----------------------------------------------------------------------------
  // Clock logic to generate required clocks from the 200MHz on board
  // if 125MHz is available directly this can be removed
  //----------------------------------------------------------------------------
  tri_mode_ethernet_mac_0_example_design_clocks example_clocks
   (
      // clock input
      .clk_in           (clk_in),

      // asynchronous control/resets
      .glbl_rst         (glbl_rst),
      .dcm_locked       (dcm_locked),

      // clock outputs
      .gtx_clk_bufg     (gtx_clk_bufg),
      .s_axi_aclk       (s_axi_aclk),
      .mii_to_rmii_ref_clk(mii_to_rmii_ref_clk)
   );

    // Pass the GTX clock to the Test Bench
   assign gtx_clk_bufg_out = gtx_clk_bufg;
   

  //----------------------------------------------------------------------------
  // Generate the user side clocks for the axi fifos
  //----------------------------------------------------------------------------
   
  assign axis_clk = gtx_clk_bufg;
  assign tx_fifo_clock = gtx_clk_bufg;
  assign rx_fifo_clock = gtx_clk_bufg;
   

  //----------------------------------------------------------------------------
  // Generate resets required for the fifo side signals etc
  //----------------------------------------------------------------------------

   tri_mode_ethernet_mac_0_example_design_resets example_resets
   (
      // clocks
      .s_axi_aclk       (s_axi_aclk),
      .gtx_clk          (gtx_clk_bufg),

      // asynchronous resets
      .glbl_rst         (glbl_rst),
      .reset_error      (1'b0),
      .rx_reset         (rx_reset),
      .tx_reset         (tx_reset),

      .dcm_locked       (dcm_locked),

      // synchronous reset outputs
  
      .glbl_rst_intn    (glbl_rst_intn),
   
   
      .gtx_resetn       (gtx_resetn),
   
      .s_axi_resetn     (s_axi_resetn),
      .phy_resetn       (phy_resetn),
      .chk_resetn       ()
   );


   // generate the user side resets for the axi fifos
   assign tx_fifo_resetn = gtx_resetn;
   assign rx_fifo_resetn = gtx_resetn;
   assign axis_resetn = gtx_resetn;

  //----------------------------------------------------------------------------
  // Instantiate the TRIMAC core fifo block wrapper
  //----------------------------------------------------------------------------
  tri_mode_ethernet_mac_0_fifo_block trimac_fifo_block (
      
       
      // asynchronous reset
      .glbl_rstn                    (glbl_rst_intn),
      .rx_axi_rstn                  (1'b1),
      .tx_axi_rstn                  (1'b1),

      // Receiver Statistics Interface
      //---------------------------------------
      .rx_mac_aclk                  (rx_mac_aclk),
      .rx_reset                     (rx_reset),
      .rx_statistics_vector         (),
      .rx_statistics_valid          (),

      // Receiver (AXI-S) Interface
      //----------------------------------------
      .rx_fifo_clock                (rx_fifo_clock),
      .rx_fifo_resetn               (rx_fifo_resetn),
      .rx_axis_fifo_tdata           (rx_axis_tdata),
      .rx_axis_fifo_tvalid          (rx_axis_tvalid),
      .rx_axis_fifo_tready          (rx_axis_tready),
      .rx_axis_fifo_tlast           (rx_axis_tlast),
       
      // Transmitter Statistics Interface
      //------------------------------------------
      .tx_mac_aclk                  (tx_mac_aclk),
      .tx_reset                     (tx_reset),
      .tx_ifg_delay                 (8'b0),
      .tx_statistics_vector         (),
      .tx_statistics_valid          (),

      // Transmitter (AXI-S) Interface
      //-------------------------------------------
      .tx_fifo_clock                (tx_fifo_clock),
      .tx_fifo_resetn               (tx_fifo_resetn),
      .tx_axis_fifo_tdata           (tx_axis_tdata),
      .tx_axis_fifo_tvalid          (tx_axis_tvalid),
      .tx_axis_fifo_tready          (tx_axis_tready),
      .tx_axis_fifo_tlast           (tx_axis_tlast),
       


      // MAC Control Interface
      //------------------------
      .pause_req                    (1'b0),
      .pause_val                    (16'b0),

      // MII Interface
      //---------------
      .mii_txd                      (mii_txd),
      .mii_tx_en                    (mii_tx_en),
      .mii_tx_er                    (mii_tx_er),
      .mii_rxd                      (mii_rxd),
      .mii_rx_dv                    (mii_rx_dv),
      .mii_rx_er                    (mii_rx_er),
      .mii_rx_clk                   (mii_rx_clk),
      .mii_tx_clk                   (mii_tx_clk),

      
      // MDIO Interface
      //---------------
      .mdio                         (mdio),
      .mdc                          (mdc),

      // AXI-Lite Interface
      //---------------
      .s_axi_aclk                   (s_axi_aclk),
      .s_axi_resetn                 (s_axi_resetn),

      .s_axi_awaddr                 (s_axi_awaddr),
      .s_axi_awvalid                (s_axi_awvalid),
      .s_axi_awready                (s_axi_awready),

      .s_axi_wdata                  (s_axi_wdata),
      .s_axi_wvalid                 (s_axi_wvalid),
      .s_axi_wready                 (s_axi_wready),

      .s_axi_bresp                  (s_axi_bresp),
      .s_axi_bvalid                 (s_axi_bvalid),
      .s_axi_bready                 (s_axi_bready),

      .s_axi_araddr                 (s_axi_araddr),
      .s_axi_arvalid                (s_axi_arvalid),
      .s_axi_arready                (s_axi_arready),

      .s_axi_rdata                  (s_axi_rdata),
      .s_axi_rresp                  (s_axi_rresp),
      .s_axi_rvalid                 (s_axi_rvalid),
      .s_axi_rready                 (s_axi_rready)

   );

endmodule

