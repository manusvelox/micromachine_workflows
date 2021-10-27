

addpath(genpath('C:\Users\KenneyUsers\Documents\GitHub\micromachine_workflows'));
fs = 10E6;


savedata.settings.sampleTime_speced = 2^12/fs;
savedata.settings.sampleRate_speced =  fs;




%% setup instruments



setADC.channels             = 'CH_AB';        
setADC.triggerOutDelay      = 0; %[fraction of total sample time]
setADC.samplesPerBuffer      = 204800*100;%Low[samples per channel per buffer]
setADC.timeoutForceTrigger   = 0;
setADC.timeoutCapture         = 10;%[seconds until buffer capture canceled]
setADC.fileName          = 'homodyne_fft_capture_temp.bin';   
setADC.sampleRate  = savedata.settings.sampleRate_speced;
setADC.sampleTime  = savedata.settings.sampleTime_speced; 
savedata.settings.setADC = setADC;

%% read one

setADC_ret = runDataCapture(setADC);
savedata.settings.sampleRate_actual = setADC_ret.sampleRate;
savedata.settings.sampleTime_actual = setADC_ret.sampleTime;


[ CHA, CHB ] = readDualChannelDaqData( setADC_ret.fileName );
dt = 1/setADC_ret.sampleRate;
t = linspace(0,dt*length(CHA),length(CHA));

figure(100);clf;plot(t,CHA)
figure(101);clf;plot(t,CHB)
pause(.2)
