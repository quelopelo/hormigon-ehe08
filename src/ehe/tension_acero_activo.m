function sigma = tension_acero_activo(ep, fpk, Ep, gamAcero)
%  TENSION_ACERO_ACTIVO devuelve la tensión del acero activo según la EHE-08.
% 
% 	 sigma = tension_acero_activo(ep, fpk, Ep, gamAcero) devuelve la tensión
%    del acero activo (en MPa) según el apartado 38.7 de la norma EHE-08
% 	 (diagrama simplificado con sigma_pd = fpd), dada la deformación
%    unitaria 'ep', el límite elástico del acero 'fpk' (en MPa), el módulo
%    de elasticidad lineal del acero 'Es' (por defecto, igual a 200 GPa), y
%    el factor del material acero 'gamAcero' (por defecto, igual a 1.15). 
% 
%    ENTRADA REQUERIDA:
%    ep             Deformación unitaria del acero de pretensado
%    fpk            Límite elástico característico del acero activo (MPa)
% 
%    ENTRADA OPCIONAL:
%    Ep             Módulo de elasticidad lineal del acero activo (MPa)
%    gamAcero       Factor del material acero
% 
%    SALIDA:
%    sigma          Tensión del acero para los parámetros ingresados (MPa)

% Valor por defecto de 'Ep' y 'gamAcero'
if nargin < 3 || isempty(Ep)
    Ep = 200000;
end
if nargin < 4 || isempty(gamAcero)
    gamAcero = 1.15;
end

% Obtención de la resistencia de cálculo 
fpd = fpk / gamAcero;

% Cálculo de la tensión
epAbs = abs(ep);
if epAbs < fpd/Ep + 0.002
    % Obtención de un punto inicial para el problema de optimización
    if ep >= 0
        sigma1 = 0;
        sigma2 = fpd;
    else
        sigma1 = -fpd;
        sigma2 = 0;
    end
    % Definición del problema de optimización
    problem.objective = @(x) deformacion_acero_activo(x, fpk, Ep, gamAcero) - ep;
    problem.x0 = [sigma1, sigma2];
    problem.solver = 'fzero';
    problem.options = optimset('Display', 'off');
    % Resolución del problema de optimización
    [sigma, ~, exitFlag] = fzero(problem);
    if exitFlag ~= 1
        sigma = NaN;
    end
else
    sigma = sign(ep) * fpd;
end

end