function y = u(x)
    y = (sign(x) + 1)/2
endfunction

function y = rect(x)
    y = u(x + 1/2) - u(x - 1/2)
endfunction

function y = rampa(x)
    y = x.*u(x)
endfunction

function y = sincPi(x)
    y = sinc(x*%pi)
endfunction

function y = polyval(p, x)
    y = 0
    p = p(length(p):-1:1)
    for k = 1:length(p)
        y = y + p(k) * x.^(k - 1)
    end
endfunction

function y = polyvalNegativo(p, x)
    y = 0
    p = p(length(p):-1:1)
    for k = 1:length(p)
        y = y + p(k) * x.^(1 - k)
    end
endfunction

function g = getGain(x)
    g = 1 / max(abs(min(x)), abs(max(x)))
endfunction
// TODO: Probar con E15 B15
A = 7390
B = 20
C = 1 / (2*B)
D = 177.3
E = 20
F = 1 / (2*E)
N = 700 // Maxima cantidad de terminos positivos de T.Fourier en tiempo discreto
[x, fs, bits] = wavread('.\Audio200Hz\ParlaProfeTESundavCONtono200Hz_1erCuat2019.wav');
Ts = 1 / fs;
f = 0:0.1:fs
k = 0:2*N
hc = 4*D*E*F*sincPi(2*D*(k - N)*Ts).*sincPi(2*E*(k - N)*Ts) + 8*A*B*C*sincPi(2*A*(k - N)*Ts).*sincPi(2*B*(k - N)*Ts).*cos(2*%pi*7627.3*(k - N)*Ts)
Z = exp(%i*2*%pi*f*Ts)
Hz = polyvalNegativo(Ts*hc, Z)
figure(0)
plot(k, hc)
figure(1)
plot(f, abs(Hz), 'r')
xgrid()

// Se usa hc para filtrar una señal de audio
t = (1:length(x))*Ts;
y = filter(Ts*hc, 1, x)  // denominador = 1 para que sea filtro FIR.
figure(2)
title('señal de entrada')
plot(t, x)
figure(3)
title('señal de salida')
plot(t, y)

wavwrite(y, fs, bits, '.\Audio200Hz\TPFiltroFIRAaudio200Hz_out.wav')
playsnd(y*getGain(y), fs, bits, '')
