addpath 'C:\GAMS\42'
addpath 'C:\Users\jiahuic\Dropbox (University of Michigan)\V2G_PJM'
addpath 'C:\Users\jiahuic\Dropbox (University of Michigan)\V2G_PJM'

for loopVar = 20:40
    str = string(loopVar) 
    fun_Main_0('UC_ev05',str); 
end