clear; close('all');
%% CALCULATE POLYGON
bathy='/work/lewysd/BATHY_DATA/IBCAO/data/IBCAO_V3_30arcsec_RR_Arc/IBCAO_V3_30arcsec_RR_lowres.mat';

isobath=-800;       % isobath limits

thickness=400;      % thickness in kilometers of polygon

llwidth=300; % longitudinal spacing. MUST BE ROUND DIVISOR OF 3600

[polyTFA] = fun_terrain_follow_ARCTIC(bathy,isobath,thickness,llwidth);

clear bathy llwidth isobath thickness

%% EXTRACT MEANS FOR THE REGIONS
years = 2005:1:2018;
% daily mean for  each region
daily_reg_mean=NaN(numel(years),numel(polyTFA),366);
monthly_reg_mean=NaN(numel(years),numel(polyTFA),12);

for cc=1:numel(years) 
    fname =[ '/work/lewysd/PEANUTS/NSIDC/DAILY/mat/sea_ice_concentration_' num2str(years(cc)) '.mat'];   
    load(fname)      
    [Y,M,D]= datevec(date_time);            
    month_array=NaN(14,366);
    for kk=1:numel(polyTFA)
        in = inpolygon(LON, LAT, polyTFA(kk).lon,polyTFA(kk).lat);
        for ii=1:numel(ice_conc(1,1,:))
            tmp_conc = squeeze(ice_conc(:,:,ii));        
            daily_reg_mean(cc,kk,ii)=nanmean(tmp_conc(in));
            month_array(cc,ii)=M(ii);
        end
%% get monthly means
        for jj=1:12
            id=ismember(month_array(cc,:),jj);
            monthly_reg_mean(cc,kk,jj)=nanmean(daily_reg_mean(cc,kk,id));
        end
    end
end
%% DAILY MEAN
h=figure(1);
set(gcf,'pos',[ 1          41        1280         907]);
set(gcf,'color',[1 1 1]);
annual_mean=nanmean(daily_reg_mean);
for ii=1:numel(years)
    mean_diff=squeeze(daily_reg_mean(ii,:,:))-squeeze(annual_mean);
    
    ax(ii)=subplot(4,4,ii);
    sc=imagesc(mean_diff);
    set(sc,'AlphaData',~isnan(mean_diff));
    colormap(brewermap(41,'RdBu'));
    colorbar
    caxis([-50 50]);
    yaxis_strings={'Chukchi Sea','Beaufort Sea west','Beaufort Sea east',...
    'Baffin Bay west', 'Baffin Bay east',...
    'Greenland east', 'Spitsbergen','Barents Sea north',...
    'Kara Sea west','Kara Sea east','Laptev Sea','East Siberian Sea'};
    yaxis_strings={'CS','BSw','BSe',...
    'BBw', 'BBe',...
    'Ge', 'Sp','BSn',...
    'KSw','KSe','LS','ESS'};
    yticks([1:1:numel(polyTFA)]);
    yticklabels(yaxis_strings);
    xticks([50:100:365]);
end
fname = 'Figures/daily_mean_difference';
export_fig(fname,'-png');
%% MONTHLY MEAN
h=figure(1);
set(gcf,'pos',[ 1          41        1280         907]);
set(gcf,'color',[1 1 1]);
annual_mean=nanmean(monthly_reg_mean);
for ii=1:numel(years)
    mean_diff=squeeze(monthly_reg_mean(ii,:,:))-squeeze(annual_mean);
    ax(ii)=subplot(4,4,ii);
    sc=imagesc(mean_diff);
    set(sc,'AlphaData',~isnan(mean_diff));
    colormap(brewermap(41,'RdBu'));
    colorbar
    caxis([-50 50]);
    yaxis_strings={'Chukchi Sea','Beaufort Sea west','Beaufort Sea east',...
    'Baffin Bay west', 'Baffin Bay east',...
    'Greenland east', 'Spitsbergen','Barents Sea north',...
    'Kara Sea west','Kara Sea east','Laptev Sea','East Siberian Sea'};
    yaxis_strings={'CS','BSw','BSe',...
    'BBw', 'BBe',...
    'Ge', 'Sp','BSn',...
    'KSw','KSe','LS','ESS'};
    text(0.01,1.05,num2str(years(ii)),'Units','Normalized');
    yticks([1:1:numel(polyTFA)]);
    yticklabels(yaxis_strings);
    xticks([1:1:12]);
    xaxis_strings={'Jan','Feb','March',...
    'April', 'May',...
    'Jun', 'Jul','Aug',...
    'Sep','Oct','Nov','Dec'};
    xticklabels(xaxis_strings);
    xtickangle(90);

end

fname = 'Figures/monthly_mean_difference';
export_fig(fname,'-png');