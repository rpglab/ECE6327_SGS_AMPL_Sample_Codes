# AMPL tutorial example 1
# by Xingpeng Li
# run command: model fileName.mod; e.g. model example_1.mod;

# Use reset to clear memory for AMPL
reset;

# Declare Variable 
var x;

# Define objective function
minimize obj: x;

# Define constraints
subject to constName: -1.5 <= x <= 3;

# Solver setting
option solver gurobi; # MINOS, cplex
option gurobi_options('mipgap=0.0 timelim=90');
#option show_stats 1;
solve;

# Show me the results
display x;
#printf "%.2f\n", x;
#printf "%.2f", x >> 1.txt;
