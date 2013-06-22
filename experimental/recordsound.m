% Record sound for 1 second from IOID device at Fs sampling freq, store in
% filename
function myRecording = recordsound(Fs, filename, IOID)
recObj = audiorecorder(Fs, 16, 1, IOID); % the internal mic is at id 2
disp('Start speaking.')
recordblocking(recObj, 1);
disp('End of Recording.');
% Play back the recording.
play(recObj);
% Store data in double-precision array.
myRecording = getaudiodata(recObj);
% Plot the waveform.
plot(myRecording);
% Write to file
wavwrite(filename,myRecording, Fs);
end