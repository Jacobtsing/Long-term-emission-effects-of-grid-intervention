$OFFLISTING

* PHORUM - PJM Hourly Open-source Reduced-form Unit Commitment Model

* Pull data from gdx files: LoadData.gdx, GenData.gdx, and StorageData.gdx
$GDXIN LoadData.gdx
set t "time";
Parameter loadTCR1(t)        "Hourly load - TCR1";
Parameter loadTCR2(t)        "Hourly load - TCR2";
Parameter loadTCR3(t)        "Hourly load - TCR3";
Parameter loadTCR4(t)        "Hourly load - TCR4";
Parameter loadTCR5(t)        "Hourly load - TCR5";
Parameter windSolarTCR1(t);
Parameter windSolarTCR2(t);
Parameter windSolarTCR3(t);
Parameter windSolarTCR4(t);
Parameter windSolarTCR5(t);
$LOAD t loadTCR1 loadTCR2 loadTCR3 loadTCR4 loadTCR5 windSolarTCR1 windSolarTCR2 windSolarTCR3 windSolarTCR4 windSolarTCR5
Parameter gap;
Parameter modelStatus;
Parameter solveStatus;

set tOpt(t) "optimization periods";
alias (t, tp);

* Gather generator data
$GDXIN GenData.gdx
set g "thermal generators";

set gTCR1(g) "TCR1 generators";
set gTCR2(g) "TCR2 generators";
set gTCR3(g) "TCR3 generators";
set gTCR4(g) "TCR4 generators";
set gTCR5(g) "TCR5 generators";

Parameter gInitState(g)  "Generator initial state";
Parameter gInitGen(g)    "Generator initial generation";
Parameter gMinCapacity(g)        "Generator Min Power";
Parameter gCapacity(g)        "Generator Max Power";
Parameter gVC(g)    "Generator marginal cost";
Parameter gNLC(g)        "Generator no-load cost";
Parameter gRampRate(g)       "Generator Ramp Rate";
Parameter gMinUp(g)     "Generator Min Uptime";
Parameter gMinDown(g)   "Generator Min Downtime";
Parameter gOntime(g)     "Generator ontime";
Parameter gDowntime(g)   "Generator downtime";
Parameter gStartupC(g)      "Generator Startup Costs";

$LOAD g gTCR1 gTCR2 gTCR3 gTCR4 gTCR5 gInitState gInitGen gMinCapacity gCapacity gVC gNLC gRampRate gMinUp gMinDown gOntime gDowntime gStartupC

set g1(g) "first generator";
* Storage data
$GDXIN StorageData.gdx
set s "storage units";
set sTCR1(s) "TCR1 SUs";
set sTCR2(s) "TCR2 SUs";
set sTCR3(s) "TCR3 SUs";
set sTCR4(s) "TCR4 SUs";
set sTCR5(s) "TCR5 SUs";
Parameter sSOCmax(s)        "Storage capacity";
Parameter sRampRate(s)        "Storage ramp rate";
Parameter sChargeEff(s)       "Storage charge efficiency";
Parameter sDischargeEff(s)    "Storage discharge efficiency";
Parameter sInitSOC(s)       "Storage initial state";

$LOAD s sTCR1 sTCR2 sTCR3 sTCR4 sTCR5 sSOCmax sRampRate sChargeEff sDischargeEff sInitSOC

* tOpt is a subset of t that excludes the first hour from the optimization
tOpt(t) = yes$(ord(t) gt 1);

Variables
* System variables
        SysCost                System cost
        HourlyCost(t)          Hourly cost
*        TI12(t)                Power transfered from TCR1 to TCR2
*        TI13(t)                Power transfered from TCR1 to TCR3
*        TI15(t)                Power transfered from TCR1 to TCR5
*        TI52(t)                Power transfered from TCR5 to TCR2
*        TI23(t)                Power transfered from TCR2 to TCR3
*        TI34(t)                Power transfered from TCR3 to TCR4
*        windTCR1(t)
*        windTCR2(t)
*        windTCR3(t)
*        windTCR4(t)
*        windTCR5(t)
        wind(t)

* Generator variables
        gLevel(g, t)           Power plant production level
*        gLevelReserves(g, t)   Power plant production level - reserves NEW
        gStartupCost(g, t)     Hourly startup cost for each generator
        U(g, t)                Discrete decision var of Gen g for on (+1) or off (-1) of unit at time t+1

* Storage variables
         sCharge(s, t)         Storage charging rate
         sDischarge(s,t)       Storage discharging rate
         sSOC(s, t)            Storage state of charge

* Set limits on variables
Positive variable gLevel;
Free variable wind;

*Positive variable windTCR1;
*Positive variable windTCR2;
*Positive variable windTCR3;
*Positive variable windTCR4;
*Positive variable windTCR5;

*Positive variable gLevelReserves;
Binary variable U;
Positive variable gStartupCost;
Positive variable sSOC;
Positive variable sCharge;
Positive variable sDischarge;
Positive variable vSOC;
Positive variable vCharge;
wind.lo(t) = min(0,windSolarTCR1(t) + windSolarTCR2(t) + windSolarTCR3(t) + windSolarTCR4(t) + windSolarTCR5(t));
wind.up(t) = windSolarTCR1(t) + windSolarTCR2(t) + windSolarTCR3(t) + windSolarTCR4(t) + windSolarTCR5(t);


*windTCR1.up(t) = windSolarTCR1(t);
*windTCR2.up(t) = windSolarTCR2(t);
*windTCR3.up(t) = windSolarTCR3(t);
*windTCR4.up(t) = windSolarTCR4(t);
*windTCR5.up(t) = windSolarTCR5(t);

sCharge.lo(s,t) = 0;
sCharge.up(s,t) = sRampRate(s);
sDischarge.lo(s,t) = 0;
sDischarge.up(s,t) = sRampRate(s);
sSOC.lo(s,t) = 0.1;
sSOC.up(s,t) = sSOCmax(s);

*TI12.lo(t)$(ord(t) gt 1) = -TI12max(t);
*TI12.up(t)$(ord(t) gt 1) = TI12max(t);
*TI13.lo(t)$(ord(t) gt 1) = -TI13max(t);
*TI13.up(t)$(ord(t) gt 1) = TI13max(t);
*TI15.lo(t)$(ord(t) gt 1) = -TI15max(t);
*TI15.up(t)$(ord(t) gt 1) = TI15max(t);
*TI52.lo(t)$(ord(t) gt 1) = -TI52max(t);
*TI52.up(t)$(ord(t) gt 1) = TI52max(t);
*TI23.lo(t)$(ord(t) gt 1) = -TI23max(t);
*TI23.up(t)$(ord(t) gt 1) = TI23max(t);
*TI34.lo(t)$(ord(t) gt 1) = -TI34max(t);
*TI34.up(t)$(ord(t) gt 1) = TI34max(t);

* Fix values for first hour, which is the last hour of the previous day
sSOC.fx(s, t)$(ord(t) eq 1) = sInitSOC(s);
sSOC.fx(s, t)$(ord(t) eq 49) = sSOCmax(s)/2;
sCharge.fx(s,t)$(ord(t) eq 1) = 0;
sDischarge.fx(s,t)$(ord(t) eq 1) = 0;
if((sum(g, gInitGen(g)) > 0),
         U.fx(g, t)$(ord(t) eq 1) = gInitState(g);
         gLevel.fx(g, t)$(ord(t) eq 1) = gInitGen(g);
);

gLevel.up(g,t) = gCapacity(g);	

Equations
         OBJ_FN
         HOURLY_COSTc(t)

* Generator constraints
         MAXGENc(g,t)
         MINGENc(g,t)
         RAMPUPc(g,t)
         RAMPDOWNc(g,t)
         UPTIME1c(g)
         UPTIME2c(g,t)
         UPTIME3c(g,t)
         DOWNTIME1c(g)
         DOWNTIME2c(g,t)
         DOWNTIME3c(g,t)
         STARTUPCOSTc(g, t)

* Storage constraints
         SOCc(s,t)

* TCR constraints
         SUPPLY(t);

*         SUPPLYTCR1c(t)
*         SUPPLYTCR2c(t)
*         SUPPLYTCR3c(t)
*         SUPPLYTCR4c(t)
*         SUPPLYTCR5c(t);
*         tempEqn(t);

* Reserve constraints
*         RESERVETCR1c(t)
*         RESERVETCR234c(t)
*         RESERVETCR5c(t);

OBJ_FN ..            SysCost =e= sum(tOpt, HourlyCost(tOpt));
HOURLY_COSTc(t) ..   HourlyCost(t) =e= sum(g, gLevel(g, t)*(gVC(g)) + gStartupCost(g, t) + gNLC(g)*U(g,t));
STARTUPCOSTc(g,t) .. gStartupCost(g,t) =g= gStartupC(g)*(U(g,t) - U(g,t-1));

* Load constraints for each TCR
SUPPLY(t) $(ord(t) gt 1) ..                 loadTCR1(t)+ loadTCR2(t)+loadTCR3(t)+loadTCR4(t)+loadTCR5(t) =e= sum(g, gLevel(g,t))+sum(s,sDischarge(s,t)-sCharge(s,t))+wind(t);
*SUPPLYTCR1c(t)$(ord(t) gt 1) ..            loadTCR1(t) =e= sum(gTCR1, gLevel(gTCR1, t)) - TI12(t) - TI13(t) - TI15(t) + windTCR1(t) + sum(sTCR1,sDischarge(sTCR1,t)-sCharge(sTCR1,t))-sum((v,a)$(ord(a) eq 1),vCharge(v,t,a));
*SUPPLYTCR2c(t)$(ord(t) gt 1) ..            loadTCR2(t) =e= sum(gTCR2, gLevel(gTCR2, t)) + TI12(t) + TI52(t) - TI23(t)  + windTCR2(t) + sum(sTCR2,sDischarge(sTCR2,t)-sCharge(sTCR2,t))-sum((v,a)$(ord(a) eq 2),vCharge(v,t,a));
*SUPPLYTCR3c(t)$(ord(t) gt 1) ..            loadTCR3(t) =e= sum(gTCR3, gLevel(gTCR3, t)) + TI23(t) + TI13(t) - TI34(t)  + windTCR3(t) + sum(sTCR3,sDischarge(sTCR3,t)-sCharge(sTCR3,t))-sum((v,a)$(ord(a) eq 3),vCharge(v,t,a));
*SUPPLYTCR4c(t)$(ord(t) gt 1) ..            loadTCR4(t) =e= sum(gTCR4, gLevel(gTCR4, t)) + TI34(t)  + windTCR4(t) + sum(sTCR4,sDischarge(sTCR4,t)-sCharge(sTCR4,t))-sum((v,a)$(ord(a) eq 4),vCharge(v,t,a));
*SUPPLYTCR5c(t)$(ord(t) gt 1) ..            loadTCR5(t) =e= sum(gTCR5, gLevel(gTCR5, t)) + TI15(t)  + windTCR5(t) - TI52(t) + sum(sTCR5,sDischarge(sTCR5,t)-sCharge(sTCR5,t))-sum((v,a)$(ord(a) eq 5),vCharge(v,t,a));

*tempEqn(t)$(ord(t) gt 1) .. tempOutput(t) =e= sum((v,a)$(ord(a) eq 1),vCharge(v,t,a)*vNum(v,a)*vCR(v));

* Reserve constraints for each TCR
*RESERVETCR1c(t)$(ord(t) gt 1) ..            1300  =e= sum(gTCR1, gLevelReserves(gTCR1, t));
*RESERVETCR234c(t)$(ord(t) gt 1) ..          1170  =e= sum(gTCR2, gLevelReserves(gTCR2, t)) + sum(gTCR3, gLevelReserves(gTCR3, t)) + sum(gTCR4, gLevelReserves(gTCR4, t));
*RESERVETCR5c(t)$(ord(t) gt 1) ..            1170  =e= sum(gTCR5, gLevelReserves(gTCR5, t));

* Generation levels
MAXGENc(g,t) ..      gLevel(g,t) =l= gCapacity(g)*U(g,t);
MINGENc(g,t)$(gMinCapacity(g) gt 0) ..      gLevel(g,t) =g= gMinCapacity(g)*U(g,t);

* Ramp rates
RAMPUPc(g,t)$(ord(t) gt 1 and gRampRate(g) lt gCapacity(g)) ..   gLevel(g,t) =l= gLevel(g, t-1) + gRampRate(g)*U(g,t-1)+gMinCapacity(g)*(U(g,t)-U(g,t-1));
RAMPDOWNc(g,t)$(ord(t) gt 1 and gRampRate(g) lt gCapacity(g)) .. gLevel(g,t-1) - gLevel(g,t) =l= gRampRate(g)*U(g,t)+gMinCapacity(g)*(U(g,t-1)-U(g,t));

* Min uptime (updated mbruchon May 4 2021)
UPTIME1c(g)$(gMinUp(g) gt 1).. sum(t$(ord(t) gt 1 and ord(t) le (gOntime(g)+1)*gInitState(g)), 1 - U(g,t)) =e= 0;
UPTIME2c(g,t)$(ord(t) gt gOntime(g)*gInitState(g)+1 and ord(t) lt card(t)-gMinUp(g)+2 and gMinUp(g) gt 1).. sum(tp$(ord(tp) ge ord(t) and ord(tp) lt ord(t)+gMinUp(g)),U(g,tp)) =g= gMinUp(g)*(U(g,t) - U(g,t-1));
UPTIME3c(g,t)$(ord(t) ge card(t)-gMinUp(g)+2 and ord(t) lt card(t) and gMinUp(g) gt 1).. sum(tp$(ord(tp) gt ord(t)), U(g,tp)) =g= (card(t)-ord(t))*(U(g,t)-U(g,t-1));

* Min downtime (updated mbruchon May 4 2021)
DOWNTIME1c(g)$(gMinDown(g) gt 1).. sum(t$(ord(t) gt 1 and ord(t)le (gDowntime(g)+1)*(1-gInitState(g))), U(g,t)) =e= 0;
DOWNTIME2c(g,t)$(ord(t) gt gDowntime(g)*(1-gInitState(g))+1 and ord(t) lt card(t)-gMinDown(g)+2 and gMinDown(g) gt 1).. sum(tp$(ord(tp) ge ord(t) and ord(tp) lt ord(t)+gMinDown(g)),1-U(g,tp)) =g= gMinDown(g)*(U(g,t-1) - U(g,t));
DOWNTIME3c(g,t)$(ord(t) ge card(t)-gMinDown(g)+2 and ord(t) lt card(t) and gMinDown(g) gt 1).. sum(tp$(ord(tp) gt ord(t)), 1-U(g,tp)) =g= (card(t)-ord(t))*(U(g,t-1)-U(g,t));


* Storage state of charge
SOCc(s,t)$(ord(t) gt 1) ..                sSOC(s,t) =e= sSOC(s,t-1)+ sChargeEff(s)*sCharge(s,t) - (1/sDischargeEff(s))*sDischarge(s,t);

Model PHORUM /all/;


* Scale varibles to speed optimization
*SUPPLY.scale(t) = 1000;
*SUPPLYTCR1c.scale(t) = 1000;
*SUPPLYTCR2c.scale(t) = 1000;
*SUPPLYTCR3c.scale(t) = 1000;
*SUPPLYTCR4c.scale(t) = 1000;
*SUPPLYTCR5c.scale(t) = 1000;
*SOCc.scale(s, t) = 1000;
*OBJ_FN.scale = 10000;

$Onlisting 
PHORUM.OptFile=1;
Option ResLim = 3600;
Option OptCR=1e-3;
Option OptCA=100;
Option MIP = OSIGUROBI;
Option threads = 0;
Option SysOut = on;
Option limrow=0;
Option limcol=0;
Option solprint=off;
* Option MIP = CPLEX;
* Option Errnam=error
* Option solverstat=gams_solverstat.log
* Option Logfile=gams_logfile.log
* Option Output=gams_output.log
* Option writemps = U:\PJM\Refactor\out.mps;
* Option names = yes;
* Option Logline=2
* Option Logoption=4
* Option Errmsg=0
* Option Errorlog=99
Solve PHORUM using MIP minimizing SysCost;

gap =  abs(PHORUM.objest - PHORUM.objval)/(1e-10+abs(PHORUM.objval));
modelStatus = PHORUM.modelStat;
solveStatus = PHORUM.solveStat;

* CC0, Trans0
execute_unload "results.gdx" modelStatus solveStatus gap gLevel U HourlyCost gVC sDischarge sCharge sSOC loadTCR1 loadTCR2 loadTCR3 loadTCR4 loadTCR5 wind SUPPLY.m 
* CC0, Trans1
*execute_unload "results.gdx" modelStatus solveStatus gap gLevel U HourlyCost gVC sDischarge sCharge sSOC loadTCR1 loadTCR2 loadTCR3 loadTCR4 loadTCR5 windTCR1 windTCR2 windTCR3 windTCR4 windTCR5 SUPPLYTCR1c.m SUPPLYTCR2c.m SUPPLYTCR3c.m SUPPLYTCR4c.m SUPPLYTCR5c.m TI12 TI15 TI13 TI52 TI23 TI34 TI12max loadTCR5 TI13max TI15max TI52max TI23max TI34max 
* CC1, Trans0
* execute_unload "results.gdx" modelStatus solveStatus gap gLevel U HourlyCost gVC sDischarge sCharge sSOC loadTCR1 loadTCR2 loadTCR3 loadTCR4 loadTCR5 vSOC.l vCharge.l wind SUPPLY.m
* CC1, Trans1
* execute_unload "results.gdx" modelStatus solveStatus gap gLevel U HourlyCost gVC sDischarge sCharge sSOC loadTCR1 loadTCR2 loadTCR3 loadTCR4 loadTCR5 vSOC.l vCharge.l windTCR1 windTCR2 windTCR3 windTCR4 windTCR5 SUPPLYTCR1c.m SUPPLYTCR2c.m SUPPLYTCR3c.m SUPPLYTCR4c.m SUPPLYTCR5c.m TI12 TI15 TI13 TI52 TI23 TI34 TI12max loadTCR5 TI13max TI15max TI52max TI23max TI34max 
