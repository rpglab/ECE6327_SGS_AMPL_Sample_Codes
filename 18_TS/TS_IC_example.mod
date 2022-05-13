# Transmission Switching example program for EEE6327
# by Xingpeng.Li
# run command: include fileName.mod; e.g. include TS_IC_example.mod; 

# Use reset to clear memory for AMPL
reset;

# Declare parameters
param MVABase = 100; # MW

param x1; let x1 := 0.01; # per unit
param x2; let x2 := 0.02; # per unit
param x3; let x3 := 0.02; # per unit

param lineLimit1; let lineLimit1 := 50; # MW
param lineLimit2; let lineLimit2 := 20; # MW
param lineLimit3; let lineLimit3 := 10; # MW


param LoadA; let LoadA := 0;
param LoadB; let LoadB := 150; # MW

param Gamin; let Gamin := 0; 
param Gamax; let Gamax := 200; # MW

param Gbmin; let Gbmin := 0; 
param Gbmax; let Gbmax := 100; # MW

param CostGa; let CostGa := 10; # $/MWh
param CostGb; let CostGb := 30; # $/MWh

# Declare Variables
var lineflow1;  # per unit
var lineflow2;  # per unit
var lineflow3;  # per unit

var line_status1 binary;  # 1: online; 0: out of service
var line_status2 binary;  # 1: online; 0: out of service
var line_status3 binary;  # 1: online; 0: out of service

var thetaA;  # in radian
var thetaB;  # in radian

var Ga;  # in per unit
var Gb;  # in per unit

# Define objective function
minimize totalCost: CostGa*Ga*MVABase + CostGb*Gb*MVABase;

# Define constraints
subject to NodalConstrntA:  Ga - LoadA/MVABase - lineflow1 - lineflow2 - lineflow3 = 0;
subject to NodalConstrntB:  Gb - LoadB/MVABase + lineflow1 + lineflow2 + lineflow3 = 0;

# nonlinear constraints for branch flow calculation
#subject to LineFlow1:  lineflow1 = line_status1*(thetaA - thetaB)/x1;
#subject to LineFlow2:  lineflow2 = line_status2*(thetaA - thetaB)/x2;
#subject to LineFlow3:  lineflow3 = line_status3*(thetaA - thetaB)/x3;

# or equivalent linear constraints with Big-M method for branch flow calculation
param BigM = 10e7;
subject to LineFlow1_1:  -BigM*(1-line_status1) <= lineflow1 - (thetaA - thetaB)/x1;
subject to LineFlow1_2:  lineflow1 - (thetaA - thetaB)/x1 <= BigM*(1-line_status1);
subject to LineFlow2_1:  -BigM*(1-line_status2) <= lineflow2 - (thetaA - thetaB)/x2;
subject to LineFlow2_2:  lineflow2 - (thetaA - thetaB)/x2 <= BigM*(1-line_status2);
subject to LineFlow3_1:  -BigM*(1-line_status3) <= lineflow3 - (thetaA - thetaB)/x3;
subject to LineFlow3_2:  lineflow3 - (thetaA - thetaB)/x3 <= BigM*(1-line_status3);

subject to LineLimitConstrnt1_1:  -line_status1*lineLimit1/MVABase <= lineflow1;
subject to LineLimitConstrnt1_2:    lineflow1 <= line_status1*lineLimit1/MVABase;

subject to LineLimitConstrnt2_1:  -line_status2*lineLimit2/MVABase <= lineflow2;
subject to LineLimitConstrnt2_2:    lineflow2 <= line_status2*lineLimit2/MVABase;

subject to LineLimitConstrnt3_1:  -line_status3*lineLimit3/MVABase <= lineflow3;
subject to LineLimitConstrnt3_2:    lineflow3 <= line_status3*lineLimit3/MVABase;

subject to GenLimitConstrntA:  Gamin/MVABase <= Ga <= Gamax/MVABase;
subject to GenLimitConstrntB:  Gbmin/MVABase <= Gb <= Gbmax/MVABase;


option solver gurobi;
#option solver xpress;
solve;
display line_status1, line_status2, line_status3;
display Ga, Gb; # in per unit
display Ga*MVABase, Gb*MVABase; # in MW

