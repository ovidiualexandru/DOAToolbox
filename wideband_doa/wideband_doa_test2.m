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
N = wlen * bins; %num of samples
sig = 0.01; % sig is the noise variance -> influences snr
%% Signal composition
[munch,Fs] = wavread('highb.wav');
Y = simsound_planar(25*pi/180, m, l, munch(:,1), Fs);
dsfactor = 5; % 'downsampling' factor
fs = Fs / dsfactor;
Y = Y(1:dsfactor:end,:);
Y = addnoise(Y, sig);
player = audioplayer(Y, fs);
play(player);
%% Wideband DOA
wideband_doa(real(Y), l, fs, wlen, bins);
%% Plotting
% figure(3)
% plot(t, real(Y));
% xlabel('Time');
% ylabel('Value');
% title('Data set');
% legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
% grid on

