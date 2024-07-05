addpath '/home/jiahuic/Downloads/gams43.4_linux_x64_64_sfx'
addpath '/home/jiahuic/V2G_PJM'

for loopVar = 43:-1:1; 
    str = string(loopVar) 
    fun_Main_0('UC_ev05',str); 
end