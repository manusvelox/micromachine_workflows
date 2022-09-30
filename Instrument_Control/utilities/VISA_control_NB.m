function retval = VISA_control_NB(instrument, addr,command, value, channel, aux, verbose)
validInst = 0; % validInst will be set if a valid instrument has been called.
retval=0;

%% input parsing
    verbose_default = 2;
    if nargin < 7, verbose = verbose_default; end % verbose default
    if nargin < 6, aux = 0; end
    if nargin < 5, channel = 0; end
    if nargin < 4, value = 0; end
    if nargin < 3, command = 'none'; end
    if verbose >= 3
    fprintf(1,'kpib: (REGULAR) %s/%s/%s/%s/%s/%s/%s\n',instrument,num2str(GPIB),num2str(command),num2str(value),num2str(channel),num2str(aux),num2str(verbose));
    end
%% begin instrument code
if strcmpi(instrument,'SDG_2000X')

    io = visa_open(addr, instrument, verbose);
    if (io ~=0) && (strcmp(get(io,'Status'),'open') ~=0)

            
        switch command
            case 'reset'
                fprintf(io,'*RST');
            case {'output','out'}
                switch value
                    case {'on','ON'}
                        write(io,sprintf('C%u:OUTP ON',channel));
                    case {'off','OFF'}
                        write(io,sprintf('C%u:OUTP OFF',channel));
                    case {'?','query'}
                        sprintf('C%u:OUTP?',channel)
                        retval = writeread(io,sprintf('C%u:OUTP?',channel));
                    case {'load','imp'}
                        write(io,sprintf('C%u:OUTP LOAD,%s',channel, aux));
                end
            case {'basic','wave'}
                switch value
                    case {'?','query'}
                        retval = writeread(io,sprintf('C%u:OUTP?',channel));
                    case {'WVTP','type'}
                        %{SINE, SQUARE, RAMP, PULSE, NOISE, ARB, DC, PRBS}.
                        write(io,sprintf('C%u:BSWV %s',channel,aux));
                    case {'freq'}
                        write(io, sprintf('C%u:BSWV FRQ,%d',channel,aux));
                    case {'amp'}
                        % in Vpp
                        write(io, sprintf('C%u:BSWV AMP,%d',channel,aux));
                    case {'offset','off'}
                        write(io, sprintf('C%u:BSWV OFST,%d',channel,aux));
                    case {'phase'}
                        %in degrees
                        write(io, sprintf('C%u:BSWV PHSE,%d',channel,aux));
                    case {'stdev'}
                        write(io, sprintf('C%u:BSWV STDEV,%d',channel,aux));
                    case {'mean'}
                        write(io, sprintf('C%u:BSWV MEAN,%d',channel,aux));
                end
            case {'sweep'}
                switch value
                    case{'state'}
                    case{'time'}
                    case{'start'}
                    case{'stop'}
                    case{'mode','SWMD'}
                    case{'dir'}
                end
            case {'burst'}
                switch value
                    case{'?','query'}
                        retval = writeread(io,sprintf('C%u:BTWV?',channel));
                    case{'state'}
                        write(io, sprintf('C%u:BTWV STATE,%s',channel,aux));
                    case{'period','PRD'}
                        write(io, sprintf('C%u:BTWV PRD,%d',channel,aux));
                    case{'STPS','start_phase'}
                        write(io, sprintf('C%u:BTWV STPS,%d',channel,aux));
                    case{'mode','GATE_NCYC'}
                        %{GATE, NCYC}.
                        write(io, sprintf('C%u:BTWV GATE_NCYC,%s',channel,aux));
                    case{'time','NCYC'}
                        write(io, sprintf('C%u:BTWV TIME,%u',channel,aux));
                    case{'trigger','TRSR'}
                        %{EXT, INT, MAN}
                        write(io, sprintf('C%u:BTWV TRSR,%s',channel,aux));
                    case{'TRMD'}
                        %{RISE, FALL, OFF}
                        write(io, sprintf('C%u:BTWV TRMD,%s',channel,aux));
                    case{'edge'}
                        %{RISE, FALL}
                        write(io, sprintf('C%u:BTWV EDGE,%s',channel,aux));
                    case{'MTRIG'}
                        write(io, sprintf('C%u:BTWV MTRIG',channel));
                    case{'WVTP'}
                        write(io, sprintf('C%u:BTWV CARR,WVTP,%s',channel,aux));
                    case{'freq'}
                        write(io, sprintf('C%u:BTWV CARR,FRQ,%d',channel,aux));
                    case{'phase'}
                        write(io, sprintf('C%u:BTWV CARR,PHSE,%d',channel,aux));
                    case{'amp'}
                        write(io, sprintf('C%u:BTWV CARR,AMP,%d',channel,aux));
                    case{'offset'}
                        write(io, sprintf('C%u:BTWV CARR, OFST,%d',channel,aux));
                end

                
%% ^^^^                
            case {'sin','sine','SIN'}
                if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Sine wave: %g Hz, %g ',value,channel); end
                if any(strcmpi(aux,{'VPP','VRMS','DBM'}))
                    cmd=sprintf('APPLY:SIN %d, %d %s',value,channel,upper(aux)); fprintf(io,cmd);
                    if verbose >= 2, fprintf(1, '%s\n',aux); end
                    %fprintf(io,'APPLY:SIN %d, %d, %d',[value,channel,aux]);
                else
                    fprintf(io,'APPLY:SIN %d, %d, %d',[value,channel,aux]);
                    if verbose >= 2, fprintf(1, 'V, %g V (offset)\n',aux); end
                end
                %if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Sine wave: %g Hz %s\n',channel,value,aux); end
                
            case {'square','SQU'}
                if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Square wave: %g Hz, %g ',value,channel); end
                if any(strcmpi(aux,{'VPP','VRMS','DBM'}))
                    cmd=sprintf('APPLY:SQU %d, %d %s',value,channel,upper(aux)); fprintf(io,cmd);
                    if verbose >= 2, fprintf(1, '%s\n',aux); end
                else
                    fprintf(io,'APPLY:SQU %d, %d, %d',[value,channel,aux]);
                    if verbose >= 2, fprintf(1, 'V, %g V (offset)\n',aux); end
                end
                
            case {'triangle','TRI'}
                if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Triangle wave: %g Hz, %g ',value,channel); end
                if any(strcmpi(aux,{'VPP','VRMS','DBM'}))
                    cmd=sprintf('APPLY:TRI %d, %d %s',value,channel,upper(aux)); fprintf(io,cmd);
                    if verbose >= 2, fprintf(1, '%s\n',aux); end
                else
                    fprintf(io,'APPLY:TRI %d, %d, %d',[value,channel,aux]);
                    if verbose >= 2, fprintf(1, 'V, %g V (offset)\n',aux); end
                end
                
            case {'ramp','RAMP','saw'}
                if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Ramp wave: %g Hz, %g ',value,channel); end
                if any(strcmpi(aux,{'VPP','VRMS','DBM'}))
                    cmd=sprintf('APPLY:RAMP %d, %d %s',value,channel,upper(aux)); fprintf(io,cmd);
                    if verbose >= 2, fprintf(1, '%s\n',aux); end
                else
                    fprintf(io,'APPLY:RAMP %d, %d, %d',[value,channel,aux]);
                    if verbose >= 2, fprintf(1, 'V, %g V (offset)\n',aux); end
                end
                
            case {'noise','NOISE'}
                if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Noise: %g Hz, %g ',value,channel); end
                if any(strcmpi(aux,{'VPP','VRMS','DBM'}))
                    cmd=sprintf('APPLY:NOISE %d, %d %s',value,channel,upper(aux)); fprintf(io,cmd);
                    if verbose >= 2, fprintf(1, '%s\n',aux); end
                else
                    fprintf(io,'APPLY:NOISE %d, %d, %d',[value,channel,aux]);
                    if verbose >= 2, fprintf(1, 'V, %g V (offset)\n',aux); end
                end                
                
            case 'DC'
                fprintf(io,'APPLY:DC DEF, DEF, %d',value);
                if verbose >= 2, fprintf(1, 'kpib/HP_33120A: DC voltage: %g V\n',value); end

            case 'burst' % set burst mode
                switch value
                    case {'on','ON'}
                        %fprintf(io,'BM:MODE TRIG');
                        fprintf(io,'BM:STATE ON');
                        if verbose >= 1, fprintf(1, 'kpib/HP_33120A: Burst mode enabled.\n'); end
                        if verbose >= 2,
                            fprintf(io,'FUNCTION?')
                            func=fscanf(io);
                            fprintf(1, 'kpib/HP_33120A: Burst mode function: %s.\n',func);
                        end
                    case {'off','OFF'}
                        fprintf(io,'BM:STATE OFF');
                        if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Burst mode disabled\n'); end
                    case {'mode','type'}
                        switch channel
                            case {'imm','immediate'}
                                fprintf(io,'TRIGGER:SOURCE IMM');
                                if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Burst mode trigger set to "immediate" (when burst ''on'')\n'); end
                            case {'ext','external'}
                                fprintf(io,'TRIGGER:SOURCE EXT');
                                if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Burst mode trigger set to "external"\n'); end
                            case {'bus','software','kpib'}
                                fprintf(io,'TRIGGER:SOURCE BUS');
                                if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Burst mode trigger set to "bus" (use ''burst'',''trigger'')\n'); end
                            otherwise
                                if verbose >= 1, fprintf(1, 'kpib/HP_33120A: Burst mode command (CHANNEL) not undestood.\n'); end
                        end
                        if isnumeric(aux) && aux > 0
                            fprintf(io,'BM:NCYCLES %d',aux);
                            if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Burst mode set for %d cycles.\n',aux); end
                        else
                            if verbose >= 1, fprintf(1, 'kpib/HP_33120A: Error: use AUX to specify number of cycles per burst (1 - 50e3).\n'); end
                        end
                    case {'trigger','now','start','trig'}
                        fprintf(io,'*TRG'); % initiate a burst
                    case 'phase'
                        if isnumeric(channel) && channel >= 0
                            fprintf(io,'BM:PHASE %d',channel);
                            if verbose >= 2, fprintf(1, 'kpib/AG_33120A: Burst mode set for %d degrees phase.\n',channel); end
                        end
                    case 'rate'
                        if isnumeric(channel) && channel >= 0
                            fprintf(io,'BM:INT:RATE %d',channel);
                            if verbose >= 2, fprintf(1, 'kpib/AG_33120A: Burst mode set for %d Hz Rate.\n',channel); end
                        end
                    otherwise
                        if isnumeric(value) && value > 0 && value < 50e3
                            fprintf(io,'BM:NCYCLES %d',value);
                            if verbose >= 2, fprintf(1, 'kpib/HP_33120A: Burst mode set for %d cycles.\n',aux); end
                        end
                end                
                
            case {'freq','frequency'}
                fprintf(io,'FREQ %d',value);
                if verbose >= 2, fprintf('kpib/HP_33120A: Output frequency set to %g Hz\n',value); end
            
            case {'amp','amplitude','setV','volt','VOLT'} % special case for setting output voltage
                fprintf(io,'VOLT %d',value); % sets the units of the current function (Vpp, Vrms, etc)
                if verbose >= 2, fprintf('kpib/HP_33120A: Output amplitude set to %g V\n',value); end

            case {'offset','dclevel'}
                fprintf(io,'VOLT:OFFSET %d',value); % in volts
                if verbose >= 2, fprintf('kpib/HP_33120A: Voltage offset (DC level) set to %g V\n',value); end
                
            case {'read'} % reading output voltage
                if any(strcmpi(aux,{'VPP','VRMS','DBM'}))
                    fprintf(io,'VOLT:UNIT %s',aux);
                else
                    fprintf(io,'VOLT:UNIT?');
                    aux = fscanf(io,'%s');
                    if ~strcmp(aux,'VPP') && verbose >=1
                        fprintf('kpib/HP_33120A: WARNING: units of %s, not Volts p-p. Use AUX to set units.\n',aux);
                    end
                end
                fprintf(io,'VOLT?'); % reads the units of the current function (Vpp, Vrms, etc)
                retval = fscanf(io,'%e');
                if verbose >= 2, fprintf('kpib/HP_33120A: Output amplitude reads %g %s\n',retval,aux); end

            %The duty cycle setting only applies to square waves.
            case {'dcycle','dutycycle','DCYC'}
                if isequal(value,'min')
                   fprintf(io,'PULS:DCYC MIN');
               elseif isequal(value,'max')
                   fprintf(io,'PULS:DCYC MAX');
               else
                   fprintf(io,'PULS:DCYC %d',value);
                   if verbose >= 2, fprintf('kpib/HP_33120A: Duty cycle set to %d%%\n',value); end
               end
            otherwise
                if verbose >= 1, fprintf('kpib/HP_33120A: Error, command not supported. ["%s"]\n',command); end
        end
                
    else % catch incorrect address errors
       if verbose >= 1, fprintf('kpib/%s: ERROR: No instrument at adress %d\n',instrument,addr); end
       retval=0;
    end
    
    validInst = 1;    
 end % end SDG_2000x

%% utility functions
function io = visa_open(addr, instrument, verbose)
    io = visadev(addr);
end


end