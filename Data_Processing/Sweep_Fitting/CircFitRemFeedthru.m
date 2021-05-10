function fitObj = CircFitRemFeedthru(varargin)
%fitObj = CircFitRemFeedthru(V_phasor, freq,phaseTol,maxIter, plotFlag)

%% process inputs

inputs = {[], [],0.01,10, 0};
inputs(1:nargin) = varargin;


 
V_phasor = inputs{1};
freq = inputs{2};
phaseTol = inputs{3};
maxIter = inputs{4};
plotFlag = inputs{5};

%% process input and fit circle

X_raw = real(V_phasor);
Y_raw = imag(V_phasor);

[R_fit,XC,YC] = circfit(X_raw,Y_raw);

X_centered = X_raw - XC;
Y_centered = Y_raw - YC;



%% first pass to find resonance along the  circle sing the spacing of the response along the circle. 
% use spline fit and then zero second derivative of angle around circle to
% get first approx for the phase of resonance. 

theta = unwrap(angle(X_centered + 1i* Y_centered));
np = 400;

f_spline_obj = splinefit(theta,freq,200);
thetaspan = linspace(min(theta),max(theta),np);
f_spline = ppval(f_spline_obj,thetaspan);
df2 = dfd(f_spline,2,8,2,thetaspan(2)-thetaspan(1),'central');

zci = @(v) find(v(:).*circshift(v(:), [-1 0]) <= 0);
ind = zci(df2);
mask1 = and(ind>(np/5),ind<(np-np/5));
single_ind = ind(mask1);


theta_res = interp1(df2(single_ind-1:single_ind+1),thetaspan(single_ind-1:single_ind+1),0);



%% rotate data to represent first pass, fit to evaluate asymmetry


X_centered_rotated = X_centered.*cos(-1*theta_res) - Y_centered*sin(-1*theta_res);
Y_centered_rotated = X_centered.*sin(-1*theta_res) + Y_centered*cos(-1*theta_res);
X_processed = X_centered_rotated+ R_fit;
Y_processed = Y_centered_rotated;
V_phasor_processed = X_processed + 1i*Y_processed;
amp_processed = sqrt(X_processed.^2 + Y_processed.^2);
phase_processed = angle(V_phasor_processed);


%% fit to middle 3 linewidths

[maxVal,maxI] = max(amp_processed);
fn0 = freq(maxI);
lowerHalfPower = max(freq(and(freq<fn0,amp_processed<maxVal/2)));
upperHalfPower = min(freq(and(freq>fn0,amp_processed<maxVal/2)));
gamma = upperHalfPower-lowerHalfPower;

mask = and(freq > (fn0-gamma), freq < (fn0+gamma));


fitObj = asymLorentzianFit(amp_processed(mask), freq(mask));
a0 = fitObj.a;
fn = fitObj.fn;




if plotFlag
f1 = figure(1001);
f1.Position = [87 231 1239 495];
subplot(2,2,[1 3])
plot(X_processed,Y_processed,'.');hold on
axis equal
xlabel('Real')
ylabel('Imag');
prettyfig_NB

subplot(2,2,2)
plot(freq,amp_processed,'.');hold on
plot(freq,fitObj.handle(freq));
text(fn,0,sprintf('a = %.2f',a0))
xlabel('Freq')
ylabel('Amp');
prettyfig_NB
subplot(2,2,4)
plot(freq,phase_processed);hold on
xlabel('Freq')
ylabel('Phase');
prettyfig_NB

end

%% iterate to make reonance at zero phase

% set stopping conditions flag
phase_error = phase_error_init;
iterCount = 0;
stoppingCondMet =  or(abs(phase_error) < phaseTol, iterCount > maxIter);

X_processed_current = X_processed;
Y_processed_current = Y_processed;

while ~stoppingCondMet
    
    X_processed_current_centered = X_processed_current-R_fit;
    Y_processed_current_centered = Y_processed_current;
    
    
    X_updated_centered = X_processed_current_centered.*cos(2*phase_error) - Y_processed_current_centered*sin(2*phase_error);
    Y_updated_centered = X_processed_current_centered.*sin(2*phase_error) + Y_processed_current_centered*cos(2*phase_error);
    
    
    X_updated = X_updated_centered +R_fit;
    Y_updated = Y_updated_centered;
    
    amp_updated = sqrt(X_updated.^2+Y_updated.^2);
    phase_updated = angle(X_updated+1i*Y_updated);
    
    [f_n_updated,~] = parabolic_peak_correct(freq,amp_updated,10,inf);
    new_phase_error = interp1(freq,phase_updated,f_n_updated);
    
    X_processed_current = X_updated;
    Y_processed_current = Y_updated;
    
   
    iterCount = iterCount + 1;
    stoppingCondMet =  or(abs(new_phase_error) < phaseTol, iterCount > maxIter);
end

X_processed_iter = X_processed_current;
Y_processed_iter = Y_processed_current;

%% plot iterated fit

V_phasor_iter = X_processed_iter + 1i*Y_processed_iter;
amp_iter = abs(V_phasor_iter);
phase_iter = angle(V_phasor_iter);

[f_n_iter,~] = parabolic_peak_correct(freq,amp_iter,10,inf);
phase_error_iter = interp1(freq,phase_iter,f_n_iter);

if plotFlag
f1 = figure(1002);
f1.Position = [87 231 1239 495];
subplot(2,2,[1 3])
plot(X_processed_iter,Y_processed_iter,'.');hold on
axis equal
xlabel('Real')
ylabel('Imag');
prettyfig_NB

subplot(2,2,2)
plot(freq,amp_iter);hold on
vline(f_n_iter,'r--');
xlabel('Freq')
ylabel('Amp');
prettyfig_NB
subplot(2,2,4)
plot(freq,phase_iter);hold on
vline(f_n_iter,'r--');
text(f_n_iter,.5,sprintf('theta = %.2f',phase_error_iter))
xlabel('Freq')
ylabel('Phase');
prettyfig_NB

end

%%
fitObj = []


end

