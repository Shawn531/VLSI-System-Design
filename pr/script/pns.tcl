connect_pg_net -automatic

###################################
# create power ring
###################################
create_pg_ring_pattern ring_pattern_4_5 \
                       -nets {VDD VSS} \
                       -horizontal_layer metal5 -vertical_layer metal4 \
                       -horizontal_width {3} -vertical_width {3} \
                       -horizontal_spacing {0.28} -vertical_spacing {0.28} \
                       -corner_bridge true

set_pg_strategy Strategy_ring_4_5 -core \
       -pattern {{name : ring_pattern_4_5}{nets : {VSS VDD VSS VDD}}{offset : {1.8 1.8}}}

compile_pg -strategies Strategy_ring_4_5

###################################
# Create Macro Block ring
###################################
set_pg_strategy Strategy_right_macro_ring_4_5 \
       -macros IM1/i_SRAM -pattern {{name : ring_pattern_4_5}{nets :  {VSS VDD}}{offset : {1.8 1.8}}{skip_sides : 3 4}} \
       -extension {{{direction : R B}{stop : outermost_ring}}}

set_pg_strategy Strategy_left_macro_ring_4_5 \
       -macros DM1/i_SRAM -pattern {{name : ring_pattern_4_5}{nets :  {VSS VDD}}{offset : {1.8 1.8}}{skip_sides : 1 4}} \
       -extension {{{direction : L B}{stop : outermost_ring}}}

compile_pg -strategies {Strategy_right_macro_ring_4_5 Strategy_left_macro_ring_4_5}


#########################################
# create power straps 4_5 , exclude macro
#########################################
create_pg_mesh_pattern mesh_pattern_4_5 \
          -layers {{{horizontal_layer : metal5} {width : 1.2} {spacing : 0.28} {pitch : 20} {trim : true}}
                   {{vertical_layer : metal4}   {width : 1.2} {spacing : 0.28} {pitch : 20} {trim : true}}} \
          -via_rule {{intersection : all}}

set_pg_strategy Strategy_4_5 -core \
       -pattern {{name : mesh_pattern_4_5}{nets : {VSS VDD}}} \
       -blockage {{{macros :   {IM1/i_SRAM DM1/i_SRAM}}}} \
       -extension {{{nets : {VSS   VDD}}{stop : outermost_ring}}}

set_pg_strategy_via_rule via_rule_4_6 \
       -via_rule {{{{existing : ring} {layers : {metal4 metal5 metal6}}}  {via_master : default}}}

compile_pg -strategies {Strategy_4_5}


########################################
# Macro connection, M5 straps over macro
########################################
create_pg_macro_conn_pattern long_pin_pattern \
                -pin_conn_type long_pin -nets {VDD VSS} \
                -direction horizontal \
                -layers metal5 -width 2 -spacing minimum -pitch 8

set_pg_strategy Strategy_SRAM_right_macro \
       -macros IM1/i_SRAM \
       -pattern {{name : long_pin_pattern}{nets : {VDD VSS}}} \
       -extension {{{nets : {VDD VSS}}{layers : {metal5}}{direction : R}{stop : first_target}}}

set_pg_strategy Strategy_SRAM_left_macro \
       -macros DM1/i_SRAM \
       -pattern {{name : long_pin_pattern}{nets : {VDD VSS}}} \
       -extension {{{nets : {VDD VSS}}{layers : {metal5}}{direction : L}{stop : first_target}}}

compile_pg -strategies {Strategy_SRAM_right_macro Strategy_SRAM_left_macro}


###################################
# create power rails
###################################
create_pg_std_cell_conn_pattern rail_pattern -layers {metal1}

set_pg_strategy power_rails -core \
   -pattern   {{name: rail_pattern}{nets: VSS VDD}} \
   -extension {{{stop : outermost_ring}}} \
   -blockage  {{{macros_with_keepout :   {IM1/i_SRAM  DM1/i_SRAM}}}}

compile_pg -strategies power_rails



check_pg_drc
check_pg_missing_vias
check_pg_connectivity