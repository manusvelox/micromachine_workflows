function fitObj = lorentzianFit(varargin)
%fitObj = lorentzianFit(amp, freq,tolFun,tolX)

%% process inputs

inputs = {[], [],1E-6,1E-6};
inputs(1:nargin) = varargin;


 
amp = inputs{1};
freq = inputs{2};
tolFun = inputs{3};
tolX = inputs{4};

%% write out model
gamma_0 = @(f0,Q) f0/2/Q;
lorentz = @(f0,Q,A,NF,freq) sqrt((A./(1 + ((freq-f0)./gamma_0(f0,Q)).^2)).^2 + ...
    NF.^2);



%% estimate intitial params
NF0 = mean(amp(1:floor(length(amp)/10)));
[maxVal,maxI] = max(amp);
fn0 = freq(maxI);
HP_thresh = NF0+(maxVal-NF0)/2;
lowerHalfPower = max(freq(and(freq<fn0,amp<HP_thresh)));
upperHalfPower = min(freq(and(freq>fn0,amp<HP_thresh)));

if isempty(upperHalfPower) 
    Q0 = fn0./2./abs(lowerHalfPower-fn0);
elseif isempty(lowerHalfPower)    
    Q0 = fn0./2./abs(upperHalfPower-fn0); 
elseif isempty(lowerHalfPower)  && isempty(upperHalfPower)    
    Q0 = 100;
else
Q0 = fn0./(upperHalfPower-lowerHalfPower);
end

A0 = maxVal;


C0 = [fn0, Q0, A0,NF0];

options = optimset('fminsearch');
options = optimset(options,'TolFun',tolFun);
options = optimset(options, 'TolX',tolX);
options = optimset(options, 'Display','none');


E = @(C) sum((amp-lorentz(C(1),C(2),C(3),C(4), freq)).^2 );
C = fminsearch(E,C0,options);


%%
fitObj.fn = C(1);
fitObj.Q = C(2);
fitObj.A = C(3);
fitObj.NF = C(4);
fitObj.handle = @(f) lorentz(C(1),C(2),C(3), C(4),f);




end