function ep = deformacion_acero_activo(sigma, fpk, Ep, gamAcero)
%  DEFORMACION_ACERO_ACTIVO devuelve la deformación unitaria del acero
%  activo según la EHE-08.
% 
% 	 ep = deformacion_acero_activo(sigma, fpk, Ep, gamAcero) devuelve la
%    deformación unitaria del acero activo según el apartado 38.7 de la norma
%    EHE-08 (diagrama simplificado con sigma_pd = fpd), dada la tensión
%    'sigma' (en MPa), el límite elástico del acero 'fpk' (en MPa), el módulo
%    de elasticidad lineal del acero 'Es' (por defecto, igual a 200 GPa), y
%    el factor del material acero 'gamAcero' (por defecto, igual a 1.15). 
% 
%    ENTRADA REQUERIDA:
%    sigma          Tensión del acero (MPa)   
%    fpk            Límite elástico característico del acero activo (MPa)
% 
%    ENTRADA OPCIONAL:
%    Ep             Módulo de elasticidad lineal del acero activo (MPa)
%    gamAcero       Factor del material acero
% 
%    SALIDA:
%    ep             Deformación unitaria del acero de pretensado

% Valor por defecto de 'Es' y 'gamAcero'
if nargin < 3 || isempty(Ep)
    Ep = 200000;
end
if nargin < 4 || isempty(gamAcero)
    gamAcero = 1.15;
end

% Obtención de la resistencia de cálculo 
fpd = fpk / gamAcero;

% Cálculo de la deformación unitaria
signo = sign(sigma);
sigma = abs(sigma);
if sigma <= 0.7 * fpd
    ep = signo * sigma/Ep;
elseif sigma <= fpd
    ep = signo * (sigma/Ep + 200/243 * (sigma/fpd - 0.7) ^ 5);
else
    ep = NaN;
end

end