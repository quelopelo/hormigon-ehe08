function EIf = rigidez_flexional_fisurada(N, M, seccion)
%  RIGIDEZ_FLEXIONAL_FISURADA devuelve la rigidez a flexión fisurada (no
%  lineal) de una sección de hormigón armado y/o pretensado para una
%  directa y un momento, según la EHE-08.
% 
%    EIf = rigidez_flexional_fisurada(N, M, seccion) calcula la rigidez a 
%    flexión fisurada (no lineal) de una sección de hormigón armado y 
%    pretensado a partir de las hipótesis del capítulo 42.1 de la norma
%    EHE-08. Para el cálculo considera una ley plana de deformaciones, una
%    directa 'N' (en N) y un momento flector 'M' (en N.mm); y la geometría
%    de la sección y las propiedades de los materiales indicadas en el
%    estructurado 'seccion'. El cálculo impone un pequeño giro en torno a
%    y = 0 y analiza la variación en el momento flector asociada.
% 
%    ENTRADA REQUERIDA:
%    N              Directa (con signo) actuante (N)
%    M              Momento flector (con signo) actuante en relación a una
%                   alutra 0 (N.mm)
%    seccion        Estructurado con la información de la geometría de la 
%                   seccion y las propiedades de los materiales componentes,
%                   creado a partir de la función crear_seccion.m
% 
%    SALIDA:
%    EIf            Rigidez a flexión fisurada no lineal (N.mm2)

% Determinación de la pareja de deformaciones correspondiente a 'N' y 'M'
[eInf0, eSup0] = deformaciones_normales(N, M, seccion);

% Cálculo de una pareja de deformaciones cercana a la de 'eInf0' y 'eSup0'
dRot = 1e-12;
eInf1 = eInf0 + seccion.yInf * dRot;
eSup1 = eSup0 + seccion.ySup * dRot;
in = inpolygon(eInf1, eSup1, seccion.eInfAgo, seccion.eSupAgo);
if ~in(1)
    eInf1 = eInf0 - seccion.yInf * dRot;
    eSup1 = eSup0 - seccion.ySup * dRot;
    in = inpolygon(eInf1, eSup1, seccion.eInfAgo, seccion.eSupAgo);
    if ~in(1)
        EIf = NaN;
        return;
    end
end

% Cálculo de la rigidez a flexión
[~, M0] = solicitaciones_normales(eInf0, eSup0, seccion);
[~, M1] = solicitaciones_normales(eInf1, eSup1, seccion);
dM = M0 - M1;
EIf = abs(dM / dRot);

end