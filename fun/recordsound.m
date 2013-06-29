% Record sound for 1 second from IOID device at Fs sampling freq, store in
% filename
function myRecording = recordsound(Fs, filename, IOID)
recObj = audiorecorder(Fs, 16, 1, IOID); % the internal mic is at id 2
% line in at 1
pause(1);
disp('Start speaking.')
recordblocking(recObj, 2);
disp('End of Recording.');
% Store data in double-precision array.
myRecording = getaudiodata(recObj);
% Plot the waveform.
% Play back the recording.
playObj = audioplayer(myRecording, Fs);
playblocking(playObj);
plot(myRecording);
% Write to file
wavwrite(myRecording, Fs, filename);
end