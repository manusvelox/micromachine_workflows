function fitObj = asymLorentzianFit(varargin)
%fitObj = asymLorentzianFit(amp, freq,tolFun,tolX)

%% process inputs

inputs = {[], [],1E-6,1E-6};
inputs(1:nargin) = varargin;


 
amp = inputs{1};
freq = inputs{2};
tolFun = inputs{3};
tolX = inputs{4};

%% write out model
gamma_0 = @(f0,Q) f0/2/Q;
gamma = @(f0,a,Q,freq) 2*gamma_0(f0,Q)./(1+ exp(a*(freq-f0)));
lorentz = @(f0,Q,A,a,NF,freq) sqrt((A./(1 + ((freq-f0)./gamma(f0,a,Q,freq)).^2)).^2+...
    NF.^2);



%% estimate intitial params

initFitObj = lorentzianFit(amp, freq);

a0 = 0.1;

C0 = [initFitObj.fn, initFitObj.Q, initFitObj.A,a0, initFitObj.NF];

options = optimset('fminsearch');
options = optimset(options,'TolFun',tolFun);
options = optimset(options, 'TolX',tolX);
options = optimset(options, 'Display','none');



E = @(C) sum((amp-lorentz(C(1),C(2),C(3),C(4),C(5),freq)).^2 );
C = fminsearch(E,C0,options);


%%
fitObj.fn = C(1);
fitObj.Q = C(2);
fitObj.A = C(3);
fitObj.a = C(4);
fitObj.NF = C(5);
fitObj.handle = @(f) lorentz(C(1),C(2),C(3),C(4),C(5),f);




end