function [ ] = fft_analyse( signal, Fs)
%% Time specification
    dt= 1/Fs;   
    N = size(signal,1);
    t = (0:dt:N*dt-dt)';
%% Fourier Transform:
    X = fftshift(fft(signal));
%% Frequency specifications:
    dF = Fs/N;                      % hertz
    f = -Fs/2:dF:Fs/2-dF;           % hertz
%% Plot the spectrum:
    figure;
    subplot(1,2,1);
    plot(t, signal);
    xlabel('Timp [s]');
    ylabel('Amplitudine');
    title('Semnal original');
    subplot(1,2,2);
    plot(f,10*log(abs(X)/N));
    xlabel('Frecventa (in hertz)');
    title('Magnitude Response');
end