
################################################################
# This is a generated script based on design: mb_bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2018.3
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source mb_bd_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7a100tcsg324-1
   set_property BOARD_PART digilentinc.com:nexys4_ddr:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name mb_bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
digilentinc.com:IP:PmodSD:1.0\
xilinx.com:hls:aes_cipher:1.0\
xilinx.com:hls:arp:1.0\
xilinx.com:ip:axis_data_fifo:2.0\
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:axis_switch:1.1\
xilinx.com:hls:des:1.0\
xilinx.com:hls:distributer:1.0\
xilinx.com:hls:icmp:1.0\
xilinx.com:ip:mdm:3.2\
xilinx.com:ip:microblaze:11.0\
xilinx.com:hls:parser:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:hls:tlast_gen:1.0\
xilinx.com:hls:udp_depacketizer:1.0\
xilinx.com:hls:udp_packetizer:1.0\
xilinx.com:hls:udp_reg:1.0\
xilinx.com:ip:lmb_bram_if_cntlr:4.0\
xilinx.com:ip:lmb_v10:3.0\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB

  # Create pins
  create_bd_pin -dir I -type clk Clk
  create_bd_pin -dir I -type rst SYS_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lmb_bram ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set Pmod_out_0 [ create_bd_intf_port -mode Master -vlnv digilentinc.com:interface:pmod_rtl:1.0 Pmod_out_0 ]
  set dip_switches_16bits [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 dip_switches_16bits ]
  set led [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gpio_rtl:1.0 led ]
  set m_axi_temac [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 m_axi_temac ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.PROTOCOL {AXI4LITE} \
   ] $m_axi_temac
  set net_axis_rx [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 net_axis_rx ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {1} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $net_axis_rx
  set net_axis_tx [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 net_axis_tx ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {125000000} \
   ] $net_axis_tx

  # Create ports
  set axi_clk [ create_bd_port -dir I -type clk axi_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {m_axi_temac} \
   CONFIG.ASSOCIATED_RESET {axi_resetn} \
   CONFIG.FREQ_HZ {100000000} \
 ] $axi_clk
  set axi_resetn [ create_bd_port -dir I -type rst axi_resetn ]
  set net_axis_clk [ create_bd_port -dir I -type clk net_axis_clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_RESET {net_axis_resetn} \
   CONFIG.FREQ_HZ {125000000} \
 ] $net_axis_clk
  set net_axis_resetn [ create_bd_port -dir I -type rst net_axis_resetn ]

  # Create instance: PmodSD_0, and set properties
  set PmodSD_0 [ create_bd_cell -type ip -vlnv digilentinc.com:IP:PmodSD:1.0 PmodSD_0 ]
  set_property -dict [ list \
   CONFIG.PMOD {sd} \
 ] $PmodSD_0

  # Create instance: aes_cipher_0, and set properties
  set aes_cipher_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:aes_cipher:1.0 aes_cipher_0 ]

  # Create instance: arp_0, and set properties
  set arp_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:arp:1.0 arp_0 ]

  # Create instance: arp_input_buffer, and set properties
  set arp_input_buffer [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 arp_input_buffer ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {512} \
   CONFIG.FIFO_MODE {1} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $arp_input_buffer

  # Create instance: arp_output_buffer, and set properties
  set arp_output_buffer [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 arp_output_buffer ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {512} \
   CONFIG.FIFO_MODE {2} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $arp_output_buffer

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]

  # Create instance: axi_bram_ctrl_0_bram, and set properties
  set axi_bram_ctrl_0_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 axi_bram_ctrl_0_bram ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
 ] $axi_bram_ctrl_0_bram

  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [ list \
   CONFIG.c_include_sg {0} \
   CONFIG.c_m_axis_mm2s_tdata_width {8} \
   CONFIG.c_sg_include_stscntrl_strm {0} \
 ] $axi_dma_0

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_INPUTS {1} \
   CONFIG.C_ALL_OUTPUTS_2 {1} \
   CONFIG.C_GPIO2_WIDTH {16} \
   CONFIG.C_GPIO_WIDTH {16} \
   CONFIG.C_IS_DUAL {1} \
   CONFIG.GPIO2_BOARD_INTERFACE {led_16bits} \
   CONFIG.GPIO_BOARD_INTERFACE {dip_switches_16bits} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_gpio_0

  # Create instance: axis_switch_0, and set properties
  set axis_switch_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_switch_0 ]
  set_property -dict [ list \
   CONFIG.ARB_ALGORITHM {3} \
   CONFIG.ARB_ON_TLAST {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.NUM_SI {4} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $axis_switch_0

  # Create instance: axis_switch_enc_data, and set properties
  set axis_switch_enc_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_switch_enc_data ]
  set_property -dict [ list \
   CONFIG.ARB_ALGORITHM {3} \
   CONFIG.ARB_ON_TLAST {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.NUM_SI {2} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $axis_switch_enc_data

  # Create instance: axis_switch_out_sel, and set properties
  set axis_switch_out_sel [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_switch_out_sel ]
  set_property -dict [ list \
   CONFIG.DECODER_REG {1} \
   CONFIG.NUM_MI {2} \
   CONFIG.NUM_SI {1} \
   CONFIG.ROUTING_MODE {1} \
 ] $axis_switch_out_sel

  # Create instance: axis_switch_raw_data, and set properties
  set axis_switch_raw_data [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_switch_raw_data ]
  set_property -dict [ list \
   CONFIG.DECODER_REG {1} \
   CONFIG.NUM_MI {2} \
   CONFIG.NUM_SI {2} \
   CONFIG.ROUTING_MODE {1} \
 ] $axis_switch_raw_data

  # Create instance: des_0, and set properties
  set des_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:des:1.0 des_0 ]

  # Create instance: distributer_0, and set properties
  set distributer_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:distributer:1.0 distributer_0 ]

  # Create instance: enc_data_buf, and set properties
  set enc_data_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 enc_data_buf ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {2048} \
   CONFIG.FIFO_MODE {1} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $enc_data_buf

  # Create instance: icmp_0, and set properties
  set icmp_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:icmp:1.0 icmp_0 ]

  # Create instance: icmp_input_buffer, and set properties
  set icmp_input_buffer [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 icmp_input_buffer ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {512} \
   CONFIG.FIFO_MODE {1} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $icmp_input_buffer

  # Create instance: icmp_output_buffer, and set properties
  set icmp_output_buffer [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 icmp_output_buffer ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {2048} \
   CONFIG.FIFO_MODE {2} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $icmp_output_buffer

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]
  set_property -dict [ list \
   CONFIG.C_ADDR_SIZE {32} \
   CONFIG.C_M_AXI_ADDR_WIDTH {32} \
   CONFIG.C_USE_UART {1} \
 ] $mdm_1

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0 ]
  set_property -dict [ list \
   CONFIG.C_ADDR_TAG_BITS {0} \
   CONFIG.C_AREA_OPTIMIZED {1} \
   CONFIG.C_DCACHE_ADDR_TAG {0} \
   CONFIG.C_DEBUG_ENABLED {1} \
   CONFIG.C_D_AXI {1} \
   CONFIG.C_D_LMB {1} \
   CONFIG.C_I_LMB {1} \
 ] $microblaze_0

  # Create instance: microblaze_0_axi_periph, and set properties
  set microblaze_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 microblaze_0_axi_periph ]
  set_property -dict [ list \
   CONFIG.NUM_MI {14} \
   CONFIG.NUM_SI {4} \
 ] $microblaze_0_axi_periph

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: network_rx_fifo, and set properties
  set network_rx_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 network_rx_fifo ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {2048} \
   CONFIG.FIFO_MODE {2} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $network_rx_fifo

  # Create instance: network_tx_fifo, and set properties
  set network_tx_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 network_tx_fifo ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {2048} \
   CONFIG.FIFO_MODE {2} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $network_tx_fifo

  # Create instance: packet_buffer, and set properties
  set packet_buffer [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 packet_buffer ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {2048} \
   CONFIG.FIFO_MODE {1} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $packet_buffer

  # Create instance: parser_0, and set properties
  set parser_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:parser:1.0 parser_0 ]

  # Create instance: prot_fifo, and set properties
  set prot_fifo [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 prot_fifo ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {16} \
 ] $prot_fifo

  # Create instance: raw_data_buf, and set properties
  set raw_data_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 raw_data_buf ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {2048} \
   CONFIG.FIFO_MODE {1} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $raw_data_buf

  # Create instance: rst_Clk_100M, and set properties
  set rst_Clk_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_Clk_100M ]

  # Create instance: rst_Clk_100M1, and set properties
  set rst_Clk_100M1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_Clk_100M1 ]

  # Create instance: tlast_gen_0, and set properties
  set tlast_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:tlast_gen:1.0 tlast_gen_0 ]

  # Create instance: udp_depacketizer_0, and set properties
  set udp_depacketizer_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:udp_depacketizer:1.0 udp_depacketizer_0 ]

  # Create instance: udp_output_buffer, and set properties
  set udp_output_buffer [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 udp_output_buffer ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {2048} \
   CONFIG.FIFO_MODE {2} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $udp_output_buffer

  # Create instance: udp_packetizer_0, and set properties
  set udp_packetizer_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:udp_packetizer:1.0 udp_packetizer_0 ]

  # Create instance: udp_rcv_buf, and set properties
  set udp_rcv_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 udp_rcv_buf ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {2048} \
   CONFIG.FIFO_MODE {1} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $udp_rcv_buf

  # Create instance: udp_reg_0, and set properties
  set udp_reg_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:udp_reg:1.0 udp_reg_0 ]

  # Create instance: udp_reg_buf, and set properties
  set udp_reg_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 udp_reg_buf ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {512} \
   CONFIG.FIFO_MODE {1} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $udp_reg_buf

  # Create instance: udp_reg_out_buf, and set properties
  set udp_reg_out_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 udp_reg_out_buf ]
  set_property -dict [ list \
   CONFIG.FIFO_DEPTH {2048} \
   CONFIG.FIFO_MODE {2} \
   CONFIG.TDATA_NUM_BYTES {1} \
 ] $udp_reg_out_buf

  # Create interface connections
  connect_bd_intf_net -intf_net PmodSD_0_Pmod_out [get_bd_intf_ports Pmod_out_0] [get_bd_intf_pins PmodSD_0/Pmod_out]
  connect_bd_intf_net -intf_net aes_cipher_0_out_r [get_bd_intf_pins aes_cipher_0/out_r] [get_bd_intf_pins axis_switch_enc_data/S01_AXIS]
  connect_bd_intf_net -intf_net arp_0_output_strm [get_bd_intf_pins arp_0/output_strm] [get_bd_intf_pins arp_output_buffer/S_AXIS]
  connect_bd_intf_net -intf_net arp_buffer_M_AXIS [get_bd_intf_pins arp_0/input_strm] [get_bd_intf_pins arp_input_buffer/M_AXIS]
  connect_bd_intf_net -intf_net arp_output_buffer_M_AXIS [get_bd_intf_pins arp_output_buffer/M_AXIS] [get_bd_intf_pins axis_switch_0/S00_AXIS]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTB [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S] [get_bd_intf_pins axis_switch_raw_data/S01_AXIS]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins axi_dma_0/M_AXI_MM2S] [get_bd_intf_pins microblaze_0_axi_periph/S02_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins axi_dma_0/M_AXI_S2MM] [get_bd_intf_pins microblaze_0_axi_periph/S03_AXI]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO [get_bd_intf_ports dip_switches_16bits] [get_bd_intf_pins axi_gpio_0/GPIO]
  connect_bd_intf_net -intf_net axi_gpio_0_GPIO2 [get_bd_intf_ports led] [get_bd_intf_pins axi_gpio_0/GPIO2]
  connect_bd_intf_net -intf_net axis_switch_0_M00_AXIS [get_bd_intf_pins axis_switch_0/M00_AXIS] [get_bd_intf_pins network_tx_fifo/S_AXIS]
  connect_bd_intf_net -intf_net axis_switch_1_M00_AXIS [get_bd_intf_pins axis_switch_raw_data/M00_AXIS] [get_bd_intf_pins des_0/inp_strm_V]
  connect_bd_intf_net -intf_net axis_switch_1_M01_AXIS [get_bd_intf_pins aes_cipher_0/in_r] [get_bd_intf_pins axis_switch_raw_data/M01_AXIS]
  connect_bd_intf_net -intf_net axis_switch_enc_data_M00_AXIS [get_bd_intf_pins axis_switch_enc_data/M00_AXIS] [get_bd_intf_pins enc_data_buf/S_AXIS]
  connect_bd_intf_net -intf_net axis_switch_out_sel_M00_AXIS [get_bd_intf_pins axis_switch_out_sel/M00_AXIS] [get_bd_intf_pins udp_packetizer_0/input_strm]
  connect_bd_intf_net -intf_net axis_switch_out_sel_M01_AXIS [get_bd_intf_pins axis_switch_out_sel/M01_AXIS] [get_bd_intf_pins tlast_gen_0/input_strm_V_V]
  connect_bd_intf_net -intf_net des_0_out_strm_V [get_bd_intf_pins axis_switch_enc_data/S00_AXIS] [get_bd_intf_pins des_0/out_strm_V]
  connect_bd_intf_net -intf_net distributer_0_arp_strm [get_bd_intf_pins arp_input_buffer/S_AXIS] [get_bd_intf_pins distributer_0/arp_strm]
  connect_bd_intf_net -intf_net distributer_0_icmp_strm [get_bd_intf_pins distributer_0/icmp_strm] [get_bd_intf_pins icmp_input_buffer/S_AXIS]
  connect_bd_intf_net -intf_net distributer_0_udp_reg_strm [get_bd_intf_pins distributer_0/udp_reg_strm] [get_bd_intf_pins udp_reg_buf/S_AXIS]
  connect_bd_intf_net -intf_net distributer_0_udp_strm [get_bd_intf_pins distributer_0/udp_strm_strm] [get_bd_intf_pins udp_rcv_buf/S_AXIS]
  connect_bd_intf_net -intf_net enc_data_buf_M_AXIS [get_bd_intf_pins axis_switch_out_sel/S00_AXIS] [get_bd_intf_pins enc_data_buf/M_AXIS]
  connect_bd_intf_net -intf_net icmp_0_output_strm [get_bd_intf_pins icmp_0/output_strm] [get_bd_intf_pins icmp_output_buffer/S_AXIS]
  connect_bd_intf_net -intf_net icmp_input_buffer_M_AXIS [get_bd_intf_pins icmp_0/input_strm] [get_bd_intf_pins icmp_input_buffer/M_AXIS]
  connect_bd_intf_net -intf_net icmp_output_buffer_M_AXIS [get_bd_intf_pins axis_switch_0/S01_AXIS] [get_bd_intf_pins icmp_output_buffer/M_AXIS]
  connect_bd_intf_net -intf_net microblaze_0_axi_dp [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins microblaze_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M01_AXI [get_bd_intf_ports m_axi_temac] [get_bd_intf_pins microblaze_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M02_AXI [get_bd_intf_pins arp_0/s_axi_ctrl] [get_bd_intf_pins microblaze_0_axi_periph/M02_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M03_AXI [get_bd_intf_pins icmp_0/s_axi_ctrl] [get_bd_intf_pins microblaze_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M04_AXI [get_bd_intf_pins microblaze_0_axi_periph/M04_AXI] [get_bd_intf_pins udp_packetizer_0/s_axi_ctrl]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M05_AXI [get_bd_intf_pins des_0/s_axi_AXILiteS] [get_bd_intf_pins microblaze_0_axi_periph/M05_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M06_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M06_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M07_AXI [get_bd_intf_pins aes_cipher_0/s_axi_AXILiteS] [get_bd_intf_pins microblaze_0_axi_periph/M07_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M08_AXI [get_bd_intf_pins axis_switch_raw_data/S_AXI_CTRL] [get_bd_intf_pins microblaze_0_axi_periph/M08_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M09_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M09_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M10_AXI [get_bd_intf_pins PmodSD_0/AXI_LITE_SPI] [get_bd_intf_pins microblaze_0_axi_periph/M10_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M11_AXI [get_bd_intf_pins PmodSD_0/AXI_LITE_SDCS] [get_bd_intf_pins microblaze_0_axi_periph/M11_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M12_AXI [get_bd_intf_pins axis_switch_out_sel/S_AXI_CTRL] [get_bd_intf_pins microblaze_0_axi_periph/M12_AXI]
  connect_bd_intf_net -intf_net microblaze_0_axi_periph_M13_AXI [get_bd_intf_pins axi_dma_0/S_AXI_LITE] [get_bd_intf_pins microblaze_0_axi_periph/M13_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]
  connect_bd_intf_net -intf_net microblaze_0_mdm_axi [get_bd_intf_pins mdm_1/S_AXI] [get_bd_intf_pins microblaze_0_axi_periph/M00_AXI]
  connect_bd_intf_net -intf_net net_axis_rx_1 [get_bd_intf_ports net_axis_rx] [get_bd_intf_pins network_rx_fifo/S_AXIS]
  connect_bd_intf_net -intf_net network_rx_fifo_M_AXIS [get_bd_intf_pins network_rx_fifo/M_AXIS] [get_bd_intf_pins parser_0/input_strm]
  connect_bd_intf_net -intf_net network_tx_fifo_M_AXIS [get_bd_intf_ports net_axis_tx] [get_bd_intf_pins network_tx_fifo/M_AXIS]
  connect_bd_intf_net -intf_net packet_buffer_M_AXIS [get_bd_intf_pins distributer_0/input_strm] [get_bd_intf_pins packet_buffer/M_AXIS]
  connect_bd_intf_net -intf_net parser_0_output_strm [get_bd_intf_pins packet_buffer/S_AXIS] [get_bd_intf_pins parser_0/output_strm]
  connect_bd_intf_net -intf_net parser_0_prot_strm_V_V [get_bd_intf_pins parser_0/prot_strm_V_V] [get_bd_intf_pins prot_fifo/S_AXIS]
  connect_bd_intf_net -intf_net prot_fifo_M_AXIS [get_bd_intf_pins distributer_0/prot_strm_V_V] [get_bd_intf_pins prot_fifo/M_AXIS]
  connect_bd_intf_net -intf_net raw_data_buf_M_AXIS [get_bd_intf_pins axis_switch_raw_data/S00_AXIS] [get_bd_intf_pins raw_data_buf/M_AXIS]
  connect_bd_intf_net -intf_net tlast_gen_0_output_strm [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM] [get_bd_intf_pins tlast_gen_0/output_strm]
  connect_bd_intf_net -intf_net udp_depacketizer_0_output_strm [get_bd_intf_pins raw_data_buf/S_AXIS] [get_bd_intf_pins udp_depacketizer_0/output_strm]
  connect_bd_intf_net -intf_net udp_output_buffer_M_AXIS [get_bd_intf_pins axis_switch_0/S02_AXIS] [get_bd_intf_pins udp_output_buffer/M_AXIS]
  connect_bd_intf_net -intf_net udp_packetizer_0_output_strm [get_bd_intf_pins udp_output_buffer/S_AXIS] [get_bd_intf_pins udp_packetizer_0/output_strm]
  connect_bd_intf_net -intf_net udp_rcv_buf_M_AXIS [get_bd_intf_pins udp_depacketizer_0/input_strm] [get_bd_intf_pins udp_rcv_buf/M_AXIS]
  connect_bd_intf_net -intf_net udp_reg_0_m_axi_reg_space_V [get_bd_intf_pins microblaze_0_axi_periph/S01_AXI] [get_bd_intf_pins udp_reg_0/m_axi_reg_space_V]
  connect_bd_intf_net -intf_net udp_reg_0_output_strm [get_bd_intf_pins udp_reg_0/output_strm] [get_bd_intf_pins udp_reg_out_buf/S_AXIS]
  connect_bd_intf_net -intf_net udp_reg_buf_M_AXIS [get_bd_intf_pins udp_reg_0/input_strm] [get_bd_intf_pins udp_reg_buf/M_AXIS]
  connect_bd_intf_net -intf_net udp_reg_out_buf_M_AXIS [get_bd_intf_pins axis_switch_0/S03_AXIS] [get_bd_intf_pins udp_reg_out_buf/M_AXIS]

  # Create port connections
  connect_bd_net -net axi_resetn_1 [get_bd_ports axi_resetn] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_dma_0/axi_resetn] [get_bd_pins microblaze_0_axi_periph/M06_ARESETN] [get_bd_pins microblaze_0_axi_periph/M08_ARESETN] [get_bd_pins microblaze_0_axi_periph/M12_ARESETN] [get_bd_pins microblaze_0_axi_periph/M13_ARESETN] [get_bd_pins rst_Clk_100M/ext_reset_in]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst_Clk_100M/mb_debug_sys_rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_ports axi_clk] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk] [get_bd_pins axis_switch_out_sel/s_axi_ctrl_aclk] [get_bd_pins axis_switch_raw_data/s_axi_ctrl_aclk] [get_bd_pins mdm_1/S_AXI_ACLK] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_axi_periph/ACLK] [get_bd_pins microblaze_0_axi_periph/M00_ACLK] [get_bd_pins microblaze_0_axi_periph/M01_ACLK] [get_bd_pins microblaze_0_axi_periph/M06_ACLK] [get_bd_pins microblaze_0_axi_periph/M08_ACLK] [get_bd_pins microblaze_0_axi_periph/M12_ACLK] [get_bd_pins microblaze_0_axi_periph/M13_ACLK] [get_bd_pins microblaze_0_axi_periph/S00_ACLK] [get_bd_pins microblaze_0_local_memory/Clk] [get_bd_pins rst_Clk_100M/slowest_sync_clk]
  connect_bd_net -net net_axis_clk_1 [get_bd_ports net_axis_clk] [get_bd_pins PmodSD_0/s_axi_aclk] [get_bd_pins aes_cipher_0/ap_clk] [get_bd_pins arp_0/ap_clk] [get_bd_pins arp_input_buffer/s_axis_aclk] [get_bd_pins arp_output_buffer/s_axis_aclk] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axis_switch_0/aclk] [get_bd_pins axis_switch_enc_data/aclk] [get_bd_pins axis_switch_out_sel/aclk] [get_bd_pins axis_switch_raw_data/aclk] [get_bd_pins des_0/ap_clk] [get_bd_pins distributer_0/ap_clk] [get_bd_pins enc_data_buf/s_axis_aclk] [get_bd_pins icmp_0/ap_clk] [get_bd_pins icmp_input_buffer/s_axis_aclk] [get_bd_pins icmp_output_buffer/s_axis_aclk] [get_bd_pins microblaze_0_axi_periph/M02_ACLK] [get_bd_pins microblaze_0_axi_periph/M03_ACLK] [get_bd_pins microblaze_0_axi_periph/M04_ACLK] [get_bd_pins microblaze_0_axi_periph/M05_ACLK] [get_bd_pins microblaze_0_axi_periph/M07_ACLK] [get_bd_pins microblaze_0_axi_periph/M09_ACLK] [get_bd_pins microblaze_0_axi_periph/M10_ACLK] [get_bd_pins microblaze_0_axi_periph/M11_ACLK] [get_bd_pins microblaze_0_axi_periph/S01_ACLK] [get_bd_pins microblaze_0_axi_periph/S02_ACLK] [get_bd_pins microblaze_0_axi_periph/S03_ACLK] [get_bd_pins network_rx_fifo/s_axis_aclk] [get_bd_pins network_tx_fifo/s_axis_aclk] [get_bd_pins packet_buffer/s_axis_aclk] [get_bd_pins parser_0/ap_clk] [get_bd_pins prot_fifo/s_axis_aclk] [get_bd_pins raw_data_buf/s_axis_aclk] [get_bd_pins rst_Clk_100M1/slowest_sync_clk] [get_bd_pins tlast_gen_0/ap_clk] [get_bd_pins udp_depacketizer_0/ap_clk] [get_bd_pins udp_output_buffer/s_axis_aclk] [get_bd_pins udp_packetizer_0/ap_clk] [get_bd_pins udp_rcv_buf/s_axis_aclk] [get_bd_pins udp_reg_0/ap_clk] [get_bd_pins udp_reg_buf/s_axis_aclk] [get_bd_pins udp_reg_out_buf/s_axis_aclk]
  connect_bd_net -net net_axis_resetn_1 [get_bd_ports net_axis_resetn] [get_bd_pins PmodSD_0/s_axi_aresetn] [get_bd_pins aes_cipher_0/ap_rst_n] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins microblaze_0_axi_periph/M02_ARESETN] [get_bd_pins microblaze_0_axi_periph/M03_ARESETN] [get_bd_pins microblaze_0_axi_periph/M04_ARESETN] [get_bd_pins microblaze_0_axi_periph/M05_ARESETN] [get_bd_pins microblaze_0_axi_periph/M07_ARESETN] [get_bd_pins microblaze_0_axi_periph/M09_ARESETN] [get_bd_pins microblaze_0_axi_periph/M10_ARESETN] [get_bd_pins microblaze_0_axi_periph/M11_ARESETN] [get_bd_pins microblaze_0_axi_periph/S02_ARESETN] [get_bd_pins microblaze_0_axi_periph/S03_ARESETN] [get_bd_pins rst_Clk_100M1/ext_reset_in] [get_bd_pins tlast_gen_0/ap_rst_n]
  connect_bd_net -net rst_Clk_100M1_peripheral_aresetn [get_bd_pins arp_0/ap_rst_n] [get_bd_pins arp_input_buffer/s_axis_aresetn] [get_bd_pins arp_output_buffer/s_axis_aresetn] [get_bd_pins axis_switch_0/aresetn] [get_bd_pins axis_switch_enc_data/aresetn] [get_bd_pins axis_switch_out_sel/aresetn] [get_bd_pins axis_switch_raw_data/aresetn] [get_bd_pins des_0/ap_rst_n] [get_bd_pins distributer_0/ap_rst_n] [get_bd_pins enc_data_buf/s_axis_aresetn] [get_bd_pins icmp_0/ap_rst_n] [get_bd_pins icmp_input_buffer/s_axis_aresetn] [get_bd_pins icmp_output_buffer/s_axis_aresetn] [get_bd_pins microblaze_0_axi_periph/S01_ARESETN] [get_bd_pins network_rx_fifo/s_axis_aresetn] [get_bd_pins network_tx_fifo/s_axis_aresetn] [get_bd_pins packet_buffer/s_axis_aresetn] [get_bd_pins parser_0/ap_rst_n] [get_bd_pins prot_fifo/s_axis_aresetn] [get_bd_pins raw_data_buf/s_axis_aresetn] [get_bd_pins rst_Clk_100M1/peripheral_aresetn] [get_bd_pins udp_depacketizer_0/ap_rst_n] [get_bd_pins udp_output_buffer/s_axis_aresetn] [get_bd_pins udp_packetizer_0/ap_rst_n] [get_bd_pins udp_rcv_buf/s_axis_aresetn] [get_bd_pins udp_reg_0/ap_rst_n] [get_bd_pins udp_reg_buf/s_axis_aresetn] [get_bd_pins udp_reg_out_buf/s_axis_aresetn]
  connect_bd_net -net rst_Clk_100M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/SYS_Rst] [get_bd_pins rst_Clk_100M/bus_struct_reset]
  connect_bd_net -net rst_Clk_100M_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins rst_Clk_100M/mb_reset]
  connect_bd_net -net rst_Clk_100M_peripheral_aresetn [get_bd_pins axis_switch_out_sel/s_axi_ctrl_aresetn] [get_bd_pins axis_switch_raw_data/s_axi_ctrl_aresetn] [get_bd_pins mdm_1/S_AXI_ARESETN] [get_bd_pins microblaze_0_axi_periph/ARESETN] [get_bd_pins microblaze_0_axi_periph/M00_ARESETN] [get_bd_pins microblaze_0_axi_periph/M01_ARESETN] [get_bd_pins microblaze_0_axi_periph/S00_ARESETN] [get_bd_pins rst_Clk_100M/peripheral_aresetn]
  connect_bd_net -net udp_depacketizer_0_dst_ip_addr_V [get_bd_pins udp_depacketizer_0/dst_ip_addr_V] [get_bd_pins udp_packetizer_0/dst_ip_addr_V]
  connect_bd_net -net udp_depacketizer_0_dst_mac_addr_V [get_bd_pins udp_depacketizer_0/dst_mac_addr_V] [get_bd_pins udp_packetizer_0/dst_mac_addr_V]

  # Create address segments
  create_bd_addr_seg -range 0x00002000 -offset 0xC0000000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00002000 -offset 0xC0000000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x44A70000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs PmodSD_0/AXI_LITE_SPI/Reg0] SEG_PmodSD_0_Reg0
  create_bd_addr_seg -range 0x00010000 -offset 0x44A80000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs PmodSD_0/AXI_LITE_SDCS/Reg0] SEG_PmodSD_0_Reg01
  create_bd_addr_seg -range 0x00010000 -offset 0x44A50000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs aes_cipher_0/s_axi_AXILiteS/Reg] SEG_aes_cipher_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs arp_0/s_axi_ctrl/Reg] SEG_arp_0_Reg
  create_bd_addr_seg -range 0x00002000 -offset 0xC0000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00010000 -offset 0x41E00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x40000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A90000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axis_switch_out_sel/S_AXI_CTRL/Reg] SEG_axis_switch_out_sel_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A60000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axis_switch_raw_data/S_AXI_CTRL/Reg] SEG_axis_switch_raw_data_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A40000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs des_0/s_axi_AXILiteS/Reg] SEG_des_0_Reg
  create_bd_addr_seg -range 0x00040000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] SEG_dlmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x44A20000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs icmp_0/s_axi_ctrl/Reg] SEG_icmp_0_Reg
  create_bd_addr_seg -range 0x00040000 -offset 0x00000000 [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] SEG_ilmb_bram_if_cntlr_Mem
  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs m_axi_temac/Reg] SEG_m_axi_temac_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x41400000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs mdm_1/S_AXI/Reg] SEG_mdm_1_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x44A30000 [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs udp_packetizer_0/s_axi_ctrl/Reg] SEG_udp_packetizer_0_Reg
  create_bd_addr_seg -range 0x00002000 -offset 0xC0000000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0

  # Exclude Address Segments
  create_bd_addr_seg -range 0x00010000 -offset 0x44A80000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs PmodSD_0/AXI_LITE_SDCS/Reg0] SEG_PmodSD_0_Reg0
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_PmodSD_0_Reg0]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A70000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs PmodSD_0/AXI_LITE_SPI/Reg0] SEG_PmodSD_0_Reg03
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_PmodSD_0_Reg03]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A50000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs aes_cipher_0/s_axi_AXILiteS/Reg] SEG_aes_cipher_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_aes_cipher_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs arp_0/s_axi_ctrl/Reg] SEG_arp_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_arp_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x41E00000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_axi_dma_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x40000000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_axi_gpio_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A90000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axis_switch_out_sel/S_AXI_CTRL/Reg] SEG_axis_switch_out_sel_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_axis_switch_out_sel_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A60000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs axis_switch_raw_data/S_AXI_CTRL/Reg] SEG_axis_switch_raw_data_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_axis_switch_raw_data_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A40000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs des_0/s_axi_AXILiteS/Reg] SEG_des_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_des_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A20000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs icmp_0/s_axi_ctrl/Reg] SEG_icmp_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_icmp_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs m_axi_temac/Reg] SEG_m_axi_temac_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_m_axi_temac_Reg]

  create_bd_addr_seg -range 0x00001000 -offset 0x41400000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs mdm_1/S_AXI/Reg] SEG_mdm_1_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_mdm_1_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A30000 [get_bd_addr_spaces axi_dma_0/Data_MM2S] [get_bd_addr_segs udp_packetizer_0/s_axi_ctrl/Reg] SEG_udp_packetizer_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_MM2S/SEG_udp_packetizer_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A80000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs PmodSD_0/AXI_LITE_SDCS/Reg0] SEG_PmodSD_0_Reg0
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_PmodSD_0_Reg0]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A70000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs PmodSD_0/AXI_LITE_SPI/Reg0] SEG_PmodSD_0_Reg03
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_PmodSD_0_Reg03]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A50000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs aes_cipher_0/s_axi_AXILiteS/Reg] SEG_aes_cipher_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_aes_cipher_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs arp_0/s_axi_ctrl/Reg] SEG_arp_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_arp_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x41E00000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_axi_dma_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x40000000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_axi_gpio_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A90000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs axis_switch_out_sel/S_AXI_CTRL/Reg] SEG_axis_switch_out_sel_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_axis_switch_out_sel_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A60000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs axis_switch_raw_data/S_AXI_CTRL/Reg] SEG_axis_switch_raw_data_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_axis_switch_raw_data_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A40000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs des_0/s_axi_AXILiteS/Reg] SEG_des_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_des_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A20000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs icmp_0/s_axi_ctrl/Reg] SEG_icmp_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_icmp_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A00000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs m_axi_temac/Reg] SEG_m_axi_temac_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_m_axi_temac_Reg]

  create_bd_addr_seg -range 0x00001000 -offset 0x41400000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs mdm_1/S_AXI/Reg] SEG_mdm_1_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_mdm_1_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A30000 [get_bd_addr_spaces axi_dma_0/Data_S2MM] [get_bd_addr_segs udp_packetizer_0/s_axi_ctrl/Reg] SEG_udp_packetizer_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs axi_dma_0/Data_S2MM/SEG_udp_packetizer_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A70000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs PmodSD_0/AXI_LITE_SPI/Reg0] SEG_PmodSD_0_Reg0
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_PmodSD_0_Reg0]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A80000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs PmodSD_0/AXI_LITE_SDCS/Reg0] SEG_PmodSD_0_Reg03
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_PmodSD_0_Reg03]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A50000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs aes_cipher_0/s_axi_AXILiteS/Reg] SEG_aes_cipher_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_aes_cipher_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A10000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs arp_0/s_axi_ctrl/Reg] SEG_arp_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_arp_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x41E00000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_axi_dma_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x40000000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_axi_gpio_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A90000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs axis_switch_out_sel/S_AXI_CTRL/Reg] SEG_axis_switch_out_sel_Reg
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_axis_switch_out_sel_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A60000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs axis_switch_raw_data/S_AXI_CTRL/Reg] SEG_axis_switch_raw_data_Reg
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_axis_switch_raw_data_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A40000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs des_0/s_axi_AXILiteS/Reg] SEG_des_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_des_0_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A20000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs icmp_0/s_axi_ctrl/Reg] SEG_icmp_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_icmp_0_Reg]

  create_bd_addr_seg -range 0x00001000 -offset 0x41400000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs mdm_1/S_AXI/Reg] SEG_mdm_1_Reg
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_mdm_1_Reg]

  create_bd_addr_seg -range 0x00010000 -offset 0x44A30000 [get_bd_addr_spaces udp_reg_0/Data_m_axi_reg_space_V] [get_bd_addr_segs udp_packetizer_0/s_axi_ctrl/Reg] SEG_udp_packetizer_0_Reg
  exclude_bd_addr_seg [get_bd_addr_segs udp_reg_0/Data_m_axi_reg_space_V/SEG_udp_packetizer_0_Reg]



  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


