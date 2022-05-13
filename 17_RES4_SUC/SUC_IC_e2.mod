# SUC example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include SUC_IC_e2.mod;

# Use reset to clear memory for AMPL
reset;

# Declare set
set GEN; # an index list for generator
set PERIOD; # an index list for time intervals
set SCENARIO; # an index list for scenarios

# Generator data
param gen_min {GEN};
param gen_max {GEN};
param gen_OpCost {GEN};
param gen_SuCost {GEN};

# Period data
param Time_TotalPd {PERIOD};

# Scenario data
param SolarProb {SCENARIO};
param SolarTotalP {SCENARIO};

# Declare Variable
var u {GEN, PERIOD} binary;
var Pg {GEN, PERIOD, SCENARIO};

# Define objective function
minimize obj: sum{g in GEN, t in PERIOD, s in SCENARIO} SolarProb[s]*(gen_OpCost[g]*Pg[g,t,s] + gen_SuCost[g]*u[g,t]);
             
# Define constraints
subject to PowerBalance {t in PERIOD, s in SCENARIO}: sum{g in GEN} Pg[g,t,s] = Time_TotalPd[t] - SolarTotalP[s];
subject to genLimit_Min {g in GEN, t in PERIOD, s in SCENARIO}: gen_min[g]*u[g,t] <= Pg[g,t,s];
subject to genLimit_Max {g in GEN, t in PERIOD, s in SCENARIO}: Pg[g,t,s] <= gen_max[g]*u[g,t];

# Load data
data SUC_IC_e2_data.txt;

# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display u, Pg;



