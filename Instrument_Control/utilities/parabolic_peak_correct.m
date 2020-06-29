function [correctedf,correctedA] = parabolic_peak_correct(f,A,win,thresh)


[Amax,peaki] = max(A);
flag = 1;
while flag
    if Amax>thresh
        f(peaki-10:peaki+10) = [];
        A(peaki-10:peaki+10) = [];
        [Amax,peaki] = max(A);
    else
        flag = 0;
    end

end
mini = 1;
maxi = length(f);

winstart = max(peaki-win/2,mini);
winend = min(peaki+win/2,maxi);
f = f(winstart:winend);
A = A(winstart:winend);

fmin = min(f);
fmax = max(f);
Amin = min(A);


f_scaled = (f-fmin)/(fmax-fmin);
A_scaled = (A-Amin)/(Amax-Amin);


mdl = polyfitn(f_scaled,A_scaled,2);
nd_peakf = -mdl.Coefficients(2)/2/ mdl.Coefficients(1);
nd_peakA = mdl.Coefficients(1)*nd_peakf^2+mdl.Coefficients(2)*nd_peakf+mdl.Coefficients(3);
correctedf = fmin + nd_peakf*(fmax-fmin);
correctedA = Amin + nd_peakA*(Amax-Amin);

% figure(1111)
% mdlf = linspace(min(f_scaled),max(f_scaled),200);
% plot(f_scaled,A_scaled,'b.')
% hold on
% plot(nd_peakf,nd_peakA,'r*')
% plot(mdlf,polyvaln(mdl,mdlf),'r-')
% xlim([min(mdlf),max(mdlf)])
% ylim([min(A_scaled) max(A_scaled)])
% hold off
% 
% figure(1112)
% mdlf = linspace(min(f_scaled),max(f_scaled),200);
% plot(f,A,'b.')
% hold on
% plot(correctedf,correctedA,'r*')
% plot(fmin+mdlf*(fmax-fmin),Amin+ (Amax-Amin)*polyvaln(mdl,mdlf),'r-')
% xlim([min(f) max(f)])
% ylim([min(A) max(A)])
% hold off


end
