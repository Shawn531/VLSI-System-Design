set sdc_version 1.2
current_design top
create_clock [get_ports {cpu_clk}] -name cpu_clk -period 10.0 -waveform {0 5.0}
create_clock [get_ports {axi_clk}] -name axi_clk -period 25.0 -waveform {0 12.5}
create_clock [get_ports {rom_clk}] -name rom_clk -period 50.2 -waveform {0 25.1}
create_clock [get_ports {dram_clk}] -name dram_clk -period 30.4 -waveform {0 15.2}
create_clock [get_ports {sram_clk}] -name sram_clk -period 11.0 -waveform {0 5.5}

set_clock_groups -asynchronous -group {cpu_clk} -group {axi_clk} -group {rom_clk} -group {dram_clk} -group {sram_clk}
set_clock_uncertainty  -setup 0.5  [get_clocks {cpu_clk axi_clk rom_clk dram_clk sram_clk}]
set_clock_uncertainty  -hold 0.02  [get_clocks {cpu_clk axi_clk rom_clk dram_clk sram_clk}]

# cpu_clk
set_input_delay  -max 5.0  -clock cpu_clk [remove_from_collection [all_inputs] [get_ports {cpu_clk}]]
set_input_delay  -min 0.0  -clock cpu_clk [remove_from_collection [all_inputs] [get_ports {cpu_clk}]]
set_output_delay -max 5.0  -clock cpu_clk [all_outputs]
set_output_delay -min 0.0  -clock cpu_clk [all_outputs]

# axi_clk
set_input_delay  -max 12.5 -clock axi_clk [remove_from_collection [all_inputs] [get_ports {axi_clk}]]
set_input_delay  -min 0.0 -clock axi_clk [remove_from_collection [all_inputs] [get_ports {axi_clk}]]
set_output_delay -max 12.5 -clock axi_clk [all_outputs]
set_output_delay -min 0.0 -clock axi_clk [all_outputs]

# sram_clk
set_input_delay  -max 5.5 -clock sram_clk [remove_from_collection [all_inputs] [get_ports {sram_clk}]]
set_input_delay  -min 0.0 -clock sram_clk [remove_from_collection [all_inputs] [get_ports {sram_clk}]]
set_output_delay -max 5.5 -clock sram_clk [all_outputs]
set_output_delay -min 0.0 -clock sram_clk [all_outputs]

# rom_clk
set_input_delay  -max 25.1 -clock rom_clk [remove_from_collection [all_inputs] [get_ports {rom_clk}]]
set_input_delay  -min 0.0 -clock rom_clk [remove_from_collection [all_inputs] [get_ports {rom_clk}]]
set_output_delay -max 25.1 -clock rom_clk [all_outputs]
set_output_delay -min 0.0 -clock rom_clk [all_outputs]

# dram_clk
set_input_delay  -max 15.2 -clock dram_clk [remove_from_collection [all_inputs] [get_ports {dram_clk}]]
set_input_delay  -min 0.0 -clock dram_clk [remove_from_collection [all_inputs] [get_ports {dram_clk}]]
set_output_delay -max 15.2 -clock dram_clk [all_outputs]
set_output_delay -min 0.0 -clock dram_clk [all_outputs]



set_drive 0.1 [all_inputs]
set_load -pin_load 20 [all_outputs]

set_max_fanout 20 [all_inputs]
set_clock_latency 2 [get_clocks {cpu_clk axi_clk rom_clk dram_clk sram_clk}]

change_names -hierarchy -rules verilog
define_name_rules name_rule -allowed "A-Z a-z 0-9 _" -max_length 255 -type cell
define_name_rules name_rule -allowed "A-Z a-z 0-9 _[]" -max_length 255 -type net
define_name_rules name_rule -map {{"\\*cell\\*" "cell"}}
define_name_rules name_rule -case_insensitive
change_names -hierarchy -rules name_rule
