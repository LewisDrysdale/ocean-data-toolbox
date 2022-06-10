function  cnvread(cast,filename,driver,inpath,outpath,meta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. Read in CTD data from .cnv file (produced by SeaBird Processing)
% A driver file should be created listing all the columns contained in the
% file plus the units, e.g. 
%       CTDtime,[secs]
%       CTDpres,[db]
%       CTDtemp1,[ITS-90 deg C]
%       CTDtemp2,[ITS-90 deg C]
%       ........
% 2. Load metadata and cross check. Select relevant info. 
% 3. Save all variables to structure
% 4. Save structure containing all data and metadata
% Example:
%     filename = 'DY008_001_derive_2Hz.cnv';
%     driver = 'C:\data\SSB\DY008\CTD\calibration\DY008_CTDcnv_driver.csv';
%     meta = 'C:\data\SSB\DY008\CTD\calibration\DY008_metadata.mat';
%     inpath = 'C:\data\SSB\DY008\CTD\processed CTD data\';
%     outpath = 'C:\data\SSB\DY008\CTD\calibration\mat\';
% cnvread(filename,driver,inpath,outpath)

% Writtten by J. Hopkins for SSB CTD data processing, 08 August 2014
% Edited by ESDU for JR16006, July 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Read in driver file containing file contents
    fid=fopen([driver]);
        H = textscan(fid,'%s%s','delimiter',',');
    fclose(fid);

% Transpose
    H=cellfun(@transpose,H,'UniformOutput',false);
    %headers = cell2table([H{1}; H{2}])

%% Loop through input file and extract columns of data
infile = [inpath filename];
fid = fopen(infile,'r');            %open input file for reading

while 1  % Read each line of the input file                       
    lines = fgetl(fid);
    
% check for blank delimiter line at end of file    
    if ~isstr(lines);break;end               

    if strncmp(lines,'** Station Number:',18);
        STNNBR = lines(19:end);
        S.STNNBR = strtrim(STNNBR);
    end
    
% loop through file header until '*END*' is reached.
% skip out of loop to start reading data
    if strncmp(lines,'*END*',5);     
        break                        
    end
    
end

row = 0;
while 1             
    lines = fgetl(fid);              %Read each line of the input file
    if ~isstr(lines);break;end        %check for blank delimiter line at end of file
    row = row+1;                      %increment line counter
    DATA(row,:) = sscanf(lines,'%f')';   %read into output variable.
end

fclose(fid);

% % Compile into a table
%     master = [H{1}; H{2}; num2cell(DATA)];
%     master = cell2table(master);



% %% Extract relevant metadata and drop into a structured array
% 
% cast_num = str2num(filename(7:9)); % Extract cast number from filename
% 
% % Load metadata
%     MET = load(meta);
% % verify that cast and station number agree between meta data and cnv
%     % file
%     p1 = find(MET.STNNBR == STN_ID);
%     p2 = find(MET.CAST == cast_num);
% 
% if p1 == p2
%     display(['Merging metadata from cast #: ',num2str(MET.CAST(p1)),' (STNNBR: ',num2str(MET.STNNBR(p1)),')'])
%     S.CRUISE = MET.CRUISECODE;
%     S.CAST = MET.CAST(p1);
%     S.STNNBR = MET.STNNBR(p1);
%     S.DATE = MET.DATE(p1,:);
%     S.TIME = MET.TIME(p1,:);
%     S.LAT = MET.LAT(p1);
%     S.LON = MET.LON(p1);
%     S.DEPTH = MET.DEPTH(p1);
%     
% else
%     display('Uncertainy over cast and station numbers')
% end
%% Convert DATA into a structure
% 
% for ind = 1:size(DATA,2)
%         ch = cell2struct(H{1}(ind));
%         ch = ch(3:end-3);
%         eval(['S.',ch,' = DATA(:,ind);'])
%         ch = [];
% end

vars=char(H{1});
for ind = 1:size(DATA,2)
    eval(['S.' strtrim(vars(ind,:)) '=DATA(:,' num2str(ind) ');']);
end

S.vars=char(H{1});
S.units=char(H{2});
S.CAST=cast;

% Rename structure
sname = 'CTD000';
sname(end-(size(num2str(cast),2)-1):end) = num2str(cast);
eval([sname,' = S;',])

% Save
outfile = filename(1:end-4);
eval(['save ',outpath outfile ,' ',sname])