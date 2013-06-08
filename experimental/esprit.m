function theta = esprit(Y, fc, l, n, c)
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
[S, D] = eig(R);
[S,~]=sortem(S,D);
%% DOA estimation
S = S(:,1:n);
S1 = S(1:m-1, :);
S2 = S(2:m, :);
phi = S1\S2;
W = eig(phi);
w = -angle(eig(phi)); %ws->fs->sin(theta)
theta = asin(w/d/pi/2)*180/pi;
end