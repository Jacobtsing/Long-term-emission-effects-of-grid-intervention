addpath 'C:\GAMS\45'
addpath 'C:\jiahuic\Dropbox (University of Michigan)\V2G_PJM'
addpath 'C:\Users\jiahuic\Documents\GAMS'
for loopVar = 18:44
    str = string(loopVar) 
    fun_Main_0('V2G50_cp',str); 
end