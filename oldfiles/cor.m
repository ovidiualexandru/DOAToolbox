%%Signal generation
N = 200; 
%x = randn(N,1);
%y = randn(N,1);
Ts = 0.01;
fc = 2;
t = 0:Ts:(N-1)*Ts;
tau = 0.4;
x = sin(2*pi*fc.*t);
y = sin(2*pi*fc.*t-tau);
sig2 = 1;
n1 = sqrt(sig2/2)*randn(1,N);
n2 = sqrt(sig2/2)*randn(1,N);
x = x + n1;
y = y + n2;
%%Correlation
[c, lags] = xcorr(x,y);
figure(1)
stem(lags,c./N);
figure(2)
plot(t,x);
