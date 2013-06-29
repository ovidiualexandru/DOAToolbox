%% Initializations
%Variables:
%Fixed:
% l: distance between sensors in m
% m: number of sensors
% fs: sampling frequency
%Tunables:
% wlen: affects frequency precision, is the most important parameter
% bins: number of samples for the narrowband algo to work with
% wlen and bins set the total number of necessary samples, N
l = 0.04;        %distance between sensors in m
m = 8;           %num of sensors
wlen = 256;      %fft order, or window size
bins = 10;       %num of windows 
N = wlen * bins * 5; %num of samples
sig = 0.01; % sig is the noise variance -> influences snr
%% Signal composition
[Y,Fs] = wavread('test31.wav');

player = audioplayer(Y, Fs);
play(player);
%% Wideband DOA
wideband_doa(real(Y), l, Fs, wlen, bins);
%% Plotting
figure(3)
plot(real(Y));
xlabel('Time');
ylabel('Value');
title('Data set');
legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
grid on

