%% Planar wave simulator
% Gives the output of an m sensor ULA with a planar wave with multiple
% frequencies with a given DOA.
%
% Input parameters:
%
% * _theta_: the DOA of the planar wave in radians [-pi/2; pi/2]
% * _m_: number of sensors
% * _l_: distance between sensors in m
% * _fc_: the frequency vector.
% * _fs_: sampling frequency
% * _N_: number of samples
% * _amps_ (optional): the amplitudes of each frequency. If not given,
% takes value of one for each frequency.
%
% Output parameters:
%
% * _Y_: the output matrix, with N lines and m colums.
% * _d_: the distance between sensors in wavelengths l/lambda
%
% ex: |[Y,d] = simband_planar(-pi/3, 2,0.04, 350:10:400, 44100, 5000, 1:0.1:1.5);|
%%
function [Y, d, t] = simband_planar(theta, m, l, fc, fs, N, amps)
%% Preprocessing
fc = fc(:)';
if nargin < 7
    amps = ones(length(fc), 1);
end
amps = amps(:);
%% Delays
c = 340.29; %speed of sound in air in m/s
[~,domi] = max(amps);
fdom = fc(domi);
lambda = c/fdom;
d = l/lambda;
tau = ((m-1):-1:0)'.*(l/c)*sin(theta);
%% Output matrix
Ts = 1/fs;
t = (0:Ts:(N-1)*Ts)';
Y = zeros(length(t),m);
for i = 1:m
    Y(:,i)=exp(-1j*2*pi*(t-tau(i))*fc)*amps;
end
%% Plotting
%plot(t, real(Y));
end