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
Parameter TI12max(t)         "Hourly Transmission Limit - TI12";
Parameter TI13max(t)         "Hourly Transmission Limit - TI13";
Parameter TI15max(t)         "Hourly Transmission Limit - TI15";
Parameter TI52max(t)         "Hourly Transmission Limit - TI52";
Parameter TI23max(t)         "Hourly Transmission Limit - TI23";
Parameter TI34max(t)        "Hourly Transmission Limit - TI34";
Parameter windTCR1(t);
Parameter windTCR2(t);
Parameter windTCR3(t);
Parameter windTCR4(t);
Parameter windTCR5(t);

Parameter solarTCR1(t);
Parameter solarTCR2(t);
Parameter solarTCR3(t);
Parameter solarTCR4(t);
Parameter solarTCR5(t);
$LOAD t loadTCR1 loadTCR2 loadTCR3 loadTCR4 loadTCR5 TI12max TI13max TI15max TI52max TI23max TI34max solarTCR1 solarTCR2 solarTCR3 solarTCR4 solarTCR5 windTCR1 windTCR2 windTCR3 windTCR4 windTCR5
Parameter gap;
Parameter modelStatus;
Parameter solveStatus;
$GDXIN VehData.gdx
set v "vehicle profile";
set a "transmission area";
Parameter vAvailable(t,v)        "percent of timestep that the vehicle is home to charge";
Parameter vMiles(t,v)            "miles the vehicle drives before charging";
Parameter vNum(v,a)              "number of electric vehicles in the area";
Parameter vInitSOC(v,a)          "State of charge at the beginning of the day";
Parameter vBattery(v)               "Size of the battery in MWh";
Parameter vCR(v)                    "Charging rate in MW";
Parameter vEff(v)                    "electric effficiency of the vehicles in MWh/mile";

$LOAD v a vAvailable vMiles vNum vInitSOC vBattery vCR vEff

set tOpt(t) "optimization periods";
alias (t, tp);

set fct(v,t) /
v1.t13,v2.t13,v3.t7,v4.t8,v5.t25,v6.t16,v7.t14,v8.t6,v9.t8,v10.t8,v11.t10,v12.t9,v13.t25,v14.t8,v15.t18
v1.t37,v2.t37,v3.t31,v4.t32,v5.t49,v6.t40,v7.t38,v8.t30,v9.t32,v10.t32,v11.t34,v12.t33,v13.t49,v14.t32,v15.t42  /;

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
Parameter gReserveCost(g)    "Generator regulation provision cost";
Parameter gNLC(g)        "Generator no-load cost";
Parameter gRampRate(g)       "Generator Ramp Rate";
Parameter gMinUp(g)     "Generator Min Uptime";
Parameter gMinDown(g)   "Generator Min Downtime";
Parameter gOntime(g)     "Generator ontime";
Parameter gDowntime(g)   "Generator downtime";
Parameter gStartupC(g)      "Generator Startup Costs";

$LOAD g gTCR1 gTCR2 gTCR3 gTCR4 gTCR5 gInitState gReserveCost gInitGen gMinCapacity gCapacity gVC gNLC gRampRate gMinUp gMinDown gOntime gDowntime gStartupC

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
        TI12(t)                Power transfered from TCR1 to TCR2
        TI13(t)                Power transfered from TCR1 to TCR3
        TI15(t)                Power transfered from TCR1 to TCR5
        TI52(t)                Power transfered from TCR5 to TCR2
        TI23(t)                Power transfered from TCR2 to TCR3
        TI34(t)                Power transfered from TCR3 to TCR4


* Generator variables
        gLevel(g, t)           Power plant production level
        gReserve(g, t)        Power plant regulation offer
        gReservespin(g, t)     Power plant Spinning reserve offer
*        gLevelReserves(g, t)   Power plant production level - reserves NEW
        gStartupCost(g, t)     Hourly startup cost for each generator
        U(g, t)                Discrete decision var of Gen g for on (+1) or off (-1) of unit at time t+1

* Storage variables
         sCharge(s, t)         Storage charging rate
         sDischarge(s,t)       Storage discharging rate
         sSOC(s, t)            Storage state of charge
         sReserve(s,t)         Storage reserve offer
         sReservespin(s,t)     Storage spinning reserve offer
* Vehicle Variables
         vSOC(v,t,a)
         vCharge(v,t,a)
         vReserve(v,t,a)
         vReservespin(v,t,a)
*         tempOutput(t)

* Set limits on variables
Positive variable gLevel;
* Positive variable gLevelStart(g, t);
Positive variable windTCRact1;
Positive variable windTCRact2;
Positive variable windTCRact3;
Positive variable windTCRact4;
Positive variable windTCRact5;
Free variable solarTCRact1;
Free variable solarTCRact2;
Free variable solarTCRact3;
Free variable solarTCRact4;
Free variable solarTCRact5;

*Positive variable gLevelReserves;
Binary variable U;
Positive variable gStartupCost;
Positive variable gReserve;
Positive variable gReservespin;
Positive variable sSOC;
Positive variable sCharge;
Positive variable sDischarge;
Positive variable sReserve;
Positive variable sReservespin;
Positive variable vSOC;
Positive variable vReserve;
Positive variable vReservespin;
Positive variable vCharge;
Positive variable vDischarge;

windTCRact1.lo(t) = min(0,windTCR1(t));
windTCRact2.lo(t) = min(0,windTCR2(t));
windTCRact3.lo(t) = min(0,windTCR3(t));
windTCRact4.lo(t) = min(0,windTCR4(t));
windTCRact5.lo(t) = min(0,windTCR5(t));
windTCRact1.up(t) = windTCR1(t);
windTCRact2.up(t) = 0;
windTCRact3.up(t) = windTCR3(t);
windTCRact4.up(t) = 0;
windTCRact5.up(t) = windTCR5(t);

solarTCRact1.lo(t) = min(0,solarTCR1(t));
solarTCRact2.lo(t) = min(0,solarTCR2(t));
solarTCRact3.lo(t) = min(0,solarTCR3(t));
solarTCRact4.lo(t) = min(0,solarTCR4(t));
solarTCRact5.lo(t) = min(0,solarTCR5(t));
solarTCRact1.up(t) = solarTCR1(t);
solarTCRact2.up(t) = 0;
solarTCRact3.up(t) = solarTCR3(t);
solarTCRact4.up(t) = 0;
solarTCRact5.up(t) = solarTCR5(t);

sCharge.lo(s,t) = 0;
sCharge.up(s,t) = sRampRate(s);
sDischarge.lo(s,t) = 0;
sDischarge.up(s,t) = sRampRate(s);
sSOC.lo(s,t) = sSOCmax(s)* 0.1;
sSOC.up(s,t) = sSOCmax(s)* 0.9;

vCharge.up(v,t,a) = vNum(v,a)*vCR(v)*vAvailable(t,v);
vDischarge.up(v,t,a) = vNum(v,a)*vCR(v)*vAvailable(t,v);
vSOC.lo(v,t,a) = 0.1*vNum(v,a)*vBattery(v);
vSOC.up(v,t,a) = 0.9*vNum(v,a)*vBattery(v);

*vSOC.lo(v,t,a) = 0;
*vSOC.up(v,t,a) = 1;

TI12.lo(t)$(ord(t) gt 1) = -2*abs(TI12max(t));
TI12.up(t)$(ord(t) gt 1) = 2*abs(TI12max(t));
TI13.lo(t)$(ord(t) gt 1) = -2*abs(TI13max(t));
TI13.up(t)$(ord(t) gt 1) = 2*abs(TI13max(t));
TI15.lo(t)$(ord(t) gt 1) = -2*abs(TI15max(t));
TI15.up(t)$(ord(t) gt 1) = 2*abs(TI15max(t));
TI52.lo(t)$(ord(t) gt 1) = -2*abs(TI52max(t));
TI52.up(t)$(ord(t) gt 1) = 2*abs(TI52max(t));
TI23.lo(t)$(ord(t) gt 1) = -2*abs(TI23max(t));
TI23.up(t)$(ord(t) gt 1) = 2*abs(TI23max(t));
TI34.lo(t)$(ord(t) gt 1) = -2*abs(TI34max(t));
TI34.up(t)$(ord(t) gt 1) = 2*abs(TI34max(t));

* Fix values for first hour, which is the last hour of the previous day
sSOC.fx(s, t)$(ord(t) eq 1) = sInitSOC(s);
*sSOC.fx(s, t)$(ord(t) eq 49) = sSOCmax(s)/2;
sCharge.fx(s,t)$(ord(t) eq 1) = 0;
sDischarge.fx(s,t)$(ord(t) eq 1) = 0;
if((sum(g, gInitGen(g)) > 0),
         U.fx(g, t)$(ord(t) eq 1) = gInitState(g);
         gLevel.fx(g, t)$(ord(t) eq 1) = gInitGen(g);
);
        
gLevel.up(g,t) = gCapacity(g);  
* $GDXIN results.gdx    
* $LOAD gLevelStart = gLevel    
* gLevel.l(g,t)$(ord(t) gt 1 and ord(t) lt 20) = gLevelStart.l(g,t+24); 
* execute_unload "start.gdx" gLevel gLevelStart;
vSOC.fx(v,t,a)$(ord(t) eq 1) = vInitSOC(v,a); 

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

* Vehicle constraints
         VSOCc(v,t,a)
         VFULLYCHARGE(v,t,a)

* TCR constraints
         SUPPLYTCR1c(t)
         SUPPLYTCR2c(t)
         SUPPLYTCR3c(t)
         SUPPLYTCR4c(t)
         SUPPLYTCR5c(t)
* reserve constraints
         RESERVETCR1c(t)
         RESERVETCR2c(t)     
         RESERVETCR5c(t)
         gReserveC1(g,t)
         gReserveC2(g,t)
         gReserveC3(g,t)
         sReserveC(s,t)
         sReserveC2(s,t)
         vReserveC(v,t,a)
         vReserveC2(v,t,a)
         
         RESERVETCR1spinc(t)
         RESERVETCR2spinc(t)
         RESERVETCR5spinc(t)
         gReservespinC1(g,t)
         gReservespinC2(g,t)
         gReservespinC3(g,t)
         sReservespinC(s,t)
         sReservespinC2(s,t)
         vReservespinC(v,t,a)
         vReservespinC2(v,t,a);

OBJ_FN ..            SysCost =e= sum(tOpt, HourlyCost(tOpt));
HOURLY_COSTc(t) ..   HourlyCost(t) =e= sum(g, gLevel(g, t)*(gVC(g)) + gStartupCost(g, t) + gNLC(g)*U(g,t)+gReserve(g,t)*gReserveCost(g))+sum(s,2*sReserve(s,t))+sum((v,a),2*vReserve(v,t,a));
STARTUPCOSTc(g,t) .. gStartupCost(g,t) =g= gStartupC(g)*(U(g,t) - U(g,t-1));

* Load constraints for each TCR
SUPPLYTCR1c(t)$(ord(t) gt 1) ..            loadTCR1(t) =e= sum(gTCR1, gLevel(gTCR1, t)) - TI12(t) - TI13(t) - TI15(t) + windTCRact1(t) + solarTCRact1(t) + sum(sTCR1,sDischarge(sTCR1,t)-sCharge(sTCR1,t))-sum((v,a)$(ord(a) eq 1),vCharge(v,t,a)-vDischarge(v,t,a));
SUPPLYTCR2c(t)$(ord(t) gt 1) ..            loadTCR2(t) =e= sum(gTCR2, gLevel(gTCR2, t)) + TI12(t) + TI52(t) - TI23(t)   + windTCRact2(t) + solarTCRact2(t) + sum(sTCR2,sDischarge(sTCR2,t)-sCharge(sTCR2,t))-sum((v,a)$(ord(a) eq 2),vCharge(v,t,a)-vDischarge(v,t,a));
SUPPLYTCR3c(t)$(ord(t) gt 1) ..            loadTCR3(t) =e= sum(gTCR3, gLevel(gTCR3, t)) + TI23(t) + TI13(t) - TI34(t)   + windTCRact3(t) + solarTCRact3(t) + sum(sTCR3,sDischarge(sTCR3,t)-sCharge(sTCR3,t))-sum((v,a)$(ord(a) eq 3),vCharge(v,t,a)-vDischarge(v,t,a));
SUPPLYTCR4c(t)$(ord(t) gt 1) ..            loadTCR4(t) =e= sum(gTCR4, gLevel(gTCR4, t)) + TI34(t)   + windTCRact4(t) + solarTCRact4(t) + sum(sTCR4,sDischarge(sTCR4,t)-sCharge(sTCR4,t))-sum((v,a)$(ord(a) eq 4),vCharge(v,t,a)-vDischarge(v,t,a));
SUPPLYTCR5c(t)$(ord(t) gt 1) ..            loadTCR5(t) =e= sum(gTCR5, gLevel(gTCR5, t)) + TI15(t)  + windTCRact5(t) + solarTCRact5(t) - TI52(t) + sum(sTCR5,sDischarge(sTCR5,t)-sCharge(sTCR5,t))-sum((v,a)$(ord(a) eq 5),vCharge(v,t,a)-vDischarge(v,t,a));

*tempEqn(t)$(ord(t) gt 1) .. tempOutput(t) =e= sum((v,a)$(ord(a) eq 1),vCharge(v,t,a)*vNum(v,a)*vCR(v));

* Reserve constraints for each TCR 
RESERVETCR1c(t)$(ord(t) gt 1) ..            0.01* loadTCR1(t) + 0.005 * windTCRact1(t) + 0.003 * solarTCRact1(t) =l=    
                                            sum(gTCR1, gReserve(gTCR1,t))+sum((v,a)$(ord(a) eq 1),vReserve(v,t,a))+sum(sTCR1,sReserve(sTCR1,t));    
RESERVETCR2c(t)$(ord(t) gt 1) ..            0.01* loadTCR2(t) + 0.005 * windTCRact2(t) + 0.0033 * solarTCRact2(t) +
                                            0.01* loadTCR3(t) + 0.005 * windTCRact3(t) + 0.003 * solarTCRact3(t) +
                                            0.01* loadTCR4(t) + 0.005 * windTCRact4(t) + 0.003 * solarTCRact4(t) =l=   
                                            sum(gTCR2, gReserve(gTCR2,t))+sum((v,a)$(ord(a) eq 2),vReserve(v,t,a))+sum(sTCR2,sReserve(sTCR2,t))+
                                            sum(gTCR3, gReserve(gTCR3,t))+sum((v,a)$(ord(a) eq 3),vReserve(v,t,a))+sum(sTCR3,sReserve(sTCR3,t))+
                                            sum(gTCR4, gReserve(gTCR4,t))+sum((v,a)$(ord(a) eq 4),vReserve(v,t,a))+sum(sTCR4,sReserve(sTCR4,t));
RESERVETCR5c(t)$(ord(t) gt 1) ..            0.01* loadTCR5(t) + 0.005 * windTCRact5(t) + 0.003 * solarTCRact5(t) =l=    
                                            sum(gTCR5, gReserve(gTCR5,t))+sum((v,a)$(ord(a) eq 5),vReserve(v,t,a))+sum(sTCR5,sReserve(sTCR5,t));    

RESERVETCR1spinc(t)$(ord(t) gt 1) ..            0.03* loadTCR1(t) =l=   
                                            sum(gTCR1, gReservespin(gTCR1,t))+sum((v,a)$(ord(a) eq 1),vReservespin(v,t,a))  
                                            +sum(sTCR1,sReservespin(sTCR1,t));  

RESERVETCR2spinc(t)$(ord(t) gt 1) ..        0.03* loadTCR2(t)+
                                            0.03* loadTCR3(t)+
                                            0.03* loadTCR4(t)=l=   
                                            sum(gTCR2, gReservespin(gTCR2,t))+sum((v,a)$(ord(a) eq 2),vReservespin(v,t,a))  
                                            +sum(sTCR2,sReservespin(sTCR2,t))+
                                            sum(gTCR3, gReservespin(gTCR3,t))+sum((v,a)$(ord(a) eq 3),vReservespin(v,t,a))  
                                            +sum(sTCR3,sReservespin(sTCR3,t))+
                                            sum(gTCR4, gReservespin(gTCR4,t))+sum((v,a)$(ord(a) eq 4),vReservespin(v,t,a))  
                                            +sum(sTCR4,sReservespin(sTCR4,t));  

RESERVETCR5spinc(t)$(ord(t) gt 1) ..            0.03* loadTCR5(t) =l=   
                                            sum(gTCR5, gReservespin(gTCR5,t))+sum((v,a)$(ord(a) eq 5),vReservespin(v,t,a))  
                                            +sum(sTCR5,sReservespin(sTCR5,t));  

* Regulation reserve constraints


gReserveC1(g,t)$(ord(t) gt 1) ..            gReserve(g,t) =l= 1/12*(gLevel(g, t-1) + gRampRate(g)*U(g,t-1)+gMinCapacity(g)*(U(g,t)-U(g,t-1))-gLevel(g,t))-gReservespin(g,t);
gReserveC2(g,t) ..                          gReserve(g,t) =l= 1/12*(gCapacity(g)-gLevel(g,t))-gReservespin(g,t);
gReserveC3(g,t) ..                          gReserve(g,t) =l= 1/12*(gCapacity(g)*U(g,t))-gReservespin(g,t);
sReserveC(s,t) ..                           sReserve(s,t) =l= sDischarge.up(s,t)-sDischarge(s,t)+sCharge(s,t)-sReservespin(s,t);
sReserveC2(s,t) ..                          sReserve(s,t) =l= sSOC(s,t)-sReservespin(s,t);
vReserveC(v,t,a) ..                         vReserve(v,t,a) =l= vDischarge.up(v,t,a)-vDischarge(v,t,a)+vCharge(v,t,a)-vReservespin(v,t,a);
vReserveC2(v,t,a)..                         vReserve(v,t,a) =l= vSOC(v,t,a)-vReservespin(v,t,a);


* Spinning reserve constraints
gReservespinC1(g,t)$(ord(t) gt 1) ..            gReservespin(g,t) =l= 1/6*(gLevel(g, t-1) + gRampRate(g)*U(g,t-1)+gMinCapacity(g)*(U(g,t)-U(g,t-1))-gLevel(g,t))-gReserve(g,t);
gReservespinC2(g,t) ..                          gReservespin(g,t) =l= 1/6*(gCapacity(g)-gLevel(g,t))-gReserve(g,t);
gReservespinC3(g,t) ..                          gReservespin(g,t) =l= 1/6*(gCapacity(g)*U(g,t))-gReserve(g,t);
sReservespinC(s,t) ..                           sReservespin(s,t) =l= sDischarge.up(s,t)-sDischarge(s,t)+sCharge(s,t)-sReserve(s,t);
sReservespinC2(s,t) ..                          sReservespin(s,t) =l= sSOC(s,t)-sReserve(s,t);
vReservespinC(v,t,a) ..                         vReserve(v,t,a) =l= vDischarge.up(v,t,a)-vDischarge(v,t,a)+vCharge(v,t,a)-vReserve(v,t,a);
vReservespinC2(v,t,a)..                         vReserve(v,t,a) =l= vSOC(v,t,a)-vReserve(v,t,a);

* Generation levels
MAXGENc(g,t) ..      gLevel(g,t) =l= gCapacity(g)*U(g,t);
MINGENc(g,t) ..      gLevel(g,t) =g= gMinCapacity(g)*U(g,t);
*MAXGENc(g,t) ..      gLevel(g,t) + gLevelReserves(g,t) =l= gCapacity(g)*U(g,t);
*MINGENc(g,t) ..      gLevel(g,t) + gLevelReserves(g,t)  =g= gMinCapacity(g)*U(g,t);

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

* Vehicle Constraints
VSOCc(v,t,a)$(ord(t) gt 1) ..                vSOC(v,t,a) =e= vSOC(v,t-1,a)+ vCharge(v,t,a)*.95 - vDischarge(v,t,a)/.95- vMiles(t,v)*vNum(v,a)*vEff(v);
VFULLYCHARGE(v,t,a)$fct(v,t)..               vSOC(v,t,a) =e= 0.9*vNum(v,a)*vBattery(v);

Model PHORUM /all/;


$Onlisting 
PHORUM.OptFile=1;
Option rMIP = OSIGUROBI;
Option Threads = 46;
Option asyncSolLst = 0;
Option limrow=0;
Option limcol=0;
Solve PHORUM using rMIP minimizing SysCost;


gap =  abs(PHORUM.objest - PHORUM.objval)/(1e-10+abs(PHORUM.objval));
modelStatus = PHORUM.modelStat;
solveStatus = PHORUM.solveStat;

execute_unload "results.gdx" modelStatus solveStatus gap gLevel U HourlyCost gVC sReserve gReserve vReserve sDischarge sCharge sSOC loadTCR1 loadTCR2 loadTCR3 loadTCR4 loadTCR5 windTCRact1 windTCRact2 windTCRact3 windTCRact4 windTCRact5 solarTCRact1 solarTCRact2 solarTCRact3 solarTCRact4 solarTCRact5 vSOC.l vCharge.l vDischarge.l  SUPPLYTCR1c.m SUPPLYTCR2c.m SUPPLYTCR3c.m SUPPLYTCR4c.m SUPPLYTCR5c.m RESERVETCR1c.m RESERVETCR2c.m RESERVETCR5c.m RESERVETCR1spinc.m RESERVETCR2spinc.m RESERVETCR5spinc.m TI12 TI15 TI13 TI52 TI23 TI34 TI12max loadTCR5 TI13max TI15max TI52max TI23max TI34max gReservespin sReservespin vReservespin
