#thank you toivoh !
# https://github.com/toivoh/tt08-demo/blob/main/src/project.sdc

read_sdc $::env(SCRIPTS_DIR)/base.sdc

# internally resynch'd
set_input_delay 1.5 -clock [get_clocks $::env(CLOCK_PORT)] {rst_n}

# Encode = uio_in[5];
# Decode = uio_in[6];
set_input_delay 1.5 -clock [get_clocks $::env(CLOCK_PORT)] {uio_in[5]}
set_input_delay 1.5 -clock [get_clocks $::env(CLOCK_PORT)] {uio_in[6]}
