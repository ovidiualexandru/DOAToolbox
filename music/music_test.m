%% Parameters
L = 180; %num of divisions for [-pi/2, pi/2]
x = ((0:(L-1)) .* pi/L - pi/2); % x in radians
x = x * 180/pi; %x in degrees
l = 0.04; %distance between sensors in m
m = 8; %num of sensors
fs = 44100; %sampling frequency
N = 1000; %num of samples
fc = 4000; %wave frequency
doa1 = 27; %doa in degrees
doa2 = -12; 
%% Generate data
%%% Narrowband data
[Ya,d,t] = simtone_planar(doa1*pi/180, m, l, fc, fs, N);
Ya = addnoise(Ya,0.1); %add noise with given amplitude
[Yb,d,t] = simtone_planar(doa2*pi/180, m, l, fc, fs, N);
Yb = addnoise(Yb,0.1); %add noise with given amplitude
Y = Ya;
%[Y,d,t] = simband_planar(doa*pi/180, m, l, [500 4000 4500 1000 100], fs, N, [0.1 1 0.1 0.3 0.01]);
Y = addnoise(Y,0.1);
%% Play sound
%aps = audioplayer(real(Y), fs);
%play(aps);
%% Compute DOAs
phim = music(Y, fc, l, L, 2);
%% Plotting
figure(1)
plot(x,phim);
xlabel('Degrees');
title('MUSIC');
grid on
figure(2)
plot(t, real(Y));
xlabel('Time');
ylabel('Value');
title('Data set');
legend('Sensor 1','Sensor 2','Sensor 3','Sensor 4','Sensor 5','Sensor 6','Sensor 7','Sensor 8');
grid on