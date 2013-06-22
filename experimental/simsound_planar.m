function [Y, t] = simsound_planar(theta, m, l, s, fs)
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