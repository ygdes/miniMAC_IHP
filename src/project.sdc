read_sdc $::env(SCRIPTS_DIR)/base.sdc

set_input_delay 1.5 -clock [get_clocks $::env(CLOCK_PORT)] {rst_n}  # internally resynch'd
#set_input_delay 1.5 -clock [get_clocks $::env(CLOCK_PORT)] {ui_in}
