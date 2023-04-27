function seccion = crear_seccion(geoHorm, fck, Ec, geoAcPas, fyk, Es, ...
             geoAcAct, fpk, Ep, gamHorm, gamAcero, minDivHorm, bariFlag)
%  CREAR_SECCION devuelve un estructurado con la geometría de la sección y
%  las propiedades de los materiales componentes.
% 
%    seccion = crear_seccion(geoHorm, fck, Ec, geoAcPas, fyk, Es) crea y
%    devuelve un estructurado 'seccion' con la información de una sección
%    de hormigón armado simple (sin acero activo). Para ello considera la
%    geometría de la sección indicada en la matriz 'geoHorm', la resistencia
%    característica del hormigón 'fck', el módulo de elasticidad del hormigón
%    'Ec' (opcional, por defecto calculado según el capítulo 39.6 de la norma
%    EHE-08), la geometría del acero pasivo 'geoAcPas', el límite elástico
%    del acero pasivo 'fyk' y el módulo de elasticidad del acero pasivo 'Es'
%    (opcional, por defecto igual a 200 GPa).
% 
%    seccion = crear_seccion(geoHorm, fck, Ec, [], [], [], geoAcAct, fpk, Ep)
%    crea y devuelve un estructurado 'seccion' con la información de una
%    seccion de hormigón pretensado (sin acero pasivo). Para ello, además
%    de 'geoHorm', 'fck' y 'Ec' (opcional), considera la geometría del acero
%    activo 'geoAcAct', el límite elástico característico del acero activo
%    'fpk' y el módulo de elasticidad del acero activo 'Ep' (opcional, por
%    defecto igual a 200 GPa).
% 
%    seccion = crear_seccion(geoHorm, fck, Ec, geoAcPas, fyk, Es, ...
%    geoAcAct, fpk, Ep) crea y devuelve un estructurado 'seccion' con la
%    información de una sección de hormigón armado y pretensado.
% 
%    seccion = crear_seccion(geoHorm, fck, Ec, geoAcPas, fyk, Es, ...
%    geoAcAct, fpk, Ep, gamHorm, gamAcero, minDivHorm, bariFlag) crea y
%    devuelve un estructurado 'seccion' con la información de una sección de
%    hormigón armado y pretensado. Además, el estructurado incluye los 
%    coeficientes de los materiales 'gamHorm' (hormigón, por defecto igual a
%    1.5) y 'gamAcero' (acero, por defecto igual a 1.15); el parámetro
%    'minDivHorm' (por defecto, igual a 100), que controla la mínima cantidad
%    de alturas en la que se divide la sección de hormigón para efectuar un
%    subcálculo lineal; y el booleano 'bariFlag' (por defecto, igual a true),
%    que corrige la posición vertical del baricentro en caso de valer 'true'.
% 
%    ENTRADA REQUERIDA:
%    geoHorm        Geometría del hormigón, dada por una matriz que en la
%                   primera columna contiene alturas (en mm) y en la segunda
%                   columna contiene anchos (en mm) para esas alturas
%    fck            Resistencia característica a compresión del hormigón (MPa)
% 
%    ENTRADA OPCIONAL (OBLIGATORIA):
%    Ec             Módulo de elasticidad lineal a 28 días del hormigón
%    geoAcPas       Geometría del acero pasivo, dada por una matriz que en
%                   la primera columna contiene alturas (en mm) y en la
%                   segunda columna contiene las áreas de acero (en mm2)
%                   asociadas a esas alturas
%    fyk            Límite elástico característico del acero pasivo (MPa)
% 
%    ENTRADA OPCIONAL (NO OBLIGATORIA):
%    Es             Módulo de elasticidad lineal del acero pasivo (MPa)
%    geoAcAct       Geometría del acero activo, dada por una matriz que en
%                   la primera columna contiene alturas (en mm), en la
%                   segunda columna contiene las áreas de acero (en mm2)
%                   asociadas a esas alturas y en la tercera columna contiene
%                   las tensiones iniciales de pretensado (en MPa) asociadas
%                   a las mismas alturas
%    fpk            Límite elástico característico del acero activo (MPa)
%    Ep             Módulo de elasticidad lineal del acero activo (MPa)
%    gamHorm        Factor del material hormigón
%    gamAcero       Factor del material acero
%    minDivHorm     Mínima cantidad de divisiones en altura del hormigón
%    bariFlag       Booleano que permite indicar si el cálculo corrige las
%                   posiciones verticales por el baricentro lineal ('true') 
%                   o si el cálculo no modifica las posiciones ('false')
% 
%    SALIDA:
%    seccion        Estructurado con la información de la sección de
%                   hormigón armado y/o pretensado.

% Valor por defecto de 'Ec, 'geoAcPas', 'fyk', 'Es', 'geoAcAct', 'fpk',
% 'Ep', 'gamHorm', 'gamAcero' y 'minDivHorm'
if isempty(Ec)
    Ec = 8500 * (fck + 8) ^ (1 / 3);
end
if isempty(geoAcPas)
    fyk = 0;
end
if isempty(fyk) || fyk == 0
    geoAcPas = [];
    fyk = 0;
end
if nargin < 6 || isempty(Es)
    Es = 200000;
end
if nargin < 7 || isempty(geoAcAct)
    fpk = 0;
end
if nargin < 8 || isempty(fpk) || fpk == 0
    geoAcAct = [];
    fpk = 0;
end
if nargin < 9 || isempty(Ep)
    Ep = 200000;
end
if nargin < 10 || isempty(gamHorm)
    gamHorm = 1.5;
end
if nargin < 11 || isempty(gamAcero)
    gamAcero = 1.15;
end
if nargin < 12 || isempty(minDivHorm)
    minDivHorm = 100;
end
if nargin < 13 || isempty(bariFlag)
    bariFlag = true;
end

% Corrección del órden de la matriz 'geoHorm'
if geoHorm(1, 1) > geoHorm(end, 1)
    geoHorm = flip(geoHorm, 1);
end

% Creación del estructurado 'seccion'
seccion.geoHorm = geoHorm;
seccion.fck = fck;
seccion.Ec = Ec;
seccion.geoAcPas = geoAcPas;
seccion.fyk = fyk;
seccion.Es = Es;
seccion.geoAcAct = geoAcAct;
seccion.fpk = fpk;
seccion.Ep = Ep;
seccion.gamHorm = gamHorm;
seccion.gamAcero = gamAcero;
seccion.minDivHorm = minDivHorm;

% Corrección del centro de gravedad
if bariFlag
    yG = baricentro_lineal(seccion);
    if ~isempty(seccion.geoAcPas)
        geoHorm(:, 1) = geoHorm(:, 1) - yG;
    end
    geoAcPas(:, 1) = geoAcPas(:, 1) - yG;
    if ~isempty(seccion.geoAcAct)
        geoAcAct(:, 1) = geoAcAct(:, 1) - yG;
    end
    seccion.geoHorm = geoHorm;
    seccion.geoAcPas = geoAcPas;
    seccion.geoAcAct = geoAcAct;
end

% Obtención de las propiedades geométricas
yInf = geoHorm(1, 1);
ySup = geoHorm(end, 1);
h = ySup - yInf;
if fpk == 0
    yAcInf = min(geoAcPas(:, 1));
    yAcSup = max(geoAcPas(:, 1));
elseif fyk == 0
    yAcInf = min(geoAcAct(:, 1));
    yAcSup = max(geoAcAct(:, 1));
else
    yAcInf = min([geoAcPas(:, 1); geoAcAct(:, 1)]);
    yAcSup = max([geoAcPas(:, 1); geoAcAct(:, 1)]);
end
dInf = ySup - yAcInf;
dSup = yAcSup - yInf;

% Obtención de las propiedades de los materiales
if fck <= 50
    ec0 = - 0.002;
    ecu = - 0.0035;
    nParHorm = 2;
    fctm = 0.30 * fck ^ (2/3);
else
    ec0 = - (0.002 + 0.000085 * (fck - 50) ^ 0.5);
    ecu = - (0.0026 + 0.0144 * (1 - fck/100) ^ 4);
    nParHorm = 1.4 + 9.6 * (1 - fck/100) ^ 4;
    fctm = 0.58 * fck ^ (1/2);
end
fctmfl = max(1.6 * h / 1000, 1) * fctm;

% Actualización del estructurado 'seccion'
seccion.yInf = yInf;
seccion.ySup = ySup;
seccion.h = h;
seccion.dInf = dInf;
seccion.dSup = dSup;
seccion.ec0 = ec0;
seccion.ecu = ecu;
seccion.nParHorm = nParHorm;
seccion.fctm = fctm;
seccion.fctmfl = fctmfl;

% Cálculo de la inercia bruta
seccion.EIb = rigidez_flexional_bruta(seccion);

% Cálculo de los vectores de pareja de deformaciones 'eInfAgo' y 'eSupAgo'
% correspondientes a la ley de deformaciones en agotamiento
eInfMax = ecu + (0.01 - ecu) * h / dInf;
eInf = [0.01 ecu ecu ec0 0 eInfMax 0.01];
eSupMax = ecu + (0.01 - ecu) * h / dSup;
eSup = [0.01 eSupMax 0 ec0 ecu ecu 0.01];
ePas = 1e-4;
nDiv = zeros(length(eInf) - 1, 1);
for i = 1 : length(nDiv)
    nDiv(i) = ceil((abs(eInf(i+1)-eInf(i)) + abs(eSup(i+1)-eSup(i))) / ePas);
end
nDivTot = sum(nDiv);
eInfAgo = zeros(nDivTot + 1, 1);
eSupAgo = eInfAgo;
k = 1;
for i = 1 : length(nDiv)
    ni = nDiv(i) + 1;
    eInfAgo(k : k+nDiv(i)) = linspace(eInf(i), eInf(i+1), ni);
    eSupAgo(k : k+nDiv(i)) = linspace(eSup(i), eSup(i+1), ni);
    k = k + nDiv(i);
end
seccion.eInfAgo = eInfAgo;
seccion.eSupAgo = eSupAgo;

% Cálculo del diagrama de interacción
NAgo = zeros(nDivTot + 1, 1);
MAgo = NAgo;
for i = 1 : nDivTot
    [NAgo(i), MAgo(i)] = solicitaciones_normales(eInfAgo(i), eSupAgo(i), seccion);                            
end
NAgo(nDivTot + 1) = NAgo(1);
MAgo(nDivTot + 1) = MAgo(1);
seccion.NAgo = NAgo;
seccion.MAgo = MAgo;
seccion.NMin = min(NAgo);
seccion.NMax = max(NAgo);
seccion.MMin = min(MAgo);
seccion.MMax = max(MAgo);

% Cálculo de las deformaciones iniciales asociadas al pretensado
seccion.eInf0 = 0;
seccion.eSup0 = 0;
[eInf0, eSup0] = deformaciones_normales(0, 0, seccion, 0);
seccion.eInf0 = eInf0;
seccion.eSup0 = eSup0;

end