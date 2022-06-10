clear; close('all');
run ../my_functions/mooring_locations.m
years = 2015:1:2018;
n=0;
for cc=1:numel(years)
% file in
fname =[ '/work/lewysd/PEANUTS/NSIDC/DAILY/mat/sea_ice_concentration_' num2str(years(cc)) '.mat'];
load(fname)
if cc==1
    dd=date_time;
else
    dd=[dd date_time];
end
    for ii=1:numel(ice_conc(1,1,:))        
        n=n+1;
        tmp_conc = squeeze(ice_conc(:,:,ii));
        lnid=LON>=min(barents_box_lon) & LON<=max(barents_box_lon);
        ltid=LAT>=min(barents_box_lat) & LAT<=max(barents_box_lat);
        idx=lnid&ltid;
        conc_array(1:20,n)=tmp_conc(idx);
    end
end

figure(1);
set(gcf,'pos',[35         471        1140         326]);
set(gcf,'color',[1 1 1]);
[c,h]=contourf(dd,1:20,conc_array,20,'Linecolor','none');
cb=colorbar;
ylabel(cb,'Sea Ice Concentration %');
cmocean('ice',10);
caxis([0 100])
datetick('x','mmm','keeplimits');
xlabel('2015                                     2016                                    2017                                    2018                                ')
axis ij
yticklabels('');
export_fig(figure(1),'Figures/barents_ice_concentration.png');


n=0;
for cc=1:numel(years)
% file in
fname =[ '/work/lewysd/PEANUTS/NSIDC/DAILY/mat/sea_ice_concentration_' num2str(years(cc)) '.mat'];
load(fname)
if cc==1
    dd=date_time;
else
    dd=[dd date_time];
end
    for ii=1:numel(ice_conc(1,1,:))        
        n=n+1;
        tmp_conc = squeeze(ice_conc(:,:,ii));
        lnid=LON>=min(beaufort_box_lon) & LON<=max(beaufort_box_lon);
        ltid=LAT>=min(beaufort_box_lat) & LAT<=max(beaufort_box_lat);
        idx=lnid&ltid;
        conc_array(1:37,n)=tmp_conc(idx);
    end
end
conc_array(any(isnan(conc_array), 2), :) = [];

figure(2)
set(gcf,'pos',[35         471        1140         326]);
set(gcf,'color',[1 1 1]);
[c,h]=contourf(dd,1:35,conc_array,20,'Linecolor','none');
cb=colorbar;
ylabel(cb,'Sea Ice Concentration %');
cmocean('ice',10);
caxis([0 100])
datetick('x','mmm','keeplimits');
axis ij
yticklabels('');
xlabel('2015                                     2016                                    2017                                    2018                                ')
export_fig(figure(2),'Figures/beaufort_ice_concentration.png');
