clc;
clear savedata;
close all;

filename='Paige_pump_detuning_test';
formatOut = 'dd-mmm-yyyy';
ds = datestr(datetime('now'),formatOut);
[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'data',ds,[ds, '_', filename]);
fullfilename=fullfile(dirname,[ds, '_', filename]);
mkdir(dirname);

data.notes = 'mPCBN6. setup with full elecs each side. AMP: LFSAV2 onboard';
data.device = 'HD16_PBL111_2_Die5_Ret10_400um_2elec';
data.startTime = datetime('now');
data.endTime = 'incomplete';


%% parameters


data.V_pump = 57E-3;
output_range = .1;
f_n_initial = 506.4E3;
data.biasV = 20;
data.df = -1*fliplr(0:10:100);

phase_2w=0 ;%Parametric pump phase

spectrum_width=200 ;%Hz, width of spectrum measurement around resonance
Naverages=1000;%Number of spectrum analyzer averages
Naverages_0 = 3000; %number of averages to determine pump freq

Poll_TimeOut=4000; %seconds
demod_c = '0'; %demod channel
in_c = '0';%input channel 1
out_c = '0' ;%output channel (0 is channel 1, 1 is channel 2)
out_drive_c='0' ;%Drive output demodulator
out_pump_c = '1' ;%Parametric pump output demodulator
PLL_c='0';%PLL 1
LPF_order=1 ;%use a first order low-pass filter for PLL phase detector

demod_rate=100 ;%samples per second

filter_BW=10.1 ; %Vary the phase detector bandwidth

Poll_Time=10*60 ;%Seconds

PauseTime=5 ;%s, time after changing current before starting sweep

%% spectrum settings

spectrumSpan1 = 5000;
RBW1 = spectrumSpan1/60;
numAve1 = 100;


spectrumSpan2 = 800;
RBW2 = 11;
numAve2 = 100;


Ch_single = 1;
Ch_diff = 2;

win_wide = 50;
win_narrow = 30;


%% Estimate time 

ts = 60; %spectrum sample time, seconds (guess)

t0 = datetime('now'); 
tr = seconds(length(V_pump)*(ts+Poll_Time));
t_end = t0 + tr;
[h, m, s] = hms(tr);


figure(9);
title('Estimated finish time');
text(0.2,0.7,datestr(t_end));
text(0.2,0.2,['time remaining: ', sprintf('%02d:%02d:%02d',[h m s])]);
set(gca,'YTick',[])
set(gca,'XTick',[])

%% Bias voltage

biasAddr = 5;
biasName = 'HP_E3634A';


%turn on bias
kpib(biasName,biasAddr,'setV',data.biasV(1),1);
pause(.5);
kpib(biasName,biasAddr,'read',1);



%% Lock in setup

clear ziDAQ;

% Check ziDAQ's ziAutoConnect (in the Utils/ subfolder) is in the path
if exist('ziAutoConnect','file') ~= 2
    fprintf('Please configure your path using the ziDAQ function ziAddPath().\n')
    fprintf('This can be found in the API subfolder of your LabOne installation.\n');
    fprintf('On Windows this is typically:\n');
    fprintf('C:\\Program Files\\Zurich Instruments\\LabOne\\API\\MATLAB2012\\\n');
    return
end

% open a connection to a Zurich Instruments server
if exist('port','var') && exist('api_level','var')
    ziAutoConnect(port, api_level);
elseif exist('port','var')
    ziAutoConnect(port);
else
    ziAutoConnect();
end

% get device name (e.g. 'dev234')
device = ziAutoDetect();

% get the device type and its options (in order to set correct device-specific
% configuration)
devtype = ziDAQ('getByte',[ '/' device '/features/devtype' ] );
options = ziDAQ('getByte',[ '/' device '/features/options' ] );



%%

f_n=f_n_initial ;

%turn all off, set range
ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/Enable'], 0); %Disable PLL
ziDAQ('setInt',['/' device '/sigouts/0/on'], 0); %Turn off channel 1 output
ziDAQ('setInt',['/' device '/sigouts/1/on'], 0); %Turn off channel 2 output
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' out_drive_c], 0); %Turn off drive channel
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' out_pump_c], 0); %Turn off pump channel
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/range'], output_range); %Set output range

%Parametric pump setup
ziDAQ('setDouble',['/' device '/oscs/0/freq'], f_n); %Hz, set oscillator 1 frequency
ziDAQ('setDouble',['/' device '/oscs/' demod_c '/freq'], f_n); %Hz, set oscillator 1 (pump) on-resonance

ziDAQ('setInt',['/' device '/sigouts/0/on'], 1); %Turn on channel 1 output
ziDAQ('setDouble',['/' device '/demods/' out_pump_c '/oscselect'], 0); %Use oscillator 1 for the parametric pump
ziDAQ('setInt',['/' device '/demods/' out_pump_c '/harmonic'], 2); %Set parametric pump harmonic to 2
ziDAQ('setDouble',['/' device '/demods/' out_pump_c '/phaseshift'], phase_2w); %Set parametric pump phase

ziDAQ('setDouble',['/' device '/demods/' demod_c '/rate'], demod_rate); %Set acquisition rate
ziDAQ('setInt',['/' device '/demods/*/order'], 1); %Set phase detector filter to be first order
ziDAQ('setDouble',['/' device '/demods/*/timeconstant'], 1/(2*pi*filter_BW)); %Set phase detector filter BW



%% sweeps
varx_r = 1;
vary_r = 1;

data.sample_rate=demod_rate ;
data.poll_time=Poll_Time ;
data.filter_BW=filter_BW ;
data.LPF_order=LPF_order;


%% find natural frequnecy with no pump

points = 1601;
%set resolution
kpib_NB('HP_89410A',spectrumAddr,'points',points)

%set averaging 
kpib_NB('HP_89410A',spectrumAddr,'average','on');
kpib_NB('HP_89410A',spectrumAddr,'center',f_n_initial);

kpib_NB('HP_89410A',spectrumAddr,'average','type','rms');

kpib_NB('HP_89410A',spectrumAddr,'span',spectrumSpan1)
kpib_NB('HP_89410A',spectrumAddr,'bandwidth',RBW1)
kpib_NB('HP_89410A',spectrumAddr,'average',numAve1);


%wait for ave
kpib_NB('HP_89410A',spectrumAddr,'restart');
pause(1);
kpib_NB('HP_89410A',spectrumAddr,'average','wait');


% pull data - diff
data.ASD_wide = kpib('HP_89410A',spectrumAddr,'getdata','xy',Ch_single);
minf = min(data.ASD_wide.x);
maxf = max(data.ASD_wide.x);

[f_n,A_n]  =  parabolic_peak_correct(data.ASD_wide.x,data.ASD_wide.y,win_wide,inf);
kpib_NB('HP_89410A',spectrumAddr,'center',f_n)

figure(201)
plot(data.ASD_wide.x*1E-3,data.ASD_wide.y*1E6,'-')
xlabel('Frequency (kHz)');
ylabel('ASD (uVrms/rtHz)');
hold on 
plot(f_n*1E-3,A_n*1E6,'r*');
title('Initial Spectrum');
xlim([minf maxf]*1e-3)





%% pull data - narrow

kpib_NB('HP_89410A',spectrumAddr,'span',spectrumSpan2)
kpib_NB('HP_89410A',spectrumAddr,'bandwidth',RBW2)
kpib_NB('HP_89410A',spectrumAddr,'average',numAve2);

%wait for ave
kpib_NB('HP_89410A',spectrumAddr,'restart');
pause(1);
kpib_NB('HP_89410A',spectrumAddr,'average','wait');




data.ASD_narrow = kpib('HP_89410A',spectrumAddr,'getdata','xy',Ch_single);
minf = min(data.ASD_narrow.x);
maxf = max(data.ASD_narrow.x);

[f_n,A_n]  =  parabolic_peak_correct(data.ASD_narrow.x,data.ASD_narrow.y,win_narrow,inf);
kpib_NB('HP_89410A',spectrumAddr,'center',f_n)

figure(202)
plot(data.ASD_narrow.x*1E-3,data.ASD_narrow.y*1E6,'-')
xlabel('Frequency (kHz)');
ylabel('ASD (uVrms/rtHz)');
hold on 
plot(f_n*1E-3,A_n*1E6,'r*');
title('Initial Spectrum - narrow');
xlim([minf maxf]*1e-3)

data.f_init = f_n;



%%
for i = 1:length(data.df)
    
osc_flag = 0;
    
%Set pump and turn on

ziDAQ('setDouble',['/' device '/oscs/' demod_c '/freq'], f_n + data.df(i)); %Hz, set drive on-resonance
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' out_drive_c], 0); %Turn off drive channel
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/amplitudes/' out_pump_c], V_pump/output_range); %Set parametric pump amplitude
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' out_pump_c], 1); %Turn on pump channel



%%Spectrum analyzer
kpib_NB('HP_89410A',spectrumAddr,'span',spectrumSpan2)
kpib_NB('HP_89410A',spectrumAddr,'bandwidth',RBW2)
kpib_NB('HP_89410A',spectrumAddr,'average',numAve2);

%wait for ave
kpib_NB('HP_89410A',spectrumAddr,'restart');
pause(1);
kpib_NB('HP_89410A',spectrumAddr,'average','wait');

data.ASD{i} = kpib('HP_89410A',spectrumAddr,'getdata','xy',Ch_single);
minf = min(data.ASD{i}.x);
maxf = max(data.ASD{i}.x);

[f_n,A_n]  =  parabolic_peak_correct(data.ASD{i}.x,data.ASD{i}.y,win_narrow,inf);

figure(300+i)
plot(data.ASD{i}.x*1E-3,data.ASD{i}.y*1E6,'-')
xlabel('Frequency (kHz)');
ylabel('ASD (uVrms/rtHz)');
hold on 
plot(f_n*1E-3,A_n*1E6,'r*');
title('Initial Spectrum - narrow');
xlim([minf maxf]*1e-3)

data.f_n(i) = f_n;


%% collect scatter

%Acquire data
ziDAQ('unsubscribe','*');
ziDAQ('flush'); pause(1.0);
ziDAQ('subscribe',['/' device '/demods/' demod_c '/sample']);
outdata = ziDAQ('poll', Poll_Time, Poll_TimeOut ) ;
ziDAQ('unsubscribe','*');

%save data:
datapath=strcat('outdata.',device,'.demods.sample') ;
output.x = eval(strcat(datapath,'.x')) ;
output.y = eval(strcat(datapath,'.y')) ;
data.output(i) = output;

%fit to PDF
X =[output.x', output.y'];
mdl = fitgmdist(X,1);
mu = mdl.mu;
sig = mdl.Sigma;
[V,L] = eig(sig);
L = [L(1,1),L(2,2)];

[val,I] = min(L);
sdir = V(:,I);
l1 = sdir(1);
l2 = sdir(2);
l3 = sqrt(l1^2+l2^2);
R = [l1/l3 l2/l3; -1*l2/l3 l1/l3];
Xr = transpose(R*(X'-repmat(mu',1,length(X))));
sigr = R*sig*R';
varx = sigr(1,1);
vary = sigr(2,2);


%save fit
data.mdl{i} = mdl;
data.var{i} = [varx, vary];

d = (mdl.mu(1) + mdl.mu(2)).^(1/2);


figure(99)
subplot(1,2,1)
hold on
plot(df(i),d,'b*')
xlabel('df')
ylabel('mag')
subplot(1,2,2)
hold on
plot(df(i),varx,'b*')
plot(df(i),vary,'bo')
xlabel('df')
ylabel('var')


%plot
figure(301+i)
hold on
title(['df = ' num2str(df(i))]);
plot(X(:,1)*1E6,X(:,2)*1E6,'.');
axis square
t = max(max(X*1E6));
xlim([-t t]);
ylim([-t t]);


figure(9);
ti = datetime('now');
t_since_start = ti-t0;
t_persample = t_since_start/i;
tr = (length(V_pump)-i)*t_persample;
t_end = ti + tr;
[h, m, s] = hms(tr);
clf(figure(9))
title('Estimated finish time');
text(0.2,0.7,datestr(t_end));
text(0.2,0.2,['time remaining: ', sprintf('%02.f:%02.f:%02.f',[h m s])]);
set(gca,'YTick',[])
set(gca,'XTick',[])


%plot
figure(302+i)
hold on
title(['df = ' num2str(df(i))]);
t = max(max(Xr*1E6));
plot(Xr(:,1)*1E6,Xr(:,2)*1E6,'.');
axis square
xlim([-t t]);
ylim([-t t]);
xlabel('X, \muV')
ylabel('Y, \muV')



end

%% turn off

ziDAQ('setInt',['/' device '/sigouts/0/on'], 0); %Turn off channel 1 output
ziDAQ('setInt',['/' device '/sigouts/1/on'], 0); %Turn off channel 2 output
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' out_drive_c], 0); %Turn off drive channel
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' out_pump_c], 0); %Turn off pump channel
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/range'], output_range); %Set output range




%%

fullfilename=fullfile(filename,filename);
save([filename,'\',filename,'.mat'],'savedata'); %Save data set

saveas(1,[fullfilename,'_spectrums']); %Save Matlab figure in created folder
saveas(1,[fullfilename,'_spectrums'],'png'); %Save png in created folder


saveas(2,[fullfilename,'scatters']); %Save Matlab figure in created folder
saveas(2,[fullfilename,'scatters'],'png'); %Save png in created folder


saveas(3,[fullfilename,'_axis_variance']); %Save Matlab figure in created folder
saveas(3,[fullfilename,'_axis_variance'],'png'); %Save png in created folder

