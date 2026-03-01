# ============================================================
# CLOCK DEFINITIONS
# ============================================================

# 50 MHz clock
create_clock -name CLK_50MHz -period 20.000 [get_ports {CLK_50MHz}]

# 16 MHz clock
create_clock -name CLK_16MHz -period 62.500 [get_ports {CLK_16MHz}]


# ============================================================
# CLOCK GROUPS (asynchronous domains)
# ============================================================

set_clock_groups -asynchronous \
    -group {CLK_50MHz} \
    -group {CLK_16MHz}


# ============================================================
# UART RX ASYNCHRONOUS INPUT
# ============================================================

# RX is asynchronous relative to system clock
set_false_path -from [get_ports {p46}]


# ============================================================
# CDC PROTECTION (2FF synchronizer protection)
# ============================================================

# Prevent optimization merging of synchronizer flops
set_false_path \
   -from [get_registers {*|r_Rx_meta}] \
   -to   [get_registers {*|r_Rx_stable}]


# ============================================================
# OPTIONAL: Cut timing from async input to rest of logic
# ============================================================

set_false_path \
   -from [get_ports {p46}] \
   -to   [get_registers {*}]