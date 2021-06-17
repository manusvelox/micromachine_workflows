clc; clear ; close all;
%measure Allanm deviation in both a PLL and open loop.

filename='Chappy_ADEV_OL_SURF_10MRf1_ovenOff_BW1k_DriveLPF_NoSide_biasRInside';
formatOut = 'dd-mmm-yyyy';
ds = datestr(datetime('now'),formatOut);
[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'data',ds,[ds, '_', filename]);
fullfilename=fullfile(dirname,[ds, '_', filename]);
mkdir(dirname);

savedata.notes = 'mPCBN6. setup with full elecs each side. AMP: LFSAV2 onboard Rf1 = 10M Cf1 = 1pF ';
savedata.device = 'Chappy HD16_PBL111_2_Die6_Ret12_600um_6um_110';
savedata.startTime = datetime('now');
savedata.endTime = 'incomplete';

FS = 18;

%% estimated device parameters

f_n_0 = 122.78E3;
Q = 5E3;

g_est = 1.7E-6;
A_est = 600E-6*60E-6;
m_eff = 83E-12;
gamma_c = .5231;
eps_0=8.85e-12;

f_n_est =@(V) sqrt(f_n_0^2-((1./(2*pi)))^2.*2*gamma_c*eps_0*A_est.*V.^2/m_eff/g_est^3);

Vspan = linspace(0,20,200);
figure(10)
plot(Vspan,f_n_est(Vspan)*1E-3,'linewidth',2)
xlabel('V_b (V)')
ylabel('estimated f_n (kHz)');
grid on; box on


%% measurement conditions

savedata.Tset = 25;

savedata.Vb = linspace(1,20,5);


Vd_squared_min = 4E-6;
Vd_squared_max = 5E-3;
Vd_squared_lin = 5.0e-4;
n_d = 5%10;


Poll_Time=200; %seconds
Poll_TimeOut=2*Poll_Time; %seconds\

PLL_init_time = 10;

%% lock in settings

LPF_order=1;
filter_TC = 1.59154943E-4; % 1kHz at 1st order
demod_rate = 1.799E3;

%% PLL settings

PLL_FreqRange=1e3;%Hz, freq range of PLL

osc_c = '0'; %oscillator
demod_c = '0'; %demod channel
in_c = '0';%input channel 1
out_c = '0' ;%output channel (0 is channel 1, 1 is channel 2)
out_drive_c='0' ;%Drive output demodulator
out_pump_c = '1' ;%Parametric pump output demodulator
PLL_c='0';%PLL 1

PLL_P_init = 20;
PLL_I_init = 1E3;

savedata.PLLparams.filter_TC = filter_TC;
savedata.PLLparams.PLL_filter_order= LPF_order;
savedata.PLLparams.poll_time= Poll_Time;
savedata.PLLparams.demod_rate= demod_rate;

%% setup thermo

s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev2',0,'Thermocouple');
thermo = s.Channels(1);
thermo.ThermocoupleType = 'K';



%% spectrum analyzer parameters 
spectrumAddr = 17;
specCh = 1;

points = 1601;


spectrumSpan1 = 800;
RBW1 = 7.5;
numAve1 = 200;



spectrumSpan2 = 1000;
RBW2 = 10;
numAve2 = 100;

win_wide = 10;
win_narrow = 10;




%% connect to lock in 

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
clockbase = double(ziDAQ('getInt',['/' device '/clockbase']));

%% setup measurment config

%turn everything off
ziDAQ('setInt',['/' device '/sigouts/*/on'], 0);
ziDAQ('setDouble',['/' device '/sigouts/*/enables/*' ], 0);

%turn off offset and add
ziDAQ('setDouble', ['/' device '/sigouts/*/offset'], 0);
ziDAQ('setInt', ['/' device '/sigouts/*/add'], 0);

%setup inputs
ziDAQ('setInt', ['/' device '/sigins/*/diff'], 0);
ziDAQ('setInt', ['/' device '/sigins/*/ac'], 1);
ziDAQ('setInt', ['/' device '/sigins/*/imp50'], 0);

%turn demod harm to 1 and phase to 0
ziDAQ('setDouble', ['/' device '/demods/*/harmonic'], 1);
ziDAQ('setDouble', ['/' device '/demods/*/phaseshift'], 0);

%set demod to corrrect input
ziDAQ('setInt', ['/' device '/demods/' demod_c '/adcselect'], str2num(in_c));

%set demod to correct osc
ziDAQ('setInt', ['/' device '/demods/0/oscselect'], 0);

%turn on data transfer
ziDAQ('setInt', ['/' device '/demods/' demod_c '/enable'], 1);

%turn off PLLs
ziDAQ('setInt',['/' device '/PLLS/*/Enable'], 0);

%% setup bias voltage

biasAddr = 5;
biasName = 'HP_E3634A';
% turn on bias
kpib_NB(biasName,biasAddr,'setV',savedata.Vb(1),1);
kpib_NB(biasName,biasAddr,'on',1);
pause(.5);
kpib_NB(biasName,biasAddr,'read',1);

%% 

%%%%%%BEGIN BIAS VOLTAGE LOOP%%%%%%%%


for j = 1:length(savedata.Vb)
    
    savedata.Vbsweep{j}.V_drive = logspace(log10(Vd_squared_min/savedata.Vb(j)),log10(Vd_squared_max/savedata.Vb(j)),n_d);
    savedata.Vbsweep{j}.V_drive_lin = Vd_squared_lin/savedata.Vb(j);
    

    % turn on bias
    kpib_NB(biasName,biasAddr,'setV',savedata.Vb(j),1);
    kpib_NB(biasName,biasAddr,'on',1);
    pause(.5);
    kpib_NB(biasName,biasAddr,'read',1);

    %% perform course OL sweep to find peak

    f_n = f_n_est(savedata.Vb(j));
    
    output_range=  outRangeFind(savedata.Vbsweep{j}.V_drive_lin);
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/range'], output_range); %set range of output
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/amplitudes/' demod_c], savedata.Vbsweep{j}.V_drive_lin/output_range);
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' demod_c], 1); %Turn on signal output amp 1


    df = 10E3;
    startf = f_n-df/2;
    stopf = f_n+df/2;
    points = 800;
    quality = 'med';
    plotflag = 1;

    ziDAQ('setInt',['/' device '/sigouts/' out_c '/on'], 1);
    sweepdata = ziSweep(device,startf, stopf, points, quality, plotflag);
    ziDAQ('setInt',['/' device '/sigouts/' out_c '/on'], 0);

    [maxval, maxI] = max(sweepdata.r);
    f_n = sweepdata.frequency(maxI);

    %% fine local OL sweep

    output_range=  outRangeFind(savedata.Vbsweep{j}.V_drive_lin);
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/range'], output_range); %set range of output
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/amplitudes/' demod_c], savedata.Vbsweep{j}.V_drive_lin/output_range);
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' demod_c], 1); %Turn on signal output amp 1


    df = 200;
    startf = f_n-df/2;
    stopf = f_n+df/2;
    points = 600;
    quality = 'high';
    plotflag = 1;

    ziDAQ('setInt',['/' device '/sigouts/' out_c '/on'], 1);
    sweepdata = ziSweep(device,startf, stopf, points, quality, plotflag);
    ziDAQ('setInt',['/' device '/sigouts/' out_c '/on'], 0);


    R = sweepdata.r(~isnan(sweepdata.r));
    phase = sweepdata.phase(~isnan(sweepdata.phase));
    freq = sweepdata.frequency(~isnan(sweepdata.frequency));
    [f_n,A_n] = parabolic_peak_correct(freq,R,10,inf);
    phase_setpoint = 180/pi*interp1(freq,phase,f_n);



    % plot sweep
    f = figure(100+j);
    clf;
    f.Position = [242 183 871 562];
    subplot(2,1,1)
    hold on
    title(sprintf('V_b %.1fV: f_n = %.1f kHz, \\phi_{set} = %.1f deg',savedata.Vb(j),f_n*1E-3,phase_setpoint))
    ylabel('Amp (mV)')
    xlabel('freq (kHz)')
    set(gca,'FontSize',FS) %Change axes value text size
    set(findall(gcf,'type','text'),'FontSize',FS) %Change all other text size
    set(findall(gca, '-Property', 'FontName'), 'FontName', 'Times New Roman');
    subplot(2,1,2)
    hold on;box on
    xlabel('freq (kHz)')
    ylabel('phase (deg)');
    set(gca,'FontSize',FS) %Change axes value text size
    set(findall(gcf,'type','text'),'FontSize',FS) %Change all other text size
    set(findall(gca, '-Property', 'FontName'), 'FontName', 'Times New Roman');

    subplot(2,1,1)
    plot(freq*1E-3,1E3*R,'-','Linewidth',2);hold on;
    h = vline(f_n*1E-3);
    h.LineWidth = 2;
    grid on
    box on

    xlim([startf*1E-3 stopf*1E-3]);
    subplot(2,1,2)
    plot(freq*1E-3,180/pi*unwrap(phase),'-','Linewidth',2); hold on;
    h = vline(f_n*1E-3);
    h.LineWidth = 2;

    grid on;
    xlim([startf*1E-3 stopf*1E-3]);

    %save
    savedata.Vbsweep{j}.OL_sweep_fn = f_n;
    savedata.Vbsweep{j}.phase_setpoint = phase_setpoint;
    savedata.Vbsweep{j}.OL_sweep = sweepdata;
    saveas(gcf,[dirname, '\',filename '_OL_Vb_' num2str(j)],'png') %Save as PNG

    %% Analyze phase slope
    % find phase slope
    df_lin = 10;
    plotwindow = 4;
    mask = freq>(f_n - df_lin/2) &  freq<(f_n + df_lin/2);
    phase_lin = phase(mask);
    freq_lin = freq(mask);
    polymodel = polyfitn(freq_lin,phase_lin,{'constant', 'x'});
    fnspan = linspace(f_n - df_lin/2*plotwindow,f_n +df_lin/2*plotwindow,300);
    dphi_df = polymodel.Coefficients(2);
    Q_phase = abs(dphi_df/2*f_n);

    %plot phase slope
    figure(200+j)
    mask = freq>(f_n - df_lin/2*plotwindow) &  freq<(f_n + df_lin/2*plotwindow);
    plot(fnspan-f_n,polyvaln(polymodel,fnspan),'r-','linewidth',2);hold on;
    plot(freq(mask)-f_n,phase(mask),'b.','markersize',10);hold on;
    plot(freq_lin-f_n,phase_lin,'g.','markersize',10);hold on;
    title(['V_b = ' num2str(savedata.Vb(j)) 'V: Phase slope Q = ' num2str(Q_phase/1000) 'k']);
    box on
    grid on
    xlabel('df (Hz)')
    ylabel('phase (rad)')
    xlim([min(fnspan-f_n),max(fnspan-f_n)]);

    %save data
    savedata.Vbsweep{j}.Q_phase = Q_phase;
    savedata.Vbsweep{j}.dphi_df = dphi_df;
    saveas(gcf,[dirname, '\',filename '_phasesslope_Vb_' num2str(j)],'png') %Save as PNG

    %% Thermal spectrum


    kpib_NB('HP_89410A',spectrumAddr,'average','on');
    kpib_NB('HP_89410A',spectrumAddr,'average','type','rms');
    kpib_NB('HP_89410A',spectrumAddr,'center',savedata.Vbsweep{j}.OL_sweep_fn) ;
    kpib_NB('HP_89410A',spectrumAddr,'points',points);
    kpib_NB('HP_89410A',spectrumAddr,'span',spectrumSpan1);
    kpib_NB('HP_89410A',spectrumAddr,'bandwidth',RBW1);
    kpib_NB('HP_89410A',spectrumAddr,'average',numAve1);

    %wait for ave
    kpib_NB('HP_89410A',spectrumAddr,'restart');
    pause(1);
    kpib_NB('HP_89410A',spectrumAddr,'average','wait');

    % pull data - single
    spectrum = kpib_NB('HP_89410A',spectrumAddr,'getdata','xy',specCh);
    minf = min(spectrum.x);
    maxf = max(spectrum.x);
    [f_n,A_n]  =  parabolic_peak_correct(spectrum.x,spectrum.y,win_narrow,inf);

    savedata.Vbsweep{j}.thermal_ASD = spectrum;

    figure(300+j)
    plot(spectrum.x*1E-3,spectrum.y*1E6,'-','LineWidth',2);
    hold on; grid on; box on;
    xlabel('frequency (kHz)');
    ylabel('ASD (uVrms/rtHz)');
    title(['V_b = ' num2str(savedata.Vb(j)) 'V: Thermal Spectrum']);
    xlim(1E-3*[minf maxf]);
    plot(f_n*1E-3,A_n*1E6,'r*');

    saveas(gcf,[dirname, '\',filename '_thermalASD_Vb_' num2str(j)],'png') %Save as PNG

    %% setup PLL

    savedata.Vbsweep{j}.PLL_P=1/((2*savedata.Vbsweep{j}.Q_phase/savedata.Vbsweep{j}.OL_sweep_fn)*(180/pi));%optimal PLL_P for resonator
    savedata.Vbsweep{j}.PLL_I = 50;

    output_range=  outRangeFind(savedata.Vbsweep{j}.V_drive_lin);
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/range'], output_range); %set range of output
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/amplitudes/' demod_c], savedata.Vbsweep{j}.V_drive_lin/output_range);

    %turn on linear drive
    ziDAQ('setInt',['/' device '/sigouts/' out_c '/on'], 1);
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' demod_c], 1); %Turn on signal output amp 1



    %Configure PLL:
    ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/ADCSELECT'], str2num(in_c)); %Set PLL input channel 1
    ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/ORDER'], LPF_order); %Set low pass filter order
    ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/TIMECONSTANT'], filter_TC); %Set low pass filter bandwidth
    ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/FREQRANGE'], PLL_FreqRange); %Set freq range of PLL
    ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/P'], PLL_P_init); %Set proportional gain of PLL
    ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/I'], PLL_I_init); %Set integral gain of PLL
    ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/FREQCENTER'], savedata.Vbsweep{j}.OL_sweep_fn); %Set frequency center
    ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/SETPOINT'], savedata.Vbsweep{j}.phase_setpoint); %Set phase setup of PLL in degrees
    ziDAQ('setDouble', ['/' device '/oscs/' osc_c '/freq'], savedata.Vbsweep{j}.OL_sweep_fn);


    %setup demodulator 
    ziDAQ('setDouble', ['/' device '/demods/' demod_c '/timeconstant'], filter_TC);
    ziDAQ('setInt', ['/' device '/demods/' demod_c '/order'], LPF_order);
    ziDAQ('setDouble', ['/' device  '/demods/' demod_c '/rate'], savedata.PLLparams.demod_rate);


    ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/Enable'], 1); %Enable PLL


    %% setup plot


    f = figure(j);
    f.Position = [-39 180 966 636];
    grid on
    box on






    hue = fliplr(linspace(.4,.8,n_d));
    FS = 12;

    %% 

    %%% BEGIN V DRIVE LOOP AND ALLAN SAMPLES 





    for i = 1:n_d

        fprintf('V_b %.0f/%.0f: starting allan sample %.0f/%.0f, V_d = %.3fmV. %.2f min \n',j,length(savedata.Vb),i,n_d,savedata.Vbsweep{j}.V_drive(i)*1000, Poll_Time/60);
        fprintf('    Init PLL...\n')
        %turn on linear drive
        ziDAQ('setInt',['/' device '/sigouts/' out_c '/on'], 1);
        ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' demod_c], 1); %Turn on signal output amp 1
        %setablish with linear drive and better PLL
        output_range=  outRangeFind(savedata.Vbsweep{j}.V_drive_lin);
        ziDAQ('setDouble',['/' device '/sigouts/' out_c '/range'], output_range); %set range of output
        ziDAQ('setDouble',['/' device '/sigouts/' out_c '/amplitudes/' demod_c], savedata.Vbsweep{j}.V_drive_lin/output_range);
        ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/P'], PLL_P_init); %Set proportional gain of PLL
        ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/I'], PLL_I_init); %Set integral gain of PLL
        ziDAQ('setDouble', ['/' device '/oscs/' osc_c '/freq'], savedata.Vbsweep{j}.OL_sweep_fn);
        ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/Enable'], 1); %Enable PLL
        pause(5)

        %set drive level
        output_range=  outRangeFind(savedata.Vbsweep{j}.V_drive(i));
        ziDAQ('setDouble',['/' device '/sigouts/' out_c '/range'], output_range); %set range of output
        ziDAQ('setDouble',['/' device '/sigouts/' out_c '/amplitudes/' demod_c], savedata.Vbsweep{j}.V_drive(i)/output_range);
        pause(1);

        ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/P'], savedata.Vbsweep{j}.PLL_P); %Set proportional gain of PLL
        ziDAQ('setDouble',['/' device '/PLLS/' PLL_c '/I'], savedata.Vbsweep{j}.PLL_I); %Set integral gain of PLL
        pause(5);

        %% start spectrum

        %find center
        kpib_NB('HP_89410A',spectrumAddr,'span',spectrumSpan2)
        kpib_NB('HP_89410A',spectrumAddr,'bandwidth',RBW2)
        kpib_NB('HP_89410A',spectrumAddr,'average',numAve2);
        %wait for ave
        kpib_NB('HP_89410A',spectrumAddr,'restart');


        %% start PLL sample
        %Acquire data
        ziDAQ('unsubscribe','*');
        ziDAQ('flush'); pause(1.0);
        ziDAQ('subscribe',['/' device '/demods/' demod_c '/sample']);
        plldata = ziDAQ('poll', PLL_init_time, Poll_TimeOut ) ;
        ziDAQ('unsubscribe','*');   

        %save data:
        datapath=strcat('plldata.',device,'.demods.sample') ;
        savedata.Vbsweep{j}.PLLsample(i).drive=savedata.Vbsweep{j}.V_drive(i) ;
        savedata.Vbsweep{j}.PLLsample(i).x=eval(strcat(datapath,'.x')) ;
        savedata.Vbsweep{j}.PLLsample(i).y=eval(strcat(datapath,'.y')) ;
        savedata.Vbsweep{j}.PLLsample(i).frequency=eval(strcat(datapath,'.frequency'));
        savedata.Vbsweep{j}.PLLsample(i).phase=eval(strcat(datapath,'.phase'));


        %% pull spectrum

        kpib_NB('HP_89410A',spectrumAddr,'average','wait');

        % pull data - single
        spectrum = kpib_NB('HP_89410A',spectrumAddr,'getdata','xy',specCh);

        savedata.Vbsweep{j}.driven_ASD(i) = spectrum;
        [f_n,A_n]  =  parabolic_peak_correct(spectrum.x,spectrum.y,win_narrow,inf);
        kpib_NB('HP_89410A',spectrumAddr,'center',f_n)

        f = figure(400+10*j+i);
        f.Position = [879 314 560 420];
        semilogy((spectrum.x-f_n),spectrum.y*1E6,'-','LineWidth',2)
        xlabel('df (Hz)');
        ylabel('ASD (uVrms/rtHz)');
        hold on 
        grid on
        title(['V_b = ' num2str(savedata.Vb(j)) 'V, V_d = ' num2str(1E3*savedata.Vbsweep{j}.V_drive(i)) 'mV']);
        xlim([min(spectrum.x-f_n),max(spectrum.x-f_n)]);
        int = 120;
        ints = (max(spectrum.x-f_n)-min(spectrum.x-f_n))/int;

        ax = gca;
        ax.XTick = -1*floor(ints/2)*int:int:floor(ints/2)*int;

        saveas(gcf,[dirname, '\',filename '_spect_' num2str(i)],'png') %Save as PNG

        savedata.Vbsweep{j}.spectsurf.Y(:,i) = spectrum.x-f_n;
        savedata.Vbsweep{j}.spectsurf.Z(:,i) = spectrum.y;
        savedata.Vbsweep{j}.spectsurf.X(:,i) = savedata.Vbsweep{j}.V_drive(i)*ones(size(spectrum.x));
        mkdir([dirname, '\',filename '\Vb' num2str(j)]);
        saveas(gcf,[dirname, '\',filename '\Vb' num2str(j) '\' filename '_drivenASD_' num2str(i)],'png') %Save as PNG


        %% start OL sample
        fprintf('    Starting OL sample...\n')
        figure(500+10*j+i)
        subplot(2,1,1)
        df = savedata.Vbsweep{j}.PLLsample(i).frequency-mean(savedata.Vbsweep{j}.PLLsample(i).frequency);
        t_df = linspace(0,PLL_init_time,length(df));
        plot(t_df,df,'b.')
        ylabel('df (Hz)');
        xlabel('time (s)');
        title(sprintf('PLL  fluct: Vdrive  = %.1f uV', 1E6*savedata.Vbsweep{j}.V_drive(i)));

        %disable PLL
        ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/Enable'], 0);
        %set freq
        freqset = mean(savedata.Vbsweep{j}.PLLsample(i).frequency);
        ziDAQ('setDouble', ['/' device '/oscs/' osc_c '/freq'], freqset);
        %turn on linear drive
        ziDAQ('setInt',['/' device '/sigouts/' out_c '/on'], 1);
        ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/' demod_c], 1); 

        %Acquire data
        ziDAQ('unsubscribe','*');
        ziDAQ('flush'); pause(1.0);
        ziDAQ('subscribe',['/' device '/demods/' demod_c '/sample']);
        oldata = ziDAQ('poll', Poll_Time, Poll_TimeOut ) ;
        ziDAQ('unsubscribe','*');   

        %save data:
        datapath=strcat('oldata.',device,'.demods.sample') ;
        savedata.Vbsweep{j}.OLsample(i).drive=savedata.Vbsweep{j}.V_drive(i) ;
        savedata.Vbsweep{j}.OLsample(i).x=eval(strcat(datapath,'.x')) ;
        savedata.Vbsweep{j}.OLsample(i).y=eval(strcat(datapath,'.y')) ;
        savedata.Vbsweep{j}.OLsample(i).frequency=eval(strcat(datapath,'.frequency'));
        savedata.Vbsweep{j}.OLsample(i).phase=atan2(savedata.Vbsweep{j}.OLsample(i).y,savedata.Vbsweep{j}.OLsample(i).x);

        %find implied freq fluct
        savedata.Vbsweep{j}.OLsample(i).frequency_impl = freqset + savedata.Vbsweep{j}.OLsample(i).phase./savedata.Vbsweep{j}.dphi_df;

        figure(500+10*j+i)
        subplot(2,1,2)
        df = savedata.Vbsweep{j}.OLsample(i).frequency_impl-mean(savedata.Vbsweep{j}.OLsample(i).frequency_impl);
        t_df = linspace(0,Poll_Time,length(df));
        plot(t_df,df,'b.')
        ylabel('df (Hz)');
        xlabel('time (s)');
        title(sprintf('OL Implied fluct: V_b = %.1f V, Vdrive  = %.1f uV', savedata.Vb(j),1E6*savedata.Vbsweep{j}.V_drive(i)));
        mkdir([dirname, '\',filename '\Vb' num2str(j)]);
        saveas(gcf,[dirname, '\',filename '\Vb' num2str(j) '\' filename '_freqtimeseries_' num2str(i)],'png')

        %% process OL ADEV
        fprintf('    processing OL ADEV....\n');

        tau  = logspace(-1*ceil(abs(log10(1/demod_rate))),(log10(Poll_Time)-0.1),200);
        data.rate = savedata.PLLparams.demod_rate;
        data.freq = transpose(savedata.Vbsweep{j}.OLsample(i).frequency_impl) ; %Make sure the frequency input to allan2 is a column vector
        f1ref=freqset ;
        R_average=mean(sqrt(savedata.Vbsweep{j}.OLsample(i).x.^2+savedata.Vbsweep{j}.OLsample(i).y.^2));

        %call adev code
        ADEV = allan2(data,tau);

        %process reuslt, throw out repeated values
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
        
        %%Find minimum ADEV in 1/f regime
        ptp=find(ADEVx(:) < 10) ;%s, to avoid picking an ADEV from the drift regime
        [minADEVy,I]=min(ADEVy(ptp)); %Find minimum ADEV value and index
        minADEVx=ADEVx(I);
        
        savedata.Vbsweep{j}.minADEVy(i) = minADEVy;
        
        savedata.minADEVySURF.X(j,i) = savedata.Vb(j);
        savedata.minADEVySURF.Y(j,i) = savedata.Vbsweep{j}.V_drive(i)*savedata.Vb(j);
        savedata.minADEVySURF.Z(j,i) = minADEVy;

        savedata.Vbsweep{j}.OLsample(i).ADEVx = ADEVx;
        savedata.Vbsweep{j}.OLsample(i).ADEVy = ADEVy;

        %% plot OL ADEV
        

        label_2{i} = sprintf('Vdrive  = %.1f uV', 1E6*savedata.Vbsweep{j}.V_drive(i));
        f = figure(j);
        handle_2(i) = loglog(ADEVx(:),ADEVy(:),'Color',[.2 .2 hue(i)]);
        hold on
        loglog(minADEVx,minADEVy,'ko','HandleVisibility','off'); %plot on ADEV plot
        grid on
        title(['OL Allan V_b = ' num2str(savedata.Vb(j)) 'V'])
        ylabel('Allan Deviation')
        xlabel('Integration time, seconds')
        legend(handle_2,label_2,'Location','Southwest')
        set(gca,'FontSize',FS) %Change axes value text size
        set(findall(gcf,'type','text'),'FontSize',FS) %Change all other text size
        set(findall(gca, 'Type', 'Line'),'LineWidth',2); %Change line width
        set(findall(gca, '-Property', 'FontName'), 'FontName', 'Times New Roman');

        mkdir([dirname, '\',filename '\Vb' num2str(j)]);
        saveas(gcf,[dirname, '\',filename '\Vb' num2str(j) '\' filename '_OLADEV'],'png')


        %% save data
        save([dirname, '\',filename ],'savedata');


    %% %%%%END DRIVE VOLTAGE LOOP %%%%%%
    end


%% %%%%END BIAS VOLTAGE LOOP %%%%%%
        
end


%% minadev colormap 

FS = 14;


X = savedata.minADEVySURF.X;
Y = savedata.minADEVySURF.Y;
Z = savedata.minADEVySURF.Z;
C = reshape(zscore(log(Z(:))),size(Z));

f = figure(901);
surf(X,Y,Z,C)
h = gca;
shading interp
colormap(bluewhitered)
view([0 0 1]);
xlabel('Bias Voltage (V)');
ylabel('Drive Voltage, V_b \times V_d (V.^2)')
title('Min ADEV colormap')

f.Position = [206 65 1000 700];

set(gca,'FontSize',FS) %Change axes value text size
set(findall(gcf,'type','text'),'FontSize',FS) %Change all other text size
set(findall(gca, '-Property', 'FontName'), 'FontName', 'Times New Roman');


saveas(gcf,[dirname, '\',filename '_minADEV_colormap'],'png') %Save as PNG

%% minADEV surf


f = figure(902);
surf(X,Y,Z,C)
h = gca;
shading interp
colormap(bluewhitered)
xlabel('Bias Voltage (V)');
ylabel('Drive Voltage, V_b \times V_d (V^2)')
zlabel('Min ADEV');
title('Min ADEV surf')

f.Position = [206 65 1000 700];


set(gca,'FontSize',FS) %Change axes value text size
set(findall(gcf,'type','text'),'FontSize',FS) %Change all other text size
set(findall(gca, '-Property', 'FontName'), 'FontName', 'Times New Roman');


saveas(gcf,[dirname, '\',filename '_minADEV_surf'],'png') %Save as PNG




%% turn off 


% turn off bias
kpib_NB(biasName,biasAddr,'setV',0,1);
kpib_NB(biasName,biasAddr,'off',1);
pause(.5);
kpib_NB(biasName,biasAddr,'read',1);


%Turn off PLL      
ziDAQ('setInt', ['/' device '/plls/0/enable'],0); %Turn off PLL 
%Turn off drive:
ziDAQ('setInt', ['/' device '/sigouts/*/on'], 0); % turn OFF drive channel


save([dirname, '\',filename ],'savedata');




