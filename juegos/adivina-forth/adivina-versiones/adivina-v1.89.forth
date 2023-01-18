( abrir gForth e indicar 
include adivina.forth
)

\ Adivinar un número
: VERSION-ADIVINA   ." *** Adivina v1.89 (01-ene-2023 21.42) *** " ;

\ v1.89 (01-ene-2023 21.42)
\	En jugar hay que poner un numero en la pila para que no de error.
\	Sigue dando Stack underflow al llamar a jugar.
\	Defino AYUDA-SEE sin usar *AYUDAS.

\ v1.88 (01-ene-2023 21.17)
\	Da error de Stack underflow al llamar a jugar.
\	Al indicar el nivel se llama a JUGAR.
\	En JUGAR no mostrar ninguna ayuda, simplemente empezar el juego.

\ v1.87 (01-ene-2023 20.42)
\	Usando *AYUDAS con punteros a las palabras filtrado con QUEAYUDA-INDEX.

\ v1.86 (01-ene-2023 15.57)
\	En AYUDA-SEE se convierte QUE.AYUDA en mayúsculas para simplificar las comparaciones.

\ v1.85 (01-ene-2023 15.48)
\	Incluyo la comprobación de ADIVINA en AYUDA-SEE.

\ TODO:
\	En JUGAR hacer un bucle para pedir los números, 
\		terminarlo cuando se adivine el número, escriba RESUELVE o escriba 0.
\	Al sacar el número a adivinar, comprobar si será uno de los múltiplos habituales
\		si es así, sacar otro y no comprobar ese caso más.
\	El nivel de dificultad debe tener en cuenta el nivel,
\		ya que no es lo mismo adivinar un número entre 1 y 100 que entre 1 y 1200.
\	Guardar los intentos de cada partida con el nivel.
\		Diferenciar entre humano y maquina.
\	Guardar el número de intentos más bajo al adivinar el número en cada nivel.
\		Esto hay que guardarlo en un array.
\		Diferenciar entre humano y maquina.


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

\ v1.14 Un número aleatorio entre los dos indicados, ambos inclusives
\ n1 n2 -- n -> n será un número entre n1 y n2 inclusive
: random2   ( n1 n2 -- n )
	\ hace una copia del primero y lo pone arriba de la pila
	OVER ( w1 w2 -- w1 w2 w1 )
	\  sacar un número aleatorio entre 0 y n2-n1
	- 1 +
	\ random saca un número entre 0 y uno menos del número indicado
	\ por eso le sumo 1 para que sea entre 0 y n2-n1 inclusive
	random 
	\ le sumamos el primero para que sea un número entre n1 y n2 ambos inclusive
	+
;

\ muestra un número sencillo como cadena
: STR   ( n -- d como cadena ) 0 <# #S #> TYPE ;

\ Limpiar el contenido de la pila (31-dic-2022 18.40)
: LIMPIAR-PILA   DEPTH 0> IF DEPTH 0 DO DROP LOOP THEN ;

: TEXT  ( delimiter -- )  PAD 258 BL FILL  WORD COUNT PAD SWAP  MOVE ;

\ Para crear un array de forma fácil (01-ene-2023 09.48)
\ Usage <n> ARRAY <name>
: ARRAY   ( n -- )
	CREATE  CELLS ALLOT
	DOES> ( n -- a )
	SWAP CELLS + ;


\ ********************************************************
\ * Constantes y variables                               *
\ * Definirlas todas antes de las palabras que las usan. *
\ ********************************************************

\ El número de orden actual de los números indicados, máximo será MAX.INTENTOS 
\ 	ya que se juega con nivel de dificultad.
VARIABLE I.N 

\ v1.52 para saber quién está jugando
\ v1.54 cambio HUMANO por _HUMANO y MAQUINA por _MAQUINA
10 CONSTANT _HUMANO
11 CONSTANT _MAQUINA
\ v1.54 antes QUIEN-JUEGA
\ v1.81 asigno _HUMANO a QUIEN.JUEGA
VARIABLE QUIEN.JUEGA _HUMANO QUIEN.JUEGA !

\ v1.50 para saber que se ha mostrdo la solución al pasar los intentos
\ v1.54 cambio SOLUCION-MOSTRADA por SOLUCION.MOSTRADA
VARIABLE SOLUCION.MOSTRADA

\ Los números según el nivel de juego:
\ n adivinar un número del 1 al n*100
\ Los niveles son del 1 al 9.
\ v1.42 defino el nivel máximo como variable
\ Le asigno el valor 12 a ver qué pasa
VARIABLE NIVEL.MAX 12 NIVEL.MAX !

\ v1.5 el valor predeterminado del nivel es 1
\ v1.54 cambio EL-NIVEL por EL.NIVEL
VARIABLE EL.NIVEL 1 EL.NIVEL !

\ El número a adivinar 
\ v1.54 cambio NUM por EL.NUM
VARIABLE EL.NUM 
\ El último número indicado 
VARIABLE N.LAST 

\ El número máximo de adivinazas ( 51 = de 0 a 50 )
\ Aunque se usará siempre MAX.INTENTOS, esto solo define el máximo para el array ARRAY.NUMS.
\ v1.54 cambio MAX.NUMS por MAX_NUMS ya que es una constante
51 CONSTANT MAX_NUMS

\ El número de intentos máximos, será según el nivel de dificultad
VARIABLE MAX.INTENTOS MAX_NUMS MAX.INTENTOS !

\ Costantes para el nivel de DIFICULTAD
\ SENCILLO 22, MEDIO 14, DIFICIL 9, EXPERTO 6, MAESTRO 5
0 CONSTANT _SENCILLO
1 CONSTANT _MEDIO
2 CONSTANT _DIFICIL
3 CONSTANT _EXPERTO
4 CONSTANT _MAESTRO

VARIABLE NIVEL.D -1 NIVEL.D !

\ Array para los números indicados de 0 a MAX_NUMS
\ v1.54 cambio NUMS por ARRAY.NUMS
\ Usando ARRAY
MAX_NUMS ARRAY ARRAY.NUMS
\ VARIABLE ARRAY.NUMS MAX_NUMS CELLS ALLOT

\ v1.15 para los valores más cercanos
\ El menor más cercano
VARIABLE N.MENOR
\ El mayor más cercano
VARIABLE N.MAYOR

\ v1.46 estaba definida en la línea 346 y se usa antes en la 281
\ v1.23 Usar una variable para el número indicado
\	Con idea de no tener que duplicar el número indicado y usar ese valor en las comprobaciones.
VARIABLE N.GUESS 

\ Variable para la palabra escrita
\ Máximo 40 caracteres
40 CONSTANT MAX_AYUDA
VARIABLE QUE.AYUDA MAX_AYUDA ALLOT


\ ************************************************************
\ * Las ayudas y palabras que muestran textos de ayuda, etc. *
\ * Las palabras que se usan en las ayudas las defino antes. *
\ ************************************************************

\ Esto debe estar antes de las ayudas, porque se usa en MOSTRAR-CORRECTO.
\ TRUE si juega el humano, en otro caso FALSE
: HUMANO?   QUIEN.JUEGA @ _HUMANO =  ;

\ v1.10 El número máximo a adivinar 
: EL-MAXIMO   ( -- EL.NIVEL * 100 ) EL.NIVEL @ 100 * ;

\ Asigna el nivel de dificultad según la dificultad indicada
\ v1.54 cambio el nombre de DIFICULTAD.N a DIFICULTAD-N
: DIFICULTAD-N
  	CASE 
  		_SENCILLO     OF 22 ENDOF
  		_MEDIO        OF 14 ENDOF
  		_DIFICIL      OF  9 ENDOF
  		_EXPERTO      OF  6 ENDOF
  		_MAESTRO      OF  5 ENDOF
  	ENDCASE
;

\ Devuelve una cadena según el nivel de dificultad 
\ Con el texto y el valor de los intentos 
\ v1.54 cambio el nombre de DIFICULTAD? a DIFICULTAD-$
: DIFICULTAD-$
	DUP
 	CASE 
 		_SENCILLO  OF ." _SENCILLO " ENDOF
 		_MEDIO     OF ." _MEDIO " ENDOF
 		_DIFICIL   OF ." _DIFICIL " ENDOF
 		_EXPERTO   OF ." _EXPERTO " ENDOF
 		_MAESTRO   OF ." _MAESTRO " ENDOF
 	ENDCASE
 	." (" DIFICULTAD-N . ." intentos) "
;

\ v1.28 mostrar los niveles de dificultades para HELP1
: LAS-DIFICULTADES
	."    "
	\ v1.61 separar el nivel del texto y el signo igual
	_MAESTRO 1 + 0 DO I . ." = " I DIFICULTAD-$ ."  " 
	I 1 + 3 MOD 0= IF CR ."    " THEN
	LOOP
;


\ ********************
\ * Las ayudas, etc. *
\ ********************

\ Muestra el nivel de dificultado asignado a NIVEL.D
: DIFICULTAD-MOSTRAR   ." El nivel de DIFICULTAD es " NIVEL.D @ DIFICULTAD-$ ;

\ v1.8 mostrar el nivel y el número a adivinar.
\ v1.10 usar EL-MAXIMO para el número máximo a adivinar
\ cambio el nombre de NIVEL-SHOW a NIVEL-MOSTRAR
: NIVEL-MOSTRAR
	." El NIVEL actual es " EL.NIVEL ? 
	." y el numero a adivinar sera del 1 al " EL-MAXIMO STR ." ."
;

\ cambio SHOW-DIFICULTADES por DIFICULTADES-MOSTRAR
: DIFICULTADES-MOSTRAR
	." Escribe n DIFICULTAD (o n D!) para cambiar el nivel de dificultad " CR
	LAS-DIFICULTADES CR
	\ mostrar el nivel actual de DIFICULTAD del juego
	DIFICULTAD-MOSTRAR
;

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
		."     Escribe 0 NIVEL para usar un nivel aleatorio entre 1 y " NIVEL.MAX @ STR ." ." CR
	ELSE 
		." Si quieres que vuelva a jugar yo, escribe JUGAR-SOLO (seguire con los mismos niveles). " CR
		."     " NIVEL-MOSTRAR CR
		."     Escribe OPCIONES-SOLO para ver otras posibilidades de juego automatico." CR
	THEN
	\ v1.25 mostrar info del nivel de dificultad
	DIFICULTADES-MOSTRAR
;

\ Para mostrar el mensaje cuando lo adivina 
\ Cambio SHOW-CORRECTO por MOSTRAR-CORRECTO
: MOSTRAR-CORRECTO
	." Correcto! el numero era " EL.NUM ? 
	HUMANO? IF ." lo has adivinado en " ELSE ." lo he adivinado en "  THEN
	I.N ? 
	\ v1.3 comprobar si es 1 intento o más
	I.N @ 1 = IF ." intento. " ELSE ." intentos. " THEN CR
	INSTRUCCIONES-MOSTRAR
;

\ Mostrar las opciones de juego automático
\ v1.60 cambio el nombre de OPCIONES-AUTO a OPCIONES-SOLO
: OPCIONES-SOLO
	CR 
	." Opciones de juego automatico y los niveles de dificultad: " CR
	."    JUGAR-SOLO-FACIL   NIVEL de 1 a 5 y DIFICULTAD de _SENCILLO a _MEDIO." CR
	."    JUGAR-SOLO-DIFICIL NIVEL de " NIVEL.MAX @ 4 - . ." a " NIVEL.MAX ? ." y DIFICULTAD de _DIFICIL a _MAESTRO." CR
	."    JUGAR-SOLO-AUTO    NIVEL de 1 a " NIVEL.MAX ? ." y DIFICULTAD de _SENCILLO a _MAESTRO." CR
	."    JUGAR-SOLO         Usando el NIVEL y DIFICULTAD que se haya asignado antes." CR
	."    VER-NIVELES        Para mostrar los niveles: NIVEL Y DIFICULTAD.
;

\ Mostrar los niveles de juego de NIVEL y DIFICULTAD
: VER-NIVELES
	CR
	NIVEL-MOSTRAR CR
	DIFICULTAD-MOSTRAR
;

: AYUDA-GENERAL 
	VERSION-ADIVINA
	CR CR
	." Para adivinar el numero que el ordenador elija, escribe JUGAR." CR
	." Para que el ordenador adivine el numero, escribe JUGAR-SOLO." CR
	." Para ver las opciones del juego: niveles, etc. escribe AYUDA seguida de:" CR
	."    JUGAR      - para explicarte las opciones basicas." CR
	."    NIVEL      - para explicarte los niveles de juego." CR
	."    DIFICULTAD - para explicarte los niveles de dificultad." CR
	."    PISTA      - para explicarte algunos trucos." CR
	."    ADIVINA    - para explicarte como indicar el numero que crees que hay que adivinar." CR
	."    Puedes escribir AYUDA-XXX, donde XXX es una de las palabras anteriores, para mostrar esa ayuda." CR
	CR
	." Escribe AYUDA para ver esta ayuda." 
;

: AYUDA-PISTA
	DEPTH 0= IF CR ." La ayuda de PISTA" CR CR ELSE DROP THEN
	." Escribe PISTA y te mostrare como de cerca estas de adivinar el numero y los intentos que llevas."
	CR CR
	." Para ver la solucion escribe RESUELVE, RES o ME-RINDO." CR
	CR
	." Si quieres que el ordenador te diga que numero elegiria, escribe A-N? " CR
	."    Sera como si hubieras escrito ese numero seguido de ADIVINA." CR
	."    A-N? es lo que usa el ordenador cuando juega solo (en modo automatico)." CR
	CR
	." Escribe NUMS? para ver los numeros que has indicado y si son menor o mayor que el que hay que adivinar." CR
	\ para no mostrar el ok
	\ no usarlo porque si esto se llama desde un bloque con IFs, ya no se sigue analizando el resto
	\ QUIT
;

: AYUDA-JUGAR
	DEPTH 0= IF CR ." La ayuda de JUGAR" CR ELSE DROP THEN
	CR
	." Para jugar una partida contra el ordenador escribe JUGAR." CR
	." A continuacion escribe el numero que crees que debes adivinar seguido de ADIVINA:" CR
	."    num ADIVINA (o num A-N) y te dire si lo has acertado, " CR
	."    o si el numero indicado es menor o mayor que el numero a adivinar." CR
	."    Si indicas un numero menor o mayor de los ya indicados no se cuenta como intento." CR
	1 AYUDA-PISTA
	CR
	." Si quieres que yo adivine el numero escribe OPCIONES-SOLO y veras las opciones de juego automatico."
;
: AYUDA-NIVEL
	DEPTH 0= IF CR ." La ayuda de NIVEL" CR CR ELSE DROP THEN
	." Escribe n NIVEL ( n del 1 al " NIVEL.MAX ?  ." ) para generar un numero de 1 al n * 100." CR
	."     Escribe 0 NIVEL para generar un nivel aleatorio entre 1 y " NIVEL.MAX @ STR ." ." CR
	."     Al indicar un nivel, se reiniciara el numero a adivinar y los intentos, etc." CR
	VER-NIVELES
;
: AYUDA-DIFICULTAD
	DEPTH 0= IF CR ." La ayuda de DIFICULTAD" CR CR ELSE DROP THEN
	DIFICULTADES-MOSTRAR
;

: AYUDA-ADIVINA
	DEPTH 0= IF CR ." La ayuda de ADIVINA" CR CR ELSE DROP THEN
	." Escribe num ADIVINA (o num A-N) y te dire si lo has acertado," CR
	."     o si el numero indicado es menor o mayor que el numero a adivinar." CR
	." Escribe A-N? si quieres que el ordenador te diga que numero elegiria." CR
	."    Sera como si hubieras escrito ese numero seguido de ADIVINA." CR
	CR
	." Escribe NUMS? para ver los numeros que has indicado y si son menor o mayor que el que hay que adivinar." CR	
;

\ Mostrar la ayuda / inicio del programa con las palabras a usar

\ No mostrar que se puede usar el nivel, para mostrar esta ayuda desde NIVEL
: HELP2   
	1 AYUDA-ADIVINA CR
	\ ." Escribe num ADIVINA (o num A-N) y te dire si lo has acertado," CR
	\ ."     o si el numero indicado es menor o mayor que el numero a adivinar." CR
	." Escribe PISTA y te mostrare como de cerca estas de adivinar el numero." CR
	." Para ver la solucion escribe RESUELVE, RES o ME-RINDO." CR
	." Para reiniciar el juego escribe JUGAR o cambia de NIVEL." CR
	\ ." Escribe NUMS? para ver los numeros introducidos (y si era menor o mayor)." CR
	DIFICULTADES-MOSTRAR
;

: HELP1   
	VERSION-ADIVINA CR
	1 AYUDA-NIVEL
	\ ." Escribe n NIVEL ( n del 0 al " NIVEL.MAX ?  ." ) para generar un numero de 1 al n * 100." CR
	\ ."     Escribe 0 NIVEL para generar un nivel aleatorio entre 1 y " NIVEL.MAX @ STR ." ." CR
	\ ."     Al indicar un nivel, se reiniciara el numero a adivinar y los intentos, etc." CR
	CR HELP2 CR
	." Si quieres que yo adivine el numero escribe OPCIONES-SOLO y veras las opciones de juego automatico." CR
;


\ ********************************************************************
\ * Las palabras usadas en el juego que no dependen de las ayudas.   *
\ ********************************************************************

\ Iniciar el nivel con un valor aleatorio entre 1 y NIVEL.MAX
\ v1.57 le faltaba el @ en NIVEL.MAX ya que ahora es una variable
: NIVEL-RANDOM   1 NIVEL.MAX @ random2 EL.NIVEL ! ;

\ v1.27 Mostrar si es mayor, menor o igual
\ n -- indicar si es mayor o menor que el número a adivinar
: MAYOR-MENOR 
	DUP 
	EL.NUM @ = 
	IF ." (el numero) " DROP
	ELSE
		EL.NUM @ <
		IF ." (era menor) "
		ELSE ." (era mayor) "
		THEN 
	THEN
;

\ Asigna el nivel de dificultad indicado en la pila 
\	comprueba si el valor es válido y asigna el número máximo de intentos
\	no muestra info del nivel de dificultad.
: DIFICULTAD!   ( n -- )
	NIVEL.D !
	\ Comprobar si el nivel es el adecuado 
	NIVEL.D @ _SENCILLO < NIVEL.D @ _MAESTRO > OR
	\ asignar _SENCILLO si no es un valor entre _SENCILLO y _MAESTRO
	IF _SENCILLO NIVEL.D ! THEN
	\ y asignar el valor a MAX.INTENTOS
	NIVEL.D @ DIFICULTAD-N MAX.INTENTOS !
;

\ Asigna el nivel de dificultad, 
\	comprueba si el valor es válido y asigna el número máximo de intentos
\	muestra info del nivel de dificultad.
: DIFICULTAD
	\ Si no haya número indicado, mostrar el nivel de DIFICULTAD (01-ene-2023 09.52)
	DEPTH 0=
	IF DIFICULTAD-MOSTRAR
	ELSE DIFICULTAD!
	THEN
;

\ v1.61 defino D! para asignar el nivel de dificultad
: D!   DIFICULTAD ;

\ Definiendo ARRAY.NUMS como array, esto no es necesario
\	asignar   el valor: n ARRAY.NUMS !
\	recuperar el valor: n ARRAY.NUMS @

\ Definición de NUMS! usando ARRAY
\ Asignar a ARRAY.NUMS el valor en el índice indicado
\	3 4 ARRAY.NUMS
: NUMS!   ( n INDEX# -- ) ARRAY.NUMS ! ;

\ Borrar el contenido del array ARRAY.NUMS
\ Se borran todos los valores aunque se usen menos del tamaño del array
\ Sin usar la definición de NUMS!
: NUMS-CLEAR    MAX_NUMS 0 DO 0 I ARRAY.NUMS ! LOOP ;
\ Usando la definición de NUMS!
\ : NUMS-CLEAR    MAX_NUMS 0 DO 0 I NUMS! LOOP ;

\ Mostrar el contenido del array ARRAY.NUMS
: MOSTRAR-NUMS
	\ No mostrar los intentos, si I.N es cero
	I.N @ 0= 
	IF ." Aun no hay intentos." EXIT THEN
	CR
	."  Intento -   Numero  (mayor-menor) "
	\ mostrar el total de intentos
	MAX.INTENTOS @ 0
	DO 
		I ARRAY.NUMS @ DUP DUP
		\ si es cero, salir del bucle
		0= IF DROP LEAVE THEN
		CR
		\ mostrar si es menor o mayor que el número que había que adivinar
		1 I + 5 U.R ."     - " 7 U.R ."    " MAYOR-MENOR
	LOOP 
;

: NUMS?   MOSTRAR-NUMS ;

\ Incrementar el número de intentos sin más comprobaciones
\ v1.81 cambio INC.I.N por INC-INTENTOS
: INC-INTENTOS   I.N @ 1 + I.N ! ;

\ v1.19 El rango del número a adivinar
\ v1.29 Ahora los valores de N.MENOR y N.MAYOR son el menor y el mayor indicado.
\ 	Si está entre 48 y 50 solo hay una posibilidad, el 49
\ 	Si está entre 47 y 50 hay 2 posibilidades: 48 y 49
\	Cambio N.POSIBLES por N-POSIBLES
: N-POSIBLES   N.MAYOR @ 1 - N.MENOR @ - ;

\ Asignar a N.MENOR o N.MAYOR el que corresponda
: CERCANOS 
	\ N.LAST tiene el último número asignado
	\ Comprobar si N.LAST es menor que el número
	\ Hacer copia del número para asignarlo después al menor o mayor
	N.LAST @ DUP 
	\ si el último es menor que el número a adivinar
	EL.NUM @ < 
	\ asignar N.LAST al menor
	IF N.MENOR !   
	\ asignar N.LAST al mayor
	ELSE N.MAYOR ! 
	THEN
;

\ Comprobar si quedan intentos, si no, mostrar la solución
: QUEDAN-INTENTOS
	\ v1.46 Aclaración:
	\	QUEDAN-INTENTOS se llama desde ADIVINA si el número es menor o mayor
	\		también se llama desde PISTA
	\	Por tanto, debe ser I.N @ MAX.INTENTOS @ >= 
	I.N @ MAX.INTENTOS @ >= 
	IF 
		CR
		."     No quedan intentos, la solucion es " EL.NUM ? 
		\ v1.46 asignar a N.GUESS el número para que sea como adivinado
		EL.NUM @ N.GUESS !
		TRUE SOLUCION.MOSTRADA !
	ELSE
		\ v1.13 mostrar los intentos que lleva y los que quedan
		\ con el plural correcto según sea 1 o más
		\ v1.52 poner el texto según sea humano o máquina
		HUMANO? IF ." Llevas " ELSE ." Llevo " THEN
		I.N ?
		I.N @ 1 = 
		IF ." intento, " ELSE ." intentos, " THEN 
		HUMANO? IF ." te " ELSE ." me " THEN
		\ v1.26 para saber los intentos que quedan, usar MAX.INTENTOS @
		MAX.INTENTOS @  I.N @ - 1 = 
		IF ." queda 1. " 
		\ v1.18 convertir en cadena y añadir un punto al final
		ELSE ." quedan " MAX.INTENTOS @ I.N @ - STR ." ." 
		THEN 
	THEN
;

\ Las comprobaciones en ADIVINA:
\	Si el número indicado no está entre los "posibles" avisar y no asignarlo.
\	Si el número indicado es mayor del máximo avisar y no asignarlo.

\ v1.23 comprobar si el número indicado es aceptable.
\	Devuelve FALSE si no se acepta el número
: GUESS?
	\ v1.23 Si el número es menor que 1, avisar y no tenerlo en cuenta.
	N.GUESS @ 0 <=
	IF ." El numero debe ser mayor que cero. " FALSE
	ELSE
		\ v1.10 comprobar si el número es mayor del máximo
		\ 	Si es así, avisar y no tenerlo en cuenta
		N.GUESS @ EL-MAXIMO >
		\ v1.19 usar STR para mostrar el numero
		IF ." El numero indicado es mayor que el maximo (" EL-MAXIMO STR ." )" FALSE
		ELSE
			\ v1.23 Si el número es mayor que el menor o menor que el mayor
			\ no aceptarlo y mostrar un aviso
			\ si el número es menor que el menor indicado
			N.GUESS @ N.MENOR @ < 
			IF ." El numero indicado es menor que el menor indicado hasta ahora (" N.MENOR @ STR ." )" 
				FALSE
			ELSE
				\ si el número es mayor que el mayor indicado
				N.GUESS @ N.MAYOR @ > 
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
\ v1.54 cambio GUESS por ADIVINA
: ADIVINA
	\ v1.23 asignar el número indicado a N.GUESS 
	N.GUESS !
	\ v1.23 devuelve FALSE si no se acepta el número
	GUESS? 
	IF 
		\ v1.46 comprobar si es >= en vez de mayor
		I.N @ MAX.INTENTOS @ >=
		IF 
			\ indicarlo y mostrar la solución
			." Ya no quedan intentos, el numero era " EL.NUM @ STR ." ." CR
			\ v1.33 asignar a N.GUESS el número para que sea como adivinado
			EL.NUM @ N.GUESS !
			TRUE SOLUCION.MOSTRADA !
			INSTRUCCIONES-MOSTRAR
		ELSE
			\ incrementar el número de intentos
			INC-INTENTOS 
			\ v1.26 guardar el número en el array después de incrementar
			\ pero restando uno ya que el índice es en base cero
			N.GUESS @ I.N @ 1 - NUMS!
			\ si lo ha adivinado
			N.GUESS @ EL.NUM @ = 
			IF MOSTRAR-CORRECTO
			ELSE 
				\ si es menor
				N.GUESS @  EL.NUM @ < 
				\ IF ." Tu numero es menor. "
				\ ELSE ." Tu numero es mayor. "
				IF ." Es menor. "
				ELSE ." Es mayor. "
				THEN 
				\ mostrar los intentos que quedan o la solución
				QUEDAN-INTENTOS 
			THEN 
			\ asignar el número indicado al último
			N.GUESS @ N.LAST ! 
			\ Asignar el último número al menor o mayor más cercano
			CERCANOS
		THEN
	THEN
;

\ v1.54 A-N como ADIVINA / GUESS
: A-N   ADIVINA ;
\ v1.55 defino N-A por si lo escribo al revés
: N-A   ADIVINA ;

\ v1.57 cambio el sitio de estas palabras porque A-N? usa ADIVINA

\ v1.24 Poner en la pila el siguiente número a comprobar.
\	Media = (Mayor - Menor) / 2
\	Siguiente = Menor + Media
\	El valor devuelto es el número sin decimales: 14.5 -> 14
\ En gForth está definido NEXT, pero no en SwiftForth
\ v1.56 cambio el nombre de N.NEXT a N-NEXT
: N-NEXT   ( -- N.MAYOR N.MENOR - 2 / N.MENOR + )
	\ v1.29 comprobar si es cero
	N.MAYOR @ N.MENOR @ - 0= 
	IF N.MAYOR @ 1 - ." SE ASIGNA " N.MAYOR @ 1 - STR
	ELSE
		N.MAYOR @ N.MENOR @ - 2 / N.MENOR @ +
	THEN
;

\ Saca el siguiente valor, lo muestra y deja una copia en la pila, para poder usarlo con ADIVINA
\ v1.56 cambio el nombre de NEXT? a N-NEXT?
: N-NEXT?   N-NEXT DUP . ;

\ v1.24 Elegir el siguiente número recomendado para adivinar usando N-NEXT
\ v1.56 cambio el nombre N.G? a A-N?
: A-N?   N-NEXT? ADIVINA ;
\ v1.56 defino N-A? como alias de A-N?
: N-A?   A-N? ;

\ Devuelve TRUE si el número es el correcto o se han pasado los intentos
\ 	Se usa cuando juega automáticamente/solo
\ v1.47 cambio el nombre de ADIVINADO a SEGUIR-BUCLE
: SEGUIR-BUCLE
	\ Considerarlo adivinado si lo ha adivinado o se ha pasado del número de intentos
	\ v1.50 tener también en cuenta si se ha mostrado la solución
	N.GUESS @ EL.NUM @ = I.N @ MAX.INTENTOS @ > OR
	SOLUCION.MOSTRADA @ OR
;

\ Resolver el juego = mostrar la solución y los intentos pendientes
: RESUELVE   
	." Te quedan " MAX.INTENTOS @ I.N @ - . ." intentos. "
	." El numero a adivinar es " EL.NUM @ STR ." ."
;

: ME-RINDO   RESUELVE ;
\ v1.22 RES es como RESUELVE antes era R
: RES   RESUELVE ;

\ v1.20 defino todo esto después de HELP1 y HELP2 porque en PISTA se usa HELP1

\ v1.19 mostrar textos según las posibilidades que tenga de adivinarlo.
: HUMOR-HINT 
	\ Solo mostrar mensajes si es menor de 6
	N-POSIBLES 6 <
	IF ."      " 
		\ solo tiene un número que poner, ej. está entre 15 y 17
		N-POSIBLES 1 = 
		IF ." Si no lo adivinas ahora no se que hacer contigo."
		ELSE
			\ ej. está entre 15 y 18 solo tiene 2 números que probar
			N-POSIBLES 2 = 
			IF ." Tienes el 50% de posibilidades de adivinarlo."
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
: PISTA
	\ v 1.20 si el número es N.LAST es que ya lo ha adivinado
	N.LAST @ EL.NUM @ = 
	IF 
		CR CR 
		\ ."     Que mas ayuda quieres, ya has adivinado el numero!" CR CR HELP1
		."    O no has empezado a jugar o ya has adivinado el numero." CR
		."    Escribe JUGAR para empezar un nuevo juego." 
		CR
	ELSE
		\ v1.17 mostrar los números más cercanos indicados
		\ si es la primera vez, mostrará 1 y el máximo a adivinar + 1
		." El numero a adivinar es mayor que " N.MENOR ? 
		\ v1.18 añadir un punto después del número
		." y menor que " N.MAYOR @ STR ." ." CR
		\ v1.19 un poco de humor
		HUMOR-HINT
		."      " QUEDAN-INTENTOS
	THEN
;

\ v1.22 Comprobar si el nivel está ajustado y si no, asignar el valor adecuado
: NIVEL?   
	\ comprobar si el NIVEL es correcto 
	\ si el nivel es menor de 1, asignar un nivel aleatorio entre 1 y NIVEL.MAX 
	EL.NIVEL @ 1 < 
	IF 
		\ Sacar un valor aleatorio
		NIVEL-RANDOM  
		\ ." (nivel aleatorio, el nuevo nivel es " EL.NIVEL ? ." )"
	THEN
	\ si el nivel es mayor de NIVEL.MAX, asignar NIVEL.MAX
	\ ." (el nivel es " EL.NIVEL ? ." )"
	EL.NIVEL @ NIVEL.MAX @ > 
	IF NIVEL.MAX @ EL.NIVEL !  THEN
;

\ v1.22 crear un numero aleatorio según el nivel 
\ Se comprueba si el nivel es correcto y si no, se asigna del 1 al NIVEL.MAX
\ Se muestra el nivel a usar, etc.
: NUEVO-NUM   
	NIVEL? 
	\ asignar el número aleatorio
	1 100 EL.NIVEL @ * random2 EL.NUM ! 
;

\ Reiniciar el juego, asignando los valores predeterminados, etc.
: REINICIAR 
	\ v1.54 no asignar nada a QUIEN.JUEGA por si se llama desde NIVEL
	\ Poner solución mostrada en false
	FALSE SOLUCION.MOSTRADA !
	\ asignar los valores predeterminados de las variables
	0 N.LAST ! 0 I.N !
	\ EL-MAXIMO se debe usar después de asignar el nivel
	NIVEL?
	\ v1.29 asignar a N.MAYOR 1 más del máximo, y 0 a N.MENOR
	0 N.MENOR ! EL-MAXIMO 1 + N.MAYOR !
	\ asignar ceros al array de números indicados
	\ v1.25 usando NUMS-CLEAR
	NUMS-CLEAR
	NUEVO-NUM
;

\ Iniciar el juego, poner todos los valores a cero
\ No mostrar la ayuda ni nada
: JUGAR   
	\ PAGE
	\ HELP1
	REINICIAR 
	\ v1.38 mostrar el nivel y el número máximo a adivinar
	\ v1.81 no mostrarlo, se muestra desde HELP1
	\ CR NIVEL-MOSTRAR
	\ Asignar que juega el humano
	_HUMANO QUIEN.JUEGA !
	\ no se porqué pero espera 1 valor en la pila ???
	1
	CR
	." Adivina el numero que he elegido." CR 
	."     Es un numero entre 1 y " EL-MAXIMO . ." inclusive." CR
	."     Tienes " DIFICULTAD-N . ." intentos para adivinarlo." CR
	." Si quieres cambiar el nivel o el numero de intentos escribe " CR
	."     n NIVEL o n DIFICULTAD." CR
	." Escribe tu numero seguido de ADIVINA (o A-N) " CR
;

\ Asignar el nivel, y reiniciar los valores y mostrar la ayuda, etc.
\ v1.80 si no se indica el nivel, mostrar el nivel actual
: NIVEL   ( n -- ) 
	DEPTH 0= IF NIVEL-MOSTRAR EXIT THEN
	EL.NIVEL ! 
	\ v1.57 no borrar la pantalla
	\ PAGE 
	CR CR
	\ VERSION-ADIVINA CR HELP2 REINICIAR 
	\ v1.38 mostrar el nivel y el número máximo a adivinar
	\ CR NIVEL-MOSTRAR
	JUGAR
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
	\ No mostrar el nivel de DIFICULTAD
	\ pero sí el número máximo de intentos
	NIVEL.D @ DIFICULTAD!
	REINICIAR
	\ Asignar que juega la máquina
	_MAQUINA QUIEN.JUEGA !
	\ Mostrar que se juega automáticamente
	CR CR
	." Juego automaticamente, ire mostrando los numeros elegidos y si lo acierto. " CR
	." Estoy jugando con el NIVEL: " EL.NIVEL ? 
	." tengo que adivinar un numero del 1 al " EL-MAXIMO STR ." ." CR
	." El nivel de DIFICULTAD es " NIVEL.D @ DIFICULTAD-$ CR
	1800 MS
	\ Empieza un bucle
	BEGIN
		CR
		A-N?
		800 MS
		\ v1.47 cambio el nombre de ADIVINADO a SEGUIR-BUCLE
		\ SEGUIR-BUCLE devuelve TRUE si lo ha adivinado o han pasado los intentos
		SEGUIR-BUCLE
		\ If flag is false, go back to BEGIN. If flag is true, terminate the loop
	UNTIL
	\ v1.50 Comprobar si se ha mostrado la solución
	\ v1.51 fallaba porque no tenía el @
	SOLUCION.MOSTRADA @
	IF CR CR ." Me he pasado del numero de intentos :-( " CR
		."     Tengo que mejorar con el NIVEL: " EL.NIVEL ? 
		." y el nivel de DIFICULTAD " NIVEL.D @ DIFICULTAD-$ CR
		1000 MS
	THEN
;

\ JUGAR-SOLO-AUTO elige al azar el NIVEL y DIFICULTAD
: JUGAR-SOLO-AUTO
	1 NIVEL.MAX @ random2 EL.NIVEL !
	_SENCILLO _MAESTRO random2 NIVEL.D !
	JUGAR-SOLO
;

\ JUGAR-SOLO-FACIL juega con un NIVEL entre 1 y 5 y con el nivel de DIFICULTAD entre _SENCILLO y _MEDIO
: JUGAR-SOLO-FACIL
	1 5 random2 EL.NIVEL !
	_SENCILLO _MEDIO random2 NIVEL.D !
	JUGAR-SOLO
;

\ JUGAR-SOLO-DIFICIL para probar con nivel NIVEL.MAX - 4 a NIVEL.MAX y DIFICULTAD _DIFICIL a _MAESTRO
: JUGAR-SOLO-DIFICIL
	NIVEL.MAX @ 4 - NIVEL.MAX @ random2 EL.NIVEL !
	_DIFICIL _MAESTRO random2 NIVEL.D !
	JUGAR-SOLO
;

\ *******************************************************************
\ Para mostrar la ayuda                           (30/dic/22 16.46) *
\ *******************************************************************

\ Convertir el contenido de QUE.AYUDA en mayúsculas
: QUEAYUDA-TOUPPER
    \ parsed count bounds
    QUE.AYUDA 40 -TRAILING BOUNDS
    ?DO I c@ toupper I c! LOOP 
    \ QUE.AYUDA 40 -TRAILING TYPE
;


\ Esto solo sirve si se usa AYUDA-SEE con las comparaciones
: AYUDAS  ( -- addr )
   \ C" JUGAR     jugar     NIVEL     nivel     DIFICULTADdificultadPISTA     pista     ADIVINA   adivina   " ;
   \ C" JUGAR     NIVEL     DIFICULTADPISTA     ADIVINA   " ;
   C" GENERAL   JUGAR     NIVEL     DIFICULTADPISTA     ADIVINA   " ;

: .AYUDAS  ( index -- )
   10 *  AYUDAS 1+  +  10 -TRAILING
;

: AYUDA-SEE
    QUEAYUDA-TOUPPER
    QUE.AYUDA 40 -TRAILING
    2DUP 2DUP 2DUP 2DUP 2DUP
    \ 0 .AYUDAS COMPARE 0= IF 0 THEN 2DUP
    1 .AYUDAS COMPARE 0= IF LIMPIAR-PILA AYUDA-JUGAR EXIT THEN
    2 .AYUDAS COMPARE 0= IF LIMPIAR-PILA AYUDA-NIVEL EXIT THEN
    3 .AYUDAS COMPARE 0= IF LIMPIAR-PILA AYUDA-DIFICULTAD EXIT THEN
    4 .AYUDAS COMPARE 0= IF LIMPIAR-PILA AYUDA-PISTA EXIT THEN
    5 .AYUDAS COMPARE 0= IF LIMPIAR-PILA AYUDA-ADIVINA EXIT THEN
    LIMPIAR-PILA AYUDA-GENERAL
;

\ Create *AYUDAS ' AYUDA-GENERAL , ' AYUDA-JUGAR , ' AYUDA-NIVEL , ' AYUDA-DIFICULTAD , ' AYUDA-PISTA , ' AYUDA-ADIVINA ,

\ : QUEAYUDA-INDEX ( -- #index )
\     QUEAYUDA-TOUPPER
\     QUE.AYUDA 40 -TRAILING
\     2DUP 2DUP 2DUP 2DUP 2DUP
\     \ 0 .AYUDAS COMPARE 0= IF 0 THEN 2DUP
\     1 .AYUDAS COMPARE 0= IF LIMPIAR-PILA 1 EXIT THEN
\     2 .AYUDAS COMPARE 0= IF LIMPIAR-PILA 2 EXIT THEN
\     3 .AYUDAS COMPARE 0= IF LIMPIAR-PILA 3 EXIT THEN
\     4 .AYUDAS COMPARE 0= IF LIMPIAR-PILA 4 EXIT THEN
\     5 .AYUDAS COMPARE 0= IF LIMPIAR-PILA 5 EXIT ELSE LIMPIAR-PILA 0 THEN
\ ;

\ \ Usando *AYUDAS y AYUDA-INDEX (01-ene-2023 20.40)
\ : AYUDA-SEE-PUNTEROS
\     \ Averiguar el índice en .AYUDAS
\     QUEAYUDA-INDEX
\     DEPTH 0= IF 0 THEN
\     \ Esto ejecuta la definicion de *AYUDAS del índice indicado
\     CELLS *AYUDAS + @ EXECUTE
\ ;


\ Forma un poco más simple, (31-dic-22 19.12)
: AYUDA-SEE-ANT
    \ QUE.AYUDA 40 -TRAILING
    QUEAYUDA-TOUPPER
    QUE.AYUDA 40 -TRAILING
    \ Poner un 2DUP para cada comparación que se vaya a hacer menos una
    2DUP 2DUP 2DUP 2DUP
    0 .AYUDAS COMPARE 0= 
    IF LIMPIAR-PILA AYUDA-JUGAR
    ELSE 
        1 .AYUDAS COMPARE 0= 
        IF LIMPIAR-PILA AYUDA-NIVEL
        ELSE
            2 .AYUDAS COMPARE 0= 
            IF LIMPIAR-PILA AYUDA-DIFICULTAD
            ELSE
            	3 .AYUDAS COMPARE 0= 
                IF LIMPIAR-PILA AYUDA-PISTA
                ELSE
                	4 .AYUDAS COMPARE 0= 
                    IF LIMPIAR-PILA AYUDA-ADIVINA
                    ELSE LIMPIAR-PILA AYUDA-GENERAL
                    THEN
                THEN
            THEN
        THEN
    THEN
    \ LIMPIAR-PILA
;

: AYUDA
    \ Acepta más de una palabra, hasta que se pulsa INTRO
    1 TEXT PAD QUE.AYUDA 40 MOVE
    AYUDA-SEE
;

\ v1.64 borrar el contenido de la pantalla
PAGE 

\ Iniciar la semilla del número aleatorio
randomize 
\ Empezar un un nivel al azar
NIVEL-RANDOM
\ Jugar con el nivel _MEDIO de DIFICULTAD
_MEDIO DIFICULTAD
\ Empieza el juego
\ JUGAR
\ v1.63 empezar mostrando la ayuda general
AYUDA-GENERAL
\ AYUDA
