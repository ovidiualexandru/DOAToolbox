[munch1,Fs] = wavread('highb.wav');
Y = simsound_planar(85*pi/180, 2, 0.2, munch1(:,1), Fs);
Y = Y(1:5:end, :);
player = audioplayer(Y, Fs/5);
play(player);