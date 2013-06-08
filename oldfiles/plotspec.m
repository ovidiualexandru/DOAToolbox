 function plotspec(x,Te) 
N=length(x); 
t=Te*(1:N);   %vectorul timp 
f=((-1)*N/2:N/2-1)/(Te*N);  %vectorul frecventa 
fx=fft(x(1:N));  %transformata Fourier  
                %discreta rapida 
fxs=fftshift(fx);   %deplaseaza vectorul spectru  
  %cu mijlocul intervalului in  
  %origine 
 
subplot(2,1,1)  
plot(t,x) 
xlabel('secunde') ; 
ylabel('amplitudine'); 
subplot(2,1,2) 
plot(f,abs(fxs)) 
xlabel('frecventa'); 
ylabel('modul');