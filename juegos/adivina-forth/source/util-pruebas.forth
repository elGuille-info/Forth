\
\ Para probar las palabras (utilidades) de util.forth
\ por Guillermo Som (Guille), 17-ene-2023 16.32
\
\ Para cargar este fichero en una plicación de Forth:
\ include util-pruebas.forth
\

\ Cargar las palabras definidas en util.forth
include util.forth

\ Así se deben definir las cadenas
\ El tamaño máximo depende de cuántos caracteres queramos almacenar
80 CONSTANT MAX_RESP
VARIABLE RESPUESTA MAX_RESP ALLOT

\ La dirección de memoria y longitud
: 'RESPUESTA   ( -- addr len ) RESPUESTA MAX_RESP -TRAILING ;
\ Mostrar el contenido de RESPUESTA
: RESPUESTA.   ( -- ) 'RESPUESTA TYPE ;
\ Asignar el contenido de una cadena en RESPUESTA
: RESPUESTA!   ( addr len -- ) 'RESPUESTA >LIMPIAR RESPUESTA SWAP MOVE ;
\ La longitud actual de RESPUESTA
: RESPUESTA-LEN   ( -- len ) 'RESPUESTA SWAP DROP ;
\ Limpiar el contenido de RESPUESTA con espacios
: RESPUESTA-LIMPIAR   ( -- ) 'RESPUESTA BLANK ;

\ Poner todos los caracteres en blanco (espacios
RESPUESTA MAX_RESP BLANK


\ s" hola mundo" respuesta!
\ respuesta.

: prueba-continuar
    CR s" Si haces esto, tal y tal..."
    RESPUESTA MAX_RESP
    CONTINUAR?
    CR
    ." Has contestado "
    IF ." sí." ELSE ." que no." THEN CR
    ." La respuesta es: '" RESPUESTA. ." '" CR
;

: prueba-pregunta
    CR ." Para conocernos mejor. "
    s" Dime tu nombre y apellidos? " 
    RESPUESTA MAX_RESP
    PREGUNTA?
    CR ." Hola '" RESPUESTA. ." '" CR
    CR ." En mayúsculas " 'RESPUESTA >MAYUSCULAS RESPUESTA.
;

