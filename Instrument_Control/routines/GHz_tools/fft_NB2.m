function [f,psd] = fft_NB2(data,Fs)


N = length(data);
xdft = fft(data);
xdft = xdft(1:N/2+1);
psd = (1/(Fs*N)) * abs(xdft).^2;
psd(2:end-1) = 2*psd(2:end-1);
f = 0:Fs/length(data):Fs/2;



end

