%% fft_dac_NB.m

% Nicholas Bousse
% July 8, 2021


% uses the Irwin lab NIST QSP homodyne box to make a network anaylyzer
% using the HP8560A tracking generatopr as a source


clc; clear ; close all;

addpath(genpath('C:\Users\KenneyUsers\Documents\GitHub\micromachine_workflows'));

filename='microwave_readout_fft_dev1_-22dBm_10V_50ave';
formatOut = 'dd-mmm-yyyy';
ds = datestr(datetime('now'),formatOut);
[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'data',ds,[ds, '_', filename]);
fullfilename=fullfile(dirname,[ds, '_', filename]);
mkdir(dirname);

savedata.notes = '';
savedata.device = 'device 1 with DYVI PBH-RR4 GDV D1 Ret4 springy 400um LAME ';


%% measurment conditions



fs = 50E6;


savedata.settings.sampleTime_speced = 2^26/fs;
savedata.settings.sampleRate_speced =  fs;
savedata.settings.numave =  50;


%% plot range
center = 1.008828667534722e+07;
span = 100000;



%% setup instruments



setADC.channels             = 'CH_AB';        
setADC.triggerOutDelay      = 0; %[fraction of total sample time]
setADC.samplesPerBuffer      = 204800*24;%Low[samples per channel per buffer]
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

overrange_flag = check_overrange([CHA;CHB],.4);

figure(1); clf;
subplot(2,1,1);
plot(t(1:20:end),CHA(1:20:end))
subplot(2,1,2)
plot(t(1:20:end),CHB(1:20:end))
pause(.2)



%% aquire 

POWA_sum = zeros(length(t)/2+1,1);
POWB_sum = zeros(length(t)/2+1,1);

for ii = 1:savedata.settings.numave
    
    disp(['ave ' num2str(ii)])
    
    pause(.2)
    disp('polling DAQ');
    setADC_ret = runDataCapture(setADC);
    savedata.settings.sampleRate_actual = setADC_ret.sampleRate;
    savedata.settings.sampleTime_actual = setADC_ret.sampleTime;

    disp('reading data');
    [ CHA, CHB ] = readDualChannelDaqData( setADC_ret.fileName );
    
    overrange_flag = check_overrange([CHA;CHB],.4);
    figure(1); clf;
    subplot(2,1,1);
    plot(t(1:20:end),CHA(1:20:end))
    subplot(2,1,2)
    plot(t(1:20:end),CHB(1:20:end))
    pause(.2)
    
    disp('performing fft');
    [freq, POWA_ii] = fft_NB2(hamming(length(CHA)).*CHA,setADC_ret.sampleRate);
%     [freq, POWB_ii] = fft_NB2(hamming(length(CHB)).*CHB,setADC_ret.sampleRate);
    
    
    POWA_sum = POWA_sum + POWA_ii;
%     POWB_sum = POWB_sum + POWB_ii;
    
    
    figure(2);clf;
    mask = and(freq> center-span/2 ,freq< center+span/2 );
    semilogy(freq(mask),POWA_sum(mask)./ii);
    xlabel('Frequency (Hz)');
    ylabel('PSD (V^2/Hz)');
    title(['averages: ' num2str(ii)]);
    prettyfig_NB('LW',1,'MS',1);

end


%%

savedata.POWA_ave = POWA_sum/savedata.settings.numave;
savedata.POWB_ave = POWB_sum/savedata.settings.numave;
savedata.freq = freq;







figure(2);clf;
mask = and(freq> center-span/2 ,freq< center+span/2 );
freq_trimmed = savedata.freq(mask);
semilogy(savedata.freq(mask),savedata.POWA_ave(mask));
xlabel('Frequency (Hz)');
ylabel('PSD (V^2/Hz)');
prettyfig_NB('LW',1,'MS',1);

[PKS,LOCS,W] = findpeaks(savedata.POWA_ave(mask),'WidthReference','halfheight','MinPeakProminence',1E-10);
peakfreq = freq_trimmed(LOCS);
hold on;plot(peakfreq,PKS,'r*');


%%

saveas(2,[fullfilename '_spectrum_zoom'],'png') %Save as PNG
saveas(2,[fullfilename '_spectrum_zoom']) %Save as PNG

savedata.savetime = datetime('now');
save(fullfilename,'savedata');




