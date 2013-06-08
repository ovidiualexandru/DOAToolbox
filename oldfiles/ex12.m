%program 2 
f=100;     %frecventa 
phi=0;     %faza 
T=1; 
Te=1/2000;
%f = [30 40 49 50 51 60];
f1 = 400;
f2 = 300;
figure(1);
t=Te:Te:T;
x = sin(2*pi*f*t);
b=firpm(100,[ 0 0.1 0.11 0.3 0.31 1],[0 0 1 1 0 0]);
%b=firpm(100,[0 .1 .2 .5],[1 1 0 0]);
ytb=filter (b,1,x);
%ytb = x;
y = ytb.^2;
plotspec(y,Te);
