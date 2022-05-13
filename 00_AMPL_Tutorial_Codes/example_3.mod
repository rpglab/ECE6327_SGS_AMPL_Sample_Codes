# AMPL tutorial example 3 
# by Xingpeng Li
# run command: model fileName.mod; e.g. model example_3.mod;

# Use reset to clear memory for AMPL
reset;

# Declare Variable 
var x integer;

# Define objective function
minimize obj: x;

# Define constraints
subject to constName: -1.5 <= x <= 3;

# Solver setting
option solver gurobi; # MINOS, cplex
option gurobi_options('mipgap=0.0 timelim=90');
solve; 


