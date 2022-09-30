%% setup
clear all;clc; close all force;

addpath(genpath('C:\Users\KenneyUsers\Documents\GitHub\micromachine_workflows'));

filename='400mVrms_100pulses_saveall';
formatOut = 'dd-mmm-yyyy';
ds = datestr(datetime('now'),formatOut);
[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'data',ds,[ds, '_', filename]);
fullfilename=fullfile(dirname,[ds, '_', filename]);
mkdir(dirname);

savedata.notes = 'clocks linked!';
savedata.device = 'HD16 PBL111_2 JMD6 Ret 6 N32 600umx 6um beam';

%% running flags

save_flag = 1;
plot_aquisitions = 0;
save_all_pulses = 1;

%% burst parameters
burstparams.freq = 118.849E3;
burstparams.Vrms = 400E-6;
burstparams.BurstPeriod = 700E-3;
burstparams.Npulse = 5;
burstparams.Npulse_total = 100;

burstparams.startEndBufferFrac = .1;

savedata.readDecimation = 100;
savedata.burstAtten = 40;
savedata.maxDacRetries = 5;


%% calc dependant params
burstparams.Ncyc = round(burstparams.BurstPeriod/2*burstparams.freq);
setADC.sampleTime  = (burstparams.Npulse + burstparams.startEndBufferFrac*2)*burstparams.BurstPeriod;
setADC.triggerDelay  = burstparams.BurstPeriod/2-burstparams.BurstPeriod*burstparams.startEndBufferFrac;


%% check inputs

if not(mod(burstparams.Npulse_total,burstparams.Npulse) == 0)
   error('%i pulse bursts does not fit in to %i total pulses',burstparams.Npulse,burstparams.Npulse_total)
end


%% setup burst generator
addr = 'USB0::0xF4EC::0x1102::SDG2XCAC6R0543::0::INSTR';
VISA_control_NB('SDG_2000X', addr,'reset');
VISA_control_NB('SDG_2000X', addr,'output','off',1);
VISA_control_NB('SDG_2000X', addr,'output','load','HIZ');


VISA_control_NB('SDG_2000X', addr,'burst','state',1 ,'ON');
VISA_control_NB('SDG_2000X', addr,'burst','mode',1 ,'NCYC');
VISA_control_NB('SDG_2000X', addr,'burst','trigger',1 ,'int');
VISA_control_NB('SDG_2000X', addr,'burst','TRMD',1 ,'RISE');


VISA_control_NB('SDG_2000X', addr,'burst','freq',1 ,burstparams.freq);
VISA_control_NB('SDG_2000X', addr,'burst','amp',1 ,burstparams.Vrms*sqrt(2)*4*10^(savedata.burstAtten/20));
VISA_control_NB('SDG_2000X', addr,'burst','time',1 ,burstparams.Ncyc);
VISA_control_NB('SDG_2000X', addr,'burst','period',1 ,burstparams.BurstPeriod);

%% Setup DAC

setADC.channels             = 'CH_AB';        
setADC.triggerOutDelay      = 0; %[fraction of total sample time]
setADC.samplesPerBuffer      = 10*4096*2;%Low[samples per channel per buffer]
setADC.triggerSource        = 'CH_B';
setADC.triggerDirection     = 'FALL';
setADC.triggerLevel         = 130;
setADC.timeoutForceTrigger   = 0;
setADC.timeoutCapture         = 10;%[seconds until buffer capture canceled]
setADC.fileName          = 'test_temp.bin';
setADC.sampleRate  = 300E6;
setADC.externalClock = 1;
savedata.sampleRateEffective = setADC.sampleRate/savedata.readDecimation;



%% aquire NPulse_total pulses in Npulse groups 
fprintf('Aquiring %i total pulses in %i pulse groups\n',burstparams.Npulse_total,burstparams.Npulse)

numAquisitions = round(burstparams.Npulse_total/burstparams.Npulse);
progressWinHandle = waitbar(0, ...
                        sprintf('Captured %i/%i streams',0,numAquisitions));
progressWinHandle.Position = [5.995862068965517e+02 2.507586206896552e+02 270 55.862068965517267];

%setup variables 
if save_all_pulses
    allPulseCell = {};
end
stackedPulseSum = 0;

%aquire in loop
for ii = 1:numAquisitions

fprintf('   Aquiring: %i/%i\n',ii,numAquisitions)

%turn on burst gen
VISA_control_NB('SDG_2000X', addr,'output','on',1);

%init capture flags
captureSuccess = 0;
dacReadFailures = 0;

% poll DAC and catch timeouts/errors and retry
while xor(~captureSuccess,dacReadFailures>=savedata.maxDacRetries)
try 
setADC_ret = runDataCapture_NB(setADC);
captureSuccess = 1;
catch 
dacReadFailures = dacReadFailures + 1;
captureSuccess = 0;
warning('%i DAC Read Failures. Retrying %i times before giving up',dacReadFailures,savedata.maxDacRetries)
end

end
if captureSuccess ==0
    error('DAC capture failed')
end

%turn off pulse gen
VISA_control_NB('SDG_2000X', addr,'output','off',1);

fprintf('processing...')

%read the data from the bin file
[ CHA, CHB ] = readDualChannelDaqDataDecimated( setADC_ret.fileName,savedata.readDecimation );

%% stack pulses
thresh = mean(CHB);
trig = CHB>thresh;

riseEdges = find(diff(trig) == 1);
% fallEdges = find(diff(trig) == -1);
sizes = diff([0,riseEdges-1,length(CHA)]);
pulseCell = mat2cell(CHA, 1, sizes);
pulseCell = pulseCell(2:end-1);

%sum all the pulses from this burst together
stackedPulseSumAquisition = stackPulses(pulseCell,1);

%sum with previous bursts
stackedPulseSum = stackedPulseSum + stackedPulseSumAquisition;

%save all the pulses in a cell if we want them
if save_all_pulses
    allPulseCell = horzcat(allPulseCell,pulseCell);
end


if plot_aquisitions
    figure(1000+ii)
    plot(CHA)
end

%update the progress bar
waitbar(ii/numAquisitions, ...
        progressWinHandle, ...
        sprintf('Captured %i/%i streams',ii,numAquisitions));

fprintf('complete!\n')

end

%delete our progress window
delete(progressWinHandle)
% find average of all pulses and clean up
stackedPulse = stackedPulseSum/burstparams.Npulse_total;
clear stackedPulseSum stackedPulseSumAquisition pulseCell trig CHA CHB

%find out time vector
dt = 1./savedata.sampleRateEffective;
t = 0:dt:dt*(length(stackedPulse)-1);

%plot our stacked pulse
figure(1);clf
plot(t,stackedPulse)
xlabel('t (s)')
ylabel('V_{out} (V)')
prettyfig_NB



%% save data
savedata.setADC_ret = setADC_ret;
savedata.setADC = setADC;
savedata.stackedPulse = stackedPulse;
savedata.t = t;
savedata.burstparams = burstparams;
savedata.endTime = datetime('now');

if save_all_pulses
    savedata.allPulseCell = allPulseCell;
end

if save_flag
    fprintf('saving...')
    saveas(1,[fullfilename '_stackedPulses'],'png') %Save as PNG
    saveas(1,[fullfilename '_stackedPulses']) %Save as PNG
    save(fullfilename,'savedata','-v7.3');
    fprintf('complete!\n')
end

