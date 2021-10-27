

%% savetrace_8753.m

% Nicholas Bousse
% June 17, 2021



clc; clear ; close all;

addpath(genpath('C:\Users\KenneyUsers\Documents\GitHub\micromachine_workflows'));

filename='microwave_readout_dev1_4V_-28dbm_homoV2_noatten_run2';
formatOut = 'dd-mmm-yyyy';
ds = datestr(datetime('now'),formatOut);
[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'data',ds,[ds, '_', filename]);
fullfilename=fullfile(dirname,[ds, '_', filename]);
mkdir(dirname);

savedata.notes = 'Q port amplified with ZKL-15R running on 12V';
savedata.device = 'device 1 with DYVI PBH-RR4 GDV D1 Ret4 springy 400um LAME ';

%%

savedata.Vdc = 10;
savedata.drivepower = -22;
savedata.IFBW = 10;


retval = kpib_NB('HP_8753ES',18,'getdata',1,1);pause(.1);
savedata.power = retval.y;
savedata.freq = retval.x;
retval = kpib_NB('HP_8753ES',18,'getdata',1, 2);pause(.1);
savedata.phase = retval.y;


f1 = figure(1);clf
subplot(2,1,1)
plot(savedata.freq,savedata.power,'.');
xlabel('Frequency (Hz)');
ylabel('Power (dBm)');
prettyfig_NB;
subplot(2,1,2)
plot(savedata.freq,unwrap(savedata.phase/180*pi)*180/pi,'.');
xlabel('Frequency (Hz)');
ylabel('Phase (deg)');
prettyfig_NB;

%%

saveas(1,[fullfilename '_amp_phase'],'png') %Save as PNG
saveas(1,[fullfilename '_amp_phase']) %Save as PNG

savedata.endTime = datetime('now');
save(fullfilename,'savedata');
