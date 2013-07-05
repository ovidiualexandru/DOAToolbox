addpath './DOAToolbox'
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
% olf: overlapping factor, integer between 0 and wlen-1
% L: precision/ resolution, how many slices to divide the angle domain
l = 0.04;        %distance between sensors in m
m = 8;           %num of sensors
fs = 8820;       %sampling frequency
wlen = 512;      %fft order, or window size
bins = 10;       %num of windows 
olf = wlen/2;    %overlapping factor for stft( fft_separate)
N = wlen * bins; %num of samples
L = 180;         %num of divisions for [-pi/2, pi/2]
x = ((0:(L-1)) .* pi/L - pi/2); % x in radians
x = x * 180/pi; %x in degrees
%% Signal composition
fc = 4000;
doa = [-5 0];
%doa = doa .* pi/180;
sig = 0.1; % sig is the noise variance -> influences snr
%amps = [1 1.01 0.99 1 1.02 1.3 1 1.2];
%% Generate data
n = length(doa);
Y = zeros(N,m);
for i = 1:n
    [Yx,~,t] = simtone_planar(doa(i) * pi/180, m, l, fc, fs, N);
    Y = Y + Yx;
end
%% Wideband DOA
Y = addnoise(Y,sig);
phib = beamform(Y, fc, l, L);
phic = capon(Y,fc, l, L);
phim = music(Y, fc, l, L, n);
thetae = esprit( Y, fc, l, n)
%% Plotting
figure(1)
plot(x,phib);
xlabel('Degrees');
title('Beamforming');
grid on

figure(2)
plot(x,phic);
xlabel('Degrees');
title('Capon');
grid on

figure(3)
plot(x,phim);
xlabel('Degrees');
title('MUSIC');
grid on
%% Clean-up
rmpath './DOAToolbox'
clear L N Y Yx bins doa fc fs i l m n olf phib phic phim sig t wlen x thetae