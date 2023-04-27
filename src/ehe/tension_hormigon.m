function sigma = tension_hormigon(ec, fck, fct, gamHorm)
%  TENSION_HORMIGON devuelve la tensión del hormigón según la EHE-08.
% 
% 	 sigma = tension_hormigon(ec, fck, fct, gamHormigon) devuelve la tensión
% 	 del hormigón (en MPa) según el apartado 39.5 de la norma EHE-08
%    (diagrama de cálculo parábola-rectángulo), dada la deformación unitaria
%    'ec', la resistencia característica del hormigón 'fck' (en MPa), la
%    resistencia límite a tracción del hormigón 'fct' (en MPa) y el factor
%    del material hormigón 'gamHorm' (por defecto, igual a 1.5).
% 
%    ENTRADA REQUERIDA:
%    ec             Deformación unitaria del hormigón
%    fck            Resistencia característica a compresión del hormigón (MPa)
% 
%    ENTRADA OPCIONAL:
%    fct            Resistencia límite a tracción del hormigón (MPa)
%    gamHorm        Factor del material hormigón
% 
%    SALIDA:
%    sigma          Tensión del hormigón para los parámetros ingresados (MPa)

% Valor por defecto de 'fct' y 'gamHormigon'
if nargin < 3 || isempty(fct)
    fct = 0;
end
if nargin < 4 || isempty(gamHorm)
    gamHorm = 1.5;
end

% Obtención de la resistencia de cálculo 
fcd = fck / gamHorm;

% Obtención los parámetros del diagrama tensión-deformación
if fck <= 50
    ec0 = - 0.002;
    ecu = - 0.0035;
    n = 2;
else
    ec0 = - (0.002 + 0.000085 * (fck - 50) ^ 0.5);
    ecu = - (0.0026 + 0.0144 * (1 - fck/100) ^ 4);
    n = 1.4 + 9.6 * (1 - fck/100) ^ 4;
end
ecf = - ec0 * (1 - (1 - fct / fcd) ^ (1/n));

% Cálculo de la tensión
if ec > ecf
    sigma = 0;
elseif ec > 0
    sigma = fcd * (1 - (1 + ec/ec0) ^ n);
elseif ec >= ec0
    sigma = - fcd * (1 - (1 - ec/ec0) ^ n);
elseif ec >= ecu - eps
    sigma = - fcd;
else
    sigma = NaN;
end

end