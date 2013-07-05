%% Index to frequency
% Generate a frequency from a bin index. Using FFT to separate frequencies
% results in multiple bins in which close frequencies are grouped. This
% functions takes a bin index and outputs the central frequency for the
% bin.
%
% Input parameters
%
% *_i_: the index
% *_fs_: sampling frequency
% *_wlen_: window size for FFT
% 
% Output parameters:
%
% *_fi_: the centered frequency for the bin
%
function fi = i2fi(i, fs, wlen)
fi = (i-1)*fs/wlen + fs/(2*wlen);
end