( abrir gForth e indicar 
include adivina.forth
)

\ Adivinar un número
: VERSION   ." Adivina v1.34 (28-dic-2022 05.29) " ;

\ Nuevo en v1.34:
\ 	Cambio la forma de usar JUGAR-SOLO2
\	JUGAR-EXPERTO con nivel 7 a 9 y DIFICULTAD EXPERTO
\	Pero parece que no hace caso al llamar a JUGAR-SOLO2
\		Aunque se asignan los valores de EL-NIVEL y NIVEL.D
\

\ Nuevo en v1.33:
\	Ya juega solo de forma automática. Escribir JUGAR-SOLO.
\ 	JUGAR-AUTO elige al azar el NIVEL de juego entre 4 y 9 y DIFICULTAD entre NORMAL y MASTER
\ 	JUGAR-SOLO juega con un NIVEL entre 1 y 9 y con el nivel de DIFICULTAD MEDIO

\ Nuevo en v1.32:
\	Pruebas para ver cómo va BEGIN / UNTIL
\		Y adivinar usando el array PRUEBAS con los números a usar con GUESS
\	Quito LEVEL porque Level es una variable de gForth
\ 	Primer intento de jugar automáticamente.

\ TODO:
\	Al jugar solo si se pasa del número de intentos, finalizar el bucle.
\	Usar una variable para saber si juega solo.
\		De forma que los mensajes sean adecuados, por ejemplo:
\		Tu numero es mayor. Llevas 1 intento, te quedan 7.
\		Mi numero es mayor. Llevo 1 intento, me quedan 7.
\		368 Correcto! el numero era 368 lo has adivinado en 9 intentos.
\		368 Correcto! el numero era 368 lo he adivinado en 9 intentos.
\	Guardar los intentos de cada partida con el nivel.
\	Guardar el número de intentos más bajo al adivinar el número en cada nivel.
\		Esto hay que guardarlo en un array.

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

\ v1.27 Mostrar si es mayor, menor o igual
: MAYOR-MENOR ( n -- indicar si es mayor o menor que el número a adivinar )
	DUP 
	NUM @ = 
	IF ." (el numero) " DROP
	ELSE
		NUM @ <
		IF ." (era menor) "
		ELSE ." (era mayor) "
		THEN 
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
 		MUY-FACIL OF ." MUY-FACIL " ENDOF
 		FACIL     OF ." FACIL " ENDOF
 		NORMAL    OF ." NORMAL " ENDOF
 		MEDIO     OF ." MEDIO " ENDOF
 		DIFICIL   OF ." DIFICIL " ENDOF
 		EXPERTO   OF ." EXPERTO " ENDOF
 		MASTER    OF ." MASTER " ENDOF
 	ENDCASE
 	." (" DIFICULTAD.N . ." intentos) "
;

\ v1.28 mostrar los nivels de dificultades para HELP1
: LAS-DIFICULTADES
	."    "
	7 0 DO I STR ." :" I DIFICULTAD.N I DIFICULTAD? ."  " 
	I 1 + 4 MOD 0= IF CR ."    " THEN
	LOOP
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
	." El nivel de DIFICULTAD es "
	NIVEL.D @ DIFICULTAD? 
;

\ Asigna el nivel de dificultad, el número máximo de intentos y
\ muestra info del nivel de dificultad.
: DIFICULTAD
	NIVEL.D !
	DIFICULTAD-MOSTRAR
;

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
	( mostrar el total de intentos )
	( usar MAX.INTENTOS en vez de I.N ya que a veces falla )
	MAX.INTENTOS @ 0= IF 1 MAX.INTENTOS ! ." NO Habia intentos ??? " CR THEN
	MAX.INTENTOS @ 0
	DO 
		I NUMS+ @ DUP DUP
		( si es cero, salir del bucle )
		0= IF DROP LEAVE THEN
		CR
		( mostrar si es menor o mayor que el número que había que adivinar )
		1 I + 5 U.R ."     - " 7 U.R ."    " MAYOR-MENOR
	LOOP 
;

: NUMS?   MOSTRAR-NUMS ;

\ El número de orden actual de los números indicados, máximo será MAX.INTENTOS 
\ 	ya que se juega con nivel de dificultad.
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
	\ v1.29 comprobar si es cero
	N.MAYOR @ N.MENOR @ - 0= 
	IF N.MAYOR @ 1 - ." SE ASIGNA " N.MAYOR @ 1 - STR
	ELSE
		N.MAYOR @ N.MENOR @ - 2 / N.MENOR @ +
	THEN
;
: NEXT?   N.NEXT DUP . ;

\ v1.19 El rango del número a adivinar
\ v1.29 Ahora los valores de N.MENOR y N.MAYOR son el menor y el mayor indicado.
\ 	Si está entre 48 y 50 solo hay una posibilidad, el 49
\ 	Si está entre 47 y 50 hay 2 posibilidades: 48 y 49
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
	I.N @ MAX.INTENTOS @ >= 
	IF ." Muchos intentos, la solucion es " NUM ? 
	ELSE
		( v1.13 mostrar los intentos que lleva y los que quedan )
		( con el plural correcto según sea 1 o más )
		." Llevas " I.N ?
		I.N @ 1 = 
		IF ." intento, " ELSE ." intentos, " THEN ." te "
		( v1.26 para saber los intentos que quedan, usar MAX.INTENTOS @ )
		MAX.INTENTOS @  I.N @ - 1 = 
		IF ." queda 1. " 
		( v1.18 convertir en cadena y añadir un punto al final )
		ELSE ." quedan " MAX.INTENTOS @ I.N @ - STR ." ." 
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

: SHOW-DIFICULTADES 
	." Escribe n DIFICULTAD para cambiar el nivel de dificultad " CR
	LAS-DIFICULTADES CR
	( mostrar el nivel actual de juego )
	DIFICULTAD-MOSTRAR
;

: SHOW-INSTRUCCIONES 
	\ v 1.13 mostrar RUN también para iniciar otra partida.
	." Para jugar de nuevo escribe RUN o JUGAR y seguir con el mismo nivel. " CR
	( v1.9 indicar el nivel y el rango del número a adivinar )
	."     " NIVEL-NUMERO CR
	( v1.5 indicar el rango de números según el nivel )
	."     Para jugar con otro nivel, escribe n NIVEL." CR
	."     Escribe 0 NIVEL para usar un nivel aleatorio entre 1 y 9." CR
	( v1.25 mostrar info del nivel de dificultad )
	SHOW-DIFICULTADES
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
			\ v1.33 asignar a N.GUESS el número para que sea como adivinado.
			NUM @ N.GUESS !
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

\ Devuelve TRUE si el número es el correcto.
\ Se usa cuando juega automáticamente/solo.
: ADIVINADO
	\ Considerarlo adivinado si lo ha adivinado o se ha pasado del número de intentos.
	N.GUESS @ NUM @ = I.N @ MAX.INTENTOS @ > OR
;

\ v1.15 G lo mismo que GUESS
: G  GUESS ;
: ADIVINA   GUESS ;

( v1.24 Para elegir el siguiente número recomendado )
: N.G   N.NEXT GUESS ;
: N.G?   NEXT? GUESS ;

\ Resolver el juego ( ver la solución )
: RESUELVE   
	." Te quedan " MAX.INTENTOS @ I.N @ - . ." intentos. "
	." El numero a adivinar es " NUM @ STR ." ."
;

: ME-RINDO   RESUELVE ;
: GIVE-UP   RESUELVE ;
\ v1.22 RES es como RESUELVE antes era R
: RES   RESUELVE ;

\ Mostrar la ayuda / inicio del programa con las palabras a usar

\ No mostrar que se puede usar el nivel, para mostrar esta ayuda desde NIVEL
: HELP2   
	." Escribe num GUESS (o num G) y te dire si lo has acertado," CR
	."     o si el numero indicado es menor o mayor que el numero a adivinar." CR
	." Escribe HINT, H o PISTA y te mostrare como de cerca estas de adivinar el numero." CR
	." Para ver la solucion escribe RESUELVE, RES, ME-RINDO o GIVE-UP." CR
	." Para reiniciar el juego escribe JUGAR o RUN. " CR
	." Escribe NUMS? para ver los numeros introducidos (y si era menor o mayor)." CR
	SHOW-DIFICULTADES
;

: HELP1   
	VERSION CR
	." Escribe n NIVEL ( n del 0 al 9 ) para generar un numero de 1 al n * 100." CR
	."     Escribe 0 NIVEL para generar un nivel aleatorio entre 1 y 9." CR
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
		( si es la primera vez, mostrará 1 y el máximo a adivinar + 1 )
		." El numero a adivinar es mayor que " N.MENOR ? 
		( v1.18 añadir un punto después del número )
		." y menor que " N.MAYOR @ STR ." ." CR
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
	CR NIVEL-NUMERO
;

\ Reiniciar el juego, asignando los valores predeterminados, etc.
: REINICIAR 
	( asignar los valores predeterminados de las variables )
	0 N.LAST ! 0 I.N !
	( EL-MAXIMO se debe usar después de asignar el nivel )
	NIVEL?
	\ v1.29 asignar a N.MAYOR 1 más del máximo, y 0 a N.MENOR
	0 N.MENOR ! EL-MAXIMO 1 + N.MAYOR !
	( asignar ceros al array de números indicados )
	( v1.25 usando NUMS-CLEAR )
	NUMS-CLEAR
	NUEVO-NUM
;

\ Iniciar el juego, poner todos los valores a cero
: JUGAR   PAGE HELP1 REINICIAR ;
: RUN   JUGAR ;

\ Asignar el nivel, y reiniciar los valores y mostrar la ayuda, etc.
: NIVEL   ( n -- ) EL-NIVEL ! 
	PAGE VERSION CR HELP2 REINICIAR
;

\ v1.32 primer intento de jugar automáticamente.
( Los pasos son:
	 - ELEGIR un nivel entre 4 y 9.
	 - Usar el nivelde DIFICULTAD MEDIO 12 intentos
	 - JUGAR
	 - Indicar que se juega automáticamente.
	[- Empieza un bucle.
	 - Usar N.G? para elegir un número.
	 - Si lo ha adivinado indicarlo y salir del bucle.
	 - Hacer una pausa de casi 1 segundo.
	-] Seguir el bucle si el número no se ha acertado.
)
: JUGAR-SOLO2
	\ EL-NIVEL @ NIVEL
	NIVEL.D @ DIFICULTAD
	CR
	REINICIAR
	\ JUGAR
	( Indicar que se juega automáticamente )
	CR CR
	." Juego automaticamente, ire mostrando los numeros elegidos y si lo acierto. " CR
	." Estoy jugando con el NIVEL: " EL-NIVEL ? 
	." tengo que adivinar un numero del 1 al " EL-MAXIMO STR ." ." CR
	." El nivel de DIFICULTAD es " NIVEL.D @ DIFICULTAD? CR
	1800 MS
	( Empieza un bucle )
	BEGIN
		CR
		N.G?
		800 MS
		ADIVINADO
	UNTIL
	( Comprobar si se ha pasado del número de intentos )
	I.N @ MAX.INTENTOS @ >
	IF CR CR ." Me he pasado del numero de intentos :-( " CR
		."     Tengo que mejorar con el NIVEL: " EL-NIVEL ? 
		." y el nivel de DIFICULTAD " NIVEL.D @ DIFICULTAD? CR
		800 MS
	THEN
;

\ JUGAR-EXPERTO Nivel 7 a 9 y DIFICIL (8 intentos) 
: JUGAR-EXPERTO
	7 9 random2 EL-NIVEL !
	DIFICIL NIVEL.D !
	JUGAR-SOLO2
;

\ JUGAR-AUTO elige al azar el NIVEL de juego entre 4 y 9 y DIFICULTAD entre DIFICIL y MASTER
: JUGAR-AUTO
	( Elegir un nivel entre 4 y 9 )
	4 9 random2 EL-NIVEL !
	( Elegir un nivel de DIFICULTAD entre NORMAL y MASTER)
	DIFICIL MASTER random2 NIVEL.D !
	\ EL-NIVEL @ NIVEL.D @
	JUGAR-SOLO2
;

\ JUGAR-SOLO juega con un NIVEL entre 1 y 9 y con el nivel de DIFICULTAD MEDIO
: JUGAR-SOLO
	( Elegir un nivel entre 1 y 9 )
	1 9 random2 EL-NIVEL !
	( Usar el nivelde DIFICULTAD MEDIO 12 intentos )
	MEDIO DIFICULTAD
	\ EL-NIVEL @ NIVEL.D @
	JUGAR-SOLO2
;

\ v1.32 Pruebas para probar BEGIN / UNTIL
10 CONSTANT MAX.P 
VARIABLE PRUEBAS MAX.P CELLS ALLOT

: P+   ( INDEX# -- addr ) CELLS PRUEBAS + ;
: P!   ( n INDEX# -- ) P+ ! ;

: ASIGNAR-PRUEBAS
	PRUEBAS MAX.P 1 + CELLS ERASE
	1 0 P!
	3 1 P!
	5 2 P!
	6 3 P!
	7 4 P!
	15 5 P!
	9 6 P!
	10 7 P!
;

( 
include adivina.forth
)
: PRUEBA-BEGIN
	10 NUM !
	ASIGNAR-PRUEBAS
	0 I.N !
	BEGIN
		CR ." Intento: " I.N @ 1 + .
		I.N @ P+ @ STR ."  "
		200 MS
		I.N @ P+ @
		G
		\ ADIVINADO FALSE =
		\ WHILE 
		I.N @ 3 MOD 0=
		IF CR HINT THEN
	\ REPEAT
		ADIVINADO 
	UNTIL 
;

randomize ( iniciar la semilla del número aleatorio )
NIVEL-RANDOM ( v1.14 empezar con un nivel aleatorio )
NORMAL DIFICULTAD ( v1.28 empezar con el nivel de dificultad NORMAL )
JUGAR ( v1.11 iniciar el juego )
