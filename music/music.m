function phi = music(Y, fc, l, L, n, c)
%% Preprocessing
if nargin < 6
    c = 340.29; %speed of sound in air in m/s
end
%% Prerequisites
lambda = c/fc;
d = l/lambda;
[N,m] = size(Y);
Y = Y.'; %transpose Y for the next line
R = (Y*Y')/N;
J = fliplr(eye(m));
R = 1/2*(R + J*R.'*J); %make R persymmetric
[S,D] = eig(R);
[S,D]=sortem(S,D);
D = diag(D);
%% DOA estimation
G = S(:,n+1:end);
phi = zeros(L,1);
for i = 1:L
    theta = -pi/2+(pi/L)*(i-1); % angle to search
    fs = d*sin(theta);
    ws = 2*pi*fs;
    a = exp(-1i*ws*(0:m-1).');
    phi(i) = 1/real(a'*G*G'*a); %1/a'*(GG*)*a
end
end