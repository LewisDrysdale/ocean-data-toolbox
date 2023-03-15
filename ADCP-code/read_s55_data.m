clear all; close('all')

% averaged data file
fname='X:\Marphys_Archive\Data\OSNAP\RHADCP\RHADCP_S55_data_JC238\converted\S200044A008_RHADCP_2020_avgd.mat'

load(fname)

x=Data.Average_Time;
y=1:56;
z=rot90(Data.Average_VelEast);

figure;
[c,f]=contourf(x,y,z,'LineStyle','none')