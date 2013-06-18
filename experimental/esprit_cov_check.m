%% Initializations
l = 0.04; %distance between sensors in m
m = 8; %num of sensors
fs = 44100; %sampling frequency
N = 1000; %num of samples
fc = [3500]; %wave frequency
doa = [-22 ];
fp = 4000;
doa = doa .* pi/180;
sig = 0.1;
amps = [1 1.7 1.3 1.4];
%% Generate data
n = length(doa);
Y = zeros(N,m);
d = zeros(1, n);
for i = 1:n
    [Yx, d(i), t] = simtone_planar(doa(i), m, l, fc(i), fs, N);
    Y = Y + Yx .* amps(i);
end
Y = addnoise(Y, sig);
%% Generate covariance matrix
Y = Y.'; %transpose Y for the next line
R2 = (Y*Y')./N;
J = fliplr(eye(m));
R2 = 1/2*(R2 + J*R2.'*J);
%% DOA
theta = zeros(n);
for i = 1:n
    theta(:,i) = esprit_cov(R2, d(i), n);
end
theta
%% Plotting
plot(t, real(Y));
xlabel('Time');
ylabel('Value');
title('Data set');
legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
grid on