function [freqs, powers] = fftParcel(y, t)
N = length(y);
Y = fft(y);
Pyy = Y.*conj(Y)/N;

f = (1/t)/N*(0:floor(N/2));

freqs = f;
powers = Pyy(1:floor(N/2)+1);
end