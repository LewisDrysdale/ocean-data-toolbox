% Read in and save the ice extent for each month in shapefiles (polyline)
% for each month (1-12)

% n.b. to work with polygon data use 'shaperead' and 'mapshow'

mnth = ['01';'02';'03';'04';'05';'06';'07';'08';'09';'10';'11';'12'];
mnth2 = ['Jan';'Feb';'Mar';'Apr';'May';'Jun';'Jul';'Aug';'Sep';'Oct';'Nov';'Dec'];

% Set parameters for conversion to lat-lon from NSIDC polar stereogrpahic project 
% map coordinates (found in .prf file)
% Uses [LAT,LON]=polarstereo_inv(x,y,a,e,phi_c,lambda_0) function
   a = 6378273; % Huges ellipsoid
   e = 0.081816153; % Huges eccentricity
   phi_c = 70;
   lambda_0 = -45;


mainpath = ['/work/jeh200/data/CAO/NSIDC/monthly/shapefiles/shp_extent/'];
outpath = ['/work/jeh200/data/CAO/NSIDC/monthly/shapefiles/extent_mat/'];   


for mi = 1:12

    subdir = [mnth(mi,:),'_',mnth2(mi,:),'/'];
    filedir = dir([mainpath mnth(mi,:),'_',mnth2(mi,:),'/*polyline*.0']); % Folders that need opening in the month
    nfold = size(filedir,1);
    
    for ind = 1:nfold % Loop through all folders for the month

        infile = [mainpath subdir filedir(ind).name,'/',filedir(ind).name]; 
        ice = shaperead(infile);
        yr = filedir(ind).name(10:13);

          for ind1 = 1:size(ice,1) % Add lat-lon
               x = ice(ind1).X; 
               y = ice(ind1).Y;

              [LAT,LON]=polarstereo_inv(x,y,a,e,phi_c,lambda_0);

              ice(ind1).Lon = LON;
              ice(ind1).Lat = LAT;

          end

          outfile = ['ice_extent_',mnth(mi,:),'_',yr];
          eval(['save ',outpath outfile ,' ice'])
          
          
          clear ice

    end
    
    
end
