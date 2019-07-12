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

A = 3760
B = 20
C = 1 / (2*B)
D = 440
E = 20
F = 1 / (2*E)
N = 300 // Maxima cantidad de terminos positivos de T.Fourier en tiempo discreto
fs = 44100
f = 0:0.1:fs
Ts = 1 / fs
k = 0:2*N
hc = 4*D*E*F*sincPi(2*D*(k - N)*Ts).*sincPi(2*E*(k - N)*Ts) + 8*A*B*C*sincPi(2*A*(k - N)*Ts).*sincPi(2*B*(k - N)*Ts).*cos(2*%pi*4300*(k - N)*Ts)
Z = exp(%i*2*%pi*f*Ts)
Hz = polyvalNegativo(Ts*hc, Z)
plot(f, abs(Hz), 'r')
xgrid()

// Se usa Hz para filtrar un barrido de frecuencias
// De 0 Hz a 4000 Hz la respuesta del filtro es siempre 1
fini = 0
ffin = 1000
tbarrido = 10
t = 0:Ts:tbarrido
fase = 2*%pi*(fini*t + ((ffin - fini)/(2*tbarrido))*(t^2))
x = cos(fase)
y = filter(Ts*hc, 1, x)  //denominador=1.
figure(1)
title('señal de entrada')
plot(t, x)
figure(2)
title('señal de salida')
plot(t, y)

/* testPolyVal
x = 0:0.1:3
testpol = polyval([2 2 1], x)
figure(1)
plot(x, testpol)
*/
