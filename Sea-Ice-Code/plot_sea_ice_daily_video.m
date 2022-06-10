clear; close('all');
run ../my_functions/mooring_locations.m

years = 2015:1:2018;
% dir info
h=figure(1);
set(gcf,'pos',[ 1          41        1280         907]);
set(gcf,'color',[1 1 1]);
m_proj('stereographic','lat',90,'long',30,'radius',25);
hold on
m_gshhs('l','patch',[0.9 0.9 0.9]);    
m_grid('xtick',12,'tickdir','out','ytick',[],'linestyle','none');  
cmocean('-ice',64); 
v=VideoWriter('sea_ice_vid_daily.avi');
v.FrameRate = 20;  % Default 30
open(v)
ax=gcf()
for cc=1:numel(years)
% file in
fname =[ '/work/lewysd/PEANUTS/NSIDC/DAILY/mat/sea_ice_concentration_' num2str(years(cc)) '.mat'];
load(fname)
    for ii=1:365

        tmp_conc = squeeze(ice_conc(:,:,ii));
        [c,H] = m_contourf(LON,LAT,tmp_conc,[0:1:100],'Linecolor','none');
        hc = colorbar('Position',[0.85 0.1 0.03 0.8]);
        hold on
        h2=text(-0.3,0.01,[ num2str(years(cc)) ', day ' num2str(ii)],'Units','normalized',...
            'FontSize',36);
        hold on 
        h3=m_plot(barents_mooring(2),barents_mooring(1),'^r','Markersize',12,...
        'MarkerFaceColor','y','Markeredgecolor','k','Linewidth',2);
        hold on
        h4=m_plot(beaufort_mooring(2),beaufort_mooring(1),'^r','Markersize',12,...
        'MarkerFaceColor','y','Markeredgecolor','k','Linewidth',2);
        set(gca,'FontSize',16);

        drawnow()  

        writeVideo(v,getframe(ax))

        hnd=[hc,h2,h3,h4];
        delete(hnd);
    end
end
close(gcf)
close(v)

 