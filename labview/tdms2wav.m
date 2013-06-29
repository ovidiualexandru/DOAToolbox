function Y1 = tdms2wav(filename, Fs, downsample)

[ConvertedData,ConvertVer,ChanNames,GroupNames,ci]=convertTDMS(0,filename);
samples = ConvertedData.Data.MeasuredData(1,3).Total_Samples;
newsamples = floor(samples / downsample);
total = newsamples * downsample;
Y1 = zeros(samples, 8);
Y = zeros(newsamples, 8);
for i = 3:10
    y1 = ConvertedData.Data.MeasuredData(1,i).Data;
    Y1(:,i-2) = y1;
    y1 = y1(1:total);
    y2 = reshape(y1, downsample, newsamples);
    y2 = mean(y2);
    Y(:,i-2) = y2';
end
plot(Y);
Fs = floor(Fs/downsample)
wavwrite(int16(Y), Fs,16, 'f.wav');
end