clearvars; close('all')
fname='X:\Marphys_Archive\Data\OSNAP\RHADCP\RHADCP_S55_data_JC238\converted\S200044A008_RHADCP_2020_avgd.mat'
load(fname)

%%
bin=1:56;

%%

figure('Renderer', 'painters', 'Position', [10 20 1600 600]);
imagesc(Data.Average_Time,bin,rot90(Data.Average_CorBeam1))
datetick('x','mmm-YY')
% ylabel('Cell Number')
axis ij
c=colorbar; 
ylabel(c,'Average vcorrelation beam 1')
cmocean('solar') 
grid on;
set(gca,'FontSize',16)
title('RHADCP-Nortek-S55. Deployed DY120, recovered JC238')
print(gcf,'-dpng',['../figures/corrbeam1']);
