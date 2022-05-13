# SUC example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include SUC_IC_e1.mod;

# Use reset to clear memory for AMPL
reset;

# Declare parameters
param c1 = 10;
param SU1 = 800;
param Pgmin1; let Pgmin1 := 40;
param Pgmax1; let Pgmax1 := 80;

param c2; let c2 := 30;
param SU2 = 100;
param Pgmin2; let Pgmin2 := 20;
param Pgmax2; let Pgmax2 := 90;

param TLoad = 120;
param SolarPg = 50;

# Declare Variables
var u1 binary;
var u2 binary;

var Pg1;
var Pg2;

# Define objective function
minimize obj: (u1*SU1 + c1*Pg1) + (u2*SU2 + c2*Pg2);

# Define constraints
subject to PowerBalance: Pg1 + Pg2 = TLoad - SolarPg;
subject to genLimit_1_Min: Pgmin1*u1 <= Pg1;
subject to genLimit_1_Max: Pg1 <= Pgmax1*u1;
subject to genLimit_2_Min: Pgmin2*u2 <= Pg2;
subject to genLimit_2_Max: Pg2 <= Pgmax2*u2;

# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display u1, u2;
display Pg1, Pg2;


