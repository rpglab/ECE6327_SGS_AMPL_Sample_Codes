# SUC example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include SUC_IC_e3_M2.mod;

# Use reset to clear memory for AMPL
reset;

# Declare set
set GEN; # an index list for generator
set SCENARIO; # an index list for scenarios

# Generator data
param gen_min {GEN};
param gen_max {GEN};
param gen_OpCost {GEN};
param gen_SuCost {GEN};

# Period data
param Time_TotalPd = 100;

# Scenario data
param SolarProb {SCENARIO};
param SolarTotalP {SCENARIO};

# Declare Variable
var u {GEN} binary;
var Pg {GEN, SCENARIO};

# Define objective function
minimize obj: sum{g in GEN, s in SCENARIO} SolarProb[s]*(gen_OpCost[g]*Pg[g,s] + gen_SuCost[g]*u[g]);
             
# Define constraints
subject to PowerBalance {s in SCENARIO}: sum{g in GEN} Pg[g,s] = Time_TotalPd - SolarTotalP[s];
subject to genLimit_Min {g in GEN, s in SCENARIO}: gen_min[g]*u[g] <= Pg[g,s];
subject to genLimit_Max {g in GEN, s in SCENARIO}: Pg[g,s] <= gen_max[g]*u[g];

# Load data
data SUC_IC_e3_data_M2.txt;

# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display u, Pg;



