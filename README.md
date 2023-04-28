# Hórmigon EHE-08

## Introducción

Hórmigon EHE-08 consiste en un conjunto de funciones implementadas en MATLAB para diseñar secciones de hormigón armado y pretensado según la norma española EHE-08. Por ser una versión inicial y estar en desarrollo, el programa se distribuye únicamente mediante el [código fuente](https://github.com/quelopelo/hormigon-ehe08/tree/main/src) de MATLAB.

Actualmente, el programa permite trabajar con secciones de hormigón armado y/o pretensado con un eje de simetría. Una vez ingresada la sección es posible obtener las propiedades lineales, como la posición del baricentro y la inercia bruta; y las propiedades no lineales (dependientes de las solicitaciones), como el momento de fisuración, la inercia fisurada y la inercia equivalente. A su vez, el programa permite obtener la ley plana de deformaciones dadas unas solicitaciones; así como las solicitaciones dada una ley plana de deformaciones. Por último, vinculada a esta última funcionalidad, el programa permite calcular el factor de utilización para unas solicitaciones dadas. Esta función se puede usar iterativamente para dimensionar una sección.

El flujo de trabajo en el programa es el siguiente:
1. Agregar al *path* los directorios [src/ehe](https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe) y [src/utils](https://github.com/quelopelo/hormigon-ehe08/tree/main/src/utils), por ejemplo a partir del script [init](https://github.com/quelopelo/hormigon-ehe08/tree/main/src/init.m).
2. Crear una sección de hormigón armado y/o pretensado usando la función [crear_seccion](https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/crear_seccion.m).
3. Utilizar cualquiera de las funciones incluidas en el directorio [src/ehe](https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe).

Todas las funciones incluyen una ayuda que puede ser consultada desde MATLAB usando el comando `help` seguido por el nombre de la función (por ejemplo: `help crear_seccion`). Adicionalmente, se incluyen algunos [ejemplos](https://github.com/quelopelo/hormigon-ehe08/blob/main/src/docs) que sirven de guía del flujo de trabajo y de las funciones implementadas.

## Lista de funciones

### Crear sección de hormigón armado y/o pretensado

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/crear_seccion.m"><b>crear_seccion</b></a></summary>

    CREAR_SECCION devuelve un estructurado con la geometría de la sección y
    las propiedades de los materiales componentes.

    seccion = crear_seccion(geoHorm, fck, Ec, geoAcPas, fyk, Es) crea y
    devuelve un estructurado 'seccion' con la información de una sección
    de hormigón armado simple (sin acero activo). Para ello considera la
    geometría de la sección indicada en la matriz 'geoHorm', la resistencia
    característica del hormigón 'fck', el módulo de elasticidad del hormigón
    'Ec' (opcional, por defecto calculado según el capítulo 39.6 de la norma
    EHE-08), la geometría del acero pasivo 'geoAcPas', el límite elástico
    del acero pasivo 'fyk' y el módulo de elasticidad del acero pasivo 'Es'
    (opcional, por defecto igual a 200 GPa).

    seccion = crear_seccion(geoHorm, fck, Ec, [], [], [], geoAcAct, fpk, Ep)
    crea y devuelve un estructurado 'seccion' con la información de una
    seccion de hormigón pretensado (sin acero pasivo). Para ello, además
    de 'geoHorm', 'fck' y 'Ec' (opcional), considera la geometría del acero
    activo 'geoAcAct', el límite elástico característico del acero activo
    'fpk' y el módulo de elasticidad del acero activo 'Ep' (opcional, por
    defecto igual a 200 GPa).

    seccion = crear_seccion(geoHorm, fck, Ec, geoAcPas, fyk, Es, ...
    geoAcAct, fpk, Ep) crea y devuelve un estructurado 'seccion' con la
    información de una sección de hormigón armado y pretensado.

    seccion = crear_seccion(geoHorm, fck, Ec, geoAcPas, fyk, Es, ...
    geoAcAct, fpk, Ep, gamHorm, gamAcero, minDivHorm, bariFlag) crea y
    devuelve un estructurado 'seccion' con la información de una sección de
    hormigón armado y pretensado. Además, el estructurado incluye los 
    coeficientes de los materiales 'gamHorm' (hormigón, por defecto igual a
    1.5) y 'gamAcero' (acero, por defecto igual a 1.15); el parámetro
    'minDivHorm' (por defecto, igual a 100), que controla la mínima cantidad
    de alturas en la que se divide la sección de hormigón para efectuar un
    subcálculo lineal; y el booleano 'bariFlag' (por defecto, igual a true),
    que corrige la posición vertical del baricentro en caso de valer 'true'.

    ENTRADA REQUERIDA:
    geoHorm        Geometría del hormigón, dada por una matriz que en la
                   primera columna contiene alturas (en mm) y en la segunda
                   columna contiene anchos (en mm) para esas alturas
    fck            Resistencia característica a compresión del hormigón (MPa)

    ENTRADA OPCIONAL (OBLIGATORIA):
    Ec             Módulo de elasticidad lineal a 28 días del hormigón
    geoAcPas       Geometría del acero pasivo, dada por una matriz que en
                   la primera columna contiene alturas (en mm) y en la
                   segunda columna contiene las áreas de acero (en mm2)
                   asociadas a esas alturas
    fyk            Límite elástico característico del acero pasivo (MPa)

    ENTRADA OPCIONAL (NO OBLIGATORIA):
    Es             Módulo de elasticidad lineal del acero pasivo (MPa)
    geoAcAct       Geometría del acero activo, dada por una matriz que en
                   la primera columna contiene alturas (en mm), en la
                   segunda columna contiene las áreas de acero (en mm2)
                   asociadas a esas alturas y en la tercera columna contiene
                   las tensiones iniciales de pretensado (en MPa) asociadas
                   a las mismas alturas
    fpk            Límite elástico característico del acero activo (MPa)
    Ep             Módulo de elasticidad lineal del acero activo (MPa)
    gamHorm        Factor del material hormigón
    gamAcero       Factor del material acero
    minDivHorm     Mínima cantidad de divisiones en altura del hormigón
    bariFlag       Booleano que permite indicar si el cálculo corrige las
                   posiciones verticales por el baricentro lineal ('true') 
                   o si el cálculo no modifica las posiciones ('false')

    SALIDA:
    seccion        Estructurado con la información de la sección de
                   hormigón armado y/o pretensado.

</details>

### Obtener propiedades lineales

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/baricentro_lineal.m"><b>baricentro_lineal</b></a></summary>

    BARICENTRO_LINEAL devuelve la posición vertical del baricentro de una
    sección de hormigón armado y/o pretensado, según la EHE-08.

    yG = baricentro_lineal(seccion) calcula la posición del baricentro 
    (lineal) de una sección de hormigón armado y pretensado a partir de 
    las hipótesis de los materiales de la norma EHE-08.

    ENTRADA REQUERIDA:
    seccion        Estructurado con la información de la geometría de la 
                   seccion y las propiedades de los materiales componentes,
                   creado a partir de la función crear_seccion.m

    SALIDA:
    yG             Posición vertical del baricentro lineal (mm)

</details>

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/rigidez_flexional_bruta.m"><b>rigidez_flexional_bruta</b></a></summary>

    RIGIDEZ_FLEXIONAL_BRUTA devuelve la rigidez a flexión bruta de una
    sección de hormigón armado y pretensado, según la EHE-08.

    EIb = rigidez_flexional_bruta(seccion) calcula la rigidez a flexión
    bruta (lineal) de una sección de hormigón armado y prentensado a
    partir de las hipótesis de los materiales de la norma EHE-08.

    ENTRADA REQUERIDA:
    seccion        Estructurado con la información de la geometría de la 
                   seccion y las propiedades de los materiales componentes,
                   creado a partir de la función crear_seccion.m

    SALIDA:
    EIb            Rigidez a flexión bruta lineal (N.mm2)

</details>

### Obtener propiedades no lineales

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/momento_fisuracion.m"><b>momento_fisuracion</b></a></summary>

    MOMENTO_FISURACION devuelve los momentos de fisuración de una sección
    de hormigón armado para una directa dada, según la EHE-08.

    [MfInf, MfSup] = momento_fisuracion(N, seccion) calcula los momentos
    de fisuración de una sección de hormigón armado a partir de las hipótesis
    del capítulo 42.1 de la norma EHE-08. Para el cálculo considera una ley
    plana de deformaciones, una directa 'N' (en N); y la geometría de la
    sección y las propiedades de los materiales indicadas en el estructurado
    'seccion' (incluyendo la resistencia a flexotracción del hormigón, dada
    por el parámetro 'seccion.fctmfl').

    ENTRADA REQUERIDA:
    N              Directa (con signo) actuante (N)
    seccion        Estructurado con la información de la geometría de la 
                   seccion y las propiedades de los materiales componentes,
                   creado a partir de la función crear_seccion.m

    SALIDA:
    MfInf          Momento de fisuración para la directa ingresada (N.mm)
                   relativo al caso en que fisura la fibra inferior
    MfSup          Momento de fisuración para la directa ingresada (N.mm)
                   relativo al caso en que fisura la fibra superior

</details>

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/rigidez_flexional_fisurada.m"><b>rigidez_flexional_fisurada</b></a></summary>

    RIGIDEZ_FLEXIONAL_FISURADA devuelve la rigidez a flexión fisurada (no
    lineal) de una sección de hormigón armado y/o pretensado para una
    directa y un momento, según la EHE-08.

    EIf = rigidez_flexional_fisurada(N, M, seccion) calcula la rigidez a 
    flexión fisurada (no lineal) de una sección de hormigón armado y 
    pretensado a partir de las hipótesis del capítulo 42.1 de la norma
    EHE-08. Para el cálculo considera una ley plana de deformaciones, una
    directa 'N' (en N) y un momento flector 'M' (en N.mm); y la geometría
    de la sección y las propiedades de los materiales indicadas en el
    estructurado 'seccion'. El cálculo impone un pequeño giro en torno a
    y = 0 y analiza la variación en el momento flector asociada.

    ENTRADA REQUERIDA:
    N              Directa (con signo) actuante (N)
    M              Momento flector (con signo) actuante en relación a una
                   alutra 0 (N.mm)
    seccion        Estructurado con la información de la geometría de la 
                   seccion y las propiedades de los materiales componentes,
                   creado a partir de la función crear_seccion.m

    SALIDA:
    EIf            Rigidez a flexión fisurada no lineal (N.mm2)

</details>

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/rigidez_flexional_equivalente.m"><b>rigidez_flexional_equivalente</b></a></summary>

    RIGIDEZ_FLEXIONAL_FISURADA devuelve la rigidez a flexión equivalente de
    una sección de hormigón armado y/o pretensado para una directa y un
    momento, según la EHE-08.

    EIe = rigidez_flexional_equivalente(N, M, seccion) calcula la rigidez
    a flexión equivalente (no lineal) de una sección de hormigón armado y 
    pretensado a partir de las hipótesis del capítulo 42.1 y de acuerdo al
    capítulo 50.2 de la norma EHE-08. Para el cálculo considera una ley
    plana de deformaciones, una directa 'N' (en N) y un momento flector 'M'
    (en N.mm); y la geometría de la sección y las propiedades de los
    materiales indicadas en el estructurado 'seccion'.

    ENTRADA REQUERIDA:
    N              Directa (con signo) actuante (N)
    M              Momento flector (con signo) actuante en relación a una
                   alutra 0 (N.mm)
    seccion        Estructurado con la información de la geometría de la 
                   seccion y las propiedades de los materiales componentes,
                   creado a partir de la función crear_seccion.m

    SALIDA:
    EIe            Rigidez a flexión equivalente no lineal (N.mm2)

</details>

### Calcular deformaciones y solicitaciones normales

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/deformaciones_normales.m"><b>deformaciones_normales</b></a></summary>

    DEFORMACIONES_NORMALES devuelve la pareja de deformaciones asociada a
    una ley plana de deformaciones de una sección de hormigón armado y/o
    pretensado para una directa y un momento, según la EHE-08.

    [eInf, eSup, exitFlag] = deformaciones_normales(N, M, seccion, initFlag)
    calcula la pareja de deformaciones de una sección de hormigón armado
    y pretensado según el capítulo 42.1 de la norma EHE-08. Para el cálculo
    considera una ley plana de deformaciones, una directa 'N' (en N) y un
    momento flector 'M' (en N.mm); y la geometría de la sección y las
    propiedades de los materiales indicadas en el estructurado 'seccion'.
    El parámetro opcional 'initFlag' (por defecto, igual a 1) sirve para
    modificar la evalúación del punto inicial (ver implementación).

    ENTRADA REQUERIDA:
    N              Directa (con signo) actuante (N)
    M              Momento flector (con signo) actuante en relación a una
                   alutra 0 (N.mm)
    seccion        Estructurado con la información de la geometría de la 
                   seccion y las propiedades de los materiales componentes,
                   creado a partir de la función crear_seccion.m

    ENTRADA OPCIONAL (NO RECOMENDADA):
    initFlag       Booleano que permite modificar la evaluación del punto
                   inicial (ver implementación)

    SALIDA:
    eInf           Deformación unitaria de la fibra inferior del hormigón
    eSup           Deformación unitaria de la fibra superior del hormigón
    exitFlag       Entero que codifica la salida obtenida

</details>

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/solicitaciones_normales.m"><b>solicitaciones_normales</b></a></summary>

    SOLICITACIONES_NORMALES devuelve la directa y el momento flector de una
    sección de hormigón armado y/o pretensado dada una ley plana de
    deformaciones, según la EHE-08.

    [N, M] = solicitaciones_normales(eInf, eSup, seccion) calcula la 
    directa (en N) y el momento flector (en N.mm) de una sección simétrica
    de hormigón armado y pretensado según el capítulo 42.1 de la norma
    EHE-08. Para el cálculo considera una ley plana de deformaciones, con
    deformaciones unitarias 'eInf' y 'eSup' en los extremos (inferior y
    superior) del hormigón; y la geometría de la sección y las propiedades
    de los materiales indicadas en el estructurado 'seccion'.

    [N, M] = solicitaciones_normales(eInf, eSup, seccion, fctmlFlag) con 
    fctml = true calcula la directa (en N) y el momento flector (en N.mm)
    de una sección simétrica de hormigón armado y pretensado bajo las mismas
    hipótesis de la sintaxis anterior, pero considerando la contribución
    del hormigón a tracción, hasta una tensión igual a 'seccion.fctmfl'.

    ENTRADA REQUERIDA:
    eInf           Deformación unitaria de la fibra inferior del hormigón
    eSup           Deformación unitaria de la fibra superior del hormigón
    seccion        Estructurado con la información de la geometría de la 
                   seccion y las propiedades de los materiales componentes,
                   creado a partir de la función crear_seccion.m

    ENTRADA OPCIONAL (NO RECOMENDADA):
    fctmlFlag      Booleano que permite considerar la contribución del
                   hormigón a flexotracción (por defecto, false)

    SALIDA:
    N              Directa para la ley de deformaciones ingresada (N)
    M              Momento flector (con signo) para la ley de deformaciones
                   ingresada y en relación a una alutra 0 (N.mm)

</details>

### Verificar solicitaciones normales

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/coeficiente_solicitaciones_normales.m"><b>coeficiente_solicitaciones_normales</b></a></summary>

    COEFICIENTE_SOLICITACIONES_NORMALES devuelve el coeficiente de
    verificación de una sección de hormigón armado y/o pretensado para una
    directa y un momento flector dados, según la EHE-08.

    coef = coeficiente_solicitaciones_normales(N, M, seccion) devuelve el
    coeficiente de verificación 'coef' de una sección de hormigón armado
    y pretensado según el capítulo 42.1 de la norma EHE-08. Para el cálculo
    considera una ley plana de deformaciones, una directa 'N' (en N) y un
    momento flector 'M' (en N.mm); y la geometría de la sección y las
    propiedades de los materiales indicadas en el estructurado 'seccion'.

    [coef, eInf, eSup] = coeficiente_solicitaciones_normales(N, M, seccion)
    adicionalmente devuelve la pareja de deformaciones 'eInf' y 'eSup'
    correspondiente a la ley plana de deformaciones en agotamiento que
    iguala la excentricidad última con la actuante e ingresada (M / N).

    [coef, eInf, eSup] = coeficiente_solicitaciones_normales(N, M, seccion, ...
    eInfVec, eSupVec) permite modificar la frontera de deformaciones a partir 
    de la pareja de deformaciones definida en los vectores 'eInfVec' y 
    'eSupVec'. Esta sintaxis solo es recomendada para en contextos específicos.

    ENTRADA REQUERIDA:
    N              Directa (con signo) actuante (N)
    M              Momento flector (con signo) actuante en relación a una
                   alutra 0 (N.mm)
    seccion        Estructurado con la información de la geometría de la 
                   seccion y las propiedades de los materiales componentes,
                   creado a partir de la función crear_seccion.m

    ENTRADA OPCIONAL (NO RECOMENDADA):
    eInfVec        Vector de deformaciones unitarias de la fibra inferior
                   del hormigón correspondiente a la frontera de
                   deformaciones planas bajo estudio
    eSupVec        Vector de deformaciones unitarias de la fibra superior
                   del hormigón correspondiente a la frontera de
                   deformaciones planas bajo estudio

    SALIDA:
    coef           Coeficiente de verificación calculado como la relación
                   entre las solicitaciones actuantes y las capacidades 
                   resistentes últimas para la misma excentricidad (M / N)
    eInf           Deformación unitaria de la fibra inferior del hormigón
                   correspondiente a la ley de deformaciones en agotamiento
                   o para la frontera dada si se ingresó 'eInfVec'
    eSup           Deformación unitaria de la fibra superior del hormigón
                   correspondiente a la ley de deformaciones en agotamiento
                   o para la frontera dada si se ingresó 'eSupVec'

</details>

### Funciones auxiliares

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/deformacion_acero_activo.m"><b>deformacion_acero_activo</b></a></summary>

    DEFORMACION_ACERO_ACTIVO devuelve la deformación unitaria del acero
    activo según la EHE-08.

    ep = deformacion_acero_activo(sigma, fpk, Ep, gamAcero) devuelve la
    deformación unitaria del acero activo según el apartado 38.7 de la norma
    EHE-08 (diagrama simplificado con sigma_pd = fpd), dada la tensión
    'sigma' (en MPa), el límite elástico del acero 'fpk' (en MPa), el módulo
    de elasticidad lineal del acero 'Es' (por defecto, igual a 200 GPa), y
    el factor del material acero 'gamAcero' (por defecto, igual a 1.15). 

    ENTRADA REQUERIDA:
    sigma          Tensión del acero (MPa)   
    fpk            Límite elástico característico del acero activo (MPa)

    ENTRADA OPCIONAL:
    Ep             Módulo de elasticidad lineal del acero activo (MPa)
    gamAcero       Factor del material acero

    SALIDA:
    ep             Deformación unitaria del acero de pretensado

</details>

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/tension_acero_activo.m"><b>tension_acero_activo</b></a></summary>

    TENSION_ACERO_ACTIVO devuelve la tensión del acero activo según la EHE-08.

	sigma = tension_acero_activo(ep, fpk, Ep, gamAcero) devuelve la tensión
    del acero activo (en MPa) según el apartado 38.7 de la norma EHE-08
	(diagrama simplificado con sigma_pd = fpd), dada la deformación
    unitaria 'ep', el límite elástico del acero 'fpk' (en MPa), el módulo
    de elasticidad lineal del acero 'Es' (por defecto, igual a 200 GPa), y
    el factor del material acero 'gamAcero' (por defecto, igual a 1.15). 

    ENTRADA REQUERIDA:
    ep             Deformación unitaria del acero de pretensado
    fpk            Límite elástico característico del acero activo (MPa)

    ENTRADA OPCIONAL:
    Ep             Módulo de elasticidad lineal del acero activo (MPa)
    gamAcero       Factor del material acero

    SALIDA:
    sigma          Tensión del acero para los parámetros ingresados (MPa)

</details>

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/tension_acero_pasivo.m"><b>tension_acero_pasivo</b></a></summary>

    TENSION_ACERO_PASIVO devuelve la tensión del acero pasivo según la EHE-08.

	sigma = tension_acero_pasivo(es, fyk, Es, gamAcero) devuelve la tensión
    del acero pasivo (en MPa) según el apartado 38.4 de la norma EHE-08
	(diagrama bilineal con plastificación perfecta), dada la deformación
    unitaria 'es', el límite elástico del acero 'fyk' (en MPa), el módulo
    de elasticidad lineal del acero 'Es' (por defecto, igual a 200 GPa), y
    el factor del material acero 'gamAcero' (por defecto, igual a 1.15). 

    ENTRADA REQUERIDA:
    es             Deformación unitaria del acero
    fyk            Límite elástico característico del acero pasivo (MPa)

    ENTRADA OPCIONAL:
    Es             Módulo de elasticidad lineal del acero pasivo (MPa)
    gamAcero       Factor del material acero

    SALIDA:
    sigma          Tensión del acero para los parámetros ingresados (MPa)

</details>

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/tension_hormigon.m"><b>tension_hormigon</b></a></summary>

    TENSION_HORMIGON devuelve la tensión del hormigón según la EHE-08.

	sigma = tension_hormigon(ec, fck, fct, gamHormigon) devuelve la tensión
	del hormigón (en MPa) según el apartado 39.5 de la norma EHE-08
    (diagrama de cálculo parábola-rectángulo), dada la deformación unitaria
    'ec', la resistencia característica del hormigón 'fck' (en MPa), la
    resistencia límite a tracción del hormigón 'fct' (en MPa) y el factor
    del material hormigón 'gamHorm' (por defecto, igual a 1.5).

    ENTRADA REQUERIDA:
    ec             Deformación unitaria del hormigón
    fck            Resistencia característica a compresión del hormigón (MPa)

    ENTRADA OPCIONAL:
    fct            Resistencia límite a tracción del hormigón (MPa)
    gamHorm        Factor del material hormigón

    SALIDA:
    sigma          Tensión del hormigón para los parámetros ingresados (MPa)

</details>

<details>
<summary><a href="https://github.com/quelopelo/hormigon-ehe08/tree/main/src/ehe/tension_hormigon_rapida.m"><b>tension_hormigon_rapida</b></a></summary>

    TENSION_HORMIGON_RAPIDA devuelve la tensión del hormigón según la EHE-08.

	sigma = tension_hormigon_rapida(ec, ecf, ec0, ecu, fcd, n) devuelve la
    tensión del hormigón (en MPa) según el apartado 39.5 de la norma EHE-08
    (diagrama de cálculo parábola-rectángulo), dada la deformación unitaria
    'ec', y los parámetros 'ecf', 'ec0', 'ecu', 'fcd' y 'n' (ver entrada
    requerida y tension_hormigon.m por más detalles).

    ENTRADA REQUERIDA:
    ec             Deformación unitaria del hormigón
    ecf            Deformación correspondiente a la fisuración
    ec0            Deformación de rotura a compresión simple
    ecu            Deformación última
    fcd            Resistencia de diseño a compresión del hormigón (MPa)
    n              Grado de la "parábola"

    SALIDA:
    sigma          Tensión del hormigón para los parámetros ingresados (MPa)

</details>

## Ejemplos

Esta sección contiene los enlaces a los ejemplos de la documentación.

El [ejemplo 1](https://htmlpreview.github.io/?https://github.com/quelopelo/hormigon-ehe08/blob/main/docs/ejemplo1.html) consiste en la inicialización del programa, la creación de una sección de hormigón armado, y el análisis de las propiedades calculadas e incluidas en la sección generada. El ejemplo termina con el gráfico del diagrama de interacción de la sección generada.

El [ejemplo 2](https://htmlpreview.github.io/?https://github.com/quelopelo/hormigon-ehe08/blob/main/docs/ejemplo2.html) consiste en la creación de una sección de hormigón pretensado, y el análisis de las propiedades calculadas (específicas de las secciones pretensadas). Posteriormente, se calcula y grafica el momento de fisuración (en función de la directa aplicada) y la inercia equivalente (en función de la directa y el momento flector aplicados).

> En proceso de generación del ejemplo 3

## Posibles futuros trabajos

- Extender el cálculo de solicitaciones normales a secciones sin un eje de simetría.
- Agregar funciones adicionales para verificar otros estados límite (ELS y ELU).
- Utilizar una normativa más actualizada y de alcance internacional, como el Eurocódigo 2.
- Incorporar el diseño y cálculo de otros materiales, como acero o madera.
- Mejorar la eficiencia de las funciones implementadas.
- Generar la documentación en otros idiomas, especialmente en inglés.
- Agregar una interfaz de usuario (GUI) que permita visualizar los datos introducidos y los resultados.
- Implementar el programa en otro lenguaje de programación, que no sea propietario y que admita la programación orientada a objetos.
