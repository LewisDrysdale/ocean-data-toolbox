%% NORTEK S55 QC after data retrival and conversion 
clearvars; close('all')
fname='X:\Marphys_Archive\Data\OSNAP\RHADCP\RHADCP_S55_data_JC238\converted\S200044A008_RHADCP_2020.mat';
fname='X:\Marphys_Archive\Data\OSNAP\RHADCP\RHADCP_S55_data_JC238\converted\S200044A008_RHADCP_2020_avgd.mat'
load(fname)
% Data are ensemble averages over 1 minute of data collection. The
% avergages are spaced approximatley 6 seconds apart, so 10 averages each
% sample period
%% QC poor correlation data
% replace data with poor correlation (i.e. <50% ) with nan
% beam 1
id1 = Data.Average_CorBeam1>=50; 
id2 = Data.Average_CorBeam2>=50; 
id3 = Data.Average_CorBeam3>=50; 

Data.Average_CorBeam1=Data.Average_CorBeam1(id1);
Data.Average_CorBeam1=Data.Average_CorBeam2(id1);
Data.Average_CorBeam1=Data.Average_CorBeam3(id1);

%% BIN DEPTHS
% Config: 56bins @ 20m depth
nbin=1:56; binz=20;
water_depth=1083; %[m];
offset=15 ; %[m] From mooring diagram in DY120 CR this is height of transducer above seabed

wk1=nbin*binz;
depth=(water_depth-offset)-wk1;


p=mean(Data.Average_Pressure(100:end-20))
lat = 57;
z = gsw_z_from_p(p,lat)

