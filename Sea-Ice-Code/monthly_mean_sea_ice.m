%% Plot mean monthly sea ice concentration 
close all
clear all

% Load monthly concentration data
    load /work/jeh200/data/CAO/NSIDC/monthly/geotiff/mat/monthly_ice_concentration.mat
    
    p1 = find(date_time == datenum('01-Mar-1990'));
    datain1 = squeeze(ice_conc(:,:,p1));
    
    p2 = find(date_time == datenum('01-Sep-1990'));
    datain2 = squeeze(ice_conc(:,:,p2));
    
%load matlab coast for coarse res. pan arctic map
    land = shaperead('landareas', 'UseGeoCoords', true);
% bathy
    bathy = load('/work/jeh200/data/bathymetry/IBCAO/data/IBCAO_V3_30arcsec_RR_Arc/IBCAO_V3_30arcsec_RR_lowres.mat');
    bathy.LATi = flipud(bathy.LATi(:,1));
    bathy.LONi = bathy.LONi(1,:);

% March 1st 1990
    setfig([0 0 15 15],'portrait')
    axesm eqdazim
    framem; gridm; mlabel; plabel

    setm(gca,'Origin',[90 0 0],'FLatLimit',[-inf 90],...
    'MLabelLocation',-180:45:180,'MLineLocation',45,...
    'MLineLimit',[65 90],'MLabelParallel',10,...
    'PLabelMeridian',180,'PLabelLocation',65:5:85,'MapLatLimit',[65 90],'FontSize',8)

    pcolorm(LAT,LON,datain1)
    cb=colorbar; caxis([0 100]);
    set(gca,'FontSize',8)
    
    
   [c,h] = contourm(bathy.LATi,bathy.LONi,bathy.HHi,[-500 -500],'k');
    geoshow(gca, land, 'FaceColor', [0.83 0.82 0.78]) % For internal matlab file

    set(gca,'XColor','none')
    set(gca,'YColor','none')   
    
    
   eval(['print -djpeg -r500 /work/jeh200/arctic/figures/sea_ice/arctic_sea_ice_01Mar1990.jpg'])
   
   
   
 % September 1st 1990
    setfig([0 0 15 15],'portrait')
    axesm eqdazim
    framem; gridm; mlabel; plabel

    setm(gca,'Origin',[90 0 0],'FLatLimit',[-inf 90],...
    'MLabelLocation',-180:45:180,'MLineLocation',45,...
    'MLineLimit',[65 90],'MLabelParallel',10,...
    'PLabelMeridian',180,'PLabelLocation',65:5:85,'MapLatLimit',[65 90],'FontSize',8)

    pcolorm(LAT,LON,datain2)
    cb=colorbar; caxis([0 100]);
    set(gca,'FontSize',8)
    
    
   [c,h] = contourm(bathy.LATi,bathy.LONi,bathy.HHi,[-500 -500],'k');
    geoshow(gca, land, 'FaceColor', [0.83 0.82 0.78]) % For internal matlab file

    set(gca,'XColor','none')
    set(gca,'YColor','none')   
    
    
   eval(['print -djpeg -r500 /work/jeh200/arctic/figures/sea_ice/arctic_sea_ice_01Sep1990.jpg'])  
    
    
  % 1st Sep 1979 
    p3 = find(date_time == datenum('01-Sep-1979'));
    datain3 = squeeze(ice_conc(:,:,p3));
    
    setfig([0 0 15 15],'portrait')
    axesm eqdazim
    framem; gridm; mlabel; plabel

    setm(gca,'Origin',[90 0 0],'FLatLimit',[-inf 90],...
    'MLabelLocation',-180:45:180,'MLineLocation',45,...
    'MLineLimit',[65 90],'MLabelParallel',10,...
    'PLabelMeridian',180,'PLabelLocation',65:5:85,'MapLatLimit',[65 90],'FontSize',8)

    pcolorm(LAT,LON,datain3)
    cb=colorbar; caxis([0 100]);
    set(gca,'FontSize',8)
    
    
   [c,h] = contourm(bathy.LATi,bathy.LONi,bathy.HHi,[-500 -500],'k');
    geoshow(gca, land, 'FaceColor', [0.83 0.82 0.78]) % For internal matlab file

    set(gca,'XColor','none')
    set(gca,'YColor','none')   
    
    
   eval(['print -djpeg -r500 /work/jeh200/arctic/figures/sea_ice/arctic_sea_ice_01Sep1989.jpg'])   
    
    
  % 1st Sep 2012  
    p4 = find(date_time == datenum('01-Sep-2012'));
    datain4 = squeeze(ice_conc(:,:,p4));
    
    setfig([0 0 15 15],'portrait')
    axesm eqdazim
    framem; gridm; mlabel; plabel

    setm(gca,'Origin',[90 0 0],'FLatLimit',[-inf 90],...
    'MLabelLocation',-180:45:180,'MLineLocation',45,...
    'MLineLimit',[65 90],'MLabelParallel',10,...
    'PLabelMeridian',180,'PLabelLocation',65:5:85,'MapLatLimit',[65 90],'FontSize',8)

    pcolorm(LAT,LON,datain4)
    cb=colorbar; caxis([0 100]);
    set(gca,'FontSize',8)
    
    
   [c,h] = contourm(bathy.LATi,bathy.LONi,bathy.HHi,[-500 -500],'k');
    geoshow(gca, land, 'FaceColor', [0.83 0.82 0.78]) % For internal matlab file

    set(gca,'XColor','none')
    set(gca,'YColor','none')   
    
    
   eval(['print -djpeg -r500 /work/jeh200/arctic/figures/sea_ice/arctic_sea_ice_01Sep2012.jpg'])  
   
    % 1st July 2017  
    p5 = find(date_time == datenum('01-Jul-2017'));
    datain5 = squeeze(ice_conc(:,:,p5));
    
    setfig([0 0 15 15],'portrait')
    axesm eqdazim
    framem; gridm; mlabel; plabel

    setm(gca,'Origin',[90 0 0],'FLatLimit',[-inf 90],...
    'MLabelLocation',-180:45:180,'MLineLocation',45,...
    'MLineLimit',[65 90],'MLabelParallel',10,...
    'PLabelMeridian',180,'PLabelLocation',65:5:85,'MapLatLimit',[65 90],'FontSize',8)

    pcolorm(LAT,LON,datain5)
    cb=colorbar; caxis([0 100]);
    set(gca,'FontSize',8)
    
    
   [c,h] = contourm(bathy.LATi,bathy.LONi,bathy.HHi,[-500 -500],'k');
    geoshow(gca, land, 'FaceColor', [0.83 0.82 0.78]) % For internal matlab file
    
    % Median July ice edge
    % Load median ice edge 1981-2010
   load('/work/jeh200/data/CAO/NSIDC/monthly/shapefiles/median_mat/median_monthly_ice_extent.mat');
   a=geoshow(ice_median_07,'Color','r','LineWidth',2);

    set(gca,'XColor','none')
    set(gca,'YColor','none')   
    
    
   eval(['print -djpeg -r500 /work/jeh200/arctic/figures/sea_ice/arctic_sea_ice_01Jul17.jpg'])
    
 