# AMPL tutorial example 8
# by Xingpeng Li
# run command: model fileName.mod; e.g. model example_8.mod;

# Use reset to clear memory for AMPL
reset;

# Declare Variable 
var x1;
var x2;

# Define objective function
maximize obj: 0;

# Define constraints
subject to constName:    3*x1 + 2*x2 = 9;
subject to constName_2:  x1 + 6*x2 = -7;

# Solver setting
option solver gurobi; # MINOS, cplex
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display x1;
display x2;
