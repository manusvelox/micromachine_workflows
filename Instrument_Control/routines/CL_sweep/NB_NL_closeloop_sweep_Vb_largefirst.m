clc;clear;close all;


filename='5_19_20_HD16_PBL111_2_Die5_Ret10_400um_2elec_CLsweep_Vbsweep_V2max45mV';
formatOut = 'dd-mmm-yyyy';
ds = datestr(datetime('now'),formatOut);
[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'data',ds,filename);
fullfilename=fullfile(dirname,filename);
mkdir(dirname);


data.notes = 'mPCBN6. setup with full elecs each side. AMP: LFSAV2 onboard';
data.device = 'HD16_PBL111_2_Die5_Ret10_400um_2elec';
data.startTime = datetime('now');
data.endTime = 'incomplete';

off = 1; %turn off after?



%%

data.V2_max = 45E-3;
data.V2_min = 20E-4;
n_drive = 20;

data.biasV  = 4.2:.2:6.4%2:.2:4.4;


phi_start = -73.0;
phi_end = -270;
dphi = -.1;
nphi = 600;
phase_cont =linspace(phi_start,phi_end,nphi);

%wrap to -180 -- +180

phase = 180/pi*wrapTo2Pi(pi*(phase_cont+180)/180)-180;

PLL_tc = 10*6.92291283e-06; %6.92E-6 = 10k@4th order
PLL_filter_order = 4;
demod_rate=14.4e3 ;%samples per second


pause_time=PLL_tc*10; %Time to let PLL re-lock (need more time for longer bandwidths)
poll_time = 700*PLL_tc;



data.phase = phase;
data.phase_cont = phase_cont;
data.PLLparams.PLL_tc = PLL_tc;
data.PLLparams.PLL_filter_order= PLL_filter_order;
data.PLLparams.poll_time= poll_time;
data.PLLparams.demod_rate= demod_rate;

load('HD16_PBL111_2_Die5_Ret10_400um_2elec_100_freqs')
mdl = polyfitn(freqdata.V,freqdata.f,{'constant','x','x^2'});
centers = polyvaln(mdl,data.biasV);
centers = interp1(freqdata.V,freqdata.f,data.biasV,'pchip','extrap')
figure(999)
plot(data.biasV,centers,'b-',freqdata.V,freqdata.f,'r*')
%%

biasAddr = 5;
biasName = 'HP_E3634A';


%turn on bias
kpib(biasName,biasAddr,'setV',data.biasV(1),1);
pause(.5);
kpib(biasName,biasAddr,'read',1);


%%

poll_timeout=500; %seconds
demod_c = '0'; %demod channel for piezoresistive readout
in_c = '0' ; %input channel (0 is channel 1, 1 is channel 2)
out_c = '0' ;%output channel (0 is channel 1, 1 is channel 2)
out_drive_c='0' ;%Drive output demodulator
PLL_c='0';%PLL 1

%demod_rate=115e3 ;%samples per second


%%
hue = fliplr(linspace(.4,.8,n_drive));

%Zurich Initialization
%
ziDAQ('connect');
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
%device = 'dev1375';
%device = 'dev473';
%device = 'dev473';

% get the device type and its options (in order to set correct device-specific
% configuration)
devtype = ziDAQ('getByte',[ '/' device '/features/devtype' ] );
options = ziDAQ('getByte',[ '/' device '/features/options' ] );

fprintf('Will run the example on an ''%s'' with options ''%s''.\n',...
        devtype,regexprep(options,'\n','|'));

%%
    
data.startTime = datetime('now');
for j = 1:length(data.biasV)
    
    
    
    fprintf('\n\nstarting V_b = %.2f. Sample %.0f/%.0f\n', data.biasV(j), j, length(data.biasV));
    %Configure drive and PLL
    ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/Enable'], 0); %disable PLL
    ziDAQ('setInt',['/' device '/sigins/' in_c '/imp50'], 0);
    ziDAQ('setInt',['/' device '/sigins/' in_c '/ac'], 1);
    ziDAQ('setInt', ['/' device '/sigouts/*/on'], 0); % turn OFF drive channel
    ziDAQ('setDouble',['/' device '/demods/' demod_c '/rate'], demod_rate); %Channel 1
    ziDAQ('setDouble',['/' device '/sigouts/' out_c '/enables/*'], 0); %Turn off all demodulator channels
    ziDAQ('setInt', ['/' device '/plls/0/order'], PLL_filter_order);
    ziDAQ('setDouble', ['/' device '/plls/' PLL_c '/timeconstant'],PLL_tc);
    ziDAQ('setDouble', ['/' device '/plls/' PLL_c '/setpoint'],data.phase(1));

    V_d_init = data.V2_max/data.biasV(j);
    output_range=  outRangeFind(V_d_init);
    ziDAQ('setDouble', '/dev479/sigouts/0/range', output_range);
    pause(1);
    ziDAQ('setDouble', ['/' device '/sigouts/' out_c '/amplitudes/' out_drive_c], V_d_init/output_range) ;
    pause(1);

    
    
    %turn on bias
    kpib(biasName,biasAddr,'setV',data.biasV(j),1);
    pause(.5);
    kpib(biasName,biasAddr,'read',1);

    ziDAQ('setDouble',['/' device '/sigouts/' demod_c '/enables/' out_c], 1); %turn on demod
    ziDAQ('setInt', ['/' device '/sigouts/' out_c '/on'], 1); % turn ON drive channel


    ziDAQ('setDouble', ['/' device '/PLLS/' PLL_c '/freqcenter'],centers(j) );
    ziDAQ('setDouble', ['/' device '/oscs/' demod_c '/freq'], centers(j));
    ziDAQ('setInt',['/' device '/PLLS/' PLL_c '/Enable'], 1); %Enable PLL

    pause(4);

    V_drive= linspace(data.V2_min/data.biasV(j),data.V2_max/data.biasV(j),n_drive);
    data.biaslevel(j).V_drive = V_drive;

f1 = figure(1);
f1.Position = [35 336 530 350];

fprintf('\n\n');
delV = '';
deli = '';
 for k=1:length(V_drive) 
     

%     output_range=  outRangeFind(mean(V_drive));
%     ziDAQ('setDouble', '/dev479/sigouts/0/range', output_range);
%     pause(1);
%     ziDAQ('setDouble', ['/' device '/sigouts/' out_c '/amplitudes/' out_drive_c], mean(V_drive)/output_range) ;
%     pause(1);
     
    output_range=  outRangeFind(V_drive(k));
    ziDAQ('setDouble', ['/' device '/sigouts/' out_c '/range'], output_range);
    pause(1);
    ziDAQ('setDouble', ['/' device '/sigouts/' out_c '/amplitudes/' out_drive_c], V_drive(k)/output_range);
    pause(1);
    

    figure(1);
    subplot(2,1,1);
    cla;
    subplot(2,1,2);
    cla
    
    biasV_done = (k-1)/length(V_drive);
    total_done = 1E-4+(biasV_done+j-1)/length(data.biasV);

    t_elapsed = (datetime('now')-data.startTime);
    t_end = datetime('now') + t_elapsed/total_done;
    ds_end = datestr(t_end);

    msgv = sprintf([' V_b %.0f/%.0f: %d/100 complete, total %d/100 complete. End time: ' ds_end]...
        ,j,length(data.biasV),floor(100*biasV_done),floor(100*total_done));
    fprintf([delV, msgv]);
    delV = repmat(sprintf('\b'), 1, length(msgv));
        
    
    
    for i = 1:length(phase)


        ziDAQ('setDouble', ['/' device '/plls/' PLL_c '/setpoint'], phase(i));
        
        pause(pause_time);
        

           %Acquire data
        ziDAQ('unsubscribe','*');
        ziDAQ('flush'); pause(0.1);
        ziDAQ('subscribe',['/' device '/demods/' demod_c '/sample']);
        outdata = ziDAQ('poll', poll_time, poll_timeout ) ;
        ziDAQ('unsubscribe','*');
        
        %if ~isempty(data)
            % collect data:
            
            datapath=strcat('outdata.',device,'.demods.sample');
            x=mean(eval(strcat(datapath,'.x'))) ;
            y=mean(eval(strcat(datapath,'.y'))) ;
            data.biaslevel(j).CLSweep(k).R(i)=sqrt(x^2+y^2) ;
            data.biaslevel(j).CLSweep(k).phase_measured(i)=atan2d(y,x) ;
            data.biaslevel(j).CLSweep(k).freq(i)=mean(eval(strcat(datapath,'.frequency'))) ;
            
%             retval.freq(i) = mean(strcat('d.' device '.demods(1,1).sample.frequency);
%             retval.x(i) = mean(d.dev473.demods(1,1).sample.x);
%             retval.y(i) = mean(d.dev473.demods(1,1).sample.y);
%             retval.R(i) = sqrt(retval.x(i).^2+retval.y(i).^2);

        %end %end data collection
        

        
        figure(1);
        subplot(2,1,1);
        title(sprintf('V_b = %.2fV, V_d = %.1fmV',data.biasV(j),V_drive(k)*1E3));
        plot(data.biaslevel(j).CLSweep(k).freq(i),data.biaslevel(j).CLSweep(k).R(i),'b.'); hold on;
        xlabel('Frequency (Hz)')
        ylabel('Amplitude (V)')
        subplot(2,1,2);
        plot(data.biaslevel(j).CLSweep(k).freq(i),phase_cont(i),'b.'); hold on;
        xlabel('Frequency (Hz)')
        ylabel('Phase (deg)')
        
    end % End loop over phases

    
    f3 = figure(100+j);
    f3.Position = [647 91 760 700];
    subplot(2,1,1);
    hold on
    title(sprintf('V_b = %.2fV, V_d = %.1fmV - %.1fmV',data.biasV(j),min(V_drive)*1E3,max(V_drive)*1E3))
    plot(data.biaslevel(j).CLSweep(k).freq,data.biaslevel(j).CLSweep(k).R,'.','Color',[.2 hue(k),.2]); hold on;
    xlabel('Frequency (Hz)')
    ylabel('Amplitude (V)')
    subplot(2,1,2);
    plot(data.biaslevel(j).CLSweep(k).freq,phase_cont,'.','Color',[.2 hue(k),.2]); hold on;
    xlabel('Frequency (Hz)')
    ylabel('Phase (deg)')
    
    
    
 end    

 saveas(100+j,[fullfilename,'_CLSweep_',num2str(j)],'png');
 
 fprintf('\n\n');

 ziDAQ('setDouble', ['/' device '/sigouts/' out_c '/amplitudes/' out_drive_c], min(V_drive)/output_range);
 
end
   



%%
data.endTime = datetime('now');
save([fullfilename '.mat'],'data'); %Save data set




if off
    %Turn off PLL      
    ziDAQ('setInt', ['/' device '/plls/0/enable'],0); %Turn off PLL 
    %Turn off drive:
    ziDAQ('setInt', ['/' device '/sigouts/*/on'], 0); % turn OFF drive channel

    %turn off bias
    kpib(biasName,biasAddr,'setV',0,1);
    pause(.5);
    kpib(biasName,biasAddr,'read',1);
end


