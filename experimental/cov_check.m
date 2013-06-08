%% Initializations
l = 0.04; %distance between sensors in m
m = 8; %num of sensors
fs = 44100; %sampling frequency
N = 1000; %num of samples
fc = [10 100 2 ]; %wave frequency
doa = [-10 45 65];
fp = 4000;
doa = doa .* pi/180;
sig = 0.1;
amps = 1;
%% Generate data
n = length(doa);
Y = zeros(N,m);
for i = 1:n
    [Yx,~, ~] = simtone_planar(doa(i), m, l, fc(i), fs, N);
    [Yp,d, t] = simtone_planar(doa(i), m, l, fp, fs, N);
    Yx = Yx .* amps .* Yp; %modulation
    Y = Y + Yx;
end
Y = addnoise(Y, sig);
%% Generate covariance matrices
P = diag(amps.^2);
R1 = cov_model(P, sig, m, 2*pi*d*sin(doa));
Y = Y.'; %transpose Y for the next line
R2 = (Y*Y')./N;
J = fliplr(eye(m));
R2 = 1/2*(R2 + J*R2.'*J);
%% Compute their norm
nm = norm(R1-R2);
nm
%% DOA
theta = esprit_cov(R2,d,n)
%% Plotting
plot(t, real(Y));
xlabel('Time');
ylabel('Value');
title('Data set');
legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
grid on