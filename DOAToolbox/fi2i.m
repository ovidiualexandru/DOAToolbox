%% Frequency to index
% Generate a bin index from a frequnecy. Using FFT to separate frequencies
% results in multiple bins in which close frequencies are grouped. This
% functions takes a frequency and generates a bin index in which the
% frequnecy is "most present".
%
% Input parameters
%
% *_fi_: the desired frequency
% *_fs_: sampling frequency
% *_wlen_: window size for FFT
% 
% Output parameters:
%
% *_fi_: the bin index
%
function i = fi2i(fi, fs, wlen)
i=ceil(fi*wlen/fs);
end