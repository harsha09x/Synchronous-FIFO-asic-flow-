#==============================================================================
# Synopsys Design Constraints (SDC)
# Target: chip_top | Technology: SCL 180nm
#==============================================================================

#------------------------------------------------------------------------------
# Constraint Section 1 — Clock Definition
#------------------------------------------------------------------------------
# A 100 MHz clock (10 ns period, 50 % duty cycle) is defined at the external 
# pad boundary (PAD_CLK), which is the true entry point of the clock into the chip. 
# Defining the clock at the pad rather than at an internal port is mandatory when 
# a pad wrapper is used, because it accurately models the latency introduced by 
# the input pad cell.
create_clock -name CLK \
             -period 10 \
             -waveform {0 5} \
             [get_ports PAD_CLK]

#------------------------------------------------------------------------------
# Constraint Section 2 — Clock Source Latency
#------------------------------------------------------------------------------
# Clock source latency models the delay between the real clock source (e.g., 
# an on-board oscillator or PLL) and the chip pad. Early/Late values bound 
# the arrival-time uncertainty at the source.
set_clock_latency -source -early 0.30 [get_clocks CLK]
set_clock_latency -source -late  0.50 [get_clocks CLK]

#------------------------------------------------------------------------------
# Constraint Section 3 — Clock Network Latency
#------------------------------------------------------------------------------
# Before Clock Tree Synthesis (CTS), the physical clock buffer tree does not yet 
# exist. The tool uses an estimated insertion delay to perform meaningful 
# pre-CTS timing analysis and to guide placement optimization.
# Pre-CTS estimated insertion delay
set_clock_latency -early 0.80 [get_clocks CLK]
set_clock_latency -late  1.20 [get_clocks CLK]

#------------------------------------------------------------------------------
# Constraint Section 4 — Clock Uncertainty (Jitter + Skew)
#------------------------------------------------------------------------------
# Clock uncertainty derates the timing budget to account for clock jitter 
# and skew that cannot be modeled deterministically.
set_clock_uncertainty -setup 0.20 [get_clocks CLK]
set_clock_uncertainty -hold  0.10 [get_clocks CLK]

#------------------------------------------------------------------------------
# Constraint Section 5 — Input Timing Constraints
#------------------------------------------------------------------------------
# Input delay constraints model the logic delay in the upstream device that 
# drives the chip. They tell the synthesis tool how much of the clock period 
# is consumed before the signal arrives at the chip input pads.
set_input_delay -min 0.50 -clock CLK [get_ports {PAD_DIN[*] PAD_WR_EN PAD_RD_EN}]
set_input_delay -max 2.50 -clock CLK [get_ports {PAD_DIN[*] PAD_WR_EN PAD_RD_EN}]

#------------------------------------------------------------------------------
# Constraint Section 6 — Output Timing Constraints
#------------------------------------------------------------------------------
# Output delay constraints model the setup requirement of the downstream 
# receiving device.
set_output_delay -min 0.40 -clock CLK [get_ports {PAD_DOUT[*] PAD_FULL PAD_EMPTY}]
set_output_delay -max 2.00 -clock CLK [get_ports {PAD_DOUT[*] PAD_FULL PAD_EMPTY}]

#------------------------------------------------------------------------------
# Constraint Section 7 — Driving Cell Model
#------------------------------------------------------------------------------
# The driving cell constraint tells the synthesizer what cell drives the chip's 
# input pads from outside, which establishes the transition time at the pad input.
set_driving_cell -lib_cell inv0d2 [get_ports {PAD_DIN[*] PAD_WR_EN PAD_RD_EN PAD_RSTN}]

#------------------------------------------------------------------------------
# Constraint Section 8 — Output Load
#------------------------------------------------------------------------------
# Output load models the capacitance of the PCB trace and the input capacitance 
# of downstream devices seen by each output pad.
set_load 5.0 [get_ports {PAD_DOUT[*] PAD_FULL PAD_EMPTY}]

#------------------------------------------------------------------------------
# Constraint Section 9 — Clock Transition
#------------------------------------------------------------------------------
# The clock transition constraint specifies the slew rate of the incoming clock 
# signal at the chip pad, which directly impacts jitter and hold-time margins.
set_clock_transition 0.10 [get_clocks CLK]

#------------------------------------------------------------------------------
# Constraint Section 10 — Design Rule Constraints
#------------------------------------------------------------------------------
# These constraints set global limits on transition time and fanout, tuned for 
# the SCL 180 nm process. Violations of these constraints are treated as 
# design-rule violations (DRVs) that must be repaired during synthesis and optimization.
set_max_transition 1.50 [current_design]
set_max_fanout     16   [current_design]

#==============================================================================
# END OF SDC
#==============================================================================
