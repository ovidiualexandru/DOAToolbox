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
wlen = 4096;      %fft order, or window size
bins = 10;       %num of windows
olf = wlen/2;    %overlapping factor for stft( fft_separate)
sig = 0.01; % sig is the noise variance -> influences snr
%% Signal composition
[Y,Fs, NBITS] = wavread('eighchannel.wav');
%% Wideband DOA
N = wideband_doa(real(Y(10000:end, :)), l, Fs, wlen, bins, olf);
N
player = audioplayer(Y, Fs);
play(player);
%% Plotting
figure(3)
plot(real(Y));
xlabel('Time');
ylabel('Value');
title('Data set');
legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
grid on

