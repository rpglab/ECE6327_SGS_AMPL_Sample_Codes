# AMPL tutorial example 6 
# by Xingpeng Li
# run command: model fileName.mod; e.g. model example_6.mod;

# Use reset to clear memory for AMPL
reset;

# Declare Variable 
var x1 >= 0;
var x2 >= 0;
var x3 >= 0;

# Define objective function
maximize obj: 2*x1 + 5*x2 + x3;

# Define constraints
subject to constName: x1 + 3*x2 + 2*x3 <= 10;
subject to constName_2: 2*x1 + x2 + 5*x3 <= 8;

# Solver setting
option solver gurobi; # MINOS, cplex
option gurobi_options('mipgap=0.0 timelim=90');
solve; 

# Show me the results
display x1, x2, x3;



