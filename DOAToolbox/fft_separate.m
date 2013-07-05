%% FFT separation
% Separate frequencies using FFT
%
% Input parameters:
%
% * _y_: the sample vector, should be of size wlen*bins.
% * _wlen_: window length, or FFT order. Should be power of 2( 32, 64 etc.)
% * _bins_: number of frequency bins, number of samples for each frequency.
% * _fs_: sampling frequency.
% * _olf_ (optional): overlapping factor. Number of samples that should overlap
% between windows. 0 <= olf <wlen. If left blank, will be assumed 0,
% meaning no overlapping between windows
%
% Output parameters:
%
% *_W_: an wlen-by-bins matrix containing each frequency samples on the
% lines
% *_f_: the frequency spectrum. Useful for plotting the FFT for each
% window( columns).
%
function [W,f] = fft_separate(y, wlen, bins, fs, olf)
if nargin < 5
    olf = 0;
end
%% FFT
%%% W contains each frequency bin on the lines
%%% W(1,:) are samples for 0*(wlen/2)/fs
%%% W(2,:) are samples for 1*(wlen/2)/fs
%%% etc
W = zeros(wlen, bins);
for i = 1: bins
    %take a wlen size window from the samples and compute the fft
    W(:,i) = fft(y(((i-1)*(wlen-olf)+1): (i-1)*(wlen-olf)+wlen),wlen)/wlen;
end
f = fs/2*linspace(0,1,wlen/2+1);
end