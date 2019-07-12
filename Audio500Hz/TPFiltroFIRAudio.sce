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

function y = myFilter(VN, VD, x) //Recibo 2 vectores REALES (VN:VectorNumerador y VD:VectorDenominador) y la señal de entrada (x).
    //La salida de myFilter() es la señal x filtrada.
    //Sacamos longitudes:
    LongDen = length(VD);    //Longitud del vector del DENOMINADOR.    
    LongNum = length(VN);    //Longitud del vector del NUMERADOR.
    LongX = length(x);       //Longitud de nuestra función de entrada x.
        
    Maximo = max(LongNum, LongDen);  //Obtenemos el valor máximo entre ambas longitudes.
    x2 = [zeros(Maximo-1,1); x'];    //Usamos x2 como auxiliar. zeros(2,3) me devuelve una matriz de ceros de 2 filas x 3 columnas. x' es la traspuesta de x. 
    //Y la ";" es para concatenar ambos vectores. Esto lo hacemos porque en el for se abajo (al sacar y[n]) se necesita que los dos vectores tengan el mismo tamaño;
    //entonces agrandamos el tamaño de x rellenandolo con 0s.
    
    //Ahora hacemos un bucle for para obtener nuestra salida y[n]:
    for n = Maximo:LongX+Maximo-1 //for basado en nuestra ecuacion H(z)=B(Z)/A(Z) --> ver help filter()
    //Es un for que va de n=Maximo HASTA Maximo+Nx-1.
        y(n) = ( (VN(LongNum:-1:1))*(x2(n-LongNum+1:n)) ) / (VD(1)); //Al hacer: 8:-1:4 (ejemplo) nos devuelve 8,7,6,5,4 (disminuimos el 8 en 1 hasta llegar al 4).
        if LongDen > 1
           y(n) = ( (y(n)-VD(LongDen:-1:2))*(y(n-LongDen+1:n-1)) ) / (VD(1));
        end
    end

    //Salida...    
    y2 = y(Maximo:LongX+Maximo-1); //Nos sirve para eliminar los 0s.
    y = y2'; //La trasponemos y obtenemos nuestra señal x ya filtrada = señal y.
endfunction

[x, fs, bits] = wavread('.\Audio500Hz\ParlaProfeTESundavCONtono500Hz_1erCuat2019.wav');
A = 7390 // Ancho del filtro pasabanda
B = 20
D = 477.3 // Ancho del filtro pasabajos
E = 20
N = 700 // Maxima cantidad de terminos positivos de T.Fourier en tiempo discreto
Ts = 1 / fs;
k = 0:2*N

// Se define el filtro notch de 500Hz compuesto por un filtro pasa bajos y un
// filtro pasa banda.
hc = lowPassFilter(D, E, (k - N)*Ts) + bandPassFilter(A, B, 7927.3, (k - N)*Ts)

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
y = myFilter(Ts*hc, 1, x)  // denominador = 1 para que sea filtro FIR.

// Se grafica la señal de entrada x
figure(1)
title('Señal de entrada')
plot(t, x)

// Se grafica la señal filtrada y
figure(2)
title('Señal de salida')
plot(t, y)

wavwrite(y, fs, bits, '.\Audio500Hz\TPFiltroFIRAaudio500Hz_out.wav')
playsnd(y*getGain(y), fs, bits, '')
