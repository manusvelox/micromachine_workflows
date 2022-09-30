function [result] = configureBoardDataCapture_NB(boardHandle, setADC)
% Configure sample rate, input, and trigger settings

%---------------------------------------------------------------------------
%
% Copyright (c) 2008-2013 AlazarTech, Inc.
%
% AlazarTech, Inc. licenses this software under specific terms and
% conditions. Use of any of the software or derivatives thereof in any
% product without an AlazarTech digitizer board is strictly prohibited.
%
% AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY,
% EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF
% MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. AlazarTech makes no
% guarantee or representations regarding the use of, or the results of the
% use of, the software and documentation in terms of correctness, accuracy,
% reliability, currentness, or otherwise; and you rely on the software,
% documentation and results solely at your own risk.
%
% IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF
% BUSINESS, LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL
% DAMAGES OF ANY KIND. IN NO EVENT SHALL ALAZARTECH%S TOTAL LIABILITY EXCEED
% THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED HEREUNDER.
%
%---------------------------------------------------------------------------

%call mfile with library definitions
AlazarDefs

% declare global variable used in acquireData.m
global SamplesPerSec

% set default return code to indicate failure
result = false;

% TODO: Specify the sample rate (pass through from run function)
SamplesPerSec = setADC.sampleRateTrue;

% TODO: Select clock parameters as required to generate this sample rate.
%
% Use internal 10MHz reference clock, scaled by value as set by run
% function
if setADC.externalClock == 0
retCode = ...
    calllib('ATSApi', 'AlazarSetCaptureClock', ...
        boardHandle,		...	% HANDLE -- board handle
        INTERNAL_CLOCK,		...	% U32 -- clock source id
        setADC.sampleCode,  ...	% U32 -- sample rate id
        CLOCK_EDGE_RISING,	...	% U32 -- clock edge id
        0					...	% U32 -- clock decimation 
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetCaptureClock failed -- %s\n', errorToText(retCode));
    return
end
elseif setADC.externalClock == 1
    retCode = ...
    calllib('ATSApi', 'AlazarSetCaptureClock', ...
        boardHandle,		...	% HANDLE -- board handle
        EXTERNAL_CLOCK_10MHz_REF,		...	% U32 -- clock source id
        setADC.sampleRate,  ...	% U32 -- sample rate id
        CLOCK_EDGE_RISING,	...	% U32 -- clock edge id
        1					...	% U32 -- clock decimation 
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetCaptureClock failed -- %s\n', errorToText(retCode));
    return
end

else
    fprintf('Error: clock config failed');
   
end

% TODO: Select CHA input parameters as required
retCode = ...
    calllib('ATSApi', 'AlazarInputControl', ...       
        boardHandle,		...	% HANDLE -- board handle
        CHANNEL_A,			...	% U8 -- input channel 
        DC_COUPLING,		...	% U32 -- input coupling id
        INPUT_RANGE_PM_400_MV, ...	% U32 -- input range id
        IMPEDANCE_50_OHM	...	% U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControl failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select CHB input parameters as required
retCode = ...
    calllib('ATSApi', 'AlazarInputControl', ...       
        boardHandle,		...	% HANDLE -- board handle
        CHANNEL_B,			...	% U8 -- channel identifier
        DC_COUPLING,		...	% U32 -- input coupling id
        INPUT_RANGE_PM_400_MV,	...	% U32 -- input range id
        IMPEDANCE_50_OHM	...	% U32 -- input impedance id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarInputControl failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select trigger inputs and levels as required
retCode = ...
    calllib('ATSApi', 'AlazarSetTriggerOperation', ...       
        boardHandle,		...	% HANDLE -- board handle
        TRIG_ENGINE_OP_J,	...	% U32 -- trigger operation 
        TRIG_ENGINE_J,		...	% U32 -- trigger engine id
        setADC.triggerSource,...	% U32 -- trigger source id
        setADC.triggerDirection,	... % U32 -- trigger slope id
        setADC.triggerLevel,...	% U32 -- trigger level from 0 (-range) to 255 (+range)
        TRIG_ENGINE_K,		...	% U32 -- trigger engine id
        TRIG_DISABLE,		...	% U32 -- trigger source id for engine K
        TRIGGER_SLOPE_POSITIVE, ...	% U32 -- trigger slope id
        128					...	% U32 -- trigger level from 0 (-range) to 255 (+range)
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetTriggerOperation failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Select external trigger parameters as required
retCode = ...
    calllib('ATSApi', 'AlazarSetExternalTrigger', ...       
        boardHandle,		...	% HANDLE -- board handle
        DC_COUPLING,		...	% U32 -- external trigger coupling id
        ETR_2V5				...	% U32 -- external trigger range id
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetExternalTrigger failed -- %s\n', errorToText(retCode));
    return
end
    
% TODO: Set trigger delay as required.

triggerDelay_sec = setADC.triggerDelay;
triggerDelay_samples = uint32(floor(triggerDelay_sec * SamplesPerSec + 0.5));
retCode = calllib('ATSApi', 'AlazarSetTriggerDelay', boardHandle, triggerDelay_samples);
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetTriggerDelay failed -- %s\n', errorToText(retCode));
    return;
end

% TODO: Set trigger timeout as required. 

% NOTE:
% The board will wait for a for this amount of time for a trigger event. 
% If a trigger event does not arrive, then the board will automatically 
% trigger. Set the trigger timeout value to 0 to force the board to wait 
% forever for a trigger event.
%
% IMPORTANT: 
% The trigger timeout value should be set to zero after appropriate 
% trigger parameters have been determined, otherwise the 
% board may trigger if the timeout interval expires before a 
% hardware trigger event arrives.
triggerTimeout_sec = setADC.timeoutForceTrigger;
triggerTimeout_clocks = uint32(floor(triggerTimeout_sec / 10.e-6 + 0.5));
retCode = ...
    calllib('ATSApi', 'AlazarSetTriggerTimeOut', ...       
        boardHandle,            ...	% HANDLE -- board handle
        triggerTimeout_clocks	... % U32 -- timeout_sec / 10.e-6 (0 == wait forever)
        );
if retCode ~= ApiSuccess
    fprintf('Error: AlazarSetTriggerTimeOut failed -- %s\n', errorToText(retCode));
    return
end

% TODO: Configure AUX I/O connector as required
retCode = ...
    calllib('ATSApi', 'AlazarConfigureAuxIO', ...       
        boardHandle,		...	% HANDLE -- board handle
        AUX_OUT_TRIGGER,	...	% U32 -- mode
        0					...	% U32 -- parameter
        );	
if retCode ~= ApiSuccess
    fprintf('Error: AlazarConfigureAuxIO failed -- %s\n', errorToText(retCode));
    return 
end

result = true;