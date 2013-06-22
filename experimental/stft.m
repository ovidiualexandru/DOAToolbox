time1=0:1:200;
t1=201:1:400;
time2=401:1:600;
t2=601:1:800;
time3=801:1:1000;
signal1=sin(500*t1); %frequency1 = 500/(2*pi)

plot(t1,signal1);
xlabel('Time (seconds)');
ylabel('Magnitude');
signal2=sin(50*t2); %frequency2 =50/(2*pi)
figure,
plot(t2,signal2);
xlabel('Time (seconds)');
ylabel('Magnitude');

signal=[zeros(size(time1)) signal1 zeros(size(time2)) signal2  zeros(size(time3))];
figure,
time=0:1:1000;
plot(time,signal);
xlabel('Time (seconds)');
ylabel('Magnitude');

x=size(signal);
p=round(x(2)/10);
X=signal;

step_dist=10;
window_length=p;
LENX = length(X);
IMGX = ceil(LENX/step_dist);
if (window_length/2 == round(window_length/2))
	IMGY = (window_length/2) + 1;
else
	IMGY = ceil(window_length/2);
end

stft_plot = zeros(IMGX,IMGY);

X = [zeros(1,window_length/2) X zeros(1,window_length/2)]; % padding the signal with zeros
WIN = ones(1,window_length);
iter = 0;
for i = 1:step_dist:LENX
	iter = iter + 1;
	windowing = X(i:(i + window_length - 1));  % making window

	signal_window = windowing.* WIN; %y(t)=h(t)*w(n-t)
	signalout = abs(fft(signal_window, window_length)); %fft of y(t) gives us stft
	stft_plot(iter,:) = signalout(1:IMGY);
end
%sampling_rate=10;
freq = 10;
figure,
imagesc([0:(step_dist):(LENX-1)],[0:(freq):freq*10],stft_plot');
xlabel('Time (seconds)');
ylabel('Frequency (Hz)');
axis('xy')