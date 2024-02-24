###################################################################

# Created by write_sdc on Sat Oct 28 14:53:34 2023

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions -max WCCOM -max_library                               \
fsa0m_a_generic_core_ss1p62v125c\
                         -min BCCOM -min_library                               \
fsa0m_a_generic_core_ff1p98vm40c
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports clk]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports rst]
set_max_fanout 6 [get_ports clk]
set_max_fanout 6 [get_ports rst]
set_ideal_network [get_ports clk]
create_clock [get_ports clk]  -period 8  -waveform {0 4}
set_clock_latency 1  [get_clocks clk]
set_clock_uncertainty 0.1  [get_clocks clk]
set_input_delay -clock clk  -max 4  [get_ports rst]
set_input_delay -clock clk  -min 0  [get_ports rst]
