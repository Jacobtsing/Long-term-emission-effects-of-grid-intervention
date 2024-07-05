 function [totalResults, prevDayResults] = ParseOutputs_2(totalResults, PHORUMdata, day, dEnd, totalRuntime, tic, isControlledCharging,optWindow, EVdata, dirString)

% This function parses the results from the GAMS run.  It pulls
% results from results.GDX, cleans the data, and saves it to the
% totalResults structure.  Cross-day variables are saved to the
% prevDayResults structure. 
numGens = length(PHORUMdata.genData.HeatRate);
numStors = length(PHORUMdata.storageData.PowerCapacity);
isControlledCharging = isControlledCharging;
% Check if this is the last day of the range.  If so, save results for all 48 hours.
 hour = 24;
 lastDay = 0;
 if day == dEnd - 1
     hour = optWindow;
     lastDay = 1;
 end

% Save date and runtime
totalResults.date = [totalResults.date, day];
if lastDay == 1
    totalResults.date = [totalResults.date, day+1];
end    

runtime = toc;
totalRuntime = sum(totalResults.runtime) + runtime;
totalResults.runtime = [totalResults.runtime,runtime];
disp(['Day complete.  Runtime: ', num2str(runtime/60), ', Total runtime: ', num2str(totalRuntime/60)]);

GAMSoutput.form = 'full';
GAMSoutput.compress = 'false';
gdxFileString = convertStringsToChars(strcat(pwd(),'/Cases/',dirString,'/results.gdx'));

GAMSoutput.name = 'solveStatus'; output = rgdx(gdxFileString, GAMSoutput);
solveStatus = output.val;
totalResults.solveStatus = [totalResults.solveStatus, output.val];
GAMSoutput.name = 'modelStatus'; output = rgdx(gdxFileString, GAMSoutput);
totalResults.modelStatus = [totalResults.modelStatus, output.val];
GAMSoutput.name = 'gap'; output = rgdx(gdxFileString, GAMSoutput);
totalResults.gap = [totalResults.gap, output.val];

%% If optimization did not execute correctly, set results = 0 and return
if solveStatus > 4 %1=normal completion, 2=iteration interrupt, 3=resource interrupt (time limit)
    totalResults.loadTCR1 = [totalResults.loadTCR1, zeros(1,hour)];
    totalResults.loadTCR2 = [totalResults.loadTCR2, zeros(1,hour)];
    totalResults.loadTCR3 = [totalResults.loadTCR3, zeros(1,hour)];
    totalResults.loadTCR4 = [totalResults.loadTCR4, zeros(1,hour)];
    totalResults.loadTCR5 = [totalResults.loadTCR5, zeros(1,hour)];

%   Storage
    totalResults.sSOC = [totalResults.sSOC, zeros(numStors,hour)];

    % Transmission
    totalResults.tLevelTI12 = [totalResults.tLevelTI12, zeros(1,hour)];
    totalResults.tLevelTI13 = [totalResults.tLevelTI13, zeros(1,hour)];
    totalResults.tLevelTI15 = [totalResults.tLevelTI15, zeros(1,hour)];
    totalResults.tLevelTI52 = [totalResults.tLevelTI52, zeros(1,hour)];
    totalResults.tLevelTI23 = [totalResults.tLevelTI23, zeros(1,hour)];
    totalResults.tLevelTI34 = [totalResults.tLevelTI34, zeros(1,hour)];

    totalResults.tMaxTI12 = [totalResults.tMaxTI12, zeros(1,hour)];
    totalResults.tMaxTI13 = [totalResults.tMaxTI13, zeros(1,hour)];
    totalResults.tMaxTI15 = [totalResults.tMaxTI15, zeros(1,hour)];
    totalResults.tMaxTI52 = [totalResults.tMaxTI52, zeros(1,hour)];
    totalResults.tMaxTI23 = [totalResults.tMaxTI23, zeros(1,hour)];
    totalResults.tMaxTI34 = [totalResults.tMaxTI34, zeros(1,hour)];

    % LMPs
    totalResults.LMPTCR1 = [totalResults.LMPTCR1, zeros(1,hour)];
    totalResults.LMPTCR2 = [totalResults.LMPTCR2, zeros(1,hour)];
    totalResults.LMPTCR3 = [totalResults.LMPTCR3, zeros(1,hour)];
    totalResults.LMPTCR4 = [totalResults.LMPTCR4, zeros(1,hour)];
    totalResults.LMPTCR5 = [totalResults.LMPTCR5, zeros(1,hour)];
%    totalResults.LMPTCR1actual = [totalResults.LMPTCR1actual, zeros(1,hour)];
%    totalResults.LMPTCR2actual = [totalResults.LMPTCR2actual, zeros(1,hour)];
%    totalResults.LMPTCR3actual = [totalResults.LMPTCR3actual, zeros(1,hour)];
%    totalResults.LMPTCR4actual = [totalResults.LMPTCR4actual, zeros(1,hour)];
%    totalResults.LMPTCR5actual = [totalResults.LMPTCR5actual, zeros(1,hour)];
    % Reserve LMP
    totalResults.RESERVETCR1c = [totalResults.RESERVETCR1c, zeros(1,hour)];
    totalResults.RESERVETCR2c = [totalResults.RESERVETCR2c, zeros(1,hour)];
    totalResults.RESERVETCR5c = [totalResults.RESERVETCR5c, zeros(1,hour)];
    
    % System Cost
    totalResults.sysCost = [totalResults.sysCost, 0];
    totalResults.gLevel = [totalResults.gLevel, zeros(numGens,1)];
    totalResults.gRuntime = [totalResults.gRuntime, zeros(numGens,1)];
    totalResults.gStartup = [totalResults.gStartup, zeros(numGens,1)];
%    totalResults.gGrossRevenue = [totalResults.gGrossRevenue, zeros(numGens,1)];
    totalResults.gVC = [totalResults.gVC, zeros(numGens,1)];
%    totalResults.wind = [totalResults.wind, 0];
    totalResults.windSolarTCR1 = [totalResults.windSolarTCR1, zeros(1,hour)];
    totalResults.windSolarTCR2 = [totalResults.windSolarTCR2, zeros(1,hour)];
    totalResults.windSolarTCR3 = [totalResults.windSolarTCR3, zeros(1,hour)];
    totalResults.windSolarTCR4 = [totalResults.windSolarTCR4, zeros(1,hour)];
    totalResults.windSolarTCR5 = [totalResults.windSolarTCR5, zeros(1,hour)];

%   totalResults.sNetRevenue = [totalResults.sNetRevenue, zeros(numStors,1)];
    totalResults.sCharge = [totalResults.sCharge, zeros(numStors,1)];
    totalResults.sDischarge = [totalResults.sDischarge, zeros(numStors,1)];

    if isControlledCharging == 1   
        totalResults.vSOC = [totalResults.vSOC, zeros(size(EVdata.prevSOC,1),hour,size(EVdata.prevSOC,2))];
        totalResults.vCharge = [totalResults.vCharge, zeros(size(EVdata.prevSOC,1),1,size(EVdata.prevSOC,2))];
        totalResults.vDischarge = [totalResults.vDischarge, zeros(size(EVdata.prevSOC,1),1,size(EVdata.prevSOC,2))];   
        totalResults.vReserve = [totalResults.vReserve, zeros(size(EVdata.prevSOC,1),1,size(EVdata.prevSOC,2))];
        %spinning reserve not modeled yet
    end

% Set prevDayResults to null
     prevDayResults.Ontime = [];
     prevDayResults.Downtime = [];
     prevDayResults.InitState = [];
     prevDayResults.InitGen = [];
     prevDayResults.sInitSOC = [];
     if isControlledCharging == 1, prevDayResults.vInitSOC = []; end

     save('totalResults', 'totalResults');
    return;
end


%% Pull outputs from GAMS


% Wind
% GAMSoutput.name = 'wind';
% output = rgdx(gdxFileString,GAMSoutput);
% wind = output.val;


% Generation
GAMSoutput.name = 'gLevel';
output = rgdx(gdxFileString, GAMSoutput);
gLevel = output.val;
% compress manually. the values returned by gams are bloated with zeros.
% 1113x1113
numStorageUnits = size(PHORUMdata.storageData.TCR,1);
numGens = size(PHORUMdata.genData.TCR,1);
numResults = size(gLevel,1);
% Variable costs
GAMSoutput.name = 'gVC';
output = rgdx(gdxFileString, GAMSoutput);
gVC = output.val;

% Generator reserve offer
GAMSoutput.name = 'gReserve';
output = rgdx(gdxFileString, GAMSoutput);
gReserve = output.val;
GAMSoutput.name = 'gReservespin';
output = rgdx(gdxFileString, GAMSoutput);
gReservespin = output.val;
% Generators
gLevel = gLevel(numResults - (numStorageUnits) - (numGens)+1 : numResults - numStorageUnits, 2:hour+1);
gReserve = gReserve(numResults - (numStorageUnits) - (numGens)+1 : numResults - numStorageUnits, 2:hour+1);
gReservespin = gReservespin(numResults - (numStorageUnits) - (numGens)+1 : numResults - numStorageUnits, 2:hour+1);
gVC = gVC(numResults - (numStorageUnits) - (numGens)+1 : numResults - numStorageUnits, 1);

% Load
GAMSoutput.name = 'loadTCR1';
output = rgdx(gdxFileString, GAMSoutput);
loadTCR1 = output.val;
GAMSoutput.name = 'loadTCR2';
output = rgdx(gdxFileString, GAMSoutput);
loadTCR2 = output.val;
GAMSoutput.name = 'loadTCR3';
output = rgdx(gdxFileString, GAMSoutput);
loadTCR3 = output.val;
GAMSoutput.name = 'loadTCR4';
output = rgdx(gdxFileString, GAMSoutput);
loadTCR4 = output.val;
GAMSoutput.name = 'loadTCR5';
output = rgdx(gdxFileString, GAMSoutput);
loadTCR5 = output.val;

GAMSoutput.name = 'loadshedTCR1';
output = rgdx(gdxFileString, GAMSoutput);
loadshedTCR1 = output.val;
GAMSoutput.name = 'loadshedTCR2';
output = rgdx(gdxFileString, GAMSoutput);
loadshedTCR2 = output.val;
GAMSoutput.name = 'loadshedTCR3';
output = rgdx(gdxFileString, GAMSoutput);
loadshedTCR3 = output.val;
GAMSoutput.name = 'loadshedTCR4';
output = rgdx(gdxFileString, GAMSoutput);
loadshedTCR4 = output.val;
GAMSoutput.name = 'loadshedTCR5';
output = rgdx(gdxFileString, GAMSoutput);
loadshedTCR5 = output.val;
loadshedTCR1 = loadshedTCR1(2:hour+1);
loadshedTCR2 = loadshedTCR2(2:hour+1);
loadshedTCR3 = loadshedTCR3(2:hour+1);
loadshedTCR4 = loadshedTCR4(2:hour+1);
loadshedTCR5 = loadshedTCR5(2:hour+1);

GAMSoutput.name = 'respenaltyTCR1';
output = rgdx(gdxFileString, GAMSoutput);
respenaltyTCR1 = output.val;
GAMSoutput.name = 'respenaltyTCR2';
output = rgdx(gdxFileString, GAMSoutput);
respenaltyTCR2 = output.val;
GAMSoutput.name = 'respenaltyTCR5';
output = rgdx(gdxFileString, GAMSoutput);
respenaltyTCR5 = output.val;
respenaltyTCR1 = respenaltyTCR1(2:hour+1);
respenaltyTCR2 = respenaltyTCR2(2:hour+1);
respenaltyTCR5 = respenaltyTCR5(2:hour+1);
GAMSoutput.name = 'spinpenaltyTCR1';
output = rgdx(gdxFileString, GAMSoutput);
spinpenaltyTCR1 = output.val;
GAMSoutput.name = 'spinpenaltyTCR2';
output = rgdx(gdxFileString, GAMSoutput);
spinpenaltyTCR2 = output.val;
GAMSoutput.name = 'spinpenaltyTCR5';
output = rgdx(gdxFileString, GAMSoutput);
spinpenaltyTCR5 = output.val;
spinpenaltyTCR1 = spinpenaltyTCR1(2:hour+1);
spinpenaltyTCR2 = spinpenaltyTCR2(2:hour+1);
spinpenaltyTCR5 = spinpenaltyTCR5(2:hour+1);
% Load
loadTCR1 = loadTCR1(2:hour+1);
loadTCR2 = loadTCR2(2:hour+1);
loadTCR3 = loadTCR3(2:hour+1);
loadTCR4 = loadTCR4(2:hour+1);
loadTCR5 = loadTCR5(2:hour+1);
% windSolar
GAMSoutput.name = 'windTCRact1';
output = rgdx(gdxFileString, GAMSoutput);
windTCR1 = output.val;
windTCR1 = windTCR1(2:hour+1);
GAMSoutput.name = 'windTCRact2';
output = rgdx(gdxFileString, GAMSoutput);
windTCR2 = output.val;
windTCR2 = windTCR2(2:hour+1);
GAMSoutput.name = 'windTCRact3';
output = rgdx(gdxFileString, GAMSoutput);
windTCR3 = output.val;
windTCR3 = windTCR3(2:hour+1);
GAMSoutput.name = 'windTCRact4';
output = rgdx(gdxFileString, GAMSoutput);
windTCR4 = output.val;
windTCR4 = windTCR4(2:hour+1);
GAMSoutput.name = 'windTCRact5';
output = rgdx(gdxFileString, GAMSoutput);
windTCR5 = output.val;
windTCR5 = windTCR5(2:hour+1);

GAMSoutput.name = 'solarTCRact1';
output = rgdx(gdxFileString, GAMSoutput);
solarTCR1 = output.val;
solarTCR1 = solarTCR1(2:hour+1);
GAMSoutput.name = 'solarTCRact2';
output = rgdx(gdxFileString, GAMSoutput);
solarTCR2 = output.val;
solarTCR2 = solarTCR2(2:hour+1);
GAMSoutput.name = 'solarTCRact3';
output = rgdx(gdxFileString, GAMSoutput);
solarTCR3 = output.val;
solarTCR3 = solarTCR3(2:hour+1);
GAMSoutput.name = 'solarTCRact4';
output = rgdx(gdxFileString, GAMSoutput);
solarTCR4 = output.val;
solarTCR4 = solarTCR4(2:hour+1);
GAMSoutput.name = 'solarTCRact5';
output = rgdx(gdxFileString, GAMSoutput);
solarTCR5 = output.val;
solarTCR5 = solarTCR5(2:hour+1);
%transmission
GAMSoutput.name = 'TI12';
output = rgdx(gdxFileString, GAMSoutput);
tLevelTI12 = output.val;
GAMSoutput.name = 'TI13';
output = rgdx(gdxFileString, GAMSoutput);
tLevelTI13 = output.val;
GAMSoutput.name = 'TI15';
output = rgdx(gdxFileString, GAMSoutput);
tLevelTI15 = output.val;
GAMSoutput.name = 'TI52';
output = rgdx(gdxFileString, GAMSoutput);
tLevelTI52 = output.val;
GAMSoutput.name = 'TI23';
output = rgdx(gdxFileString, GAMSoutput);
tLevelTI23 = output.val;
GAMSoutput.name = 'TI34';
output = rgdx(gdxFileString, GAMSoutput);
tLevelTI34 = output.val;
tLevelTI12 = tLevelTI12(2:hour+1);
tLevelTI13 = tLevelTI13(2:hour+1);
tLevelTI15 = tLevelTI15(2:hour+1);
tLevelTI52 = tLevelTI52(2:hour+1);
tLevelTI23 = tLevelTI23(2:hour+1);
tLevelTI34 = tLevelTI34(2:hour+1);
GAMSoutput.name = 'TI12max';
output = rgdx(gdxFileString, GAMSoutput);
tMaxTI12 = output.val;
GAMSoutput.name = 'TI13max';
output = rgdx(gdxFileString, GAMSoutput);
tMaxTI13 = output.val;
 GAMSoutput.name = 'TI15max';
output = rgdx(gdxFileString, GAMSoutput);
tMaxTI15 = output.val;
 GAMSoutput.name = 'TI52max';
output = rgdx(gdxFileString, GAMSoutput);
tMaxTI52 = output.val;
 GAMSoutput.name = 'TI23max';
output = rgdx(gdxFileString, GAMSoutput);
tMaxTI23 = output.val;
 GAMSoutput.name = 'TI34max';
output = rgdx(gdxFileString, GAMSoutput);
tMaxTI34 = output.val;
tMaxTI12 = tMaxTI12(2:hour+1);
tMaxTI13 = tMaxTI13(2:hour+1);
tMaxTI15 = tMaxTI15(2:hour+1);
tMaxTI52 = tMaxTI52(2:hour+1);
tMaxTI23 = tMaxTI23(2:hour+1);
tMaxTI34 = tMaxTI34(2:hour+1);
% reserve constraints
GAMSoutput.compress = 'false';
GAMSoutput.field = 'm';
GAMSoutput.name = 'RESERVETCR1c';
output = rgdx(gdxFileString, GAMSoutput);
RESERVETCR1c = -output.val;

GAMSoutput.compress = 'false';
GAMSoutput.name = 'RESERVETCR2c';
GAMSoutput.field = 'm';
output = rgdx(gdxFileString, GAMSoutput);
RESERVETCR2c = -output.val;

GAMSoutput.compress = 'false';
GAMSoutput.name = 'RESERVETCR5c';
GAMSoutput.field = 'm';
output = rgdx(gdxFileString, GAMSoutput);
RESERVETCR5c = -output.val;
% RESERVE LMP
RESERVETCR1c = RESERVETCR1c(2:hour+1);
RESERVETCR2c = RESERVETCR2c(2:hour+1);
RESERVETCR5c = RESERVETCR5c(2:hour+1);
% Storage
GAMSoutput.compress='false';
GAMSoutput.name = 'sSOC';
GAMSoutput.field = 'l';
output  = rgdx(gdxFileString,GAMSoutput);
sSOC = output.val;
GAMSoutput.compress='false';

GAMSoutput.name = 'sDischarge';
output = rgdx(gdxFileString,GAMSoutput);
sDischarge = output.val;
GAMSoutput.name = 'sCharge';
output = rgdx(gdxFileString,GAMSoutput);
sCharge = output.val;
GAMSoutput.name = 'sReserve';
output = rgdx(gdxFileString,GAMSoutput);
sReserve = output.val;
GAMSoutput.name = 'sReservespin';
output = rgdx(gdxFileString,GAMSoutput);
sReservespin = output.val;
if solveStatus > 3
    sSOC = zeros(numStorageUnits,hour);
    sDischarge = zeros(numStorageUnits,hour);
    sCharge = zeros(numStorageUnits,hour);
    sDiff = zeros(numStorageUnits,hour);
else
    sSOC2 = sSOC(numResults-(numStorageUnits-1):numResults, 1:hour+1);
    sSOC = sSOC(numResults-(numStorageUnits-1):numResults, 2:hour+1);
    
    sDiff = diff(sSOC2,1,2);
    clear sSOC2
    sDischarge = sDischarge(numResults-(numStorageUnits-1): numResults, 2:hour+1);
    sCharge = sCharge(numResults-(numStorageUnits-1):numResults, 2:hour+1);
    sReserve = sReserve(numResults-(numStorageUnits-1):numResults, 2:hour+1);
    sReservespin = sReservespin(numResults-(numStorageUnits-1):numResults, 2:hour+1);
end
% Hourly system cost
GAMSoutput.name = 'HourlyCost';
output = rgdx(gdxFileString, GAMSoutput);
sysCost = output.val;
% Sys Cost 
sysCost = sysCost(2:hour+1);

% If running EVs, pull EV data
if isControlledCharging >= 1
    GAMSoutput.name = 'vSOC';
    GAMSoutput.compress = 'true';
    GAMSoutput.field = 'l';
    output = rgdx(gdxFileString, GAMSoutput);
    vSOC = output.val;
    if solveStatus > 3 % If the day did not solve
       vSOC = zeros(size(EVdata.number,1),hour,size(EVdata.number,2));
       vDiff = zeros(size(EVdata.number,1),hour,size(EVdata.number,2));
    else
        vDiff = diff(vSOC,1,2);
        vSOC = vSOC(:,2:hour+1,:);
    end
    vCharge = [];
    vDischarge = [];
    for y = 1 : size(vSOC,1)
        for z = 1 : size(vSOC,3)
            for i = 1 : hour
                if vDiff(y,i,z) >= 0
                    vCharge(y,i, z) = vDiff(y,i, z);
                    vDischarge(y,i, z) = 0;
                else
                    vCharge(y,i, z) = 0;
                    vDischarge(y,i, z) = -vDiff(y,i, z);
                end
            end
        end
    end
    GAMSoutput.form = 'sparse';
    GAMSoutput.field = 'l';
    GAMSoutput.name = 'vReserve';
    GAMSoutput.compress = 'false';

    output = rgdx(gdxFileString, GAMSoutput);
    
    vReserve = zeros(15,hour,5);
    [m n] = size(output.val);
    res = output.val;
    if hour == 48
        for i=1:m
            if res(i,2) ~= 1
                vReserve(res(i,1)-49,res(i,2)-1,res(i,3)-64) = res(i,4);
            end
        end
    elseif hour == 24
        for i=1:m
            if res(i,2) > 24
                vReserve(res(i,1)-49,res(i,2)-24,res(i,3)-64) = res(i,4);
            end
        end
    end
    GAMSoutput.form = 'sparse';
    GAMSoutput.field = 'l';
    GAMSoutput.name = 'vReservespin';
    GAMSoutput.compress = 'false';
    output = rgdx(gdxFileString, GAMSoutput);
    vReservespin = zeros(15,hour,5);
    [m n] = size(output.val);
    res = output.val;
    if hour == 48
        for i=1:m
            if res(i,2) ~= 1
                vReservespin(res(i,1)-49,res(i,2)-1,res(i,3)-64) = res(i,4);
            end
        end
    elseif hour == 24
        for i=1:m
            if res(i,2) > 24
                vReservespin(res(i,1)-49,res(i,2)-24,res(i,3)-64) = res(i,4);
            end
        end
    end
end

% LMPs
GAMSoutput.form = 'full';
GAMSoutput.field = 'm';
GAMSoutput.name = 'SUPPLYTCR1c';
GAMSoutput.compress = 'true';
output = rgdx(gdxFileString, GAMSoutput);
LMPTCR1 = -output.val;

GAMSoutput.field = 'm';
GAMSoutput.name = 'SUPPLYTCR2c';
output = rgdx(gdxFileString, GAMSoutput);
LMPTCR2 = -output.val;

GAMSoutput.field = 'm';
GAMSoutput.name = 'SUPPLYTCR3c';
output = rgdx(gdxFileString, GAMSoutput);
LMPTCR3 = -output.val;

GAMSoutput.compress = 'True';
GAMSoutput.field = 'm';
GAMSoutput.name = 'SUPPLYTCR4c';
output = rgdx(gdxFileString, GAMSoutput);
LMPTCR4 = -output.val;

GAMSoutput.compress = 'True';
GAMSoutput.field = 'm';
GAMSoutput.name = 'SUPPLYTCR5c';
output = rgdx(gdxFileString, GAMSoutput);
LMPTCR5 = -output.val;
% LMP
if hour == 24
    LMPTCR1 = LMPTCR1(2:hour+1);
    LMPTCR2 = LMPTCR2(2:hour+1);
    LMPTCR3 = LMPTCR3(2:hour+1);
    LMPTCR4 = LMPTCR4(2:hour+1);
    LMPTCR5 = LMPTCR5(2:hour+1);
elseif hour ~= 24
    LMPTCR1 = LMPTCR1(1:hour);
    LMPTCR2 = LMPTCR2(1:hour);
    LMPTCR3 = LMPTCR3(1:hour);
    LMPTCR4 = LMPTCR4(1:hour);
    LMPTCR5 = LMPTCR5(1:hour);
end
%% Clean result structures
% undesired columns returned from GAMS are discarded



% % Storage - calculate sCharge & sDischarge
sCharge = [];
sDischarge = [];
for y = 1 : size(sSOC,1)
    for i = 1 : hour
        if sDiff(y,i) >= 0
            sCharge(y,i) = sDiff(y,i);
            sDischarge(y,i) = 0;
        else
            sCharge(y,i) = 0;
            sDischarge(y,i) = -sDiff(y,i);
        end
    end
end


%% Load prevDayResults

% How long generators have been on / off
for index = 1 : size(gLevel,1)
    hourCounter = 0;
    prevDayResults.Ontime(index) = 0;
    prevDayResults.Downtime(index) = 0;
    if gLevel(index, hour) > 0
        while gLevel(index, hour - hourCounter) > 0 && hourCounter < hour - 1
            prevDayResults.Ontime(index) = prevDayResults.Ontime(index) + 1;
            hourCounter = hourCounter + 1;
        end
    end
    if gLevel(index, hour) == 0
        while gLevel(index, hour - hourCounter) == 0 && hourCounter < hour - 1
            prevDayResults.Downtime(index) = prevDayResults.Downtime(index) + 1;
            hourCounter = hourCounter + 1;
        end
    end        
end

% Generator level and state (on/off)
for index = 1 : size(gLevel,1)
    prevDayResults.InitGen(index) = gLevel(index,hour);
    if gLevel(index,hour) > 0
        prevDayResults.InitState(index) = 1;
    else
        prevDayResults.InitState(index) = 0;
    end
end

% Storage state of charge
for index = 1 : size(sSOC,1)
    prevDayResults.sInitSOC(index) = sSOC(index,hour);
end

% Vehicle state of charge
if isControlledCharging >= 1
    prevDayResults.vInitSOC = zeros(size(EVdata.number,1),1,size(EVdata.number,2));
    for index = 1:size(EVdata.number,1) 
        prevDayResults.vInitSOC(index,1:size(vSOC,3)) = squeeze(vSOC(index,hour,1:size(vSOC,3)));
    end 
    prevDayResults.vInitSOC = squeeze(prevDayResults.vInitSOC);
end 


 %% Add the day's results to totalResults

% First, hourly results.

% Load
totalResults.loadTCR1 = [totalResults.loadTCR1, loadTCR1'];
totalResults.loadTCR2 = [totalResults.loadTCR2, loadTCR2'];
totalResults.loadTCR3 = [totalResults.loadTCR3, loadTCR3'];
totalResults.loadTCR4 = [totalResults.loadTCR4, loadTCR4'];
totalResults.loadTCR5 = [totalResults.loadTCR5, loadTCR5'];

% loadshed
totalResults.loadshedTCR1 = [totalResults.loadshedTCR1, loadshedTCR1'];
totalResults.loadshedTCR2 = [totalResults.loadshedTCR2, loadshedTCR2'];
totalResults.loadshedTCR3 = [totalResults.loadshedTCR3, loadshedTCR3'];
totalResults.loadshedTCR4 = [totalResults.loadshedTCR4, loadshedTCR4'];
totalResults.loadshedTCR5 = [totalResults.loadshedTCR5, loadshedTCR5'];
totalResults.respenaltyTCR1 = [totalResults.respenaltyTCR1, respenaltyTCR1'];
totalResults.respenaltyTCR2 = [totalResults.respenaltyTCR2, respenaltyTCR2'];
totalResults.respenaltyTCR5 = [totalResults.respenaltyTCR5, respenaltyTCR5'];
totalResults.spinpenaltyTCR1 = [totalResults.spinpenaltyTCR1, spinpenaltyTCR1'];
totalResults.spinpenaltyTCR2 = [totalResults.spinpenaltyTCR2, spinpenaltyTCR2'];
totalResults.spinpenaltyTCR5 = [totalResults.spinpenaltyTCR5, spinpenaltyTCR5'];

% Wind and solar
totalResults.windTCR1 = [totalResults.windTCR1, windTCR1'];
totalResults.windTCR2 = [totalResults.windTCR2, windTCR2'];
totalResults.windTCR3 = [totalResults.windTCR3, windTCR3'];
totalResults.windTCR4 = [totalResults.windTCR4, windTCR4'];
totalResults.windTCR5 = [totalResults.windTCR5, windTCR5'];

totalResults.solarTCR1 = [totalResults.solarTCR1, solarTCR1'];
totalResults.solarTCR2 = [totalResults.solarTCR2, solarTCR2'];
totalResults.solarTCR3 = [totalResults.solarTCR3, solarTCR3'];
totalResults.solarTCR4 = [totalResults.solarTCR4, solarTCR4'];
totalResults.solarTCR5 = [totalResults.solarTCR5, solarTCR5'];

% Storage
totalResults.sSOC = [totalResults.sSOC, sSOC(1:numStorageUnits,:)];
totalResults.sCharge = [totalResults.sCharge, sCharge(1:numStorageUnits,:)];
totalResults.sDischarge = [totalResults.sDischarge, sDischarge(1:numStorageUnits,:)];
totalResults.sReserve = [totalResults.sReserve, sReserve(1:numStorageUnits,:)];
totalResults.sReservespin = [totalResults.sReservespin, sReservespin(1:numStorageUnits,:)];

% Transmission
totalResults.tLevelTI12 = [totalResults.tLevelTI12, tLevelTI12'];
totalResults.tLevelTI13 = [totalResults.tLevelTI13, tLevelTI13'];
totalResults.tLevelTI15 = [totalResults.tLevelTI15, tLevelTI15'];
totalResults.tLevelTI52 = [totalResults.tLevelTI52, tLevelTI52'];
totalResults.tLevelTI23 = [totalResults.tLevelTI23, tLevelTI23'];
totalResults.tLevelTI34 = [totalResults.tLevelTI34, tLevelTI34'];


totalResults.tMaxTI12 = [totalResults.tMaxTI12, tMaxTI12'];
totalResults.tMaxTI13 = [totalResults.tMaxTI13, tMaxTI13'];
totalResults.tMaxTI15 = [totalResults.tMaxTI15, tMaxTI15'];
totalResults.tMaxTI52 = [totalResults.tMaxTI52, tMaxTI52'];
totalResults.tMaxTI23 = [totalResults.tMaxTI23, tMaxTI23'];
totalResults.tMaxTI34 = [totalResults.tMaxTI34, tMaxTI34'];

% LMPs
totalResults.LMPTCR1 = [totalResults.LMPTCR1, LMPTCR1'];
totalResults.LMPTCR2 = [totalResults.LMPTCR2, LMPTCR2'];
totalResults.LMPTCR3 = [totalResults.LMPTCR3, LMPTCR3'];
totalResults.LMPTCR4 = [totalResults.LMPTCR4, LMPTCR4'];
totalResults.LMPTCR5 = [totalResults.LMPTCR5, LMPTCR5'];

% RESERVE LMP
totalResults.RESERVETCR1c = [totalResults.RESERVETCR1c, RESERVETCR1c'];
totalResults.RESERVETCR2c = [totalResults.RESERVETCR2c, RESERVETCR2c'];
totalResults.RESERVETCR5c = [totalResults.RESERVETCR5c, RESERVETCR5c'];

% Next, daily outputs
% System Cost
totalResults.sysCost = [totalResults.sysCost, transpose(sysCost)];
% Generation
gRuntime = zeros(size(gLevel,1),size(gLevel,2));
gStartup = zeros(size(gLevel,1),size(gLevel,2));
%gGrossRevenue = zeros(size(gLevel,1),size(gLevel,2));

gTCR = PHORUMdata.genData.TCR;

for rowIndex = 1 : size(gLevel,1)
    for colIndex = 1 : size(gLevel,2)
        % Generator runtime
        if gLevel(rowIndex,colIndex) > 0
            gRuntime(rowIndex,colIndex) = 1;
            % Generator startup
            if colIndex > 1 
                if gLevel(rowIndex,colIndex - 1) == 0
                    gStartup(rowIndex,colIndex) = 1;
                end
            end
        end
%{
        % Generator gross revenue
        if (gTCR(rowIndex) == 1) 
            gGrossRevenue(rowIndex,colIndex) = LMPTCR1(colIndex)*gLevel(rowIndex,colIndex);
        elseif (gTCR(rowIndex) == 2) 
            gGrossRevenue(rowIndex,colIndex) = LMPTCR2(colIndex)*gLevel(rowIndex,colIndex);
        elseif (gTCR(rowIndex) == 3) 
            gGrossRevenue(rowIndex,colIndex) = LMPTCR3(colIndex)*gLevel(rowIndex,colIndex);
        elseif (gTCR(rowIndex) == 4) 
            gGrossRevenue(rowIndex,colIndex) = LMPTCR4(colIndex)*gLevel(rowIndex,colIndex);
        elseif (gTCR(rowIndex) == 5) 
            gGrossRevenue(rowIndex,colIndex) = LMPTCR5(colIndex)*gLevel(rowIndex,colIndex);
        end 
   %}
    end
end
totalResults.gLevel = [totalResults.gLevel, gLevel];
totalResults.gRuntime = [totalResults.gRuntime, gRuntime];
totalResults.gStartup = [totalResults.gStartup, gStartup];
totalResults.gReserve = [totalResults.gReserve, gReserve];
totalResults.gReservespin = [totalResults.gReservespin, gReservespin];
% totalResults.gGrossRevenue = [totalResults.gGrossRevenue, sum(gGrossRevenue,2)];
totalResults.gVC = [totalResults.gVC, gVC];
% totalResults.wind = [totalResults.wind,sum(wind)];

% Storage gross revenue
%{
sTCR = PHORUMdata.storageData.sTCR;
sNetRevenue = zeros(size(sSOC,1),size(sSOC,2));
for rowIndex = 1 : size(sSOC,1)
    for colIndex = 1 : size(sSOC,2)
        if (sTCR(rowIndex) == 1) 
            sNetRevenue(rowIndex,colIndex) = LMPTCR1(colIndex)*(sDischarge(rowIndex,colIndex)-sCharge(rowIndex,colIndex));
        elseif (sTCR(rowIndex) == 2) 
            sNetRevenue(rowIndex,colIndex) = LMPTCR2(colIndex)*(sDischarge(rowIndex,colIndex)-sCharge(rowIndex,colIndex));
        elseif (sTCR(rowIndex) == 3) 
            sNetRevenue(rowIndex,colIndex) = LMPTCR3(colIndex)*(sDischarge(rowIndex,colIndex)-sCharge(rowIndex,colIndex));
        elseif (sTCR(rowIndex) == 4) 
            sNetRevenue(rowIndex,colIndex) = LMPTCR4(colIndex)*(sDischarge(rowIndex,colIndex)-sCharge(rowIndex,colIndex));
        elseif (sTCR(rowIndex) == 5) 
            sNetRevenue(rowIndex,colIndex) = LMPTCR5(colIndex)*(sDischarge(rowIndex,colIndex)-sCharge(rowIndex,colIndex));
        end
    end
end

totalResults.sNetRevenue = [totalResults.sNetRevenue, sum(sNetRevenue,2)];
%}
% totalResults.sCharge = [totalResults.sCharge, sum(sCharge,2)];
% totalResults.sDischarge = [totalResults.sDischarge, sum(sDischarge,2)];

% EV outputs -- outputting HOURLY outputs.
if isControlledCharging >= 1
    totalResults.vSOC = [totalResults.vSOC, vSOC];
    totalResults.vCharge = [totalResults.vCharge, vCharge];
    totalResults.vDischarge = [totalResults.vDischarge, vDischarge]; 
    totalResults.vReserve = [totalResults.vReserve, vReserve];
    totalResults.vReservespin = [totalResults.vReservespin, vReservespin];
end

save(strcat('Cases/',dirString,'/totalResults.mat'),'totalResults');
save(strcat('Cases/',dirString,'/prevDayResults.mat'),'prevDayResults');
end