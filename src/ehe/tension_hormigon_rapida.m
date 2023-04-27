function sigma = tension_hormigon_rapida(ec, ecf, ec0, ecu, fcd, n)
%  TENSION_HORMIGON_RAPIDA devuelve la tensión del hormigón según la EHE-08.
% 
% 	 sigma = tension_hormigon_rapida(ec, ecf, ec0, ecu, fcd, n) devuelve la
%    tensión del hormigón (en MPa) según el apartado 39.5 de la norma EHE-08
%    (diagrama de cálculo parábola-rectángulo), dada la deformación unitaria
%    'ec', y los parámetros 'ecf', 'ec0', 'ecu', 'fcd' y 'n' (ver entrada
%    requerida y tension_hormigon.m por más detalles).
% 
%    ENTRADA REQUERIDA:
%    ec             Deformación unitaria del hormigón
%    ecf            Deformación correspondiente a la fisuración
%    ec0            Deformación de rotura a compresión simple
%    ecu            Deformación última
%    fcd            Resistencia de diseño a compresión del hormigón (MPa)
%    n              Grado de la "parábola"
% 
%    SALIDA:
%    sigma          Tensión del hormigón para los parámetros ingresados (MPa)

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