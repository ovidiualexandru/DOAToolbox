%% Beamforming DOA estimation
% Estimates the DOA of single source
%
% Input parameters:
%
% * _Y_: an mxN matrix with the data set. m is the number of sensors and N
% the number of samples
% * _fc_: the frequency of the signal
% * _l_: distance between sensors in meters
% * _L_: number of divisions of [-pi/2; pi/2]
% * _c_ (optional): the speed of the wave. Default is 340.29, speed of
% sound in air.
%
% Output parameters:
%
% * _phi_: estimations of the spatial spectra in L divisions of [-pi/2;
% pi/2]
%
% ex |phi = beamform(Y, fc, l, 180);| with Y, fc and l defined for
% simtone_planar
%%
function phi = beamform(Y, fc, l, L, c)
%% Preprocessing
if nargin < 5
    c = 340.29; %speed of sound in air in m/s
end
%% Prerequisites
lambda = c/fc;
d = l/lambda;
[N,m] = size(Y);
Y = Y.'; %transpose Y for the next line
R = (Y*Y')/N;
phi = zeros(L,1);
%% DOA estimation
for i = 1:L
    theta = -pi/2+(pi/L)*(i-1); % angle to search
    fs = d*sin(theta);
    ws = 2*pi*fs;
    a = exp(-1i*ws*(0:m-1).');
    phi(i) = real(a'*R*a);
end
phi = phi ./ m^2;
end