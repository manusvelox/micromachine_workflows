clc;
clear savedata;
close all;

filename = '11_14_thermal_squeeze_10hzBW_5min_50mv_ffixed';

mkdir(filename)

%% parameters

output_range=.1 ;%This can be 0.01, 0.1, 1, or 10 V

V_pump = [0 0 0 linspace(0,50E-3,51)];
f_n_initial = 108.899E3;

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

demod_rate=14.1 ;%samples per second

filter_BW=10.1 ; %Vary the phase detector bandwidth

Poll_Time=10*60 ;%Seconds

PauseTime=5 ;%s, time after changing current before starting sweep

Idc = 0;
Vb_device = 20;
Vb_drive = 0;


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

%%
%Initial biasing and current:
%Make sure to have Output 2 going to bias the drive electrode through a
%bias Tee, and output 1 to
kpib('HP_E3632A',10,'setV',Vb_device,1); %Set bias to device electrode (through bias Tee)
kpib('HP_E3632A',10,'read',1);

kpib('HP_E3647A',11,'setV',Vb_drive,1); %Set bias to drive electrode (through bias Tee)
kpib('HP_E3647A',11,'read',1);

kpib('HP_E3634A',5,'setI',Idc,1); %Set current supply to 0. The supply won't let the voltage reach Ve_max because this is 0.
%kpib('HP_E3647A',5,'setV',Ve_max,1); %Sets the max voltage o the current source
kpib('HP_E3634A',5,'read',1);



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

%% setup plots

figure(1)
xlabel('Frequency (Hz)');
ylabel('SPD (Vrms/rtHz)');
hold on


figure(2)
xlabel('X, \muV')
ylabel('Y, \muV')
% xlim([-150 150]);
% ylim([-150 150]);
axis square
hold on

figure(3)
xlabel('V_{pump} \muV');
ylabel('normalized Variance ');
legend('minor','major');
hold on

figure(4)
xlabel('V_{pump} \muV');
ylabel('normalized squeezed axis Variance ');
hold on

figure(8)
xlabel('Frequency (Hz)');
ylabel('SPD (Vrms/rtHz)');
title('no pump fit');
hold on


figure(5)
xlabel('V_{pump} \muV');
ylabel('mag(Mu)');
hold on





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



%% sweeps
varx_r = 1;
vary_r = 1;

savedata.sample_rate=demod_rate ;
savedata.poll_time=Poll_Time ;
savedata.filter_BW=filter_BW ;
savedata.LPF_order=LPF_order;
savedata.V_pump=V_pump;
savedata.Vb_drive = Vb_drive;
savedata.Vb_device = Vb_device;
savedata.Idc = Idc;

%% find natural frequnecy with no pump

% spectrum_channel = 1;
% 
% %%Spectrum analyzer
% kpib('HP_89410A',17,'peaktrack','on',spectrum_channel);
% kpib('HP_89410A',17,'average','on');
% kpib('HP_89410A',17,'average','type','rms');
% kpib('HP_89410A',17,'average',Naverages_0);
% kpib('HP_89410A',17,'autoscale');
% kpib('HP_89410A',17,'center',f_n);
% kpib('HP_89410A',17,'span',spectrum_width);
% 
% 
% kpib('HP_89410A',17,'restart');
% kpib('HP_89410A',17,'average','wait')
% kpib('HP_89410A',17,'autoscale');
% peak = kpib('HP_89410A',17,'marker?');
% spectrum = kpib('HP_89410A',17,'getdata',1);

%%
% x = transpose(spectrum.x);
% y = transpose(spectrum.y);
% 
% f1 = @(G,F,fn,Q,x) sqrt(G./(((2*pi*fn).^2-(2*pi*x).^2).^2 + (2*pi*x*2*pi*fn/Q).^2)+ F^2);
% 
% MSE = @(C) (1/length(x))*sum((f1(C(1),C(2),C(3),C(4),x)-y).^2);
% 
% %setup solver
% opts = optimset('MaxFunEvals',50000, 'MaxIter',10000);
% init = [1.3E5,0,1.089E5,9000];
% [C,fval] = fminsearch(@(C) 1E10*MSE(C), init, opts); 
% 
% 
% figure(8)
% plot(x,y)
% hold on
% plot(x,f1(C(1),C(2),C(3),C(4),x));
% 
% f_n = C(3);
% Q = C(4);
 savedata.f_n = f_n;
savedata.Q = Q;

%%
for i = 1:length(V_pump);
    
osc_flag = 0;
    
%Set pump and turn on
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' out_drive_c], 0); %Turn off drive channel
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/amplitudes/' out_pump_c], V_pump(i)/output_range); %Set parametric pump amplitude
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' out_pump_c], 1); %Turn on pump channel

spectrum_channel = 1;

%%Spectrum analyzer
kpib('HP_89410A',17,'peaktrack','on',spectrum_channel);
kpib('HP_89410A',17,'average','on');
kpib('HP_89410A',17,'average','type','rms');
kpib('HP_89410A',17,'average',Naverages);
kpib('HP_89410A',17,'autoscale');
kpib('HP_89410A',17,'center',f_n);
kpib('HP_89410A',17,'span',spectrum_width);


kpib('HP_89410A',17,'restart');
kpib('HP_89410A',17,'average','wait')
kpib('HP_89410A',17,'autoscale');
peak = kpib('HP_89410A',17,'marker?');
spectrum = kpib('HP_89410A',17,'getdata',1);

%f_n = peak.x;

% %save data
savedata.peak(i) = peak;
savedata.spectrum(i) = spectrum;


figure(1)
plot(spectrum.x,spectrum.y);
hold on;

%%

%ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' out_drive_c], 1); %Turn on drive channel
ziDAQ('setDouble',['/' device '/oscs/' demod_c '/freq'], f_n); %Hz, set drive on-resonance
ziDAQ('setDouble',['/' device '/demods/' demod_c '/rate'], demod_rate); %Set acquisition rate
ziDAQ('setInt',['/' device '/demods/*/order'], 1); %Set phase detector filter to be first order
ziDAQ('setDouble',['/' device '/demods/*/timeconstant'], 1/(2*pi*filter_BW)); %Set phase detector filter BW


%Acquire data
ziDAQ('unsubscribe','*');
ziDAQ('flush'); pause(1.0);
ziDAQ('subscribe',['/' device '/demods/' demod_c '/sample']);
data = ziDAQ('poll', Poll_Time, Poll_TimeOut ) ;
ziDAQ('unsubscribe','*');

%save data:
datapath=strcat('data.',device,'.demods.sample') ;
output.x = eval(strcat(datapath,'.x')) ;
output.y = eval(strcat(datapath,'.y')) ;
savedata.output(i) = output;

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




if V_pump(i) ==0
    varx_r = (varx+vary)/2;
    vary_r = (varx+vary)/2;
end

%save fit
savedata.mdl{i} = mdl;
savedata.var{i} = [varx, vary];

d = (mdl.mu(1) + mdl.mu(2)).^(1/2);
thresh = 1E-3;
if d > thresh    
    osc_flag = 1;
    minstr = 'r*';
    maxstr = 'ro';
    
    
else
    minstr = 'b*';
    maxstr = 'bo';
end


%plot
figure(2)
%t = max(max(X*1E6));
plot(X(:,1)*1E6,X(:,2)*1E6,'.');
%legend( strsplit(num2str(1000*V_pump(1:i))));
axis square
% xlim([-t t]);
% ylim([-t t]);
hold on


figure(3)
plot(V_pump(i)*1000,varx/varx_r,minstr,V_pump(i)*1000,vary/vary_r,maxstr);
legend('minor','major','location','southwest');
hold on

figure(4);
plot(V_pump(i)*1000,varx/varx_r,minstr);
hold on

figure(5)
plot(V_pump(i)*1000,sqrt(mdl.mu(1)^2+mdl.mu(2).^2),minstr);
hold on

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
figure(9+i)
t = max(max(Xr*1E6));
plot(Xr(:,1)*1E6,Xr(:,2)*1E6,'.');
axis square
xlim([-t t]);
ylim([-t t]);
xlabel('X, \muV')
ylabel('Y, \muV')
title(['Vpump = '  num2str(V_pump(i)*1000) 'mV']);



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

