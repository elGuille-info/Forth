( abrir gForth e indicar 
include adivina.forth

Para usar otras versiones:
adivina-versiones\adivina-v1.195.forth
)
\ Marcar que se han cargado las palabras, 05-ene-2023 18.12
[DEFINED] adivina.forth [IF]
    adivina.forth
[THEN]
marker adivina.forth

\ Adivinar un número
: VERSION-ADIVINA   ." *** Adivina Forth v1.264 (16-ene-2023 13.29) *** " ;

\ v1.264 (16-ene-2023 13.29)
\   En reiniciar ya no se asigna una cadena vacía a quejugar, se asigna al cargar el fichero.
\   En jugar-solo mostrar qué tipo de juego es.
\   Cuando se llame a las opciones de jugar solo poner en quejugar el valor del tipo de juego
\       para mostarlo desde jugar-solo.

\ v1.263 (16-ene-2023 12.38)
\   Muevo %comandos, etc a la parte de variables
\   Muevo %ayudas, $ayudas, ayuda>s y ayuda-index a la parte de variables.
\   Muevo %dificultades, etc a la parte de variables.
\   Muevo la definición de comprobarsee a la parte de las variables.
\   En reiniciar asignar una cadena vacía a quejugar.
\   Muevo las variables de quejugar, etc antes de las palabras.
\   Quito debugs en ayuda-see.

\ v1.262 (16-ene-2023 12.33)
\   En DEBUG1 y DEBUG2 mostrar el texto indicado después de ">>> "

\ v1.261 (16-ene-2023 12.06)
\   Ajustando algunas cosas en jugar-bucle y jugar-cambiar.


\ NOTAS:
\   Cuando se use >R y R> (o 2>R y 2R>) hay que hacerlo de forma que se use el par 
\       antes de que se use "algo" que utilice el return stack,
\       si no, se pierde el valor o sabe dios lo que puede pasar.


\ TODO:
\   En jugar solo, al finalizar, preguntar si quiere que juegue solo de nuevo,
\       pudiendo cambiar el tipo de juego en solitario: actual, facil, dificil, auto.
\   En dime, poder usar jugar <opcion> y confirmar si se quiere cambiar la opción de juego.
\   Pendiente desde v1.232...
\   En ayuda?ayuda dividir queayuda por espacio 
\       para tener en quenumeros y queletras y poder comprobar si queletras está en blanco,
\       también sirve para comprobar si quenumeros tiene la palabra ayuda.
\       Esto servirá para saber si se ha escrito ayuda <> o ayuda <loquesea>,
\       si es el primer caso, mostrar la ayuda general que corresponda,
\       si es el segundo caso, buscar <loquesea> en las ayudas,
\           dividiendo queletras en 2, por espacio o guión.
\   En DIFICULTADES-MOSTRAR poder ponerle un parámetro para los espacios a usar:
\       con 4 espacios delante: s"    " DIFICULTADES-MOSTRAR
\       sin   espacios delante: s" "
\   Cambiar los nombres de las palabras de forma que empiecen o tengan ... si ...:
\       Siempre de la variable indicada, por ejemplo 'QUEAYUDA
\       .   imprimir, muestrar en la consola, type
\       '   devuelve addr len
\       !   para asignar un valor
\       >n  devuelve un número simple, normalmente sin signo, ej. s>n sería como tou
\       >s  devuelve una cadena, addr len
\       ?n  es un número simple, normalmente sin signo, ej. s?n, sería como to?u
\   Cambiar STR>INT para que devuelva NO_NUM si se indica un número y letras.
\       No, dejarlo como está.
\   Al sacar el número a adivinar, comprobar si será uno de los múltiplos habituales
\       si es así, sacar otro y no comprobar ese caso más.
\   El nivel de dificultad debe tener en cuenta el nivel,
\       ya que no es lo mismo adivinar un número entre 1 y 100 que entre 1 y 1200.
\   Guardar los intentos de cada partida con el nivel.
\       Diferenciar entre humano y maquina.
\   Guardar el número de intentos más bajo al adivinar el número en cada nivel.
\       Esto hay que guardarlo en un array.
\       Diferenciar entre humano y maquina.


\ Las palabras y variables a usar

\ *********************************************************
\ * Definiciones de palabras adicionales al juego adivina *
\ *********************************************************

FALSE VALUE ESGFORTH?
: ES-GFORTH?
    s" gforth" environment?
    0= 
    if FALSE TO ESGFORTH?
    else TRUE TO ESGFORTH? 2DROP
    then
;
ES-GFORTH?

[UNDEFINED] between [IF]
: between within ;
[THEN]

[UNDEFINED] toupper [IF]
\ Si es una letra de la a a la z en minúsculas, la convierte en mayúsculas
\ sino, devuelve el mismo carácter
: toupper   ( char -- char )
    DUP
    [CHAR] a [CHAR] z 1+ WITHIN
    IF 32 - THEN
;
[THEN]

\ Para los números aleatorios

\ Adaptado del fichero "C:\Program Files (x86)\gforth\tt.fs"
variable seed
\ time&date pone en la pila s m h d M y 
: randomize   time&date + + + + + seed ! ;
$10450405 Constant generator
: rnd  ( -- n )  seed @ generator um* drop 1+ dup seed ! ;
: random ( n -- 0..n-1 )  rnd um* nip ;

\ v1.14 Un número aleatorio entre los dos indicados, ambos inclusive
: random2   ( n1 n2 -- n1..n2 )
    \ hace una copia del primero y lo pone arriba de la pila
    OVER \ w1 w2 -- w1 w2 w1
    - 1 + \ n2-n1+1 
    \ random saca un número entre 0 y uno menos del número indicado
    \ por eso le sumo 1 para que sea entre 0 y n2-n1 inclusive
    random 
    \ le sumamos el primero para que sea un número entre n1 y n2 ambos inclusive
    +
;

\ Esto devuelve TRUE o FALSE siempre
\ Si se indica cualquier valor que no sea cero, se convierte en FALSE
[UNDEFINED] NOT [IF]
: NOT   ( flag -- flag ) IF FALSE ELSE TRUE THEN ;
[THEN]

\ muestra un número sencillo como cadena sin espacios delante ni detrás
: STR   ( n -- d como cadena ) 0 <# #S #> TYPE ;

\ del fichero easy.4th
\ Para usarla: <longitud> STRING <nombre>
\ STRING es compatible con las variables definidas como:
\   VARIABLE <nombre> <longitud> ALLOT
\   CREATE <nombre> <longitud> CELLS ALLOT
\   CREATE <nombre> <longitud> CHARS ALLOT
[UNDEFINED] STRING [IF]
: STRING CREATE CHARS ALLOT ;
[THEN]
\ v1.240 definir STRING2 para usar al crear las variables
\ Ya que la definición de string en SwiftForth es diferente a esta
: STRING2 CREATE CHARS ALLOT ;
\ En SwiftForth parace que está definida como:
\ : STRING CREATE STRING, ;

\ Limpiar el contenido de la pila (31-dic-2022 18.40)
: LIMPIAR-PILA   DEPTH 0> IF DEPTH 0 DO DROP LOOP THEN ;

\ Definir clearstacks para SwiftForth, 14-ene-2023 09.17
[UNDEFINED] clearstacks [IF]
: clearstacks   ( -- )  LIMPIAR-PILA ;
[THEN]

\ para usarlo desde palabras en formato: <nombre> <respuesta>
\ por ejemplo: AYUDA pista
\ : AYUDA   1 TEXT PAD QUEAYUDA MAX_AYUDA MOVE <el codigo para buscar la ayuda> ;
\ 1 TEXT PAD <nombre> <max len> MOVE
: TEXT  ( delimiter -- )  PAD 258 BL FILL WORD COUNT PAD SWAP MOVE ;

\ Para crear un array de forma fácil (01-ene-2023 09.48)
\ Usage <n> ARRAY <name>
: ARRAY   ( n -- )
    CREATE  CELLS ALLOT
    \ Esto es lo que hace fuera de la definición
    DOES> ( n -- a )
    SWAP CELLS + ;

\ v1.240 Lo vuelvo a usar para compatibilidad con SwiftForth
\ (02-ene-2023 22.26)
\ Para poder crear arrays de cadenas con $"
4096 constant /string-space

( Reserve  STRING-SPACE  in data-space. )
CREATE STRING-SPACE           /STRING-SPACE CHARS ALLOT
VARIABLE NEXT-STRING          0 NEXT-STRING !

( "string<">" — caddr ) 
: $" [CHAR] " PARSE
  DUP 1+ NEXT-STRING @ + /STRING-SPACE >
        ABORT" String Space Exhausted. "
  STRING-SPACE NEXT-STRING @ CHARS + >R
  DUP 1+ NEXT-STRING +!
  R@ PLACE
  R>
;

\ SwiftForth no tiene la definición de find-name,
\ hacer esta comprobación para definir see? para gForth
\ en SwiftForth se puede usar see porque no lanza error
[DEFINED] find-name [IF]
\ Comprobar si una palabra existe sin mostrar error, 10-ene-2023 10.15
: see? parse-name find-name dup 0= if drop ." no existe " else name-see then ;
[ELSE]
: find-name   CR ." Esto es find-name si no está definido" ;
: see?   see ;
[THEN] \ [UNDEFINED] find-name [IF]

\ Nuevas palabras para convertir en un número y comprobar si es un número, 04-ene-2023 17.15
\ Compruebo las que son iguales, 15-ene-2023 08.59

\ Convierte una cadena en un número ud
\   Si la cadena tiene caracteres el flag será FALSE
\   Si la cadena no tiene caracteres el flag será TRUE
\   Si la cadena no tenía un número, ud será 0.
: to?ud   ( addr len -- ud flag ) 
    0. 2swap >number nip 0>
    if 2drop 0. false else true then ;

\ Convierte una cadena en un número ud
\   Si la cadena no tiene números el flag es FALSE y ud es 0.
\   Si la cadena empieza por números el flag es TRUE y ud es el número
: toud   ( addr len -- ud flag ) 0. 2swap dup >r >number nip r> < ;

\ alias para toud y to?ud
: str>ud   ( addr len -- ud flag ) toud ;
: str?ud   ( addr len -- ud flag ) to?ud ;

\ Convierte una cadena en un número u
\   Si la cadena tiene caracteres el flag será FALSE
\   Si la cadena no tiene caracteres el flag será TRUE
\   Si la cadena no tenía un número, u será 0.
: to?u   ( addr len -- u flag ) 
    0. 2swap >number nip 0>
    \ si tiene caracteres quitar el valor ud de la pila y dejar false
    \ si no tiene, quitar el cero y dejar true
    if 2drop 0 false else drop true then ;

\ Convierte una cadena en un número u
\   Si la cadena no tiene números el flag es FALSE y u es 0.
\   Si la cadena empieza por números el flag es TRUE y u es el número
: tou   ( addr len -- u flag )
    0. 2swap dup >r >number nip r> <
    \ quitar el número extra
    swap drop
;

\ alias para tou y to?u
: str>u   ( addr len -- u flag ) tou ;
: str?u   ( addr len -- u flag ) to?u ;

\ Defino str?u? y str?ud? para comprobar si es o no un número, 15-ene-2023 09.56
\   sin devolver el número y 
\   teniendo en cuenta que si tiene caracteres, delante o detrás del número,
\       devolverá false
: str?ud?   ( addr len -- flag )
    0. 2swap >number nip 0>
    -rot 2drop not
;
: str?u?   ( addr len -- flag ) str?ud? ;

\ Comprobar si es un número, devolverá true o false
\   El número a convertir puede tener letras después del número
\       en ese caso devuelve true
\ : STR>NUM?  ( addr len -- flag )
\     0. 2swap dup >r >number nip r> <
\     2SWAP 2DROP
\ ;

\ v1.128 cambio NO-NUM por NO_NUM, 06-ene-2023 01.28
#-1234567890 CONSTANT NO_NUM

\ Convierte un string en un número simple, 
\   deja el número o NO_NUM si no lo ha convertido
\ Funciona con s" 123" STR>INT . -- 123
\ También funciona con una variable definida con VARIABLE <NOMBRE> <TAMAÑO> ALLOT
\   Usando <NOMBRE> <TAMAÑO> -TRAILING STR>INT
\ : STR>INT  ( addr len -- n )
\     0. 2swap dup >r >number nip r> <
\     
\     \ Si no lo convierte, la pila tendrá 0 0 0
\     \ Si lo convierte, la pila tendrá num 0 -1
\     \   Es decir, el último valor es el flag de si lo ha convertido
\     
\     \ Si no lo ha convertido, devolver NO_NUM o el número sencillo
\     0= IF 2DROP NO_NUM ELSE DROP THEN
\ ;

\ Definiciones para saber si es un dígito, una letra o una cadena tiene letras, 05-ene-2023 17.42

\ En gForth digit? está definido y hace lo mismo

\ Comprueba si el contenido de la pila es un dígito
\ No se comprueba si es el signo - 45 o el signo + 43
\ Usando la definición del libro Forth Application Techniques
: DIGITO? ( nchar -- flag )
    [CHAR] 0 [CHAR] 9 1+ WITHIN ;
     
\ Comprueba si es una letra, no es un digito
: LETRA?  ( nchar -- flag ) DIGITO? INVERT ;

\ Comprobar si la cadena indicada en la pila tiene letras, 05-ene-2023 13.30
\ Se considera letras si no es un número
\ Esto solo funciona con variables definidas con ALLOT, no funciona con CELLS ALLOT
: LETRAS?   ( addr len -- flag )
    \ Dejar false en la pila sin afectar a los valores dejados en la pila
    2>R FALSE 2R>
    BOUNDS
    DO 
        I C@ 
        \ Si no es entre 48 y 57 es que tiene letras
        LETRA?
        IF DROP TRUE LEAVE THEN
    LOOP
;

\ Definiciones en string.fs de Gforth, 05-ene-2023 23.24
\ dynamic string handling                              12dec99py

\ Solo utilizo split$, 06-ene-2023 00.23
: $split ( addr u char -- addr1 u1 addr2 u2 )
  >r 2dup r> scan dup >r dup IF  1 /string  THEN
  2swap r> - 2swap ;

\ hacer un volcado de la memoria de la dirección indicada
\   y opcionalmente la cantidad, si no se indica se usan 80
: ADDR-DUMP   ( addr n -- ) 
    DEPTH 1 = IF 80 THEN
    DUMP 
    DECIMAL
;

\ v1.217 función para saber si una cadena tiene el carácter indicado
\ dejará la posición en base 0 o -1 si no está
\   ej. char - s" hola-mundo" s?char
: S?CHAR   ( char addr len -- pos|-1 )
    \ dejar -1 antes de los parámetros
    2DUP 2>R 2>R >R -1 R> 2R>
    BOUNDS 
    ?DO
        DUP
        I c@ = 
        IF DROP I SWAP LEAVE THEN
    LOOP
    DROP
    DUP
    -1 = IF 2R> 2DROP ELSE 2R> BOUNDS SWAP DROP - THEN
;

\ v1.223 12-ene-2023 16.20
\ Rellenar de espacios la cadena indicada
\   hasta el máximo indicado
: ?LIMPIAR   ( addr len max -- ) 
    DEPTH 3 < IF CR ." Se necesitan 3 parametros en la pila." CR EXIT THEN
    MIN BLANK ;

\ **************************************
\ * Las definiciones propias del juego *
\ **************************************

\ Las palabras que se usan antes de definirlas, 06-ene-2023 06.19
DEFER COMANDOS-MOSTRAR  \ : COMANDOS-MOSTRAR
DEFER DIME              \ : DIME
DEFER AYUDA             \ : AYUDA
DEFER DIFICULTAD-INDEX  \ : DIFICULTAD-INDEX
DEFER REINICIAR         \ : REINICIAR
DEFER JUGAR             \ : JUGAR
DEFER JUGAR-QUEJUGAR    \ : JUGAR-QUEJUGAR
DEFER JUGAR-OPCIONES    \ : JUGAR-OPCIONES
DEFER JUGAR-BUCLE       \ : JUGAR-BUCLE
DEFER JUGAR-CAMBIAR     \ : JUGAR-CAMBIAR

\ v1.215 para mostrar o no los mensajes de depuración
\ Debug? ya está definido en gforth
VARIABLE ESDEBUG? TRUE ESDEBUG? !

\ para facilitar la búsqueda de donde se muestran comentarios
: DEBUG1   ( addr len -- ) ESDEBUG? @ IF CR ." >>> " TYPE .s ELSE 2DROP THEN ;
: DEBUG2   ( addr1 len1 addr2 len2 -- ) 
    ESDEBUG? @ 
    IF CR 2SWAP ." >>> " TYPE ." '" TYPE ." ' " .s 
    ELSE 2DROP 2DROP
    THEN
;

\ *********************************************************************************
\ * Constantes y variables                                                        *
\ * Definirlas todas antes de las palabras que las usan                           *
\ *                                                                               *
\ * Aquí también estarán las palabras para acceder a las variables de tipo cadena *
\ *********************************************************************************

\ El número de orden actual de los números indicados, 
\   el máximo será INTENTOSMAXIMO ya que se juega con nivel de dificultad
\ v1.94 cambio I.N por INTENTOS
VARIABLE INTENTOS

\ v1.52 para saber quién está jugando
\ v1.54 cambio HUMANO por _HUMANO y MAQUINA por _MAQUINA
10 CONSTANT _HUMANO
11 CONSTANT _MAQUINA
\ v1.54 antes QUIEN-JUEGA
\ v1.81 asigno _HUMANO a QUIENJUEGA
\ v1.94 cambio QUIEN.JUEGA por QUIENJUEGA
VARIABLE QUIENJUEGA _HUMANO QUIENJUEGA !

\ v1.50 para saber que se ha mostrdo la solución al pasar los intentos
\ v1.54 cambio SOLUCION-MOSTRADA por SOLUCION.MOSTRADA
\ v1.94 cambio SOLUCION.MOSTRADA por SOLUCIONMOSTRADA
VARIABLE SOLUCIONMOSTRADA FALSE SOLUCIONMOSTRADA !

\ Los números según el nivel de juego:
\ n adivinar un número del 1 al n*100
\ Los niveles son del 1 al 9.
\ v1.42 defino el nivel máximo como variable
\ Le asigno el valor 12 a ver qué pasa
\ v1.94 cambio NIVEL.MAX por NIVELMAXIMO
VARIABLE NIVELMAXIMO 12 NIVELMAXIMO !

\ v1.5 el valor predeterminado del nivel es 1
\ v1.54 cambio EL-NIVEL por EL.NIVEL
\ v1.94 cambio EL.NIVEL por ELNIVEL
VARIABLE ELNIVEL 1 ELNIVEL !

\ El número a adivinar 
\ v1.54 cambio NUM por EL.NUM
\ v1.94 cambio EL.NUM por NUMEROADIVINAR
VARIABLE NUMEROADIVINAR
\ El último número indicado 
\ v1.94 cambio N.LAST por ULTIMONUMERO
VARIABLE ULTIMONUMERO 

\ El número máximo de adivinazas ( 51 = de 0 a 50 )
\ Aunque se usará siempre INTENTOSMAXIMO, esto solo define el máximo para el array ARRAY.NUMS.
\ v1.54 cambio MAX.NUMS por MAX_NUMS ya que es una constante
51 CONSTANT MAX_NUMS

\ El número máximo de intentos, será según el nivel de dificultad
\ v1.94 cambio MAX.INTENTOS por INTENTOSMAXIMO
VARIABLE INTENTOSMAXIMO MAX_NUMS INTENTOSMAXIMO !

\ El nivel de DIFICULTAD
\ v1.94 cambio NIVEL.D por NIVELDIFICULTAD
VARIABLE NIVELDIFICULTAD -1 NIVELDIFICULTAD !

\ Array para los números indicados de 0 a MAX_NUMS
\ v1.54 cambio NUMS por ARRAY.NUMS
MAX_NUMS ARRAY ARRAY.NUMS

\ v1.15 para los valores más cercanos
\ El menor más cercano
\ v1.94 cambio N.MENOR por MENORINDICADO
VARIABLE MENORINDICADO
\ El mayor más cercano
\ v1.94 cambio N.MAYOR por MAYORINDICADO
VARIABLE MAYORINDICADO

\ v1.46 estaba definida en la línea 346 y se usa antes en la 281
\ v1.23 Usar una variable para el número indicado
\   Con idea de no tener que duplicar el número indicado y usar ese valor en las comprobaciones.
\ v1.94 cambio N.GUESS por NUMEROINDICADO
VARIABLE NUMEROINDICADO

\ v1.208, variable para cuando se llama desde JUGAR
VARIABLE DESDEJUGAR

\ Variable para la palabra escrita
\ Máximo 20 caracteres
\ v1.111 lo cambio a 40 caracteres
40 CONSTANT MAX_AYUDA
\ v1.237 vuelvo a definirlas con VARIABLE para ver si va en SwiftForth
VARIABLE QUEAYUDA MAX_AYUDA ALLOT
\ Así también funciona, estando QUENUMEROS y QUELETRAS con: CREATE ... MAX_AYUDA CHARS ALLOT
\ CREATE QUEAYUDA MAX_AYUDA CELLS ALLOT
\ CREATE QUEAYUDA MAX_AYUDA CHARS ALLOT
\ MAX_AYUDA STRING2 QUEAYUDA

\ Crear las variables para el número y las letras, 05-ene-2023 23.00
VARIABLE QUENUMEROS MAX_AYUDA ALLOT
VARIABLE QUELETRAS MAX_AYUDA ALLOT
\ Para probar con otras definiciones
\ CREATE QUENUMEROS MAX_AYUDA CELLS ALLOT
\ CREATE QUELETRAS MAX_AYUDA CELLS ALLOT
\ CREATE QUENUMEROS MAX_AYUDA CHARS ALLOT
\ CREATE QUELETRAS MAX_AYUDA CHARS ALLOT
\ MAX_AYUDA STRING2 QUENUMEROS
\ MAX_AYUDA STRING2 QUELETRAS

\ Devuelve la dirección y longitud del contenido de QUEAYUDA
: 'QUEAYUDA   ( -- addr len ) QUEAYUDA MAX_AYUDA -TRAILING ;

\ Devuelve TRUE o FALSE según tenga alguna letra
: QUEAYUDA?LETRAS   ( -- flag ) 'QUEAYUDA LETRAS? ;

\ Limpiar el contenido de QUEAYUDA con espacios
: QUEAYUDA-LIMPIAR   ( -- ) 'QUEAYUDA BLANK ;

\ Asignar el contenido de una dirección de memoria a QUEAYUDA
\   El texto se indicará con s" ..." o dejando una dirección y longitud en la pila
\ v1.223 no asignar más de los caracteres que puede contener
: QUEAYUDA!   ( addr len -- ) QUEAYUDA-LIMPIAR MAX_AYUDA MIN QUEAYUDA SWAP MOVE ;
\ : QUEAYUDA!   ( addr len -- ) QUEAYUDA-LIMPIAR QUEAYUDA SWAP MOVE ;

\ Muestra en la consola el contenido de QUEAYUDA
: QUEAYUDA.   ( -- ) 'QUEAYUDA TYPE ;

\ Comprueba si el contenido de QUEAYUDA es un número
\ Devolver false si tiene letras
: QUEAYUDA?N    ( -- ) QUEAYUDA?LETRAS FALSE = ;

\ Convierte el contenido de QUEAYUDA en un número
\ v1.251 devuelve NO_NUM si contiene carcteres antes o después del número
: QUEAYUDA>N   ( -- n ) \ 'QUEAYUDA STR>INT ;
    'QUEAYUDA to?u
    \ si el top de la pila es false, es que tenía letras,
    \   en ese caso, dejar NO_NUM en la pila
    NOT IF DROP NO_NUM THEN
;

\ La longitud de QUEAYUDA
: QUEAYUDA-LEN   ( -- len ) 'QUEAYUDA SWAP DROP ;

\ Convertir el contenido de QUEAYUDA en mayúsculas
: QUEAYUDA>MAYUSCULAS   ( -- ) 'QUEAYUDA BOUNDS ?DO I c@ toupper I c! LOOP ;

\ v1.217 comprobar si QUEAYUDA tiene el carácter indicado
: QUEAYUDA?C   ( char -- flag )
    'QUEAYUDA S?CHAR
;
\ Comprobar si QUEAYUDA empieza por un número, 06-ene-2023 00.05
: QUEAYUDA?1N   ( -- flag ) QUEAYUDA C@ DIGITO? ;

: 'QUENUMEROS   ( -- addr len ) QUENUMEROS MAX_AYUDA -TRAILING ;
: 'QUELETRAS   ( -- addr len ) QUELETRAS MAX_AYUDA -TRAILING ;

: QUENUMEROS-LEN   ( -- len ) 'QUENUMEROS SWAP DROP ;
: QUELETRAS-LEN   ( -- len ) 'QUELETRAS SWAP DROP ;

: QUENUMEROS-LIMPIAR   ( -- ) 'QUENUMEROS BLANK ;
: QUELETRAS-LIMPIAR   ( -- ) 'QUELETRAS BLANK ;

\ Limpiar los números y las letras, 06-ene-2023 02.01
\   con idea de llamarlo desde AYUDA-SEE antes de llamar a QUEAYUDA?1N
: QUENUMEROS-LETRAS-LIMPIAR   ( -- ) QUENUMEROS-LIMPIAR QUELETRAS-LIMPIAR ;

\ v1.223 no asignar más de los caracteres que puede contener
\ Asignar la cadena indicada a QUENUMEROS
\ : QUENUMEROS!   ( addr len -- ) QUENUMEROS-LIMPIAR QUENUMEROS SWAP MOVE ;
: QUENUMEROS!   ( addr len -- ) QUENUMEROS-LIMPIAR MAX_AYUDA MIN QUENUMEROS SWAP MOVE ;
\ Asignar la cadena indicada a QUELETRAS
\ : QUELETRAS!   ( addr len -- ) QUELETRAS-LIMPIAR QUELETRAS SWAP MOVE ;
: QUELETRAS!   ( addr len -- ) QUELETRAS-LIMPIAR MAX_AYUDA MIN QUELETRAS SWAP MOVE ;

\ Convertir QUENUMEROS en un número, 06-ene-2023 00.29
: QUENUMEROS>N   ( -- numero )
    \ Comprobar si el contenido es una de las palabras de $DIFICULTADES
    \ Si no es uno de esos valores, convertirlo a número
    \ Si es, dejará en la pila el valor.
    'QUENUMEROS DIFICULTAD-INDEX
    \ hacer una copia porque la comparación lo quitará
    DUP
    -1 =
    \ IF DROP 'QUENUMEROS STR>INT THEN
    IF
        DROP 'QUENUMEROS to?u
        \ si el top de la pila es false, es que tenía letras,
        \   en ese caso, dejar NO_NUM en la pila
        NOT IF DROP NO_NUM THEN
        \ s" en quenumeros>n, QUENUMEROS= " 'QUENUMEROS DEBUG2
    THEN
;

\ Divide el contenido de QUEAYUDA separándolo por un espacio 
\   para cuando primero están los números
: QUEAYUDA-SPLIT-NUMEROS-LETRAS   'QUEAYUDA 32 $SPLIT QUELETRAS! QUENUMEROS! ;
\   para cuando primero están las letras
: QUEAYUDA-SPLIT-LETRAS-NUMEROS   'QUEAYUDA 32 $SPLIT QUENUMEROS! QUELETRAS! ;

\ v1.227 variable temporal para manipular las ayudas
\ v1.237 La defino con VARIABLE para ver si va en SwiftForth
VARIABLE QUEAYUDATMP MAX_AYUDA ALLOT
\ MAX_AYUDA STRING2 QUEAYUDATMP

: 'QUEAYUDATMP   ( -- addr len ) QUEAYUDATMP MAX_AYUDA -TRAILING ;
: QUEAYUDATMP!   ( addr len -- ) 
    QUEAYUDATMP MAX_AYUDA MAX_AYUDA ?LIMPIAR MAX_AYUDA MIN QUEAYUDATMP SWAP MOVE
;

\ v1.218 divide QUELETRAS por un espacio
\ deja en QUENUMEROS la primera parte y en QUELETRAS la segunda
\   esto no va con la misma variable, usar una temporal
: QUELETRAS-SPLIT   ( -- )
    \ estaban al revés las asignaciones
    \ pero no se puede asignar a la misma dirección !!!???
    \ 'QUELETRAS 32 $SPLIT QUELETRAS! QUENUMEROS!
    'QUELETRAS 32 $SPLIT QUEAYUDATMP! QUENUMEROS!
    'QUEAYUDATMP QUELETRAS!
;

\ Divide el contenido de QUEAYUDA por un guión
\   para comprobar si se escribe AYUDA-XXX
: QUEAYUDA-SPLIT-GUION   'QUEAYUDA [CHAR] - $SPLIT QUELETRAS! QUENUMEROS! ;

VARIABLE QUEAYUDAPOS

\ Para incrementar el contenido de QUEAYUDAPOS
: QUEAYUDAPOS-INC   ( -- ) QUEAYUDAPOS @ 1 + QUEAYUDAPOS ! ;

\ Unir lo que hay en QUELETRAS y QUENUMEROS y guardarlo en QUEAYUDA
\ para usar como 'QUENUMEROS 'QUELETRAS
: QUEAYUDA-UNIR   ( -- )
    QUEAYUDA QUEAYUDAPOS !
    'QUENUMEROS BOUNDS ?DO I c@ QUEAYUDAPOS @ c! QUEAYUDAPOS-INC LOOP
    s"  " drop c@  QUEAYUDAPOS @ c! QUEAYUDAPOS-INC
    'QUELETRAS BOUNDS ?DO I c@ QUEAYUDAPOS @ c! QUEAYUDAPOS-INC LOOP
;

\ Divide el contenido del QUEAYUDA separándolo por un espacio
\   Si empieza por un número lo que haya antes del espacio se asigna a QUENUMEROS
\   si no, se asigna a QUELETRAS
: QUEAYUDA-SPLIT
    \ Limpiar el contenido de los números y las letras, 06-ene-2023 01.58
    QUENUMEROS-LIMPIAR
    QUELETRAS-LIMPIAR
    QUEAYUDA?1N
    IF QUEAYUDA-SPLIT-NUMEROS-LETRAS
    ELSE QUEAYUDA-SPLIT-LETRAS-NUMEROS
    THEN
;

\ Asignar el texto escrito en la consola a QUEAYUDA con MAX_AYUDA máximo de caracteres
\ : DI-QUEAYUDA   1 TEXT PAD QUEAYUDA MAX_AYUDA MOVE ;

\ v1.230 para el texto que se escriba con jugar
VARIABLE QUEJUGAR MAX_AYUDA ALLOT

\ Devuelve la dirección y longitud del contenido de QUEJUGAR
: 'QUEJUGAR   ( -- addr len ) QUEJUGAR MAX_AYUDA -TRAILING ;

\ La longitud de QUEJUGAR
: QUEJUGAR-LEN   ( -- len ) 'QUEJUGAR SWAP DROP ;

\ Convertir el contenido de QUEJUGAR en mayúsculas
: QUEJUGAR>MAYUSCULAS   ( -- ) 'QUEJUGAR BOUNDS ?DO I c@ toupper I c! LOOP ;

\ Limpiar el contenido de QUEAYUDA con espacios
: QUEJUGAR-LIMPIAR   ( -- ) 'QUEJUGAR BLANK ;

\ Asignar el contenido de una dirección de memoria a QUEAYUDA
\   El texto se indicará con s" ..." o dejando una dirección y longitud en la pila
\ No asignar más de los caracteres que puede contener
: QUEJUGAR!   ( addr len -- ) QUEJUGAR-LIMPIAR MAX_AYUDA MIN QUEJUGAR SWAP MOVE ;

\ Muestra en la consola el contenido de QUEJUGAR
: QUEJUGAR.   ( -- ) 'QUEJUGAR TYPE ;

8 CONSTANT %JUGAR
\ Definir el array con las palabras que se podrán usar, 14-ene-2023 19.15
\   Si solo se escribe jugar, se sigue como ahora.
\   Las opciones de JUGAR serían:
\       <nada>, interactivo, solo, SOLO AUTO, SOLO FACIL, SOLO DIFICIL
\       facil, dificil, auto
CREATE $JUGAR
    $" FACIL" ,
    $" DIFICIL" ,
    $" AUTO" ,
    $" INTERACTIVO" , 
    $" SOLO" , 
    $" SOLO AUTO" , 
    $" SOLO FACIL" , 
    $" SOLO DIFICIL" , 
    $" ?" ,

CREATE $JUGARINFO
    $" juegas con nivel de 1 a 5 y dificultad de SENCILLO a MEDIO" ,
    $" juegas con nivel de 4 a 12 y dificultad de DIFICIL a SENSEI" ,
    $" juegas con nivel 1 a 12 y dificultad de SENCILLO a SENSEI" ,
    $" juegas con los niveles actuales en modo interactivo (no en bucle)" , 
    $" el ordenador juega solo con los niveles actuales" , 
    $" el ordenador juega solo con nivel 1 a 12 y dificultad de SENCILLO a SENSEI" , 
    $" el ordenador juega solo con nivel de 1 a 5 y dificultad de SENCILLO a MEDIO" ,
    $" el ordenador juega solo con nivel de 4 a 12 y dificultad de DIFICIL a SENSEI" , 
    $" para mostrar estas opciones" , 

\ Deja en la pila la dirección de memoria del texto del índice indicado
: JUGAR>S   ( index -- addr len )
    %JUGAR MIN 0 MAX
    \ Si se define con $"
    $JUGAR SWAP CELLS + @ COUNT
;
: JUGAR-LEN   ( index -- len )
    JUGAR>S SWAP DROP
;
: JUGARINFO>S   ( index -- addr len )
    %JUGAR MIN 0 MAX
    \ Si se define con $"
    $JUGARINFO SWAP CELLS + @ COUNT
;

\ Para ver si se debe comprobar la palabra para mostrar la ayuda correspondiente
\ y si no se encuentra esa palabra salir sin más.
VARIABLE COMPROBARSEE FALSE COMPROBARSEE !


\ El valor máximo para las dificultades
\ En el array se buscará siempre desde 1 o _SENCILLO
6 CONSTANT %DIFICULTADES

\ Constantes para el nivel de DIFICULTAD
\ v1.105 el mínimo es 1 y el máximo 5, antes de 0 a 4
\ SENCILLO 22, MEDIO 14, DIFICIL 9, EXPERTO 6, MAESTRO 5
\ SENCILLO 22, MEDIO 14, DIFICIL 12, EXPERTO 9, MAESTRO 6, SENSEI 5
1 CONSTANT _SENCILLO
2 CONSTANT _MEDIO
3 CONSTANT _DIFICIL
4 CONSTANT _EXPERTO
5 CONSTANT _MAESTRO
%DIFICULTADES CONSTANT _SENSEI

\ Array con los valores de las dificultades
CREATE NDIFICULTADES
    255 , 22 , 14 , 12 , 9 , 6 , 5 ,

\ Definir el array con los niveles de las dificultades, 6-ene-2023
\ El array contiene los textos y los valores de los intentos
\ El índice 0 no se usa
\ v1.240 volver a usar $"
CREATE $DIFICULTADES
    $" _ALEATORIO" , 
    $" _SENCILLO" , 
    $" _MEDIO" , 
    $" _DIFICIL" , 
    $" _EXPERTO" , 
    $" _MAESTRO" , 
    $" _SENSEI" , 

\ Asigna el nivel de dificultad según la dificultad indicada
\ Muestra los intentos del índice indicado: de 1 _SENCILLO a 6 _SENSEI o %DIFICULTADES
: DIFICULTAD>N   ( index -- num ) 4 * NDIFICULTADES + @ ;

\ Imprime el nombre y los números de intentos
\ El índice siempre de 1 a %DIFICULTADES
: DIFICULTAD.   ( index -- str )
    DUP
    \ Si se define con $"
    $DIFICULTADES SWAP CELLS + @ COUNT TYPE ."  "
    ." (" DIFICULTAD>N . ." intentos)"
;

\ Deja en la pila la dirección de memoria del texto del índice indicado
: DIFICULTAD>S   ( index -- addr len ) %DIFICULTADES MIN 1 MAX $DIFICULTADES SWAP CELLS + @ COUNT ;

\ Para mostrar las dificultades en DIFICULTADES-MOSTRAR
: LAS-DIFICULTADES
    ."    "
    %DIFICULTADES 1 + 1
    DO 
        I . ." = " I DIFICULTAD. ."  "
        I 3 + 3 MOD 0= IF CR ."    " THEN
    LOOP
;

\ v1.245 añado D! y N! para usar en las ayudas
\ El número de elementos de $AYUDAS
15 CONSTANT %AYUDAS
\ Definir el array de las ayudas
CREATE $AYUDAS
    $" GENERAL" ,  \ 0
    $" JUGAR" ,
    $" NIVEL" ,
    $" DIFICULTAD" ,
    $" PISTA" , 
    $" ADIVINA" ,
    $" FORTH" , \ 6
    \ AYUDA-INTERACTIVO
    $" INTERACTIVO" , \ 7
    $" JUGAR-INTERACTIVO" , \ 8
    $" JUGAR INTERACTIVO" , \ 9
    $" JUGANDO" , \ 10
    \ AYUDA-SOLO
    $" SOLO" , \ 11
    $" JUGAR SOLO" , \ 12
    $" D!" , 
    $" N!" ,
    $" AYUDA" ,

\ Se accede siempre de 0 a %AYUDAS
: AYUDA>S   ( index -- addr len )
    \ Que solo acepte valores entre %AYUDAS y 0  03-ene-2023 13.25
    %AYUDAS MIN 0 MAX 
    \ Deja en la pila la dirección de $AYUDAS del índice que está en la pila
    \ Si se define con $"
    $AYUDAS SWAP CELLS + @ COUNT
;

\ Busca en la colección $AYUDAS si está la palabra dejada en la pila
\ Debe estar en mayúsculas, será al estilo de QUEAYUDA MAX_AYUDA -TRAILING
: AYUDA-INDEX   ( addr len -- index|-1 )
    \ s"     al entrar en ayuda-index " DEBUG1
    \ Poner -1 y dejarlo antes de addr len: -1 addr len
    -1 -ROT
    %AYUDAS 1+ 0
    DO
        2DUP
        I AYUDA>S COMPARE 0=
        IF 
            \ En la pila habrá -1 addr len
            \ Se quitan las 2 cosas que hay y 
            \ se pone I y 2 valores para quitar después de salir
            2DROP DROP I 0 0
            LEAVE THEN
    LOOP
    \ En la pila estará el valor del índice si se ha hallado, 
    \ si no, lo que hubiera en la pila y la dirección puesta al entrar
    2DROP
    \ s"     al salir de ayuda-index " DEBUG1
;

9 CONSTANT %COMANDOS
\ Definir el array con las palabras que se podrán usar, 4-ene-2023 19.42
CREATE $COMANDOS
    $" NIVEL" ,
    $" DIFICULTAD" , 
    $" PISTA" , 
    $" A-N?" , 
    $" RESUELVE" , 
    $" NUMS?" , 
    $" AYUDA" , 
    $" D!" , 
    $" N!" , 
    $" JUGAR" ,

\ definir un array con la explicación de los comandos, 06-ene-2023 04.58
CREATE $COMANDOS-TEXT
    $" para mostrar o cambiar el NIVEL de juego (no es recomendable cambiar el NIVEL)." ,
    $" para mostrar o cambiar el nivel de DIFICULTAD." ,
    $" para mostrarte una pista del numero que puedes indicar." , 
    $" para que el ordenador te diga que numero elegir." , 
    $" para mostrar la solucion y terminar." , 
    $" para mostrarte los numeros que has indicado hasta ahora." , 
    $" para mostrarte las ayudas disponibles." , 
    $" alias para mostrar o cambiar el nivel de DIFICULTAD." , 
    $" alias para mostrar o cambiar el NIVEL de juego." ,
    $" para elegir otro tipo de juego y abandonar el actual." ,

: COMANDO>S   ( index -- addr len )
    \ Que solo acepte valores entre %COMANDOS y 0  03-ene-2023 13.25
    %COMANDOS MIN 0 MAX 
    \ Deja en la pila la dirección de $COMANDOS del índice que está en la pila
    
    \ Si se define con s"
    \ $COMANDOS SWAP 2 CELLS * + 2@ 
    
    \ Si se define con $"
    $COMANDOS SWAP CELLS + @ COUNT
;

: COMANDO-LEN   ( index -- len )
    COMANDO>S SWAP DROP
;

\ Deja en la pila la dirección de memoria del texto del índice indicado
: COMANDO-TEXT>S   ( index -- addr len )
    %COMANDOS MIN 0 MAX 
    \ Si se define con s"
    \ $COMANDOS-TEXT SWAP 2 CELLS * + 2@
    \ Si se define con $"
    $COMANDOS-TEXT SWAP CELLS + @ COUNT
;

\ Busca en la colección $COMANDOS si está la palabra dejada en la pila
\ Debe estar en mayúsculas, será al estilo de QUEAYUDA MAX_AYUDA -TRAILING
: COMANDO-INDEX  ( addr len -- index|-1 )
    \ guardar cuántos valores hay en la pila
    DEPTH >R
    %COMANDOS 1+ 0
    DO 
        2DUP
        I COMANDO>S COMPARE 0=
        IF I -ROT LEAVE THEN
    LOOP
    \ Cuando llegue aquí solo debe haber un valor en la pila
    \ Si hay más es que no se ha encontrado
    DEPTH R> = IF -1 -ROT THEN
    2DROP
;

\ Muestra los comandos disponibles en el modo de juego en bucle, usando DIME.
\ : COMANDOS-MOSTRAR   ( -- )
:NONAME
    %COMANDOS 1 + 0
    DO
        \ ."     " I COMANDO>S TYPE ."  - " I $COMANDOS-TEXT SWAP CELLS + @ COUNT TYPE CR
        \ Que tenga 11 caracteres de ancho la lista de comandos
        \   La palabra más larga tiene 10
        ."     " I COMANDO>S TYPE 
        11 I COMANDO-LEN - SPACES
        ."  - " I COMANDO-TEXT>S TYPE CR
    LOOP
    \ CR
; IS COMANDOS-MOSTRAR

\ ******************************************************
\ * Las palabras del juego                             *
\ * Las variables y arrays deben estar definidas antes *
\ ******************************************************

\ Hacer una pregunta y devolver la respuesta en QUEAYUDA.
\ Los parámetros son:
\   addr2 len2 La cadena a mostrar antes de la pregunta
\   addr1 len1 La pregunta
\ Devuelve el índice de la opción elegida o -1 si no existe.
: PREGUNTA?   ( addr2 len2 addr1 len1 -- )
    TYPE CR TYPE
    TIB MAX_AYUDA ACCEPT #TIB !  0 >IN !
    1 TEXT PAD QUEAYUDA MAX_AYUDA MOVE
    \ Convertir en mayúsculas
    QUEAYUDA>MAYUSCULAS
    \ Si es la letra indicada en mayúsculas, pondrá TRUE en la pila, si no pondrá FALSE
    QUEAYUDA C@ = 
;
\ Preguntar el texto indicado en addr2 len2
\ La cadena para usar antes de la pregunta estará en addr len
\ La letra mayúsculas para aceptar la respuesta estará en char
\ CHAR S s" La pregunta" s" texto antes de la pregunta"
: PREGUNTA-CHAR?   ( char addr2 len2 addr len -- flag )
    TYPE CR TYPE
    TIB MAX_AYUDA ACCEPT #TIB !  0 >IN !
    1 TEXT PAD QUEAYUDA MAX_AYUDA MOVE
    \ Convertir en mayúsculas
    QUEAYUDA>MAYUSCULAS
    \ Si es la letra indicada en mayúsculas, pondrá TRUE en la pila, si no pondrá FALSE
    QUEAYUDA C@ = 
;

\ Preguntar si quiere continuar
\ En la pila estará la dirección de una cadena para usar con la pregunta de si continúa o no
: CONTINUAR?   ( addr len -- flag )
    2>R [CHAR] S S" Quieres continuar (s = si, otra = no)? " 2R>
    PREGUNTA-CHAR?
;

\ TRUE si juega el humano, en otro caso FALSE
: HUMANO?   QUIENJUEGA @ _HUMANO =  ;

\ v1.10 El número máximo a adivinar 
: EL-MAXIMO   ( -- ELNIVEL * 100 ) ELNIVEL @ 100 * ;

\ Comprueba si el contenido de la dirección de memoria es uno de los valores de $DIFICULTADES
\ : DIFICULTAD-INDEX  ( addr len -- index|-1 )
:NONAME
    \ guardar cuántos valores hay en la pila
    DEPTH >R
    %DIFICULTADES 1+ 1
    DO 
        2DUP
        I DIFICULTAD>S COMPARE 0=
        IF I -ROT LEAVE THEN
    LOOP
    \ Cuando llegue aquí solo debe haber un valor en la pila
    \ Si hay más es que no se ha encontrado
    DEPTH R> = IF -1 -ROT THEN
    2DROP
; IS DIFICULTAD-INDEX

\ Muestra el nivel de dificultado asignado a NIVELDIFICULTAD
: DIFICULTAD-MOSTRAR   
    ." El nivel de DIFICULTAD actual es " NIVELDIFICULTAD @ . ." - "
    NIVELDIFICULTAD @ DIFICULTAD. ;

\ v1.8 mostrar el nivel y el número a adivinar.
\ v1.10 usar EL-MAXIMO para el número máximo a adivinar
\ cambio el nombre de NIVEL-SHOW a NIVEL-MOSTRAR
: NIVEL-MOSTRAR
    ." El NIVEL actual es " ELNIVEL ? 
    ." y el numero a adivinar es mayor que " MENORINDICADO ? 
    ." y menor que " MAYORINDICADO @ STR ." ."
;
    

\ cambio SHOW-DIFICULTADES por DIFICULTADES-MOSTRAR
: DIFICULTADES-MOSTRAR
    CR
    ." Escribe n DIFICULTAD (o n D!) para cambiar el nivel de dificultad." CR
    ."     Para asignar un valor aleatorio entre _SENCILLO y _SENSEI escribe 0 DIFICULTAD (o 0 D!)." CR
    ." Los niveles de DIFICULTAD son:" CR
    LAS-DIFICULTADES \ CR
    \ mostrar el nivel actual de DIFICULTAD del juego
    DIFICULTAD-MOSTRAR ;

\ cambio SHOW-INSTRUCCIONES por INSTRUCCIONES-MOSTRAR
: INSTRUCCIONES-MOSTRAR
    \ v1.59 pongo un cambio de línea para que se separa el resultado de las instrucciones
    CR
    HUMANO? 
    IF 
        ." Para jugar de nuevo escribe JUGAR (sigues con el mismo nivel). " CR
        \ v1.9 mostrar el nivel y el rango del número a adivinar
        ."     " NIVEL-MOSTRAR CR
        \ v1.5 mostrar el rango de números según el nivel
        ."     Para jugar con otro nivel, escribe n NIVEL." CR
        \ v1.42 el nivel máximo es una variable
        ."     Escribe 0 NIVEL para usar un nivel aleatorio entre 1 y " NIVELMAXIMO @ STR ." ." \ CR
    ELSE 
        ." Si quieres que vuelva a jugar yo, escribe JUGAR-SOLO (seguire con los mismos niveles). " CR
        ."     " NIVEL-MOSTRAR CR
        ."     Escribe OPCIONES-SOLO para ver otras posibilidades de juego automatico." \ CR
    THEN
    \ v1.25 mostrar info del nivel de dificultad
    DIFICULTADES-MOSTRAR
;

\ Para mostrar el mensaje cuando lo adivina 
: MOSTRAR-CORRECTO   ( -- )
    CR ." Correcto! el numero era " NUMEROADIVINAR ? 
    HUMANO? IF ." lo has adivinado en " ELSE ." lo he adivinado en "  THEN
    INTENTOS ? 
    \ v1.3 comprobar si es 1 intento o más
    INTENTOS @ 1 = IF ." intento. " ELSE ." intentos. " THEN 
    \ v1.208 no mostrarlo si se llega desde JUGAR.
    DESDEJUGAR @ FALSE = IF CR INSTRUCCIONES-MOSTRAR THEN
;

\ Mostrar las opciones de juego automático
\ v1.60 cambio el nombre de OPCIONES-AUTO a OPCIONES-SOLO
: OPCIONES-SOLO
    CR 
    ." Opciones de juego automatico y los niveles de dificultad: " CR
    ."    JUGAR-SOLO-FACIL   NIVEL de 1 a 5 y DIFICULTAD de _SENCILLO a _MEDIO." CR
    ."    JUGAR-SOLO-DIFICIL NIVEL de " NIVELMAXIMO @ 4 - . ." a " NIVELMAXIMO ? ." y DIFICULTAD de _DIFICIL a _SENSEI." CR
    ."    JUGAR-SOLO-AUTO    NIVEL de 1 a " NIVELMAXIMO ? ." y DIFICULTAD de _SENCILLO a _SENSEI." CR
    ."    JUGAR-SOLO         Usando el NIVEL y DIFICULTAD que se haya asignado antes." CR
    ."    VER-NIVELES        Para mostrar los niveles: NIVEL Y DIFICULTAD.
;

\ v1.228 para ponerlo como ayuda
: AYUDA-SOLO   ( flag| -- )
    DEPTH 0= IF TRUE THEN
    IF CR ." *** La ayuda de JUGAR SOLO ***" CR THEN
    ."     El ordenador adivinara el numero (sin hacer trampas)." CR CR
    ." Jugare automaticamente y te ire mostrando los numeros elegidos y si lo acierto." CR
    ." Escribe una de estas opciones para que yo empiece a jugar automaticamente."
    OPCIONES-SOLO
    CR
;

\ Mostrar los niveles de juego de NIVEL y DIFICULTAD
: VER-NIVELES
    CR
    NIVEL-MOSTRAR CR
    DIFICULTAD-MOSTRAR
;

\ v1.108 Breve explicación de qué es FORTH
: AYUDA-FORTH
    DEPTH 0= IF CR ." *** La ayuda de FORTH ***" CR CR ELSE DROP THEN
    ." Forth o FORTH es un lenguaje de programacion y un ambiente de programacion " CR
    ."   para ordenadores inventado por Charles H. Moore en 1968 y usado en 1970 " CR
    ."   para controlar el telescopio de 30ft del National Radio Astronomy Observatory de Kitt Peak, Arizona." CR
    ." Inicialmente disenado para una aplicacion muy concreta, la astronomia " CR
    ."   (calculo de trayectorias de cuerpos en orbita, cromatografias, analisis de espectros de emision), " CR
    ."   ha evolucionado hasta ser aplicable a casi todos los demas campos relacionados o no con esa rama " CR
    ."   de la ciencia (calculos de probabilidad, bases de datos, analisis estadisticos y hasta financieros)." CR
    ." Forth es un lenguaje de programacion procedimental, estructurado, imperativo, reflexivo, " CR
    ."   basado en pila y sin comprobacion de tipos." CR
    ." Una de sus importantes caracteristicas es la utilizacion de una pila de datos " CR
    ."   para pasar los argumentos entre las palabras, que son los constituyentes de un programa en Forth." CR
    ." En Forth para el manejo de la pila se usa la notacion postfija (notacion polaca inversa) " CR
    ."   de forma que para sumar dos numeros se escriba de esta forma: 3 2 +" CR
    ."   Se ponen los numeros en la pila y despues se indica la operacion a realizar con esos numeros, " CR
    ."     dejando en la pila el resultado." CR
    ."   Si queremos sumar 3+2 y el resultado multiplicarlo por 7 lo hariamos asi: 7 2 3 + *" CR
    ."     Primero se suman 2+3 y el resultado (que estara en la pila) se multiplica por 7." CR
    CR ." Para mas informacion e implementaciones populares de Forth ver:" CR
    ."    Forth en Wikipedia                       https://es.wikipedia.org/wiki/Forth" CR
    ."    Forth Interest Group (FIG)               http://www.forth.org/" CR
    ."    Forth Standard                           https://forth-standard.org/" CR
    ."    GForth del Proyecto GNU                  https://gforth.org/" CR
    ."    Sitio web oficial de FORTH, Inc.         https://www.forth.com/" CR
    ."    Starting FORTH (tutorial de Leo Brodie)  https://www.forth.com/starting-forth/" CR
    ."        Este es el que he usado yo para empaparme de Forth."
;

: AYUDA-OPCIONES   ( -- )
    ." Para ver las opciones del juego: niveles, etc. escribe AYUDA seguida de:" CR
    ."    JUGAR       - para explicarte las opciones basicas." CR
    ."    INTERACTIVO - para explicarte las opciones de juego interactivo." CR
    ."    NIVEL       - para explicarte los niveles de juego." CR
    ."    DIFICULTAD  - para explicarte los niveles de dificultad." CR
    ."    PISTA       - para explicarte algunos trucos." CR
    ."    ADIVINA     - para explicarte como indicar el numero que crees que hay que adivinar." CR
    ."    FORTH       - para explicarte un poco del lenguaje usado para crear este programa." CR
    ."    SOLO        - para explicarte las opciones de juego automatico (el ordenador adivina el numero)." CR
    ."    Tambien puedes escribir AYUDA-XXX, donde XXX es una de las palabras anteriores." CR
    ."    Escribe AYUDA para ver esta ayuda."
;

: AYUDA-GENERAL   ( -- )
    CR VERSION-ADIVINA CR
    ."     Este programa esta escrito en el lenguaje Forth." CR CR
    ." Escribe REINICIAR para reiniciar el juego y asignar el numero a adivinar." CR
    ." Para adivinar el numero que el ordenador elija, escribe JUGAR." CR
    ." Para que el ordenador adivine el numero, escribe JUGAR-SOLO." CR
    AYUDA-OPCIONES
;

: AYUDA-PISTA   ( flag| -- )
    DEPTH 0= IF TRUE THEN
    IF CR ." *** La ayuda de PISTA ***" CR CR THEN
    ." Escribe PISTA y te mostrare como de cerca estas de adivinar el numero y los intentos que llevas." CR
    ." Para ver la solucion escribe RESUELVE, RES o ME-RINDO." CR
    ." Si quieres que el ordenador te diga que numero elegiria, escribe A-N? " CR
    ."    Sera como si hubieras escrito ese numero seguido de ADIVINA." CR
    ."    A-N? es lo que usa el ordenador cuando juega solo (en modo automatico)." CR
    ." Escribe NUMS? para ver los numeros que has indicado y si son menor o mayor que el que hay que adivinar." CR
    \ para no mostrar el ok
    \ no usarlo porque si esto se llama desde un bloque con IFs, ya no se sigue analizando el resto
    \ QUIT
;

: AYUDA-INTERACTIVO   ( flag| -- )
    DEPTH 0= IF TRUE THEN
    IF CR ." *** La ayuda de JUGAR en modo INTERACTIVO ***" CR THEN
    CR
    ." Para jugar una partida contra el ordenador en modo interactivo escribe JUGAR-INTERACTIVO." CR
    ." A continuacion escribe el numero que crees que debes adivinar seguido de ADIVINA:" CR
    ."    num ADIVINA (o num A-N o num ??) y te dire si lo has acertado, " CR
    ."    o si el numero indicado es menor o mayor que el numero a adivinar." CR
    ."    Si indicas un numero menor o mayor de los ya indicados no se cuenta como intento." CR
    ." Para ver la solucion escribe RESUELVE, RES o ME-RINDO." CR   
    \ FALSE AYUDA-PISTA CR
    CR
    ." Si quieres que yo adivine el numero escribe OPCIONES-SOLO y veras las opciones de juego automatico." CR
    ." Si quieres jugar contra el ordenador en modo normal, escribe JUGAR." CR
;
: AYUDA-NIVEL   ( flag| -- )
    DEPTH 0= IF TRUE THEN
    IF CR ." *** La ayuda de NIVEL ***" CR CR THEN
    ." Escribe n NIVEL ( n del 1 al " NIVELMAXIMO ?  ." ) para generar un numero de 1 al n * 100." CR
    ."     Escribe 0 NIVEL para generar un nivel aleatorio entre 1 y " NIVELMAXIMO @ STR ." ." CR
    ."     Al indicar un nivel, se reiniciara el numero a adivinar y los intentos, etc." CR
    VER-NIVELES ;

: AYUDA-DIFICULTAD   ( flag| -- )
    DEPTH 0= IF TRUE THEN
    IF CR ." *** La ayuda de DIFICULTAD ***" CR THEN
    DIFICULTADES-MOSTRAR ;

: AYUDA-ADIVINA   ( flag| -- )
    DEPTH 0= IF TRUE THEN
    IF CR ." *** La ayuda de ADIVINA ***" CR CR THEN
    ." Escribe num ADIVINA (o num A-N o num ??) y te dire si lo has acertado," CR
    ."     o si el numero indicado es menor o mayor que el numero a adivinar." CR
    ." Escribe A-N? si quieres que el ordenador te diga que numero elegiria." CR
    ."    Sera como si hubieras escrito ese numero seguido de ADIVINA." CR
    CR
    ." Escribe NUMS? para ver los numeros que has indicado " 
    ." y si son menor o mayor que el que hay que adivinar." CR  
;

: AYUDA-JUGANDO   ( flag| -- )
    DEPTH 0= IF TRUE THEN
    IF 
        CR ." *** La ayuda de JUGANDO ***" CR CR
        ." Este es el modo de juego en bucle para que tu adivines el numero." CR
        ."    Cuando termines la partida, te preguntare si quieres seguir jugando." CR CR
        ." Para empezar a jugar, escribe JUGAR y t"
    ELSE
        CR
        ." T"
    THEN
    ." e ire preguntando el numero que crees que he elegido aleatoriamente" CR
    ."     hasta que lo adivines o no quieras continuar." CR
    ." En este modo el numero de comandos esta limitado a:" CR
    COMANDOS-MOSTRAR
;

\ La ayuda para cuando juega con DIME
: AYUDA-JUGAR   ( flag| -- )
    DEPTH 0= IF TRUE THEN
    IF CR ." *** La ayuda de JUGAR ***" CR THEN
    \ CR
    \ ." Para jugar una partida contra el ordenador escribe JUGAR." \ CR
    JUGAR-OPCIONES CR
    ." Si eliges jugar contra el ordenador:"
    FALSE AYUDA-JUGANDO
;

: AYUDA-DIME   ( -- )
    CR ." *** AYUDA (mientras juegas) ***" CR
    ." Intenta adivinar el numero que he elegido." CR
    VER-NIVELES CR
    AYUDA-OPCIONES \ CR
    FALSE AYUDA-JUGANDO
;

\ ********************************************************************
\ * Las palabras usadas en el juego que no dependen de las ayudas.   *
\ ********************************************************************

\ Iniciar el nivel con un valor aleatorio entre 1 y NIVELMAXIMO
\ v1.57 le faltaba el @ en NIVELMAXIMO ya que ahora es una variable
: NIVEL-RANDOM   1 NIVELMAXIMO @ random2 ELNIVEL ! ;

\ v1.27 Mostrar si es mayor, menor o igual
\ n -- indicar si es mayor o menor que el número a adivinar
: MAYOR-MENOR 
    DUP 
    NUMEROADIVINAR @ = 
    IF ." (el numero) " DROP
    ELSE
        NUMEROADIVINAR @ <
        IF ." (era menor) " ELSE ." (era mayor) " THEN 
    THEN
;

\ v1.103 asignar un valor aleatorio a NIVELDIFICULTAD
\ Usar siempre de 1 a %DIFICULTADES por si le cambio los nombres
: DIFICULTAD-RANDOM   ( -- ) 1 %DIFICULTADES random2 NIVELDIFICULTAD ! ;

\ Asigna el nivel de dificultad indicado en la pila 
\   comprueba si el valor es válido y asigna el número máximo de intentos
\   no muestra info del nivel de dificultad.
: DIFICULTAD!   ( n -- )
    \ Si es cero, asignar un valor aleatorio
    DUP
    0= 
    IF
        DROP
        CR ." Se asigna un valor aleatorio al nivel de DIFICULTAD."
        DIFICULTAD-RANDOM
    ELSE
        \ Asignar un valor que esté en rango
        %DIFICULTADES MIN 1 MAX
        NIVELDIFICULTAD !
    THEN
    
    \ y asignar el valor a INTENTOSMAXIMO
    NIVELDIFICULTAD @ DIFICULTAD>N INTENTOSMAXIMO !
;

\ Asigna el nivel de dificultad.
\ Si se indica -1 o no hay nada en la pila, mostrar el nivel.
\ Si se indica 0 asignar un valor aleatorio.
\ Si se indica un valor asignar ese nivel.
: DIFICULTAD   ( n|-1| -- )
    DEPTH 0= IF -1 THEN
    DUP
    0 >= 
    IF
        DIFICULTAD!
    ELSE
        DROP CR ."     El numero indicado para la DIFICULTAD no es valido."
    THEN 
    \ Mostrar siempre los niveles
    VER-NIVELES
;

\ v1.61 defino D! para asignar el nivel de dificultad
: D!   ( n|-1| -- ) DIFICULTAD ;

\ Definición de NUMS! usando ARRAY
\ Asignar a ARRAY.NUMS el valor en el índice indicado
: NUMS!   ( n INDEX# -- ) ARRAY.NUMS ! ;

\ Borrar el contenido del array ARRAY.NUMS
\ Se borran todos los valores aunque se usen menos del tamaño del array
: NUMS-CLEAR   ( -- ) MAX_NUMS 0 DO 0 I ARRAY.NUMS ! LOOP ;

\ Mostrar el contenido del array ARRAY.NUMS
: MOSTRAR-NUMS ( -- )
    \ Guardar lo que había en la pila
    DEPTH >R
    
    \ No mostrar los intentos, si INTENTOS es cero
    INTENTOS @ 0= 
    IF ." Aun no hay intentos." R> DROP EXIT THEN
    CR
    ."  Intento -   Numero  (mayor-menor) "
    \ mostrar el total de intentos
    INTENTOSMAXIMO @ 0
    DO 
        I ARRAY.NUMS @ DUP DUP
        \ si es cero, salir del bucle
        0= 
        IF DROP LEAVE THEN
        CR
        \ mostrar si es menor o mayor que el número que había que adivinar
        1 I + 5 U.R ."     - " 7 U.R ."    " MAYOR-MENOR
    LOOP
    \ Comprobar si ha cambiado la pila
    DEPTH R> - 0> 
    \ Hay más datos en la pila
    IF DROP THEN
;

: NUMS?   MOSTRAR-NUMS ;

\ Incrementar el número de intentos sin más comprobaciones
\ v1.81 cambio INC.I.N por INC-INTENTOS
: INC-INTENTOS   INTENTOS @ 1 + INTENTOS ! ;

\ v1.19 El rango del número a adivinar
\ v1.29 Ahora los valores de MENORINDICADO y MAYORINDICADO son el menor y el mayor indicado.
\   Si está entre 48 y 50 solo hay una posibilidad, el 49
\   Si está entre 47 y 50 hay 2 posibilidades: 48 y 49
\   Cambio N.POSIBLES por N-POSIBLES
: N-POSIBLES   MAYORINDICADO @ 1 - MENORINDICADO @ - ;

\ Asignar a MENORINDICADO o MAYORINDICADO el que corresponda
: CERCANOS 
    \ ULTIMONUMERO tiene el último número asignado
    \ Comprobar si ULTIMONUMERO es menor que el número
    \ Hacer copia del número para asignarlo después al menor o mayor
    ULTIMONUMERO @ DUP 
    \ si el último es menor que el número a adivinar
    NUMEROADIVINAR @ < 
    \ asignar ULTIMONUMERO al menor
    IF MENORINDICADO !   
    \ asignar ULTIMONUMERO al mayor
    ELSE MAYORINDICADO ! 
    THEN
;

\ Comprobar si quedan intentos, si no, mostrar la solución
: QUEDAN-INTENTOS   ( -- )
    \ v1.46 Aclaración:
    \   QUEDAN-INTENTOS se llama desde ADIVINA si el número es menor o mayor
    \       también se llama desde PISTA
    \   Por tanto, debe ser INTENTOS @ INTENTOSMAXIMO @ >= 
    INTENTOS @ INTENTOSMAXIMO @ >= 
    IF 
        CR
        ."     No quedan intentos, la solucion es " NUMEROADIVINAR ? 
        \ v1.46 asignar a NUMEROINDICADO el número para que sea como adivinado
        NUMEROADIVINAR @ NUMEROINDICADO !
        TRUE SOLUCIONMOSTRADA !
    ELSE
        \ v1.13 mostrar los intentos que lleva y los que quedan
        \ con el plural correcto según sea 1 o más
        \ v1.52 poner el texto según sea humano o máquina
        HUMANO? IF ." Llevas " ELSE ." Llevo " THEN INTENTOS ?
        INTENTOS @ 1 = IF ." intento, " ELSE ." intentos, " THEN 
        HUMANO? IF ." te " ELSE ." me " THEN
        \ v1.26 para saber los intentos que quedan, usar INTENTOSMAXIMO @
        INTENTOSMAXIMO @  INTENTOS @ - 1 = 
        IF ." queda 1. " 
        \ v1.18 convertir en cadena y añadir un punto al final
        ELSE ." quedan " INTENTOSMAXIMO @ INTENTOS @ - STR ." ." 
        THEN 
    THEN
;

\ Las comprobaciones en ADIVINA:
\   Si el número indicado no está entre los "posibles" avisar y no asignarlo.
\   Si el número indicado es mayor del máximo avisar y no asignarlo.

\ v1.23 comprobar si el número indicado es aceptable.
\   Devuelve FALSE si no se acepta el número
\ v1.100 cambio GUESS? por NUMEROCORRECTO?
: NUMEROCORRECTO?
    \ v1.23 Si el número es menor que 1, avisar y no tenerlo en cuenta.
    NUMEROINDICADO @ 0 <=
    IF ." El numero debe ser mayor que cero. " FALSE
    ELSE
        \ v1.10 comprobar si el número es mayor del máximo
        \   Si es así, avisar y no tenerlo en cuenta
        NUMEROINDICADO @ EL-MAXIMO >
        \ v1.19 usar STR para mostrar el numero
        IF ." El numero indicado es mayor que el maximo (" EL-MAXIMO STR ." )" FALSE
        ELSE
            \ v1.23 Si el número es mayor que el menor o menor que el mayor
            \ no aceptarlo y mostrar un aviso
            \ si el número es menor que el menor indicado
            NUMEROINDICADO @ MENORINDICADO @ < 
            IF ." El numero indicado es menor que el menor indicado hasta ahora (" MENORINDICADO @ STR ." )" 
                FALSE
            ELSE
                \ si el número es mayor que el mayor indicado
                NUMEROINDICADO @ MAYORINDICADO @ > 
                IF ." El numero indicado es mayor que el mayor indicado hasta ahora (" MAYORINDICADO @ STR ." )" 
                    FALSE
                ELSE
                    TRUE
                THEN
            THEN
        THEN
    THEN
;

\ Comprobar si adivina el número.
\ v1.54 cambio GUESS por ADIVINA
: ADIVINA
    \ v1.23 asignar el número indicado a NUMEROINDICADO 
    NUMEROINDICADO !
    \ v1.23 devuelve FALSE si no se acepta el número
    NUMEROCORRECTO?
    IF 
        \ v1.46 comprobar si es >= en vez de mayor
        INTENTOS @ INTENTOSMAXIMO @ >=
        IF 
            \ indicarlo y mostrar la solución
            ." Ya no quedan intentos, el numero era " NUMEROADIVINAR @ STR ." ." CR
            \ v1.33 asignar a NUMEROINDICADO el número para que sea como adivinado
            NUMEROADIVINAR @ NUMEROINDICADO !
            TRUE SOLUCIONMOSTRADA !
            \ v1.208 no mostrarlo si se llega desde JUGAR.
            DESDEJUGAR @ FALSE = IF CR INSTRUCCIONES-MOSTRAR THEN
        ELSE
            \ incrementar el número de intentos
            INC-INTENTOS 
            \ v1.26 guardar el número en el array después de incrementar
            \ pero restando uno ya que el índice es en base cero
            NUMEROINDICADO @ INTENTOS @ 1 - NUMS!
            \ si lo ha adivinado
            NUMEROINDICADO @ NUMEROADIVINAR @ = 
            IF MOSTRAR-CORRECTO
            ELSE 
                \ si es menor
                NUMEROINDICADO @  NUMEROADIVINAR @ < 
                IF ." Es menor. "
                ELSE ." Es mayor. "
                THEN 
                \ mostrar los intentos que quedan o la solución
                QUEDAN-INTENTOS 
            THEN 
            \ asignar el número indicado al último
            NUMEROINDICADO @ ULTIMONUMERO ! 
            \ Asignar el último número al menor o mayor más cercano
            CERCANOS
        THEN
    THEN
;

\ v1.54 A-N como ADIVINA
: A-N   ADIVINA ;
\ v1.55 defino N-A por si lo escribo al revés
\ v1.94 quito la definición de N-A
\ : N-A   ADIVINA ;
\ v1.91 defino ?? como alias de ADIVINA
: ??   ADIVINA ;

\ v1.57 cambio el sitio de estas palabras porque A-N? usa ADIVINA

\ v1.24 Poner en la pila el siguiente número a comprobar.
\   Media = (Mayor - Menor) / 2
\   Siguiente = Menor + Media
\   El valor devuelto es el número sin decimales: 14.5 -> 14
\ En gForth está definido NEXT, pero no en SwiftForth
\ v1.56 cambio el nombre de N.NEXT a N-NEXT
: N-NEXT   ( -- n )
    \ v1.29 comprobar si es cero
    MAYORINDICADO @ MENORINDICADO @ - 0= 
    IF MAYORINDICADO @ 1 - \ ." SE ASIGNA " MAYORINDICADO @ 1 - STR
    ELSE MAYORINDICADO @ MENORINDICADO @ - 2 / MENORINDICADO @ +
    THEN
;

\ v1.24 Elegir el siguiente número recomendado para adivinar usando N-NEXT
: A-N?   ( -- ) N-NEXT DUP . ADIVINA ;

\ Devuelve TRUE si el número es el correcto o se han pasado los intentos
\   Se usa cuando juega automáticamente/solo
\ v1.47 cambio el nombre de ADIVINADO a SEGUIR-BUCLE
: SEGUIR-BUCLE ( -- flag )
    \ Considerarlo adivinado si lo ha adivinado o se ha pasado del número de intentos
    \ v1.50 tener también en cuenta si se ha mostrado la solución
    NUMEROINDICADO @ NUMEROADIVINAR @ = 
    INTENTOS @ INTENTOSMAXIMO @ > OR
    SOLUCIONMOSTRADA @ OR
;

\ Resolver el juego = mostrar la solución y los intentos pendientes
: RESUELVE   ( -- )
    ." Te quedaban " INTENTOSMAXIMO @ INTENTOS @ - . ." intentos. "
    ." El numero a adivinar era " NUMEROADIVINAR @ STR ." ."
    \ Asignar los valores para indicar que ya está resuelto, 06-ene-2023 05.54
    NUMEROADIVINAR @ NUMEROINDICADO !
    TRUE SOLUCIONMOSTRADA !
    \ v1.208 no mostrarlo si se llega desde JUGAR.
    DESDEJUGAR @ FALSE = IF CR INSTRUCCIONES-MOSTRAR THEN
;

: ME-RINDO   ( -- ) RESUELVE ;
\ v1.22 RES es como RESUELVE antes era R
: RES   ( -- ) RESUELVE ;

\ v1.20 defino todo esto después de HELP1 y HELP2 porque en PISTA se usa HELP1

\ v1.19 mostrar textos según las posibilidades que tenga de adivinarlo.
\ v1.106 cambio HUMOR-HINT por HUMOR-PISTA
: HUMOR-PISTA   ( -- )
    \ Solo mostrar mensajes si es menor de 6
    N-POSIBLES 6 <
    IF ."      " 
        \ solo tiene un número que poner, ej. está entre 15 y 17
        N-POSIBLES 1 = 
        IF ." Si no lo adivinas ahora no se que hacer contigo."
        ELSE
            \ ej. está entre 15 y 18 solo tiene 2 números que probar
            N-POSIBLES 2 = 
            IF ." Tienes el 50% de posibilidades de adivinarlo: "
                \ Mostrar los números que puede poner
                ." O es el " MENORINDICADO @ 1+ .
                ." o es el " MAYORINDICADO @ 1- STR ." ."
            ELSE
                \ ej. está entre 15 y 19 tiene 3 posibilidades
                N-POSIBLES 3 =
                IF ." Tienes el 33% de posibilidades de adivinarlo."
                ELSE ." Que poquito te falta."
                THEN
            THEN
        THEN
        CR
    THEN
;

\ Mostrar los dos ultimos numeros indicados ( si se han indicado ) 
\ v1.3 Al mostrar los números, indicar si era mayor o menor
\ v1.4 Usar MAYOR-MENOR para mostrar si era mayor o menor
\ v1.17 simplificar el texto
\ v1.54 cambio HINT por PISTA
: PISTA   ( -- )
    \ v 1.20 si el número es ULTIMONUMERO es que ya lo ha adivinado
    ULTIMONUMERO @ NUMEROADIVINAR @ = 
    IF 
        CR CR 
        ."    O no has empezado a jugar o ya has adivinado el numero." CR
        ."    Escribe JUGAR para empezar un nuevo juego." 
        CR
    ELSE
        \ v1.17 mostrar los números más cercanos indicados
        \ si es la primera vez, mostrará 1 y el máximo a adivinar + 1
        ." El numero a adivinar es mayor que " MENORINDICADO ? 
        \ v1.18 añadir un punto después del número
        ." y menor que " MAYORINDICADO @ STR ." ." CR
        \ v1.19 un poco de humor
        HUMOR-PISTA
        ."      " QUEDAN-INTENTOS
    THEN
;

\ v1.22 Comprobar si el nivel está ajustado y si no, asignar el valor adecuado
: NIVEL?   ( -- )
    \ comprobar si el NIVEL es correcto 
    \ si el nivel es menor de 1, asignar un nivel aleatorio entre 1 y NIVELMAXIMO 
    ELNIVEL @ 1 < IF NIVEL-RANDOM THEN
    \ si el nivel es mayor de NIVELMAXIMO, asignar NIVELMAXIMO
    ELNIVEL @ NIVELMAXIMO @ > IF NIVELMAXIMO @ ELNIVEL ! THEN
;

\ Si se indica -1 o no hay nada en la pila, mostrar el nivel.
\ Si se indica 0 asignar un valor aleatorio.
\ Si se indica un valor asignar ese nivel.
\ Si se asigna un nivel llamar a reiniciar.
: NIVEL   ( n|-1| -- ) 
    DEPTH 0= IF -1 ELSE DUP THEN
    \ Asignar el nivel si es 0 o mayor
    0 >= 
    IF
        ELNIVEL ! TRUE REINICIAR
    ELSE
        CR ."     El numero indicado para la NIVEL no es valido."
        VER-NIVELES
    THEN
;

: N!   ( n|-1| -- ) NIVEL ;

\ v1.22 crear un numero aleatorio según el nivel 
\ Se comprueba si el nivel es correcto y si no, se asigna del 1 al NIVELMAXIMO
\ Se muestra el nivel a usar, etc.
: NUEVO-NUM   ( -- )
    NIVEL?
    \ asignar el número aleatorio
    1 100 ELNIVEL @ * random2 NUMEROADIVINAR ! 
;

\ v1.252 por si se cambia de juego
FALSE VALUE CAMBIARJUEGO?

\ Reiniciar el juego, asignando los valores predeterminados, etc.
\ Si no se indica un parámetro es como TRUE
\ Si se indica FALSE no mostrar los mensajes
\ Si se indica TRUE mostrar los mensajes
\ : REINICIAR   ( flag| -- limpia la pila )
:NONAME
    \ v1.264 no asignarla
    \ Se asigna al cargar el fichero
    \ v1.263 asignar una cadena vacía a quejugar
    \ s" " QUEJUGAR!
    \ v1.252 asignar false a CAMBIARJUEGO?
    FALSE TO CAMBIARJUEGO?
    \ v1.208 asignar false al reiniciar
    FALSE DESDEJUGAR !
    \ v1.54 no asignar nada a QUIENJUEGA por si se llama desde NIVEL
    \ Poner solución mostrada en false
    FALSE SOLUCIONMOSTRADA !
    \ asignar los valores predeterminados de las variables
    0 ULTIMONUMERO ! 0 INTENTOS !
    \ EL-MAXIMO se debe usar después de asignar el nivel
    NIVEL?
    \ v1.29 asignar a MAYORINDICADO 1 más del máximo, y 0 a MENORINDICADO
    0 MENORINDICADO ! EL-MAXIMO 1 + MAYORINDICADO !
    \ asignar ceros al array de números indicados
    \ v1.25 usando NUMS-CLEAR
    NUMS-CLEAR
    NUEVO-NUM
    \ v1.102 Si no hay valor en la pila, mostrar los niveles de juego.
    DEPTH 0= IF TRUE THEN
    \ Si el parámetro es TRUE mostrar los mensajes
    IF
        CR ." Se han reiniciado los valores y el numero a adivinar." CR
        VER-NIVELES
    THEN
    LIMPIAR-PILA
; IS REINICIAR

\ v1.124 defino INICIAR como alias de REINICIAR
: INICIAR   ( flag| -- ) REINICIAR ;

\ ********************************************
\ * v1.246 Todo lo relacionado con JUGAR xxx *
\ ********************************************

\ v1.32 primer intento de jugar automáticamente.
( Los pasos son:
     - Usar el NIVEL asignado
     - Usar el nivel de DIFICULTAD asignado
     - REINICIAR
     - Indicar que se juega automáticamente.
    [- Empieza un bucle.
     - Usar A-N? para elegir un número.
     - Si lo ha adivinado indicarlo y salir del bucle.
     - Hacer una pausa de casi 1 segundo.
    -] Seguir el bucle si el número no se ha acertado.
)
\ Juega con el NIVEL y DIFICULTAD que estén asignados
: JUGAR-SOLO   ( -- )
    NIVELDIFICULTAD @ DIFICULTAD!
    \ v1.102 poner un valor en la pila para que no se muestren los niveles
    FALSE REINICIAR
    \ Asignar que juega la máquina
    _MAQUINA QUIENJUEGA !
    \ Mostrar que se juega automáticamente
    s" en jugar-solo, quejugar= " 'QUEJUGAR DEBUG2
    QUEJUGAR-LEN 0= 
    CR
    IF
        ." *** JUGAR SOLO usando los niveles anteriores (el ordenador adivinara el numero) ***"
    ELSE
        ." *** JUGAR SOLO usando los niveles del juego '" QUEJUGAR.
        ." ' (el ordenador adivinara el numero) ***"
    THEN
    CR CR
    \ CR
    \ ." *** JUGAR SOLO (el ordenador adivinara el numero) ***" CR CR
    ." Juego automaticamente, ire mostrando los numeros elegidos y si lo acierto. " CR
    ." Estoy jugando con el NIVEL: " ELNIVEL ? 
    ." tengo que adivinar un numero del 1 al " EL-MAXIMO STR ." ." CR
    ." El nivel de DIFICULTAD es " NIVELDIFICULTAD @ DIFICULTAD. CR
    1800 MS
    \ Empieza un bucle
    BEGIN
        CR
        A-N?
        800 MS
        \ SEGUIR-BUCLE devuelve TRUE si lo ha adivinado o han pasado los intentos
        SEGUIR-BUCLE
        \ If flag is false, go back to BEGIN. If flag is true, terminate the loop
    UNTIL
    \ Comprobar si se ha pasado de intentos o se ha mostrado la solución
    INTENTOS @ INTENTOSMAXIMO @ > SOLUCIONMOSTRADA @ OR
    IF CR CR ." Me he pasado del numero de intentos :-( " CR
        ."     Tengo que mejorar con el NIVEL: " ELNIVEL ? 
        ." y el nivel de DIFICULTAD " NIVELDIFICULTAD @ DIFICULTAD. CR
        1000 MS
        INSTRUCCIONES-MOSTRAR
    THEN
;

\ Elige al azar el NIVEL y DIFICULTAD
: JUGAR-SOLO-AUTO   ( -- )
    \ v1.264 asignar el tipo de juego
    s" SOLO AUTO" QUEJUGAR!
    1 NIVELMAXIMO @ random2 ELNIVEL !
    _SENCILLO _SENSEI random2 NIVELDIFICULTAD !
    JUGAR-SOLO
;

\ Juega con un NIVEL entre 1 y 5 y con el nivel de DIFICULTAD entre _SENCILLO y _MEDIO
: JUGAR-SOLO-FACIL   ( -- )
    \ v1.264 asignar el tipo de juego
    s" SOLO FACIL" QUEJUGAR!
    1 5 random2 ELNIVEL !
    _SENCILLO _MEDIO random2 NIVELDIFICULTAD !
    JUGAR-SOLO
;

\ Para probar con nivel NIVELMAXIMO - 4 a NIVELMAXIMO y DIFICULTAD _DIFICIL a _SENSEI
: JUGAR-SOLO-DIFICIL   ( -- )
    \ v1.264 asignar el tipo de juego
    s" SOLO DIFICIL" QUEJUGAR!
    NIVELMAXIMO @ 4 - NIVELMAXIMO @ random2 ELNIVEL !
    _DIFICIL _SENSEI random2 NIVELDIFICULTAD !
    JUGAR-SOLO
;

\ Esto juega escribiendo las palabras, sin bucle
\ Lo llamaré JUGAR-INTERACTIVO
\ Iniciar el juego, poner todos los valores a cero
\ No mostrar la ayuda ni nada
: JUGAR-INTERACTIVO   ( -- )
    \ v1.102 poner un valor en la pila para que no se muestren los niveles
    FALSE REINICIAR
    \ Asignar que juega el humano
    _HUMANO QUIENJUEGA !
    CR
    ." *** JUGAR en modo interactivo (indicando los comandos para jugar) ***" CR CR
    ." Adivina el numero que he elegido." CR 
    ."     Es un numero entre 1 y " EL-MAXIMO . ." ambos inclusive." CR
    ."     Tienes " NIVELDIFICULTAD @ DIFICULTAD>N . ." intentos para adivinarlo." CR
    ." Si quieres cambiar el nivel o el numero de intentos escribe " CR
    ."     n NIVEL o n DIFICULTAD." CR
    ." Escribe tu numero seguido de ADIVINA (o A-N o ??)."
    \ No mostrar ok
    QUIT
;

\ Mostrar las opciones para JUGAR
: JUGAR-MOSTRAR-OPCIONES   ( -- )
    CR
    %JUGAR 1 + 0
    DO
        ."     " I JUGAR>S TYPE 
        13 I JUGAR-LEN - SPACES
        ." - " I JUGARINFO>S TYPE CR
    LOOP
;

\ Mostrar las opciones que se pueden usar con JUGAR
\ : JUGAR-OPCIONES   ( -- )
:NONAME
    CR ." Las opciones para indicar con JUGAR son:" CR
    ." Escribe JUGAR seguido de una de estas opciones:"
    JUGAR-MOSTRAR-OPCIONES
    ." Si escribes solo JUGAR empezaras el juego contra el ordenador con los niveles actuales." CR
; IS JUGAR-OPCIONES

\ Busca en la colección $JUGAR si está la palabra dejada en la pila
: JUGAR-INDEX   ( addr len -- index|-1 )
    \ s"     en jugar-index, escrito: " 'QUEJUGAR DEBUG2
    
    \ Poner -1 y dejarlo antes de addr len: -1 addr len
    -1 -ROT
    %JUGAR 1+ 0
    DO
        2DUP
        I JUGAR>S COMPARE 0=
        IF 2DROP DROP I 0 0 LEAVE THEN
    LOOP
    2DROP
    \ s"     al salir de jugar-index " DEBUG1
;

: JUGAR-FACIL   ( -- )
    1 5 random2 ELNIVEL !
    _SENCILLO _MEDIO random2 NIVELDIFICULTAD !
    JUGAR-BUCLE
;

: JUGAR-DIFICIL   ( -- )
    NIVELMAXIMO @ 4 - NIVELMAXIMO @ random2 ELNIVEL !
    _DIFICIL _SENSEI random2 NIVELDIFICULTAD !
    JUGAR-BUCLE
;

: JUGAR-AUTO   ( -- )
    1 NIVELMAXIMO @ random2 ELNIVEL !
    _SENCILLO _SENSEI random2 NIVELDIFICULTAD !
    JUGAR-BUCLE
;

\ v1.246 jugar en bucle, lo que tenía antes JUGAR
\ Se llama desde:
\   jugar-quejugar si quejugar no tiene contenido
\   jugar-facil, jugar-dificil y jugar-auto
\
\ : JUGAR-BUCLE   ( -- )
:NONAME
    NIVELDIFICULTAD @ DIFICULTAD!
    \ v1.102 poner un valor en la pila para que no se muestren los niveles
    FALSE REINICIAR
    \ v1.208 para indicar que se ha llamado desde JUGAR.
    TRUE DESDEJUGAR !
    _HUMANO QUIENJUEGA !
    \ CR
    \ mostrar qué forma de jugar, se usa: el contenido de QUEJUGAR
    \ s" cuando empieza jugar-bucle, quejugar= " 'QUEJUGAR DEBUG2
    \ Si no tiene nada es porque se ha elegido jugar sin nada más
    QUEJUGAR-LEN 0= 
    CR
    IF
        ." *** JUGAR en modo normal usando los niveles anteriores (con comandos limitados) ***"
    ELSE
        ." *** JUGAR en modo normal usando los niveles del juego '" QUEJUGAR.
        ." ' (con comandos limitados) ***"
    THEN
    CR CR
    \ CR ." *** JUGAR en modo normal (con comandos limitados) ***" CR CR
    ." Los comandos que puedes utilizar son:" CR
    COMANDOS-MOSTRAR
    ." Escribe AYUDA para ver las ayudas disponibles." CR CR
    ." Adivina el numero que he elegido." CR 
    ."     Te ire preguntando el numero hasta que lo aciertes o no desees continuar." CR
    ."     Es un numero entre 1 y " EL-MAXIMO . ." ambos inclusive." CR
    ."     " DIFICULTAD-MOSTRAR CR
    ."     Si quieres cambiar los intentos o la dificultad, ahora es el momento." CR
    
    BEGIN
        DIME
        \ Si se ha indica cambiar de juego, salir
        \ CAMBIARJUEGO? IF LEAVE THEN
        CAMBIARJUEGO?
        IF
            JUGAR-CAMBIAR
            \ Este DUP hace falta para que después de salir del bucle se use en el CASE.
            DUP
            \ s" en jugar-bucle despues de jugar-cambiar " DEBUG1
            \ Asignar false si es -1, true en otro caso
            -1 = IF FALSE ELSE TRUE THEN TO CAMBIARJUEGO?
            \ Después de LEAVE da error de invalid memory address
            \ CAMBIARJUEGO? IF LEAVE THEN
        THEN
        \ s" en jugar-bucle despues del then de cambiarjuego? " DEBUG1
        CAMBIARJUEGO?
        IF
            \ dejar true en la pila para salir y no usar LEAVE
            TRUE
        ELSE
            \ s" en jugar-bucle antes de seguir-bucle " DEBUG1
            DEPTH 0> IF DROP THEN
            SEGUIR-BUCLE
        THEN
        \ If flag is false, go back to BEGIN. If flag is true, terminate the loop
    UNTIL
    \ Aquí llega después de finalizar el juego
    \ s" en jugar-bucle despues de until " DEBUG1
    \ Comprobar si es que se ha indicado cambiar de juego
    CAMBIARJUEGO?
    IF
        \ quejugar no tiene nada asignado
        \ s" en jugar-bucle cambiarjuego? es true 'quejugar= " 'QUEJUGAR DEBUG2
        \ asignar lo que se haya indicado en el índice
        DUP JUGAR>S QUEJUGAR!
        \ s" en jugar-bucle cambiarjuego? es true 'quejugar= " 'QUEJUGAR DEBUG2
        \ asignar false para que no se cumpla este if
        \   salvo que se seleccione cambiar de tipo de juego
        FALSE TO CAMBIARJUEGO?
        CR CR ."         === Se cambia el tipo de juego ===" CR \ CR
        \ Llamar a jugar-quejugar con el tipo de juego elegido
        'QUEJUGAR JUGAR-QUEJUGAR
        \ Aquí llega después de jugar al nuevo juego y finalizar.
        \ s" Antes de salir despues de cambiar de juego " DEBUG1
    ELSE
        CR
        \ Preguntar si quiere echar otra partida
        \ Si se ha mostrado la solución
        SOLUCIONMOSTRADA @
        IF CR ." No has adivinado el numero." S" A ver si ahora tienes mas suerte." 2>R
        ELSE CR ." Lo has hecho bien." S" Prueba con otro nivel y/o otra dificultad." 2>R
        THEN
        CR
        \ v1.244 le pongo un espacio después, estaba así: "... = no) ?"
        [CHAR] S S" Quieres echar otra partida (s = si, otra = no)? " 2R>
        PREGUNTA-CHAR?
        IF CR 'QUEJUGAR JUGAR-QUEJUGAR EXIT THEN
        CR CR
        ." Si quieres que yo eche una partida escribe JUGAR-SOLO." CR
        ."     Escribe OPCIONES-SOLO y veras las opciones de juego automatico." CR
        ." Para jugar una partida contra el ordenador en modo interactivo escribe JUGAR-INTERACTIVO." CR
        INSTRUCCIONES-MOSTRAR
    THEN
    
; IS JUGAR-BUCLE

\ Jugar el juego indicado en QUEJUGAR
\   si QUEJUGAR no tiene nada se llama directamente a JUGAR-BUCLE
\   si no, se comprueba el contenido de QUEJUGAR y se llama a la palabra que corresponda
\
\ Se llama desde:
\   jugar-bucle cuando ha terminado la partida y quiere seguir jugando
\   jugar con lo que se haya escrito después
\
\ : JUGAR-QUEJUGAR   ( addr len -- index|-1 )
:NONAME
    \ si no se ha escrito nada, jugar en bucle con los niveles actuales
    QUEJUGAR-LEN 0= IF JUGAR-BUCLE EXIT THEN
    
    QUEJUGAR>MAYUSCULAS
    
    \ buscar si lo indicado está contemplado.
    JUGAR-INDEX
    DUP
    -1 =
    IF
        DROP CR ." La opcion 'JUGAR " QUEJUGAR. ." ' no existe." CR
        JUGAR-OPCIONES EXIT
    THEN
    CASE
        0 OF JUGAR-FACIL ENDOF
        1 OF JUGAR-DIFICIL ENDOF
        2 OF JUGAR-AUTO ENDOF
        3 OF JUGAR-INTERACTIVO ENDOF
        4 OF JUGAR-SOLO ENDOF
        5 OF JUGAR-SOLO-AUTO ENDOF
        6 OF JUGAR-SOLO-FACIL ENDOF
        7 OF JUGAR-SOLO-DIFICIL ENDOF
        8 OF JUGAR-OPCIONES ENDOF
    ENDCASE
; IS JUGAR-QUEJUGAR

\ Jugar según la opción indicada
\ Si se indica jugar xxx, comprobar si es:
\   interactivo, solo, SOLO AUTO, SOLO FACIL, SOLO DIFICIL
\ v1.246 el código anterior ahora está en JUGAR-BUCLE
\ : JUGAR   ( -- )
:NONAME
    \ Acepta más de una palabra, hasta que se pulsa INTRO
    1 TEXT PAD QUEJUGAR MAX_AYUDA MOVE
    
    'QUEJUGAR JUGAR-QUEJUGAR
; IS JUGAR


\ Comprobar si es una ayuda y si es así mostrarla
\   Se puede llamar con 'QUEAYUDA AYUDA-RUN o 'QUELETRA AYUDA-RUN
\ Solo se llama desde AYUDA?AYUDA
: AYUDA-RUN   ( addr len -- index|-1 )
    \ para mostrar lo que se busca
    \ 2DUP 2>R
    \ si se comenta esto, comentar lo anterior
    \ s"   al entrar en ayuda-run " 2R> DEBUG2
    
    \ s"   al entrar en ayuda-run " DEBUG1
    AYUDA-INDEX
    DUP
    DUP \ hacer otra copia
    \ s"   en ayuda-run despues del ayuda-index y DUP DUP " DEBUG1
    \ Si devuelve -1 es que no existe esa ayuda, buscar sin guión
    -1 = 
    IF
        DROP \ quitar el -1 de la pila
        DROP \ quitar la copia hecha después del ayuda-index anterior
        
        \ s"   en ayuda-run no existe la ayuda " DEBUG1
        
        \ Cambiar el guión por un espacio y buscar la ayuda
        QUENUMEROS-LETRAS-LIMPIAR
        QUEAYUDA-SPLIT-GUION
        'QUELETRAS AYUDA-INDEX
        DUP
    THEN
    \ Existe la ayuda, el índice está en la pila
    -1 > 
    IF
        \ Comprobar qué ayuda mostrar según el índice en la pila
        CASE 
            0 OF AYUDA-GENERAL 0 ENDOF
            1 OF TRUE AYUDA-JUGAR 1 ENDOF
            2 OF TRUE TRUE AYUDA-NIVEL 2 ENDOF
            3 OF TRUE AYUDA-DIFICULTAD 3 ENDOF
            4 OF TRUE AYUDA-PISTA 4 ENDOF
            5 OF TRUE AYUDA-ADIVINA 5 ENDOF
            6 OF TRUE AYUDA-FORTH 6 ENDOF
            7 OF TRUE AYUDA-INTERACTIVO 7 ENDOF
            8 OF TRUE AYUDA-INTERACTIVO 8 ENDOF
            9 OF TRUE AYUDA-INTERACTIVO 9 ENDOF
            \ Ayuda jugando no recibe el parámetro de mostrar título
            10 OF AYUDA-JUGANDO 10 ENDOF
            11 OF AYUDA-SOLO 11 ENDOF
            12 OF AYUDA-SOLO 12 ENDOF
            13 OF TRUE AYUDA-DIFICULTAD 13 ENDOF
            14 OF TRUE TRUE AYUDA-NIVEL 14 ENDOF
            15 OF AYUDA-GENERAL 15 ENDOF
            
            \ Aquí estaría el caso para cuando no se cumplen los anteriores
            \   pero es una ayuda.
            DUP \ para mostrar qué ayuda es 
            DUP \ porque después de ENDCASE quita el valor 
            CR ." *** La ayuda '" AYUDA>S TYPE ." ' existe, pero no esta contemplada ***" CR
            \ s" en ayuda-run existe la ayuda, en el CASE " DEBUG1
        ENDCASE
        \ s" en ayuda-run existe la ayuda, despues de ENDCASE " DEBUG1
    ELSE
        DROP \ v1.233
        -1
        \ s" en ayuda-run no existe la ayuda, en el else " DEBUG1
    THEN
    \ s"   al salir de ayuda-run " DEBUG1
;

: DIFICULTAD-CASE   ( n -- n )
    \ En la pila estará el índice el comando de DIFICULTAD
    QUENUMEROS>N
    DUP
    \ Este caso se dará si no se escribe un número
    \   solo el comando dificultad o d!
    NO_NUM =
    IF 
        \ Quitar el valor de la constante NO_NUM,
        \   guardar en el return stack el valor de la pila,
        \       que será el índice del comando
        \   llamar a dificultad y reponer el valor 
        \ s" en dificultad-case antes de DROP >R DIFICULTAD R> " DEBUG1
        DROP >R DIFICULTAD R>
        \ s" en dificultad-case despues de DROP >R DIFICULTAD R> " DEBUG1
    ELSE
        CR DIFICULTAD-MOSTRAR CR
        \ Comprobar si es el mismo nivel, en ese caso, no hacer nada más
        QUENUMEROS>N NIVELDIFICULTAD @ =
        IF 
            ." Has indicado el mismo nivel de DIFICULTAD, no se hacen cambios." CR
            DROP
            \ Mostrar los niveles
            CR VER-NIVELES
            \ s" en dificultad-case despues de indicar el mismo nivel " DEBUG1
        ELSE
            \ Comprobar si se ha indicado 0, sacará un número aleatorio
            QUENUMEROS>N 0=
            IF 
                ." Esto asigna un nivel de DIFICULTAD aleatorio entre 1 (" 
                1 DIFICULTAD>S TYPE ." ) y " %DIFICULTADES . ." (" %DIFICULTADES DIFICULTAD>S TYPE s" )."
            ELSE
                ." Si asignas el nivel " QUENUMEROS>N . ." (" DUP DIFICULTAD>S TYPE ." ) "
                \ Comprobar si es un numero menor al actual
                \ Si el número es mayor, tendrá menos oportunidades
                QUENUMEROS>N NIVELDIFICULTAD @ >
                IF s" tendras menos intentos."
                ELSE s" tendras mas intentos y es casi como hacer trampas."
                THEN
            THEN
            CONTINUAR?
            IF DIFICULTAD ELSE DROP CR VER-NIVELES THEN
        THEN
        \ Mostrar siempre los intentos que quedan
        CR QUEDAN-INTENTOS CR
    THEN
;

: NIVEL-CASE   ( n -- n )
    \ En la pila estará el valor del comando de NIVEL
    QUENUMEROS>N
    DUP
    \ Si es NO_NUM es que no se ha indicado número
    NO_NUM =
    \ Si solo se muestra el nivel actual no hay problemas
    \ IF s" en nivel-case, en el IF de NO_NUM " DEBUG1 2DROP NIVEL 0
    \ v1.251 dejar en la pila el valor con el que se entró
    IF
        \ Quitar el valor de la constante NO_NUM,
        \   guardar en el return stack el valor de la pila,
        \       que será el índice del comando
        \   llamar a nivel y reponer el valor 
        DROP >R NIVEL R>
    ELSE
        \ Si se va a asignar un nuevo nivel, preguntar si lo quiere hacer
        \ Comprobar si el indicado es el que había
        DUP ELNIVEL @ =
        IF 
            CR ." Has indicado el mismo nivel: " STR ." , no se hacen cambios."
            \ Mostrar los niveles y los intentos que quedan
            CR VER-NIVELES CR
        ELSE
            CR s" Si asignas un nuevo valor a NIVEL se reiniciara el juego."
            CONTINUAR?
            IF NIVEL 0 ELSE DROP VER-NIVELES THEN
        THEN
        \ Mostrar los intentos que quedan
        CR QUEDAN-INTENTOS CR
    THEN
;

\ v1.252 las opciones de jugar
\ Se pregunta qué tipo de juego quiere jugar
\   se comprueba si lo indicado es uno de los tipos de juego definidos
\   si no está definido o es ? se pone -1 en la pila, en otro caso se pone el índice
\ : JUGAR-CAMBIAR   ( -- n|-1 )
:NONAME
    CR ." Elige que forma de jugar quieres."
    \ ." Escribe una de estas opciones para cambiar de juego."
    JUGAR-MOSTRAR-OPCIONES
    ." Indica una de las opciones mostradas para cambiar el tipo de juego." CR
    s" Que forma de jugar quieres? "
    s" Si cambias de tipo de juego se finaliza el juego actual."
    PREGUNTA?
    
    \ Comprobar si lo escrito es la misma opción de juego
    'QUEAYUDA 'QUEJUGAR COMPARE 0=
    IF
        CR ." Has indicado la misma opcion con la que estas jugando, se sigue con el juego."
        -1 EXIT
    THEN
    \ Buscar lo escrito en JUGAR-INDEX
    \ Si es -1 es que no existe esa opción de juego
    \ Si es 8 (?) como si no se hubiera elegido una opción
    'QUEAYUDA JUGAR-INDEX
    s" en jugar-cambiar, queayuda= " 'QUEAYUDA DEBUG2
    DUP
    8 = IF DROP -1 THEN
    DUP
    -1 =
    IF
        \ Si se ha escrito ? avisar que aquí no es una opción
        'QUEAYUDA s" ?" COMPARE 0=
        CR
        IF
            ." La opcion '?' no es una opcion de juego, solo se puede usar con JUGAR cuando no estas jugando."
        ELSE
            ." La opcion de juego '" QUEAYUDA. ." ' no es valida."
        THEN
        CR
        \ CR ." Esa opcion de juego no es valida." CR
    THEN
; IS JUGAR-CAMBIAR

\ Comprobar si es un comando y si es así, ejecutarlo
: COMANDO-RUN  ( addr len -- index|-1 )
    COMANDO-INDEX
    \ Hacer copia del resultado, se usa para el -1 > IF...
    \   si se cumple, la copia se usa para el CASE.
    \   si no se cumple, sirve para el valor a devolver por comando-run
    DUP
    \ Si devuelve -1 es que no existe ese comando, devolver el -1 que ya está en la pila
    -1 > 
    IF
        \ hacer copia del índice, para?
        DUP
        \ Comprobar el comando, según el índice en la pila
        CASE
            \ Para NIVEL y DIFICULTAD el número debe estar indicado antes que la palabra
            \ Si es NIVEL o DIFICULTAD aquí llegará se indique o no un número
            0 OF NIVEL-CASE ENDOF
            \ En DIFICULTAD  hacer las mismas comprobaciones de NIVEL 
            \   para que no deje 0 en la pila cuando no se indica el nivel
            1 OF DIFICULTAD-CASE ENDOF
            2 OF PISTA ENDOF
            3 OF A-N? ENDOF
            4 OF CR RESUELVE ENDOF
            5 OF NUMS? ENDOF
            \ no dejar nada en la pila
            6 OF AYUDA-DIME ENDOF
            7 OF DIFICULTAD-CASE ENDOF
            8 OF NIVEL-CASE ENDOF
            \ 9 OF TRUE TO CAMBIARJUEGO? s" en comando-run es 9-cambiar-juego " DEBUG1 ENDOF
            9 OF TRUE TO CAMBIARJUEGO? ENDOF
        ENDCASE
    THEN
;

\ v1.217 comprobar si QUEAYUDA tiene ayuda-xxx o ayuda xxx
\ v1.218 se tendrán en cuenta estas posibilidades: 
\   ayuda xxx o ayuda-xxx o ayuda ayuda-xxx
\ Devuelve el índice o -1 si no se ha encontrado
: AYUDA?AYUDA   ( -- index|-1 )
    \ v1.233 por hacer: Dividir queayuda por un espacio
    \ v1.221 comprobar primero si QUEAYUDA tiene una ayuda
    \ s" en ayuda?ayuda antes de 'QUEAYUDA AYUDA-RUN, QUEAYUDA: " 'QUEAYUDA DEBUG2
    \ s" en ayuda?ayuda antes de 'QUEAYUDA AYUDA-RUN " DEBUG1
    'QUEAYUDA AYUDA-RUN
    \ s" en ayuda?ayuda despues de 'QUEAYUDA AYUDA-RUN " DEBUG1
    DUP
    -1 > 
    IF
        \ s" en ayuda?ayuda ha encontrado la ayuda " DEBUG1
        EXIT
    ELSE
        \ s" en ayuda?ayuda no se ha encontrado la ayuda " DEBUG1
        DROP
        \ s" en ayuda?ayuda no se ha encontrado la ayuda, despues de DROP " DEBUG1
    THEN 
    
    \ s"   al entrar en ayuda?ayuda, QUEAYUDA= " 'queayuda DEBUG2
    \ Dividirlo poniendo la primera parte en números y la segunda en letras
    QUEAYUDA-SPLIT-NUMEROS-LETRAS
    \ s"     en ayuda?ayuda QUENUMEROS= " 'QUENUMEROS DEBUG2
    \ s"     en ayuda?ayuda QUELETRAS= " 'QUELETRAS DEBUG2
    \ comprobar si tiene un espacio y -
    \   eso es que está en formato ayuda ayuda-xxx
    32 QUEAYUDA?C
    0 >
    IF
        \ tiene un espacio
        \ comprobar si tiene guión
        [CHAR] - QUEAYUDA?C
        0 >
        IF
            \ comprobar si la segunda palabra es una ayuda-xxx
            'QUELETRAS AYUDA-RUN
            \ s"   en ayuda?ayuda tiene un espacio y guion, despues de 'QUELETRAS AYUDA-RUN " DEBUG1
        ELSE
            \ no tiene guión, pero está separada por espacio
            \ comprobar si la segunda palabra es una ayuda
            'QUELETRAS AYUDA-RUN
            \ s"   en ayuda?ayuda tiene un espacio, pero no guion, despues de 'QUELETRAS AYUDA-RUN " DEBUG1
        THEN
    ELSE
        \ no tiene espacio
        \ comprobar si la segunda palabra es una ayuda
        'QUELETRAS AYUDA-RUN
        \ s"   en ayuda?ayuda no tiene espacio, despues de 'QUELETRAS AYUDA-RUN " DEBUG1
    THEN
    \ si es -1 es que no se ha encontrado
    \ comprobar si se ha escrito como ayuda ayuda xxx
    DUP
    -1 =
    IF 
        \ s"   en ayuda?ayuda antes de comprobar si la segunda palabra es una ayuda " 'QUEAYUDA DEBUG2
        DROP
        QUEAYUDA-SPLIT-NUMEROS-LETRAS
        \ s"   en ayuda?ayuda despues de QUEAYUDA-SPLIT-NUMEROS-LETRAS, QUELETRAS= " 'QUELETRAS DEBUG2
        QUELETRAS-SPLIT
        \ s"   en ayuda?ayuda despues de QUELETRAS-SPLIT, QUELETRAS= " 'QUELETRAS DEBUG2
        \ comprobar si tiene algo
        \ QUELETRAS-LEN 0= IF s" *** QUELETRAS ESTA EN BLANCO *** " DEBUG1 -1 EXIT THEN
        QUELETRAS-LEN 0= IF -1 EXIT THEN
        
        'QUELETRAS AYUDA-RUN
        \ s"   en ayuda?ayuda comprobando si la segunda palabra es una ayuda " 'QUELETRAS DEBUG2
    THEN
    \ s"   en ayuda?ayuda comprobar si se ha encontrado " DEBUG1
    
    \ s"   al salir de ayuda?ayuda, QUELETRAS= " 'QUELETRAS DEBUG2
; \ IS AYUDA?AYUDA

\ Si no es una ayuda, mostrar la ayuda general que corresponda
\ v1.251 poner un flag para indicar si se llama desde ayuda o desde ayuda-see
\ si no se indica un valor en la pila, no comprobar de dónde viene
: AYUDA-GENERAL?   ( flag|-- )
    \ si hay algo en la pila
    DEPTH 0>
    IF
        \ Guardar el valor indicado en la pila
        >R
        \ Solo mostrar que no es una ayuda si no está en blanco
        QUEAYUDA-LEN 0>
        IF
            \ Recuperar lo que se dejó en la pila
            R>
            \ si es true (o no cero) es que se llama desde ayuda
            \ si es false es que se llama desde ayuda-see
            CR
            IF
                ." La ayuda indicada: '" QUEAYUDA. ." ' no es una ayuda." CR
            ELSE
                \ ." El comando o la ayuda indicada: '" QUEAYUDA. ." ' no es valido."
                ." '" QUEAYUDA. ." ' no es un comando o una ayuda."
            THEN
        THEN
    THEN

    \ Saber si se ha llamado desde AYUDA o desde DIME.
    COMPROBARSEE @
    IF CR AYUDA-DIME
    ELSE AYUDA-GENERAL
    THEN
    CR
;

\ Solo se llama desde DIME
\ v1.213 quito el parámetro
: AYUDA-SEE   ( -- )
    \ s" al entrar en ayuda-see " DEBUG1
    
    QUEAYUDA>MAYUSCULAS
    \ Limpiar el contenido de los números y letras, 06-ene-2023 02.02
    QUENUMEROS-LETRAS-LIMPIAR

    \ Puede que tenga 2 cosas separadas por un espacio
    \ Si es así, puede ser <_NOMBRE> DIFICULTAD
    \   En ese caso, se tratará como número comando
    \ Aunque se puede comprobar si lo asignado en NUMEROS es una de las dificultades

    \ Dividirlo poniendo la primera parte en números y la segunda en letras
    QUEAYUDA-SPLIT-NUMEROS-LETRAS

    \ Comprobar si QUENUMEROS es una de las palabras de DIFICULTADES
    'QUENUMEROS DIFICULTAD-INDEX -1 >
    \ Si es así, poner true en la pila,
    \   si no, comprobar si lo escrito empieza por un número
    IF TRUE ELSE QUEAYUDA?1N THEN

    \ Si empieza por número
    IF 
        \ v1.214 DROP \ v1.213
        \ s" en ayuda-see empieza por numero, QUELETRAS= " 'QUELETRAS DEBUG2
        'QUELETRAS COMANDO-RUN
        \ s" en ayuda-see despues de 'QUELETRAS comando-run " DEBUG1
    
    \ Si no empieza por número
    ELSE 
        \ v1.214 DROP \ v1.213
        \ s" en ayuda-see no empieza por numero " 'QUEAYUDA DEBUG2
        \ comprobar si es un comando
        'QUEAYUDA COMANDO-RUN
        \ s" en ayuda-see despues de 'QUEAYUDA comando-run, QUEAYUDA= " 'QUEAYUDA DEBUG2
        DUP
        \ Si devuelve -1 es que no se ha encontrado,
        \ comprobar si se ha indicado ayuda-xxx
        \ dividir la palabra por el guión y buscar por ayuda xxx
        -1 = 
        IF
            DROP
            \ s" en ayuda-see antes de ayuda?ayuda " DEBUG1
            \ buscar las posibilidades de que ponga ayuda
            AYUDA?AYUDA
            \ s" en ayuda-see despues de ayuda?ayuda " DEBUG1
         THEN
    THEN
    \ v1.223 ya no hay que hacer más comprobaciones
    \ s" en ayuda-see antes de salir " DEBUG1
    
    \ v1.225 si es -1 es que no está esa palabra, mostrar la ayuda general
    -1 =
    IF
        \ s" en ayuda-see NO existe la ayuda o el comando: " 'QUEAYUDA DEBUG2
        FALSE AYUDA-GENERAL?
    THEN
;

\ Preguntar por algo, para el juego adivina 03-ene-2023 20.39
\ : DIME   ( -- )
:NONAME
    \ Si se indica algo en la pila, llamar a REINICIAR, 05-ene-2023 22.13
    DEPTH 0> IF DROP TRUE REINICIAR THEN
    CR ." Dime el numero (0 para terminar)? "
    TIB MAX_AYUDA ACCEPT #TIB !  0 >IN !
    1 TEXT PAD QUEAYUDA MAX_AYUDA MOVE
    
    \ v1.251 indicar que se está usando el juego
    TRUE COMPROBARSEE !
    
    \ Las comprobaciones
    
    \ v1.211
    \ Si está vacía, simplemente se ha pulsado INTRO, 
    \   mostrar aviso y volver a pedir el número.
    QUEAYUDA-LEN 0=
    IF CR ." Por favor indica un numero, un comando o una ayuda." CR DIME EXIT THEN
    
    \ v1.242 poner un espacio, en SwiftForth sale el texto junto a la respuesta
    \ v1.244 usando ESGFORTH?
    ESGFORTH? FALSE = IF ."  " THEN
    
    \ Comprobar si es un número, puede ser el cero
    \ Puede ser num comando, en los casos de NIVEL y DIFICULTAD
    \   si es así, QUEAYUDA tendrá letras
    \ Si lo indicado tiene letras, por ejemplo 3 NIVEL, QUEAYUDA?N devuelve FALSE.
    QUEAYUDA?N
    IF
        \ Si llega aquí, es que es un número sin letras
        QUEAYUDA>N
        DUP
        0= 
        IF 
            DROP 
            ." Has escrito 0, terminamos." CR 
            ." Los numeros indicados son: " NUMS? CR 
            RESUELVE
        ELSE
            ADIVINA
        THEN
        DEPTH 0> IF  CR ." En DIME queda algo en la pila cuando es un numero " .s CR THEN
    ELSE
        \ s" en dime no es un numero, se llama a ayuda-see " 'QUEAYUDA DEBUG2
        AYUDA-SEE
    THEN
; IS DIME

\ : AYUDA   ( -- )
:NONAME
    \ Acepta más de una palabra, hasta que se pulsa INTRO
    1 TEXT PAD QUEAYUDA MAX_AYUDA MOVE
    
    \ v1.211 si no se ha escrito nada, mostrar la ayuda general
    QUEAYUDA-LEN 0= IF AYUDA-GENERAL CR JUGAR-OPCIONES EXIT THEN
    
    \ v1.211 buscar la ayuda, convertido a mayúsculas
    QUEAYUDA>MAYUSCULAS
    
    \ v1.233 quitar lo que haya en la pila
    LIMPIAR-PILA
    
    \ v1.233 no es necesario usar AYUDA-BUSCAR
    FALSE COMPROBARSEE !
    AYUDA?AYUDA
    \ Si se encuentra devuelve el índice,
    \ si no se encuentra, devuelve -1
    -1 = IF TRUE AYUDA-GENERAL? THEN
    
    DEPTH 0 > IF DROP THEN
; IS AYUDA

\ v1.64 borrar el contenido de la pantalla
\ PAGE 
CR

\ Iniciar la semilla del número aleatorio
randomize 
\ Empezar un un nivel al azar
NIVEL-RANDOM
\ Jugar con el nivel _MEDIO de DIFICULTAD
\ Usar esto para que no se muestre el nivel de dificultad
_MEDIO DIFICULTAD!

\ v1.264 asignar una cadena vacía
s" " QUEJUGAR!

\ Poner algo en la pila para que no muestre el mensaje de los niveles
FALSE REINICIAR

AYUDA

LIMPIAR-PILA
  
