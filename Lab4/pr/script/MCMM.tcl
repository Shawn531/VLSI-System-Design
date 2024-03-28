set REPORTS_DIR "rpt_icc2"
if !{[file exists $REPORTS_DIR]} {file mkdir $REPORTS_DIR} 
set OUTPUTS_DIR "./outputs_icc2" 
if !{[file exists $OUTPUTS_DIR]} {file mkdir $OUTPUTS_DIR}
puts "source: Running script [info script]\n"

set mode_constraints(Mfunc)                                "" ;
set corner_constraints(max)        "../script/corner_max.tcl" ;
set corner_constraints(min)        "../script/corner_min.tcl" ;

set scenario_constraints(Mfunc:max)       "../script/APR.sdc" ;
set scenario_constraints(Mfunc:min)       "../script/APR.sdc" ;


########################################
## Create modes, corners, and scenarios first
########################################
remove_modes -all; remove_corners -all; remove_scenarios -all

foreach m [array name mode_constraints] {
    puts "RM-info: create_mode $m"
    create_mode $m
}

foreach c [array name corner_constraints] {
    puts "RM-info: create_corner $c"
    create_corner $c
}

foreach s [array name scenario_constraints] {
    set m [lindex [split $s :] 0]
    set c [lindex [split $s :] end]
    create_scenario -name $s -mode $m -corner $c
}

########################################
## Populate constraints 
########################################
## Populate mode contraints
foreach m [array name mode_constraints] {
    current_mode $m
    current_scenario [index_collection [get_scenarios -mode $m] 0] 
    # ensures a current_scenario exists in case provided mode constraints are actually scenario specific
    if { [file exist $mode_constraints($m)] == 1} {
        puts "RM-info: current_mode $m"
        puts "RM-info: source $mode_constraints($m)"
        source -echo $mode_constraints($m)
    }
}

## Populate corner contraints
#  Please ensure parasitics are assigned to the corners properly
foreach c [array name corner_constraints] {
    current_corner $c
    current_scenario [index_collection [get_scenarios -corner $c] 0] 
    # ensures a current_scenario exists in case provided corner constraints are actually scenario specific

    puts "RM-info: current_corner $c"
    puts "RM-info: source $corner_constraints($c)"
    source -echo $corner_constraints($c)

    # pls ensure $corner_constraints($c) includes set_parasitic_parameters command for the corresponding corner,
    # for example, set_parasitic_parameters -late_spec $parasitics1 -early_spec $parasitics2,
    # where the command points to the parasitics read by the read_parasitic_tech commands.
    # Specify TCL_PARASITIC_SETUP_FILE in icc2_common_setup.tcl for your read_parasitic_tech commands.
    # read_parasitic_tech_example.tcl is provided as an example.
}

## Populate scenario constraints
foreach s [array name scenario_constraints] {
    current_scenario $s
    puts "RM-info: current_scenario $s"
    puts "RM-info: source $scenario_constraints($s)"
    source -echo $scenario_constraints($s)
}
current_scenario Mfunc:max

########################################
## Configure analysis settings for scenarios
########################################
# Below are just examples to show usage of set_scenario_status (actual usage shold depend on your objective)
# scenario1 is a setup scenario and scenario2 is a hold scenario

set_scenario_status {*:max*} -setup true -hold true -leakage_power true -dynamic_power true
set_scenario_status {*:min*} -setup false -hold true -leakage_power false -dynamic_power false

#set_scenario_status $scenario1 -none -setup true -hold false -leakage_power true -dynamic_power true -max_transition true -max_capacitance true -min_capacitance false -active true
#set_scenario_status $scenario3 -none -setup true -hold false -leakage_power true -dynamic_power true -max_transition true -max_capacitance true -min_capacitance false -active true
#set_scenario_status $scenario2 -none -setup false -hold true -leakage_power true -dynamic_power false -max_transition true -max_capacitance false -min_capacitance true -active true
#set_scenario_status $scenario4 -none -setup false -hold true -leakage_power true -dynamic_power false -max_transition true -max_capacitance false -min_capacitance true -active true


redirect -file ${REPORTS_DIR}/report_scenarios.rpt {report_scenarios} 

## Note :
#  To remove duplicate modes, corners, and scenarios, and to improve runtime and capacity,
#  without loss of constraints, try the following command :
#    remove_duplicate_timing_contexts

puts "RM-info: Completed script [info script]\n"