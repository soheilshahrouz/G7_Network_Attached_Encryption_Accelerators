
`timescale 1 ps/1 ps

module top (
    input           sys_clk_in,    

    inout           mdio,
    output          mdc,

    output          phy_resetn,

    input           phy2rmii_crs_dv,
    input           phy2rmii_rx_er,
    input  [1 : 0]  phy2rmii_rxd,
    output [1 : 0]  rmii2phy_txd,
    output          rmii2phy_tx_en,
    output          eth_ref_clk

);




    wire axi_clk;
    wire axi_resetn;

    wire [31:0]axi_temac_araddr;
    wire [2:0]axi_temac_arprot;
    wire [0:0]axi_temac_arready;
    wire [0:0]axi_temac_arvalid;
    wire [31:0]axi_temac_awaddr;
    wire [2:0]axi_temac_awprot;
    wire [0:0]axi_temac_awready;
    wire [0:0]axi_temac_awvalid;
    wire [0:0]axi_temac_bready;
    wire [1:0]axi_temac_bresp;
    wire [0:0]axi_temac_bvalid;
    wire [31:0]axi_temac_rdata;
    wire [0:0]axi_temac_rready;
    wire [1:0]axi_temac_rresp;
    wire [0:0]axi_temac_rvalid;
    wire [31:0]axi_temac_wdata;
    wire [0:0]axi_temac_wready;
    wire [3:0]axi_temac_wstrb;
    wire [0:0]axi_temac_wvalid;

    wire net_axis_clk;
    wire net_axis_resetn;

    wire [7:0]net_axis_rx_tdata;
    wire net_axis_rx_tlast;
    wire net_axis_rx_tready;
    wire net_axis_rx_tvalid;
    wire [7:0]net_axis_tx_tdata;
    wire net_axis_tx_tlast;
    wire net_axis_tx_tready;
    wire net_axis_tx_tvalid;

    wire [3:0]  mii_txd;
    wire        mii_tx_en;
    wire        mii_tx_er;
    wire [3:0]  mii_rxd;
    wire        mii_rx_dv;
    wire        mii_rx_er;
    wire        mii_rx_clk;
    wire        mii_tx_clk;

    wire        mii_to_rmii_ref_clk;  


    mb_bd_wrapper mb_bd_inst(

        .axi_clk(axi_clk),
        .axi_resetn(axi_resetn),

        .m_axi_temac_araddr(axi_temac_araddr),
        .m_axi_temac_arprot(axi_temac_arprot),
        .m_axi_temac_arready(axi_temac_arready),
        .m_axi_temac_arvalid(axi_temac_arvalid),
        .m_axi_temac_awaddr(axi_temac_awaddr),
        .m_axi_temac_awprot(axi_temac_awprot),
        .m_axi_temac_awready(axi_temac_awready),
        .m_axi_temac_awvalid(axi_temac_awvalid),
        .m_axi_temac_bready(axi_temac_bready),
        .m_axi_temac_bresp(axi_temac_bresp),
        .m_axi_temac_bvalid(axi_temac_bvalid),
        .m_axi_temac_rdata(axi_temac_rdata),
        .m_axi_temac_rready(axi_temac_rready),
        .m_axi_temac_rresp(axi_temac_rresp),
        .m_axi_temac_rvalid(axi_temac_rvalid),
        .m_axi_temac_wdata(axi_temac_wdata),
        .m_axi_temac_wready(axi_temac_wready),
        .m_axi_temac_wstrb(axi_temac_wstrb),
        .m_axi_temac_wvalid(axi_temac_wvalid),

        .net_axis_clk(net_axis_clk),
        .net_axis_resetn(net_axis_resetn),

        .net_axis_rx_tdata(net_axis_rx_tdata),
        .net_axis_rx_tlast(net_axis_rx_tlast),
        .net_axis_rx_tready(net_axis_rx_tready),
        .net_axis_rx_tvalid(net_axis_rx_tvalid),

        .net_axis_tx_tdata(net_axis_tx_tdata),
        .net_axis_tx_tlast(net_axis_tx_tlast),
        .net_axis_tx_tready(net_axis_tx_tready),
        .net_axis_tx_tvalid(net_axis_tx_tvalid)
    );


    tri_mode_ethernet_mac_0_example_design temac_inst(
        // asynchronous reset
        .glbl_rst(1'b0),

        // 100MHz clock input from board
        .clk_in(sys_clk_in),
        
        // 125 MHz clock from MMCM
        .gtx_clk_bufg_out(),
        .mii_to_rmii_ref_clk(mii_to_rmii_ref_clk),

        .phy_resetn(phy_resetn),


        // MII Interface
        //---------------
        .mii_txd(mii_txd),
        .mii_tx_en(mii_tx_en),
        .mii_tx_er(mii_tx_er),
        .mii_rxd(mii_rxd),
        .mii_rx_dv(mii_rx_dv),
        .mii_rx_er(mii_rx_er),
        .mii_rx_clk(mii_rx_clk),
        .mii_tx_clk(mii_tx_clk),


        .mdio(mdio),
        .mdc(mdc),

        .axis_clk(net_axis_clk),
        .axis_resetn(net_axis_resetn),
        
        .rx_axis_tdata(net_axis_rx_tdata),
        .rx_axis_tvalid(net_axis_rx_tvalid),
        .rx_axis_tlast(net_axis_rx_tlast),
        .rx_axis_tready(net_axis_rx_tready),

        .tx_axis_tdata(net_axis_tx_tdata),
        .tx_axis_tvalid(net_axis_tx_tvalid),
        .tx_axis_tlast(net_axis_tx_tlast),
        .tx_axis_tready(net_axis_tx_tready),


        .s_axi_aclk_out(axi_clk),
        .s_axi_resetn_out(axi_resetn),

        .s_axi_awaddr(axi_temac_awaddr),
        .s_axi_awvalid(axi_temac_awvalid),
        .s_axi_awready(axi_temac_awready),

        .s_axi_wdata(axi_temac_wdata),
        .s_axi_wvalid(axi_temac_wvalid),
        .s_axi_wready(axi_temac_wready),

        .s_axi_bresp(axi_temac_bresp),
        .s_axi_bvalid(axi_temac_bvalid),
        .s_axi_bready(axi_temac_bready),

        .s_axi_araddr(axi_temac_araddr),
        .s_axi_arvalid(axi_temac_arvalid),
        .s_axi_arready(axi_temac_arready),

        .s_axi_rdata(axi_temac_rdata),
        .s_axi_rresp(axi_temac_rresp),
        .s_axi_rvalid(axi_temac_rvalid),
        .s_axi_rready(axi_temac_rready)
    );



    mii_to_rmii_0 mii_to_rmii_inst(
        .rst_n(phy_resetn),
        .ref_clk(mii_to_rmii_ref_clk),

        .mac2rmii_tx_en(mii_tx_en),    // input wire mac2rmii_tx_en
        .mac2rmii_txd(mii_txd),        // input wire [3 : 0] mac2rmii_txd
        .mac2rmii_tx_er(mii_tx_er),    // input wire mac2rmii_tx_er
        .rmii2mac_tx_clk(mii_tx_clk),  // output wire rmii2mac_tx_clk
        .rmii2mac_rx_clk(mii_rx_clk),  // output wire rmii2mac_rx_clk
        .rmii2mac_col(),               // output wire rmii2mac_col
        .rmii2mac_crs(),               // output wire rmii2mac_crs
        .rmii2mac_rx_dv(mii_rx_dv),    // output wire rmii2mac_rx_dv
        .rmii2mac_rx_er(mii_rx_er),    // output wire rmii2mac_rx_er
        .rmii2mac_rxd(mii_rxd),        // output wire [3 : 0] rmii2mac_rxd

        .phy2rmii_crs_dv(phy2rmii_crs_dv),
        .phy2rmii_rx_er(phy2rmii_rx_er),
        .phy2rmii_rxd(phy2rmii_rxd),
        .rmii2phy_txd(rmii2phy_txd),
        .rmii2phy_tx_en(rmii2phy_tx_en)
    );


    assign eth_ref_clk = mii_to_rmii_ref_clk;
    
endmodule