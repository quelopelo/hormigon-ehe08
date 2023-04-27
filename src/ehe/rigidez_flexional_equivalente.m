function EIe = rigidez_flexional_equivalente(N, M, seccion)
%  RIGIDEZ_FLEXIONAL_FISURADA devuelve la rigidez a flexión equivalente de
%  una sección de hormigón armado y/o pretensado para una directa y un
%  momento, según la EHE-08.
% 
%    EIe = rigidez_flexional_equivalente(N, M, seccion) calcula la rigidez
%    a flexión equivalente (no lineal) de una sección de hormigón armado y 
%    pretensado a partir de las hipótesis del capítulo 42.1 y de acuerdo al
%    capítulo 50.2 de la norma EHE-08. Para el cálculo considera una ley
%    plana de deformaciones, una directa 'N' (en N) y un momento flector 'M'
%    (en N.mm); y la geometría de la sección y las propiedades de los
%    materiales indicadas en el estructurado 'seccion'.
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
%    EIe            Rigidez a flexión equivalente no lineal (N.mm2)

% Obtención de las rigideces brutas y fisuradas
EIb = seccion.EIb;
EIf = rigidez_flexional_fisurada(N, M, seccion);

% Cálculo del momento de fisuración
[MfInf, MfSup] = momento_fisuracion(N, seccion);
if M < 0
    Mf = - MfInf;
    M = - M;
elseif M > 0
    Mf = MfSup;
else
    Mf = max(- MfInf, MfSup);
end

% Cálculo de la inercia equivalente (apartado 50.2.2.2 de la EHE-08)
if M <= Mf
    EIe = EIb;
else
    if ~isnan(EIf)
        MfsM3 = (Mf / M) ^ 3;
        EIe = min(MfsM3 * EIb + (1 - MfsM3) * EIf, EIb);
    else
        EIe = NaN;
    end
end

end