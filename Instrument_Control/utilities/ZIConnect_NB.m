function   device = ZIConnect_NB( varargin )
%connect tio lock in, reset settings to basic config

inputs = {[0],[0]};
inputs(1:nargin) = varargin;


config = inputs{1}; 
imp50 = inputs{2};

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


%% setup measurment config

if config
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

%turn demod harm to 1 and phase to 0
ziDAQ('setDouble', ['/' device '/demods/*/harmonic'], 1);
ziDAQ('setDouble', ['/' device '/demods/*/phaseshift'], 0);

%set demod to corrrect input
ziDAQ('setInt', ['/' device '/demods/*/adcselect'], 0);

%set demod to correct osc
ziDAQ('setInt', ['/' device '/demods/0/oscselect'], 0);

%turn on data transfer for first demod
ziDAQ('setInt', ['/' device '/demods/0/enable'], 1);

%turn off PLLs
ziDAQ('setInt',['/' device '/PLLS/*/Enable'], 0);


end
end

