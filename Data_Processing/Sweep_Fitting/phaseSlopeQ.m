function Q_phase = phaseSlopeQ(varargin)
%Q_phase = phaseSlopeQ(phase,freq,phaseRes,freqFit,plotFlag)

%% process inputs

inputs = {[], [],0,.8,0};
inputs(1:nargin) = varargin;


 
phase = inputs{1};
freq = inputs{2};
freqRes = inputs{3};
freqFit = inputs{4};
plotFlag = inputs{5};

%% Analyze phase slope


mask = freq>(freqRes - freqFit/2) &  freq<(freqRes + freqFit/2);
mask2 = freq>(freqRes - freqFit*1.5) &  freq<(freqRes +freqFit*1.5);
fn = freqRes;

phase_lin = phase(mask);
freq_lin = freq(mask);
polymodel = polyfitn(freq_lin,phase_lin,{'constant', 'x'});
fnspan = linspace(min(freq(mask2)),max(freq(mask2)),300);
dphi_df = polymodel.Coefficients(2);
Q_phase = abs(dphi_df/2*fn);

%plot phase slope
if plotFlag
f2 = figure(200);clf
f2.Name = 'phaseSlopeQ';
plot(fnspan-fn,polyvaln(polymodel,fnspan),'r-');hold on;
plot(freq-fn,phase,'b.');hold on;
plot(freq_lin-fn,phase_lin,'g.');hold on;
xlabel('df (Hz)')
ylabel('phase (rad)')
prettyfig_NB('MS',10, 'LW',5);
end

end

