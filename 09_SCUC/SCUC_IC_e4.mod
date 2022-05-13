# SCUC example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include SCUC_IC_e4.mod;

# Use reset to clear memory for AMPL
reset;

# Declare parameters
param BigM   = 10^3; 

param c1 = 10;
param SU1 = 800;
param NL1 = 100;
param RR1 = 25;
param Pgmin1; let Pgmin1 := 40;
param Pgmax1; let Pgmax1 := 80;

param c2; let c2 := 30;
param SU2 = 100;
param NL2 = 50;
param RR2 = 30;
param Pgmin2; let Pgmin2 := 20;
param Pgmax2; let Pgmax2 := 90;

param TLoad_H1 = 70;
param TLoad_H2 = 110;

# Declare Variables
var u1_H1 binary;
var u1_H2 binary;
var u2_H1 binary;
var u2_H2 binary;

var v1_H1 binary;
var v1_H2 binary;
var v2_H1 binary;
var v2_H2 binary;

var Pg1_H1;
var Pg1_H2;
var Pg2_H1;
var Pg2_H2;

# Define objective function
minimize obj: (c1*Pg1_H1 + c1*Pg1_H2 + c2*Pg2_H1 + c2*Pg2_H2) 
             + (NL1*u1_H1 + NL1*u1_H2 + NL2*u2_H1 + NL2*u2_H2)
             + (SU1*v1_H1 + SU1*v1_H2 + SU2*v2_H1 + SU2*v2_H2);
             
# Define constraints
subject to PowerBalance_H1: Pg1_H1 + Pg2_H1 = TLoad_H1;
subject to PowerBalance_H2: Pg1_H2 + Pg2_H2 = TLoad_H2;

subject to genLimit_1_Min_H1: Pgmin1*u1_H1 <= Pg1_H1;
subject to genLimit_1_Min_H2: Pgmin1*u1_H2 <= Pg1_H2;

subject to genLimit_1_Max_H1: Pg1_H1 <= Pgmax1*u1_H1;
subject to genLimit_1_Max_H2: Pg1_H2 <= Pgmax1*u1_H2;

#subject to genRRLimit_1_H2_Up: Pg1_H2 - Pg1_H1 <= RR1*u1_H2;
#subject to genRRLimit_1_H2_Dn: Pg1_H1 - Pg1_H2 <= RR1*u1_H2;
subject to genRRLimit_1_H2_Up: Pg1_H2 - Pg1_H1 <= RR1*u1_H1 + BigM*v1_H2;
subject to genRRLimit_1_H2_Dn: Pg1_H1 - Pg1_H2 <= RR1*u1_H2 + BigM*(v1_H2-u1_H2+u1_H1);

subject to genVU_1_cnstrnt2_H1: v1_H1 >= u1_H1;
subject to genVU_1_cnstrnt2_H2: v1_H2 >= u1_H2 - u1_H1;

subject to genLimit_2_Min_H1: Pgmin2*u2_H1 <= Pg2_H1;
subject to genLimit_2_Min_H2: Pgmin2*u2_H2 <= Pg2_H2;

subject to genLimit_2_Max_H1: Pg2_H1 <= Pgmax2*u2_H1;
subject to genLimit_2_Max_H2: Pg2_H2 <= Pgmax2*u2_H2;

#subject to genRRLimit_2_H2_Up: Pg2_H2 - Pg2_H1 <= RR2*u2_H2;
#subject to genRRLimit_2_H2_Dn: Pg2_H1 - Pg2_H2 <= RR2*u2_H2;
subject to genRRLimit_2_H2_Up: Pg2_H2 - Pg2_H1 <= RR2*u2_H1 + BigM*v2_H2;
subject to genRRLimit_2_H2_Dn: Pg2_H1 - Pg2_H2 <= RR2*u2_H2 + BigM*(v2_H2-u2_H2+u2_H1);

subject to genVU_2_cnstrnt2_H1: v2_H1 >= u2_H1;
subject to genVU_2_cnstrnt2_H2: v2_H2 >= u2_H2 - u2_H1;

# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display v1_H1, u1_H1, Pg1_H1, v1_H2, u1_H2, Pg1_H2;
display v2_H1, u2_H1, Pg2_H1, v2_H2, u2_H2, Pg2_H2;


