clc; clear ; close all;
%sweep lames

filename='testtrace';
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

FS = 18;

%%
spec_name = 'HP_8560A';
spec_addr = 15;
savedata.drive_power = -10;

spectrum = kpib_NB(spec_name,spec_addr,'getdata',1);
savedata.freqs = spectrum.x;
savedata.S21_dBm = spectrum.y-savedata.drive_power;

figure(1)
plot(spectrum.x,savedata.S21_dBm)
xlabel('Frequency (Hz)');
ylabel('|S_{21}| (dBm');
prettyfig_NB('FS', FS)

saveas(1,[fullfilename,'_S21']); %Save Matlab figure in created folder
saveas(1,[fullfilename,'_S21'],'png'); %Save png in created folder

save([dirname, '\',filename ],'savedata');
