# AMPL tutorial example 2
# by Xingpeng Li
# run command: model fileName.mod; e.g. model example_2.mod;

# Use reset to clear memory for AMPL
reset;

# Declare Variable 
var x >= 0;

# Define objective function
minimize obj: x;

# Define constraints
subject to constName: -1.5 <= x <= 3;

# Solver setting
option solver gurobi; # MINOS, cplex
option gurobi_options('mipgap=0.0 timelim=90');

solve;

