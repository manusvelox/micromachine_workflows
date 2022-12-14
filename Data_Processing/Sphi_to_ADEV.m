function sigy = Sphi_to_ADEV(Sphi,freqs,fn)

taus = 1./freqs;
sigy = zeros(size(Sphi));
Sy = (freqs./fn).^2.*Sphi;

for ii = 1:length(taus)

    sigy_sq = 2*trapz(freqs,Sy.*(sin(pi.*taus(ii).*freqs)).^4./((pi.*taus(ii).*freqs).^2));
    sigy(ii) = sqrt(sigy_sq);
    


end