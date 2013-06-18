function theta = esprit_cov(R, d, n)
% Compute esprit using covariance matrix R
% d: distance between sensors in wavelengths( output from simtone_planar)
% n: number of sources to search.
%% Prerequisites
[m,~] = size(R);
[S, D] = eig(R);
[S,D]=sortem(S,D);
%% DOA estimation
S = S(:,1:n);
S1 = S(1:m-1, :);
S2 = S(2:m, :);
phi = S1\S2;
W = eig(phi);
w = -angle(eig(phi)); %ws->fs->sin(theta)
theta = asin(w/d/pi/2)*180/pi;
end