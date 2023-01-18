( abrir gForth e indicar 
include adivina.forth
)

\ Adivinar un número v1.10 25-dic-2022 23.09

: VERSION   ." Adivina v1.10 (25-dic-2022 23.09) " ;

\ ( 
\ 1- Al INICIAR el juego sacar un número aleatorio entre el 1 y el 100 ambos incluidos.
\ 2- Indicar el número seguido de GUESS o ADIVINA
\ 3- Mostrar si el número en correcto, mayor o menor.
\ 4- HINT o PISTA mostrará los 2 últimos números y si eran mayor o menor.
\ 5- Se podría ampliar para mostrar todos los números introducidos (en un array).
\ 6- En este caso se podría usar PISTAS / HINTS indicando cuántos números mostrar.
\ 7- Para ver la solución RESUELVE, ME-RINDO o GIVE-UP.
\ 8- HELP Muestra las palabras que se pueden usar.
\ )

\ Nuevo en v1.10:
\ 	Si se indica un número mayor del máximo no aceptarlo ni contarlo como intento.

\ Nuevo en v1.9:
\ 	Ajustes al mostrar el nivel después de adivinar el número.

\ Nuevo en v1.8:
\ 	Al final de la ayuda se muestra el nivel actual y el rango del número a adivinar.
\	Usar NIVEL-NUMERO para mostrar el nivel y el rango del número a adivinar

\ Nuevo en v1.7:
\ 	Quito que se muestre el número elegido

\ Nuevo en v1.6:
\	Revisión de lo hecho en v1.5 y algunos ajustes
\ 	random2 para sacar un número aleatorio entre los 2 indicados (ambos inclusive)

\ Nuevo en v1.5:
\ 	Algunos signos de puntuación
\ 	Si se indica 0 NIVEL elegir un nivel aleatorio entre 1 y 9
\	Al iniciar el juego de forma predeterminada, sin indicar el nivel, el nivel será 1.

\ Nuevo en v1.4:
\ 	DEFINIR MAYOR-MENOR para usar en HINT.

\ Nuevo en v1.3:
\ 	En SHOW-CORRECTO si lo adivina a la primera mostrar "intento" en vez de "intentos".
\ 	En HINT mostrar los dos últimos números y si eran mayor o menor.


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

\ v1.6 Un número aleatorio entre los dos indicados, ambos inclusives
: random2 ( n1 n2 -- n )
	( arriba en la pila está n2 por tanto se hará aleatorio entre 0 y n2 - 1)
	( le sumamos el primer número y tenemos un número entre n1 y n2 )
	random + 
;

\ Para comprobar con 10 números aleatorios entre 1 y 9
: test-random2 
	50 0 ?DO 1 9 random2 . LOOP
;

\ El nivel de juego:
\ 1 adivinar un número del 1 al 100
\ 2 adivinar un número del 1 al 200
\ 3 adivinar un número del 1 al 200, etc. hasta 9

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

\ El número máximo de adivinazas )
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
	ELSE ." Te quedan " MAX.NUMS+1 I.N @ - . ." intentos "
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
: HINT   
	( comprobar si no ha indicado aun los dos numeros )
	N.LAST @ 0=  N.ANT @ 0= AND 
	IF ." Aun no has indicado un numero. "
	ELSE 
		( si no ha indicado el últiumo, no mostrar nada )
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
	\ ." El NIVEL actual es: " EL-NIVEL ? ." tienes que adivinar un numero del 1 al " EL-NIVEL @ 100 * .
	." El NIVEL actual es: " EL-NIVEL ? ." tienes que adivinar un numero del 1 al " EL-MAXIMO .
;

\ Para mostrar el mensaje cuando lo adivina 

: SHOW-CORRECTO   
	." Correcto! el numero era " NUM ? ." lo has adivinado en " I.N ? 
	( v1.3 comprobar si es 1 intento o más )
	I.N @ 1 = IF ." intento. " ELSE ." intentos. " THEN CR
	." Para jugar de nuevo escribe JUGAR o INICIAR y seguir con el mismo nivel. " CR
	( v1.9 indicar el nivel y el rango del número a adivinar )
	."     " NIVEL-NUMERO CR
	( v1.5 indicar el rango de números según el nivel )
	."     Para jugar con otro nivel, escribe n NIVEL." CR
	."     Escribe 0 NIVEL para usar un nivel aleatorio entre 1 y 9."
;

\ Adivinar el número
: GUESS   
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
	THEN
;

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
	."     o si n es menor o mayor que el numero a adivinar. " CR
	." Escribe HINT o PISTA y te mostrare los dos ultimos numeros que has indicado. " CR
	." Para ver la solucion escribe RESUELVE, ME-RINDO o GIVE-UP. " CR
	." Para reiniciar el juego escribe INICIAR, JUGAR o RUN "
;

: HELP   
	VERSION CR
	." Escribe n NIVEL ( n del 0 al 9 ) para generar un numero de 1 al n * 100" CR
	."     Escribe 0 NIVEL para generar un nivel aleatorio entre 1 y 9." CR
	."     Al indicar un nivel, se reiniciara el numero a adivinar y los intentos, etc." CR
	HELP2
;

: -H   HELP ;

\ Reiniciar el juego, asignando los valores predeterminados, etc.
: REINICIAR 
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
	CR NIVEL-NUMERO
;

\ Iniciar el juego, poner todos los valores a cero
: INICIAR  
	PAGE
	HELP
	( en reiniciar se muestra el nivel y el rango del número a adivinar )
	REINICIAR
;

: JUGAR   INICIAR ;
: RUN   INICIAR ;

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
	( en REINICIAR, llamado desde INICIAR, se comprueban los valores mínimos y máximos )  
	( si el nivel indicado es cero o menor, se elegirá un nivel aleatorio entre 1 y 9 )
	EL-NIVEL ! 
	( v1.5 si inicia desde aquí, no mostrar que se puede usar NIVEL )
	INICIAR2
;
