clc; clear all; close all;
%Automated PLL frequency, phase, and magnitude asynchronous measurement
%with post-processing

%%
%To use this code, first connect the channel 1 output of the Zurich to the
%drive, and connect the output from the device amplifier to channel 1 input
%Measure the Q, resonant frequency, and phase on resonance and enter below
%This code takes about an hour to measure and process ADEV

%%
%Change the following parameters for your device! After these are changed,
%you can run the code. Make sure the sweeper is not on prior to running.
%filename='DeviceName'
filename='12_15_19_ADEV_Vb4V_robbins_Vd_sweep_2';
formatOut = 'dd-mmm-yyyy';
ds = datestr(datetime('now'),formatOut);
[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'data',ds,filename);
fullfilename=fullfile(dirname,filename);
mkdir(dirname);


%%


savedata.notes = 'mPCBN6. setup with full elecs each side. AMP: LFSAV2 onboard';
savedata.device = 'HD16_PBL111_1_Die6_Ret1_600um_6um_100';
savedata.startTime = datetime('now');
savedata.endTime = 'incomplete';

savedata.Tset = 25;
blueoven('set',savedata.Tset,6)
savedata.biasV = 4;
% V2 = 67E-3;

% Vd_max = V2/savedata.biasV;
% n_d = 7;
% V_drive = logspace(log10(Vd_max)-3,log10(Vd_max),n_d);
% 
% V2 = 67E-3;

Vd_min = 1E-6;
Vd_max = 1.5E-3;
% n_d = 7;
% V_drive = logspace(log10(Vd_min),log10(Vd_max),n_d);
V_drive = 1E-3*[.001 .002 .005 .010 .020 .050 .1 .2 .5 1 1.5];


f_n=124.6095e3 ; %Hz, resonant frequency
PLL_Phase_SetPoint=  -178.4155  ;%deg, phase setpoint of PLL
Q=8.1668e3 ; %Measured device Q from phase-slope for setting proportional gain
%Q = 4E3;

%%
LPF_order=1 ;%use a first order low-pass filter for PLL phase detector
filter_BW=3.3E3; %
PLL_tc = 1./2./pi./filter_BW; %159.1u = 1k@1st order
PLL_FreqRange=3e3;%Hz, freq range of PLL

Poll_Time=60; %seconds
Poll_TimeOut=2*Poll_Time; %seconds


%% PLL settings

demod_c = '0'; %demod channel
in_c = '0' ;%input channel 1
out_c = '0' ;%output channel (0 is channel 1, 1 is channel 2)
out_drive_c='0' ;%Drive output demodulator
out_pump_c = '1' ;%Parametric pump output demodulator
PLL_c='0';%PLL 1

%demod_rate=115e3 ;%samples per second
%demod_rate=7.2e3 ;%samples per second
%demod_rate=14.4e3 ;%samples per second
%demod_rate = 115.1E3;
%demod_rate = 3.598E3;
demod_rate = 1.799E3;
%%

savedata.PLLparams.PLL_tc = PLL_tc;
savedata.PLLparams.PLL_filter_order= LPF_order;
savedata.PLLparams.poll_time= Poll_Time;
savedata.PLLparams.demod_rate= demod_rate;
savedata.V_drive = V_drive;
savedata.PLL_Phase_SetPoint =PLL_Phase_SetPoint;





%%
% noiseAddr = 19;
% noiseName = 'HP_33120A';
% divider = 10^(30/20);
% %turn on noise source
% kpib(noiseName,noiseAddr,'noise',1,savedata.noiseamp*divider,'VPP',1);
% pause(.5);
% kpib(noiseName,noiseAddr,'read',1);

biasAddr = 5;
biasName = 'HP_E3634A';
% turn on bias
kpib(biasName,biasAddr,'setV',savedata.biasV,1);
pause(.5);
kpib(biasName,biasAddr,'read',1);

spectrumAddr = 17;
specCh = 1;

points = 1601;


spectrumSpan1 = 800;
RBW1 = spectrumSpan1/60;
numAve1 = 500;

Ch_single = 1;

n_samples = 5;
spectrumSpan2 = 500;
RBW2 = 7.5;
numAve2 = 50;

win_wide = 80;
win_narrow = 100;




%%
%Initialize lock-in
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

%% get noise floor


ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' demod_c], 0); %Turn off signal output amp 1
kpib_NB('HP_89410A',spectrumAddr,'average','on');
kpib_NB('HP_89410A',spectrumAddr,'average','type','rms');
kpib_NB('HP_89410A',spectrumAddr,'center',f_n) 
kpib_NB('HP_89410A',spectrumAddr,'points',points)

% %setup wide spectrum
% kpib_NB('HP_89410A',spectrumAddr,'span',spectrumSpan1)
% kpib_NB('HP_89410A',spectrumAddr,'bandwidth',RBW1)
% kpib_NB('HP_89410A',spectrumAddr,'average',numAve1);
% 
% %wait for ave
% kpib_NB('HP_89410A',spectrumAddr,'restart');
% pause(1);
% kpib_NB('HP_89410A',spectrumAddr,'average','wait');
% 
% 
% % pull data - wide
% savedata.ASD_wide = kpib('HP_89410A',spectrumAddr,'getdata','xy',Ch_single);
% minf = min(savedata.ASD_wide.x);
% maxf = max(savedata.ASD_wide.x);
% 
% 
% [f_n,A_n]  =  parabolic_peak_correct(savedata.ASD_wide.x,savedata.ASD_wide.y,win_wide,inf);
% 
% kpib_NB('HP_89410A',spectrumAddr,'center',f_n)
% savedata.peak_wide = f_n;
% 
% figure(200)
% plot(savedata.ASD_wide.x*1E-3,savedata.ASD_wide.y*1E6,'-')
% xlabel('frequency (kHz)');
% ylabel('ASD (uVrms/rtHz)');
% hold on 
% plot(f_n*1E-3,A_n*1E6,'r*');
% title('wide span');
% xlim([minf maxf]*1e-3)

% narrow spectrum
kpib_NB('HP_89410A',spectrumAddr,'center',f_n)
kpib_NB('HP_89410A',spectrumAddr,'span',spectrumSpan2)
kpib_NB('HP_89410A',spectrumAddr,'bandwidth',RBW2)
kpib_NB('HP_89410A',spectrumAddr,'average',numAve2);
    
df = spectrumSpan2/points;
lim = spectrumSpan2/2-75;
f_samples = transpose(-lim:df:lim);
y_sum = zeros(size(f_samples));

%throw away one:
%wait for ave
kpib_NB('HP_89410A',spectrumAddr,'restart');
pause(1);
kpib_NB('HP_89410A',spectrumAddr,'average','wait');

% pull data - single
spectrum = kpib('HP_89410A',spectrumAddr,'getdata','xy',Ch_single);
minf = min(spectrum.x);
maxf = max(spectrum.x);
[f_n,A_n]  =  parabolic_peak_correct(spectrum.x,spectrum.y,win_narrow,inf);
kpib_NB('HP_89410A',spectrumAddr,'center',f_n);


for m = 1:n_samples
    %wait for ave
    kpib_NB('HP_89410A',spectrumAddr,'restart');
    pause(1);
    kpib_NB('HP_89410A',spectrumAddr,'average','wait');


    % pull data - single
    spectrum = kpib('HP_89410A',spectrumAddr,'getdata','xy',Ch_single);
    minf = min(spectrum.x);
    maxf = max(spectrum.x);
    [f_n,A_n]  =  parabolic_peak_correct(spectrum.x,spectrum.y,win_narrow,inf);
    kpib_NB('HP_89410A',spectrumAddr,'center',f_n);
    savedata.ASD_narrow_subsampled.fn(m) = f_n;
    f_norm = spectrum.x-f_n;
    y_sampled = interp1(f_norm,spectrum.y,f_samples);
    y_sum = y_sum +y_sampled;

    savedata.ASD_narrow_subsampled.subspectrums{m} = spectrum;

    figure(400)
    plot(spectrum.x*1E-3,spectrum.y*1E6,'-')
    xlabel('frequency (kHz)');
    ylabel('ASD (uVrms/rtHz)');
    hold on 
    plot(f_n*1E-3,A_n*1E6,'r*');
    title('single narrow');
    xlim([minf maxf]*1e-3)

end


savedata.ASD_narrow_subsampled.fn_mean = mean(savedata.ASD_narrow_subsampled.fn);
savedata.ASD_narrow_subsampled.x = f_samples+mean(savedata.ASD_narrow_subsampled.fn);
savedata.ASD_narrow_subsampled.y = y_sum/n_samples;

figure(500)
plot(savedata.ASD_narrow_subsampled.x*1E-3,savedata.ASD_narrow_subsampled.y*1E6,'-','LineWidth',2)
xlabel('frequency (kHz)');
ylabel('ASD (uVrms/rtHz)');
hold on 
title('narrow averaged');
xlim(1E-3*[-lim+mean(savedata.ASD_narrow_subsampled.fn) lim+mean(savedata.ASD_narrow_subsampled.fn)])

%%

f_n = savedata.ASD_narrow_subsampled.fn_mean;
PLL_P=1/((2*Q/f_n)*(180/pi));%optimal PLL_P for resonator

%PLL_I=PLL_P/filter_BW ; %Choose this based on how high of frequency in the ADEV you wish to measure
PLL_I = 5;



%%
%Asynchronously measure x,y and freq

%Configure channel:
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' demod_c], 1); %Turn on signal output amp 1
ziDAQ('setInt',['/' device '/sigouts/' out_c '/on'], 1);

output_range=  outRangeFind(Vd_max);
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/range'], output_range); %set range of output
ziDAQ('setDouble',['/' device '/sigouts/' out_c '/amplitudes/' demod_c], Vd_max/output_range);

ziDAQ('setDouble',['/' device '/demods/' demod_c '/rate'], demod_rate); %set domodulation rate (fastest frequency measurements for ADEV)

%Configure PLL:
ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/ADCSELECT'], str2num(in_c)); %Set PLL input channel 1
ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/ORDER'], LPF_order); %Set low pass filter order
ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/TIMECONSTANT'], PLL_tc(1)); %Set low pass filter bandwidth
ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/FREQRANGE'], PLL_FreqRange); %Set freq range of PLL
ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/P'], PLL_P); %Set proportional gain of PLL
ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/I'], PLL_I); %Set integral gain of PLL
ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/FREQCENTER'], f_n); %Set frequency center
ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/SETPOINT'], PLL_Phase_SetPoint); %Set phase setup of PLL in degrees


ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/Enable'], 1); %Enable PLL
pause(5);


%%
n_allan = length(V_drive);

hue = fliplr(linspace(.4,.8,n_allan));
FS = 12;

for i = 1:n_allan;

    fprintf('starting allan sample %.0f/%.0f, V_d = %.3fmV. %.2f min \n',i,n_allan,V_drive(i)*1000, Poll_Time/60);
    output_range=  outRangeFind(Vd_max);
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/range'], output_range); %set range of output
    pause(1);
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/amplitudes/' demod_c], Vd_max/output_range);
    pause(5);
    
    output_range = outRangeFind(V_drive(i));
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/range'], output_range); %set range of output
    pause(1);
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/amplitudes/' demod_c], V_drive(i)/output_range);
    pause(5);
    
    
    %% find integrated noise value
    
    %use thermomech peak value
    [f_n,A_n]  =  parabolic_peak_correct(savedata.ASD_narrow_subsampled.x ,savedata.ASD_narrow_subsampled.y,10,inf);
    minf = f_n - 2;
    maxf = f_n + 2;
    mask = find(savedata.ASD_narrow_subsampled.x > minf & savedata.ASD_narrow_subsampled.x < maxf);
    adevdata.sweep(i).Vn_mean = A_n;%,mean(savedata.ASD_narrow_subsampled.y(mask));
    
    figure(500+i)
    plot(savedata.ASD_narrow_subsampled.x*1E-3,savedata.ASD_narrow_subsampled.y*1E6,'-','LineWidth',2)
    xlabel('frequency (kHz)');
    ylabel('ASD (uVrms/rtHz)');
    hold on 
    title('narrow averaged');
    xlim(1E-3*[-lim+mean(savedata.ASD_narrow_subsampled.fn) lim+mean(savedata.ASD_narrow_subsampled.fn)])
    plot(savedata.ASD_narrow_subsampled.x(mask)*1E-3,savedata.ASD_narrow_subsampled.y(mask)*1E6,'r.')
    plot(savedata.ASD_narrow_subsampled.x(mask)*1E-3, adevdata.sweep(i).Vn_mean*ones(size(mask))*1E6)
    filename2=strcat([dirname, '\',filename '_noiseint', num2str(i)]);
    saveas(gcf,filename2,'png') %Save as PNG
        
    
    
    %% sample
    %Acquire data
    ziDAQ('unsubscribe','*');
    ziDAQ('flush'); pause(1.0);
    ziDAQ('subscribe',['/' device '/demods/' demod_c '/sample']);
    plldata = ziDAQ('poll', Poll_Time, Poll_TimeOut ) ;
    ziDAQ('unsubscribe','*');


    %save data:
    datapath=strcat('plldata.',device,'.demods.sample') ;

    savedata.PLLsample(i).sample_rate=demod_rate ;
    savedata.PLLsample(i).poll_time=Poll_Time ;
    savedata.PLLsample(i).drive=V_drive ;
    savedata.PLLsample(i).x=eval(strcat(datapath,'.x')) ;
    savedata.PLLsample(i).y=eval(strcat(datapath,'.y')) ;
    savedata.PLLsample(i).frequency=eval(strcat(datapath,'.frequency')) ;

    save([dirname, '\', filename '_FrequencyFluctuations'],'savedata') %Save each measurement into its own file

    %%
    %Process ADEV:
    t0 = datetime('now');
    fprintf('    processing....');

    ThermalTime=.7*10^-2;%Time to sample the thermal part of ADEV curve at

    allan_sample_time = savedata.PLLsample(i).poll_time ;
    data.rate = savedata.PLLsample(i).sample_rate ;
    %tau  = logspace(-5,2.25,200); %For 180 seconds of data
    tau  = logspace(-4,log10(Poll_Time)-0.1,200); %For X seconds of data


    

    data.freq = transpose(savedata.PLLsample(i).frequency) ; %Make sure the frequency input to allan2 is a column vector
    f1ref=savedata.PLLsample(i).frequency(2) ;
    R_average=mean(sqrt(savedata.PLLsample(i).x(1:10000).^2+savedata.PLLsample(i).y(1:10000).^2)) ;

    ADEV = allan2(data,tau);

    ki=1;
    ADEVxlast=0;
    for k=1:length(ADEV.tau1) %Throw out repeated ADEV values.
        if ADEV.tau1(k)>=0
            if ADEV.tau1(k) ~= ADEVxlast
            ADEVx(ki)=ADEV.tau1(k) ; %3D array to store ADEVx
            ADEVxlast=ADEV.tau1(k) ;
            ADEVy(ki)=ADEV.sig2(k)/f1ref ; %3D array to store ADEVy
            ki=ki+1;
            else
            end
        else
        end
    end 

%%

    label{i} = sprintf('Vdrive  = %.3f mV', 1000*V_drive(i));
    f = figure(1);
    f.Position = [250 137 966 636];
    handle(i) = loglog(ADEVx(:),ADEVy(:),'Color',[.2 hue(i),.2]);
    hold on
    legend(handle,label,'Location','Southwest')
    title(sprintf('int peak, BW = %.0f ',filter_BW))
    

    

    %%Pick point along thermal noise:
    ADEV_thermal=interp1(ADEVx(:),ADEVy(:),ThermalTime,'spline');
    loglog(ThermalTime,ADEV_thermal,'k*','HandleVisibility','off'); %plot on ADEV plot

    %%Find minimum ADEV in 1/f regime
    ptp=find(ADEVx(:) < 10) ;%s, to avoid picking an ADEV from the drift regime
    [minADEVy,I]=min(ADEVy(ptp)); %Find minimum ADEV value and index
    minADEVx=ADEVx(I) ;

    hold on
    loglog(minADEVx,minADEVy,'ko','HandleVisibility','off'); %plot on ADEV plot
    
    robbins = 1./2/Q*adevdata.sweep(i).Vn_mean./R_average*sqrt(1./(2*pi*tau));
    loglog(tau,robbins,'k--','HandleVisibility','off');
    

    %Save ADEV results:
    ylabel('Allan Deviation')
    xlabel('Integration time, seconds')
    set(gca,'FontSize',FS) %Change axes value text size
    set(findall(gcf,'type','text'),'FontSize',FS) %Change all other text size
    set(findall(gca, 'Type', 'Line'),'LineWidth',2); %Change line width
    set(findall(gca, '-Property', 'FontName'), 'FontName', 'Times New Roman');

    
    filename2=strcat([dirname, '\',filename '_ADEVplot']);
    saveas(gcf,filename2,'png') %Save as PNG
    
    
    adevdata.sweep(i).R_average = R_average;
    adevdata.sweep(i).ADEVx = ADEVx;
    adevdata.sweep(i).ADEVy = ADEVy;
    adevdata.sweep(i).ThermalTime = ThermalTime;
    adevdata.sweep(i).ADEV_thermal = ADEV_thermal;
    adevdata.sweep(i).minADEVx = minADEVx;
    adevdata.sweep(i).minADEVy = minADEVy;
    adevdata.sweep(i).PLL_I = PLL_I;
    adevdata.sweep(i).PLL_P = PLL_P;
    adevdata.sweep(i).filter_BW = filter_BW;
    adevdata.sweep(i).V_drive = V_drive(i);
    
    save([dirname, '\',filename '_ADEV'],'adevdata');
    
    fprintf('finished %.2f min elapsed\n', minutes(datetime('now')-t0));
    
    
end

%%
%Turn off direct current and Zurich outputs
ziDAQ('setInt',['/' device '/sigouts/*/on'], 0); %turn off output
kpib('HP_E3634A',5,'setV',0,1); %Set bias to device electrode (through bias Tee)
pause(.1)
kpib('HP_E3634A',5,'read',1);
