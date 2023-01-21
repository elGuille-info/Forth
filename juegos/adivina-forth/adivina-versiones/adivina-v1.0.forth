( abrir gForth e indicar 
include adivina.forth
)


\ Adivinar un número v1.0 25-dic-2022

\ ( 
\ 1- Al INICIAR el juego sacar un número aleatorio entre el 1 y el 100 ambos incluidos.
\ 2- Indicar el número seguido de GUESS o ADIVINA
\ 3- Mostrar si el número en correcto, mayor o menor.
\ 4- HINT o PISTA mostrará los 2 últimos números y si eran mayor o menor.
\ 5- Se podría ampliar para mostrar todos los números introducidos (en un array).
\ 6- En este caso se podría usar PISTAS / HINTS indicando cuántos números mostrar.
\ 7- Para ver la solución ME-RINDO / GIVE-UP.
\ 8- HELP Muestra las palabras que se pueden usar.
\ )


\ Las variables a usar

\ Para los números aleatorios

\ Del fichero "C:\Program Files (x86)\gforth\random.fs"
\ Variable seed
\ $10450405 Constant generator
\ : rnd  ( -- n )  seed @ generator um* drop 1+ dup seed ! ;
\ : random ( n -- 0..n-1 )  rnd um* nip ;

\ Adaptado del fichero "C:\Program Files (x86)\gforth\tt.fs"
\ stupid random number generator

variable seed
: randomize   time&date + + + + + seed ! ;

$10450405 Constant generator
: rnd  ( -- n )  seed @ generator um* drop 1+ dup seed ! ;
: random ( n -- 0..n-1 )  rnd um* nip ;



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


\ Incrementar los números adivinados y guardarlo en el array
\ Si se pasa del máximo, poner el contador a cero
\ : INC.I.N   I.N @ MAX.NUMS+1 >= IF 0 I.N ! ELSE I.N @ 1 + I.N ! THEN ;

\ Incrementa el contador y si se pasa del máximo mostrar la solución
\ : INC.I.N   I.N @ MAX.NUMS+1 >= 
\ 	IF ." Muchos intentos, la solucion es " NUM . 
\ 	ELSE I.N @ 1 + I.N ! 
\	THEN ;


\ Incrementar el número de intentos sin más comprobaciones
: INC.I.N   I.N @ 1 + I.N ! ;

\ Comprobar si quedan intentos, si no, mostrar la solución
: QUEDAN-INTENTOS   
	I.N @ MAX.NUMS+1 >= 
	IF ." Muchos intentos, la solucion es " NUM . 
	ELSE ." Te quedan " MAX.NUMS+1 I.N @ - . ." intentos "
	THEN
	\ CR
;


\ Array para los números indicados de 0 a MAX.NUMS )
VARIABLE NUMS MAX.NUMS CELLS ALLOT 

\ Mostrar los dos ultimos numeros indicados ( si se han indicado ) 
: HINT   
	( comprobar si no ha indicado aun los dos numeros )
	N.LAST @ 0=  N.ANT @ 0= AND 
	IF ." Aun no has indicado un numero "
	ELSE 
		( si no ha indicado el últiumo, no mostrar nada )
		N.LAST @ 0 > 
		IF ." Ultimo numero indicado es " N.LAST ?
		THEN
		( si no ha indicado el penúltiumo, no mostrar nada )
		N.ANT @ 0 > 
		IF ." El Penultimo numero indicado es " N.ANT ? 
		THEN
	THEN ;
\ PISTA lo mismo que HINT
: PISTA   HINT ;

\ Adivinar el número
: GUESS   
	DUP DUP ( hacer dos copias para comprobar y asignar el último )
	INC.I.N ( incrementar el número de intentos )
	NUM @ = ( si lo ha adivinado )
	IF ." Correcto! el numero era " . ." lo has adivinado en " I.N ? ." intentos " CR
	." Para jugar de nuevo escribe JUGAR o INICIAR. "
	ELSE 
		NUM @ < ( si es menor )
		IF ." Tu numero es menor "
		ELSE ." Tu numero es mayor "
		THEN 
		\ ." Llevas " I.N ? ." intentos "
		QUEDAN-INTENTOS ( mostrar los intentos que quedan o la solución )
	THEN 
	N.LAST @ N.ANT ! ( asignar el último al penúltimo )
	N.LAST ! ( asignar el número indicado al último )
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

\ Iniciar el juego, poner todos los valores a cero
: INICIAR  
	PAGE
	." Adivina un numero del 1 al 100 " CR
	." Escribe n GUESS y te dire si lo has acertado. " CR
	."     o si n es menor o mayor que el numero a adivinar. " CR
	." Escribe HINT o PISTA y te mostrare los dos ultimos numeros que has indicado. " CR
	." Para ver la solucion escribe RESUELVE, ME-RINDO o GIVE-UP. "
	( iniciar la semilla del número aleatorio )
	randomize
	( asignar un número aleatorio entre 1 y 100 )
	100 random ( un número de 0 a 99 ) 
	1 + NUM ! ( el número será entre 1 y 100 )
	( asignar los valores de las variables, etc. )
	0 N.LAST ! ( asignar el valor cero )
	0 N.ANT !  ( asignar el valor cero )
	0 I.N ! ( asignar cero al contador de números indicados )
	NUMS MAX.NUMS+1 CELLS ERASE ( asignar ceros al array de números indicados )
;

: JUGAR   INICIAR ;
