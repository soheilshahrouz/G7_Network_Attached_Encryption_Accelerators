
open_project aes
set_top aes_cipher

add_files AES.cpp -cflags "-std=c++11"
add_files AES.h
add_files -tb main.cpp

open_solution "solution1"
set_part {xc7a100tcsg324-1} -tool vivado
create_clock -period 8 -name default
config_export -format ip_catalog -rtl verilog

# csynth_design
# export_design -rtl verilog -format ip_catalog