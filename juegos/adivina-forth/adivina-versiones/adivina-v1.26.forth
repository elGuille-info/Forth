( abrir gForth e indicar 
include adivina.forth
)

\ Adivinar un número v1.26 27-dic-2022 19.23

: VERSION   ." Adivina v1.26 (27-dic-2022 19.23) " ;

\ Nuevo en v1.26:
\	En GUESS se guarda el valor indicado en la posición I.N - 1 
\		porque el índice del array empieza por cero.
\	NUMS! para asignar un valor en el índice de NUMS: n index# NUMS!
\ 	MAX.NUMS+1 ahora devuelve MAX.INTENTOS, antes le sumaba 1
\	No muestra bien los intentos que lleva y los que quedan.
\	Corregir el último intento en GUESS (da la solución cuando aún queda 1 )
\		Tenía I.N @ MAX.INTENTOS @ >= y debía ser I.N @ MAX.INTENTOS @ >

\ Nuevo en v1.25:
\	DIFICULTAD (antes NIVEL-JUEGO) para indicar el nivel de dificultad.
\ 		Asigna el número máximo de intentos, 
\ 		Comprueba si el valor del nivel de dificultad está en rango.
\ 		Asigna el valor de máximo intentos y muestra info del nivel de dificultad.
\	DIFICULTAD! asigna el nivel de dificultad indicado y llamar a DIFICULTAD.
\	DIFICULTAD.N Para acceder al número de intentos del nivel indicado.
\	DIFICULTAD? Devuelve una cadena según el nivel de dificultad 
\ 		Con el texto y el valor de los intentos 
\	Usar un nivel de dificultad para indicar cuántos intentos se le da.
\		0-MUY-FACIL	50
\		1-FACIL		30
\		2-NORMAL	15
\		3-MEDIO		12
\		4-DIFICIL	 8
\		5-EXPERTO	 6
\		6-MASTER	 4
\	MAX.NUMS+1 será el valor de MAX.INTENTOS + 1
\	MAX.INTENTOS será el número máximo de intentos.
\		Se asignará según el nivel de dificultad.
\	SHOW-INSTRUCCIONES muestra las instrucciones después de 
\	adivinar el número o mostrar el que era por si ha pasado el número de intentos.
\	Defino las palabras para manejar el array de NUMS.
\	NUMS+ indicará la posición a asignar que esté en la pila.
\	NUMS-CLEAR borra el contenido del array NUMS.
\	MOSTRAR-NUMS muestra el contenido del array NUMS.

\ Nuevo en v1.24:
\	Defino N.G y N.G? para elegir automáticamente el número recomendado.
\		N.G? lo muestra
\	Defino NEXT? para asignarlo y mostrarlo (lo muestra y lo deja en la pila)
\	N.NEXT lo definí como NEXT, pero NEXT está definido en gForth.
\	Defino N.NEXT para poner en la pila el siguiente número que debería elegir.
\		Media = (Mayor - Menor) / 2
\		Siguiente = Menor + Media
\	N.NEXT se podrá usar para cuando juegue en modo automático.
\	Mostrarlo mediante HINT? o en el mismo HINT.

\ TODO:
\	Definir las palabras para manejar el array de NUMS.
\		Asignar el número indicado en la siguiente posición
\		Mostrarlos con la indicación si era mayor o menor.
\	Guardar los intentos de cada partida con el nivel.
\ 	Guardar los números indicados en el array y poder mostrarlos.
\		Indicando si era mayor o menor.
\	Guardar el número de intentos más bajo al adivinar el número en cada nivel.
\		Esto hay que guardarlo en un array.
\	JUGAR-SOLO para que el programa adivine el número, sin hacer tampas.
\		Irá mostrando el número adivinado y actuará según sea menor o mayor.
\		El proceso será indicando un número entre el mayor y el menor que haya indicado.
\		Por ejemplo, si tiene que adivinar entre 1 y 500 empezará por 250.
\		Si el numero es menor, usará 250 / 2 como el siguiente.
\		Si el numero es mayor, usará 500 - 250 / 2 como el siguiente.


\ Las palabras y variables a usar

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

( muestra un número sencillo como cadena )
: STR ( n -- d como cadena ) 0 <# #S #> TYPE ;

\ Los números según el nivel de juego:
\ 1 adivinar un número del 1 al 100
\ 2 adivinar un número del 1 al 200
\ etc. hasta 9 que será del 1 al 900.

\ v1.5 el valor predeterminado del nivel es 1
VARIABLE EL-NIVEL 1 EL-NIVEL !

\ Iniciar el nivel con un valor aleatorio entre 1 y 9
: NIVEL-RANDOM   1 9 random2 EL-NIVEL ! ;

\ El número a adivinar 
VARIABLE NUM 
\ El último número indicado 
VARIABLE N.LAST 

: MAYOR-MENOR ( n -- indicar si es mayor o menor que el número a adivinar )
	NUM @ <
	IF ." (era menor) "
	ELSE ." (era mayor) "
	THEN 
;

\ El número máximo de adivinazas ( 51 = de 0 a 50 )
\ Aunque se usará siempre MAX.INTENTOS, esto solo define el máximo para el array NUMS.
51 CONSTANT MAX.NUMS 

\ El número de intentos máximos, será según el nivel de dificultad
VARIABLE MAX.INTENTOS MAX.NUMS MAX.INTENTOS !

\ Costantes para el nivel de dificultad
0 CONSTANT MUY-FACIL ( 50 )
1 CONSTANT FACIL     ( 30 )
2 CONSTANT NORMAL    ( 15 )
3 CONSTANT MEDIO     ( 12 )
4 CONSTANT DIFICIL   (  8 )
5 CONSTANT EXPERTO   (  6 )
6 CONSTANT MASTER    (  4 )

\ Asigna el nivel de dificultad según la dificultad indicada
: DIFICULTAD.N
  	CASE 
  		MUY-FACIL OF 50 ENDOF
  		FACIL     OF 30 ENDOF
  		NORMAL    OF 15 ENDOF
  		MEDIO     OF 12 ENDOF
  		DIFICIL   OF  8 ENDOF
  		EXPERTO   OF  6 ENDOF
  		MASTER    OF  4 ENDOF
  	ENDCASE
;

\ Devuelve una cadena según el nivel de dificultad 
\ Con el texto y el valor de los intentos 
: DIFICULTAD?
	DUP
 	CASE 
 		MUY-FACIL OF ." muy facil " ENDOF
 		FACIL     OF ." facil " ENDOF
 		NORMAL    OF ." normal " ENDOF
 		MEDIO     OF ." medio " ENDOF
 		DIFICIL   OF ." dificil " ENDOF
 		EXPERTO   OF ." experto " ENDOF
 		MASTER    OF ." master " ENDOF
 	ENDCASE
 	." ( con " DIFICULTAD.N . ." intentos) "
;

VARIABLE NIVEL.D -1 NIVEL.D !

\ Comprueba si el valor del nivel de dificultad está en rango.
\ Muestra el nivel de dificultado asignado a NIVEL.D
: DIFICULTAD-MOSTRAR
	( comprobar si está asignado el nivel correcto de juego )
	NIVEL.D @ MUY-FACIL < NIVEL.D @ MASTER > OR
	( asignar MUY-FACIL si no es un valor entre MUY-FACIL y MASTER )
	IF MUY-FACIL NIVEL.D ! THEN
	NIVEL.D @ DIFICULTAD.N MAX.INTENTOS !
	." El nivel de dificultad es "
	NIVEL.D @ DIFICULTAD? 
;

\ Asigna el nivel de dificultad, el número máximo de intentos y
\ muestra info del nivel de dificultad.
: DIFICULTAD
	NIVEL.D !
	DIFICULTAD-MOSTRAR
;

\ El total de celdas en MAX.NUMS: MAX.NUMS + 1
\ : MAX.NUMS+1  ( -- MAX.NUMS + 1 ) 1 MAX.NUMS + ; 
\ v1.25 el máximo será el valor de MAX-INTENTOS + 1
\ v1.26 en realidad el máximo de intentos es MAX.INTENTOS
\ : MAX.NUMS+1  ( -- MAX.INTENTOS + 1 ) 1 MAX.INTENTOS @ + ; 
: MAX.NUMS+1  ( -- MAX.INTENTOS + 1 ) MAX.INTENTOS @ ; 

\ Array para los números indicados de 0 a MAX.NUMS )
VARIABLE NUMS MAX.NUMS CELLS ALLOT 

\ Borrar el contenido del array NUMS
\ Se borran todos los valores aunque se usen menos
: NUMS-CLEAR   NUMS MAX.NUMS 1 + CELLS ERASE ;

\ La posición indicada para acceder al array NUMS
\ La posición INDEX# del array 
: NUMS+   ( INDEX# -- addr ) CELLS NUMS + ;

\ Asignar a NUMS el valor en el índice indicado
\ 	Asignar el número 3 a la posición 4 del array:
\ 	3 4 NUMS!
: NUMS!   ( n INDEX# -- ) NUMS+ ! ;

\ Mostrar el contenido del array NUMS
: MOSTRAR-NUMS
	CR
	."  Intento -   Numero  (mayor-menor) "
	MAX.INTENTOS @ 0 
	DO 
		I NUMS+ @ DUP
		CR
		( mostrar si es menor o mayor que el número que había que adivinar )
		1 I + 5 U.R ."     - " 7 U.R ."    " MAYOR-MENOR
	LOOP 
;

: NUMS?   MOSTRAR-NUMS ;

\ El número de orden actual de los números indicados, máximo será MAX.NUMS 
\ o MAX.INTENTOS si se juega con nivel de dificultad.
VARIABLE I.N 

\ Incrementar el número de intentos sin más comprobaciones
: INC.I.N   I.N @ 1 + I.N ! ;

\ v1.15 para los valores más cercanos
VARIABLE N.MENOR ( El menor más cercano )
VARIABLE N.MAYOR ( El mayor más cercano )

\ v1.24 Poner en la pila el siguiente número a comprobar.
\	Media = (Mayor - Menor) / 2
\	Siguiente = Menor + Media
\	El valor devuelto es el número sin decimales: 14.5 -> 14
\ En gForth está definido NEXT, pero no en SwiftForth
: N.NEXT   ( -- N.MAYOR N.MENOR - 2 / N.MENOR + )
	N.MAYOR @ N.MENOR @ - 2 / N.MENOR @ +
;
: NEXT?   N.NEXT DUP . ;

\ v1.19 El rango del número a adivinar
\ Si está entre 48 y 50 solo hay una posibilidad, el 49
\ Si está entre 47 y 50 hay 2 posibilidades: 48 y 49
: N.POSIBLES   N.MAYOR @ 1 - N.MENOR @ - ;

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

\ Comprobar si quedan intentos, si no, mostrar la solución
: QUEDAN-INTENTOS   
	( v1.26 MAX.NUMS+1 ahora es MAX.INTENTOS @ no se suma 1 )
	I.N @ MAX.NUMS+1 >= 
	IF ." Muchos intentos, la solucion es " NUM ? 
	ELSE
		( v1.13 mostrar los intentos que lleva y los que quedan )
		( con el plural correcto según sea 1 o más )
		." Llevas " I.N ?
		I.N @ 1 = 
		IF ." intento, " ELSE ." intentos, " THEN ." te "
		\ MAX.NUMS+1 I.N @ - 1 = 
		( v1.26 para saber los intentos que quedan, usar MAX.INTENTOS @ )
		( v1.26 MAX.NUMS+1 ahora no suma 1 a MAX.INTENTOS )
		MAX.NUMS+1 I.N @ - 1 = 
		IF ." queda 1. " 
		( v1.18 convertir en cadena y añadir un punto al final )
		ELSE ." quedan " MAX.NUMS+1 I.N @ - STR ." ." 
		THEN 
	THEN
;

\ v1.10 El número máximo a adivinar 
: EL-MAXIMO   ( -- EL-NIVEL * 100 ) EL-NIVEL @ 100 * ;

\ v1.8 mostrar el nivel y el número a adivinar.
\ v1.10 usar EL-MAXIMO para el número máximo a adivinar
: NIVEL-NUMERO 
	." El NIVEL actual es: " EL-NIVEL ? 
	." tienes que adivinar un numero del 1 al " EL-MAXIMO STR ." ."
;

: SHOW-INSTRUCCIONES 
	\ v 1.13 mostrar RUN también para iniciar otra partida.
	." Para jugar de nuevo escribe RUN o JUGAR y seguir con el mismo nivel. " CR
	( v1.9 indicar el nivel y el rango del número a adivinar )
	."     " NIVEL-NUMERO CR
	( v1.5 indicar el rango de números según el nivel )
	."     Para jugar con otro nivel, escribe n NIVEL." CR
	."     Escribe 0 NIVEL para usar un nivel aleatorio entre 1 y 9." CR
	."     Puedes usar indistintamente NIVEL o LEVEL." CR
	( v1.25 mostrar info del nivel de dificultad )
	." Escribe n DIFICULTAD para cambiar el nivel de dificultad "
	."  (n debe ser un valor entre MUY-FACIL 0 a EXPERTO 6 ) " CR
	( mostrar el nivel actual de juego )
	DIFICULTAD-MOSTRAR
;

\ Para mostrar el mensaje cuando lo adivina 
: SHOW-CORRECTO   
	." Correcto! el numero era " NUM ? ." lo has adivinado en " I.N ? 
	( v1.3 comprobar si es 1 intento o más )
	I.N @ 1 = IF ." intento. " ELSE ." intentos. " THEN CR
	SHOW-INSTRUCCIONES
;

\ Las comprobaciones en GUESS:
\	Si el número indicado no está entre los "posibles" avisar y no asignarlo.
\	Si el número indicado es mayor del máximo avisar y no asignarlo.

\ v1.23 Usar una variable para el número indicado
\	Con idea de no tener que duplicar el número indicado y usar ese valor en las comprobaciones.
VARIABLE N.GUESS 

\ v1.23 comprobar si el número indicado es aceptable.
\	Devuelve FALSE si no se acepta el número.
: GUESS?   ( -- true o false según sea aceptado o no )
	\ v1.23 Si el número es menor que 1, avisar y no tenerlo en cuenta.
	N.GUESS @ 0 <=
	IF ." El numero debe ser mayor que cero. " FALSE
	ELSE
		\ v1.10 comprobar si el número es mayor del máximo
		\ 	Si es así, avisar y no tenerlo en cuenta
		N.GUESS @ EL-MAXIMO >
		( v1.19 usar STR para mostrar el numero )
		IF ." El numero indicado es mayor que el maximo (" EL-MAXIMO STR ." )" FALSE
		ELSE
			( v1.23 Si el número es mayor que el menor o menor que el mayor )
			( no aceptarlo y mostrar un aviso )
			N.GUESS @ N.MENOR @ < ( si el número es menor que el menor indicado )
			IF ." El numero indicado es menor que el menor indicado hasta ahora (" N.MENOR @ STR ." )" 
				FALSE
			ELSE
				N.GUESS @ N.MAYOR @ > ( si el número es mayor que el mayor indicado )
				IF ." El numero indicado es mayor que el mayor indicado hasta ahora (" N.MAYOR @ STR ." )" 
					FALSE
				ELSE
					TRUE
				THEN
			THEN
		THEN
	THEN
;

\ Comprobar si adivina el número.
: GUESS   
	( v1.23 asignar el número indicado a N.GUESS )
	N.GUESS !
	GUESS? ( v1.23 devuelve FALSE si no se acepta el número )
	IF 
		( v1.25 Si se ha pasado del número de intentos )
		I.N @ MAX.INTENTOS @ >
		IF 
			( indicarlo y mostrar la solución )
			." Ya no te quedan intentos el numero era " NUM @ STR ." ." CR
			SHOW-INSTRUCCIONES
		ELSE
			INC.I.N ( incrementar el número de intentos )
			( v1.26 guardar el número en el array después de incrementar )
			( pero restando uno ya que el índice es en base cero )
			N.GUESS @ I.N @ 1 - NUMS!
			N.GUESS @ NUM @ = ( si lo ha adivinado )
			IF SHOW-CORRECTO
			ELSE 
				N.GUESS @  NUM @ < ( si es menor )
				IF ." Tu numero es menor. "
				ELSE ." Tu numero es mayor. "
				THEN 
				QUEDAN-INTENTOS ( mostrar los intentos que quedan o la solución )
			THEN 
			N.GUESS @ N.LAST ! ( asignar el número indicado al último )
			\ Asignar el último número al menor o mayor más cercano
			CERCANOS
		THEN
	THEN
;

\ v1.15 G lo mismo que GUESS
: G  GUESS ;
: ADIVINA   GUESS ;

( v1.24 Para elegir el siguiente número recomendado )
: N.G   N.NEXT GUESS ;
: N.G?   NEXT? GUESS ;

\ Resolver el juego ( ver la solución )
: RESUELVE   
	." Te quedan " MAX.NUMS+1 I.N @ - . ." intentos. "
	." El numero a adivinar es " NUM @ STR ." ."
;

: ME-RINDO   RESUELVE ;
: GIVE-UP   RESUELVE ;
\ v1.22 RES es como RESUELVE antes era R
: RES   RESUELVE ;

\ Mostrar la ayuda / inicio del programa con las palabras a usar

\ No mostrar que se puede usar el nivel, para mostrar esta ayuda desde NIVEL
: HELP2   
	." Escribe n GUESS y te dire si lo has acertado." CR
	."     o si el numero indicado es menor o mayor que el numero a adivinar." CR
	( v1.19 nuevo texto para HINT )
	." Escribe HINT o PISTA y te mostrare como de cerca estas de adivinar el numero." CR
	." Para ver la solucion escribe RESUELVE, ME-RINDO o GIVE-UP." CR
	." Para reiniciar el juego escribe JUGAR o RUN. " CR
	( v1.25 mostrar info del nivel de dificultad )
	." Escribe n DIFICULTAD para cambiar el nivel de dificultad "
	."  (n debe ser un valor entre MUY-FACIL 0 a EXPERTO 6 ) " CR
	( mostrar el nivel actual de juego )
	DIFICULTAD-MOSTRAR
;

: HELP1   
	VERSION CR
	." Escribe n NIVEL ( n del 0 al 9 ) para generar un numero de 1 al n * 100." CR
	."     Escribe 0 NIVEL para generar un nivel aleatorio entre 1 y 9." CR
	."     Puedes usar indistintamente NIVEL o LEVEL." CR
	."     Al indicar un nivel, se reiniciara el numero a adivinar y los intentos, etc." CR
	HELP2
;

( v1.20 defino todo esto después de HELP1 y HELP2 porque en HINT se usa HELP1 )

\ v1.19 mostrar textos según las posibilidades que tenga de adivinarlo.
: HUMOR-HINT 
	( Solo mostrar mensajes si es menor de 6 )
	N.POSIBLES 6 <
	IF ."      " 
		N.POSIBLES 1 = ( solo tiene un número que poner, ej. está entre 15 y 17 ) 
		IF ." Si no lo adivinas ahora no se que hacer contigo."
		ELSE
			N.POSIBLES 2 = ( ej. está entre 15 y 18 solo tiene 2 números que probar )
			IF ." Tienes el 50% de posibilidades de adivinarlo."
			ELSE
				N.POSIBLES 2 = ( ej. está entre 15 y 19 tiene 3 posibilidades )
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
: HINT   
	( v 1.20 si el número es N.LAST es que ya lo ha adivinado. )
	N.LAST @ NUM @ = 
	IF CR CR ."     Que mas ayuda quieres, ya has adivinado el numero!" CR CR HELP1
	ELSE
		( v1.17 mostrar los números más cercanos indicados )
		( si es la primera vez, mostrará 1 y el máximo a adivinar )
		." El numero a adivinar esta entre " N.MENOR ? 
		( v1.18 añadir un punto después del número )
		." y " N.MAYOR @ STR ." ." CR
		\ v1.19 un poco de humor
		HUMOR-HINT
		."      " QUEDAN-INTENTOS
	THEN
;

\ PISTA lo mismo que HINT
: PISTA   HINT ;
\ v1.19 H lo mismo que HINT
: H HINT ;

( v1.22 Comprobar si el nivel está ajustado y si no, asignar el valor adecuado )
: NIVEL?   
	( comprobar si el NIVEL es correcto )
	( si el nivel es menor de 1, asignar un nivel aleatorio entre 1 y 9 )
	EL-NIVEL @ 1 < IF NIVEL-RANDOM  THEN
	( si el nivel es mayor de 9, asignar 9 )
	EL-NIVEL @ 9 > IF 9 EL-NIVEL !  THEN
;

( v1.22 crear un numero aleatorio según el nivel )
( Se comprueba si el nivel es correcto y si no, se asigna del 1 al 9 )
( Se muestra el nivel a usar, etc. )
: NUEVO-NUM   
	NIVEL? 
	( asignar el número aleatorio )
	1 100 EL-NIVEL @ * random2 NUM ! 
	\ ." El numero a adivinar es " NUM ?
	CR NIVEL-NUMERO
;

\ Reiniciar el juego, asignando los valores predeterminados, etc.
: REINICIAR 
	( asignar los valores predeterminados de las variables )
	( v1.23 N.ANT ya no se usa )
	\ 0 N.LAST ! 0 N.ANT ! 0 I.N !
	0 N.LAST ! 0 I.N !
	( EL-MAXIMO se debe usar después de asignar el nivel )
	NIVEL?
	1 N.MENOR ! EL-MAXIMO N.MAYOR !
	( asignar ceros al array de números indicados )
	( v1.25 usando NUMS-CLEAR )
	NUMS-CLEAR
;

\ Iniciar el juego, poner todos los valores a cero
: JUGAR   PAGE HELP1 REINICIAR NUEVO-NUM ;
: RUN   JUGAR ;

( v1.22 Quito INICIAR2 y lo pongo directamente en NIVEL )
\ Para no mostrar en la ayuda que se puede usar NIVEL 
\ Este INICIAR se llamará desde NIVEL
\ : INICIAR2   PAGE VERSION CR HELP2 REINICIAR NUEVO-NUM ;

\ Asignar el nivel, y reiniciar los valores y mostrar la ayuda, etc.
\ : NIVEL   ( n -- ) EL-NIVEL ! INICIAR2 ;
: NIVEL   ( n -- ) EL-NIVEL ! 
	PAGE VERSION CR HELP2 REINICIAR NUEVO-NUM 
;

\ v1.14 LEVEL como NIVEL
: LEVEL   NIVEL ;

randomize ( iniciar la semilla del número aleatorio )
NIVEL-RANDOM ( v1.14 empezar con un nivel aleatorio )
JUGAR ( v1.11 iniciar el juego )
