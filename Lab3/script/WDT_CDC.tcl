#spyglass shell source tcl code
#In the Spyglass shell type "source ../script/Spyglass_CDC.tcl" to execute script

#import design
read_file -type sgdc ../script/WDT_CDC.sgdc
read_file -type verilog ../src/WDT.sv
set_option enableSV yes
#set_option ignoredu {tag_array data_array SRAM}
set_option incdir {../include ../src ../src/AXI ../sim/data_array ../sim/SRAM ../sim/tag_array}

#read design
current_goal Design_Read -alltop
link_design -force

#start CDC verification
#current_goal cdc/cdc_setup_check -alltop
#run_goal

#current_goal cdc/clock_reset_integrity -alltop
#run_goal

current_goal cdc/cdc_verify_struct -alltop
run_goal

current_goal cdc/cdc_verify -alltop
run_goal

current_goal cdc/cdc_abstrast -alltop
run_goal