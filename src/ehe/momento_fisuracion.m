function [MfInf, MfSup] = momento_fisuracion(N, seccion)
%  MOMENTO_FISURACION devuelve los momentos de fisuración de una sección
%  de hormigón armado para una directa dada, según la EHE-08.
% 
%    [MfInf, MfSup] = momento_fisuracion(N, seccion) calcula los momentos
%    de fisuración de una sección de hormigón armado a partir de las hipótesis
%    del capítulo 42.1 de la norma EHE-08. Para el cálculo considera una ley
%    plana de deformaciones, una directa 'N' (en N); y la geometría de la
%    sección y las propiedades de los materiales indicadas en el estructurado
%    'seccion' (incluyendo la resistencia a flexotracción del hormigón, dada
%    por el parámetro 'seccion.fctmfl').
% 
%    ENTRADA REQUERIDA:
%    N              Directa (con signo) actuante (N)
%    seccion        Estructurado con la información de la geometría de la 
%                   seccion y las propiedades de los materiales componentes,
%                   creado a partir de la función crear_seccion.m
% 
%    SALIDA:
%    MfInf          Momento de fisuración para la directa ingresada (N.mm)
%                   relativo al caso en que fisura la fibra inferior
%    MfSup          Momento de fisuración para la directa ingresada (N.mm)
%                   relativo al caso en que fisura la fibra superior

% Obtención los parámetros del hormigón
fcd = seccion.fck / seccion.gamHorm;
ecf = - seccion.ec0 * (1 - (1 - seccion.fctmfl / fcd) ^ (1/seccion.nParHorm));

% Definición del rango de deformaciones
eInfVec = [ecf seccion.ecu];
eSupVec = [seccion.ecu ecf];

% Definición de la variable compartida 'Mc' y del vector 'MfVec'
Mc = 0;
MfVec = [0, 0];

% Cálculo de los momentos de fisuración para los dos casos
% -> Caso 1: fisuración de la fibra inferior
% -> Caso 2: fisuración de la fibra superior
for i = 1 : 2
    % Determinación del tramo relativo a los dominios de deformación
    eInf1 = eInfVec(i); eInf2 = ecf;
    eSup1 = eSupVec(i); eSup2 = ecf;
    % Análisis de los casos extremos (N < N1 o N > N2)
    [N1, ~] = solicitaciones_normales(eInf1, eSup1, seccion, 1);
    [N2, ~] = solicitaciones_normales(eInf2, eSup2, seccion, 1);
    if N < N1
        MfVec(i) = sign(-1.5 + i) * Inf;
        continue
    elseif N > N2
        MfVec(i) = 0;
        continue
    end
    % Definición del problema de optimización
    problem.objective = @solicitaciones_normales_obj;
    problem.x0 = [0, 1];
    problem.solver = 'fzero';
    problem.options = optimset('Display', 'off');
    % Resolución del problema de optimización
    [~, ~, exitFlag] = fzero(problem);
    if exitFlag == 1
        MfVec(i) = Mc;
    else
        MfVec(i) = NaN;
    end     
end

% Asignación de las variables de retorno
MfInf = min(MfVec(1), 0);
MfSup = max(MfVec(2), 0);

% DEFINICIÓN DE FUNCIONES ANIDADAS
    
% solicitaciones_normales_obj(x)
% Definición de la función objetivo, cuya raíz (obj == 0) corresponde al
% coeficiente 'x' que iguala la directa de cálculo con la actuante
function obj = solicitaciones_normales_obj(x)
    eInf = (1-x) * eInf1 + x * eInf2;
    eSup = (1-x) * eSup1 + x * eSup2;
    [Nc, Mc] = solicitaciones_normales(eInf, eSup, seccion, 1);
    obj = Nc - N;
end

end