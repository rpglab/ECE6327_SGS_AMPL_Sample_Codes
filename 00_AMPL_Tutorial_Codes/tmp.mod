# Use reset to clear memory for AMPL
reset;

# Declare Variable 
var x;
var y;

maximize obj: 0;

# Define constraints
subject to constName:    x*x + 2*y = 3;
subject to constName_2:  y*y - x*y = 1;

# Solver setting
option solver minos; # MINOS, cplex
solve; 

# Show me the results
display x, y;
