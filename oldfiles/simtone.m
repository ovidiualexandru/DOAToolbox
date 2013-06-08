function [tmat, fs]= simtone(x,y)

c = 340.29;
d = sqrt(x.^2 + y.^2);
tau = d./c;

T = 1;
f = 523.25;
fs = 44100; %sampling frequency
%fs = 2000; %sampling frequency
Ts = 1/fs;
t = 0:Ts:T;
%ys = cos(2*pi*t.*f);
ys = exp(-1i*2*pi*t.*f);
% aps = audioplayer(ys, fs);
% playblocking(aps);

n = floor(T/Ts);
tmat = zeros( n, length(x));
for i = 1:length(x)
    m = floor(tau(i)/ Ts);
    tmat(m:end,i) = ys(1:n-m+1);
end

figure(1)
hold on
h = stem(x,y,'filled');
set(h,'LineStyle','none');
h = stem(0,0);
set(h,'MarkerFaceColor','red','Marker','square');
set(h,'LineStyle','none');
%axis([-2 2 -2 2]);
grid on
hold off


figure(2)
plot(t(1:end-1), tmat);
grid on

end