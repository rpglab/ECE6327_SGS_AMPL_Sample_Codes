# DCOPF example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include DCOPF_IC_e1.mod;

# Use reset to clear memory for AMPL
reset;


# Declare parameters
param c1; let c1 := 10;
param Pgmin1; let Pgmin1 := 20;
param Pgmax1; let Pgmax1 := 70;

param c3; let c3 := 20;
param Pgmin3; let Pgmin3 := 40;
param Pgmax3; let Pgmax3 := 90;

param Load2 = 100;

param x; let x := 0.1;
param branchRate1; let branchRate1 := 60;
param branchRate2; let branchRate2 := 100;
param branchRate3; let branchRate3 := 100;

param MWbase = 100;

# Declare Variables
var G1;
var G3;

var pk1;
var pk2;
var pk3;

var theta1;
var theta2;
var theta3;


# Define objective function
minimize obj: c1*G1 + c3*G3;


# Define constraints
subject to branchLimit_1: -branchRate1 <= pk1 <= branchRate1;
subject to branchLimit_2: -branchRate2 <= pk2 <= branchRate2;
subject to branchLimit_3: -branchRate3 <= pk3 <= branchRate3;
          
subject to lineFlow_1: pk1 = (theta1 - theta2)/x;      # Note that this is incorrect
subject to lineFlow_2: pk2 = (theta1 - theta3)/x;      # Note that this is incorrect
subject to lineFlow_3: pk3 = (theta2 - theta3)/(2*x);  # Note that this is incorrect

subject to PowerBalance_1: G1 - pk1 - pk2 = 0;
subject to PowerBalance_2: pk1 - pk3 = Load2;
subject to PowerBalance_3: G3 + pk2 + pk3 = 0;

subject to genLimit_1: Pgmin1 <= G1 <= Pgmax1;
subject to genLimit_3: Pgmin3 <= G3 <= Pgmax3;

fix theta3 := 0;

# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display G1, G3;
display pk1, pk2, pk3;
display theta1, theta2, theta3;














