( abrir gForth e indicar 
include adivina.forth
)
\ Marcar que se han cargado las palabras, 05-ene-2023 18.12
[IFDEF] adivina.forth
    adivina.forth
[ENDIF]
marker adivina.forth

\ Adivinar un número
: VERSION-ADIVINA   ." *** Adivina Forth v1.203 (10-ene-2023 20.21) *** " ;

\ v1.203 (10-ene-2023 20.21)
\   En JUGAR, cuando finalice preguntar si quiere jugar de nuevo.

\ v1.202 (10-ene-2023 20.05)
\   Defino PREGUNTA?, CONTINUAR? ahora usar PREGUNTA?

\ v1.201 (10-ene-2023 19.45)
\   Seguir con los cambios de nombres
\       $AYUDA por AYUDA>S, $COMANDO por COMANDO>S, $COMANDO-TEXT por COMANDO-TEXT>S

\ v1.200 (10-ene-2023 18.49)
\   Quito la definición de DIFICULTAD-PRINT, LAS-DIFICULTADES-NOMBRES
\   Seguir con los cambios de nombres
\       DIFICULTAD-$ por DIFICULTAD., $DIFICULTAD por DIFICULTAD>S
\       QUENUMEROS-TONUMBER por QUENUMEROS>N, DIFICULTAD-N por DIFICULTAD>N
\       QUENUMEROS-LENGTH por QUENUMEROS-LEN, QUELETRAS-LENGTH por QUELETRAS-LEN
\       *QUENUMEROS por 'QUENUMEROS, *QUELETRAS por 'QUELETRAS

\ v1.199 (10-ene-2023 18.27)
\   Cambiar las palabras del juego para que estén en español.
\       TIENE-LETRAS? por LETRAS?
\       QUEAYUDA-EMPIEZA-NUMERO por QUEAYUDA?1N, QUEAYUDA-TIENE-LETRAS por QUEAYUDA?LETRAS
\       QUEAYUDA-LENGTH por QUEAYUDA-LEN, QUEAYUDA-TOUPPER por QUEAYUDA>MAYUSCULAS
\       QUEAYUDA-TONUMBER por QUEAYUDA>N, *QUEAYUDA por 'QUEAYUDA
\       QUEAYUDA-ISNUMBER por QUEAYUDA?N, QUEAYUDA-MOSTRAR por QUEAYUDA.

\ v1.198 (10-ene-2023 17.20)
\   Dejo STR>INT como está:
\       admite cadenas que empiecen por un número aunque tengan letras,
\       devuelve NO_NUM si no contiene números.
\   Quito las definciones de STR>INT? y STR>INT2, ya que no se usan.
\   Defino str>ud, str?ud, str>u y str?u como alias para toud, to?ud, tou y to?u

\ v1.197 (10-ene-2023 08.52)
\   Defino toud, to?ud, tou y to?u
\       Las que tienen ? devolverán cero si tiene alguna letra.
\   Haciendo pruebas para convertir cadenas en números
\       teniendo en cuenta si la cadena tiene algún número.
\   Defino see? que es como see, si la palabra no esta definida 
\       muestra "no existe" en lugar de dar error, y si está definida muestra la palabra.


\ NOTAS:
\   Cuando se use >R y R> (o 2>R y 2R>) hay que hacerlo de forma que se use el par 
\       antes de que se use "algo" que utilice el return stack,
\       si no, se pierde el valor o sabe dios lo que puede pasar.


\ TODO:
\   Cambiar los nombres de las palabras de forma que empiecen o tengan ... si ...:
\       Siempre de la variable indicada, por ejemplo 'QUEAYUDA
\       .   imprimir, muestrar en la consola, type
\       '   devuelve addr len
\       !   para asignar un valor
\       >n  devuelve un número simple, normalmente sin signo, ej. s>n sería como tou
\       >s  devuelve una cadena, addr len
\       ?n  es un número simple, normalmente sin signo, ej. s?n, sería como to?u
\   Poder escribir jugar solo o jugar xxx para los distintos tipos de juegos.
\       Si solo se escribe jugar, se sigue como ahora.
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
: NOT   ( flag -- flag ) IF FALSE ELSE TRUE THEN ;

\ muestra un número sencillo como cadena sin espacios delante ni detrás
: STR   ( n -- d como cadena ) 0 <# #S #> TYPE ;

\ Limpiar el contenido de la pila (31-dic-2022 18.40)
: LIMPIAR-PILA   DEPTH 0> IF DEPTH 0 DO DROP LOOP THEN ;

: TEXT  ( delimiter -- )  PAD 258 BL FILL WORD COUNT PAD SWAP MOVE ;

\ Para crear un array de forma fácil (01-ene-2023 09.48)
\ Usage <n> ARRAY <name>
: ARRAY   ( n -- )
    CREATE  CELLS ALLOT
    \ Esto es lo que hace fuera de la definición
    DOES> ( n -- a )
    SWAP CELLS + ;

\ Definición de see de gforth
( : see parse-name find-name dup 0= IF drop -13 throw THEN name-see ; )

\ Comprobar si una palabra existe sin mostrar error, 10-ene-2023 10.15
: see? parse-name find-name dup 0= if drop ." no existe " else name-see then ;

\ Nuevas palabras para convertir en un número y comprobar si es un número, 04-ene-2023 17.15

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
: toud   ( addr len -- ud flag )
    0. 2swap dup >r >number nip r> <
;

\ alias para toud y to?ud
: str>ud   ( addr len -- ud flag ) toud ;
: str?ud   ( addr len -- ud flag ) to?ud ;

\ Convierte una cadena en un número u
\   Si la cadena tiene caracteres el flag será FALSE
\   Si la cadena no tiene caracteres el flag será TRUE
\   Si la cadena no tenía un número, u será 0.
: to?u   ( addr len -- u flag ) 
    0. 2swap >number nip 0>
    if 2drop 0 false else drop true then ;

\ Convierte una cadena en un número u
\   Si la cadena no tiene números el flag es FALSE y u es 0.
\   Si la cadena empieza por números el flag es TRUE y u es el número
: tou   ( addr len -- u flag )
    0. 2swap dup >r >number nip r> <
    swap drop
;

\ alias para tou y to?u
: str>u   ( addr len -- u flag ) tou ;
: str?u   ( addr len -- u flag ) to?u ;

\ Esta no se usa
\ comprobar si es un número, devolverá true o false
\ : STR>INT?  ( addr len -- flag )
\     0. 2swap dup >r >number nip r> <
\     2SWAP 2DROP
\ ;

\ La definición original de STR>INT sin devolver NO_NUM
\ : STR>INT2  ( addr len -- ud flag )
\     0. 2swap dup >r >number nip r> <
\     
\     \ Si no lo convierte, la pila tendrá 0 0 0
\     \ Si lo convierte, la pila tendrá num 0 -1
\     \   Es decir, el último valor es el flag de si lo ha convertido
\ ;

\ v1.128 cambio NO-NUM por NO_NUM, 06-ene-2023 01.28
#-1234567890 CONSTANT NO_NUM

\ Convierte un string en un número simple, 
\   deja el número o NO_NUM si no lo ha convertido
\ Funciona con s" 123" STR>INT . -- 123
\ También funciona con una variable definida con VARIABLE <NOMBRE> <TAMAÑO> ALLOT
\   Usando <NOMBRE> <TAMAÑO> -TRAILING STR>INT
: STR>INT  ( addr len -- n )
    0. 2swap dup >r >number nip r> <
    
    \ Si no lo convierte, la pila tendrá 0 0 0
    \ Si lo convierte, la pila tendrá num 0 -1
    \   Es decir, el último valor es el flag de si lo ha convertido
    
    \ Si no lo ha convertido, devolver NO_NUM o el número sencillo
    0= IF 2DROP NO_NUM ELSE DROP THEN
;

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

\ para facilitar la búsqueda de donde se muestran comentarios
: DEBUG   ( addr len -- ) TYPE .s ;

\ ********************************************************
\ * Constantes y variables                               *
\ * Definirlas todas antes de las palabras que las usan. *
\ ********************************************************

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

\ Variable para la palabra escrita
\ Máximo 20 caracteres
\ v1.111 lo cambio a 40 caracteres
40 CONSTANT MAX_AYUDA
VARIABLE QUEAYUDA MAX_AYUDA ALLOT

\ Devuelve la dirección y longitud del contenido de QUEAYUDA
: 'QUEAYUDA   ( -- addr len ) QUEAYUDA MAX_AYUDA -TRAILING ;

\ Devuelve TRUE o FALSE según tenga alguna letra
: QUEAYUDA?LETRAS   ( -- flag ) 'QUEAYUDA LETRAS? ;

\ Limpiar el contenido de QUEAYUDA con espacios
: QUEAYUDA-LIMPIAR   ( -- ) 'QUEAYUDA BLANK ;

\ Asignar el contenido de una dirección de memoria a QUEAYUDA
\   El texto se indicará con s" ..." o dejando una dirección y longitud en la pila
: QUEAYUDA!   ( addr len -- ) QUEAYUDA-LIMPIAR QUEAYUDA SWAP MOVE ;

\ Muestra en la consola el contenido de QUEAYUDA
: QUEAYUDA.   ( -- ) 'QUEAYUDA TYPE ;

\ Comprueba si el contenido de QUEAYUDA es un número
\ Devolver false si tiene letras
: QUEAYUDA?N    ( -- ) QUEAYUDA?LETRAS FALSE = ;

\ Convierte el contenido de QUEAYUDA en un número
: QUEAYUDA>N   ( -- ) 'QUEAYUDA STR>INT ;

\ La longitud de QUEAYUDA
: QUEAYUDA-LEN   ( -- len ) 'QUEAYUDA SWAP DROP ;

\ Convertir el contenido de QUEAYUDA en mayúsculas
: QUEAYUDA>MAYUSCULAS   ( -- )
    'QUEAYUDA BOUNDS ?DO I c@ toupper I c! LOOP ;

\ Comprobar si QUEAYUDA empieza por un número, 06-ene-2023 00.05
: QUEAYUDA?1N   ( -- flag ) QUEAYUDA C@ DIGITO? ;


\ Crear las variables para el número y las letras, 05-ene-2023 23.00
VARIABLE QUENUMEROS MAX_AYUDA ALLOT
VARIABLE QUELETRAS  MAX_AYUDA ALLOT

: 'QUENUMEROS   ( -- addr len ) QUENUMEROS MAX_AYUDA -TRAILING ;
: 'QUELETRAS   ( -- addr len ) QUELETRAS MAX_AYUDA -TRAILING ;

: QUENUMEROS-LEN   ( -- len ) 'QUENUMEROS SWAP DROP ;
: QUELETRAS-LEN   ( -- len ) 'QUELETRAS SWAP DROP ;

: QUENUMEROS-LIMPIAR   ( -- ) 'QUENUMEROS BLANK ;
: QUELETRAS-LIMPIAR   ( -- ) 'QUELETRAS BLANK ;

\ Limpiar los números y las letras, 06-ene-2023 02.01
\   con idea de llamarlo desde AYUDA-SEE antes de llamar a QUEAYUDA?1N
: QUENUMEROS-LETRAS-LIMPIAR   ( -- ) QUENUMEROS-LIMPIAR QUELETRAS-LIMPIAR ;

\ Asignar la cadena indicada a QUENUMEROS
: QUENUMEROS!   ( addr len -- ) QUENUMEROS-LIMPIAR QUENUMEROS SWAP MOVE ;
\ Asignar la cadena indicada a QUELETRAS
: QUELETRAS!   ( addr len -- ) QUELETRAS-LIMPIAR QUELETRAS SWAP MOVE ;

\ Convertir QUENUMEROS en un número, 06-ene-2023 00.29
: QUENUMEROS>N   ( -- numero )
    \ Comprobar si el contenido es una de las palabras de $DIFICULTADES
    \ Si no es uno de esos valores, convertirlo a número
    \ Si es, dejará en la pila el valor.
    'QUENUMEROS DIFICULTAD-INDEX
    \ hacer una copia porque la comparación lo quitará
    DUP
    -1 =
    IF DROP 'QUENUMEROS STR>INT THEN
;

\ Divide el contenido de QUEAYUDA separándolo por un espacio 
\   para cuando primero están los números
: QUEAYUDA-SPLIT-NUMEROS-LETRAS   'QUEAYUDA 32 $SPLIT QUELETRAS! QUENUMEROS! ;
\   para cuando primero están las letras
: QUEAYUDA-SPLIT-LETRAS-NUMEROS   'QUEAYUDA 32 $SPLIT QUENUMEROS! QUELETRAS! ;

\ Divide el contenido de QUEAYUDA por un guión
\   para comprobar si se escribe AYUDA-XXX
: QUEAYUDA-SPLIT-GUION   'QUEAYUDA [CHAR] - $SPLIT QUELETRAS! QUENUMEROS! ;

VARIABLE QUEAYUDAPOS

: QUEAYUDAPOS-INC   ( -- ) QUEAYUDAPOS @ 1 + QUEAYUDAPOS ! ;

\ Unir lo que hay en QUELETRAS y QUENUMEROS y guardarlo en QUEAYUDA
\ para usar como 'QUENUMEROS 'QUELETRAS
: QUEAYUDA-UNIR   ( -- )
    QUEAYUDA QUEAYUDAPOS !
    'QUENUMEROS BOUNDS ?DO I c@ QUEAYUDAPOS @ c! QUEAYUDAPOS-INC LOOP
    s"  " drop c@  QUEAYUDAPOS @ c! QUEAYUDAPOS-INC !
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
: DI-QUEAYUDA   1 TEXT PAD QUEAYUDA MAX_AYUDA MOVE ;


\ ************************************************************
\ * Las ayudas y palabras que muestran textos de ayuda, etc. *
\ * Las palabras que se usan en las ayudas las defino antes. *
\ ************************************************************

\ Preguntar el texto indicado en addr2 len2
\ La cadena para usar antes de la pregunta estará en addr len
\ La letra mayúsculas para aceptar la respuesta estará en char
\ CHAR S s" La pregunta" s" texto antes de la pregunta"
: PREGUNTA?   ( char addr2 len2 addr len -- flag )
    \ s" al entrar en pregunta " cr DEBUG
    TYPE CR TYPE
    TIB MAX_AYUDA ACCEPT #TIB !  0 >IN !
    1 TEXT PAD QUEAYUDA MAX_AYUDA MOVE
    \ Convertir en mayúsculas
    QUEAYUDA>MAYUSCULAS
    \ Si es la letra S mayúsculas, pondrá TRUE en la pila, si no pondrá FALSE
    \ s" antes de QUEAYUDA C@ = " cr DEBUG
    QUEAYUDA C@ = 
;

\ Preguntar si quiere continuar
\ En la pila estará la dirección de una cadena para usar con la pregunta de si continúa o no
: CONTINUAR-ant?   ( addr len -- flag )
    TYPE CR ." Quieres continuar (s = si, otra = no)? "
    TIB MAX_AYUDA ACCEPT #TIB !  0 >IN !
    1 TEXT PAD QUEAYUDA MAX_AYUDA MOVE
    \ Convertir en mayúsculas
    QUEAYUDA>MAYUSCULAS
    \ Si es la letra S mayúsculas, pondrá TRUE en la pila, si no pondrá FALSE
    QUEAYUDA C@ 83 = 
;

: CONTINUAR?   ( addr len -- flag )
    \ s" al entrar en continuar? " cr DEBUG
    2>R [CHAR] S S" Quieres continuar (s = si, otra = no)? " 2R>
    \ s" antes de llamar a pregunta? " cr DEBUG
    PREGUNTA?
;

\ Esto debe estar antes de las ayudas, porque se usa en MOSTRAR-CORRECTO.
\ TRUE si juega el humano, en otro caso FALSE
: HUMANO?   QUIENJUEGA @ _HUMANO =  ;

\ v1.10 El número máximo a adivinar 
: EL-MAXIMO   ( -- ELNIVEL * 100 ) ELNIVEL @ 100 * ;

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

\ Definir el array con los niveles de las dificultades, 6-ene-2023
\ El array contiene los textos y los valores de los intentos
\ El índice 0 no se usa
CREATE $DIFICULTADES
    s" _ALEATORIO" 2, 
    s" _SENCILLO" 2, 
    s" _MEDIO" 2, 
    s" _DIFICIL" 2, 
    s" _EXPERTO" 2, 
    s" _MAESTRO" 2, 
    s" _SENSEI" 2, 
    255 , 22 , 14 , 12 , 9 , 6 , 5 ,

\ Muestra los intentos del índice indicado: de 1 _SENCILLO a 6 _SENSEI o %DIFICULTADES
: DIFICULTAD>N   ( index -- num )
    \ offset 56 para el primer valor y 4 + para los siguientes
    4 * 56 + $DIFICULTADES + @ ;

\ Imprime el nombre y los números de intentos
\ El índice siempre de 1 a %DIFICULTADES
: DIFICULTAD.   ( index -- str )
    DUP
    $DIFICULTADES SWAP 2 CELLS * + 2@ TYPE ."  "
    ." (" DIFICULTAD>N . ." intentos)"
;

\ Deja en la pila la dirección de memoria del texto del índice indicado
: DIFICULTAD>S   ( index -- addr len )
    %DIFICULTADES MIN 1 MAX
    $DIFICULTADES SWAP 2 CELLS * + 2@ 
;

\ Muestra el texto de la dificultad indicada
\ : DIFICULTAD-PRINT   ( index -- print string )
\     %DIFICULTADES MIN 1 MAX
\     DIFICULTAD>S TYPE
\ ;

\ Esto no se usa
\ : LAS-DIFICULTADES-NOMBRES ( -- imprime los textos )
\     %DIFICULTADES 1 + 1 DO I DIFICULTAD>S TYPE I %DIFICULTADES < IF ." , " THEN LOOP ;

\ Para mostrar las dificultades en DIFICULTADES-MOSTRAR
: LAS-DIFICULTADES
    ."    "
    %DIFICULTADES 1 + 1
    DO 
        I . ." = " I DIFICULTAD. ."  "
        I 3 + 3 MOD 0= IF CR ."    " THEN
    LOOP
;

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



\ ********************
\ * Las ayudas, etc. *
\ ********************

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
\ Cambio SHOW-CORRECTO por MOSTRAR-CORRECTO
: MOSTRAR-CORRECTO
    ." Correcto! el numero era " NUMEROADIVINAR ? 
    HUMANO? IF ." lo has adivinado en " ELSE ." lo he adivinado en "  THEN
    INTENTOS ? 
    \ v1.3 comprobar si es 1 intento o más
    INTENTOS @ 1 = IF ." intento. " ELSE ." intentos. " THEN 
    CR INSTRUCCIONES-MOSTRAR ;

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
    1 AYUDA-PISTA CR
    ." Si quieres que yo adivine el numero escribe OPCIONES-SOLO y veras las opciones de juego automatico." CR
    ." Si quieres jugar contra el ordenador en modo normal, escribe JUGAR."
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

: AYUDA-JUGANDO   ( -- )
    ." Te ire preguntando el numero que crees que he elegido aleatoriamente" CR
    ." hasta que lo adivines o no quieras continuar." CR
    ." En este modo el numero de comandos esta limitado a:" CR
    COMANDOS-MOSTRAR
;

\ La ayuda para cuando juega con DIME
: AYUDA-JUGAR   ( flag| -- )
    DEPTH 0= IF TRUE THEN
    IF CR ." *** La ayuda de JUGAR ***" CR THEN
    CR
    ." Para jugar una partida contra el ordenador escribe JUGAR." CR
    AYUDA-JUGANDO
;

: AYUDA-DIME   ( -- )
    CR ." *** AYUDA (mientras juegas) ***" CR
    ." Intenta adivinar el numero que he elegido." CR
    VER-NIVELES CR
    AYUDA-OPCIONES CR
    AYUDA-JUGANDO
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
    0 >= IF DIFICULTAD! ELSE DROP THEN 
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
            CR INSTRUCCIONES-MOSTRAR
            s" despues de no quedan intentos " cr DEBUG
        ELSE
            \ incrementar el número de intentos
            INC-INTENTOS 
            \ v1.26 guardar el número en el array después de incrementar
            \ pero restando uno ya que el índice es en base cero
            NUMEROINDICADO @ INTENTOS @ 1 - NUMS!
            \ si lo ha adivinado
            NUMEROINDICADO @ NUMEROADIVINAR @ = 
            IF MOSTRAR-CORRECTO
                s" en adivina despues de MOSTRAR-CORRECTO " cr DEBUG
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
    CR INSTRUCCIONES-MOSTRAR
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
    IF ELNIVEL ! TRUE REINICIAR ELSE VER-NIVELES THEN
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

\ Reiniciar el juego, asignando los valores predeterminados, etc.
\ Si no se indica un parámetro es como TRUE
\ Si se indica FALSE no mostrar los mensajes
\ Si se indica TRUE mostrar los mensajes
\ : REINICIAR   ( flag| -- limpia la pila )
:NONAME
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

\ Jugar en bucle
\ : JUGAR   ( -- )
:NONAME
    FALSE REINICIAR
    _HUMANO QUIENJUEGA !
    CR
    ." *** JUGAR en modo normal (con comandos limitados) ***" CR CR
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
        SEGUIR-BUCLE
        \ If flag is false, go back to BEGIN. If flag is true, terminate the loop
    UNTIL
    
    CR
    \ Preguntar si quiere echar otra partida
    \ Si se ha mostrado la solución
    SOLUCIONMOSTRADA @
    IF CR ." No has adivinado el numero." S" A ver si ahora tienes mas suerte." 2>R
    ELSE CR ." Lo has hecho bien." S" Prueba con otro nivel y/o otra dificultad." 2>R
    THEN
    CR
    [CHAR] S S" Quieres echar otra partida (s = si, otra = no) ?" 2R>
    PREGUNTA?
    IF CR JUGAR EXIT THEN
    CR CR ." Si quieres volver a jugar, escribe JUGAR," CR 
    ."     si quieres que yo eche una partida escribe JUGAR-SOLO." 
    CR
; IS JUGAR

\ Esto juega escribiendo las palabras, sin bucle
\ Lo llamaré JUGAR-INTERACTIVO
\ Iniciar el juego, poner todos los valores a cero
\ No mostrar la ayuda ni nada
: JUGAR-INTERACTIVO
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
\ JUGAR-SOLO juega con el NIVEL y DIFICULTAD que estén asignados
: JUGAR-SOLO
    NIVELDIFICULTAD @ DIFICULTAD!
    \ v1.102 poner un valor en la pila para que no se muestren los niveles
    FALSE REINICIAR
    \ Asignar que juega la máquina
    _MAQUINA QUIENJUEGA !
    \ Mostrar que se juega automáticamente
    CR
    ." *** JUGAR SOLO (el ordenador adivinara el numero) ***" CR CR
    ." Juego automaticamente, ire mostrando los numeros elegidos y si lo acierto. " CR
    ." Estoy jugando con el NIVEL: " ELNIVEL ? 
    ." tengo que adivinar un numero del 1 al " EL-MAXIMO STR ." ." CR
    ." El nivel de DIFICULTAD es " NIVELDIFICULTAD @ DIFICULTAD. CR
    1800 MS
    \ Empieza un bucle
    BEGIN
        CR
        A-N?
        \ s" en jugar-solo despues de a-n? " cr DEBUG
        800 MS
        \ SEGUIR-BUCLE devuelve TRUE si lo ha adivinado o han pasado los intentos
        SEGUIR-BUCLE
        \ s" en jugar-solo despues de SEGUIR-BUCLE " cr DEBUG
        \ If flag is false, go back to BEGIN. If flag is true, terminate the loop
    UNTIL
    \ Comprobar si se ha pasado de intentos o se ha mostrado la solución
    INTENTOS @ INTENTOSMAXIMO @ > SOLUCIONMOSTRADA @ OR
    IF CR CR ." Me he pasado del numero de intentos :-( " CR
        ."     Tengo que mejorar con el NIVEL: " ELNIVEL ? 
        ." y el nivel de DIFICULTAD " NIVELDIFICULTAD @ DIFICULTAD. CR
        1000 MS
    THEN
;

\ JUGAR-SOLO-AUTO elige al azar el NIVEL y DIFICULTAD
: JUGAR-SOLO-AUTO
    1 NIVELMAXIMO @ random2 ELNIVEL !
    _SENCILLO _SENSEI random2 NIVELDIFICULTAD !
    JUGAR-SOLO
;

\ JUGAR-SOLO-FACIL juega con un NIVEL entre 1 y 5 y con el nivel de DIFICULTAD entre _SENCILLO y _MEDIO
: JUGAR-SOLO-FACIL
    1 5 random2 ELNIVEL !
    _SENCILLO _MEDIO random2 NIVELDIFICULTAD !
    JUGAR-SOLO
;

\ JUGAR-SOLO-DIFICIL para probar con nivel NIVELMAXIMO - 4 a NIVELMAXIMO y DIFICULTAD _DIFICIL a _SENSEI
: JUGAR-SOLO-DIFICIL
    NIVELMAXIMO @ 4 - NIVELMAXIMO @ random2 ELNIVEL !
    _DIFICIL _SENSEI random2 NIVELDIFICULTAD !
    JUGAR-SOLO
;

\ *******************************************************************
\ Para mostrar la ayuda                           (30/dic/22 16.46) *
\ *******************************************************************

\ El número de elementos de $AYUDAS
19 CONSTANT %AYUDAS
\ Definir el array de las ayudas
CREATE $AYUDAS
    S" GENERAL" 2,  \ 0
    s" JUGAR" 2,
    s" NIVEL" 2,
    s" DIFICULTAD" 2,
    s" PISTA" 2, 
    s" ADIVINA" 2,
    s" FORTH" 2,
    s" AYUDA GENERAL" 2, \ 7
    s" AYUDA JUGAR" 2,
    s" AYUDA NIVEL" 2,
    s" AYUDA DIFICULTAD" 2,
    s" AYUDA PISTA" 2, 
    s" AYUDA ADIVINA" 2,
    s" AYUDA FORTH" 2,
    s" INTERACTIVO" 2,
    s" AYUDA INTERACTIVO" 2,
    s" JUGAR INTERACTIVO" 2,
    s" AYUDA JUGAR INTERACTIVO" 2, 
    s" JUGANDO" 2,  \ 18
    s" AYUDA JUGANDO" 2,

\ Se accede siempre de 0 a %AYUDAS
: AYUDA>S   ( index -- addr len )
    \ Que solo acepte valores entre %AYUDAS y 0  03-ene-2023 13.25
    %AYUDAS MIN 0 MAX 
    \ Deja en la pila la dirección de $AYUDAS del índice que está en la pila
    ( el código si se define $ayudas con S" )
    $AYUDAS SWAP 2 CELLS * + 2@ 
;

\ Para asignar el valor: *queayuda 'ayudatmp 2!
\ Para recuperar el valor 'AYUDATMP 2@ 
2VARIABLE 'AYUDATMP

\ Busca en la colección $AYUDAS si está la palabra dejada en la pila
\ Debe estar en mayúsculas, será al estilo de QUEAYUDA MAX_AYUDA -TRAILING
: AYUDA-INDEX   ( addr len -- index|-1 )
    'AYUDATMP 2! -1 'AYUDATMP 2@
    %AYUDAS 1+ 0
    DO 
        2DUP
        I AYUDA>S COMPARE 0=
        IF 
            \ Quitar la addr len y el valor -1
            2DROP DROP I 'AYUDATMP 2@
            LEAVE THEN
    LOOP
    \ En la pila estará el valor del índice si se ha hallado, 
    \ si no, lo que hubiera en la pila y la dirección puesta al entrar
    2DROP
;

\ Comprobar si es una ayuda y si es así mostrarla
: AYUDA-RUN   ( addr len -- index|-1 )
    AYUDA-INDEX
    DUP
    \ Si devuelve -1 es que no existe ese comando, devolver -1
    -1 > 
    IF
        \ hacer copia del índice
        DUP
        \ Comprobar qué ayuda mostrar según el índice en la pila
        \ OJO, salvo AYUDA-GENERAL, el resto de AYUDA-XXX quita lo que haya en la pila
        \ ya que se comprueba si no hay nada en la pila para mostrar "La ayuda de XXX"
        CASE 
            0 OF AYUDA-GENERAL ENDOF
            1 OF TRUE AYUDA-JUGAR 1 ENDOF
            2 OF TRUE TRUE AYUDA-NIVEL 2 ENDOF
            3 OF TRUE AYUDA-DIFICULTAD 3 ENDOF
            4 OF TRUE AYUDA-PISTA 4 ENDOF
            5 OF TRUE AYUDA-ADIVINA 5 ENDOF
            6 OF TRUE AYUDA-FORTH 6 ENDOF
            7 OF TRUE AYUDA-GENERAL ENDOF
            8 OF TRUE AYUDA-JUGAR 8 ENDOF
            9 OF TRUE AYUDA-NIVEL 9 ENDOF
            10 OF TRUE AYUDA-DIFICULTAD 10 ENDOF
            11 OF TRUE AYUDA-PISTA 11 ENDOF
            12 OF TRUE AYUDA-ADIVINA 12 ENDOF
            13 OF AYUDA-FORTH 13 ENDOF
            14 OF TRUE AYUDA-INTERACTIVO 14 ENDOF
            15 OF TRUE AYUDA-INTERACTIVO 15 ENDOF
            16 OF TRUE AYUDA-INTERACTIVO 16 ENDOF
            17 OF TRUE AYUDA-INTERACTIVO 17 ENDOF
            \ Ayuda jugando no recibe el parámetro de mostrar título
            18 OF TRUE AYUDA-JUGANDO ENDOF
            19 OF TRUE AYUDA-JUGANDO ENDOF
            \ Aquí estaría el caso para cuando no se cumplen los anteriores
        ENDCASE
    THEN
;

8 CONSTANT %COMANDOS
\ Definir el array con las palabras que se podrán usar, 4-ene-2023 19.42
CREATE $COMANDOS
    s" NIVEL" 2,
    s" DIFICULTAD" 2, 
    s" PISTA" 2, 
    s" A-N?" 2, 
    s" RESUELVE" 2, 
    s" NUMS?" 2, 
    s" AYUDA" 2, 
    s" D!" 2, 
    s" N!" 2, 

\ definir un array con la explicación de los comandos, 06-ene-2023 04.58
CREATE $COMANDOS-TEXT
    s" para mostrar o cambiar el NIVEL de juego (no es recomendable cambiar el NIVEL)." 2,
    s" para mostrar o cambiar el nivel de DIFICULTAD." 2,
    s" para mostrarte una pista del numero que puedes indicar." 2, 
    s" para que el ordenador te diga que numero elegir." 2, 
    s" para mostrar la solucion y terminar." 2, 
    s" para mostrarte los numeros que has indicado hasta ahora." 2, 
    s" para mostrarte las ayudas disponibles." 2, 
    s" alias para mostrar o cambiar el nivel de DIFICULTAD." 2, 
    s" alias para mostrar o cambiar el NIVEL de juego." 2,

: COMANDO>S   ( index -- addr len )
    \ Que solo acepte valores entre %COMANDOS y 0  03-ene-2023 13.25
    %COMANDOS MIN 0 MAX 
    \ Deja en la pila la dirección de $COMANDOS del índice que está en la pila
    $COMANDOS SWAP 2 CELLS * + 2@ 
;

: COMANDO-LEN   ( index -- len )
    COMANDO>S SWAP DROP
;

\ Deja en la pila la dirección de memoria del texto del índice indicado
: COMANDO-TEXT>S   ( index -- addr len )
    %COMANDOS MIN 0 MAX 
    $COMANDOS-TEXT SWAP 2 CELLS * + 2@
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

: DIFICULTAD-CASE   ( -- )
    QUENUMEROS>N
    DUP
    \ Este caso se dará si no se escribe un número
    \   solo el comando dificultad o d!
    NO_NUM =
    IF 
        \ Quitar el valor de la constante NO_NUM,
        \   guardar en el return stack el valor de la pila,
        \   llamar a dificultad y reponer el valor 
        DROP >R DIFICULTAD R>
    ELSE
        CR DIFICULTAD-MOSTRAR CR
        \ Comprobar si es el mismo nivel, en ese caso, no hacer nada más
        QUENUMEROS>N NIVELDIFICULTAD @ =
        IF 
            \ Esto está bien, deja en la pila el valor con el que entró: 
            \   el número de la opción del case
            ." Has indicado el mismo nivel de DIFICULTAD, no se hacen cambios." CR
            \ ." en dificultad-case, es el mismo nivel " .s
            DROP
            \ Mostrar los niveles
            CR VER-NIVELES
        ELSE
            \ Comprobar si se ha indicado 0, sacará un número aleatorio
            QUENUMEROS>N 0 =
            IF 
                ." Esto asigna un nivel de DIFICULTAD aleatorio entre 1 (" 
                1 DIFICULTAD>S TYPE
                ." ) y 6 (" %DIFICULTADES DIFICULTAD>S TYPE 
                s" )."
            ELSE
                ." Si asignas el nivel " QUENUMEROS>N . ." (" DUP DIFICULTAD>S TYPE ." ) "
                
                \ Comprobar si es un numero menor al actual
                \ Si el número es mayor, tendrá menos oportunidades
                QUENUMEROS>N NIVELDIFICULTAD @ >
                IF 
                    \ ." Si asignas " DUP DIFICULTAD>S TYPE
                    s" tendras menos intentos."
                ELSE
                    \ ." Si asignas " DUP DIFICULTAD>S TYPE
                    s" tendras mas intentos y es casi como hacer trampas."
                THEN
            THEN
            CONTINUAR?
            IF DIFICULTAD ELSE DROP CR VER-NIVELES THEN
        THEN
        \ Mostrar siempre los intentos que quedan
        CR QUEDAN-INTENTOS CR
    THEN
;

: NIVEL-CASE   ( -- )
    \ En la pila estará 0
    QUENUMEROS>N
    DUP
    \ Si es NO_NUM es que no se ha indicado número
    NO_NUM =
    \ Si solo se muestra el nivel actual no hay problemas
    IF 2DROP NIVEL 0
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

\ Comprobar si es un comando y si es así, ejecutarlo
: COMANDO-RUN  ( addr len -- index|-1 )
    COMANDO-INDEX
    \ Hacer copia del resultado, se usa para el -1 > IF...
    \   si se cumple, la copia se usa para el CASE.
    \   si no se cumple, sirve para el valor a devolver por COMANDO-RUN
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
            \   si no se ha indicado un número QUENUMEROS>N devolverá NO_NUM
            \ Cuando sea NIVEL dejar el índice en la pila
            0 OF NIVEL-CASE ENDOF
            \ En DIFICULTAD  hacer las comprobaciones de NIVEL 
            \   para que no se use 0 cuando no se indica el nivel
            1 OF DIFICULTAD-CASE ENDOF
            2 OF PISTA ENDOF
            3 OF A-N? ENDOF
            4 OF CR RESUELVE ENDOF
            5 OF NUMS? ENDOF
            \ no dejar nada en la pila
            6 OF AYUDA-DIME ENDOF
            7 OF DIFICULTAD-CASE ENDOF
            8 OF NIVEL-CASE ENDOF
        ENDCASE
    THEN
;

\ Para ver si se debe comprobar la palabra para mostrar la ayuda correspondiente
\ y si no se encuentra esa palabra salir sin más.
VARIABLE COMPROBARSEE FALSE COMPROBARSEE !

\ indicar siempre el valor a asignar a COMPROBARSEE
\   FALSE si se llama desde AYUDA
\   TRUE si se llama desde DIME
: AYUDA-SEE   ( flag -- )
    DUP
    
    \ Guardar el valor en el return stack
    \ >R
    COMPROBARSEE !
    
    \ \ Si es FALSE, hacer una copia
    \ FALSE = IF DUP THEN
    
    QUEAYUDA>MAYUSCULAS
    
    \ Si se ha llamado con TRUE para buscar la ayuda o el comando
    IF
        \ Limpiar el contenido de los números y letras, 06-ene-2023 02.02
        QUENUMEROS-LETRAS-LIMPIAR
        
        \ Puede que tenga 2 cosas separadas por un espacio
        \ Si es así, puede ser <_NOMBRE> DIFICULTAD
        \   En ese caso, se tratará como número comando
        \ Aunque se puede comprobar si lo asignado en NUMEROS es una de las dificultades
        
        \ Dividirlo poniendo la primera parte en números y la segunda en letras
        QUEAYUDA-SPLIT-NUMEROS-LETRAS
        
        \ Comprobar si QUENUMEROS es una de las palabras de DIFICULTADES
        \ dificultad-index usa return stack
        \ poner el valor en la pila
        'QUENUMEROS DIFICULTAD-INDEX -1 >
        \ Si es así, poner true en la pila,
        \   si no, comprobar si lo escrito empieza por un número
        IF TRUE ELSE QUEAYUDA?1N THEN
        
        \ buscar primero el comando, si no se encuentra, intentar con la ayuda
        
        \ Si empieza por número
        IF 'QUELETRAS COMANDO-RUN 
        ELSE 
            'QUEAYUDA COMANDO-RUN
            DUP
            \ Si devuelve -1 es que no se ha encontrado,
            \ comprobar si se ha indicado ayuda-xxx
            \ dividir la palabra por el guión y buscar por ayuda xxx
            -1 = 
            IF
                QUEAYUDA-SPLIT-GUION
                QUEAYUDA-UNIR
                -1
             THEN
        THEN
    ELSE
        -1
    THEN
    \ Si es -1 es que no está esa palabra, buscar en las ayudas
    -1 = 
    IF
        \ Esto buscará tanto ayuda xxx como xxx
        'QUEAYUDA AYUDA-RUN
        
        DEPTH 0= 
        IF CR ." ERROR debe haber algo en la pila en AYUDA-SEE despues de 'QUEAYUDA AYUDA-RUN " .s CR THEN
        \ Si queda -1 en la pila, es que no está esa ayuda
        -1 =
        IF  
            \ comprobar si QUEAYUDA tiene algo escrito, 05-ene-2023 20.37
            QUEAYUDA-LEN 0>
            IF CR ." '" QUEAYUDA. ." ' no es un comando ni una ayuda." THEN

            \ el return stack no se puede usar porque desde aquí 
            \   se llama a dificultad-index que usa el return stack
            \ R>
            \ Aquí tiene que estar el valor de COMPROBARSEE
            \ Saber si se ha llamado desde AYUDA o desde DIME.
            COMPROBARSEE @
            IF CR AYUDA-DIME
            ELSE AYUDA-GENERAL
            THEN
        THEN
    THEN
    \ Limpiar la pila, para asegurarnos de que no quede nada
    DEPTH 0>
    IF
        CR ." Hay que limpiar la pila al finalizar AYUDA-SEE: " .S CR
        LIMPIAR-PILA
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

    \ Las comprobaciones
    
    \ Comprobar si es un número, puede ser el cero
    \ Puede ser num comando, en los casos de NIVEL y DIFICULTAD
    \   si es así, QUEAYUDA tendrá letras
    \ Si lo indicado tiene letras, por ejemplo 3 NIVEL, QUEAYUDA?N devuelve FALSE.
    QUEAYUDA?N
    IF
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
        TRUE AYUDA-SEE
    THEN
; IS DIME

\ : AYUDA   ( -- )
:NONAME
    \ Acepta más de una palabra, hasta que se pulsa INTRO
    1 TEXT PAD QUEAYUDA MAX_AYUDA MOVE
    FALSE AYUDA-SEE
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

\ Poner algo en la pila para que no muestre el mensaje de los niveles
FALSE REINICIAR

AYUDA

LIMPIAR-PILA
  
