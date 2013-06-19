%% Initializations
l = 0.04; %distance between sensors in m
m = 8; %num of sensors
fs = 8500; %sampling frequency
N = 1000; %num of samples
fc = 4000; %wave frequency
doa = [33 37];
fp = 4000;
doa = doa .* pi/180;
sig = 0.1;
amps = [1 1];
%% Generate data
n = length(doa);
Y = zeros(N,m);
for i = 1:n
    [Yx, d, t] = simtone_planar(doa(i), m, l, fc, fs, N);
    Y = Y + Yx .* amps(i);
end
Y = addnoise(Y, sig);
%% DOA
[phi,D] = esprit(Y, fc, l, n);
phi
D = abs(D)
%% Plotting
plot(t, real(Y));
xlabel('Time');
ylabel('Value');
title('Data set');
legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
grid on