[munch,Fs] = wavread('scare_crow.wav');
munch = munch(:,1);
N = size(munch,1);
l = 180;
angles = linspace(-pi/2, pi/2, l);
n = floor(N/180);
Y = [];
for i = 1:l
    y = simsound_planar(angles(i), 2, 0.2, munch( (n*(i-1)+1):(n*i)), Fs);
    Y = [Y; y];
end
player = audioplayer(Y, Fs);
play(player);