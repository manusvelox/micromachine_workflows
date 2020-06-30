function [output] = Sweep_Forward_NonkZI(freqs_forward,device,demod_c1,demod_c2,filter_TC,in_Ch,poll_length,poll_timeout)

%   Sweep forward in "freqs_forward" vector using demod_c1
deltaf = max(freqs_forward)-min(freqs_forward);
maxf = 10^-3*(max(freqs_forward)+deltaf/100);
minf = 10^-3*(min(freqs_forward)-deltaf/100);

for j=1:length(freqs_forward) %loop over parametric pump freqs; dont update center freq

    %Change pump frequency
    ziDAQ('setDouble',['/' device '/oscs/' demod_c1 '/freq'], freqs_forward(j)); %Hz, set oscillator 1 (pump) on-resonance
    %ziDAQ('setDouble',['/' device '/oscs/1/freq'], freqs_forward(j)); %Hz, set oscillator 1 (pump) on-resonance

    %Let the filter settle after changing the frequency:
    pause(3*filter_TC);

   %Acquire data
ziDAQ('unsubscribe','*');
ziDAQ('flush'); pause(0.1);
ziDAQ('subscribe',['/' device '/demods/' demod_c1 '/sample']); %Channel 1
ziDAQ('subscribe',['/' device '/demods/' demod_c2 '/sample']); %Channel 2
data = ziDAQ('poll', poll_length, poll_timeout ) ;
ziDAQ('unsubscribe','*');

%save data:

if in_Ch=='A' | in_Ch=='AB'
%Channel 1: Capacitive
datapath=strcat('data.',device,'.demods(1).sample') ; %Channel 1 data
output.forward.ChA.x(j)=mean(eval(strcat(datapath,'.x'))) ;
output.forward.ChA.y(j)=mean(eval(strcat(datapath,'.y'))) ;
output.forward.ChA.R(j)=sqrt(output.forward.ChA.x(j)^2+output.forward.ChA.y(j)^2) ;
output.forward.ChA.phi(j)=atan2d(output.forward.ChA.y(j),output.forward.ChA.x(j)) ;
output.forward.ChA.frequency(j)=mean(eval(strcat(datapath,'.frequency'))) ;

  %%  
    %Plot sweep   
    %Channel 1: Capacitive sweep:
    figure(1); subplot(2,1,1); hold on; scatter(output.forward.ChA.frequency(j)./10^3,output.forward.ChA.R(j),'b'); hold on;   
    xlim([minf maxf]);
    ylim([-inf inf]);
    figure(1); subplot(2,1,2); hold on; scatter(output.forward.ChA.frequency(j)./10^3,output.forward.ChA.phi(j),'b'); hold on;
    xlim([minf maxf]);
    ylim([-inf inf]);
end

if in_Ch=='B' | in_Ch=='AB'
%Channel 2: Piezoresistive
datapath=strcat('data.',device,'.demods(4).sample') ; %Channel 2 data
output.forward.ChB.x(j)=mean(eval(strcat(datapath,'.x'))) ;
output.forward.ChB.y(j)=mean(eval(strcat(datapath,'.y'))) ;
output.forward.ChB.R(j)=sqrt(output.forward.ChB.x(j)^2+output.forward.ChB.y(j)^2) ;
output.forward.ChB.phi(j)=atan2d(output.forward.ChB.y(j),output.forward.ChB.x(j)) ;
output.forward.ChB.frequency(j)=mean(eval(strcat(datapath,'.frequency'))) ;

  %%  
    %Plot sweep   
    %Channel 2: Piezoresistive sweep:
    figure(2); subplot(2,1,1); hold on; scatter(output.forward.ChB.frequency(j)./10^3,output.forward.ChB.R(j),'b') ;   
    figure(2); subplot(2,1,2); hold on; scatter(output.forward.ChB.frequency(j)./10^3,output.forward.ChB.phi(j),'b') ;
end
    
end %end loop over frequency (forward direction)


end

