function fnInitSound()

disp('Initializing sound...');

SamplingFreq = 44100;
t = 0:1/SamplingFreq:1-1/SamplingFreq;
freq = 400; %Hz, frequency of the tone
ToneData = sin(2*pi*freq*t);

Channels = size(ToneData,1);          % Number of rows == number of channels.

% Performing a basic initialization of the sound driver
InitializePsychSound;

% Open the default audio device [], with default mode [] (==Only playback)
% A required latency class of zero 0 == no low-latency mode
% A frequency of freq and nrchannels sound channels.  This returns a handle to the audio device:
Handle = PsychPortAudio('Open', [], [], 0, SamplingFreq, Channels);

% Fill the audio playback buffer with the audio data
PsychPortAudio('FillBuffer', Handle, ToneData);

end