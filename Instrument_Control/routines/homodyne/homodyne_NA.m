%% homodyne_NA.m

% Nicholas Bousse
% June 17, 2021


% uses the Irwin lab NIST QSP homodyne box to make a network anaylyzer
% using the HP8560A tracking generatopr as a source

clc; clear ; close all;

addpath(genpath('C:\Users\KenneyUsers\Documents\GitHub\micromachine_workflows'));

filename='test_NA';
formatOut = 'dd-mmm-yyyy';
ds = datestr(datetime('now'),formatOut);
[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'data',ds,[ds, '_', filename]);
fullfilename=fullfile(dirname,[ds, '_', filename]);
mkdir(dirname);

savedata.notes = '';
savedata.device = '';
savedata.startTime = datetime('now');
savedata.endTime = 'incomplete';

%% measurment conditions

savedata.freqs = logspace(log10(.5E9),log10(1.6E9),1000);
savedata.settings.cycles_samples = 1000;
savadata.settings.oversample_factor = 20;
savedata.settings.variable_sample_rate = 0;

savedata.settings.sampleTime_speced = .01 * ones(size(savedata.freqs));
savedata.settings.sampleRate_speced =  1E6 * ones(size(savedata.freqs));

% if savedata.settings.variable_sample_rate
%     savedata.settings.sampleTime_speced = 1./savedata.freqs .* savedata.settings.cycles_samples;
%     savedata.settings.sampleRate_speced = savedata.freqs .*savadata.settings.oversample_factor;
% else %use the sample rate and time from the first frequency
%     savedata.settings.sampleTime_speced = ones(size(savedata.freqs)).*1./savedata.freqs(1) .* savedata.settings.cycles_samples;
%     savedata.settings.sampleRate_speced = ones(size(savedata.freqs)).*savedata.freqs(1) .*savadata.settings.oversample_factor;
% end
%     

%% setup instruments

source_addr = 15;
source_name = 'HP_8560A';
kpib_NB(source_name,source_addr,'span',0);pause(.5)
kpib_NB(source_name,source_addr,'source','OFF');pause(.5)
kpib_NB(source_name,source_addr,'source',2.8);pause(.5)
kpib_NB(source_name,source_addr,'center',savedata.freqs(1));pause(.5)


setADC.channels             = 'CH_AB';        
setADC.triggerOutDelay      = 0; %[fraction of total sample time]
setADC.samplesPerBuffer      = 10*4096;%Low[samples per channel per buffer]
setADC.timeoutForceTrigger   = 0;
setADC.timeoutCapture         = 10;%[seconds until buffer capture canceled]
setADC.fileName          = 'homodyne_capture_temp.bin';   


%% calibrate with source off

%setup aquisition
setADC.sampleRate  = savedata.settings.sampleRate_speced(1);
setADC.sampleTime  = savedata.settings.sampleTime_speced(1); 

%aquire
setADC_ret = runDataCapture(setADC);


[ I, Q ] = readDualChannelDaqData( setADC_ret.fileName );
dt = 1/setADC_ret.sampleRate;
t = linspace(0,dt*length(I),length(Q));
savedata.I_offset = mean(I);
savedata.Q_offset = mean(Q);





%% sweep

%turn on source
kpib_NB(source_name,source_addr,'source','ON');pause(.5)

for ii = 1:length(savedata.freqs)
    
    %set source to measurement freq
    kpib_NB(source_name,source_addr,'center',savedata.freqs(ii),1,1,0);pause(.1);
    
    %setup aquisition
    setADC.sampleRate  = savedata.settings.sampleRate_speced(ii);
    setADC.sampleTime  = savedata.settings.sampleTime_speced(ii); 
    
    %aquire
    setADC_ret = runDataCapture(setADC);
    
    savedata.settings.sampleRate_actual(ii) = setADC_ret.sampleRate;
    savedata.settings.sampleTime_actual(ii) = setADC_ret.sampleTime;
   
    
    [ I, Q ] = readDualChannelDaqData( setADC_ret.fileName );
    clc;
    disp(ii)
    dt = 1/setADC_ret.sampleRate;
    t = linspace(0,dt*length(I),length(Q));
    I_mean = mean(I)-savedata.I_offset;
    Q_mean = mean(Q)-savedata.Q_offset;

    
    savedata.I_mean(ii) = I_mean;
    savedata.Q_mean(ii) = Q_mean;
    savedata.amp(ii) = sqrt(I_mean.^2 + Q_mean.^2);
    savedata.phase(ii) = atan2(Q_mean,I_mean);
    
    figure(1)
    subplot(2,1,1)
    loglog(savedata.freqs(ii),savedata.amp(ii) ,'b*');hold on
    xlabel('freq');
    ylabel('amp');
    subplot(2,1,2)
    semilogx(savedata.freqs(ii),savedata.phase(ii) ,'b*'); hold on
    xlabel('freq');
    ylabel('phase');
    
    
    
    
    
end
%%



kpib_NB(source_name,source_addr,'source','OFF');pause(.5)


P = polyfit(savedata.freqs,unwrap(savedata.phase),1);
savedata.phaseNoLin = unwrap(savedata.phase) - polyval(P,savedata.freqs);


figure(1);clf
subplot(2,1,1)
loglog(savedata.freqs,savedata.amp ,'.');hold on
xlabel('frequency (Hz)');
ylabel('amplitude (V)');
prettyfig_NB
subplot(2,1,2)
semilogx(savedata.freqs,savedata.phase ,'.'); hold on
prettyfig_NB
xlabel('frequency (Hz)');
ylabel('phase (rad)');

figure(2);clf
subplot(2,1,1)
loglog(savedata.freqs,savedata.amp ,'.');hold on
xlabel('frequency (Hz)');
ylabel('amplitude (V)');
prettyfig_NB
subplot(2,1,2)
semilogx(savedata.freqs,savedata.phaseNoLin ,'.'); hold on
prettyfig_NB
xlabel('frequency (Hz)');
ylabel('phase (rad)');
    


