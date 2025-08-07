clear all; close('all')
addpath('C:\Users\sa01ld\ocean-data-toolbox\Fetch-AZA\t_tide')
filename='X:\Marphys_Archive\Data\OSNAP\RTEB1L-FetchAZA\pressure-record-20230907.csv'
data=readtable(filename)
data=data(60:end,:)
presens=data.PressurePresens_kPa_
[NAME,FREQ,TIDECON,XOUT]=t_tide(presens)
tim=datenum(data.RecordTime)
YOUT=t_predic(tim,NAME,FREQ,TIDECON)

figure;
plot(presens)
hold on
plot(presens-YOUT)