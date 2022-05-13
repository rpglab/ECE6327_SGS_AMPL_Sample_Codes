# SCUC example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include ES_IC_e1.mod;

# Use reset to clear memory for AMPL
reset;

# Declare set
set GEN; # an index list for generator
set PERIOD; # an index list for time intervals
set STORAGE; # an index list for energy storages

# Generator data
param gen_min {GEN};
param gen_max {GEN};
param gen_RRlimit {GEN};
param gen_OpCost {GEN};
param gen_NlCost {GEN};
param gen_SuCost {GEN};

# Period data
param Time_TotalPd {PERIOD};
param nT; # number of periods

# Energy storages data
param ES_EInit {STORAGE};
param ES_Emax {STORAGE};
param ES_Emin {STORAGE};
param ES_PmaxC {STORAGE};
param ES_PmaxD {STORAGE};
param ES_EffiC {STORAGE};
param ES_EffiD {STORAGE};

# Declare Variable
var u {GEN, PERIOD} binary;
var v {GEN, PERIOD} binary;
var Pg {GEN, PERIOD};

var u_c_ES {STORAGE, PERIOD} binary;
var u_d_ES {STORAGE, PERIOD} binary;
var P_c_ES {STORAGE, PERIOD} >= 0;
var P_d_ES {STORAGE, PERIOD} >= 0;
var E_ES {STORAGE, PERIOD} >= 0;   # energy stored at the end of each time period

# Define objective function
minimize obj: sum{g in GEN, t in PERIOD} (gen_OpCost[g]*Pg[g,t] + gen_NlCost[g]*u[g,t] + gen_SuCost[g]*v[g,t]);
             
# Define constraints
subject to PowerBalance {t in PERIOD}: sum{g in GEN} Pg[g,t] = Time_TotalPd[t] + sum{e in STORAGE}(P_c_ES[e,t] - P_d_ES[e,t]);
subject to genLimit_Min {g in GEN, t in PERIOD}: gen_min[g]*u[g,t] <= Pg[g,t];
subject to genLimit_Max {g in GEN, t in PERIOD}: Pg[g,t] <= gen_max[g]*u[g,t];
subject to genRRLimit_Up {g in GEN, t in PERIOD: t>1}: Pg[g,t] - Pg[g,t-1] <= gen_RRlimit[g];
subject to genRRLimit_Dn {g in GEN, t in PERIOD: t>1}: Pg[g,t-1] - Pg[g,t] <= gen_RRlimit[g];

# Additional restriction on v variable.
subj to FacetUP{g in GEN, t in PERIOD}:v[g,t] <= u[g,t];
subj to FacetDN{g in GEN, t in PERIOD: t<=nT-1}: v[g,t+1] <= 1 - u[g,t];

subject to genVU_cnstrnt2 {g in GEN, t in PERIOD: t>1}: v[g,t] >= u[g,t] - u[g,t-1];
subject to genVU_cnstrnt2_Init {g in GEN}: v[g,1] >= u[g,1];


subject to ESLimit_Mode {e in STORAGE, t in PERIOD}: u_c_ES[e,t] + u_d_ES[e,t] <= 1;

subject to ESLimit_PMaxC {e in STORAGE, t in PERIOD}: P_c_ES[e,t] <= ES_PmaxC[e]*u_c_ES[e,t];
subject to ESLimit_PMaxD {e in STORAGE, t in PERIOD}: P_d_ES[e,t] <= ES_PmaxD[e]*u_d_ES[e,t];

subject to ESLimit_EMin {e in STORAGE, t in PERIOD}: E_ES[e,t] <= ES_Emax[e];
subject to ESLimit_EMax {e in STORAGE, t in PERIOD}: ES_Emin[e] <= E_ES[e,t];

subject to ES_Ecalc {e in STORAGE, t in PERIOD: t > 1}: E_ES[e,t] = E_ES[e,t-1] + ES_EffiC[e]*P_c_ES[e,t] - P_d_ES[e,t]/ES_EffiD[e];
subject to ES_EcalcInit {e in STORAGE}: E_ES[e,1] = ES_EInit[e] + ES_EffiC[e]*P_c_ES[e,1] - P_d_ES[e,1]/ES_EffiD[e];
subject to ES_ESame {e in STORAGE}: E_ES[e,2] = ES_EInit[e];


# Load data
data ES_IC_e1_data.txt;

let nT := 0;
for {t in PERIOD} let nT := nT + 1;

# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display v, u, Pg;
display u_c_ES, P_c_ES;
display u_d_ES, P_d_ES;
display E_ES;



