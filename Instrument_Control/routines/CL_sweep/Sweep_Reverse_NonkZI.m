function [output] = Sweep_Reverse_NonkZI(freqs_back,device,demod_c1,demod_c2,filter_TC,in_Ch,poll_length,poll_timeout)

%   Sweep forward in "freqs_forward" vector using demod_c1


for j=1:length(freqs_back) %loop over parametric pump freqs; dont update center freq

    %Change pump frequency
    ziDAQ('setDouble',['/' device '/oscs/' demod_c1 '/freq'], freqs_back(j)); %Hz, set oscillator 1 (pump) on-resonance

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
output.reverse.ChA.x(j)=mean(eval(strcat(datapath,'.x'))) ;
output.reverse.ChA.y(j)=mean(eval(strcat(datapath,'.y'))) ;
output.reverse.ChA.R(j)=sqrt(output.reverse.ChA.x(j)^2+output.reverse.ChA.y(j)^2) ;
output.reverse.ChA.phi(j)=atan2d(output.reverse.ChA.y(j),output.reverse.ChA.x(j)) ;
output.reverse.ChA.frequency(j)=mean(eval(strcat(datapath,'.frequency'))) ;

  %%  
    %Plot sweep   
    %Channel 1: Capacitive sweep:
    figure(1); subplot(2,1,1); hold on; scatter(output.reverse.ChA.frequency(j)./10^3,output.reverse.ChA.R(j),'r') ;   
    figure(1); subplot(2,1,2); hold on; scatter(output.reverse.ChA.frequency(j)./10^3,output.reverse.ChA.phi(j),'r') ;

end

if in_Ch=='B' | in_Ch=='AB'
%Channel 2: Piezoresistive
datapath=strcat('data.',device,'.demods(4).sample') ; %Channel 2 data
output.reverse.ChB.x(j)=mean(eval(strcat(datapath,'.x'))) ;
output.reverse.ChB.y(j)=mean(eval(strcat(datapath,'.y'))) ;
output.reverse.ChB.R(j)=sqrt(output.reverse.ChB.x(j)^2+output.reverse.ChB.y(j)^2) ;
output.reverse.ChB.phi(j)=atan2d(output.reverse.ChB.y(j),output.reverse.ChB.x(j)) ;
output.reverse.ChB.frequency(j)=mean(eval(strcat(datapath,'.frequency'))) ;

  %%  
    %Plot sweep   
    %Channel 2: Piezoresistive sweep:
    figure(2); subplot(2,1,1); hold on; scatter(output.reverse.ChB.frequency(j)./10^3,output.reverse.ChB.R(j),'r') ;   
    figure(2); subplot(2,1,2); hold on; scatter(output.reverse.ChB.frequency(j)./10^3,output.reverse.ChB.phi(j),'r') ;
end
    
end %end loop over frequency (forward direction)


end

