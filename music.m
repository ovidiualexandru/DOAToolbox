%% MUSIC DOA estimation
% Estimates the DOA of n sources.
%
% Input parameters:
%
% * _Y_: an mxN matrix with the data set. m is the number of sensors and N
% the number of samples
% * _fc_: the frequency of the signal
% * _l_: distance between sensors in meters
% * _L_: number of divisions of [-pi/2; pi/2]
% * _n_: number of estimated sources
% * _c_ (optional): the speed of the wave. Default is 340.29, speed of
% sound in air.
%
% Output parameters:
%
% * _phi_: estimations of the spatial spectra in L divisions of [-pi/2;
% pi/2]
%
% ex |phi = music(Y, fc, l, 180, 3);| with Y, fc and l defined for
% simtone_planar
%%
function phi = music(Y, fc, l, L, n, c)
%% Preprocessing
if nargin < 6
    c = 340.29; %speed of sound in air in m/s
end
%% Prerequisites
lambda = c/fc;
d = l/lambda;
[N,m] = size(Y);
Y = Y.'; %transpose Y for the next line
R = (Y*Y')/N;
J = fliplr(eye(m));
R = 1/2*(R + J*R.'*J); %make R persymmetric
[S,D] = eig(R);
[S,D]=sortem(S,D);
D = diag(D);
%% DOA estimation
G = S(:,n+1:end);
phi = zeros(L,1);
for i = 1:L
    theta = -pi/2+(pi/L)*(i-1); % angle to search
    fs = d*sin(theta);
    ws = 2*pi*fs;
    a = exp(-1i*ws*(0:m-1).');
    phi(i) = 1/real(a'*G*G'*a); %1/a'*(GG*)*a
end
end