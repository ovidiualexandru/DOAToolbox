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
fs = 8820;       %sampling frequency
wlen = 512;      %fft order, or window size
bins = 10;       %num of windows 
olf = wlen/2;    %overlapping factor for stft( fft_separate)
N = wlen * bins; %num of samples
%% Signal composition
% Create a frequency range and a doa, and add them to a cell arrays 
%'fc' and 'doa'
fc1 = 500:15:1500;
doa1 = -22;
fc2 = 1300:25:1500;
doa2 = 0;
fc3 = 100:25:150;
doa3 = 45;
fc4 = 100:20:200;
doa4 = 80;
fc5 = 500:5:1500;
doa5 = 3;
fc = {fc1, fc2};
doa = {doa1, doa2};
%doa = doa .* pi/180;
sig = 0.1; % sig is the noise variance -> influences snr
%amps = [1 1.01 0.99 1 1.02 1.3 1 1.2];
%% Generate data
n = length(doa);
Y = zeros(N,m);
for i = 1:n
    [Yx,~,t] = simband_planar(doa{i} * pi/180, m, l, fc{i}, fs, N);
    Y = Y + Yx;
end
Y = addnoise(Y,sig);

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