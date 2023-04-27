function [eInf, eSup, exitFlag] = deformaciones_normales(N, M, seccion, initFlag)
%  DEFORMACIONES_NORMALES devuelve la pareja de deformaciones asociada a
%  una ley plana de deformaciones de una sección de hormigón armado y/o
%  pretensado para una directa y un momento, según la EHE-08.
% 
%    [eInf, eSup, exitFlag] = deformaciones_normales(N, M, seccion, initFlag)
%    calcula la pareja de deformaciones de una sección de hormigón armado
%    y pretensado según el capítulo 42.1 de la norma EHE-08. Para el cálculo
%    considera una ley plana de deformaciones, una directa 'N' (en N) y un
%    momento flector 'M' (en N.mm); y la geometría de la sección y las
%    propiedades de los materiales indicadas en el estructurado 'seccion'.
%    El parámetro opcional 'initFlag' (por defecto, igual a 1) sirve para
%    modificar la evalúación del punto inicial (ver implementación).
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
%    initFlag       Booleano que permite modificar la evaluación del punto
%                   inicial (ver implementación)
% 
%    SALIDA:
%    eInf           Deformación unitaria de la fibra inferior del hormigón
%    eSup           Deformación unitaria de la fibra superior del hormigón
%    exitFlag       Entero que codifica la salida obtenida

% Valor por defecto de 'initFlag'
if nargin < 4 || isempty(initFlag)
    initFlag = true;
end

% Comprobación de la sección para las solicitaciones actuantes
[coef, eInf, eSup] = coeficiente_solicitaciones_normales(N, M, seccion);
if coef >= 1
    if coef > 1
        eInf = NaN;
        eSup = NaN;
    end
    exitFlag = 1;
    return
end

% Obtención de un punto inicial para el problema de optimización 
% Caso cuando initFlag == false
if ~initFlag
    eInf0 = 0;
    eSup0 = 0;
% Caso cuando initFlag == true
else
	% Análisis del caso de frontera (N == 0 y M == 0)
    if (N == 0) && (M == 0)
        Nf = -eps;
        Mf = 0;
    else
        Nf = N;
        Mf = M;
    end
    % Cálculo del punto inicial para el problema de optimización
    nDiv = 12;
    thVec = linspace(0, 2*pi, nDiv);
    thVec(end) = 0;
    eRadMax = p_poly_dist(seccion.eInf0, seccion.eSup0, ...
                          seccion.eInfAgo, seccion.eSupAgo);
    eRad = min(1e-3, abs(eRadMax));
    eInfVec = eRad * sin(thVec) + seccion.eInf0;
    eSupVec = eRad * cos(thVec) + seccion.eSup0;
    [coef0, eInf0, eSup0] = coeficiente_solicitaciones_normales(Nf, Mf, ...
                                seccion, eInfVec, eSupVec);
    eInf0 = coef0 * eInf0;
    eSup0 = coef0 * eSup0;
    [eInfAux, eSupAux] = polyxpoly(seccion.eInfAgo, seccion.eSupAgo, ...
                                   [0, eInf0], [0, eSup0]);
    if ~isempty(eInfAux)
        eInf0 = min(eInf0, eInfAux(1));
        eSup0 = min(eSup0, eSupAux(1));
    end
end

% Definición del problema de optimización
problem.objective = @solicitaciones_normales_obj;
problem.x0 = [eInf0, eSup0];
problem.solver = 'fsolve';
problem.options = optimoptions('fsolve', 'Display', 'off');
problem.options.StepTolerance = 1e-12;

% Resolución del problema de optimización
tol = problem.options.FunctionTolerance * 10^3;
[eVec, objVal, exitFlag] = fsolve(problem);
err = norm(objVal);

% Modificación del punto inicial si el método inicial no converge
if exitFlag < 0 || err > tol
    coef0 = 1 / coef0;
    pot = 1;
    while (exitFlag < 0 || err > tol) && pot < 5
        eInf1 = eInf0 * (1 - coef) * coef0 + eInf * coef * (1 - coef0);
        eSup1 = eSup0 * (1 - coef) * coef0 + eSup * coef * (1 - coef0);
        problem.x0 = [eInf1, eSup1];
        [eVec, objVal, exitFlag] = fsolve(problem);
        err = norm(objVal);
        coef = coef * coef;
        pot = pot + 1;
    end
end

% Modificación del punto inicial si el método anterior no converge
if exitFlag < 0 || err > tol
    cont = 1;
    red = 1 - cont / 100;
    [eInf2, eSup2] = deformaciones_normales(N, red*M, seccion, initFlag);
    while ~isnan(eInf2) && red >= 0
        cont = cont + 1;
        red = red - cont / 100;
        [eInf2, eSup2] = deformaciones_normales(N, red*M, seccion, initFlag);
    end
    if ~isnan(eInf2)
        problem.x0 = [eInf2, eSup2];
        [eVec, objVal, exitFlag] = fsolve(problem);
        err = norm(objVal);
    end
end

% Asignación de las variables de retorno
if exitFlag >= 0 && err <= tol
    eInf = eVec(1);
    eSup = eVec(2);
else
    eInf = NaN;
    eSup = NaN;
end

% DEFINICIÓN DE FUNCIONES ANIDADAS
    
% solicitaciones_normales_aux(eInf, eSup)
% Definición de la función auxiliar, que facilita el cálculo de Nc y Mc a
% partir de una pareja de deformaciones cualquiera dada en eVec
function [Nc, Mc] = solicitaciones_normales_aux(eVec)
    if eVec(1) > 0.01
        eVec(1) = 0.01;
    elseif eVec(1) < seccion.ecu
        eVec(1) = seccion.ecu;
    end
    if eVec(2) > 0.01
        eVec(2) = 0.01;
    elseif eVec(2) < seccion.ecu
        eVec(2) = seccion.ecu;
    end
    [Nc, Mc] = solicitaciones_normales(eVec(1), eVec(2), seccion);
end
    
% solicitaciones_normales_obj(eVec)
% Definición de la función objetivo, cuyo raíz (obj == 0) corresponde a la
% pareja de deformaciones (en eVec) mediante la cual se obtienen N y M 
function obj = solicitaciones_normales_obj(eVec)
    eMin = min(eVec);
    eMax = max(eVec);
    aux = seccion.ecu - eMin - (seccion.ecu/seccion.ec0 - 1) * eMax;
    con = 1 - max(aux, 0) / seccion.ec0;
    if eMin > 0.01
        con = con + eMin / 0.01 - 1;
    elseif eMin < seccion.ecu
        con = con + eMin / seccion.ecu - 1;
    end
    if eMax > 0.01
        con = con + eMax / 0.01 - 1;
    elseif eMax < seccion.ecu
        con = con + eMax / seccion.ecu - 1;
    end
    [Nc, Mc] = solicitaciones_normales_aux(eVec);
    obj = zeros(2, 1);
    obj(1) = con * (Nc - N);
    obj(2) = con * (Mc - M);
end

end