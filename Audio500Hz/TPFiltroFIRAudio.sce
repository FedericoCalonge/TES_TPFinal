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
// TODO: Volver a A3760 B20 D444.8 E25 N600 f4304.8, separar el notch en 10Hz
// TODO: Volver a A3760 B20 D444.8 E25 N600 f4304.8, restar 15 a todo
A = 3760
B = 20
C = 1 / (2*B)
D = 444.8
E = 25
F = 1 / (2*E)
N = 300 // Maxima cantidad de terminos positivos de T.Fourier en tiempo discreto
[x, fs, bits] = wavread('.\Audio500Hz\ParlaProfeTESundavCONtono500Hz_1erCuat2019.wav');
Ts = 1 / fs;
f = 0:0.1:fs
k = 0:2*N
hc = 4*D*E*F*sincPi(2*D*(k - N)*Ts).*sincPi(2*E*(k - N)*Ts) + 8*A*B*C*sincPi(2*A*(k - N)*Ts).*sincPi(2*B*(k - N)*Ts).*cos(2*%pi*4304.8*(k - N)*Ts)
Z = exp(%i*2*%pi*f*Ts)
Hz = polyvalNegativo(Ts*hc, Z)
plot(f, abs(Hz), 'r')
xgrid()

// Se usa Hz para filtrar una señal de audio
t = Ts:Ts:(Ts*length(x));
y = filter(Ts*hc, 1, x)  //denominador=1.
figure(1)
title('señal de entrada')
plot(t, x)
figure(2)
title('señal de salida')
plot(t, y)

wavwrite(y, fs, bits, '.\Audio500Hz\TPFiltroFIRAaudio500Hz_out.wav')

t1 = Ts:Ts:0.3
finishtone = cos(2*%pi*1000*t1).*u(0.1 + t1) + cos(2*%pi*3000*t1).*u(t1 - 0.1)
playsnd(finishtone, fs, bits, '')
