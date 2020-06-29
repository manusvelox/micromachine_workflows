data = savedata(1);
spectrum = data.spectrum(1);

x = transpose(spectrum.x);
y = transpose(spectrum.y);

plot(x,y);
hold on

f1 = @(G,F,fn,Q,x) sqrt(G./(((2*pi*fn).^2-(2*pi*x).^2).^2 + (2*pi*x*2*pi*fn/Q).^2)+ F^2);

MSE = @(C) (1/length(V))*sum((f1(C(1),C(2),C(3),C(4),x)-y).^2);

%setup solver
opts = optimset('MaxFunEvals',50000, 'MaxIter',10000);
init = [1E10,.5E-5,1.089E5,100];
[C,fval] = fminsearch(@(C) 1E10*MSE(C), init, opts); 

plot(x,f1(C(1),C(2),C(3),C(4),x));
