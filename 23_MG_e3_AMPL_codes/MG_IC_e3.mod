# SCUC example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include MG_IC_e3.mod;

# Use reset to clear memory for AMPL
reset;

# Declare set
set GEN; # an index list for generator
set PERIOD; # an index list for time intervals
set STORAGE; # an index list for energy storages

# Parameters
param TL_Limit = 2500; # Tie-line limit
param nT = 3; # number of periods, each period last 8 hours for this example. 
              # First period covers 8am-16pm, second period covers 16pm-00am, third period 
              # Second period covers 16pm-0am 
              # Third period covers 0am-8am
param MG_Year = 10; # MG lifespan in years. assume a year is 365 days.
param bigM = 10e9;  # a very large number

# Generator data
param gen_type {GEN} symbolic;
param genMinCap {GEN};
param genMaxCap {GEN};
param genInitCost {GEN};
param genOpCost {GEN};
param genCapFactor {GEN};

# Period data
param Time_TotalPd {PERIOD};
param GridPrice {PERIOD};

# Energy storages data
param ES_MinP {STORAGE};  
param ES_MaxP {STORAGE};
param ES_Duration {STORAGE};
param ES_InitCost {STORAGE};
param ES_SOC_Min {STORAGE};
param ES_SOC_Max {STORAGE};
param ES_EffiC {STORAGE};
param ES_EffiD {STORAGE};

# Declare Variable
var uBuild {GEN} binary;     # decide whether to invest a type of DER
var PgSize {GEN} >= 0;       # if decided to invest a DER, how much (in terms of power capacity) we invest that DER.
var Pg {GEN, PERIOD} >= 0;   # for each DER type, what is the projected output power for each period.

var uBuild_ES {STORAGE} binary;  # decide whether to invest a type of ESS
var P_Size_ES {STORAGE} >= 0;    # if decided to invest a ESS, how much (in terms of power capacity) we invest that ESS.
var ES_EInit {STORAGE} >= 0;     # if invested, assume initial ES can be any where between possible Emax and Emin.

var u_c_ES {STORAGE, PERIOD} binary;
var u_d_ES {STORAGE, PERIOD} binary;
var P_c_ES {STORAGE, PERIOD} >= 0;
var P_d_ES {STORAGE, PERIOD} >= 0;
var E_ES {STORAGE, PERIOD} >= 0;   # energy stored at the end of each time period

var Pgrid {PERIOD};              # imported power from the main grid

# Define objective function
minimize obj: sum{g in GEN}genInitCost[g]*PgSize[g]
			  + sum{e in STORAGE}ES_InitCost[e]*P_Size_ES[e]
			#  + sum{e in STORAGE, t in PERIOD}(u_c_ES[e,t]*1 + u_d_ES[e,t]*1)    # add a small penetry term to charge mode and discharge mode
			  + MG_Year*365*sum{g in GEN, t in PERIOD}(genOpCost[g]*Pg[g,t]*8)
			  + MG_Year*365*sum{t in PERIOD}(GridPrice[t]*Pgrid[t]*8);

# Define constraints
subject to PowerBalance {t in PERIOD}: sum{g in GEN} Pg[g,t] = Time_TotalPd[t] - Pgrid[t] + sum{e in STORAGE}(P_c_ES[e,t] - P_d_ES[e,t]);
subject to genLimit_Max {g in GEN, t in PERIOD}: Pg[g,t] <= PgSize[g]*genCapFactor[g];
subject to gen_Sizing {g in GEN, t in PERIOD}: genMinCap[g]*uBuild[g] <= PgSize[g];
subject to gen_Sizing2 {g in GEN, t in PERIOD}: PgSize[g] <= genMaxCap[g]*uBuild[g];
subject to solarLimit {g in GEN, t in PERIOD: gen_type[g]=="Solar" && t>1}: Pg[g,t]= 0;

subject to ES_Sizing1 {e in STORAGE}: uBuild_ES[e]*ES_MinP[e] <= P_Size_ES[e];
subject to ES_Sizing2 {e in STORAGE}: P_Size_ES[e] <= uBuild_ES[e]*ES_MaxP[e];
subject to ESLimit_EMin {e in STORAGE, t in PERIOD}: ES_SOC_Min[e]*P_Size_ES[e]*ES_Duration[e] <= E_ES[e,t];
subject to ESLimit_EMax {e in STORAGE, t in PERIOD}: E_ES[e,t] <= ES_SOC_Max[e]*P_Size_ES[e]*ES_Duration[e];

subject to ESLimit_Mode   {e in STORAGE, t in PERIOD}: u_c_ES[e,t] + u_d_ES[e,t] <= uBuild_ES[e];
subject to ESLimit_PMaxC  {e in STORAGE, t in PERIOD}: P_c_ES[e,t] <= bigM*u_c_ES[e,t];
subject to ESLimit_PMaxC2 {e in STORAGE, t in PERIOD}: P_c_ES[e,t] <= P_Size_ES[e];
subject to ESLimit_PMaxD  {e in STORAGE, t in PERIOD}: P_d_ES[e,t] <= bigM*u_d_ES[e,t];
subject to ESLimit_PMaxD2 {e in STORAGE, t in PERIOD}: P_d_ES[e,t] <= P_Size_ES[e];

subject to ES_Ecalc {e in STORAGE, t in PERIOD: t > 1}: E_ES[e,t] = E_ES[e,t-1] + 8*(ES_EffiC[e]*P_c_ES[e,t] - P_d_ES[e,t]/ES_EffiD[e]);
subject to ES_EcalcInit {e in STORAGE}: E_ES[e,1] = ES_EInit[e] + 8*(ES_EffiC[e]*P_c_ES[e,1] - P_d_ES[e,1]/ES_EffiD[e]);
subject to ES_ESame {e in STORAGE}: E_ES[e,nT] = ES_EInit[e];

subject to PCC_limit {t in PERIOD}: -TL_Limit <= Pgrid[t] <= TL_Limit;

subject to OffGrid_Req1: sum{g in GEN}PgSize[g]*genCapFactor[g] >= Time_TotalPd[1];
subject to OffGrid_Req2 {t in PERIOD: t>1}: sum{g in GEN: gen_type[g]!="Solar"}PgSize[g]*genCapFactor[g] >= Time_TotalPd[t];

# Load data
data MG_IC_e3_data.txt;


# Solver setting
option solver gurobi;
option gurobi_options('mipgap=0.0 timelim=90');
solve;

display u_c_ES, u_d_ES;
display P_c_ES, P_d_ES;
display E_ES;
display Pg, Pgrid;

display uBuild,PgSize;
display uBuild_ES, P_Size_ES;

display sum{g in GEN}genInitCost[g]*PgSize[g]
			  + sum{e in STORAGE}ES_InitCost[e]*P_Size_ES[e]
			  + MG_Year*365*sum{g in GEN, t in PERIOD}(genOpCost[g]*Pg[g,t]*8)
			  + MG_Year*365*sum{t in PERIOD}(GridPrice[t]*Pgrid[t]*8);

