clear; close('all');
% dir info
fdir = '/work/lewysd/PEANUTS/NSIDC/MONTHLY/shapefiles/extent_mat';
d=dir(fdir);
% load bathy data (taken from JEH script) and convert lat lon to array
bathy = load('/work/lewysd/BATHY_DATA/IBCAO/data/IBCAO_V3_30arcsec_RR_Arc/IBCAO_V3_30arcsec_RR_lowres.mat');
bathy.LATi = flipud(bathy.LATi(:,1));
bathy.LONi = bathy.LONi(1,:);
% data is from 1979-2018
% data has been converted using read_monthly_median_extent.m (from JEH
% folder)
nyears = 1979:1:2018;
nmonths= 1:12;
for cc=1:12 
    clf
    n=0;
    month = num2str(cc,'%02.f');
    outfile = ['SIE_1979_2018_' num2str(cc) '.gif'];
    % call stereo projection from m_map
    % Note that coastline is drawn OVER the grid because of the order in which
    % the two routines are called
    h=figure(1);
    set(gcf,'pos',[ 1          41        1280         907]);
    set(gcf,'color',[1 1 1]);
    m_proj('stereographic','lat',90,'long',30,'radius',25);
    [c,H] = m_contourf(bathy.LONi,bathy.LATi,bathy.HHi,[0:-100:-5000],'Linecolor','none');
    cmocean('-deep',64); 
    colorbar;
    hold on
    m_gshhs('l','patch',[0.9 0.9 0.9]);    
    m_grid('xtick',12,'tickdir','out','ytick',[],'linestyle','none');    
    hold on
    h3=text(-0.3,1.04,'Monthly Sea Ice Extent','Units','normalized',...
        'FontSize',36);    
    for ii=1:numel(nyears)
            n=n+1;
            fname = ['/work/lewysd/PEANUTS/NSIDC/MONTHLY/shapefiles/extent_mat/ice_extent_' month '_' num2str(nyears(ii)) '.mat'];
            if exist(fname,'file')
                load(fname);
                hold on
                h1=m_plot(ice.Lon,ice.Lat,'-k','Linewidth',2);
                hold on
                monthtime = datenum([nyears(ii),cc,1]);
                h2=text(-0.3,0.01,[datestr(monthtime,'mmmm') ' ' num2str(nyears(ii))],'Units','normalized',...
                    'FontSize',36);
                drawnow    ;
                % Capture the plot as an image 
                frame = getframe(h); 
                im = frame2im(frame); 
                [imind,cm] = rgb2ind(im,256); 
                % Write to the GIF File 
                if n == 1 
                  imwrite(imind,cm,outfile,'gif', 'Loopcount',inf); 
                else 
                  imwrite(imind,cm,outfile,'gif','WriteMode','append'); 
                end
                  delete(h1); delete(h2);            
            end
    end
end
    