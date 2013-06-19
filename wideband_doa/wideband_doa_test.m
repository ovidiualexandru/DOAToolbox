%% Initializations
l = 0.04; %distance between sensors in m
m = 8; %num of sensors
fs = 8100; %sampling frequency
wlen = 256; %% fft order, or window size
bins = 10; %%num of windows 
N = wlen * bins; %num of samples
fc = [30 124 1500 4000 3413 ]; %wave frequency
doa = [-22 12 -20 34 -47];
doa = doa .* pi/180;
sig = 0.1;
amps = [1 1.01 0.99 1 1.02 1.3 1 1.2];
%% Generate data
n = length(doa);
Y = zeros(N,m);
for i = 1:n
    [Yx,~,t] = simtone_planar(doa(i), m, l, fc(i), fs, N);
    Y = Y + Yx .* amps(i);
end
Y = addnoise(Y,sig);
%% Wideband DOA
wideband_doa(real(Y), l, fs, wlen);
%% Plotting
% figure
% plot(t, real(Y));
% xlabel('Time');
% ylabel('Value');
% title('Data set');
% legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
% grid on