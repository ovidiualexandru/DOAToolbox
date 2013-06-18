%% Initializations
l = 0.04; %distance between sensors in m
m = 8; %num of sensors
fs = 8500; %sampling frequency
wlen = 64; %% fft order
bins = 100; %%num of windows 
N = wlen * bins; %num of samples
fc = [10 4000]; %wave frequency
doa = [-2 25];
doa = doa .* pi/180;
sig = 0.1;
amps = [0.5 1];
%% Generate data
n = length(doa);
Y = zeros(N,m);
d = zeros(1, n);
for i = 1:n
    [Yx, d(i), t] = simtone_planar(doa(i), m, l, fc(i), fs, N);
    Y = Y + Yx .* amps(i);
end
y = real(Y(:,1));
%% FFT
W = zeros(wlen, bins);
for i = 1: bins
W(:,i) = fft(y( ( (i-1)*wlen+1): i*wlen),wlen)/wlen;
end
%Yfft = fftshift(Yfft);
f = fs/2*linspace(0,1,wlen/2+1);
%% Plotting
figure(1)
plot(t, real(Y));
xlabel('Time');
ylabel('Value');
title('Data set');
legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
grid on
figure(2)
plot(f,2*abs(W(1:wlen/2+1,1))) 
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
grid on
figure(3)
plot(t(1:length(W(1,:))),W(31,:)); 
grid on