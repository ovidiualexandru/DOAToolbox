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
olf = wlen/2;    %overlapping factor for stft( fft_separate)
N = wlen * bins * 5; %num of samples
sig = 0.01; % sig is the noise variance -> influences snr
%% Signal composition
[highb,Fs] = wavread('highb.wav');
d3 = wavread('d3.wav');
fc = 1000:50:1500;
Ya = simsound_planar(13*pi/180, m, l, highb(:,1), Fs);
Yb = simsound_planar(-45*pi/180, m, l, d3(:,1), Fs);
Yc = simband_planar(-34 * pi/180, m, l, fc, Fs, N);
dsfactor = 5; % 'downsampling' factor
fs = Fs / dsfactor;
minlines = min(size(Ya,1), size(Yc,1));
Y = Ya(1:minlines,:) + Yc(1:minlines, :) * 0.01;
%Y = Ya;
Y = Y(1:dsfactor:end,:);
%Y = addnoise(Y, sig);
player = audioplayer(Y, fs);
play(player);
%% Wideband DOA
N = wideband_doa(real(Y), l, fs, wlen, bins, olf);
N
player = audioplayer(real(Y(1:N,:)), fs);
play(player);
%% Plotting
% figure(3)
% plot(t, real(Y));
% xlabel('Time');
% ylabel('Value');
% title('Data set');
% legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
% grid on

