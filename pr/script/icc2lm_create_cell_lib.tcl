###############################################################
#  Generated by:      YONG-SHENG LIU (David)
#  Generated date:    2023/12/7
#  Design:            
#  Command:           # Using icc2 library manager
#                     (1) icc2_lm_shell -gui 
#                     (2) icc2_lm_shell -file icc2lm_create_cell_lib.tcl
###############################################################
set TechSearchPath /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/CIC/ICC/
set CoreSearchPath /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/FrontEnd/synopsys/
set IOSearchPath /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2008Q3v1.2/T33_GENERIC_IO/FrontEnd/synopsys/
set MemoryPath ../../sim/SRAM\ ../../sim/data_array\ ../../sim/tag_array
set search_path "$TechSearchPath $CoreSearchPath $IOSearchPath $MemoryPath"


# flow to automatically analyze the library source file
create_workspace STD_LIB -flow exploration \
                         -technology umc_018_1p6m_mk_20ka_cic.tf

set_attribute [get_site_defs unit] is_default true
set_attribute [get_site_defs unit] symmetry {Y}

# set metal from tech file
# track offset found in /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/BackEnd/lef/header6_V55.lef
set_attribute [get_layers {metal1 metal3 metal5}] routing_direction horizontal
set_attribute [get_layers {metal2 metal4 metal6}] routing_direction vertical
set_attribute [get_layers {metal1}] track_offset 0.28
set_attribute [get_layers {metal2}] track_offset 0.31
set_attribute [get_layers {metal3}] track_offset 0.28
set_attribute [get_layers {metal4}] track_offset 0.31
set_attribute [get_layers {metal5}] track_offset 0.28
set_attribute [get_layers {metal6}] track_offset 0.31


read_db { fsa0m_a_generic_core_ss1p62v125c.db \
          fsa0m_a_generic_core_ff1p98vm40c.db \
          fsa0m_a_t33_generic_io_ss1p62v125c.db \
          fsa0m_a_t33_generic_io_ff1p98vm40c.db \
          SRAM_WC.db        SRAM_BC.db \
          data_array_WC.db  data_array_BC.db \
          tag_array_WC.db   tag_array_BC.db \
        }

read_lef { /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2009Q2v2.0/GENERIC_CORE/BackEnd/lef/fsa0m_a_generic_core.lef \
           /usr/cad/CBDK/CBDK018_UMC_Faraday_v1.0/orig_lib/fsa0m_a/2008Q3v1.2/T33_GENERIC_IO/BackEnd/lef/fsa0m_a_t33_generic_io.6.lef \
           SRAM.lef \
           data_array.lef \
           tag_array.lef \
         }

report_workspace
group_libs
process_workspaces -directory ../u18_cell_lib
exit