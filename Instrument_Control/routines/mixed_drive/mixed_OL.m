%% setup instrument properties
close all;
clear;
clc;

filename='3_8_freqmixing_JMBeam_200um_5MHzCarrier_50mVdrive';
data.notes = 'mPCB N1 driven through difference amp circuit'; 
data.device = 'HD16 PBIII-1 Ret1 JMBeam_200um_2elec_0deg';
mkdir(filename);



%% instrument setup


carrierAddr = 10;
sidebandAddr = 19;
spectrumAddr = 17;
biasAddr = 5;
biasName = 'HP_E3634A';


%% measurement params
points = 1601;
RBW = 10;
spectrumSpan = 200;

channel = 1;
numAve = 2;
carrierFreq = 5E6; %2MHz carrier
driveAmp = 50E-3; %50mV
biasV = 5;


%%
sweepCenter = 516.45E3;
sweepSpan = 700;
nPoints = 100;

freqs = linspace(sweepCenter-sweepSpan/2,sweepCenter+sweepSpan/2,nPoints);


%% bias device


kpib_NB(biasName,biasAddr,'setV',biasV,1);
kpib_NB(biasName,biasAddr,'read',1);
%% sweep

% setup averaging


    
    kpib_NB('HP_89410A',17,'peaktrack','on',channel);
    kpib_NB('HP_89410A',17,'average','on');
    kpib_NB('HP_89410A',17,'average','type','rms');
    kpib_NB('HP_89410A',17,'average',numAve);
    kpib_NB('HP_89410A',17,'autoscale');


for i = 1:length(freqs)
    
    %set drive
    kpib_NB('HP_33120A',carrierAddr,'sin', carrierFreq,driveAmp,'VPP')
    kpib_NB('HP_33120A',sidebandAddr,'sin', carrierFreq+freqs(i),driveAmp,'VPP')
    
    kpib_NB('HP_89410A',spectrumAddr,'span',spectrumSpan)
    kpib_NB('HP_89410A',spectrumAddr,'center',freqs(i))    
    
    kpib_NB('HP_89410A',spectrumAddr,'points',points)
    kpib_NB('HP_89410A',spectrumAddr,'bandwidth',RBW)
    

    %restart and wait
    kpib_NB('HP_89410A',17,'autoscale');
    kpib_NB('HP_89410A',17,'restart');
    kpib_NB('HP_89410A',17,'average','wait');

    
    %pull data
    spectrums(i) = kpib_NB('HP_89410A',17,'getdata',1);
    peaks(i) = kpib_NB('HP_89410A',17,'marker?');
    
    figure(1)
    hold on
    plot(peaks(i).x,peaks(i).y,'b*')
    xlabel('Frequency (Hz)');
    ylabel('Amplitude (Vrms)');
end

data.peaks = peaks;
data.spectrums = spectrums;

%% save data

fullfilename=fullfile(filename,filename);
save([filename,'\',filename,'.mat'],'data'); %Save data set

saveas(1,[fullfilename,'_overall']); %Save Matlab figure in created folder
saveas(1,[fullfilename,'_overall'],'png'); %Save png in created folder


%% turn off bias, drive above resonance
kpib_NB(biasName,biasAddr,'setV',0,1);
kpib_NB(biasName,biasAddr,'read',1);

kpib_NB('HP_33120A',carrierAddr,'sin', 10E6,driveAmp,'VPP')
kpib_NB('HP_33120A',sidebandAddr,'sin', 10E6,driveAmp,'VPP')