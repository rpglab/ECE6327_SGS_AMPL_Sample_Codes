# AMPL tutorial example 5 
# by Xingpeng Li
# run command: model fileName.mod; e.g. model example_5.mod;

# Use reset to clear memory for AMPL
reset;

# Declare Variable 
var x1 >= 0;
var x2 >= 0;

# Define objective function
maximize obj: x1 + x2;

# Define constraints
subject to constName: 3*x1 + 4*x2 <= 24;
subject to constName_2: 7*x1 + 4*x2 <= 28;

# Solver setting
option solver gurobi; # MINOS, cplex
option gurobi_options('mipgap=0.0 timelim=90');
solve;

# Show me the results
display x1;
display x2;

