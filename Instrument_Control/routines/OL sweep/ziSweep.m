function sweepdata = ziSweep(dev,startf, stopf, points, quality, plotflag)
    %% sweeps first demodulator using thje Zurich sweep module 

    %% setup sweeper
    sweephandle = ziDAQ('sweep');
    ziDAQ('get', sweephandle, 'sweep/xmapping');
    ziDAQ('set', sweephandle, 'sweep/xmapping', 1);
    ziDAQ('get', sweephandle, 'sweep/start');
    ziDAQ('get', sweephandle, 'sweep/stop');
    ziDAQ('get', sweephandle, 'sweep/scan');
    ziDAQ('get', sweephandle, 'sweep/samplecount');
    ziDAQ('get', sweephandle, 'sweep/loopcount');
    ziDAQ('get', sweephandle, 'sweep/gridnode');
    ziDAQ('get', sweephandle, 'sweep/settling/time');
    ziDAQ('get', sweephandle, 'sweep/settling/inaccuracy');
    ziDAQ('get', sweephandle, 'sweep/averaging/sample');
    ziDAQ('get', sweephandle, 'sweep/averaging/time');
    ziDAQ('get', sweephandle, 'sweep/averaging/tc');
    ziDAQ('get', sweephandle, 'sweep/bandwidth');
    ziDAQ('get', sweephandle, 'sweep/maxbandwidth');
    ziDAQ('get', sweephandle, 'sweep/bandwidthoverlap');
    ziDAQ('get', sweephandle, 'sweep/omegasuppression');
    ziDAQ('get', sweephandle, 'sweep/bandwidthcontrol');
    ziDAQ('get', sweephandle, 'sweep/save/save');
    ziDAQ('get', sweephandle, 'sweep/save/directory');
    ziDAQ('get', sweephandle, 'sweep/order');
    ziDAQ('get', sweephandle, 'sweep/phaseunwrap');
    ziDAQ('get', sweephandle, 'sweep/sincfilter');
    ziDAQ('get', sweephandle, 'sweep/awgcontrol');
    ziDAQ('set', sweephandle, 'sweep/device', dev);
    ziDAQ('set', sweephandle, 'sweep/historylength', 100);
    ziDAQ('get', sweephandle, 'sweep/remainingtime');
    ziDAQ('get', sweephandle, 'sweep/historylength');
    ziDAQ('get', sweephandle, 'sweep/settling/tc');
    
    %% set freqs and points
    ziDAQ('set', sweephandle, 'sweep/start', startf);
    ziDAQ('set', sweephandle, 'sweep/stop', stopf);
    ziDAQ('set', sweephandle, 'sweep/samplecount', points);
    
    %% set quality
    
    
    
    switch quality
        case 'low'
            ziDAQ('setDouble', ['/' dev '/demods/0/rate'], 1000);
            ziDAQ('set', sweephandle, 'sweep/omegasuppression', 40.0000000);
            ziDAQ('set', sweephandle, 'sweep/order', 8);
            ziDAQ('set', sweephandle, 'sweep/settling/inaccuracy', 0.0001000);
            ziDAQ('set', sweephandle, 'sweep/settling/time', 0.0500000);
            ziDAQ('set', sweephandle, 'sweep/averaging/sample', 20);
            ziDAQ('set', sweephandle, 'sweep/averaging/tc', 15.0000000);
            ziDAQ('set', sweephandle, 'sweep/averaging/time', 0.0200000);
            ziDAQ('set', sweephandle, 'sweep/maxbandwidth', 100.0000000);
            ziDAQ('set', sweephandle, 'sweep/bandwidthoverlap', 1);
            ziDAQ('set', sweephandle, 'sweep/order', 8);
            ziDAQ('set', sweephandle, 'sweep/bandwidthcontrol', 2);
            ziDAQ('set', sweephandle, 'sweep/phaseunwrap',1);
        case 'med'
            ziDAQ('setDouble', ['/' dev '/demods/0/rate'], 1000);
            ziDAQ('set', sweephandle, 'sweep/omegasuppression', 40.0000000);
            ziDAQ('set', sweephandle, 'sweep/order', 8);
            ziDAQ('set', sweephandle, 'sweep/settling/inaccuracy', 0.0001000);
            ziDAQ('set', sweephandle, 'sweep/settling/time', 0.0800000);
            ziDAQ('set', sweephandle, 'sweep/averaging/sample', 20);
            ziDAQ('set', sweephandle, 'sweep/averaging/tc', 25.0000000);
            ziDAQ('set', sweephandle, 'sweep/averaging/time', 0.0800000);
            ziDAQ('set', sweephandle, 'sweep/maxbandwidth', 50.0000000);
            ziDAQ('set', sweephandle, 'sweep/bandwidthoverlap', 1);
            ziDAQ('set', sweephandle, 'sweep/order', 8);
            ziDAQ('set', sweephandle, 'sweep/bandwidthcontrol', 2);
            ziDAQ('set', sweephandle, 'sweep/phaseunwrap',1);
            
        case 'high'
            ziDAQ('setDouble', ['/' dev '/demods/0/rate'], 100);
            ziDAQ('set', sweephandle, 'sweep/omegasuppression', 40.0000000);
            ziDAQ('set', sweephandle, 'sweep/order', 8);
            ziDAQ('set', sweephandle, 'sweep/settling/inaccuracy', 0.0001000);
            ziDAQ('set', sweephandle, 'sweep/settling/time', 0.100000);
            ziDAQ('set', sweephandle, 'sweep/averaging/sample', 100);
            ziDAQ('set', sweephandle, 'sweep/averaging/tc', 50.0000000);
            ziDAQ('set', sweephandle, 'sweep/averaging/time', 0.1000000);
            ziDAQ('set', sweephandle, 'sweep/maxbandwidth', 10.0000000);
            ziDAQ('set', sweephandle, 'sweep/bandwidthoverlap', 1);
            ziDAQ('set', sweephandle, 'sweep/order', 8);
            ziDAQ('set', sweephandle, 'sweep/bandwidthcontrol', 2);
            ziDAQ('set', sweephandle, 'sweep/phaseunwrap',1);
        otherwise
            warning('quality not recognized, using med')
            ziDAQ('set', sweephandle, 'sweep/omegasuppression', 40.0000000);
            ziDAQ('set', sweephandle, 'sweep/order', 8);
            ziDAQ('set', sweephandle, 'sweep/settling/inaccuracy', 0.0001000);
            ziDAQ('set', sweephandle, 'sweep/settling/time', 0.0100000);
            ziDAQ('set', sweephandle, 'sweep/averaging/sample', 20);
            ziDAQ('set', sweephandle, 'sweep/averaging/tc', 25.0000000);
            ziDAQ('set', sweephandle, 'sweep/averaging/time', 0.0200000);
            ziDAQ('set', sweephandle, 'sweep/maxbandwidth', 50.0000000);
            ziDAQ('set', sweephandle, 'sweep/bandwidthoverlap', 1);
            ziDAQ('set', sweephandle, 'sweep/order', 8);
            ziDAQ('set', sweephandle, 'sweep/bandwidthcontrol', 2);
            ziDAQ('set', sweephandle, 'sweep/phaseunwrap',1);
    end
    
    %% execute sweep
    ziDAQ('subscribe', sweephandle, ['/'  dev '/demods/0/sample']);
    ziDAQ('execute', sweephandle);
    
    datapath=strcat('result.',dev,'.demods.sample{1}');

    result = [];
    while ~ziDAQ('finished', sweephandle)
      pause(.1);
      result = ziDAQ('read', sweephandle);
      %fprintf('Progress %0.0f%%\n', ziDAQ('progress', sweephandle) * 100);
      
      if plotflag
          try
              sweepdata = eval(datapath);
              R = sweepdata.r;
              phase = sweepdata.phase;
              freq = sweepdata.frequency;
              mask = ~isnan(R);

              f = figure(978);
              subplot(2,1,1)
              plot(freq(mask),R(mask),'b*');
              ylabel('Amp (V)')
              xlim([startf stopf]);
              subplot(2,1,2)
              plot(freq(mask),phase(mask),'b*');
              xlim([startf stopf]);
              xlabel('freq (Hz)')
              ylabel('phase (rad)');
          catch exception
              warning('wtf is up with reading the data??')
          end
              

   
      end

    end

    sweepdata = eval(datapath);
    
    if plotflag
        R = sweepdata.r;
        phase = sweepdata.phase;
        freq = sweepdata.frequency;

        f = figure(978);
        subplot(2,1,1)
        plot(freq,R,'b*');
        ylabel('Amp (V)')
        xlim([startf stopf]);
        subplot(2,1,2)
        plot(freq,phase,'b*');
        xlim([startf stopf]);
        xlabel('freq (Hz)')
        ylabel('phase (rad)');
    
      
      
    end 

end