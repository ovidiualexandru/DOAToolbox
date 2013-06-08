%% Planar wave simulator
% Gives the output of an m sensor ULA with a planar armonic wave 
% with a given DOA.
%
% Input parameters:
%
% * _theta_: the DOA of the planar wave in radians [-pi/2; pi/2]
% * _m_: number of sensors
% * _l_: distance between sensors in m
% * _fc_: the frequency of the planar wave.
% * _fs_: sampling frequency
% * _N_: number of samples
%
% Output parameters:
%
% * _Y_: the output matrix, with N lines and m colums.
% * _d_: the distance between sensors in wavelengths l/lambda
%
% ex: |[Y,d] = simtone_planar(pi/3, 8, 0.04, 3000, 8000, 1000);|
%%
function [Y, d, t] = simtone_planar(theta, m, l, fc, fs, N)
%% Delays
c = 340.29; %speed of sound in air in m/s
lambda = c/fc;
d = l/lambda;
tau = zeros(m,1); %delay vector
for k = 1:m
    tau(m+1-k) = (k-1)*(l/c)*sin(theta);
end
%% Output matrix
Ts = 1/fs;
t = (0:Ts:(N-1)*Ts)';
Y = zeros(length(t),m);
for i = 1:m
    Y(:,i)=exp(-1j*2*pi*(t-tau(i)).*fc);
end
%% Plotting
%plot(t, real(Y));
end