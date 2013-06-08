function Y = addnoise(Yc, sig)
[N,m] = size(Yc);
% generate the noise component
e=sqrt(sig/2)*(randn(N,m)+1i*randn(N,m));
Y = Yc + e;
end