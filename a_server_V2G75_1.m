addpath 'C:\GAMS\45'
addpath 'C:\jiahuic\Dropbox (University of Michigan)\V2G_PJM'

for loopVar = 32:44; 
    str = string(loopVar) 
    fun_Main_0('V2G75',str); 
end