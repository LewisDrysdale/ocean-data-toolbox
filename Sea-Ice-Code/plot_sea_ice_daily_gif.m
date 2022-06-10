clear; close('all');
years = 2015:1:2018;
% dir info
h=figure(1);
set(gcf,'pos',[ 1          41        1280         907]);
set(gcf,'color',[1 1 1]);
m_proj('stereographic','lat',90,'long',30,'radius',25);
hold on
m_gshhs('l','patch',[0.9 0.9 0.9]);    
m_grid('xtick',12,'tickdir','out','ytick',[],'linestyle','none');  
cmocean('ice',20); 
v=VideoWriter('sea_ice_daily3.avi');
v.FrameRate = 20;  % Default 30
open(v)
ax=gcf()
for cc=1:numel(years)
% file in
fname =[ '/work/lewysd/PEANUTS/NSIDC/DAILY/mat/sea_ice_concentration_' num2str(years(cc)) '.mat'];
load(fname)
    for ii=1:numel(ice_conc(1,1,:))

        tmp_conc = squeeze(ice_conc(:,:,ii));
        [c,H] = m_contourf(LON,LAT,tmp_conc,[0:1:100],'Linecolor','none');
        hc = colorbar('Position',[0.85 0.1 0.03 0.8]); caxis([0 100]);
        ylabel(hc,'% Sea Ice Concentration')
        hold on
        h2=text(-0.3,0.01,[ num2str(years(cc)) ', day ' num2str(ii)],'Units','normalized',...
            'FontSize',36);
        hold on 
        h3=m_plot([31.3428 18.4133],[81.3025 81.0339],'sr','Markersize',8,...
            'MarkerFaceColor','y');
        set(gca,'FontSize',16);

        drawnow()  

        writeVideo(v,getframe(ax))

        hnd=[H,hc,h2,h3];
        delete(hnd);
    end
    clear ice_conc
end
close(gcf)
close(v)

 