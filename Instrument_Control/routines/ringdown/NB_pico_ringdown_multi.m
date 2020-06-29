addpath(genpath('C:\Program Files\Pico Technology\SDK'));
addpath(genpath('D:\KennyUserData\Nick\Drivers\PS3000a_driver'));


clc;clear;close all;


filename='12_13_19_HH2019_ringdown_Vb2_5V_Vd18_2mV_phi_178_5_tenruns';
formatOut = 'dd-mmm-yyyy';
ds = datestr(datetime('now'),formatOut);
[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'data',ds,filename);
fullfilename=fullfile(dirname,filename);
mkdir(dirname);


data.notes = 'mPCBN6. setup with full elecs each side. AMP: LFSAV2 onboard';
data.device = 'HD16_PBL111_2_Die6_Ret3_600um_6um_110';
data.startTime = datetime('now');
data.endTime = 'incomplete';


%%

data.n_rd = 10;
data.Vd = 18.2E-3;
data.biasV = 2.5;
data.phaseset = -178.5;
data.f0 = 125.36E3;



output_range=  outRangeFind(data.Vd);
%%

biasAddr = 5;
biasName = 'HP_E3634A';


%turn on bias
kpib(biasName,biasAddr,'setV',data.biasV,1);
pause(.5);
kpib(biasName,biasAddr,'read',1);


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

% get the device type and its options (in order to set correct device-specific
% configuration)
devtype = ziDAQ('getByte',[ '/' device '/features/devtype' ] );
options = ziDAQ('getByte',[ '/' device '/features/options' ] );

fprintf('Will run the example on an ''%s'' with options ''%s''.\n',...
        devtype,regexprep(options,'\n','|'));



%%
demod_c = '0'; %demod channel for piezoresistive readout
in_c = '0' ; %input channel (0 is channel 1, 1 is channel 2)
out_c = '0' ;%output channel (0 is channel 1, 1 is channel 2)
out_drive_c='0' ;%Drive output demodulator
PLL_c='0';%PLL 1
PLL_tc = 10*6.92291283e-06; %6.92E-6 = 10k@4th order
PLL_filter_order = 4;
demod_rate=14.4e3 ;%samples per second

%Configure drive and PLL


%%

for i = 1:data.n_rd
ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/Enable'], 0); %Enable PLL

ziDAQ('setInt', ['/' device '/sigouts/' out_c '/enables/*'], 0);
ziDAQ('setInt',['/' device '/sigins/' in_c '/imp50'], 0);
ziDAQ('setInt',['/' device '/sigins/' in_c '/ac'], 1);
ziDAQ('setInt', ['/' device '/sigouts/*/on'], 0); % turn OFF drive channel
ziDAQ('setDouble', ['/' device '/sigouts/' out_c '/range'], output_range);

ziDAQ('setDouble',['/' device '/demods/' demod_c '/rate'], demod_rate); %Channel 1
ziDAQ('setInt', ['/' device '/plls/' PLL_c '/order'], PLL_filter_order);
ziDAQ('setDouble', ['/' device '/plls/' PLL_c '/timeconstant'],PLL_tc);


ziDAQ('setDouble', ['/' device '/sigouts/1/amplitudes/' out_drive_c], 0) ;
ziDAQ('setInt', ['/' device '/sigouts/0/enables/1'], 0);
pause(1);
ziDAQ('setDouble', ['/' device '/sigouts/' out_c '/amplitudes/' out_drive_c], data.Vd/output_range) ;
pause(1);

ziDAQ('setInt', ['/' device '/sigouts/' out_c '/enables/' demod_c], 1);
ziDAQ('setInt', ['/' device '/sigouts/' out_c '/on'], 1); % turn ON drive channel


ziDAQ('setInt', ['/' device '/plls/0/setpoint'], data.phaseset);
ziDAQ('setDouble', ['/' device '/PLLS/' PLL_c '/freqcenter'], data.f0);
ziDAQ('setDouble', ['/' device '/oscs/' demod_c '/freq'], data.f0);
pause(1);
ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/Enable'], 1); %Enable PLL
pause(5);





%%

if libisloaded('PS3000a')
    unloadlibrary('PS3000a');
    %unloadlibrary('ps3000aWrap'); 
    disp('lib unloaded');
end

sampling_time = .5;
pll = 1;
demod = 1;
range = 1; %mV range (3 digits, V if 1 digit)
Fs = 10E6;
delay_s = 0;

PS3000aConfig;
ps3000a_obj = icdevice('PS3000a_IC_drv','');
retval = ps_ringdown(ps3000a_obj, sampling_time, Fs, delay_s ,pll,demod,device,range);
disconnect(ps3000a_obj);

ziDAQ('setInt', ['/' device '/sigouts/*/on'], 0); % turn OFF drive channel



%% plot raw
Y_filt  = sgolayfilt(retval.y,7,21);
figure(100+i);
clf
plot(retval.time,retval.y)
hold on
plot(retval.time,Y_filt)


data.ringdown(i).y = retval.y;
data.ringdown(i).y_filt = Y_filt;
data.ringdown(i).t = retval.time;

end


%turn off bias
kpib(biasName,biasAddr,'setV',0,1);
pause(.5);
kpib(biasName,biasAddr,'read',1);
%% save

save([fullfilename '.mat'],'data'); %Save data set

saveas(gcf,[fullfilename,'_ringdown'],'png');


