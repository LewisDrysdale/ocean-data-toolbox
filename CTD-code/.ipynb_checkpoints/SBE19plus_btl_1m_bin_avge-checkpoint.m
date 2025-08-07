%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read CTD data from SBE19plus and SBE19plus on eco55 and print .CSV 
% 
% March, 2021 -Lewis Drysdale
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  User needs to change the text read function (line 57ish) to matchy the
%  PAS file headers - open a .CNV file and scroll odown to see.
%
%     CHANGE HERE ACCORDING TO PSA file, FOR EXAMPLE:
%     # name 0 = scan: Scan Count
%     # name 1 = timeJ: Julian Days
%     # name 2 = prdM: Pressure, Strain Gauge [db]
%     # name 3 = depSM: Depth [salt water, m], lat = 55.00
%     # name 4 = tv290C: Temperature [ITS-90, deg C]
%     # name 5 = c0S/m: Conductivity [S/m]
%     # name 6 = oxsatMg/L: Oxygen Saturation, Weiss [mg/l]
%     # name 7 = flECO-AFL: Fluorescence, WET Labs ECO-AFL/FL [mg/m^3]
%     # name 8 = sal00: Salinity, Practical [PSU]
%     # name 9 = density00: Density [density, kg/m^3]
%     # name 10 = flag:  0.000e+00
% 
% 
%     [scan,Jday,pres,depth,temp,cond,ox_mg_l,fluo,salt,dens,flag]= ...
%         textread(filename,'%f%f%f%f%f%f%f%f%f%f%f', 'endofline',...
%         '\r\n','headerlines',lineCounter);
%     
%     make into table
%     data = table(scan,Jday,dateform,pres,depth,temp,cond,ox_mg_l,salt,dens,fluo,flag);
% 
%     Make sure these are correct:
%     data.Properties.VariableNames{'fluo'} = 'Fluorescence, WET Labs ECO-AFL/FL [mg/m^3]';
%     data.Properties.VariableNames{'dateform'} = 'Date Time dd-mmm-yyyy HH:MM:SS';
%     data.Properties.VariableNames{'Jday'} = 'Julian Days';
%     data.Properties.VariableNames{'pres'} = 'Pressure [db]';
%     data.Properties.VariableNames{'depth'} = 'Depth [salt water, m]';
%     data.Properties.VariableNames{'temp'} = 'Temperature [ITS-90, deg C]';
%     data.Properties.VariableNames{'cond'} = 'Conductivity [S/m]';
%     data.Properties.VariableNames{'salt'} = 'Salinity, Practical [PSU]';
%     data.Properties.VariableNames{'dens'} = 'Density [density, kg/m^3]';
%     data.Properties.VariableNames{'ox_mg_l'} = 'Oxygen Saturation, Weiss [mg/l]';
%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;close('all');

% select the directory containing the data
dname = uigetdir('C:\');

fles=dir([dname '\*.cnv']);

% enter the year to convert from Jday
reply = input('Enter the year in YYYY format:','s');
dte=['31-Dec-' reply ' 00:00:00'];


for ii=1:numel(fles)
    % seperate into fileparts
    filename=fullfile(dname,fles(ii).name);
    parts = strsplit(fles(ii).name,'.');
    fname=char(parts(1));

    % find where header lines finish
    fid = fopen(filename);
    tline = fgetl(fid);
    lineCounter = 1;
    while ischar(tline)
        disp(tline)
        if strcmp(tline, '*END*')
            break;
        end
        % Read next line
        tline = fgetl(fid);
        lineCounter = lineCounter + 1;
    end
    fclose(fid);

    [scan,Jday,pres,depth,temp,cond,ox_mg_l,ox_sat,fluo,par,~,~,~,~,dep,salt,dens,sno,flag]= ...
        textread(filename,repmat('%f',1,19), 'endofline',...
        '\r\n','headerlines',lineCounter);

    % make dates to datetime format
    mtime=datenum(dte)+Jday;
    dateform=datestr(mtime,'dd-mmm-yyyy HH:MM:SS');

    % make into table
    data = table(scan,Jday,dateform,pres,depth,temp,cond,ox_mg_l,salt,dens,fluo,par,flag);

    % cut off the top 0.2 m
    surface=find(depth<=0.2);
    id=data.depth<0.2;
    data=data(~id,1:end);

    % change table headers
    data.Properties.VariableNames{'fluo'} = 'Fluorescence, WET Labs ECO-AFL/FL [mg/m^3]';
    data.Properties.VariableNames{'dateform'} = 'Date Time dd-mmm-yyyy HH:MM:SS';
    data.Properties.VariableNames{'Jday'} = 'Julian Days';
    data.Properties.VariableNames{'pres'} = 'Pressure [db]';
    data.Properties.VariableNames{'depth'} = 'Depth [salt water, m]';
    data.Properties.VariableNames{'temp'} = 'Temperature [ITS-90, deg C]';
    data.Properties.VariableNames{'cond'} = 'Conductivity [S/m]';
    data.Properties.VariableNames{'salt'} = 'Salinity, Practical [PSU]';
    data.Properties.VariableNames{'dens'} = 'Density [density, kg/m^3]';
    data.Properties.VariableNames{'ox_mg_l'} = 'Oxygen Saturation, Weiss [mg/l]';
    data.Properties.VariableNames{'par'} = 'PAR/Logarithmic, Satlantic [umol photons/m^2/sec]';

    % seperate the downcast and upcast data 
    max_z=max(data.("Depth [salt water, m]"));
    ids = find(data.("Depth [salt water, m]")==max_z);

    % downcast data
    down=data(1:ids,1:end);

    % upcast data
    up=data(ids+1:end,1:end);up=flipud(up);

    % print to CSV
    writetable(up,fullfile(dname,[fname '_upcast.csv']),'Delimiter',',')  
    writetable(down,fullfile(dname,[fname '_downcast.csv']),'Delimiter',',') 
    
    answer = questdlg('Would you like to bin average the data?', ...
        'Bin average', ...
        'Yes please!','No thank you','No thank you');
    % Handle response
    switch answer
        case 'Yes please'
        disp(['Bin averaging file ' filename])
        case 'No thank you'
        continue
    end
    % bin average 1 m bins upcast data
    edges = (0:1:ceil(max_z));
    [~,~,loc]=histcounts(up.("Depth [salt water, m]"),edges);
    up.("Date Time dd-mmm-yyyy HH:MM:SS")=datenum(up.("Date Time dd-mmm-yyyy HH:MM:SS"));
    tmat=up.Variables;
    varlen=length(tmat(1,:));
    nmat=NaN(max(edges),varlen);
    for kk=1:varlen
        nmat(:,kk) = accumarray(loc(:),tmat(:,kk))./accumarray(loc(:),1);
    end

    % add the 1 m bins in place of depth
    nmat(:,4)=1:ceil(max_z);

    up_1m=array2table(nmat);
    up_1m.nmat3=datestr(up_1m.nmat3,'dd-mmm-yyyy HH:MM:SS');

    up_1m.Properties.VariableNames=up.Properties.VariableNames;
    writetable(up_1m,fullfile(dname,[fname '_upcast_1m_bin.csv']),'Delimiter',',')  

    % Get bottle firing depths
    btl_filename=fullfile(dname,[fname '.bl']);
    % Read raw bl file
    [rosette,niskin,btl_datetime,btl_start,btl_stop]= ...
        textread(btl_filename,'%f%f%s%f%f', 'endofline','\r\n','delimiter',',','headerlines',1);
    for k=1:length(niskin)
        start=find(scan==btl_start(k));
        stop=find(scan==btl_stop(k));
        niskin_depth(k,1)=mean(depth(start:stop));
    end

    % make table of bottle data
    btldta = table(rosette,niskin,btl_datetime,niskin_depth);

    % write out to CSV
    writetable(btldta,fullfile(dname,[fname '_bottle_depths.csv']),'Delimiter',',')  

end