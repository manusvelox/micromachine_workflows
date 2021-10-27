function [f,pow] = fft_NB(data,ts)


L = length(data);
Y = fft(data);

P2 = abs(Y);

P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = 1./ts*(0:(L/2))/L;
pow = 2*10*P1.^2;

end

