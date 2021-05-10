function fitObj = lorentzianFit(varargin)
%fitObj = asymLorentzianFit(amp, freq)

%% process inputs

inputs = {[], [],1E-6,1E-6};
inputs(1:nargin) = varargin;


 
amp = inputs{1};
freq = inputs{2};
tolFun = inputs{3};
tolX = inputs{4};

%% write out model
gamma_0 = @(f0,Q) f0/2/Q;
lorentz = @(f0,Q,A,freq) A./(1 + ((freq-f0)./gamma_0(f0,Q)).^2);



%% estimate intitial params
[maxVal,maxI] = max(amp);
fn0 = freq(maxI);
lowerHalfPower = max(freq(and(freq<fn0,amp<maxVal/2)));
upperHalfPower = min(freq(and(freq>fn0,amp<maxVal/2)));
Q0 = fn0/(upperHalfPower-lowerHalfPower);
A0 = maxVal;

C0 = [fn0, Q0, A0];

options = optimset('fminsearch');
options = optimset(options,'TolFun',tolFun);
options = optimset(options, 'TolX',tolX);


E = @(C) sum((amp-lorentz(C(1),C(2),C(3),freq)).^2 );
C = fminsearch(E,C0,options);


%%
fitObj.fn = C(1);
fitObj.Q = C(2);
fitObj.A = C(3);
fitObj.handle = @(f) lorentz(C(1),C(2),C(3),f)




end