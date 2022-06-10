

% 2 Date Date and Time in UTC MMDDYY
% 3 Time 0-24H, 0.01 second resolution Hhmmss.ss
% 4 Cell Number # Dd
% 5 Cell Position Distance from sensor to centre of the cell[m] dd.dd
% 6 Velocity East [m/s] dd.ddd
% 7 Velocity North [m/s] dd.ddd
% 8 Velocity Up [m/s] dd.ddd
% 9 Velocity Up2 [m/s] dd.ddd
% 10 Speed [m/s] dd.ddd
% 11 Direction [degrees] ddd.dd
% 12 Amplitude Units D=dB D
% 13 Amplitude Beam 1 [dB] ddd.d
% 14 Amplitude Beam 2 [dB] ddd.d
% 15 Amplitude Beam 3 [dB] ddd.d
% 16 Amplitude Beam 4 [dB] ddd.d
% 17 Correlation Beam 1 [%] dd
% 18 Correlation Beam 2 [%] dd
% 19 Correlation Beam 3 [%] dd
% 20 Correlation Beam 4 [%] dd

dcount=0;
dtastrct=struct([]);
navstrct=struct([]);

ddr='C:\Users\sa01ld\OneDrive - SAMS\Projects\Autonaut-EE\Non-Acoustic data\Signature_500_ADCP_01\2021\08'
fles=dir(ddr);
fles=fles(~ismember({fles.name},{'.','..'}));
for ii=1:numel(fles)
    ff=fullfile(ddr,fles(ii).name);
    fid = fopen(ff);
    tline = fgetl(fid);
    while ischar(tline)
         disp(tline)
        if strcmpi(tline(1:7),'$PNORCV')
%             disp('Bingo!')
            dcount=dcount+1;
            linedata=split(tline,',');
            dtastrct(dcount).type=char(linedata(1));
            dtastrct(dcount).date=str2double(linedata(2));
            dtastrct(dcount).time=str2double(linedata(3));
            dtastrct(dcount).velocity_east=str2double(linedata(6));
            dtastrct(dcount).velocity_north=str2double(linedata(7));
            dtastrct(dcount).speed=str2double(linedata(10));

        end
        tline = fgetl(fid);
    end
    fclose(fid);
end