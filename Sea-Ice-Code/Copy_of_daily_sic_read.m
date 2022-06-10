clear,close('all');
% Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS 
% Passive Microwave Data, Version 1
% This data set is generated from brightness temperature data and is 
% designed to provide a consistent time series of sea ice concentrations 
% spanning the coverage of several passive microwave instruments.
% The data are provided in the polar stereographic projection 
% at a grid cell size of 25 x 25 km.
% https://nsidc.org/data/NSIDC-0051/versions/1
% use this script to read the bin files and output as MAT files
indir = '/projectsa/PEANUTS/NSIDC/DAILY/dbin/bin';
nyears=1998:2018;    
% make NAV file
%% Load georeferencing grid:  
fid = fopen('/projectsa/PEANUTS/NSIDC/geogrid/arctic_sea_ice/psn25lons_v3.dat');
LON = fread(fid,[304 448],'long','ieee-le')/100000;
fclose(fid);
fid = fopen('/projectsa/PEANUTS/NSIDC/geogrid/arctic_sea_ice/psn25lats_v3.dat');
LAT = fread(fid,[304 448],'long','ieee-le')/100000;
fclose(fid);
%% Some grid transformations: 
% Flipping and rotating is an extra computational step that is not actually necessary, 
% but I like the grid to be oriented the same way it's oriented on the map: 
LAT = flipud(rot90(LAT)); 
LON = flipud(rot90(LON));
%% save file
savename='/projectsa/PEANUTS/NSIDC/DAILY/1998_2019/NAV_data.mat';
save(savename,'LAT','LON'); 
%% load PAR nav data 
load('/projectsa/PEANUTS/HERMES_PAR/Daily/PAR_NAV.mat');
x=LON;
y=LAT;
xq=double(longrd_par);
yq=double(latgrd_par);
%% READ DATA        
for ii=1:numel(nyears)
    d=dir([indir '/*_' num2str(nyears(ii)) '*.bin']);   
    % need to get rid of month files
    count=0;
    for jj=1:numel(d)
       if strlength(d(jj).name)>24
           count=count+1;
           dn(count).name=d(jj).name;
       end
    end   
    % make nan arrays
    ice_conc=NaN(448,304,numel(dn));    
    % for interpolation
    ice_conc_i=NaN(numel(xq),numel(dn));
    date_time=NaN(1,numel(dn));    
    for cc=1:numel(dn)
       fname=[indir '/' d(cc).name];
        %% load the data
        % open using chad greene method https://uk.mathworks.com/matlabcentral/fileexchange/56923-arctic-sea-ice
        fid=fopen(fname);
        fseek(fid,300,0);
        ci = fread(fid, [304 448]);
        fclose(fid);
        % NaN-out missing data: 
        ci(ci==255) = NaN;
        % NaN-out land: 
        ci(ci==254) = NaN; 
        % Remove coastline from ci: 
        ci(ci==253) = NaN; 
        % Convert scaled values to percent: 
        ci = ci/2.5; 
        ci = flipud(rot90(ci)); 
        ice_conc(:,:,cc)=ci;
        Y=str2num(dn(cc).name(4:7));M=str2num(dn(cc).name(8:9));D=str2num(dn(cc).name(10:11));
        date_time(cc)=datenum(Y,M,D);
        % interpolate on to PAR grid
        vq=griddata(y,x,ci,yq,xq);
        disp(['Year ' num2str(nyears(ii)) ', day ' num2str(cc) ' complete'])
        ice_conc_i(1:numel(xq),cc)=vq(:);    
    end
        daynum=1:365; daynum=daynum';
        savename=(['/projectsa/PEANUTS/NSIDC/DAILY/1998_2019/sea_ice_concentration_' num2str(nyears(ii)) '.mat']);
        save(savename,'ice_conc','ice_conc_i','daynum','date_time','-v7.3');   
        clear dn
        disp(['Year ' num2str(nyears(ii)) ' complete'])
end