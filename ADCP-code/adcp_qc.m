% ADCP_QC.M
% Quality Check (QC) for raw ADCP data
% Adapted from original file written by MEI Sept 2002
% FRC March 2003
% Made more generic capability FRC Nov 2005
% Developed for GUI front end by K Johst 2010

function [adcp_depth,w_depth,bin_depth,dir,err,mag,start,u,w,bin_range,E,mtime,stop,v,mtime_all,u_all,v_all,E_all]=adcp_qc(p,f,adcp_depth,subset,start,stop,rdr,w_depth)
%p=path, f=filename, adcp_depth=adcp deployment depth, subset=extract
%subset(y,n)?, start=data segment starts, stop=data segment stops, sav=save
%extracted data (y,n)?, fpathout=full directory path for output file,
%fout=output file name, sav2=save as MAT file?, sav3=save as Excel file?

%% LOAD DATA
infile = strcat(p,f);
d=load(infile);
clear p

%% GENERATE NEW VARIABLES
if rdr=='n' % If the data comes from winadcp:
    mtime_all=datenum(2000+d.SerYear,d.SerMon,d.SerDay,d.SerHour,d.SerMin,d.SerSec); % matlab format time variable for all ensembles
else
    mtime_all=d.mtime_all;
end

bin_range=round(d.RDIBin1Mid:d.RDIBinSize:(d.RDIBinSize*(max(d.SerBins)-1)+d.RDIBin1Mid)); % distance of bins from instrument
if d.config.orientation == 'up';
    bin_depth=adcp_depth-bin_range;
else
    bin_depth=adcp_depth+bin_range;
end;


% ADCP has a beam angle of 20 degrees and can't see the surface bins due to side-lobe effect
% Max Range = instrument_depth * cos(theta)
% Instrument can see 94% of the water column
% identify depth of the last 6% of the water column

% Save initial bin_depth for ice detection routine
bin_depth_all = bin_depth;

% OLD CODE (only upward looking ADCP): i=find(bin_depth>(adcp_depth*0.06));
% NEW CODE (upward or downward looking ADCP)
if d.config.orientation == 'up';
    bin_depth = adcp_depth - bin_range;
    i = find(bin_depth>(adcp_depth*0.06));
else
    %     if w_depth_ind == 2; % i.e. if seafloor is beyond ADCP range
    %         % Do not remove any bins
    %         i = find(bin_depth>0);
    %     elseif w_depth_ind == 1; % i.e. if the ADCP can see the bottom
    %         % Select bins above 6% of the total water depth
    %         bin_depth = adcp_depth + bin_range;
    %         i = find(bin_depth<(w_depth-w_depth*0.06));
    %     end
    bin_depth = adcp_depth + bin_range;
    i = find(bin_depth<(w_depth-w_depth*0.06));
end


bin_depth=bin_depth(i)';
bin_range=bin_range(i)';

u=d.SerEmmpersec(:,i)'; % magnetic east vels
v=d.SerNmmpersec(:,i)'; % magnetic north vels
w=d.SerVmmpersec(:,i)'; % vertical vels
E=d.SerEAAcnt(:,i)'; % mean echo strength (backscatter)
if rdr=='n'
    mag=d.SerMagmmpersec(:,i)'; %Current magnitude
    dir=d.SerDir10thDeg(:,i)'; %Current direction
end
err=d.SerErmmpersec(:,i)'; %Error velocity

% Save variables for ice detection routine
u_all=d.SerEmmpersec(:,:)'; % magnetic east vels
v_all=d.SerNmmpersec(:,:)'; % magnetic north vels
E_all=d.SerEAAcnt(:,:)'; % mean echo strength (backscatter)


%% QUALITY CHECKS

erri=find(err>2000 | err<-2000); % chuck out error vels > 2000mms-1 or < 2000mms-1
cori=find(d.SerCAcnt(:,i)'<64); % screen for correlations less than 64 (RDI Guideline value for S:N ratio)

u(erri)=NaN;
u(cori)=NaN;
v(erri)=NaN;
v(cori)=NaN;
w(erri)=NaN;
w(cori)=NaN;
if rdr=='n'
    mag(erri)=NaN;
    mag(cori)=NaN;
    dir(erri)=NaN;
    dir(cori)=NaN;
end
err(erri)=NaN;
err(cori)=NaN;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% retain original backscatter data%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EXTRACT A SUB_SET OF THE DATA

if subset == 'y'
    eval(['start=datenum([',start,',00,00]);'])
    
    eval(['stop=datenum([',stop,',00,00]);'])
    
    % remove the deployment and recovery periods
    ii=find(mtime_all>=start & mtime_all<=stop);
    
    u=u(:,ii);
    v=v(:,ii);
    w=w(:,ii);
    E=E(:,ii);
    if rdr=='n'
        mag=mag(:,ii);
        dir=dir(:,ii)/10; %convert to degrees
    end
    err=err(:,ii);
    mtime=mtime_all(ii);
else
    mtime=mtime_all;
    
end

if rdr=='y' % If the data comes from rdradcp dir and mag are not given variables, so they have to be calculated here.
    [m,n]=size(u);
    [dir,mag]=cart2pol(u,v);
    dir=90-rad2deg(dir);
    for o=1:m
        for q=1:n
            if dir(o,q)<0
                dir(o,q)=360+dir(o,q);
            end
        end
    end
end

%% Make scatter plots
figure(1)
clf

umin=floor((min(min(u))/100)*100);
vmin=floor((min(min(v))/100)*100);
umax= ceil((max(max(u))/100)*100);
vmax= ceil((max(max(v))/100)*100);

for j=1:length(i)
    subplot(6,5,j)
    plot(u(j,:),v(j,:),'.k')
    set(gca,'xlim',[umin umax],'ylim',[vmin vmax])
    %     eval(['text(xmax-300,ymax-200,''',num2str(bin_depth(j)),'m'')'])
    %     eval(['text(xmin+100,ymax-200,''Bin #',num2str(j),''')'])
    eval(['text(umin+0.05*(umax-umin),vmax-0.1*(vmax-vmin),''',num2str(bin_depth(j)),'m'')'])
    eval(['text(umin+0.05*(umax-umin),vmax-0.25*(vmax-vmin),''Bin #',num2str(j),''')'])
    
end

%% Make histograms
ymax = 1000;

figure(2)
clf
for j=1:length(i)
    subplot(6,5,j)
    hist(u(j,:),50);
    xlabel('U mm/sec')
    set(gca,'xlim',[umin umax],'ylim',[0 ymax])
    %     eval(['text(xmax-300,2000-500,''',num2str(bin_depth(j)),'m'')'])
    %     eval(['text(xmin+100,2000-500,''Bin #',num2str(j),''')'])
    eval(['text(umin+0.05*(umax-umin),0.75*ymax,''',num2str(bin_depth(j)),'m'')'])
    eval(['text(umin+0.05*(umax-umin),0.9*ymax,''Bin #',num2str(j),''')'])
end

figure(3)
clf
for j=1:length(i)
    subplot(6,5,j)
    hist(v(j,:),50)
    xlabel('V mm/sec')
    set(gca,'xlim',[vmin vmax],'ylim',[0 ymax])
    %     eval(['text(xmax-300,3000-500,''',num2str(bin_depth(j)),'m'')'])
    %     eval(['text(xmin+100,3000-500,''Bin #',num2str(j),''')'])
    %     eval(['text(ymax-0.6*xmax,2250,''',num2str(bin_depth(j)),'m'')'])
    %     eval(['text(ymax-0.6*xmax,2700,''Bin #',num2str(j),''')'])
    eval(['text(vmin+0.05*(vmax-vmin),0.75*ymax,''',num2str(bin_depth(j)),'m'')'])
    eval(['text(vmin+0.05*(vmax-vmin),0.9*ymax,''Bin #',num2str(j),''')'])
end

%% Data return

for j=1:length(i)
    data_ret(j)=(length(find(~isnan(err(j,:))))/length(mtime))*100;
end


figure(4)
clf

bar(i,data_ret)
xlabel('Bin Number')
ylabel('% Return')
title('Percent Good return per bin')
set(gca,'xlim',[0 length(i)+1])

%% SAVING DATA

clear ans RDI* Ser* cori data_ret erri i* x* y* instr_dep mti x fnm j subset d

% Moved to adcp_qc_2_gui for better interaction with the user.