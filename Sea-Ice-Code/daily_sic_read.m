clear,close('all');
% Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS 
% Passive Microwave Data, Version 1
% This data set is generated from brightness temperature data and is 
% designed to provide a consistent time series of sea ice concentrations 
% spanning the coverage of several passive microwave instruments.
% The data are provided in the polar stereographic projection 
% at a grid cell size of 25 x 25 km.
% https://nsidc.org/data/NSIDC-0051/versions/1
indir = '/projectsa/PEANUTS/NSIDC/DAILY/2005_2015/';
nyears=2005:2014;
for ii=1:numel(nyears)
    d=dir([indir num2str(nyears(ii)) '/*.bin']);
    ice_conc=NaN(448,304,numel(d));
    date_time=NaN(1,numel(d));
    for cc=1:numel(d)
       fname=[indir num2str(nyears(ii)) '/' d(cc).name];
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
        Y=str2num(d(cc).name(4:7));M=str2num(d(cc).name(8:9));D=str2num(d(cc).name(10:11));
        date_time(cc)=datenum(Y,M,D);
    end
        %% Load georeferencing grid: 
        % Thanks to Laura Davies of UTAS for suggesting this section: 
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
        daynum=1:365; daynum=daynum';
        savename=(['/projectsa/PEANUTS/NSIDC/DAILY/mat/sea_ice_concentration_' num2str(nyears(ii)) '.mat']);
        save(savename,'ice_conc','LAT','LON','daynum','date_time');
end