# DSM example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include DSM_IC_e2.mod; 

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
param DSM_d_Limit {PERIOD};

# Declare Variable
var u {GEN, PERIOD} binary;
var v {GEN, PERIOD} binary;
var Pg {GEN, PERIOD};

var DSM_d {PERIOD} >= 0;

# Define objective function
minimize obj: sum{g in GEN, t in PERIOD} (gen_OpCost[g]*Pg[g,t] + gen_NlCost[g]*u[g,t] + gen_SuCost[g]*v[g,t]);

# Define constraints
subject to PowerBalance1: sum{g in GEN}Pg[g,1] = Time_TotalPd[1] - DSM_d[1];
subject to PowerBalance2 {t in PERIOD: t>1}: sum{g in GEN}Pg[g,t] = Time_TotalPd[t] - DSM_d[t] + DSM_d[t-1];
subject to genLimit_Min {g in GEN, t in PERIOD}: gen_min[g]*u[g,t] <= Pg[g,t];
subject to genLimit_Max {g in GEN, t in PERIOD}: Pg[g,t] <= gen_max[g]*u[g,t];
#subject to genRRLimit_Up {g in GEN, t in PERIOD: t>1}: Pg[g,t] - Pg[g,t-1] <= gen_RRlimit[g]*u[g,t];
#subject to genRRLimit_Dn {g in GEN, t in PERIOD: t>1}: Pg[g,t-1] - Pg[g,t] <= gen_RRlimit[g]*u[g,t];
subject to genRRLimit_Up {g in GEN, t in PERIOD: t>1}: Pg[g,t] - Pg[g,t-1] <= gen_RRlimit[g]*u[g,t-1] + BigM*v[g,t];
subject to genRRLimit_Dn {g in GEN, t in PERIOD: t>1}: Pg[g,t-1] - Pg[g,t] <= gen_RRlimit[g]*u[g,t] + BigM*(v[g,t]-u[g,t]+u[g,t-1]);

subject to genVU_cnstrnt1 {g in GEN, t in PERIOD}: 0 <= v[g,t] <= 1;
subject to genVU_cnstrnt2 {g in GEN, t in PERIOD: t>1}: v[g,t] >= u[g,t] - u[g,t-1];
subject to genVU_cnstrnt2_Init {g in GEN}: v[g,1] >= u[g,1];

subject to DSM_limit {t in PERIOD}: DSM_d[t] <= DSM_d_Limit[t]; 
subject to DSM_Zero: DSM_d[nT] = 0;  # last period does not defer load



# Load data
data DSM_IC_e2_data.txt;

let nT := 0;
for {t in PERIOD} let nT := nT + 1;

# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display v, u, Pg;
display DSM_d;


