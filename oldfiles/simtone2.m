function Y = simtone2(x,y,f, fs, T)
%% Calcul intarzieri
c = 340.29;
d = sqrt(x.^2 + y.^2);
tau = d./c;
%% Calcul matrice iesire
Ts = 1/fs;
t = 0:Ts:T;
Y = zeros(length(t),length(x));
for i = 1:length(x)
    Y((t-tau(i))>=0,i) = exp(-1i*2*pi*(t(t-tau(i)>=0)-tau(i)).*f);
end
%% Plotare
figure(1)
h = stem(x,y,'filled');
set(h,'LineStyle','none');
hold on
h = stem(0,0);
set(h,'MarkerFaceColor','red','Marker','square');
set(h,'LineStyle','none');
%axis([-2 2 -2 2]);
grid on
hold off
figure(2)
plot(t, Y);
grid on
end