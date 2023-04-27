function sigma = tension_acero_pasivo(es, fyk, Es, gamAcero)
%  TENSION_ACERO_PASIVO devuelve la tensión del acero pasivo según la EHE-08.
% 
% 	 sigma = tension_acero_pasivo(es, fyk, Es, gamAcero) devuelve la tensión
%    del acero pasivo (en MPa) según el apartado 38.4 de la norma EHE-08
% 	 (diagrama bilineal con plastificación perfecta), dada la deformación
%    unitaria 'es', el límite elástico del acero 'fyk' (en MPa), el módulo
%    de elasticidad lineal del acero 'Es' (por defecto, igual a 200 GPa), y
%    el factor del material acero 'gamAcero' (por defecto, igual a 1.15). 
% 
%    ENTRADA REQUERIDA:
%    es             Deformación unitaria del acero
%    fyk            Límite elástico característico del acero pasivo (MPa)
% 
%    ENTRADA OPCIONAL:
%    Es             Módulo de elasticidad lineal del acero pasivo (MPa)
%    gamAcero       Factor del material acero
% 
%    SALIDA:
%    sigma          Tensión del acero para los parámetros ingresados (MPa)

% Valor por defecto de 'Es' y 'gamAcero'
if nargin < 3 || isempty(Es)
    Es = 200000;
end
if nargin < 4 || isempty(gamAcero)
    gamAcero = 1.15;
end

% Obtención de la resistencia de cálculo 
fyd = fyk / gamAcero;

% Cálculo de la tensión
if es <= 0.01 + eps
    sigma = sign(es) * min(Es * abs(es), fyd);
else
    sigma = NaN;
end

end