function sweepData = OLSweeper(varargin)
%sweepData = OLSweeper(device, Vd, startf, stopf, points, quality ,inputChan, outputChan,imp50 )



inputs = {'dev717',0,10E3,10E6,1000, 'med',0,0,0};
inputs(1:nargin) = varargin;


 
device = inputs{1};
Vd = inputs{2};
startf = inputs{3};
stopf = inputs{4};
points = inputs{5};
quality = inputs{6};
inputChan = inputs{7};
outputChan = inputs{8};
imp50 = inputs{9};

%% setup lockin

%turn everything off
ziDAQ('setInt',['/' device '/sigouts/*/on'], 0);
ziDAQ('setDouble',['/' device '/sigouts/*/enables/*' ], 0);

%turn off offset and add
ziDAQ('setDouble', ['/' device '/sigouts/*/offset'], 0);
ziDAQ('setInt', ['/' device '/sigouts/*/add'], 0);

%setup inputs
ziDAQ('setInt', ['/' device '/sigins/*/diff'], 0);
ziDAQ('setInt', ['/' device '/sigins/*/ac'], 1);
ziDAQ('setInt', ['/' device '/sigins/*/imp50'], imp50);

%set demod to corrrect input
ziDAQ('setInt', ['/' device '/demods/0/adcselect'], inputChan);

%set demod to correct osc
ziDAQ('setInt', ['/' device '/demods/0/oscselect'], 0);

%turn on data transfer
ziDAQ('setInt', ['/' device '/demods/0/enable'], 1);

%turn off PLLs
ziDAQ('setInt',['/' device '/PLLS/*/Enable'], 0);

%% sweep

output_range=  outRangeFind(Vd);
ziDAQ('setDouble',['/' device '/sigouts/' num2str(outputChan) '/range'], output_range); %set range of output
ziDAQ('setDouble',['/' device '/sigouts/' num2str(outputChan) '/amplitudes/0'], Vd/output_range);
ziDAQ('setDouble',['/' device '/sigouts/' num2str(outputChan) '/enables/0'], 1); %Turn on signal output amp 1

ziDAQ('setInt',['/' device '/sigouts/' num2str(outputChan) '/on'], 1);
pause(.5);
zisweepdata = ziSweep(device,startf, stopf, points, quality, 0);
ziDAQ('setInt',['/' device '/sigouts/' num2str(outputChan) '/on'], 0);

%% process

amp = zisweepdata.r(~isnan(zisweepdata.r));
phase = zisweepdata.phase(~isnan(zisweepdata.phase));
freq = zisweepdata.frequency(~isnan(zisweepdata.frequency));
[f_n,A_n] = parabolic_peak_correct(freq,amp,10,inf);

sweepData.amp = amp;
sweepData.phase = phase;
sweepData.freq = freq;
sweepData.f_n = f_n;

sweepData.Vout_phasor = amp.* exp(1i*phase);
[sweepData.X, sweepData.Y] = pol2cart(phase,amp);



end

