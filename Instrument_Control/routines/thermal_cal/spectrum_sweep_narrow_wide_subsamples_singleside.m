clc;clear;close all;


filename='6_24_20_readoutcal_Rf1_500k_500mVstep';
formatOut = 'dd-mmm-yyyy';
ds = datestr(datetime('now'),formatOut);
[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'data',ds,filename);
fullfilename=fullfile(dirname,filename);
mkdir(dirname);


data.notes = ' mPCBN8. setup with full elecs each side. AMP: LFSAV2 onboard, Rf1 = 500k';
data.device = 'HD16_PBL111_2_Die5_Ret12_400um_2elec_100';
data.startTime = datetime('now');
data.endTime = 'incomplete';



%%

spectrumAddr = 17;
biasAddr = 5;
biasName = 'HP_E3634A';

Ch_single = 1;
Ch_diff = 2;


%%

points = 1601;

data.Tset = 25;
spectrumSpan1 = 15000;
RBW1 = spectrumSpan1/60;
numAve1 = 100;


n_samples = 10;
spectrumSpan2 = 800;
RBW2 = 11;
numAve2 = 50;


biasMax = 12;
biasMin = 3;
biasStep = .25;
biasV= fliplr(biasMin:biasStep:biasMax);



data.biasV= biasV;

load('HD16_PBL111_2_Die5_Ret10_400um_2elec_100_freqs');
% freqdata.V = [3 4 5 6 7 8 9 10];
% freqdata.f = [119.94 118.76 117.2 115.38 113.125 110.43 107.32 103.72]*1E3

centers = interp1(freqdata.V,freqdata.f,biasV,'pchip','extrap')-2E3

figure(999)
plot(biasV,centers,'b-',freqdata.V,freqdata.f,'r*')
% 
% centers = 83.5E3;%kpib_NB('HP_89410A',spectrumAddr,'center','?');

%% setup thermo

s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev2',0,'Thermocouple');
thermo = s.Channels(1);
thermo.ThermocoupleType = 'K';
blueoven('set',data.Tset,6)

%%

kpib(biasName,biasAddr,'setV',biasV(1),1);
pause(.5)
kpib(biasName,biasAddr,'read',1);
%pause(5*60)


%set resoltuion
kpib_NB('HP_89410A',spectrumAddr,'points',points)


%set averaging 
kpib_NB('HP_89410A',spectrumAddr,'average','on');
kpib_NB('HP_89410A',spectrumAddr,'center',centers(1));

kpib_NB('HP_89410A',spectrumAddr,'average','type','rms');


win_wide = 80;
win_narrow = 50;
%%

df = spectrumSpan2/points;
lim = spectrumSpan2/2-75;
f_samples = transpose(-lim:df:lim);



%%
for i = 1:length(biasV)
    
    kpib(biasName,biasAddr,'setV',biasV(i),1);
    pause(.5);
    kpib(biasName,biasAddr,'read',1);
    pause(10);
    
    if length(centers) > 1
    kpib_NB('HP_89410A',spectrumAddr,'center',centers(i)) 
    end
    
    

    
    %% wide
    data.Tprewide(i) =  s.inputSingleScan();
    kpib_NB('HP_89410A',spectrumAddr,'span',spectrumSpan1)
    kpib_NB('HP_89410A',spectrumAddr,'bandwidth',RBW1)
    kpib_NB('HP_89410A',spectrumAddr,'average',numAve1);

    %wait for ave
    kpib_NB('HP_89410A',spectrumAddr,'restart');
    pause(1);
    kpib_NB('HP_89410A',spectrumAddr,'average','wait');

    
    % pull data - diff
    data.ASD_wide{i} = kpib('HP_89410A',spectrumAddr,'getdata','xy',Ch_diff);
    minf = min(data.ASD_wide{i}.x);
    maxf = max(data.ASD_wide{i}.x);


    [f_n,A_n]  =  parabolic_peak_correct(data.ASD_wide{i}.x,data.ASD_wide{i}.y,win_wide,inf);


    
    kpib_NB('HP_89410A',spectrumAddr,'center',f_n)
    data.peaks_wide(i) = f_n;


    figure(200+i)
    plot(data.ASD_wide{i}.x*1E-3,data.ASD_wide{i}.y*1E6,'-')
    xlabel('frequency (kHz)');
    ylabel('ASD (uVrms/rtHz)');
    hold on 
    plot(f_n*1E-3,A_n*1E6,'r*');
    title(['differential, wide: Vb = ' num2str(biasV(i),3) 'V']);
    xlim([minf maxf]*1e-3)
    
    
    figure(2)
    h(2*i)=plot(data.biasV(i),data.peaks_wide(i),'b*','DisplayName','wide - diff');
    hold on
    xlabel('Vb')
    ylabel('f_n')
    
    
    saveas(200+i,[fullfilename,'_',num2str((i)),'spectrum_wide_diff']); %Save Matlab figure in created folder
    saveas(200+i,[fullfilename,'_',num2str((i)),'spectrum_wide_diff'],'png'); %Save png in created folder
    data.Tpostwide(i) =  s.inputSingleScan();

    %% narrow
    
    kpib_NB('HP_89410A',spectrumAddr,'span',spectrumSpan2)
    kpib_NB('HP_89410A',spectrumAddr,'bandwidth',RBW2)
    kpib_NB('HP_89410A',spectrumAddr,'average',numAve2);
    
    y_sum = zeros(size(f_samples));
    
    for m = 1:n_samples
        %wait for ave
        kpib_NB('HP_89410A',spectrumAddr,'restart');
        pause(1);
        kpib_NB('HP_89410A',spectrumAddr,'average','wait');

        % pull data - diff
        spectrum = kpib('HP_89410A',spectrumAddr,'getdata','xy',Ch_diff);
        [f_n,A_n]  =  parabolic_peak_correct(spectrum.x,spectrum.y,win_narrow,inf);
        data.ASD_narrow_diff_subsampled{i}.subspectrums{m} = spectrum;
        minf = min(spectrum.x);
        maxf = max(spectrum.x);
        
        figure(300+i)
        plot(spectrum.x*1E-3,spectrum.y*1E6,'-')
        xlabel('frequency (kHz)');
        ylabel('ASD (uVrms/rtHz)');
        hold on 
        plot(f_n*1E-3,A_n*1E6,'r*');
        title(['diff narrow: Vb = ' num2str(biasV(i),3) 'V']);
        xlim([minf maxf]*1e-3)
        
        
        % pull data - single
        spectrum = kpib('HP_89410A',spectrumAddr,'getdata','xy',Ch_single);
        minf = min(spectrum.x);
        maxf = max(spectrum.x);
        %[f_n_single,A_n_single]  =  parabolic_peak_correct(spectrum.x,spectrum.y,win_narrow,inf);
        kpib_NB('HP_89410A',spectrumAddr,'center',f_n);
        data.ASD_narrow_subsampled{i}.fn(m) = f_n;
        f_norm = spectrum.x-f_n;
        y_sampled = interp1(f_norm,spectrum.y,f_samples);
        y_sum = y_sum +y_sampled;
        
        data.ASD_narrow_subsampled{i}.subspectrums{m} = spectrum;
        
        figure(400+i)
        plot(spectrum.x*1E-3,spectrum.y*1E6,'-')
        xlabel('frequency (kHz)');
        ylabel('ASD (uVrms/rtHz)');
        hold on 
        plot(f_n*1E-3,A_n*1E6,'r*');
        title(['single narrow: Vb = ' num2str(biasV(i),3) 'V']);
        xlim([minf maxf]*1e-3)
          
    end
    kpib_NB('HP_89410A',spectrumAddr,'center',f_n+floor(spectrumSpan1/2));
    data.ASD_narrow_subsampled{i}.fn_mean = mean(data.ASD_narrow_subsampled{i}.fn);
    data.ASD_narrow_subsampled{i}.x = f_samples;
    data.ASD_narrow_subsampled{i}.y = y_sum/n_samples;
    data.fn_mean(i) = data.ASD_narrow_subsampled{i}.fn_mean;
    
    figure(500+i)
    plot(data.ASD_narrow_subsampled{i}.x,data.ASD_narrow_subsampled{i}.y*1E6,'-')
    xlabel('frequency (kHz)');
    ylabel('ASD (uVrms/rtHz)');
    hold on 
    title(['differential: Vb = ' num2str(biasV(i),3) 'V, f_{mean} = ' num2str(data.ASD_narrow_subsampled{i}.fn_mean)]);
    xlim([-lim lim])
    
    
    figure(2)
    hold on
    h(2*i+1) = plot(data.biasV(i),data.ASD_narrow_subsampled{i}.fn_mean,'r*');
    legend(h(2:3),'wide','narrow');
    
    
    saveas(400+i,[fullfilename,'_',num2str((i)),'spectrum_narrow_all'],'png');
    saveas(500+i,[fullfilename,'_',num2str((i)),'spectrum_narrow_ave'],'png'); 
    
    data.Tpostnarrow(i) =  s.inputSingleScan();




end

kpib(biasName,biasAddr,'setV',0,1);
pause(.5);
kpib(biasName,biasAddr,'read',1);

%% save data

data.n_samples = n_samples;
data.RBW_wide = RBW1;
data.RBW_narrow = RBW2;
data.biasV = biasV;
data.SpectrumSpan1 = spectrumSpan1;
data.SpectrumSpan2 = spectrumSpan2;
data.centers = centers;
data.Ch_single = Ch_single;
data.Ch_diff = Ch_diff;
data.endTime = datetime('now');


save([fullfilename '.mat'],'data'); %Save data set

saveas(2,[fullfilename,'_',num2str((i)),'f_V'],'png');




