%% ESPRIT DOA estimation
% Estimates the DOA of n sources.
%
% Input parameters:
%
% * _Y_: an mxN matrix with the data set. m is the number of sensors and N
% the number of samples
% * _fc_: the frequency of the signal
% * _l_: distance between sensors in meters
% * _n_: number of sources to search. Usually works for maximum 2
% correlated souces.
% * _c_ (optional): the speed of the wave. Default is 340.29, speed of
% sound in air.
%
% Output parameters:
%
% * _phi_: estimations of the spatial spectra in L divisions of [-pi/2;
% pi/2]
%
% ex |phi = esprit(Y, fc, l, 180);| with Y, fc and l defined for
% simtone_planar
%%
function [theta,W] = esprit(Y, fc, l, n, c)
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
J = fliplr(eye(m));
R = 1/2*(R + J*R.'*J); %make R persymmetric
[S,D] = eig(R);
[S,D]=sortem(S,D);
D = diag(D);
%% DOA estimation
S = S(:,1:n);
S1 = S(1:m-1, :);
S2 = S(2:m, :);
Phi = S1\S2;
W = sort(eig(Phi),'descend');
%sort(W);
w = -angle(W); %ws->fs->sin(theta)
theta = asin(w/d/pi/2)*180/pi;
end