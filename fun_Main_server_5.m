addpath '/home/jiahuic/Downloads/gams43.4_linux_x64_64_sfx'
addpath '/home/jiahuic/V2G_PJM'
for loopVar = 18:44; 
    
    str = string(loopVar) 
    fun_Main_2('UC',str); 

end