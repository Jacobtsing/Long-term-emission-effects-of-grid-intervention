addpath '/home/jiahuic/Downloads/gams43.4_linux_x64_64_sfx'
addpath '/home/jiahuic/V2G_PJM'
parfor loopVar = 31:45; 
    
    str = string(loopVar) 
    fun_Main_2('UC',str); 

end

function fun_Main_2(type,suffix)
% This is the primary PHORUM Matlab function.  The function makes 
% several sub-function calls, and is responsible for calling GAMS. 
% The function loads data from the database file and settings file.
cd('/home/jiahuic/V2G_PJM');
CR0= 1;
year = 2035;
REPct = suffix;
thisDir = '/home/jiahuic/V2G_PJM';
reserveString = '_reserve3'; 
% Load settings

% Set up a working directory for this test case
dirStringPrefix = 'BEV300_2021GREET';
if strlength(type)==0 dirStringPrefix ='NoEV'; end
if strcmp(type,'CC')
    Stg_path = 'Inputs/2035_30PctRE_loB_recost_1/storage_2035.csv';
    isControlledCharging = 1;
    dirString = strcat(dirStringPrefix,'_CC',string(isControlledCharging), '_',string(2035),'_Txn1');end
if strcmp(type,'UC')
    Stg_path = 'Inputs/2035_30PctRE_loB_recost_1/storage_2035.csv';
    isControlledCharging = 0;
    dirString = strcat(dirStringPrefix,'_UC',string(isControlledCharging), '_',string(2035),'_Txn1');end
if strcmp(type,'V2G')
    Stg_path = 'Inputs//2035_35PctRE_HV_loB_recost_1/storage_2035.csv';
    isControlledCharging = 2;
    dirString = strcat(dirStringPrefix,'_V2G',string(isControlledCharging), '_',string(2035),'_Txn1');end
if strcmp(type,'V2G50')
    Stg_path = 'Inputs//2035_35PctRE_HV_loB_recost_1/storage_203550.csv';
    isControlledCharging = 3;
    dirString = strcat(dirStringPrefix,'_V2G50',string(isControlledCharging), '_',string(2035),'_Txn1');end

dirString = strcat(dirString,'_',suffix);
disp(dirString)
dirString = strcat(dirString,reserveString,'_',string(CR0),'CR')
mkdir(strcat('Cases/',dirString));
%mkdir(strcat('Cases/',dirString,'/solver_logs'));


%% Save an archive of the code that's currently running this test case
%zip(strcat('CodeBackup_',dirString),{'*.m','Models'}); movefile(strcat('CodeBackup_',dirString,'.zip'),strcat('Cases/',dirString));
%% Move the GAMS model we will use into the working directory
txnString = 'Trans';
if isControlledCharging == 1, chgString = 'CC'; 
elseif isControlledCharging == 2, chgString = 'V2G';
elseif isControlledCharging == 3, chgString = 'V2G';
else, chgString = 'NoCC'; end

modelFile = strcat('PHORUM_',txnString,'_',chgString);
disp(modelFile);
copyfile(strcat('Models',reserveString,'/',modelFile,'.gms'),strcat('Cases/',dirString));
copyfile(strcat('Models',reserveString,'/*.opt'),strcat('Cases/',dirString));
%% Load input data
PHORUMdata = LoadPHORUMFromCSV_1(REPct,dirString,Stg_path);
[PHORUMdata, EVdata] = MakeEVData_2(PHORUMdata,isControlledCharging,2019,'2019',dirString,CR0);
% Initialize all results structures
[totalResults, prevDayResults] = InitializeResultsStruct_1(isControlledCharging);
optWindow = 48;
%% Daily GAMS loop
isTransmissionConstraints = 1
totalRuntime = 0;

for day = 1 : 1: 364

    % Status 
    tic;
    disp(['Running GAMS, day: ', num2str(day)]);

    % Create GDX files
    CreateGDX_1(day, PHORUMdata, optWindow, prevDayResults, EVdata, dirString,isTransmissionConstraints,isControlledCharging,thisDir);
    % Run GAMS
    cd(strcat(thisDir,'/Cases/',dirString));
    gams(strcat(modelFile,' logoption=2'));
    %movefile(strcat(modelFile,'.log'),strcat('solver_logs/',modelFile,'_',string(day),'.log'));
    delete('matdata.g*')
    cd('../..');
    % Parse daily results
    [totalResults, prevDayResults] = ParseOutputs_1(totalResults, PHORUMdata, day, 364+1, totalRuntime, tic, isControlledCharging,optWindow, EVdata, dirString);

end

%%
% Create all outputs as specified by settings
save(strcat('Cases/',dirString,'/Outputs_',dirString,'.mat'),'totalResults');
disp(['Saved results...']);

end
