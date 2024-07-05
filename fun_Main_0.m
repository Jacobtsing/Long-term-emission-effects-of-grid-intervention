function fun_Main_0(type,suffix)
% This is the primary PHORUM Matlab function.  The function makes 
% several sub-function calls, and is responsible for calling GAMS. 
% The function loads data from the database file and settings file.
cd('C:\Users\jiahuic\Dropbox (University of Michigan)\V2G_PJM');
CR0= 1;
year = 2035;
REPct = suffix;
thisDir = 'C:\Users\jiahuic\Dropbox (University of Michigan)\V2G_PJM';
reserveString = '_reserve3'; 
% Load settings

% Set up a working directory for this test case
dirStringPrefix = '';
if strlength(type)==0 dirStringPrefix ='NoEV'; end
if contains( type ,'CC')==1
    isControlledCharging = 1;
    if contains( type ,'HB')==0
        Stg_path = 'Inputs\2035_30PctRE_loB_recost_1\storage_2035.csv';
    elseif contains( type ,'HB')==1
        Stg_path = 'Inputs\2035_22PctRE\storage_2035.csv';
    end
    dirString = strcat(dirStringPrefix,type,string(isControlledCharging));
end
if contains( type ,'UC')==1
    isControlledCharging = 0;
    if contains( type ,'HB')==0
        Stg_path = 'Inputs\2035_30PctRE_loB_recost_1\storage_2035.csv';
    elseif contains( type ,'HB')==1
        Stg_path = 'Inputs\2035_22PctRE\storage_2035.csv';
    end
    dirString = strcat(dirStringPrefix,type,string(isControlledCharging));
end
if (contains( type ,'V2G')==1 & contains( type ,'V2G50')==0)==1
    isControlledCharging = 2;
    if contains( type ,'HB')==0
        Stg_path = 'Inputs\\2035_35PctRE_HV_loB_recost_1\\storage_2035.csv';
    elseif contains( type ,'HB')==1
        Stg_path = 'Inputs\\2035_22PctRE\\storage_2035_v2g.csv';
    end
    dirString = strcat(dirStringPrefix,type,string(isControlledCharging));
end
if contains( type ,'V2Gev05')==1
    isControlledCharging = 2;
    if contains( type ,'HB')==0
        Stg_path = 'Inputs\\2035_35PctRE_HV_loB_recost_1\\storage_203505.csv';
    elseif contains( type ,'HB')==1
        Stg_path = 'Inputs\\2035_35PctRE_HV_loB_recost_1\\storage_203550HB.csv';
    end
    dirString = strcat(dirStringPrefix,type,string(isControlledCharging));
end
if contains( type ,'V2G20')==1
    isControlledCharging = 2;
    Stg_path = 'Inputs\\2035_35PctRE_HV_loB_recost_1\\storage_203520.csv';
    dirString = strcat(dirStringPrefix,type,string(isControlledCharging));
end

dirString = strcat(dirString,'_',suffix);
disp(dirString)
dirString = strcat(dirString,reserveString,'_',string(CR0),'CR')
mkdir(strcat('Cases\\',dirString));
%mkdir(strcat('Cases/',dirString,'/solver_logs'));


%% Save an archive of the code that's currently running this test case
%zip(strcat('CodeBackup_',dirString),{'*.m','Models'}); movefile(strcat('CodeBackup_',dirString,'.zip'),strcat('Cases/',dirString));
%% Move the GAMS model we will use into the working directory
txnString = 'Trans';
if isControlledCharging == 1, chgString = 'CC'; 
elseif isControlledCharging == 2, chgString = 'V2G';
elseif isControlledCharging == 3, chgString = 'V2G';
elseif isControlledCharging == 0,  chgString = 'NoCC_loadshed';
else, chgString = 'NoEV';end
if contains( type ,'ht')==1
    modelFile = strcat('PHORUM_',txnString,'_',chgString,'_ht');
elseif contains(type,'ht')==0
    modelFile = strcat('PHORUM_',txnString,'_',chgString);end
disp(modelFile);
copyfile(strcat('Models',reserveString,'\\',modelFile,'.gms'),strcat('Cases\\',dirString));
copyfile(strcat('Models',reserveString,'\\*.opt'),strcat('Cases\\',dirString));
%% Load input data
PHORUMdata = LoadPHORUMFromCSV_1(type,REPct,dirString,Stg_path);
[PHORUMdata, EVdata] = MakeEVData_2(type,PHORUMdata,isControlledCharging,2019,'2019',dirString,CR0);
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
    CreateGDX_1(type,day, PHORUMdata, optWindow, prevDayResults, EVdata, dirString,isTransmissionConstraints,isControlledCharging,thisDir);
    % Run GAMS
    cd(strcat(thisDir,'\Cases\',dirString));
    gams(strcat(modelFile,' logoption=2'));
    %movefile(strcat(modelFile,'.log'),strcat('solver_logs/',modelFile,'_',string(day),'.log'));
    delete('matdata.g*')
    cd('..\..');
    % Parse daily results
    if isControlledCharging ~= 0
    	[totalResults, prevDayResults] = ParseOutputs_1(totalResults, PHORUMdata, day, 364+1, totalRuntime, tic, isControlledCharging,optWindow, EVdata, dirString);
    else
	    [totalResults, prevDayResults] = ParseOutputs_2(totalResults, PHORUMdata, day, 364+1, totalRuntime, tic, isControlledCharging,optWindow, EVdata, dirString);
    end
end

%%
% Create all outputs as specified by settings
save(strcat('Cases\\',dirString,'\\Outputs_',dirString,'.mat'),'totalResults');
disp(['Saved results...']);

end
