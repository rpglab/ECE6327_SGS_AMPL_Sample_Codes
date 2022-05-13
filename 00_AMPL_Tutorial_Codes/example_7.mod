# AMPL tutorial example 7 
# by Xingpeng Li
# run command: model fileName.mod; e.g. model example_7.mod;

# Use reset to clear memory for AMPL
reset;

# Declare set
set I; # an index list for constraints
set J; # an index list for variables (x)

# Declare Parameter
param a {I, J};
param b {I};
param c {J};

# Declare Variable
var x {J} >= 0;

# Define objective function
maximize obj: sum{j in J}c[j]*x[j];

# Define constraints
subject to constName{i in I} : sum{j in J}(a[i,j]*x[j]) <= b[i];


############# Load data - multiple options are available
### option 1
#data example_7_w_Ex5_Data_all_in_one.txt;  # for example 5
data example_7_w_Ex6_Data_all_in_one.txt;  # for example 6

### option 2
#data; include example_7_w_Ex5_Data_all_in_one.txt;  # for example 5
#data; include example_7_w_Ex6_Data_all_in_one.txt;  # for example 6

### option 3
#data;
#include example_7_w_Ex5_Data_a.txt;
#include example_7_w_Ex5_Data_b.txt;
#include example_7_w_Ex5_Data_c.txt;

### option 4
#data example_7_w_Ex5_Data_a.txt;
#data example_7_w_Ex5_Data_b.txt;
#data example_7_w_Ex5_Data_c.txt;

### option 5 
#data;
#param: I: b := include example_7_w_Ex5_Data_b_noTitle.txt;
#param: J: c := include example_7_w_Ex5_Data_c_noTitle.txt;
#include example_7_w_Ex5_Data_a.txt;


# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display x;



