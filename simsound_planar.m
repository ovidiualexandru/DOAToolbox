%% Planar wave recording simulator
% Gives the output of an m sensor ULA with input signal provided from 
% a vector _s_ of samples
%
% Input parameters:
%
% * _theta_: the DOA of the planar wave in radians [-pi/2; pi/2]
% * _m_: number of sensors
% * _l_: distance between sensors in m
% * _s_: the sample vector.
% * _fs_: sampling frequency
%
% Output parameters:
%
% * _Y_: the output matrix, with m colums and a variable number of lines.
% The recording is 'shortened' with a number of samples equal to the delay 
% for each sensor. This is done to avoid zeropadding.
% * _t_: the time vector, useful for plotting
%
% ex: |[Y,t] = simsound_planar(-pi/3, 2,0.2, s, 44100);|
%%
function [Y, t] = simsound_planar(theta, m, l, s, fs)
%% Notes
% NOTE : Fs should be high, to as to provide good resolution. Downsampling
% cand be done after applying this function as follows:
% example for downsampling by a factor of 5.
% Y = Y(1:5:end,:); Fs = Fs/5;
% If Fs is initially 44100 after this downsampling it becomes 8820.
% NOTE : If 2 recording need to be combined, the minimum number of lines
% from each output matrix should be selected.
%% Delays
c = 340.29; %speed of sound in air in m/s
tau = zeros(m,1); %delay vector
for k = 1:m
    tau(m+1-k) = (k-1)*(l/c)*sin(theta);
end
T = floor((tau + abs(min(tau))) .* fs);
Tmax = max(T);
N = length(s) - Tmax;
%% Output matrix
Ts = 1/fs;
t = (0:Ts:(N-1)*Ts)';
Y = zeros(N, m);
for i = 1:m
    Y(:,i) = s( (Tmax-T(i)+1):(end-T(i)) );
end
end