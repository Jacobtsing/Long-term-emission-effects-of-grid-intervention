addpath 'C:\GAMS\41'
addpath 'C:\jiahuic\Dropbox (University of Michigan)\V2G_PJM'
addpath 'C:\Users\jiahuic\Documents\GAMS'

for loopVar = 30:43 
    str = string(loopVar) 
    fun_Main_0('V2G_cp_1',str); 
end