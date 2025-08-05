# Create the working library
vlib work

# Compile the design wrapper and testbench
vlog wrapper.v       ;# Top-level design module (SPI_Slave is instantiated here)
vlog SPI_tb.v        ;# Testbench for wrapper

# Load the simulation for the testbench
vsim -voptargs=+acc work.SPI_tb

# Add all signals recursively to the waveform
add wave -r *

# Run the simulation until it ends
run -all

# Optional: Exit after simulation
# quit -sim
