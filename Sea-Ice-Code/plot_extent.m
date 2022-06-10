clear, close('all');
run ../my_functions/mooring_locations
%% BATHYMETRY
bathy = load('/work/lewysd/BATHY_DATA/IBCAO/data/IBCAO_V3_30arcsec_RR_Arc/IBCAO_V3_30arcsec_RR_lowres.mat');
bathy.LATi = flipud(bathy.LATi(:,1));
bathy.LONi = bathy.LONi(1,:);
lonbthy=bathy.LONi;
latbthy=bathy.LATi;
depbthy=bathy.HHi;
clear bathy

%% plot map of area and include moorings
figure(1); % beaufort SEA
set(gcf,'pos',[35         118        1170         679]);
set(gcf,'color',[1 1 1]);
m_proj('lambert','lat',sub_box_beaufort_lat,'long',sub_box_beaufort_lon);
hold on
m_grid('xtick',12,'tickdir','out','ytick',[],'linestyle','none');
colors=cmocean('-ice',11);
% add sea ice extent
month = '09'; % September
yrs=2007:2017;
for ii=1:numel(yrs)
            fname = ['/work/lewysd/PEANUTS/NSIDC/MONTHLY/shapefiles/extent_mat/ice_extent_' month '_' num2str(yrs(ii)) '.mat'];
            if exist(fname,'file')
                load(fname);
                ix=ice.Lon>=min(sub_box_beaufort_lon) & ice.Lon<=max(sub_box_beaufort_lon);
                hold on
                h(ii)=m_plot(movmean(ice.Lon(ix),5),movmean(ice.Lat(ix),5),'-k','Color',colors(ii,:),...
                    'Linewidth',3);
            end
            legstr{ii} =[num2str(yrs(ii))];
end
hold on
m_plot(beaufort_mooring(2),beaufort_mooring(1),'sk','Markersize',14,...
    'MarkerFaceColor','y');    
hold on
m_gshhs('f','patch',[0.9 0.9 0.9]);   
% legend(h,legstr);
export_fig(figure(1),['Figures/beaufort_sea_' month '_extent.png']);
