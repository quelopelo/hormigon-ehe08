function EIb = rigidez_flexional_bruta(seccion)
%  RIGIDEZ_FLEXIONAL_BRUTA devuelve la rigidez a flexión bruta de una
%  sección de hormigón armado y pretensado, según la EHE-08.
% 
%    EIb = rigidez_flexional_bruta(seccion) calcula la rigidez a flexión
%    bruta (lineal) de una sección de hormigón armado y prentensado a
%    partir de las hipótesis de los materiales de la norma EHE-08.
% 
%    ENTRADA REQUERIDA:
%    seccion        Estructurado con la información de la geometría de la 
%                   seccion y las propiedades de los materiales componentes,
%                   creado a partir de la función crear_seccion.m
% 
%    SALIDA:
%    EIb            Rigidez a flexión bruta lineal (N.mm2)

% Definición de la variable de acumulación
EIb = 0;

% Cálculo de la contribución del hormigón
for i = 1 : (size(seccion.geoHorm, 1) - 1)
    j = i + 1;
    yi = seccion.geoHorm(i, 1); yj = seccion.geoHorm(j, 1);
    bi = seccion.geoHorm(i, 2); bj = seccion.geoHorm(j, 2);
    EIb = EIb + 1/12 * (yj-yi) * ((3*bi+bj)*yi^2 + 2*(bi+bj)*yi*yj + ...
                                    (bi+3*bj)*yj^2);
end
EIb = seccion.Ec * EIb;

% Cálculo de la contribución del acero pasivo y activo
if ~isempty(seccion.geoAcPas)
    EIb = EIb + seccion.Es * seccion.geoAcPas(:, 2)' * seccion.geoAcPas(:, 1).^2;
end
if ~isempty(seccion.geoAcAct)
    EIb = EIb + seccion.Ep * seccion.geoAcAct(:, 2)' * seccion.geoAcAct(:, 1).^2;
end

end