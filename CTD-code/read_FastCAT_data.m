clearvars; close('all')

ddir='C:\Users\sa01ld\OneDrive - SAMS\Projects\Autonaut-EE\Non-Acoustic data\SBE_FastCat_CTD_49_01\2021';
fdrs=dir(ddir);
fdrs=fdrs(~ismember({fdrs.name},{'.','..'}));

for ii = 1:numel(fdrs)

fles=dir([fullfile(ddir,fdrs(ii).name) '\SBE_FastCat_CTD*']);
fles=fles(~ismember({fles.name},{'.','..'}));
%% salinity

cnt=1;

for jj=1:numel(fles)
    fle=fullfile(ddir,fdrs(ii).name,fles(jj).name);
    SCAT_data = read_SBE49(fle);
    x=datetime(SCAT_data.DateString,'InputFormat','yyyy/MM/dd HH:mm:ss.S');
    y=SCAT_data.Salinity;
    t=SCAT_data.Temperature;
    if cnt==1
        time=x;
        salt=y;
        temp=t;
    else
        time=[time;x];
        salt=[salt;y];
        temp=[temp;t];
    end
    cnt=cnt+1;
    clear x y t
end
%%
figure;
% plot TS with some questionable salinities
plot(salt,temp,'.'); grid on;

% User input: draw polygon of data to keep, finish by using double-click
roi = drawpolygon;
polyx = roi.Position(:,1);
polyy = roi.Position(:,2);
IN = inpolygon(salt,temp,polyx,polyy);

% Set all rejected salinities to NaN
salt(~IN==0) = nan;
temp(~IN==0) = nan;

%% speed of sound
figure
for jj=1:numel(fles)
    fle=fullfile(ddir,fdrs(ii).name,fles(jj).name);
    SCAT_data = read_SBE49(fle);
    if jj==1
        x=datetime(SCAT_data.DateString,'InputFormat','yyyy/MM/dd HH:mm:ss.S');
        y=SCAT_data.SoundVelocity;
    else
        x=[x; datetime(SCAT_data.DateString,'InputFormat','yyyy/MM/dd HH:mm:ss.S')];
        y=[y; SCAT_data.SoundVelocity];
    end

end

T = table(time,salt,temp, y, 'VariableNames', {'time','salt','temp','sound velocity'}) ;
save(['SCAT_data_qc_' fdrs(ii).name '.mat'],'SCAT_data');
end
