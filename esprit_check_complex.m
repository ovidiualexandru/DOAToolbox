%% Initializations
l = 0.04; %distance between sensors in m
m = 8; %num of sensors
fs = 8500; %sampling frequency
N = 1000; %num of samples
fc = [10 100 400 323 222]; %wave frequency
fp = 4000;
doa = [33 37 10 -20 40];
doa = doa .* pi/180;
sig = 0.1;
amps = [1 1.7 0.5 0.3 1];
%% Generate data
n = length(doa);
Y = zeros(N,m);
for i = 1:n
    Yx = simtone_planar(doa(i), m, l, fc(i), fs, N);
    [Yp, d, t] = simtone_planar(doa(i), m, l, fp, fs, N);
    Y = Y + Yx .* Yp .* amps(i);
end
Y = addnoise(Y, sig);
%% DOA
phi = esprit(Y, fp, l, n)
%% Plotting
plot(t, real(Y));
xlabel('Time');
ylabel('Value');
title('Data set');
legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
grid on