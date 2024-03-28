###############################################################
#  Generated by:      YONG-SHENG LIU (David)
#  Generated date:    2023/12/8
#  Design:            
#  Command:           (1) Just basic version without IO PAD setup.
###############################################################

###############################
#     stage 1:  floorplan     #
###############################
initialize_floorplan -honor_pad_limit -core_offset {300} -core_utilization 0.8

# found in io.lef
# create_io_ring -name ioring -corner_height 235.6

# place io ring (coner_PAD.tcl)
# create_cell {cornerLL cornerLR cornerUL cornerUR} CORNERC
# create_io_corner_cell -cell cornerLL  {ioring.bottom ioring.left}
# create_io_corner_cell -cell cornerUL  {ioring.left ioring.top}
# create_io_corner_cell -cell cornerUR  {ioring.top ioring.right}
# create_io_corner_cell -cell cornerLR  {ioring.right ioring.bottom}

# place macro
set all_macros [get_cells -hierarchical -filter "is_hard_macro && !is_physical_only"]
create_keepout_margin -type hard -outer {10 0 10 0} $all_macros
set_app_options -name place.coarse.fix_hard_macros -value false
set_app_options -name plan.place.auto_create_blockages -value auto

create_placement -floorplan
#source ../scripts/mv_macro.tcl
set_fixed_objects $all_macros
set_app_options -name place.coarse.continue_on_missing_scandef -value true

source -echo ../script/pns.tcl
create_placement -incremental

save_block
save_block -as CHIP:design_planning.design
save_lib



###############################
#     stage 2:  placement     #
###############################
set_app_options -name time.delay_calculation_style -value zero_interconnect
report_timing
set_app_options -name time.delay_calculation_style -value auto

check_design -check pre_placement_stage
remove_ideal_network -all
set_app_options -name place_opt.final_place.effort -value high
set_app_options -name opt.timing.effort -value high

place_opt


report_timing
report_power
connect_pg_net

report_timing -sign 4 > placement_setup.log
report_timing -sign 4 -delay_type min > placement_hold.log


# check drc again after placement. If have any error, something setup wrong
# but it doesn't indicate that fault will cause the timing violation
check_pg_drc
check_pg_missing_vias
check_pg_connectivity

save_block
save_block -as CHIP:placement.design
save_lib



###############################
#     stage 3:    CTS         #
###############################
report_clocks
report_clocks -skew
report_clocks -groups
report_clock_qor

report_ports [get_ports {cpu_clk axi_clk rom_clk dram_clk sram_clk}]
check_design -checks pre_clock_tree_stage

#source -echo ../scripts/cts_setup.tcl
clock_opt

report_timing
report_timing -sign 4 > cts_setup.log
report_timing -sign 4 -delay_type min > cts_hold.log

save_block
save_block -as CHIP:cts.design
save_lib



###############################
#     stage 3:    route       #
###############################
# if CTS slack < 0, can use following command optimize in route stage
set_app_options -name  route_opt.flow.enable_ccd  -value true
route_auto
route_opt

report_timing
report_timing -sign 4 -sort_by group > route_setup.log
report_timing -sign 4 -delay_type min -sort_by group > route_hold.log

save_block
save_block -as CHIP:route.design
save_lib



###############################
#     stage 4:  output file   #
###############################
write_verilog -exclude { scalar_wire_declarations \
                         leaf_module_declarations \
                         pg_objects \
                         end_cap_cells \
                         well_tap_cells \
                         filler_cells \
                         pad_spacer_cells \
                         physical_only_cells \
                         cover_cells \
                       } ../top_pr.v
write_sdf ../top_pr.sdf

report_power > total_power.log
report_qor > total_area.log