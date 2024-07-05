export MATLABPATH=$MATLABPATH:C:\jiahuic\Dropbox (University of Michigan)\V2G_PJM
export PATH=C:\Program Files\MATLAB\R2023b\bin:$PATH
export GRB_LICENSE_FILE=C:\Users\jiahuic\gurobi.lic
matlab -batch "try, a_server_V2G50_1; catch e, disp(getReport(e)), end, quit force"