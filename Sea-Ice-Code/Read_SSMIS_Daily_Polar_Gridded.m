clear,close('all');
% This data set provides a Near-Real-Time (NRT) map of sea ice concentrations for both the Northern and Southern Hemispheres.
% 
% This is the most recent version of these data.
% 
% Version Summary: See less ?
% June 2016
% 
% Starting on 1 April 2016, sea ice concentration fields are computed using F18 data.
% March 2015
% 
% New smaller pole hole mask used: SSMIS Pole Hole
% 
% New spurious ice masks: NIC Valid Ice Masks
% 1999
% 
% Initial release of this data product.

% This Near-Real-Time DMSP SSMIS Daily Polar Gridded Sea Ice Concentrations (NRTSI) data set provides sea ice concentrations for both the Northern and Southern Hemispheres. The near-real-time passive microwave brightness temperature data that are used as input to this data set are acquired with the Special Sensor Microwave Imager/Sounder (SSMIS) on board the Defense Meteorological Satellite Program (DMSP) satellites. Starting with 1 April 2016, data from DMSP-F18 are used.
% 
% The SSMIS instrument is the next generation Special Sensor Microwave/Imager (SSM/I) instrument. SSMIS data are received daily from the Comprehensive Large Array-data Stewardship System (CLASS) at the National Oceanic and Atmospheric Administration (NOAA) and are gridded onto a polar stereographic grid. Investigators generate sea ice concentrations from these data using the NASA Team algorithm.
% 
% These NRTSI data are primarily meant to provide a best estimate of current ice conditions based on information and algorithms available at the time the data are acquired. Near-real-time products are not intended for operational use in assessing sea ice conditions for navigation. In addition, the NRTSI data are processed as closely as possible to the Goddard Space Flight Center (GSFC) Sea Ice Concentrations from Nimbus-7 SMMR and DMSP SSM/I-SSMIS Passive Microwave Data, however, the NRTSI data should be used with caution in extending the GSFC sea ice time series.

indir = 'DATA_01042018_31032020\0S90N\';
% make NAV file
%% Load georeferencing grid:  
fid = fopen('geogrid/arctic_sea_ice/psn25lons_v3.dat');
LON = fread(fid,[304 448],'long','ieee-le')/100000;
fclose(fid);
fid = fopen('geogrid/arctic_sea_ice/psn25lats_v3.dat');
LAT = fread(fid,[304 448],'long','ieee-le')/100000;
fclose(fid);
%% Some grid transformations: 
% Flipping and rotating is an extra computational step that is not actually necessary, 
% but I like the grid to be oriented the same way it's oriented on the map: 
LAT = flipud(rot90(LAT)); 
LON = flipud(rot90(LON));
%% save file
savename='NAV_data.mat';
save(savename,'LAT','LON'); 
%% READ DATA        

% folders containing bin files
currentpath=pwd; d=dir([currentpath filesep indir]);

% remove the ghost folders
d=d(3:end);

% make nan matrix size lat/lon by date
ice_conc=NaN(448,304,numel(d));   
dd=NaN(1,numel(d));
% start loop
for ii=1:numel(d)
    % get .bin file
    files=dir([currentpath filesep indir d(ii).name '/*.bin']);
    % fullfile 
    fname=[currentpath filesep indir d(ii).name filesep files.name];
    % open
    fid=fopen(fname);
    % read
    fseek(fid,300,0);
    ci = fread(fid, [304 448]);
    % close
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
    ice_conc(:,:,ii)=ci;   
    Y=str2num(files.name(4:7)); 
    M=str2num(files.name(8:9)); 
    D=str2num(files.name(10:11));
    dd(ii)=datenum([Y,M,D]);
end

%% SAVE?
savename=('blahblahblah.mat');
save(savename,'ice_conc','dd');   
