function y = polyval(p, x)
    y = 0
    p = p(length(p):-1:1)
    for k = 1:length(p)
        y = y + p(k) * x.^(k - 1)
    end
endfunction

function y = negativePolyval(p, x)
    y = 0
    p = p(length(p):-1:1)
    for k = 1:length(p)
        y = y + p(k) * x.^(1 - k)
    end
endfunction

function g = getGain(x)
    g = 1 / max(abs(x))
endfunction

function h = lowPassFilter(A, B, t)
    h = 2*A*sincPi(2*A*t).*sincPi(2*B*t)
endfunction

function h = bandPassFilter(A, B, f0, t)
    h = 2*lowPassFilter(A, B, t).*cos(2*%pi*f0*t)
endfunction

[x, fs, bits] = wavread('.\Audio200Hz\ParlaProfeTESundavCONtono200Hz_1erCuat2019.wav');
A = 7390 // Ancho del filtro pasabanda
B = 20
D = 177.3 // Ancho del filtro pasabajos
E = 20
N = 700 // Maxima cantidad de terminos positivos de T.Fourier en tiempo discreto
Ts = 1 / fs;
k = 0:2*N

// Se define el filtro notch de 200Hz compuesto por un filtro pasa bajos y un
// filtro pasa banda.
hc = lowPassFilter(D, E, (k - N)*Ts) + bandPassFilter(A, B, 7627.3, (k - N)*Ts)

// Se grafica la respuesta en frecuencia del filtro hc
f = 0:0.1:fs
Z = exp(%i*2*%pi*f*Ts)
Hz = negativePolyval(Ts*hc, Z)
figure(0)
title('Transferencia del filtro notch')
plot(f, abs(Hz), 'r')
xgrid()

// Se usa hc para filtrar una señal de audio
t = (1:length(x))*Ts;
y = filter(Ts*hc, 1, x)  // denominador = 1 para que sea filtro FIR.

// Se grafica la señal de entrada x
figure(1)
title('Señal de entrada')
plot(t, x)

// Se grafica la señal filtrada y
figure(2)
title('Señal de salida')
plot(t, y)

wavwrite(y, fs, bits, '.\Audio200Hz\TPFiltroFIRAaudio200Hz_out.wav')
playsnd(y*getGain(y), fs, bits, '')
