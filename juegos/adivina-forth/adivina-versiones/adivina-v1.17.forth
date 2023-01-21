( abrir gForth e indicar 
include adivina.forth
)

\ Adivinar un número v1.17 26-dic-2022 16.51

: VERSION   ." Adivina v1.17 (26-dic-2022 16.51) " ;

\ Nuevo en v1.17:
\ 	En HINT simplifico el texto a mostrar.
\		Mostrando también los intentos que quedan.
\	Quito las comprobaciones que puse de:
\ 		Si se indica un número mayor que el mayor más cercano, no tenerlo en cuenta.
\		Lo mismo si se indica uno menor que el menor más cercano.
\	Ya que tal como estaba lo hacía bien.

\ TODO:
\	Guardar el número de intentos más bajo al adivinar el número en cada nivel.
\		Esto hay que guardarlo en un array.
\	JUGAR-SOLO para que el programa adivine el número, sin hacer tampas.
\		Irá mostrando el número adivinado y actuará según sea menor o mayor.
\		El proceso será indicando un número entre el mayor y el menor que haya indicado.
\		Por ejemplo, si tiene que adivinar entre 1 y 500 empezará por 250.
\		Si el numero es menor, usará 250 / 2 como el siguiente.
\		Si el numero es mayor, usará 500 - 250 / 2 como el siguiente.


\ Las variables a usar

\ Para los números aleatorios
\ Adaptado del fichero "C:\Program Files (x86)\gforth\tt.fs"
\ stupid random number generator

variable seed
( time&date pone en la pila s m h d M y )
: randomize   time&date + + + + + seed ! ;

$10450405 Constant generator
: rnd  ( -- n )  seed @ generator um* drop 1+ dup seed ! ;
: random ( n -- 0..n-1 )  rnd um* nip ;

\ v1.14 Un número aleatorio entre los dos indicados, ambos inclusives
VARIABLE r1 
VARIABLE r2
: random2 ( n1 n2 -- n n estará será un número entre n1 y n2 inclusive )
	r2 ! ( asignamos el segundo numero )
	r1 ! ( asignamos el primer numero )
	( sacar un número aleatorio entre 0 y n2-n1 )
	r2 @ r1 @ - 1 +
	( random será entre 0 y n2-n1 si no se le suma 1, sería entre 0 y n2-n1 -1 )
	random 
	( le sumamos el primero )
	r1 @ +
;

\ Los números según el nivel de juego:
\ 1 adivinar un número del 1 al 100
\ 2 adivinar un número del 1 al 200
\ etc. hasta 9 que será del 1 al 900.

\ v1.5 el valor predeterminado del nivel es 1
VARIABLE EL-NIVEL 1 EL-NIVEL !

\ Iniciar el nivel con un valor aleatorio entre 1 y 9
: NIVEL-RANDOM   
	( un número entre 1 y 9)
	\ v1.6 usando random2
	1 9 random2 
	EL-NIVEL !
;

\ El número a adivinar 
VARIABLE NUM 
\ El último número indicado 
VARIABLE N.LAST 
\ El penúltimo número indicado 
VARIABLE N.ANT  

\ v1.15 para los valores más cercanos
VARIABLE N.MENOR ( El menor más cercano )
VARIABLE N.MAYOR ( El mayor más cercano )
\ Asignar a N.MENOR o N.MAYOR el que corresponda
: CERCANOS 
	( N.LAST tiene el último número asignado )
	( Comprobar si N.LAST es menor que el número )
	( Hacer copia del número para asignarlo después al menor o mayor )
	N.LAST @ DUP 
	NUM @ < ( si el último es menor que el número a adivinar )
	IF N.MENOR !   ( asignar N.LAST al menor )
	ELSE N.MAYOR ! ( asignar N.LAST al mayor )
	THEN
;

\ El número máximo de adivinazas 
99 CONSTANT MAX.NUMS 

\ El total de celdas en MAX.NUMS: MAX.NUMS + 1
: MAX.NUMS+1  ( -- MAX.NUMS + 1 ) 1 MAX.NUMS + ; 

\ El número de orden actual de los números indicados, máximo será MAX.NUMS 
VARIABLE I.N 

\ Incrementar el número de intentos sin más comprobaciones
: INC.I.N   I.N @ 1 + I.N ! ;

\ Comprobar si quedan intentos, si no, mostrar la solución
: QUEDAN-INTENTOS   
	I.N @ MAX.NUMS+1 >= 
	IF ." Muchos intentos, la solucion es " NUM ? 
	ELSE \ ." Te quedan " MAX.NUMS+1 I.N @ - . ." intentos "
		( v1.13 mostrar los intentos que lleva y los que quedan )
		( con el plural correcto según sea 1 o más )
		." Llevas " I.N ?
		I.N @ 1 = 
		IF ." intento, " ELSE ." intentos, " THEN ." te "
		MAX.NUMS+1 I.N @ - 1 = 
		IF ." queda 1. " 
		ELSE ." quedan " MAX.NUMS+1 I.N @ - . 
		THEN 
	THEN
;

\ Array para los números indicados de 0 a MAX.NUMS )
VARIABLE NUMS MAX.NUMS CELLS ALLOT 

: MAYOR-MENOR ( n -- indicar si es mayor o menor que el número a adivinar )
	NUM @ <
	IF ." (era menor) "
	ELSE ." (era mayor) "
	THEN 
;

\ Mostrar los dos ultimos numeros indicados ( si se han indicado ) 
\ v1.3 Al mostrar los números, indicar si era mayor o menor
\ v1.4 Usar MAYOR-MENOR para mostrar si era mayor o menor
\ v1.17 simplificar el texto
: HINT   
	( v1.17 mostrar los números más cercanos indicados )
	( si es la primera vez, mostrará 1 y el máximo a adivinar )
	." El numero a adivinar esta entre " N.MENOR ? 
	." y " N.MAYOR ? CR
	."      " QUEDAN-INTENTOS
;

: HINT.ANT  
	( comprobar si no ha indicado aun los dos numeros )
	N.LAST @ 0=  N.ANT @ 0= AND 
	IF ." Aun no has indicado un numero. "
	ELSE 
		( si no ha indicado el último, no mostrar nada )
		N.LAST @ 0 > 
		IF ." Ultimo numero indicado es " N.LAST ?
			( indicar si era mayor o menor )
			N.LAST @ MAYOR-MENOR
		THEN
		( si no ha indicado el penúltiumo, no mostrar nada )
		N.ANT @ 0 > 
		IF ." El Penultimo numero indicado es " N.ANT ? 
			( indicar si era mayor o menor )
			N.ANT @ MAYOR-MENOR
		THEN
		( v1.15 mostrar los números más cercanos indicados )
		( se supone que aquí ya se ha indicado alguno )
		CR ."     El numero a adivinar esta entre " N.MENOR ? 
		." y " N.MAYOR ?
	THEN
;

\ PISTA lo mismo que HINT
: PISTA   HINT ;

\ v1.10 El número máximo a adivinar 
: EL-MAXIMO 
	EL-NIVEL @ 100 *
;

\ v1.8 mostrar el nivel y el número a adivinar.
\ v1.10 usar EL-MAXIMO para el número máximo a adivinar
: NIVEL-NUMERO 
	\ ." El NIVEL actual es: " EL-NIVEL ? ." tienes que adivinar un numero del 1 al " EL-MAXIMO .
	( v1.13 mostrar el máximo con 3 posiciones para añadir un punto sin separador )
	." El NIVEL actual es: " EL-NIVEL ? 
	\ Nota: "EL-MAXIMO 0" es para convertirlo en número doble ya que D.R usa un número doble.
	." tienes que adivinar un numero del 1 al " EL-MAXIMO 0 3 D.R ." . "
;

\ Para mostrar el mensaje cuando lo adivina 

: SHOW-CORRECTO   
	." Correcto! el numero era " NUM ? ." lo has adivinado en " I.N ? 
	( v1.3 comprobar si es 1 intento o más )
	I.N @ 1 = IF ." intento. " ELSE ." intentos. " THEN CR
	\ v 1.13 mostrar RUN también para iniciar otra partida.
	." Para jugar de nuevo escribe RUN o JUGAR y seguir con el mismo nivel. " CR
	( v1.9 indicar el nivel y el rango del número a adivinar )
	."     " NIVEL-NUMERO CR
	( v1.5 indicar el rango de números según el nivel )
	."     Para jugar con otro nivel, escribe n NIVEL." CR
	."     Escribe 0 NIVEL para usar un nivel aleatorio entre 1 y 9." CR
	."     Puedes usar indistintamente NIVEL o LEVEL."
;

\ Adivinar el número
: GUESS   
	DUP ( para la comprobación si se ha pasado del máximo )
	DUP DUP ( hacer dos copias para comprobar y asignar el último )
	\ v1.10 comprobar si el número es mayor del máximo
	\ 	Si es así, avisar y no tenerlo en cuenta
	EL-MAXIMO >
	IF ." El numero indicado es mayor que el maximo (" EL-MAXIMO . ." )" 
	ELSE
		INC.I.N ( incrementar el número de intentos )
		NUM @ = ( si lo ha adivinado )
		IF SHOW-CORRECTO
		ELSE 
			NUM @ < ( si es menor )
			IF ." Tu numero es menor. "
			ELSE ." Tu numero es mayor. "
			THEN 
			QUEDAN-INTENTOS ( mostrar los intentos que quedan o la solución )
		THEN 
		N.LAST @ N.ANT ! ( asignar el último al penúltimo )
		N.LAST ! ( asignar el número indicado al último )
		\ Asignar el último número al menor o mayor más cercano
		CERCANOS
	THEN
;

\ G lo mismo que GUESS
: G  GUESS ;
\ ADIVINA lo mismo que GUESS
: ADIVINA   GUESS ;

\ Resolver el juego ( ver la solución )
: RESUELVE   
	." Te quedaban " MAX.NUMS+1 I.N @ - . ." intentos. "
	." El numero que tenias que adivinar era el " NUM ?
;

: ME-RINDO   RESUELVE ;
: GIVE-UP   RESUELVE ;

\ Mostrar la ayuda / inicio del programa con las palabras a usar

\ No mostrar que se puede usar el nivel, para mostrar esta ayuda desde NIVEL
: HELP2   
	." Escribe n GUESS y te dire si lo has acertado. " CR
	."     o si el numero indicado es menor o mayor que el numero a adivinar. " CR
	." Escribe HINT o PISTA y te mostrare los dos ultimos numeros que has indicado. " CR
	." Para ver la solucion escribe RESUELVE, ME-RINDO o GIVE-UP. " CR
	." Para reiniciar el juego escribe JUGAR o RUN. "
;

: HELP1   
	VERSION CR
	." Escribe n NIVEL ( n del 0 al 9 ) para generar un numero de 1 al n * 100." CR
	."     Escribe 0 NIVEL para generar un nivel aleatorio entre 1 y 9." CR
	."     Puedes usar indistintamente NIVEL o LEVEL." CR
	."     Al indicar un nivel, se reiniciara el numero a adivinar y los intentos, etc." CR
	HELP2
;

\ Reiniciar el juego, asignando los valores predeterminados, etc.
: REINICIAR 
	( v1.2 limpiar las pilas, no limpia los valores de las variables, etc. )
	clearstacks
	( iniciar la semilla del número aleatorio )
	randomize
	( v1.5 si el nivel es menor de 1, asignar un nivel aleatorio entre 1 y 9 )
	EL-NIVEL @ 0 <= IF NIVEL-RANDOM  THEN
	( si el nivel es mayor de 9, asignar 9 )
	EL-NIVEL @ 9 > IF 9 EL-NIVEL !  THEN
	( asignar un número aleatorio entre 1 y NIVEL * 100 )
	\ v1.6 Usando random2
	1 100 EL-NIVEL @ * random2 NUM !
	\ ." El numero a adivinar es " NUM ?
	( asignar los valores de las variables, etc. )
	0 N.LAST ! ( asignar el valor cero )
	0 N.ANT !  ( asignar el valor cero )
	0 I.N ! ( asignar cero al contador de números indicados )
	NUMS MAX.NUMS+1 CELLS ERASE ( asignar ceros al array de números indicados )
	( v1.15 asignar los valores predeterminados al menor y mayor más cercanos )
	( v1.16 inicialmente serán el 1 y el máximo )
	1 N.MENOR ! EL-MAXIMO N.MAYOR !
	CR NIVEL-NUMERO
;

\ Iniciar el juego, poner todos los valores a cero
: JUGAR  
	PAGE
	HELP1
	( en reiniciar se muestra el nivel y el rango del número a adivinar )
	REINICIAR
;

: RUN   JUGAR ;

\ Para no mostrar en la ayuda que se puede usar NIVEL 
\ Este INICIAR se llamará desde NIVEL
: INICIAR2  
	PAGE
	VERSION CR
	HELP2
	( en reiniciar se muestra el nivel y el rango del número a adivinar )
	REINICIAR
;

\ Asignar el nivel, y reiniciar los valores y mostrar la ayuda, etc.
: NIVEL 
	( en REINICIAR, llamado desde JUGAR, se comprueban los valores mínimos y máximos )  
	( si el nivel indicado es cero o menor, se elegirá un nivel aleatorio entre 1 y 9 )
	EL-NIVEL ! 
	( v1.5 si inicia desde aquí, no mostrar que se puede usar NIVEL )
	INICIAR2
;

\ v1.14 LEVEL como NIVEL
: LEVEL   NIVEL ;

NIVEL-RANDOM ( v1.14 iniciar con un nivel aleatorio )
JUGAR ( v1.11 iniciar el juego )
