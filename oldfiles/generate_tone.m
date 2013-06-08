function aps = generate_tone(f, T)
fs = 44100; %sampling frequency
Ts = 1/fs;
x = 0:Ts:T;
y = sin(2*pi*x.*f);
aps = audioplayer(y, fs);
play(aps);
end