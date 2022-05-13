# FACTS program for EEE6327
# by Xingpeng.Li
# for in-class example 5 (Case 5)

# Use reset to clear memory for AMPL
reset;

# Declare set
set BUS; # an index list for bus
set GEN; # an index list for generator
set BRANCH; # an index list for branch
set LOAD;

# MVA base
param MVABase = 100;

# Bus data
param bus_number {BUS};

# Generator data
param gen_Bus {GEN};
param gen_min {GEN};
param gen_max {GEN};
param gen_Cost {GEN};

# Load data
param load_Bus {LOAD};
param load_Pd {LOAD};

# Branch data
param branch_fromBus {BRANCH};
param branch_toBus {BRANCH};
param branch_st {BRANCH};
param branch_x_orig {BRANCH};
param branch_x_upPct {BRANCH};
param branch_x_dnPct {BRANCH};
param branch_rate {BRANCH};

# Declare Variable
var pg {GEN} >= 0;
var pk {BRANCH};
var theta {BUS};
var branch_x {BRANCH};

# Define objective function
minimize obj: sum{g in GEN}pg[g]*gen_Cost[g]*MVABase;

# Define constraints
subject to nodalPowerBalance  {n in BUS}: 
          sum{g in GEN: gen_Bus[g]==n}pg[g] - sum{k in BRANCH: branch_fromBus[k]==n}pk[k]
              + sum{k in BRANCH: branch_toBus[k]==n}pk[k] == sum{d in LOAD: load_Bus[d]==n}load_Pd[d];
subject to branchThermalLimit {k in BRANCH}:
          -branch_rate[k] <= pk[k] <= branch_rate[k];
subject to lineFlow {k in BRANCH}: 
           pk[k] = (theta[branch_fromBus[k]] - theta[branch_toBus[k]])/branch_x[k];
subject to branchX_flxbl {k in BRANCH}:
           branch_x_orig[k] * (1 - branch_x_dnPct[k]) <= branch_x[k] <= branch_x_orig[k] * (1 + branch_x_upPct[k]);

# Load data
data facts_data_case.txt;

# Process data, convert to per unit system
for {d in LOAD} {
    let load_Pd[d] := load_Pd[d]/MVABase;
}
for {g in GEN} {
    let gen_min[g] := gen_min[g]/MVABase;
    let gen_max[g] := gen_max[g]/MVABase;
}
for {k in BRANCH} {
    let branch_rate[k] := branch_rate[k]/MVABase;
}

fix theta[1] := 0;

# Solver setting
#option solver baron;
option solver minos;
solve;

display {g in GEN} pg[g]*MVABase;
display {k in BRANCH} pk[k]*MVABase;
display branch_x, branch_x_orig, branch_x_upPct, branch_x_dnPct;
display {k in BRANCH} branch_x[k]/0.01;

#for {g in GEN} {
#	printf "The output of generator %d at bus %d is %f MW.\n", g, gen_Bus[g], pg[g]*MVABase > genResult.txt;
#}


