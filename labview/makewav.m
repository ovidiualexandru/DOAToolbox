file = {'1.dat', '2.dat', '3.dat', '4.dat', '5.dat', '6.dat', '7.dat', '8.dat'};
Fs =  43478;
wavname = 'eightchannel.wav';
Y = [];
for i = 1:8;
    y = readbinary(file{i},'l');
    Y(:,i) = y;
end
wavwrite(int16(Y),Fs, wavname);
Yread = wavread(wavname);
%plot(y);
%soundsc(y, 43546, 16);
%mymax = max(y);
%y = y ./ mymax;
%plr = audioplayer(int16(y), 43546, 16);
%play(plr);
