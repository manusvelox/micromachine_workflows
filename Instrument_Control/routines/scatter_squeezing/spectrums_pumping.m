clc;clear;close all;
%take spectrums of responator with various parametric pumps
%Store bias voltages, measured currents, network analyzer sweeps, etc.
%in data.XXX 
   

filename='10_19_pumppeaks';
mkdir(filename);

spect_addr=17;


span = 100; %Hz
center = 108856.625; %Hz
RBW = 1;% HZ
avenum = 2000;

V_pump = [0 10E-3 15E-3];
V_pump = linspace(0,12E-3,100);
data.V_pump = V_pump;
data.RBW = RBW;

%%
% data.VP = zeros(points,length(V_pump));
% data.F = zeros(points,length(V_pump));
% data.MAG = zeros(points,length(V_pump));

figure(2)
shading('flat')
xlabel('VP')
ylabel('f')
zlabel('mag')


%%

%%*** CHECK RBW, points settings 

%set window guess
kpib('HP_89410A',17,'center',center);
kpib('HP_89410A',17,'span',span);

% setup averaging
kpib('HP_89410A',17,'peaktrack','on',1);
kpib('HP_89410A',17,'average','on');
kpib('HP_89410A',17,'average','type','rms');
kpib('HP_89410A',17,'average',avenum);

% setup source
kpib('HP_89410A',17,'source','off');
kpib('HP_89410A',17,'source','function','sin');
kpib('HP_89410A',17,'source','freq',2*center);
%%

figure(1)
xlabel('Frequency (Hz)');
ylabel('PSD Vrms/rtHz');
hold on


%%
for i = 1:length(V_pump)
    
    kpib('HP_89410A',17,'source',V_pump(i)/2,1,'Vrms');
    kpib('HP_89410A',17,'source','on');

    kpib('HP_89410A',17,'restart');
    data.avenum =  kpib('HP_89410A',17,'average','wait');
    kpib('HP_89410A',17,'autoscale');
    peak = kpib('HP_89410A',17,'marker?');
    spectrum = kpib('HP_89410A',17,'getdata',1);

    %plot scan
    figure(1)
    plot(spectrum.x,spectrum.y);
    hold on;
    
    figure(2)
    data.VP(:,i) = V_pump(i)*ones(length(spectrum.x),1);
    data.F(:,i) = spectrum.x; 
    data.MAG(:,i) = spectrum.y;
    try
    surf(data.VP,data.F,data.MAG)
    shading('flat')
    xlabel('VP')
    ylabel('f')
    zlabel('mag')
    catch 
         
    end
    
    %store data
    data.peak_freq(i) = peak.x;
    data.peak_mag(i) = peak.y;
    data.spectrum(i) = spectrum;



end

data.points = length(spectrum.x);

%%
fullfilename=fullfile(filename,filename);
save([filename,'\',filename,'.mat'],'data'); %Save data set

saveas(1,[fullfilename,'_spectrums']); %Save Matlab figure in created folder
saveas(1,[fullfilename,'_spectrums'],'png'); %Save png in created folder

saveas(2,[fullfilename,'_spectrums3d']); %Save Matlab figure in created folder
saveas(2,[fullfilename,'_spectrums3d'],'png'); %Save png in created folder



