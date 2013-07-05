%% Downsample data set
% Y: input data set
% Fs: input sampling rate
% dsfactor: the factor by which to downsample
% Ynew : output data set
% Fsnew: output sampling rate
%
% The function works by averaging dsfactor samples
function [Ynew, Fsnew] = downsample(Y, Fs, dsfactor)
%% Cutoff excess samples
[samples, m] = size(Y);
newsamples = floor(samples/dsfactor);
Y = Y(1:(newsamples * dsfactor), :);
Ynew = zeros(newsamples, m);
Fsnew = Fs / dsfactor;
%% Reshape and mean
for i = 1:m
newline = mean(reshape(Y(:,i), dsfactor, newsamples));
Ynew(:,i) = newline(:); % as column
end