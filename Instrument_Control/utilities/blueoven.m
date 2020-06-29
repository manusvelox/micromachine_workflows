function retval = blueoven(command,temperature,gpib)
%RETVAL = BLUEOVEN('COMMAND',TEMPERATURE,GPIB)
%
% Use blueoven to control a Thermotron S1.2 thermal chamber with the 2800
%  controller (a "Blue Oven").
% blueoven simplifies the basic commands for the blue oven using
%  the kpib functions. The GPIB address is hardwired.
%
% 'command' may be one of the following:
%
% 'init'    Initialize the oven
% 'set'     Set the oven temperature setpoint to TEMPERATURE (C) [default]
% 'read'    Returns the oven temperature (C)
% 'stop'    Stops the oven program and unlocks the keypad
%
% Example:
%  To set the temperature setpoint to 60C, use:
%    blueoven('set',60);
%
% Requires: kpib v2.9+
%
% 
% M.A. Hopcroft
%  matt.hopcroft@cantab.net
%
% MH AUG2006
% v1.3 made 'read' the default command
%

% MH JUL2006
%  v1.22 updated to kpib 2.9
%
% v1.2 MH MAR2006 added default to 'set'
% v1.1 MH JUL2005
% v1.0 MH AUG2004
%

%GPIB address
if nargin < 3
    gpib=6; % 5 = B1, 6 = B2, 7 = B3
end

%RETVAL = KPIB('INSTRUMENT', gpib, 'COMMAND', VALUE, CHANNEL, AUX, VERBOSE)

if (nargin == 0)
    command='read';
elseif isnumeric(command)
    temperature=command;
    command='set';
end
switch command
    case {'init','INIT','initialize'}
        fprintf(1,'\n  %s\n', 'Clearing all MATLAB gpib objects.');
        kpib('clear',0,'0',0,0,0,0);    
        fprintf(1,'\n  %s %d\n', 'Initializing Blue Oven at gpib address:',gpib);
        % do a soft reset
        kpib('BlueOven',gpib,'init',1,0,0,0);
        fprintf(1,'\n  %s\n  %s\n\n', 'Done.','Make sure that the oven is plugged in AND switched on.');
    case {'set','SET','setpoint','temperature','temp'}
        temperature=round(temperature); % whole numbers only, please
        kpib('BlueOven',gpib,'set',temperature,0,0,0);
        pause(1);
        oven=kpib('BlueOven',gpib,'set','?',0,0,0);
        fprintf(1,'\n  %s %.1f %s\n\n', 'Blue Oven temperature setpoint:',oven,'C');
        kpib('BlueOven',gpib,'lock',0,0,0,0);
    case {'read','READ','value'}
        retval=kpib('BlueOven',gpib,'read',0,0,0,0);
        fprintf(1,'\n  %s %.1f %s\n\n', 'Blue Oven temperature:',retval,'C');
    case {'stop','STOP'}
        kpib('BlueOven',gpib,'stop',0,0,0,0);
        fprintf(1,'\n  %s\n\n', 'Blue Oven stopped and keypad unlocked.');
    otherwise
        fprintf(1,'  \n  %s\n\n','blueoven Error: command not recognized or temperature not specified.');
end
