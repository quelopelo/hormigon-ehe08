function [coef, eInf, eSup] = coeficiente_solicitaciones_normales(N, M, ...
                                  seccion, eInfVec, eSupVec)
%  COEFICIENTE_SOLICITACIONES_NORMALES devuelve el coeficiente de
%  verificación de una sección de hormigón armado y/o pretensado para una
%  directa y un momento flector dados, según la EHE-08.
% 
%    coef = coeficiente_solicitaciones_normales(N, M, seccion) devuelve el
%    coeficiente de verificación 'coef' de una sección de hormigón armado
%    y pretensado según el capítulo 42.1 de la norma EHE-08. Para el cálculo
%    considera una ley plana de deformaciones, una directa 'N' (en N) y un
%    momento flector 'M' (en N.mm); y la geometría de la sección y las
%    propiedades de los materiales indicadas en el estructurado 'seccion'.
% 
%    [coef, eInf, eSup] = coeficiente_solicitaciones_normales(N, M, seccion)
%    adicionalmente devuelve la pareja de deformaciones 'eInf' y 'eSup'
%    correspondiente a la ley plana de deformaciones en agotamiento que
%    iguala la exentricidad última con la actuante e ingresada (M / N).
% 
%    [coef, eInf, eSup] = coeficiente_solicitaciones_normales(N, M, seccion, ...
%    eInfVec, eSupVec) permite modificar la frontera de deformaciones a partir 
%    de la pareja de deformaciones definida en los vectores 'eInfVec' y 
%    'eSupVec'. Este sintaxis solo es recomendada para en contextos específicos.
% 
%    ENTRADA REQUERIDA:
%    N              Directa (con signo) actuante (N)
%    M              Momento flector (con signo) actuante en relación a una
%                   alutra 0 (N.mm)
%    seccion        Estructurado con la información de la geometría de la 
%                   seccion y las propiedades de los materiales componentes,
%                   creado a partir de la función crear_seccion.m
% 
%    ENTRADA OPCIONAL (NO RECOMENDADA):
%    eInfVec        Vector de deformaciones unitarias de la fibra inferior
%                   del hormigón correspondiente a la frontera de
%                   deformaciones planas bajo estudio
%    eSupVec        Vector de deformaciones unitarias de la fibra superior
%                   del hormigón correspondiente a la frontera de
%                   deformaciones planas bajo estudio
% 
%    SALIDA:
%    coef           Coeficiente de verificación calculado como la relación
%                   entre las solicitaciones actuantes y las capacidades 
%                   resistentes últimas para la misma excentricidad (M / N)
%    eInf           Deformación unitaria de la fibra inferior del hormigón
%                   correspondiente a la ley de deformaciones en agotamiento
%                   o para la frontera dada si se ingresó 'eInfVec'
%    eSup           Deformación unitaria de la fibra superior del hormigón
%                   correspondiente a la ley de deformaciones en agotamiento
%                   o para la frontera dada si se ingresó 'eSupVec'

% Valor por defecto de 'eInfVec', 'eSupVec', 'NVec', 'MVec', 'NMax' y 'MMax'
if nargin < 4 || (isempty(eInfVec) && isempty(eSupVec))
    eInfVec = seccion.eInfAgo;
    eSupVec = seccion.eSupAgo;
    agoFlag = true;
else
    agoFlag = false;
end

% Análisis del caso de frontera (N == 0 y M == 0)
if (N == 0) && (M == 0)
    coef = 0;
    eInf = NaN;
    eSup = NaN;
    return
end

% Determinación del tramo relativo a los dominios de deformación
if agoFlag
    NVec = seccion.NAgo;
    MVec = seccion.MAgo;
    NMax = max(abs([seccion.NMin seccion.NMax]));
    MMax = max(abs([seccion.MMin seccion.MMax]));
else
    nDiv = length(eInfVec);
    NVec = zeros(nDiv, 1);
    MVec = zeros(nDiv, 1);
    for i = 1 : nDiv-1
        [NVec(i), MVec(i)] = solicitaciones_normales(eInfVec(i), ...
                                                     eSupVec(i), seccion);
    end
    NVec(nDiv) = NVec(1);
	MVec(nDiv) = MVec(1);
    NMax = max(abs(NVec));
    MMax = max(abs(MVec));
end
coefAmp = 1 + max(NMax / (abs(N) + eps), MMax / (abs(M) + eps));
[~, ~, li] = polyxpoly(NVec, MVec, [0, coefAmp * N], [0, coefAmp * M]);
li = li(end, 1);
eInf1 = eInfVec(li); eInf2 = eInfVec(li+1);
eSup1 = eSupVec(li); eSup2 = eSupVec(li+1);

% Definición del problema de optimización
problem.objective = @solicitaciones_normales_obj;
problem.x0 = [0, 1];
problem.solver = 'fzero';
problem.options = optimset('Display', 'off');

% Resolución del problema de optimización
Nc = 0; Mc = 0;
sqrtNM = sqrt(N^2 + M^2);
[~, ~, exitFlag] = fzero(problem);
if exitFlag == 1
    coef = sqrtNM / sqrt(Nc^2 + Mc^2);
else
    coef = NaN;
    eInf = NaN;
    eSup = NaN;
end

% DEFINICIÓN DE FUNCIONES ANIDADAS
    
% solicitaciones_normales_obj(x)
% Definición de la función objetivo, cuya raíz (obj == 0) corresponde al
% coeficiente 'x' que iguala la exentricidad última con la actuante
function obj = solicitaciones_normales_obj(x)
    eInf = (1-x) * eInf1 + x * eInf2;
    eSup = (1-x) * eSup1 + x * eSup2;
    [Nc, Mc] = solicitaciones_normales(eInf, eSup, seccion);
    obj = (- Nc * M + N * Mc) / sqrtNM;
end

end