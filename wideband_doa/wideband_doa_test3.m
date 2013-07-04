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
%% Signal composition
[Y,Fs, NBITS] = wavread('test3.wav');
%% Wideband DOA
[N, phicapon, phimusic, thetaesprit, f] = wideband_doa(real(Y), l, Fs, n, wlen, bins, olf, L);
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

%% Plot the spatial spectrum
figure(1)
x = ((0:(L-1)) .* pi/L - pi/2); % x in radians
x = x * 180/pi; %x in degrees
imagesc(x,f, phicapon.');
xlabel('Degrees');
ylabel('Frequency');
title('Capon estimation');
grid on

figure(2)
x = ((0:(L-1)) .* pi/L - pi/2); % x in radians
x = x * 180/pi; %x in degrees
imagesc(x,f, phimusic.');
xlabel('Degrees');
ylabel('Frequency');
title('MUSIC estimation');
grid on

