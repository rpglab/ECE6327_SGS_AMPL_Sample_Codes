# DCOPF example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include DCOPF_IC_e4.mod;

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


# Declare Variables
var G1;
var G3;


# Define objective function
minimize obj: c1*G1 + c3*G3;

# Define constraints
subject to SysWidePowerBalance_1: G1 + G3 = Load2;
subject to genLimit_1: Pgmin1 <= G1 <= Pgmax1;
subject to genLimit_3: Pgmin3 <= G3 <= Pgmax3;

# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display G1, G3;














