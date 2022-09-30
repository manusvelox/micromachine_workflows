%% runDataCapture.m
%  This program uses the AlazarTech library and driver interface to capture
%  and save high speed ADC data. The capture can be configured, including
%  data rate, channel selection, data saving path and triggering (both 
%  triggering the data capture and providing an auxilary trigger output
%  after the commencement of data capture).

%modified NB 6/17 to hardcode file name

%  Settings are provided in a structure setADC
%       setADC.fileNameIn           ['path\fileNameToSaveData']
%                                       DEFAULT: data.bin
%       setADC.channels             ['CH_A', 'CH_B', 'CH_AB']
%                                       DEFAULT: CH_AB                                        
%       setADC.sampleRate           [1 kHZ -> 2000 kHz]
%                                       DEFAULT: 1 MHz
%       setADC.sampleTime           [seconds]
%                                       DEFAULT: 0.4s
%       setADC.triggerSource        ['EXT', 'CH_A', 'CH_B']
%                                       DEFAULT: no hardware trigger
%       setADC.triggerDirection     ['RISE', 'FALL']
%       setADC.triggerLevel         [0 -> 255] maps to [-???]
%       setADC.triggerOutFunction   ['functionToCallProduceTrigger()']
%       setADC.triggerOutDelay      [fraction of total sample time]
%       setADC.samplesPerBuffer     [samples per channel per buffer]
%                                       DEFAULT: 204,800
%       setADC.timeoutForceTrigger       [seconds until data collected
%                                       irrespective of trigger status]
%       setADC.timeoutCapture       [seconds until buffer capture canceled]
%                                       DEFAULT: 10s
%       setADC.comments             [comment field for output log]

function [setADCRun] = runDataCapture_NB(setADC)
    statusReport = 0;
    
    %% Set up default case if no input provided at all
    if ~exist('setADC', 'var')
        setADC = '';
    end

    % Load definitions and drivers for ATS9360
    if ~exist('AC_COUPLING')
        AlazarDefs;
    end
    
    if ~alazarLoadLibrary()
        fprintf('Error: ATSApi.dll not loaded\n');
        return
    end

    if ~isfield(setADC,'externalClock')
        setADC.externalClock = 0;
    end
    
    % Select a board (Assume only one available)
    systemId = int32(1);
    boardId = int32(1);

    % Get a handle to the board from the system driver
    boardHandle = calllib('ATSApi', 'AlazarGetBoardBySystemID', systemId, boardId);
    setdatatype(boardHandle, 'voidPtr', 1, 1);
    if boardHandle.Value == 0
        fprintf('Error: Unable to open board system ID %u board ID %u\n', systemId, boardId);
        return
    end

    %% Reconfigure user input to match ATS9360 requirements
    
    % Possible sampling rates
    sampleRatesK = [1 2 5 10 20 50 100 200 500];
    sampleCodesK = [1 2 4 8  10 12 14  16  18 ];
    sampleRatesM = [1 2 5 10 20 25 50 100 125 160 180 200 400 500 800 1000 1200 1500 1600 1800 2000];
    sampleCodesM = [20 24 26 28 30 33 34 36 37 38 39 40 45 48 50 53 55 58 59 61 63];

    sampleRates = [sampleRatesK*1e3 sampleRatesM*1e6];
    sampleCodes = [sampleCodesK sampleCodesM];

    % If no sample rate provided, default to 1 MHz
    if ~isfield(setADC, 'sampleRate')
       setADC.sampleRate = 1e6;
       fprintf('Sample Rate (setADC.sampleRate) not set.   Default to 1 MHz\n');
    end
    
    % Calculate cloeset possible sampling rate based on allowed ATS9360
    % settings
    if setADC.externalClock == 0
    [~, closestMatch] = min(abs(sampleRates - setADC.sampleRate));
    setADC.sampleRateTrue = sampleRates(closestMatch);
    setADC.sampleCode = sampleCodes(closestMatch);
    else
        setADC.sampleRateTrue = round(setADC.sampleRate/1E6)*1E6;
    end

    if setADC.sampleRateTrue ~= setADC.sampleRate
        fprintf('Desired sample rate %4.0f kHz               Rounded to %4.0f kHz\n',...
            setADC.sampleRate/1e3, setADC.sampleRateTrue/1e3);
    end
    
    if ~isfield(setADC, 'sampleTime')
        setADC.sampleTime = 0.4;
        fprintf('Sample Time (setADC.sampleTime) not set.   Default to 0.1s\n');
    end
    
    %% Set up trigger
    % Condition trigger level
    if ~isfield(setADC, 'triggerLevel')
        setADC.triggerLevel = 128;
    end
    
    if abs(setADC.triggerLevel-255) > 255
        fprintf('Trigger Level Exceeds Maximum.             Clamp to +/- 255\n')
        setADC.triggerLevel = 255+255*sign(setADC.triggerLevel);
    end
    
    % Condition Trigger Source
    if isfield(setADC, 'triggerSource')
        setADC.trigger = 1;
        if strfind(setADC.triggerSource, 'B')
            setADC.triggerSource = TRIG_CHAN_B;
        elseif strfind(setADC.triggerSource, 'EX')
            setADC.triggerSource = TRIG_EXTERNAL;
        else
            setADC.triggerSource = TRIG_CHAN_A;
        end
    else
        setADC.triggerSource = TRIG_DISABLE;
        setADC.trigger = 0;
        fprintf('No trigger configuration provided.         Default to immediate capture\n');
    end
    
    % Condition Trigger Direction
    if isfield(setADC, 'triggerDirection')
        if strfind(setADC.triggerDirection, 'R')
            setADC.triggerDirection = TRIGGER_SLOPE_POSITIVE;
        elseif strfind(setADC.triggerDirection, 'F')
            setADC.triggerDirection = TRIGGER_SLOPE_NEGATIVE;
        end
    else
        setADC.triggerDirection = TRIGGER_SLOPE_POSITIVE;
    end

    if ~isfield(setADC, 'triggerDelay')
       setADC.triggerDelay = 0;
    end
    
    %% Setup channels to sample
    if ~isfield(setADC, 'channels')
       setADC.channelSelect = CHANNEL_A + CHANNEL_B;
       setADC.channels = 'CH_AB';
       setADC.numChannels = 2;
       fprintf('ADC channels (setADC.channels) not set     Default to CH_A + CH_B\n');
    elseif strfind(setADC.channels, 'AB')
       setADC.channelSelect = CHANNEL_A + CHANNEL_B;
       setADC.numChannels = 2;
    elseif strfind(setADC.channels, 'B')
       setADC.channelSelect = CHANNEL_B;
       setADC.numChannels = 1;
    else
        setADC.channelSelect = CHANNEL_A;
        setADC.numChannels = 1;
    end
    %% Setup data capture and storage
    % Check for file name (modeified NB)
    if ~isfield(setADC, 'fileName')
        setADC.fileName = 'data.bin';
    end
    
    % Setup buffer size
    if ~isfield(setADC, 'samplesPerBuffer')
        setADC.samplesPerBufferCh = 204800;
    else
        % Set buffer size to multiple of 4kb for faster write speed
        setADC.samplesPerBufferCh = 4096*ceil(setADC.samplesPerBuffer/4096);
    end

    
    %% Calculate actual capture time and buffer configuration
    % Desired number samples per channel
    desNumSamplesCh = uint32(floor(setADC.sampleRateTrue*setADC.sampleTime + 0.5));        
    desNumSamplesTotal = desNumSamplesCh * setADC.numChannels;
    
    % Each buffer includes samples from each enabled channel
    samplesPerBufferTotal = setADC.samplesPerBufferCh * setADC.numChannels;
    
    % Number of buffers is quantized (cannot collect fractional buffer)
    buffersPerAcqCh = uint32(floor((desNumSamplesTotal + samplesPerBufferTotal - 1) / samplesPerBufferTotal));
    
    % Sample time is determined by buffer quantization
    setADC.timePerBuffer = setADC.samplesPerBufferCh/setADC.sampleRateTrue;
    setADC.sampleTimeTrue = single(buffersPerAcqCh)*setADC.timePerBuffer;
    
    fprintf('Set to capture %2.0f buffers in %3.3f s\n', buffersPerAcqCh,setADC.sampleTimeTrue);
    %% Setup output trigger
    if isfield(setADC, 'triggerOutFunction')
        setADC.triggerOutReq = 1;
        
        % If user does not provide time for trigger out, trigger ASAP
        % during data capture
        if ~isfield(setADC, 'triggerOutDelay')
            setADC.triggerOutDelay = 0;
        end
        
        % Calculate when to activate trigger output. Trigger actions can be
        % taken only once after each buffer capture commences. The trigger
        % action is only guaranteed to occur during data capture if number
        % of buffers is greater than one.
      
        possibleTrigOutPoints = single([1:buffersPerAcqCh])./(single(buffersPerAcqCh));
        [~, bestPoint] = min(abs(possibleTrigOutPoints - setADC.triggerOutDelay));
        setADC.trigOutDelayTrue = possibleTrigOutPoints(bestPoint);
        setADC.trigOutBufferNum = setADC.trigOutDelayTrue*single(buffersPerAcqCh);
        setADC.trigOutTime = setADC.trigOutBufferNum*setADC.timePerBuffer;
        
        if setADC.trigOutDelayTrue == 1
            fprintf(strcat(['Warning: Trigger out action set to occur during last ',...
                'data capture buffer. \n    Data capture may conclude before ',...
                'trigger action occurs. Consider earlier trigger out, or reducing buffer size']));
        else
            fprintf('Trigger out will occur after buffer number %3.0f of %3.0f (@%3.3f sec)\n',...
                setADC.trigOutBufferNum, buffersPerAcqCh, setADC.trigOutTime);
        end
    else
        setADC.triggerOutReq = 0;
    end
    
    %% Setup miscellaneous timing settings
    if ~isfield(setADC,'timeoutForceTrigger')
        % Override trigger and commence capture after this time interval
        % Set to zero to wait for trigger indefinitely
        setADC.timeoutForceTrigger = 0;
    end
    
    if ~isfield(setADC, 'timeoutCapture')
        % This timeout determines when the API "gives up" waiting for a buffer
        % to be filled. This may occur due to lack of trigger event,
        % or failed data capture.
        setADC.timeoutCapture = 8;
    end
    if (setADC.timePerBuffer > setADC.timeoutCapture)
       fprintf('WARNING: Required buffer collection time is greater than buffer timeout limit \n');
       fprintf('          -> Increase timeoutCapture limit, or reduce buffer length \n')
    end
    %% Pass through formatted inputs
    % Configure the board's sample rate, input, and trigger settings
    if ~configureBoardDataCapture_NB(boardHandle, setADC)
        fprintf('Error: Board configuration failed\n');
        return
    end
    fprintf('ADC Configuration Set, Proceed to Capture\n\n');
    %% Acquire data
    if ~acquireDataNoTrig(boardHandle, setADC)
        fprintf('Error: Acquisition failed\n');
        return
    end
    
    statusReport = 1;
    setADCRun = setADC;
    setADCRun.statusReport = statusReport;
end