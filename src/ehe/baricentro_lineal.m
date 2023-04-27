function yG = baricentro_lineal(seccion)
%  BARICENTRO_LINEAL devuelve la posición vertical del baricentro de una
%  sección de hormigón armado y/o pretensado, según la EHE-08.
% 
%    yG = baricentro_lineal(seccion) calcula la posición del baricentro 
%    (lineal) de una sección de hormigón armado y pretensado a partir de 
%    las hipótesis de los materiales de la norma EHE-08.
% 
%    ENTRADA REQUERIDA:
%    seccion        Estructurado con la información de la geometría de la 
%                   seccion y las propiedades de los materiales componentes,
%                   creado a partir de la función crear_seccion.m
% 
%    SALIDA:
%    yG             Posición vertical del baricentro lineal (mm)

% Definición de las variables de acumulación
EAb = 0;
Emub = 0;

% Cálculo de la contribución del hormigón
for i = 1 : (size(seccion.geoHorm, 1) - 1)
    j = i + 1;
    yi = seccion.geoHorm(i, 1); yj = seccion.geoHorm(j, 1);
    bi = seccion.geoHorm(i, 2); bj = seccion.geoHorm(j, 2);
    EAb = EAb + 1/2 * (yj-yi) * (bi+bj);
    Emub = Emub + 1/6 * (yj-yi) * (bi*(2*yi+yj) + bj*(yi+2*yj));
end
EAb = seccion.Ec * EAb;
Emub = seccion.Ec * Emub;

% Cálculo de la contribución del acero pasivo y activo
if ~isempty(seccion.geoAcPas)
    EAb = EAb + seccion.Es * sum(seccion.geoAcPas(:, 2));
    Emub = Emub + seccion.Es * seccion.geoAcPas(:, 2)' * seccion.geoAcPas(:, 1);
end
if ~isempty(seccion.geoAcAct)
    EAb = EAb + seccion.Ep * sum(seccion.geoAcAct(:, 2));
    Emub = Emub + seccion.Ep * seccion.geoAcAct(:, 2)' * seccion.geoAcAct(:, 1);
end

% Cálculo de la posición del baricentro lineal
yG = Emub / EAb;

end