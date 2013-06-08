%% Parameters
L = 180; %num of divisions for [-pi/2, pi/2]
x = ((0:(L-1)) .* pi/L - pi/2); % x in radians
x = x * 180/pi; %x in degrees
l = 0.04; %distance between sensors in m
m = 8; %num of sensors
fs = 44100; %sampling frequency
N = 1000; %num of samples
fc = 4000; %wave frequency
doa = 27; %doa in degrees
%% Generate data
%%% Narrowband data
[Ya,d,t] = simtone_planar(doa*pi/180, m, l, fc, fs, N);
Ya = addnoise(Ya,0.1); %add noise with given amplitude
[Yb,d,t] = simtone_planar((doa+ 5)*pi/180, m, l, fc, fs, N);
Yb = addnoise(Yb,0.1); %add noise with given amplitude
Y = Ya;
%[Y,d,t] = simband_planar(doa*pi/180, m, l, [500 4000 4500 1000 100], fs, N, [0.1 1 0.1 0.3 0.01]);
Y = addnoise(Y,0.1);
%% Play sound
%aps = audioplayer(real(Y), fs);
%play(aps);
%% Compute DOAs
phib = beamform(Y, fc, l, L);
phic = capon(Y,fc, l, L);
%phie = esprit(Y, fc, l, 2);
%% Plotting
subplot(2,2,1)
plot(x,phib);
xlabel('Degrees');
title('Beamforming');
grid on
subplot(2,2,2)
plot(x,phic);
xlabel('Degrees');
title('Capon');
grid on
subplot(2,2,3:4)
plot(t, real(Y));
xlabel('Time');
ylabel('Value');
title('Data set');
legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
grid on