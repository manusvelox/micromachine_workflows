%{

Extract device and readout parameters from thermal noise spectrums

This version uses the analytical model of a doubly clamped beam and
electrostic mechanics to measure beam size and gap width from the resonant
frequency vs bias voltage alone. This is used to determine beam mass.

Fitting to the thermal noise spectrums is then used to extract
responsivity. 

Requires a set of thermal spectrums in df format with a mean field. If the
correct amplifier calibration is used, eta will be calculated. Otherwise,
repsonsivity can be used even with a a bad amplfier cal. 

%}

close all
clear
clc

%% plotting and program parameters

FS = 18;
MS =10;
LW = 1.5;

%% Load file and point program to the correct fields

filename='7_3_20_readoutcal_MacKenzie_Rf1_500k_500mVstep';
ds  = '03-Jul-2020';

[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'dev_data',ds,filename);
fullfilename=fullfile(dirname,filename);
load(fullfilename)

popi = [];

T = data.Tset + 273.15;
Vb = data.biasV;
fn = data.fn_mean;
spectrum_cell = data.ASD_narrow_subsampled;


%% save location

savefn =[ filename '_params'];
[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'processed_data',ds,savefn);
mkdir(dirname);
savefullname=fullfile(dirname,savefn);

%% Amplifier data

filename='3_3_20_LFSAV2_1_Rf1500k_Ch2_Vd10mV_Ri_996k.txt';
ds  = '03-Mar-2020';

[contfolder,folder,ext] = fileparts(pwd);
dirname=fullfile(contfolder,'amp_data',ds);
ampfn=fullfile(dirname,filename);

G_fact = 1;

Vin = 10E-3;
R = 996E3;
fact = G_fact*R/Vin;

CH1mat = dlmread(ampfn,';',6,0);
ch1_f = CH1mat(:,1);
ch1_G = fact*movmean(CH1mat(:,2),10);

fig = figure(200);
fig.Position = [680 700 560 300];
loglog(ch1_f,ch1_G,'linewidth',LW)
hold on
grid on
xlabel('f (Hz)');
ylabel('G (V/A)');
title(filename, 'Interpreter', 'none'); 

set(gca,'FontSize',FS) %Change axes value text size
set(findall(gcf,'type','text'),'FontSize',FS-2) %Change all other text size
set(findall(gca, '-Property', 'FontName'), 'FontName', 'Times New Roman');

export_fig([savefullname '_Amp'],'-transparent','-pdf') 




%% Nominal device geometry, parameters, constants

t = 60E-6;
L = 200E-6;
g_nom = 700E-9;
W_nom = 4E-6;

Q0 = 15E3;

m_star = .3965; %modal mass coefficient
gamma_c = .5231; %mode shape correction factor for electrostatics 

kb = 1.381E-23; %Boltzmann's constant
eps_0=8.85e-12 ;%F/m, vacuum permittivity
E_si=169e9 ;%N/m^2, Young's modulus in the 100 direction
rho=2330 ;%kg/m^3, silicon density

%% doubly clamped beam model from Kaajakari

%Plot the analytical mode shapes of a doubly clamped beam
%From Kaajakari "Practical MEMS", Appendix H

beta1=4.730041 ;
beta2=7.853205 ;
beta3=10.995608 ;
beta4=14.137165 ;
beta=beta1 ; %use mode shape 1 

alpha=(sinh(beta)-sin(beta))./(cos(beta)-cosh(beta)) ;


%% Fit to beam width and gap size from electrostatics 

Vb_span = linspace(0,max(Vb),300);

fig = figure(201);
fig.Position = [30 70 560 420];
plot(Vb,fn/1E3,'b*','MarkerSize',MS,'linewidth',LW)
hold on; grid on;

xlabel('V_b (V)');
ylabel('f_n (kHz)')
xlim([min(Vb_span),max(Vb_span)])


%C = [g,W]
oe_mod = @(g) g-g_nom;
m_mod = @(g,W) (rho*m_star*(L+2*oe_mod(g))*t*W);
f_n_model = @(g,W,V) (1./(2*pi)).*sqrt(beta.^4*E_si*W^2/(12*rho*(L+2*oe_mod(g))^4)...
    -2*gamma_c*eps_0*(t*(L+2*oe_mod(g))).*V.^2/m_mod(g,W)/g^3);


C0 = [g_nom+.7E-6,W_nom-2*.7E-6];
E = @(C) 1E8*sum((fn-f_n_model(C(1),C(2),Vb)).^2 );
options = optimset( 'TolFun',1E-4);
options = optimset(options, 'TolX',1E-4);
%options = optimset(options,'Display','iter','PlotFcns',@optimplotfval);
C = fminsearch(E,C0,options);

g_elec = C(1);
W_elec = C(2);
oe = oe_mod(g_elec);
m = m_mod(g_elec,W_elec);
f_n_0 = f_n_model(g_elec,W_elec,0);

plot(Vb_span,f_n_model(C(1),C(2),Vb_span)/1E3,'r-','linewidth',LW)
title(sprintf('f_{n,0} = %.1f kHz, W = %.2f um, g = %.3f um',f_n_0/1E3,W_elec*1E6,g_elec*1E6))

set(gca,'FontSize',FS) %Change axes value text size
set(findall(gcf,'type','text'),'FontSize',FS) %Change all other text size
set(findall(gca, '-Property', 'FontName'), 'FontName', 'Times New Roman');

export_fig([savefullname '_ElectrostaticSofteningFit'],'-transparent','-pdf') 

%% Fit thermal noise model to spectrum data

%main fitting function
vout_fun =  @(G,Q,T,Vamp,kb,m,n,w,wn)sqrt(Vamp.^2+...
    (G.^2.*T.*kb.*n.^2.*w.^2.*wn.*4.0)./(Q.*m.*((w.^2-wn.^2).^2+...
    1.0./Q.^2.*w.^2.*wn.^2)));

% function for estimating inital eta
n_fun = @(G,Q,T,Vamp,Vp,kb,m,wn)(1.0./sqrt(Q).*1.0./sqrt(T...
    ).*1.0./sqrt(kb).*sqrt(m).*sqrt(wn).*sqrt(-(Vamp+Vp).*(Vamp-Vp)).*(1.0./2.0))./G;





for i = 1:length(spectrum_cell)
spectrum = spectrum_cell{i}; 
fn_mean = fn(i);
w = (spectrum.x+fn_mean)*2*pi;
V = spectrum.y;
mask = not(isnan(V));
w = w(mask);
V = V(mask);


fig = figure(i);
fig.Position = [680 700 560 300];
plot(w,V,'.','displayname','data')
xlim([min(w),max(w)])
title([num2str(i) ': Vb = ' num2str(Vb(i)) 'V'])
legend


if ismember(i,popi)
    title([num2str(i) ': POPPED: Vb = ' num2str(Vb(i)) 'V']);
end




Vp = V(floor(length(V)/2));
wn0 = fn_mean*2*pi ;
Vamp0 = mean(V(1:20));
f = wn0/2/pi;
G0 = interp1(ch1_f,ch1_G,f,'pchip');



n0 = n_fun(G0,Q0,T,Vamp0,Vp,kb,m,wn0);

wspan = linspace(min(w),max(w),300);
model = @(w,n,Q,wn,Vamp) vout_fun(G0,Q,T,Vamp,kb,m,n,w,wn);
hold on
plot(wspan,model(wspan,n0,Q0,wn0,Vamp0),'displayname','IC','linewidth',LW)

%%
C0 = [n0,Q0,wn0,Vamp0];


E = @(C) 1E8*sum((V-model(w,C(1),C(2),C(3),C(4))).^2 );

options = optimset( 'TolFun',1E-4);
options = optimset(options, 'TolX',1E-4);
%options = optimset(options,'Display','iter','PlotFcns',@optimplotfval);



C = fminsearch(E,C0,options);
n(i) = C(1);
Q(i) = C(2);
wn(i) = C(3);
Vamp(i) = C(4);
G(i) = G0;
R(i) = n(i)*wn(i)*G(i);



figure(i)
plot(wspan,model(wspan,C(1),C(2),C(3),C(4)),'displayname','opt','linewidth',LW)

end

Vb(popi) = [];
n(popi) = [];
wn(popi) = [];
Q(popi) = [];
Vamp(popi) =[];
G(popi) = [];
R(popi) = [];



%% fit gap from eta 


fig = figure(202);
fig.Position = [680 70 560 420];
plot(Vb,n,'b*','MarkerSize',MS,'linewidth',LW)
hold on; grid on;

xlabel('Vb (V)');
ylabel('\eta')
xlim([min(Vb_span),max(Vb_span)])

n_mdl = polyfitn(Vb,n,{'x'});
plot(Vb_span,n_mdl.Coefficients*Vb_span,'r-','linewidth',LW)

g_trans = (gamma_c*eps_0*L*t/n_mdl.Coefficients(end))^(1/2);
 
title(sprintf('g = %.2f um',g_trans*1E6))


set(gca,'FontSize',FS) %Change axes value text size
set(findall(gcf,'type','text'),'FontSize',FS) %Change all other text size
set(findall(gca, '-Property', 'FontName'), 'FontName', 'Times New Roman');

params.n_fun = @(V) n_mdl.Coefficients*V;


export_fig([savefullname '_EtaFit'],'-transparent','-pdf') 


%% fit responsivity


fig = figure(203);
fig.Position = [1320 70 560 420];
plot(Vb,R,'b*','MarkerSize',MS,'linewidth',LW)
hold on; grid on;

xlabel('Vb (V)');
ylabel('R')
xlim([min(Vb_span),max(Vb_span)])

R_mdl = polyfitn(Vb,R,{'x'});
plot(Vb_span,R_mdl.Coefficients*Vb_span,'r-','linewidth',LW)



set(gca,'FontSize',FS) %Change axes value text size
set(findall(gcf,'type','text'),'FontSize',FS) %Change all other text size
set(findall(gca, '-Property', 'FontName'), 'FontName', 'Times New Roman');

params.R_fun = @(V) R_mdl.Coefficients*V;


export_fig([savefullname '_Responsivity'],'-transparent','-pdf') 


%% save extracted parameters

params.Vb = Vb;
params.n = n;
params.wn = wn;
params.Q = Q;
params.Vamp = Vamp;
params.G = G;
params.T = T;
params.m = m;
params.G = G;
params.R = R;
params.g_trans = g_trans;
params.g_elec = g_elec;
params.W_elec = W_elec;


%% save params 
save(savefullname,'params')
