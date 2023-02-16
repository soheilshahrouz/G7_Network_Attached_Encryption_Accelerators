
open_project icmp
set_top icmp

add_files icmp.cpp -cflags "-std=c++11"
add_files ../network.h
add_files ../network.cpp -cflags "-std=c++11"

open_solution "solution1"
set_part {xc7a100tcsg324-1} -tool vivado
create_clock -period 8 -name default
config_export -format ip_catalog -rtl verilog

csynth_design
export_design -rtl verilog -format ip_catalog