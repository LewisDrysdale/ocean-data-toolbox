clearvars; close('all')
fname='X:\Marphys_Archive\Data\OSNAP\RHADCP\RHADCP_S55_data_JC238\converted\S200044A008_RHADCP_2020_avgd.mat'
load(fname)
% load(fullfile(folder,fles(3).name))

%% 
figure('Renderer', 'painters', 'Position', [20 30 800 300]);
plot(Data.Average_Time,Data.Average_Battery,'+');
ylabel ('Voltage')
title('Signature 55 Sensor Batttery')
grid on;
datetick('x','mmm-YYYY')
print(gcf,'-dpng','figures/battery');

%%
bin=1:56;
%bin=bin';bin=flipud(bin);
figure('Renderer', 'painters', 'Position', [10 20 1600 600]);
imagesc(Data.Average_Time,bin,rot90(Data.Average_VelNorth))
datetick('x','mmm-YY')
% ylabel('Cell Number')
c=colorbar; 
caxis([-0.5 0.5])
ylabel(c,'Average velcoity North (m/s)')
% yticklabels('');
cmocean('balance','pivot',0) 
grid on; axis ij;
title('RHADCP-Nortek-S55. Deployed DY120, recovered JC238')
print(gcf,'-dpng','figures/average_velN');

%%
figure('Renderer', 'painters', 'Position', [10 20 1600 600]);
imagesc(Data.Average_Time,bin,rot90(Data.Average_VelEast))
datetick('x','mmm-YY')
% ylabel('Cell Number')
axis ij
c=colorbar; 
caxis([-0.5 0.5])
ylabel(c,'Average velcoity East (m/s)')
cmocean('balance','pivot',0) 
grid on;
yticklabels('');
title('RHADCP-Nortek-S55. Deployed DY120, recovered JC238')
print(gcf,'-dpng','figures/average_velE');

%%
figure;
tiledlayout(2,2)
nexttile;
imagesc(rot90(Data.Average_AmpBeam1))
ylabel('Cells')
title('Amplitude Beam 1')
colorbar
cmocean('haline') 

nexttile;
imagesc(rot90(Data.Average_AmpBeam2))
ylabel('Cells')
title('Amplitude Beam 2')
colorbar
cmocean('haline') 

nexttile;
imagesc(rot90(Data.Average_AmpBeam3));
ylabel('Cells')
title('Amplitude Beam 3')
colorbar
cmocean('haline') 
sgtitle('RHADCP-Nortek-S55. Deployed DY120, recovered JC238')

print(gcf,'-dpng','figures/S55_2020_AMP');


%%
figure('Renderer', 'painters', 'Position', [10 20 1600 600]);
pergood=rot90(Data.Average_PercentGood);
pergood=double(pergood);
pergood(pergood<75)=NaN;
[h,c]=contourf(Data.Average_Time,bin,pergood,'LineStyle','none');
c=colorbar;
cmocean('phase')
datetick('x','dd-mmm')
% ylabel('Cell Number')
axis ij
ylabel(c,'Correlation Percent Good');
yticklabels('');
grid on
title('RHADCP-Nortek-S55. Deployed DY120, recovered JC238')
print(gcf,'-dpng','figures/average_percent_good');
