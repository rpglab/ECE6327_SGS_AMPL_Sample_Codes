# SCUC example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include SCUC_IC_e2.mod;

# Use reset to clear memory for AMPL
reset;

# Declare parameters
param c1 = 10;
param SU1 = 800;
param Pgmin1; let Pgmin1 := 40;
param Pgmax1; let Pgmax1 := 80;

param c2 = 30;
param SU2 = 100;
param Pgmin2; let Pgmin2 := 20;
param Pgmax2; let Pgmax2 := 90;

param c3 = 25;
param SU3 = 300;
param Pgmin3; let Pgmin3 := 5;
param Pgmax3; let Pgmax3 := 60;

param TLoad = 150;

# Declare Variables
var u1 binary;
var u2 binary;
var u3 binary;

var Pg1;
var Pg2;
var Pg3;

# Define objective function
minimize obj: (u1*SU1 + c1*Pg1) + (u2*SU2 + c2*Pg2) + (u3*SU3 + c3*Pg3);

# Define constraints
subject to PowerBalance: Pg1 + Pg2 + Pg3 = TLoad;
subject to genLimit_1_Min: Pgmin1*u1 <= Pg1;
subject to genLimit_1_Max: Pg1 <= Pgmax1*u1;
subject to genLimit_2_Min: Pgmin2*u2 <= Pg2;
subject to genLimit_2_Max: Pg2 <= Pgmax2*u2;
subject to genLimit_3_Min: Pgmin3*u3 <= Pg3;
subject to genLimit_3_Max: Pg3 <= Pgmax3*u3;

#fix u1 := 0;

# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display u1, u2, u3;
display Pg1, Pg2, Pg3;


