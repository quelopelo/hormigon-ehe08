function [N, M] = solicitaciones_normales(eInf, eSup, seccion, fctmflFlag)
%  SOLICITACIONES_NORMALES devuelve la directa y el momento flector de una
%  sección de hormigón armado y/o pretensado dada una ley plana de
%  deformaciones, según la EHE-08.
% 
%    [N, M] = solicitaciones_normales(eInf, eSup, seccion) calcula la 
%    directa (en N) y el momento flector (en N.mm) de una sección simétrica
%    de hormigón armado y pretensado según el capítulo 42.1 de la norma
%    EHE-08. Para el cálculo considera una ley plana de deformaciones, con
%    deformaciones unitarias 'eInf' y 'eSup' en los extremos (inferior y
%    superior) del hormigón; y la geometría de la sección y las propiedades
%    de los materiales indicadas en el estructurado 'seccion'.
% 
%    [N, M] = solicitaciones_normales(eInf, eSup, seccion, fctmlFlag) con 
%    fctml = true calcula la directa (en N) y el momento flector (en N.mm)
%    de una sección simétrica de hormigón armado y pretensado bajo las mismas
%    hipótesis de la sintaxis anterior, pero considerando la contribución
%    del hormigón a tracción, hasta una tensión igual a 'seccion.fctmfl'.
% 
%    ENTRADA REQUERIDA:
%    eInf           Deformación unitaria de la fibra inferior del hormigón
%    eSup           Deformación unitaria de la fibra superior del hormigón
%    seccion        Estructurado con la información de la geometría de la 
%                   seccion y las propiedades de los materiales componentes,
%                   creado a partir de la función crear_seccion.m
% 
%    ENTRADA OPCIONAL (NO RECOMENDADA):
%    fctmlFlag      Booleano que permite considerar la contribución del
%                   hormigón a flexotracción (por defecto, false)
% 
%    SALIDA:
%    N              Directa para la ley de deformaciones ingresada (N)
%    M              Momento flector (con signo) para la ley de deformaciones
%                   ingresada y en relación a una alutra 0 (N.mm)

% Valor por defecto de 'fctmflFlag'
if nargin < 4 || isempty(fctmflFlag)
    fctmflFlag = false;
end

% Obtención los parámetros del hormigón
fcd = seccion.fck / seccion.gamHorm;
if fctmflFlag
    ecf = - seccion.ec0 * (1 - (1 - seccion.fctmfl/fcd) ^ (1/seccion.nParHorm));
else
    ecf = 0;
end

% Discretización de la sección de hormigón
tamMaxHorm = seccion.h / seccion.minDivHorm;
nDiv = zeros(size(seccion.geoHorm, 1) - 1, 1);
for i = 1 : length(nDiv)
    nDiv(i) = ceil((seccion.geoHorm(i+1, 1) - seccion.geoHorm(i, 1)) / ...
                    tamMaxHorm);
end
nDivTot = sum(nDiv);
yVecHorm = zeros(nDivTot + 1, 1);
bVecHorm = yVecHorm;
k = 1;
for i = 1 : length(nDiv)
    ni = nDiv(i) + 1;
    yVecHorm(k : k+nDiv(i)) = linspace(seccion.geoHorm(i, 1), ...
                                       seccion.geoHorm(i+1, 1), ni)';
    bVecHorm(k : k+nDiv(i)) = linspace(seccion.geoHorm(i, 2), ...
                                       seccion.geoHorm(i+1, 2), ni)';
    k = k + nDiv(i);
end

% Definición de las variables de acumulación
N = 0;
M = 0;

% Cálculo de la contribución del hormigón
eVecHorm = eInf + (eSup - eInf) * (yVecHorm - seccion.yInf) / seccion.h;
sigmaVecHorm = zeros(length(eVecHorm), 1);
sigmaVecHorm(1) = tension_hormigon_rapida(eVecHorm(1), ecf, ...
                      seccion.ec0, seccion.ecu, fcd, seccion.nParHorm);
for i = 1 : nDivTot
    j = i + 1;
    yi = yVecHorm(i); yj = yVecHorm(j);
    bi = bVecHorm(i); bj = bVecHorm(j);
    si = sigmaVecHorm(i);
    sj = tension_hormigon_rapida(eVecHorm(j), ecf, ...
             seccion.ec0, seccion.ecu, fcd, seccion.nParHorm);
    sigmaVecHorm(j) = sj;
    Ni = 1/6 * (yj-yi) * (bi * (2*si+sj) + bj * (si+2*sj));
    Mi = 1/12 * (yj-yi) * (bi*yi * (3*si+sj) + bi*yj * (si+sj) + ...
                           bj*yj * (si+3*sj) + bj*yi * (si+sj));
    N = N + Ni;
    M = M + Mi;
end

% Cálculo de la contribución del acero pasivo
if ~isempty(seccion.geoAcPas)
    eVecAcero = eInf + (eSup - eInf) * ...
                       (seccion.geoAcPas(:, 1) - seccion.yInf) / seccion.h;
    for i = 1 : length(eVecAcero)
        sigmaHorm = tension_hormigon_rapida(eVecAcero(i), ecf, ...
                        seccion.ec0, seccion.ecu, fcd, seccion.nParHorm);
        sigmaAcero = tension_acero_pasivo(eVecAcero(i), seccion.fyk, ...
                                          seccion.Es, seccion.gamAcero);
        Ni = (sigmaAcero - sigmaHorm) * seccion.geoAcPas(i, 2);
        Mi = Ni * seccion.geoAcPas(i, 1);
        N = N + Ni;
        M = M + Mi;
    end
end

% Cálculo de la contribución del acero activo
if ~isempty(seccion.geoAcAct)
    eVecAcero = eInf + (eSup - eInf) * ...
                       (seccion.geoAcAct(:, 1) - seccion.yInf) / seccion.h;
    for i = 1 : length(eVecAcero)
        sigmaHorm = tension_hormigon_rapida(eVecAcero(i), ecf, ...
                        seccion.ec0, seccion.ecu, fcd, seccion.nParHorm);
        defAcero = deformacion_acero_activo(seccion.geoAcAct(i, 3), ...
                       seccion.fpk, seccion.Ep, seccion.gamAcero);
        sigmaAcero = tension_acero_activo(eVecAcero(i) + defAcero, seccion.fpk, ...
                       seccion.Ep, seccion.gamAcero);
        Ni = (sigmaAcero - sigmaHorm) * seccion.geoAcAct(i, 2);
        Mi = Ni * seccion.geoAcAct(i, 1);
        N = N + Ni;
        M = M + Mi;
    end
end

end