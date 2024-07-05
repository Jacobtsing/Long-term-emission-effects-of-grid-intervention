function PHORUMdata = LoadPHORUMFromCSV_1(type,REPct,dirString,Stg_path)
warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames');
if contains( type ,'_lc')==1
    std_dir = 'C:\Users\jiahuic\Dropbox (University of Michigan)\V2G_PJM\\Inputs\\2035_35PctRE_HV_loB_recost_1\\'
    re_dir = 'C:\Users\jiahuic\Dropbox (University of Michigan)\V2G_PJM\\V2G_RE\\'
    %% Load and Clean genData

    genData = readtable(strcat(std_dir,'phorum_2035_lowcoal.csv'));

    %% gen general data
    genData.FuelPrice = table2array(genData(:,find(string(genData.Properties.VariableNames) == "FuelPrice_01"):find(string(genData.Properties.VariableNames) == "FuelPrice_12"))); % from Jan to Dec
    genData(:,find(string(genData.Properties.VariableNames) == "FuelPrice_01"):find(string(genData.Properties.VariableNames) == "FuelPrice_12")) = [];
    genData.EAF = table2array(genData(:,find(string(genData.Properties.VariableNames) == "EAF_01"):find(string(genData.Properties.VariableNames) == "EAF_12"))); % from Jan to Dec
    genData(:,find(string(genData.Properties.VariableNames) == "EAF_01"):find(string(genData.Properties.VariableNames) == "EAF_12")) = [];
    %% Startup emissions
    % genData.StartupCO2 = phorum.so2rate;
    % genData.StartupNOX = phorum.so2rate;
    % genData.StartupSO2 = phorum.so2rate;
    % genData.StartupMDNOX = phorum.so2rate;
    % genData.StartupMDSO2 = phorum.so2rate;

    PHORUMdata.genData = genData;
    PHORUMdata.loadData = readtable(strcat(std_dir,'load_2035.csv'));
    PHORUMdata.importData = readtable(strcat(std_dir,'imports_2035.csv'));
    PHORUMdata.transferLimitData = readtable(strcat(std_dir,'transferLimits_2035.csv'));

    PHORUMdata.renewablesData = readtable(strcat(re_dir,'windSolar_2035_',REPct,'PctRE.csv'));
    PHORUMdata.storageData = readtable(Stg_path);
    save(strcat('Cases\\',dirString,'\\PHORUMdata_2035'),'PHORUMdata');
    %warning('ON', 'MATLAB:table:ModifiedAndSavedVarnames')
else
    std_dir = 'C:\Users\jiahuic\Dropbox (University of Michigan)\V2G_PJM\\Inputs\\2035_35PctRE_HV_loB_recost_1\\'
    re_dir = 'C:\Users\jiahuic\Dropbox (University of Michigan)\V2G_PJM\\V2G_RE\\'
    %% Load and Clean genData

    genData = readtable(strcat(std_dir,'phorum_2035.csv'));

    %% gen general data
    genData.FuelPrice = table2array(genData(:,find(string(genData.Properties.VariableNames) == "FuelPrice_01"):find(string(genData.Properties.VariableNames) == "FuelPrice_12"))); % from Jan to Dec
    genData(:,find(string(genData.Properties.VariableNames) == "FuelPrice_01"):find(string(genData.Properties.VariableNames) == "FuelPrice_12")) = [];
    genData.EAF = table2array(genData(:,find(string(genData.Properties.VariableNames) == "EAF_01"):find(string(genData.Properties.VariableNames) == "EAF_12"))); % from Jan to Dec
    genData(:,find(string(genData.Properties.VariableNames) == "EAF_01"):find(string(genData.Properties.VariableNames) == "EAF_12")) = [];
    %% Startup emissions
    % genData.StartupCO2 = phorum.so2rate;
    % genData.StartupNOX = phorum.so2rate;
    % genData.StartupSO2 = phorum.so2rate;
    % genData.StartupMDNOX = phorum.so2rate;
    % genData.StartupMDSO2 = phorum.so2rate;

    PHORUMdata.genData = genData;
    PHORUMdata.loadData = readtable(strcat(std_dir,'load_2035.csv'));
    PHORUMdata.importData = readtable(strcat(std_dir,'imports_2035.csv'));
    PHORUMdata.transferLimitData = readtable(strcat(std_dir,'transferLimits_2035.csv'));

    PHORUMdata.renewablesData = readtable(strcat(re_dir,'windSolar_2035_',REPct,'PctRE.csv'));
    PHORUMdata.storageData = readtable(Stg_path);
    save(strcat('Cases\\',dirString,'\\PHORUMdata_2035'),'PHORUMdata');
    %warning('ON', 'MATLAB:table:ModifiedAndSavedVarnames')
end
end