\
\ Para probar las palabras (utilidades) de util.forth
\ por Guillermo Som (Guille), 17-ene-2023 16.32
\
\ Para cargar este fichero en una plicación de Forth:
\ include util-pruebas.forth
\
\ Usando la nueva ubicación, 19-ene-2023 18.10
\ include Forth-programming-language\util-forth\util-pruebas.forth
\

\ Marcar que se han cargado estas palabras, 17-ene-2023 12.56
[DEFINED] util-pruebas.forth [IF]
    util-pruebas.forth
[THEN]
marker util-pruebas.forth

\ Cargar las palabras definidas en util.forth
include util.forth

\ Así se deben definir las cadenas
\ El tamaño máximo depende de cuántos caracteres queramos almacenar
80 CONSTANT MAX_RESP
VARIABLE RESPUESTA MAX_RESP ALLOT
\ Poner todos los caracteres en blanco (espacios)
RESPUESTA MAX_RESP BLANK

\ La dirección de memoria y longitud
: 'RESPUESTA   ( -- addr len ) RESPUESTA MAX_RESP -TRAILING ;
\ Mostrar el contenido de RESPUESTA
: RESPUESTA.   ( -- ) 'RESPUESTA TYPE ;
\ Asignar el contenido de una cadena en RESPUESTA
\ : RESPUESTA!   ( addr len -- ) 'RESPUESTA >LIMPIAR RESPUESTA SWAP MOVE ;
\ Usando place-blank
: RESPUESTA!   ( addr len -- ) RESPUESTA MAX_RESP PLACE-BLANK ;
\ La longitud actual de RESPUESTA
: RESPUESTA-LEN   ( -- len ) 'RESPUESTA SWAP DROP ;
\ Limpiar el contenido de RESPUESTA con espacios
\ : RESPUESTA-LIMPIAR   ( -- ) 'RESPUESTA BLANK ;
\ Limpiar todo el contenido
: RESPUESTA-LIMPIAR   ( -- ) RESPUESTA MAX_RESP BLANK ;


\ Pide un número
\   addr1 len1 el texto a mostrar
\   devuelve un número
: INPUTN   ( addr1 len1 -- n )
    RESPUESTA MAX_RESP
    PREGUNTA?
    \ Si no se ha escrito nada, poner 0 como respuesta
    \ RESPUESTA-LEN 0 = IF s" 0" RESPUESTA! THEN
    RESPUESTA-LEN 0 = IF s" <nada>" RESPUESTA! THEN
    'RESPUESTA to?u
    \ si el top de la pila es false, es que tenía letras,
    \   en ese caso, dejar NO_NUM en la pila
    NOT IF DROP NO_NUM THEN
;

\ Pide un número
\   addr1 len1 el texto a mostrar
\   n1 el valor predeterminado si no se escribe un número
\   devuelve un número
\ s" Dime un numero (0 terminar) ? " 0 INPUTN
: INPUTN2   ( addr1 len1 n1 -- n )
    >R
    RESPUESTA MAX_RESP
    PREGUNTA?
    \ Si no se ha escrito nada, poner 0 como respuesta
    RESPUESTA-LEN 0 = 
    \ IF s" 0" RESPUESTA! THEN
    IF R>
    ELSE
        'RESPUESTA to?u
        \ si el top de la pila es false, es que tenía letras,
        \   en ese caso, dejar NO_NUM en la pila
        NOT IF DROP R> ELSE R> DROP THEN
    THEN
;

: prueba-inputn2
    cr s" Dime un numero (0 terminar) ? " 0 INPUTN2
    cr ." Has escrito '" RESPUESTA. ." '"
    'RESPUESTA to?u FALSE = IF ."  y no es un numero." THEN
    cr ." El numero es " .
;

: prueba-inputn
    cr s" Dime un numero? " INPUTN
    cr ." Has escrito '" RESPUESTA. ." '"
    DUP
    NO_NUM = 
    IF DROP ."  y no es un numero."
    ELSE
        cr ." El numero es " .
    THEN
;

\ s" hola mundo" respuesta!
\ respuesta.

: prueba-continuar
    CR s" Si haces esto, tal y tal..."
    RESPUESTA MAX_RESP
    CONTINUAR?
    CR
    ." Tu respuesta ha sido: '" RESPUESTA. ." '" CR
    IF
        ." Empieza por 'S', por tanto, has contestado que sí."
    ELSE
        ." No empieza por 'S', por tanto, has contestado que no."
        ." 
    THEN
    
    \ ." Has contestado "
    \ IF ." sí." ELSE ." que no." THEN CR
    \ ." La respuesta es: '" RESPUESTA. ." '" CR
;

: prueba-pregunta
    CR ." Para conocernos mejor. "
    s" Dime tu nombre y apellidos? " 
    RESPUESTA MAX_RESP
    PREGUNTA?
    CR ." Hola '" RESPUESTA. ." '" CR
    CR ." En mayúsculas " 'RESPUESTA >MAYUSCULAS RESPUESTA.
;

\ Para probar creando arrays con $" y usando NULL, 19-ene-2023
create palabras
    $" palabra-0" ,
    $" palabra-1" ,
    $" palabra-2" ,
    $" palabra-3" ,
    NULL ,

\ Para guardar el número de palabras definidas
-1 VALUE %PALABRAS

: mostrar-palabras-debug
(
    palabras . 2141875272
    palabras @ count type palabra-0 ok
    palabras cell+ @ count type palabra-1 ok
    palabras cell+ cell+ @ count type palabra-2 ok
)
  palabras                             ( a1)
  begin                                ( a1)
    s" despues de begin " debug1
    dup @ NULL =
    s" despues de dup @ NULL = " debug1
    \ si no es null, es una palabra
    not
    IF dup
        s" despues de IF dup " debug1
        @ count cr type true
        s" despues de @ count cr type true " debug1
    ELSE drop false \ que no entre en el while
    THEN
    \ cr drop @ count type
  while                                ( a1 a2 a3)
    s" despues de while " debug1
    cell+              ( a1+2)
    s" antes de repeat " debug1
  repeat                               ( a1 a2 a3)
  \ until
  s" despues de repeat " debug1
;

: mostrar-palabras-begin
  palabras                             ( a1)
  begin                                ( a1)
    dup @ NULL =
    \ si es null, no es una palabra
    IF drop false  \ que no entre en el while
    ELSE dup @ count cr type true  \ que entre en el while
    THEN
  while                                ( a1 a2 a3)
    cell+              ( a1+2)
  repeat                               ( a1 a2 a3)
;

\ Cuenta el número de palabras definidas
\   Si %PALABRAS es mayor que -1 es que ya se contaron
: palabras-len   ( -- n )
    %PALABRAS -1 > IF %PALABRAS EXIT THEN
    0 >R
    palabras
    begin
        dup @ NULL =
        IF DROP FALSE ELSE R> 1+ >R TRUE THEN
    while
        cell+
    repeat
    R>
    DUP TO %PALABRAS
;

: palabras>S   ( index -- )
    \ no pasar del máximo de palabras
    dup 0< if drop 0 then palabras-len 1- min
    palabras swap
    0 ?do cell+ loop
    \ dup 0> IF 0 do cell+ loop else drop then
    
    \ >r
    \ palabras
    \ r> 0 ?do cell+ loop
    \ r> dup 0> IF 0 do cell+ loop else drop then
    @ count
;

: palabras.   ( index -- )
    palabras>s type
;

: mostrar-palabras
    palabras-len 0 do CR I 2 U.R ."  - " I palabras. loop
;

\ Defino estas palabras en util-forth, 19-ene-2023 20.52
\   pero las palabras que no empiezan por null
\ Saber los elementos del array indicado
\   El array debe estar acabado con NULL
\ : ?ARRAY-LEN   ( addr -- n )
\     0 >r
\     begin
\         dup @ null =
\         if drop false else r> 1+ >r true then
\     while
\         cell+
\     repeat
\     r>
\ ;
: NULL-LEN   ?array-len ;

\ La dirección de memoria del índice de un array acabado en null
\   addr la dirección de memoria del array acabado en null
\   index el índice que queremos mostrar
\ : N?ARRAY>S   ( addr index -- addr1 len1 )
\     \ intercambiar los valores y guardar la dirección
\     swap >r
\     \ no pasar del máximo de palabras
\     dup 0< if drop 0 then r@ null-len 1- min
\     \ poner la dirección intercambiar los valores
\     r> swap
\     0 ?do cell+ loop
\     \ dup 0> IF 0 do cell+ loop else drop then
\     @ count
\ ;
: null-array>s n?array>s ;

\ Muestra el contenido del índice indicado de un array acabado en null
\   addr la dirección de memoria del array acabado en null
\   index el índice que queremos mostrar
\ : N?ARRAY.   ( addr index -- )
\     null-array>s type
\ ;
: null-array. n?array. ;

\ Muestra el contenido de un array acabado en null
\ : ?ARRAY.   ( addr -- )
\     dup null-len 0 do CR I 2 U.R ."  - " dup I null-array. loop
\ ;
: mostrar-null-array ?array. ;

: prueba-array-palabras
    cr
    cr ." Usando las definidas con palabras:" cr
    cr ." Todas las palabras:"
    mostrar-palabras cr
    cr ." La palabra con índice 3: " 3 palabras. cr
    
    cr ." Usando las definidas con ?array:" cr
    cr ." Todas las palabras:"
    palabras ?array. cr
    cr ." La palabra con índice 3: " palabras 3 n?array. cr
;

( Esto no funciona bien...

create palabras1
    s" palabra1-0" ,
    s" palabra1-1" ,
    s" palabra1-2" ,
    s" palabra1-3" ,
    NULL ,

create palabras2
    s" palabra2-0" 2,
    s" palabra2-1" 2,
    s" palabra2-2" 2,
    s" palabra2-3" 2,
    NULL ,

\ Saber los elementos del array indicado
\   El array debe estar acabado con NULL y definido con 2,
: NULL-LEN2   \ addr -- n
    0 >r
    begin
        dup @ null =
        if drop false else r> 1+ >r true then
    while
        cell+ cell+
    repeat
    r>
;

: null-array2>s   \ addr index --
    \ no pasar del máximo de palabras
    dup 0< if drop 0 then null-len2 1- min
    >r
    \ addr
    r> 0 ?do cell+ cell+ loop
    \ r> dup 0> IF 0 do cell+ cell+ loop else drop then
    @ count
;

: null-array2.   \ addr index --
    null-array2>s type
;

: mostrar-null-array2   \ addr --
    dup null-len2 0 do CR I 2 U.R ."  - " dup I null-array2. loop
;
)

\ De startend.4th
: starts? dup >r 2over r> min compare 0= ;
: ends? dup >r 2over dup r> - 0 max /string compare 0= ;

\ Comprobar si una cadena empieza y/o termina por otra,
\   se distinguen mayúsculas de minúsculas
\ addr1 len1 la palabra a comprobar
\ addr2 len2 la palabra para si empieza y/o termina
: startend?   ( addr1 len1 addr2 len2 -- )
    2>r
    \ 2dup 
    CR ." La palabra '" type ." '"
    cr ."    "
    \ 2dup
    2r@ starts? if ." sí" else ." no" then ."  empieza por '" 2r@ type ." '"
    cr ."    "
    \ 2dup
    2r@ ends? if ." sí" else ." no" then ."  termina por '" 2r> type ." '"
;

: prueba-startend
    s" hola radi-hola" s" hola" startend?
    s" Ola ola" s" ola" startend? 
    cr .s
;

\ La definición de easy.4th
: PLACE4th   ( addr1 len1 addr2 -- ) OVER OVER C! CHAR+ SWAP MOVE ;
: PLACE2     ( addr1 len1 addr2 -- ) OVER OVER C! CHAR+ 1- SWAP MOVE ;
: PLACE1     ( addr1 len1 addr2 max2 -- ) 2dup blank drop OVER OVER C! CHAR+ 1- SWAP MOVE ;
: PLACE1b    ( addr1 len1 addr2 addr2 max2 -- ) blank OVER OVER C! CHAR+ 1- SWAP MOVE ;

\ Definida en util.forth, 19-ene-2023 20.32
\ copia la primera cadena en la segunda,
\   se indican los caracteres a limpiar de la segunda dirección
\ : PLACE-BLANK   ( addr1 len1 addr2 max2 -- ) 2dup blank drop OVER OVER C! CHAR+ 1- SWAP MOVE ;

\ la definición de gForth
\ : place   ( addr1 len1 addr2 -- ) over >r rot over 1+ r> move c! ;
: place3   ( addr1 len1 addr2 -- ) over >r rot over r> move 1- c! ;

: prueba-place
    respuesta-limpiar
    s" hola radiola!" respuesta 1- place
    cr respuesta.
    respuesta-limpiar
    s" hola radiola" respuesta place2
    cr respuesta.
    \ s" hola radiola" respuesta place3
    \ cr respuesta.
    respuesta-limpiar
    s" helou!" respuesta place2
    cr respuesta.
    
    s" Ole y Olé!" respuesta respuesta max_resp place1b
    cr respuesta.
    s" Hola!" respuesta max_resp place1
    cr respuesta.
    s" Olé!" respuesta max_resp place-blank
    cr respuesta.
    s" Helou!" respuesta!
    cr respuesta.
;

(
include util-pruebas.forth
)

