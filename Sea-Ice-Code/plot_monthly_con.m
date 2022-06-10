clear; close('all');
run ../my_functions/mooring_locations.m
load('MONTHLY/geotiff/mat/monthly_ice_concentration.mat');

% get index of lat/lon around mooring
lnid=LON>=min(beaufort_box_lon) & LON<=max(beaufort_box_lon);
ltid=LAT>=min(beaufort_box_lat) & LAT<=max(beaufort_box_lat);
idx=lnid&ltid;

mn_sic=NaN(numel(date_time),1);
ddx=NaN(numel(date_time),1);
[Y,M,D]=datevec(date_time);
yrs=unique(Y);
mn_sic=NaN(numel(yrs),1);
ddx=NaN(numel(yrs),1);
for ii=1:numel(yrs)
    idk=Y==yrs(ii);
    dta=ice_conc(:,:,idk);
    if sum(idk)>0
        for cc=1:sum(idk)
            tmpconc=squeeze(dta(:,:,cc));
            ice_array(cc)=nanmean(tmpconc(idx));
        end
            mn_sic(ii)=nanmean(ice_array);
            clear ice_array
            ddx(ii)=yrs(ii);
    end
end

% plot annual
figure(1);
set(gcf,'pos',[32    48   594   885]);
set(gcf,'color',[1 1 1]);
subplot(3,1,1)
h(1)=bar(yrs,mn_sic);
xlim([yrs(1) yrs(end)]);
ylabel('%');
set(gca,'FontSize',14)

% fit trend
yrs=yrs.';
b = polyfit(yrs,mn_sic, 1);
fr = polyval(b, yrs);
hold on
plot(yrs, fr, '-r', 'LineWidth',3)
hold on
plot(yrs, fr, '--k', 'LineWidth',2)

%% calculate winter mean concentration
% winter defined asm DJFM - Onarheim et al 2015
mn_sic=NaN(numel(date_time),1);
ddx=NaN(numel(date_time),1);
[Y,M,D]=datevec(date_time);
yrs=unique(Y);
mn_sic=NaN(numel(yrs),1);
ddx=NaN(numel(yrs),1);
for ii=1:numel(yrs)
    idk=Y==yrs(ii) & ismember(M,[12,1,2,3]);
    dta=ice_conc(:,:,idk);
    if sum(idk)>0
        for cc=1:sum(idk)
            tmpconc=squeeze(dta(:,:,cc));
            ice_array(cc)=nanmean(tmpconc(idx));
        end
            mn_sic(ii)=nanmean(ice_array);
            clear ice_array
            ddx(ii)=yrs(ii);
    end
end
% plot winter
subplot(3,1,2)
h(1)=bar(yrs,mn_sic);
xlim([yrs(1) yrs(end)]);
% xlabel([yrs(1):1:yrs(end)]);
ylabel('%');
% datetick('x','yyyy','keeplimits')
set(gca,'FontSize',14)
% fit trend
yrs=yrs.';
b = polyfit(yrs,mn_sic, 1);
fr = polyval(b, yrs);
hold on
plot(yrs, fr, '-r', 'LineWidth',3)
hold on
plot(yrs, fr, '--k', 'LineWidth',2)

%% calculate summer mean concentration
% summer defined asm JJAS - Onarheim et al 2015
mn_sic=NaN(numel(date_time),1);
ddx=NaN(numel(date_time),1);
[Y,M,D]=datevec(date_time);
yrs=unique(Y);
mn_sic=NaN(numel(yrs),1);
ddx=NaN(numel(yrs),1);
for ii=1:numel(yrs)
    idk=Y==yrs(ii) & ismember(M,[6,7,8,9]);
    dta=ice_conc(:,:,idk);
    if sum(idk)>0
        for cc=1:sum(idk)
            tmpconc=squeeze(dta(:,:,cc));
            ice_array(cc)=nanmean(tmpconc(idx));
        end
            mn_sic(ii)=nanmean(ice_array);
            clear ice_array
            ddx(ii)=yrs(ii);
    end
end

yrs=yrs.';
yrs(isnan(mn_sic))=[];
mn_sic(isnan(mn_sic))=[];
% plot summer
subplot(3,1,3)
h(1)=bar(yrs,mn_sic);
xlim([yrs(1) yrs(end)]);
% xlabel([yrs(1):1:yrs(end)]);
ylabel('%');
% datetick('x','yyyy','keeplimits')
set(gca,'FontSize',14)
% fit trend
b = polyfit(yrs,mn_sic, 1);
fr = polyval(b, yrs);
hold on
plot(yrs, fr, '-r', 'LineWidth',3)
hold on
plot(yrs, fr, '--k', 'LineWidth',2)

export_fig(figure(1),'Figures/month_sic_beaufort.png');
