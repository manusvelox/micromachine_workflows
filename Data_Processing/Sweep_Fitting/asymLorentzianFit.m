function fitObj = asymLorentzianFit(varargin)
%fitObj = asymLorentzianFit(amp, freq,tolFun,tolX,forceZero)

%% process inputs

inputs = {[], [],1E-6,1E-6,1};
inputs(1:nargin) = varargin;


 
amp = inputs{1};
freq = inputs{2};
tolFun = inputs{3};
tolX = inputs{4};

%% write out model
gamma_0 = @(f0,Q) f0/2/Q;
gamma = @(f0,a,Q,freq) 2*gamma_0(f0,Q)./(1+ exp(a*(freq-f0)));
lorentz = @(f0,Q,A,a,freq) A./(1 + ((freq-f0)./gamma(f0,a,Q,freq)).^2);



%% estimate intitial params
[maxVal,maxI] = max(amp);
fn0 = freq(maxI);
lowerHalfPower = max(freq(and(freq<fn0,amp<maxVal/2)));
upperHalfPower = min(freq(and(freq>fn0,amp<maxVal/2)));
Q0 = fn0/(upperHalfPower-lowerHalfPower);
a0 = 0;
A0 = maxVal;

C0 = [fn0, Q0, A0,a0];

options = optimset('fminsearch');
options = optimset(options,'TolFun',tolFun);
options = optimset(options, 'TolX',tolX);


E = @(C) sum((amp-lorentz(C(1),C(2),C(3),C(4),freq)).^2 );
C = fminsearch(E,C0,options);


%%
fitObj.fn = C(1);
fitObj.Q = C(2);
fitObj.A = C(3);
fitObj.a = C(4);
fitObj.handle = @(f) lorentz(C(1),C(2),C(3),C(4),f)




end