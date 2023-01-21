\ Util.forth
\ Algunas palabras para usar en los programas
\
\ by Guillermo Som (elGuille), 17-ene-2023 09.26
\
\ Para usar este fichero desde otro fichero:
\ include util.forth
\

\ 21-ene-2023 12.31
\   Redefino random, etc. usando (o casi) las definiciones de random.4th


\ No marcar esta, ya que se incluye desde otra principal, 19-ene-2023 18.05
\ \ Marcar que se han cargado estas palabras, 17-ene-2023 12.56
\ [DEFINED] util.forth [IF]
\     util.forth
\ [THEN]
\ marker util.forth

\ v1.215 para mostrar o no los mensajes de depuraci�n
\ Debug? ya est� definido en gforth
VARIABLE ESDEBUG? TRUE ESDEBUG? !

\ para facilitar la b�squeda de donde se muestran comentarios
: DEBUG1   ( addr len -- ) ESDEBUG? @ IF CR ." >>> " TYPE .s ELSE 2DROP THEN ;
: DEBUG2   ( addr1 len1 addr2 len2 -- ) 
    ESDEBUG? @ 
    IF CR 2SWAP ." >>> " TYPE ." '" TYPE ." ' " .s 
    ELSE 2DROP 2DROP
    THEN
;

\ A�ado definiciones para MAX-N y NULL. 19-ene-2023
\ De easy.4th
\ S" MAX-N" ENVIRONMENT?                 \ query environment
\ [IF]                                   \ if successful
\ NEGATE 1- CONSTANT (ERROR)             \ create constant (ERROR)
\ [THEN]
S" MAX-N" ENVIRONMENT?                 \ query environment
[IF]                                   \ if successful
CONSTANT MAX-N                         \ create constant MAX-N
[THEN]
\ De constant.4th
\ [UNDEFINED] NULL [IF]
\ (error) constant NULL                  ( NULL pointer)
\ [THEN]
MAX-N NEGATE 1- CONSTANT NULL            ( NULL pointer)


FALSE VALUE ESGFORTH?
: ES-GFORTH?
    s" gforth" environment?
    0= 
    if FALSE TO ESGFORTH?
    else TRUE TO ESGFORTH? 2DROP
    then
;
ES-GFORTH?

\ Copia la primera cadena en la segunda, 19-ene-2023 20.32
\   se indican los caracteres a limpiar de la segunda direcci�n
\ Ej. s" Hola!" <variable definida con max allot> <max> place-blank
: PLACE-BLANK   ( addr1 len1 addr2 max2 -- )
    2DUP BLANK DROP OVER OVER C! CHAR+ 1- SWAP MOVE
;


\ Para manipular arrays definidas con $" que acaban con NULL, 19-ene-2023 20.56

\ Saber los elementos del array indicado
\   El array debe estar acabado con NULL
: ?ARRAY-LEN   ( addr -- n )
    0 >r
    begin
        dup @ null =
        if drop false else r> 1+ >r true then
    while
        cell+
    repeat
    r>
;

\ La direcci�n de memoria del �ndice de un array acabado en null
\   addr la direcci�n de memoria del array acabado en null
\   index el �ndice que queremos mostrar
: N?ARRAY>S   ( addr index -- addr1 len1 )
    \ intercambiar los valores y guardar la direcci�n
    swap >r
    \ no pasar del m�ximo de palabras
    dup 0< if drop 0 then r@ ?array-len 1- min
    \ poner la direcci�n intercambiar los valores
    r> swap
    0 ?do cell+ loop
    \ dup 0> IF 0 do cell+ loop else drop then
    @ count
;

\ Muestra el contenido del �ndice indicado de un array acabado en null
\   addr la direcci�n de memoria del array acabado en null
\   index el �ndice que queremos mostrar
: N?ARRAY.   ( addr index -- )
    n?array>s type
;

\ Muestra el contenido de un array acabado en null
: ?ARRAY.   ( addr -- )
    dup ?array-len 0 do CR I 2 U.R ."  - " dup I n?array. loop
    drop
    \ s" al salir de ?array. " debug1
;


[UNDEFINED] between [IF]
: between within ;
[THEN]

[UNDEFINED] toupper [IF]
\ Si es una letra de la a a la z en min�sculas, la convierte en may�sculas
\ sino, devuelve el mismo car�cter
: toupper   ( char -- char )
    DUP
    [CHAR] a [CHAR] z 1+ WITHIN
    IF 32 - THEN
;
[THEN]

\ Para los n�meros aleatorios

\ Adaptado del fichero "C:\Program Files (x86)\gforth\tt.fs"
\ variable seed
\ \ time&date pone en la pila s m h d M y 
\ : randomize   time&date + + + + + seed ! ;
\ $10450405 Constant generator
\ : rnd  ( -- n )  seed @ generator um* drop 1+ dup seed ! ;
\ : random ( n -- 0..n-1 )  rnd um* nip ;

\ Adaptado de la definici�n de random.4th
variable seed                         \ seed variable
32767 constant max-rand               \ maximum random number
                                      ( -- n)
: (random) seed @ * + dup seed ! 16 rshift max-rand and ;
: random 2531011 214013 (random) ;  ( -- n)
\ time no existe en gForth
\ : randomize time seed ! ;             ( -- )

: randomize   time&date + + + + + seed ! ;

\ v1.14 Un n�mero aleatorio entre los dos indicados, ambos inclusive
: random2   ( n1 n2 -- n1..n2 )
    \ hace una copia del primero y lo pone arriba de la pila
    OVER \ w1 w2 -- w1 w2 w1
    - 1 + \ n2-n1+1 
    \ random saca un n�mero entre 0 y uno menos del n�mero indicado
    \ por eso le sumo 1 para que sea entre 0 y n2-n1 inclusive
    random 
    \ le sumamos el primero para que sea un n�mero entre n1 y n2 ambos inclusive
    +
;

\ Esto devuelve TRUE o FALSE siempre
\ Si se indica cualquier valor que no sea cero, se convierte en FALSE
[UNDEFINED] NOT [IF]
: NOT   ( flag -- flag ) IF FALSE ELSE TRUE THEN ;
[THEN]

\ muestra un n�mero sencillo como cadena sin espacios delante ni detr�s
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
\ Ya que la definici�n de string en SwiftForth es diferente a esta
: STRING2 CREATE CHARS ALLOT ;
\ En SwiftForth parace que est� definida como:
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

\ Para crear un array de forma f�cil (01-ene-2023 09.48)
\ Usage <n> ARRAY <name>
: ARRAY   ( n -- )
    CREATE  CELLS ALLOT
    \ Esto es lo que hace fuera de la definici�n
    DOES> ( n -- a )
    SWAP CELLS + ;

\ v1.240 Lo vuelvo a usar para compatibilidad con SwiftForth
\ (02-ene-2023 22.26)
\ Para poder crear arrays de cadenas con $"
\ M�s espacio para las cadenas, 20-ene-2023 18.03
4096 3 * constant /string-space

( Reserve  STRING-SPACE  in data-space. )
CREATE STRING-SPACE           /STRING-SPACE CHARS ALLOT
VARIABLE NEXT-STRING          0 NEXT-STRING !

( "string<">" � caddr ) 
: $" [CHAR] " PARSE
  DUP 1+ NEXT-STRING @ + /STRING-SPACE >
        ABORT" String Space Exhausted. "
  STRING-SPACE NEXT-STRING @ CHARS + >R
  DUP 1+ NEXT-STRING +!
  R@ PLACE
  R>
;

\ SwiftForth no tiene la definici�n de find-name,
\ hacer esta comprobaci�n para definir see? para gForth
\ en SwiftForth se puede usar see porque no lanza error
[DEFINED] find-name [IF]
\ Comprobar si una palabra existe sin mostrar error, 10-ene-2023 10.15
: see? parse-name find-name dup 0= if drop ." no existe " else name-see then ;
[ELSE]
: find-name   CR ." Esto es find-name si no est� definido" ;
: see?   see ;
[THEN] \ [UNDEFINED] find-name [IF]

\ Nuevas palabras para convertir en un n�mero y comprobar si es un n�mero, 04-ene-2023 17.15
\ Compruebo las que son iguales, 15-ene-2023 08.59

\ Convierte una cadena en un n�mero ud
\   Si la cadena tiene caracteres el flag ser� FALSE
\   Si la cadena no tiene caracteres el flag ser� TRUE
\   Si la cadena no ten�a un n�mero, ud ser� 0.
: to?ud   ( addr len -- ud flag ) 
    0. 2swap >number nip 0>
    if 2drop 0. false else true then ;

\ Convierte una cadena en un n�mero ud
\   Si la cadena no tiene n�meros el flag es FALSE y ud es 0.
\   Si la cadena empieza por n�meros el flag es TRUE y ud es el n�mero
: toud   ( addr len -- ud flag ) 0. 2swap dup >r >number nip r> < ;

\ alias para toud y to?ud
: str>ud   ( addr len -- ud flag ) toud ;
: str?ud   ( addr len -- ud flag ) to?ud ;

\ Convierte una cadena en un n�mero u
\   Si la cadena tiene caracteres el flag ser� FALSE
\   Si la cadena no tiene caracteres el flag ser� TRUE
\   Si la cadena no ten�a un n�mero, u ser� 0.
: to?u   ( addr len -- u flag )
    0. 2swap >number nip 0>
    \ si tiene caracteres quitar el valor ud de la pila y dejar false
    \ si no tiene, quitar el cero y dejar true
    if 2drop 0 false else drop true then ;

\ Convierte una cadena en un n�mero u
\   Si la cadena no tiene n�meros el flag es FALSE y u es 0.
\   Si la cadena empieza por n�meros el flag es TRUE y u es el n�mero
: tou   ( addr len -- u flag )
    0. 2swap dup >r >number nip r> <
    \ quitar el n�mero extra
    swap drop
;

\ alias para tou y to?u
: str>u   ( addr len -- u flag ) tou ;
: str?u   ( addr len -- u flag ) to?u ;

\ Defino str?u? y str?ud? para comprobar si es o no un n�mero, 15-ene-2023 09.56
\   sin devolver el n�mero y 
\   teniendo en cuenta que si tiene caracteres, delante o detr�s del n�mero,
\       devolver� false
: str?ud?   ( addr len -- flag )
    0. 2swap >number nip 0>
    -rot 2drop not
;
: str?u?   ( addr len -- flag ) str?ud? ;

\ v1.128 cambio NO-NUM por NO_NUM, 06-ene-2023 01.28
#-1234567890 CONSTANT NO_NUM

\ Definiciones para saber si es un d�gito, una letra o una cadena tiene letras, 05-ene-2023 17.42

\ En gForth digit? est� definido y hace lo mismo

\ Comprueba si el contenido de la pila es un d�gito
\ No se comprueba si es el signo - 45 o el signo + 43
\ Usando la definici�n del libro Forth Application Techniques
: DIGITO? ( nchar -- flag ) [CHAR] 0 [CHAR] 9 1+ WITHIN ;
\ : DIGITO?  ( char -- flag ) [CHAR] 0 - MAX-N AND 10 < ;

\ Comprueba si es una letra, no es un digito
: LETRA?  ( nchar -- flag ) DIGITO? INVERT ;

\ Comprobar si la cadena indicada en la pila tiene letras, 05-ene-2023 13.30
\ Se considera letras si no es un n�mero
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

\ hacer un volcado de la memoria de la direcci�n indicada
\   y opcionalmente la cantidad, si no se indica se usan 80
: ADDR-DUMP   ( addr n -- ) 
    DEPTH 1 = IF 80 THEN
    DUMP 
    DECIMAL
;

\ v1.217 funci�n para saber si una cadena tiene el car�cter indicado
\ dejar� la posici�n en base 0 o -1 si no est�
\   ej. char - s" hola-mundo" s?char
: S?CHAR   ( char addr len -- pos|-1 )
    \ dejar -1 antes de los par�metros
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
\   hasta el m�ximo indicado
: ?LIMPIAR   ( addr len max -- ) 
    DEPTH 3 < IF CR ." Se necesitan 3 parametros en la pila." CR EXIT THEN
    MIN BLANK ;

\ Limpiar el contenido de la direcci�n y longitud indicada, 17-ene-2023 11.54
\   solo se limpian los caracteres indicados
: >LIMPIAR   ( addr len -- ) BLANK ;


\ Convertir el contenido de la direcci�n indicada en may�sculas, 17-ene-2023 11.44
: >MAYUSCULAS   ( addr len -- ) BOUNDS ?DO I c@ toupper I c! LOOP ;

: '-TRAILING   ( addr max -- addr len ) -TRAILING ;
: >'   ( addr max -- addr len ) -TRAILING ;

\ Asigna el contenido de addr1 len1 en addr2 len2
\   len2 se usa como el m�ximo de caracteres a usar en destino
\   'ORIGEN 'DESTINO '!
\   s" Hola mundo" 'DESTINO '!
: '!   ( addr1 len1 addr2 len2 -- )
    2DUP >LIMPIAR
    DROP SWAP MOVE
;


\ Hacer una pregunta y asignar la respuesta en la segunda cadena
\ Los par�metros son:
\   addr1 len1 La pregunta a mostrar
\   addr2 len2 Donde se guardar� la respuesta sin convertir a may�sculas
\   En len2 se debe poner la longitud m�xima que se aceptar�
: PREGUNTA?   ( addr1 len1 addr2 len2 -- )
    \ Hacer copia de d�nde se guardar� la respuesta
    \ Copiarlo en el return stack
    \ Guardar la longitud en el return stack y descartar la direcci�n
    2DUP 2>R >R DROP
    \ Mostrar la cadena indicada en addr1 len1
    \ CR TYPE
    TYPE
    \ Aceptar un m�ximo de los caracteres indicados en len2
    TIB R> ACCEPT #TIB !  0 >IN !
    \ Guardar lo escrito en la direcci�n de addr2 len2
    1 TEXT PAD 2R> MOVE
;

\ Preguntar el texto indicado en addr2 len2
\ La cadena para usar antes de la pregunta estar� en addr1 len1
\ La letra may�sculas para aceptar la respuesta estar� en char
\ La respuesta se almacenar� en addr3 con un m�ximo de max3 caracteres
\   En len3 es conveniente poner la longitud m�xima que se aceptar�
\ CHAR S s" La pregunta? " s" texto antes de la pregunta" RESPUESTA MAX_RESP
: PREGUNTA-CHAR?   ( char addr1 len1 addr2 len2 addr3 max3 -- flag )
    2DUP 2>R >R DROP
    TYPE CR TYPE
    TIB R> ACCEPT #TIB ! 0 >IN !
    1 TEXT PAD 2R@ MOVE
    \ Si es la letra indicada en may�sculas, pondr� TRUE en la pila, si no pondr� FALSE
    2R> DROP C@ toupper = 
;

\ Preguntar si quiere continuar
\ En la pila estar� la direcci�n de una cadena para usar con la pregunta de si contin�a o no
\ y la direcci�n donde almacenar la respuesta es en addr2 len2
\ s" si hace eso, puede que tal y tal..." RESPUESTA MAX_RESP
: CONTINUAR?   ( addr len addr2 len2 -- flag )
    2>R 2>R [CHAR] S S" Quieres continuar (s = si, otra = no)? " 2R> 2R>
    PREGUNTA-CHAR?
;

\ Ver el fichero util-pruebas.forth para pruebas de estas palabras

\ As� se deben definir las cadenas
\ El tama�o m�ximo depende de cu�ntos caracteres queramos almacenar
\ 80 CONSTANT MAX_RESP
\ VARIABLE RESPUESTA MAX_RESP ALLOT

\ s" hola mundo" respuesta max_resp '-trailing drop max_resp '!
\ respuesta max_resp >' type
