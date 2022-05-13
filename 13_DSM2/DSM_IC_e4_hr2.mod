# DSM example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include DSM_IC_e4_hr2.mod; 

# Use reset to clear memory for AMPL
reset;

# Declare set
set GEN; # an index list for generator
set PERIOD; # an index list for time intervals

# Parameters
param nT; # number of periods
param BigM   = 10^3; 

# Generator data
param gen_min {GEN};
param gen_max {GEN};
param gen_RRlimit {GEN};
param gen_OpCost {GEN};
param gen_NlCost {GEN};
param gen_SuCost {GEN};

# Period data
param Time_TotalPd {PERIOD};
param DSM_d = 10;  # from hr1 results
param gen_Init {GEN}; # from hr1 results

# Declare Variable
var Pg {GEN, PERIOD};

# Define objective function
minimize obj: sum{g in GEN, t in PERIOD} (gen_OpCost[g]*Pg[g,t] + gen_NlCost[g]);

# Define constraints
subject to PowerBalance1{t in PERIOD}: sum{g in GEN}Pg[g,t] = Time_TotalPd[t] + DSM_d;
subject to genLimit_Min {g in GEN, t in PERIOD}: gen_min[g] <= Pg[g,t];
subject to genLimit_Max {g in GEN, t in PERIOD}: Pg[g,t] <= gen_max[g];
subject to genRRLimit_Up {g in GEN, t in PERIOD}: Pg[g,t] - gen_Init[g] <= gen_RRlimit[g];
subject to genRRLimit_Dn {g in GEN, t in PERIOD}: gen_Init[g] - Pg[g,t] <= gen_RRlimit[g];


# Load data
data DSM_IC_e4_hr2_data.txt;

let nT := 0;
for {t in PERIOD} let nT := nT + 1;

# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display Pg;

