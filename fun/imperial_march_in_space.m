[a0,Fs] = wavread('a0.wav');
a3 = wavread('a3.wav');
e1 = wavread('e1.wav');
d2 = wavread('d2.wav');
d3 = wavread('d3.wav');
d0 = wavread('d0.wav');

a0s = [a0; a0; a0];
d2s = [d2; d2; d2];
chor = [ e1; a3; a0];
rst = [d3; d0; a3];

Y1 = simsound_planar(0*pi/180, 2, 0.2, a0s, Fs);
Y2 = simsound_planar(85*pi/180, 2, 0.2, chor, Fs);
Y3 = simsound_planar(-85*pi/180, 2, 0.2, chor, Fs);
Y4 = simsound_planar(45*pi/180, 2, 0.2, d2s, Fs);
Y5 = simsound_planar(-45*pi/180, 2, 0.2, rst, Fs);
Y6 = simsound_planar(85*pi/180, 2, 0.2, chor, Fs);
Y = [Y1; Y2; Y3; Y4; Y5; Y6];
player = audioplayer(Y, Fs);
play(player);