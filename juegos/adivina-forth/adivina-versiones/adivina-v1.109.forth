( abrir gForth e indicar 
include adivina.forth
)

\ Adivinar un número
: VERSION-ADIVINA   ." *** Adivina Forth v1.109 (03-ene-2023 19.42) *** " ;

\ v1.109 (03-ene-2023 19.42)
\	Añado comprobación en AYUDA-SEE para mostrar la ayuda de Forth.
\	Cambio el valor de %AYUDAS y añado FORTH a $AYUDAS.
\	En AYUDA-GENERAL pongo que se puede escribir AYUDA FORTH.

\ v1.108 (03-ene-2023 18.47)
\	Defino AYUDA-FORTH sobre el lenguaje Forth.
\	Pongo en el título que es Adivina Forth.

\ v1.107 (03-ene-2023 17.34)
\	Cambio textos en DIFICULTADES-MOSTRAR y DIFICULTAD-MOSTRAR.
\	En HUMOR-PISTA poner los espacios para cuando es el 50%

\ v1.106 (03-ene-2023 17.25)
\	En HUMOR-PISTA poner los espacios para cuando es el 50%
\	Cambio HUMOR-HINT por HUMOR-PISTA.

\ v1.105 (03-ene-2023 16.57)
\	En LAS-DIFICULTADES se muestran los intentos desde _MAESTRO a _SENCILLO.
\	Cambiar el texto al mostrar la ayuda de DIFICULTAD.
\	Si se escribe 0 DIFICULTAD asignar un valor aleatorio entre _SENCILLO y _MAESTRO.
\	Cambiar los valores de las dificultades de 1 _SENCILLO a 5 _MAESTRO

\ v1.104 (03-ene-2023 16.25)
\	Al asignar el valor de DIFICULTAD 
\		Si el valor indicado es mayor de _MAESTRO, asignar _MAESTRO.
\		Si es menor de _SENCILLO asignar _SENCILLO.
\	Desde NIVEL llamar a REINICIAR sin nada en la pila.
\	En REINICIAR solo mostrar " Se han reiniciado los valores..." cuando no se indica nada en la pila.
\	Ajustes en los textos a mostrar en AYUDA-GENERAL.

\ v1.103 (03-ene-2023 16.07)
\	Al cargar el fichero, asignar el nivel de DIFICULTAD con _MEDIO DIFICULTAD!
\		ya que al hacerlo con _MEDIO DIFICULTAD se muestra el nivel.
\	Defino DIFICULTAD-RANDOM para asignar un valor aleatorio a NIVELDIFICULTAD.
\		El valor será entre _SENCILLO y _MAESTRO (el mínimo y el máximo).

\ v1.102 (03-ene-2023 15.10)
\	Desde JUGAR y JUGAR-SOLO se indica un valor en la pila antes de llamar a REINICIAR.
\	En REINICIAR si no se ha indicado nada en la pila se llama a VER-NIVELES.
\	En AYUDA-GENERAL se muestra que REINICIAR prepara el juego.
\	En REINICIAR se muestra un mensaje de que se han reiniciado los valores y el número a adivinar.
\	En NIVEL y DIFICULTAD mostrar el nivel después de asignar un nuevo valor.

\ v1.101 (03-ene-2023 14.50)
\	En NIVEL no se inicia el juego, solo se cambia el nivel y se llama a REINICIAR.
\	Arreglo de texto en NIVEL

\ v1.100 (03-ene-2023 12.40)
\	Cambio GUESS? por NUMEROCORRECTO?
\	Comeneto HELP1 y HELP2 porque ya no se usan.
\	Comento las definiciones de ADDR$, PLACE$ y PRINT$
\	En HUMOR-HINT muestro los números posibles cuando le quedan 2.

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

\ (02-ene-2023 22.26)
\ Para poder crear arrays de cadenas con $"
4096 constant /string-space

( Reserve  STRING-SPACE  in data-space. )
CREATE STRING-SPACE           /STRING-SPACE CHARS ALLOT
VARIABLE NEXT-STRING          0 NEXT-STRING !

( "string<">" — caddr ) 
: $" [CHAR] " PARSE
  DUP 1+ NEXT-STRING @ + /STRING-SPACE >
        ABORT" String Space Exhausted. "
  STRING-SPACE NEXT-STRING @ CHARS + >R
  DUP 1+ NEXT-STRING +!
  R@ PLACE
  R>
;

\ (02-ene-2023 17.05)
\ Esto no lo utilizo (03-ene-2023 14.37)
(
\ Adaptado de https://thebeez.home.xs4all.nl/ForthPrimer/Forth_primer.html#toc-Chapter-3

\ Para asignar cadenas a una variable
: PLACE$ over over >r >r char+ swap chars cmove r> r> c! ;

\ Deja en la pila la dirección de la cadena, lista para usar con TYPE, etc.
: ADDR$ count -trailing ;

\ Mostrar el contenido de esa variable sin los espacios finales
: PRINT$ count -trailing type ;

\ Las variables de "cadenas", en realidad son como ARRAY, se deben definir así:
\	para que tenga espacio para 40 caracteres, 39 en realidad
\ create STR1 40 cells allot
\ Se asignan de esta forma
\ s" Hello!" STR1 PLACE$
\ Se muestran de esta otra
\ STR1 PRINT$
\ Para obtener la dirección de STR1
\ STR1 ADDR$
)


\ ********************************************************
\ * Constantes y variables                               *
\ * Definirlas todas antes de las palabras que las usan. *
\ ********************************************************

\ El número de orden actual de los números indicados, 
\	el máximo será INTENTOSMAXIMO ya que se juega con nivel de dificultad
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

\ Costantes para el nivel de DIFICULTAD
\ v1.105 el mínimo es 1 y el máximo 5, antes de 0 a 4
\ SENCILLO 22, MEDIO 14, DIFICIL 9, EXPERTO 6, MAESTRO 5
1 CONSTANT _SENCILLO
2 CONSTANT _MEDIO
3 CONSTANT _DIFICIL
4 CONSTANT _EXPERTO
5 CONSTANT _MAESTRO

\ El nivel de DIFICULTAD
\ v1.94 cambio NIVEL.D por NIVELDIFICULTAD
VARIABLE NIVELDIFICULTAD -1 NIVELDIFICULTAD !

\ Array para los números indicados de 0 a MAX_NUMS
\ v1.54 cambio NUMS por ARRAY.NUMS
\ Definición de ARRAY.NUMS antes de usar ARRAY.
\ VARIABLE ARRAY.NUMS MAX_NUMS CELLS ALLOT
\ Usando ARRAY
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
\	Con idea de no tener que duplicar el número indicado y usar ese valor en las comprobaciones.
\ v1.94 cambio N.GUESS por NUMEROINDICADO
VARIABLE NUMEROINDICADO

\ Variable para la palabra escrita
\ Máximo 20 caracteres
20 CONSTANT MAX_AYUDA
VARIABLE QUE.AYUDA MAX_AYUDA ALLOT


\ ************************************************************
\ * Las ayudas y palabras que muestran textos de ayuda, etc. *
\ * Las palabras que se usan en las ayudas las defino antes. *
\ ************************************************************

\ Esto debe estar antes de las ayudas, porque se usa en MOSTRAR-CORRECTO.
\ TRUE si juega el humano, en otro caso FALSE
: HUMANO?   QUIENJUEGA @ _HUMANO =  ;

\ v1.10 El número máximo a adivinar 
: EL-MAXIMO   ( -- ELNIVEL * 100 ) ELNIVEL @ 100 * ;

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

\ v1.28 mostrar los niveles de dificultades, era para HELP1
: LAS-DIFICULTADES
	."    "
	\ v1.61 separar el nivel del texto y el signo igual
	_MAESTRO 1 + _SENCILLO DO I . ." = " I DIFICULTAD-$ ."  " 
	I 1 + 3 MOD 0= IF CR ."    " THEN
	LOOP
;


\ ********************
\ * Las ayudas, etc. *
\ ********************

\ Muestra el nivel de dificultado asignado a NIVELDIFICULTAD
: DIFICULTAD-MOSTRAR   ." El nivel de DIFICULTAD actual es " NIVELDIFICULTAD @ DIFICULTAD-$ ;

\ v1.8 mostrar el nivel y el número a adivinar.
\ v1.10 usar EL-MAXIMO para el número máximo a adivinar
\ cambio el nombre de NIVEL-SHOW a NIVEL-MOSTRAR
: NIVEL-MOSTRAR
	." El NIVEL actual es " ELNIVEL ? 
	." y el numero a adivinar sera del 1 al " EL-MAXIMO STR ." ." ;

\ cambio SHOW-DIFICULTADES por DIFICULTADES-MOSTRAR
: DIFICULTADES-MOSTRAR
	CR
	." Escribe n DIFICULTAD (o n D!) para cambiar el nivel de dificultad." CR
	."     Para asignar un valor aleatorio entre _SENCILLO y _MAESTRO escribe 0 DIFICULTAD (o 0 D!)." CR
	." Los niveles de DIFICULTAD son:" CR
	LAS-DIFICULTADES CR
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
		."     Escribe 0 NIVEL para usar un nivel aleatorio entre 1 y " NIVELMAXIMO @ STR ." ." CR
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
	."    JUGAR-SOLO-DIFICIL NIVEL de " NIVELMAXIMO @ 4 - . ." a " NIVELMAXIMO ? ." y DIFICULTAD de _DIFICIL a _MAESTRO." CR
	."    JUGAR-SOLO-AUTO    NIVEL de 1 a " NIVELMAXIMO ? ." y DIFICULTAD de _SENCILLO a _MAESTRO." CR
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
	DEPTH 0= IF CR ." La ayuda de FORTH" CR CR ELSE DROP THEN
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
	CR ." Para mas informacion e implementaciones populares de Forth ver:" CR
	."    Forth en Wikipedia                       https://es.wikipedia.org/wiki/Forth" CR
	."    Forth Interest Group (FIG)               http://www.forth.org/" CR
	."    Forth Standard                           https://forth-standard.org/" CR
	."    GForth del Proyecto GNU                  https://gforth.org/" CR
	."    Sitio web oficial de FORTH, Inc.         https://www.forth.com/" CR
	."    Starting FORTH (tutorial de Leo Brodie)  https://www.forth.com/starting-forth/" CR
	."        Este es el que he usado yo para empaparme de Forth."
;

: AYUDA-GENERAL
	CR VERSION-ADIVINA CR
	."     Este programa está escrito en el lenguaje Forth." CR CR
	." Escribe REINICIAR para reiniciar el juego y asignar el numero a adivinar." CR
	." Para adivinar el numero que el ordenador elija, escribe JUGAR." CR
	." Para que el ordenador adivine el numero, escribe JUGAR-SOLO." CR
	." Para ver las opciones del juego: niveles, etc. escribe AYUDA seguida de:" CR
	."    JUGAR      - para explicarte las opciones basicas." CR
	."    NIVEL      - para explicarte los niveles de juego." CR
	."    DIFICULTAD - para explicarte los niveles de dificultad." CR
	."    PISTA      - para explicarte algunos trucos." CR
	."    ADIVINA    - para explicarte como indicar el numero que crees que hay que adivinar." CR
	."    FORTH      - para explicarte un poco del lenguaje usado para crear este programa." CR
	."    Tambien puedes escribir AYUDA-XXX, donde XXX es una de las palabras anteriores." CR
	."    Escribe AYUDA para ver esta ayuda." ;

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
	."    num ADIVINA (o num A-N o num ??) y te dire si lo has acertado, " CR
	."    o si el numero indicado es menor o mayor que el numero a adivinar." CR
	."    Si indicas un numero menor o mayor de los ya indicados no se cuenta como intento." CR
	1 AYUDA-PISTA CR
	." Si quieres que yo adivine el numero escribe OPCIONES-SOLO y veras las opciones de juego automatico."
;
: AYUDA-NIVEL
	DEPTH 0= IF CR ." La ayuda de NIVEL" CR CR ELSE DROP THEN
	." Escribe n NIVEL ( n del 1 al " NIVELMAXIMO ?  ." ) para generar un numero de 1 al n * 100." CR
	."     Escribe 0 NIVEL para generar un nivel aleatorio entre 1 y " NIVELMAXIMO @ STR ." ." CR
	."     Al indicar un nivel, se reiniciara el numero a adivinar y los intentos, etc." CR
	VER-NIVELES ;

: AYUDA-DIFICULTAD
	DEPTH 0= IF CR ." La ayuda de DIFICULTAD" CR ELSE DROP THEN
	DIFICULTADES-MOSTRAR ;

: AYUDA-ADIVINA
	DEPTH 0= IF CR ." La ayuda de ADIVINA" CR CR ELSE DROP THEN
	." Escribe num ADIVINA (o num A-N o num ??) y te dire si lo has acertado," CR
	."     o si el numero indicado es menor o mayor que el numero a adivinar." CR
	." Escribe A-N? si quieres que el ordenador te diga que numero elegiria." CR
	."    Sera como si hubieras escrito ese numero seguido de ADIVINA." CR
	CR
	." Escribe NUMS? para ver los numeros que has indicado " 
	." y si son menor o mayor que el que hay que adivinar." CR	
;

\ Mostrar la ayuda / inicio del programa con las palabras a usar

\ v1.100 comento HELP1 y HELP2 porque ya no se usan
(
\ No mostrar que se puede usar el nivel, para mostrar esta ayuda desde NIVEL
: HELP2   
	1 AYUDA-ADIVINA CR
	." Escribe PISTA y te mostrare como de cerca estas de adivinar el numero." CR
	." Para ver la solucion escribe RESUELVE, RES o ME-RINDO." CR
	." Para reiniciar el juego escribe JUGAR o cambia de NIVEL." CR
	DIFICULTADES-MOSTRAR
;

: HELP1   
	VERSION-ADIVINA CR
	1 AYUDA-NIVEL
	CR HELP2 CR
	." Si quieres que yo adivine el numero escribe OPCIONES-SOLO " 
	." y veras las opciones de juego automatico." CR
;
)

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
		IF ." (era menor) "
		ELSE ." (era mayor) "
		THEN 
	THEN
;

\ Asigna el nivel de dificultad indicado en la pila 
\	comprueba si el valor es válido y asigna el número máximo de intentos
\	no muestra info del nivel de dificultad.
: DIFICULTAD!   ( n -- )
	NIVELDIFICULTAD !
	
	\ Comprobar si el nivel es el adecuado
	
	\ NIVELDIFICULTAD @ _SENCILLO < NIVELDIFICULTAD @ _MAESTRO > OR
	\ \ asignar _SENCILLO si no es un valor entre _SENCILLO y _MAESTRO
	\ IF _SENCILLO NIVELDIFICULTAD ! THEN
	
	\ v1.104 si es menor que _SENCILLO asignar _SENCILLO
	NIVELDIFICULTAD @ _SENCILLO <
	IF _SENCILLO NIVELDIFICULTAD ! 
	ELSE
		\ v1.104 si es mayor que _MAESTRO asignar _MAESTRO
		NIVELDIFICULTAD @ _MAESTRO >
		IF _MAESTRO NIVELDIFICULTAD ! THEN
	THEN
	
	\ y asignar el valor a INTENTOSMAXIMO
	NIVELDIFICULTAD @ DIFICULTAD-N INTENTOSMAXIMO !
;

\ v1.103 asignar un valor aleatorio a NIVELDIFICULTAD
\ Lo asigno mediante DIFICULTAD! para que asigne INTENTOSMAXIMO
: DIFICULTAD-RANDOM _SENCILLO _MAESTRO random2 DIFICULTAD! ;

\ Asigna el nivel de dificultad, 
\	comprueba si el valor es válido y asigna el número máximo de intentos
\	muestra info del nivel de dificultad.
: DIFICULTAD
	\ Solo asignar si hay número indicado, 03-ene-2023 15.16
	DEPTH 0>
	IF
		DUP
		\ v1.105 si el valor indicado es 0 asignar un valor aleatorio
		0> IF DIFICULTAD! ELSE DROP DIFICULTAD-RANDOM THEN
	THEN
	\ Mostrar siempre el nivel de DIFICULTAD
	CR DIFICULTAD-MOSTRAR
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
	\ No mostrar los intentos, si INTENTOS es cero
	INTENTOS @ 0= 
	IF ." Aun no hay intentos." EXIT THEN
	CR
	."  Intento -   Numero  (mayor-menor) "
	\ mostrar el total de intentos
	INTENTOSMAXIMO @ 0
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
: INC-INTENTOS   INTENTOS @ 1 + INTENTOS ! ;

\ v1.19 El rango del número a adivinar
\ v1.29 Ahora los valores de MENORINDICADO y MAYORINDICADO son el menor y el mayor indicado.
\ 	Si está entre 48 y 50 solo hay una posibilidad, el 49
\ 	Si está entre 47 y 50 hay 2 posibilidades: 48 y 49
\	Cambio N.POSIBLES por N-POSIBLES
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
: QUEDAN-INTENTOS
	\ v1.46 Aclaración:
	\	QUEDAN-INTENTOS se llama desde ADIVINA si el número es menor o mayor
	\		también se llama desde PISTA
	\	Por tanto, debe ser INTENTOS @ INTENTOSMAXIMO @ >= 
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
\	Si el número indicado no está entre los "posibles" avisar y no asignarlo.
\	Si el número indicado es mayor del máximo avisar y no asignarlo.

\ v1.23 comprobar si el número indicado es aceptable.
\	Devuelve FALSE si no se acepta el número
\ v1.100 cambio GUESS? por NUMEROCORRECTO?
: NUMEROCORRECTO?
	\ v1.23 Si el número es menor que 1, avisar y no tenerlo en cuenta.
	NUMEROINDICADO @ 0 <=
	IF ." El numero debe ser mayor que cero. " FALSE
	ELSE
		\ v1.10 comprobar si el número es mayor del máximo
		\ 	Si es así, avisar y no tenerlo en cuenta
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
			INSTRUCCIONES-MOSTRAR
		ELSE
			\ incrementar el número de intentos
			INC-INTENTOS 
			\ v1.26 guardar el número en el array después de incrementar
			\ pero restando uno ya que el índice es en base cero
			NUMEROINDICADO @ INTENTOS @ 1 - NUMS!
			\ si lo ha adivinado
			NUMEROINDICADO @ NUMEROADIVINAR @ = 
			IF MOSTRAR-CORRECTO
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

\ v1.54 A-N como ADIVINA / GUESS
: A-N   ADIVINA ;
\ v1.55 defino N-A por si lo escribo al revés
\ v1.94 quito la definición de N-A
\ : N-A   ADIVINA ;
\ v1.91 defino ?? como alias de ADIVINA
: ??   ADIVINA ;

\ v1.57 cambio el sitio de estas palabras porque A-N? usa ADIVINA

\ v1.24 Poner en la pila el siguiente número a comprobar.
\	Media = (Mayor - Menor) / 2
\	Siguiente = Menor + Media
\	El valor devuelto es el número sin decimales: 14.5 -> 14
\ En gForth está definido NEXT, pero no en SwiftForth
\ v1.56 cambio el nombre de N.NEXT a N-NEXT
: N-NEXT   ( -- MAYORINDICADO MENORINDICADO - 2 / MENORINDICADO + )
	\ v1.29 comprobar si es cero
	MAYORINDICADO @ MENORINDICADO @ - 0= 
	IF MAYORINDICADO @ 1 - ." SE ASIGNA " MAYORINDICADO @ 1 - STR
	ELSE
		MAYORINDICADO @ MENORINDICADO @ - 2 / MENORINDICADO @ +
	THEN
;

\ Saca el siguiente valor, lo muestra y deja una copia en la pila, para poder usarlo con ADIVINA
\ v1.56 cambio el nombre de NEXT? a N-NEXT?
: N-NEXT?   N-NEXT DUP . ;

\ v1.24 Elegir el siguiente número recomendado para adivinar usando N-NEXT
\ v1.56 cambio el nombre N.G? a A-N?
: A-N?   N-NEXT? ADIVINA ;

\ Devuelve TRUE si el número es el correcto o se han pasado los intentos
\ 	Se usa cuando juega automáticamente/solo
\ v1.47 cambio el nombre de ADIVINADO a SEGUIR-BUCLE
: SEGUIR-BUCLE
	\ Considerarlo adivinado si lo ha adivinado o se ha pasado del número de intentos
	\ v1.50 tener también en cuenta si se ha mostrado la solución
	NUMEROINDICADO @ NUMEROADIVINAR @ = 
	INTENTOS @ INTENTOSMAXIMO @ > OR
	SOLUCIONMOSTRADA @ OR
;

\ Resolver el juego = mostrar la solución y los intentos pendientes
: RESUELVE   
	." Te quedan " INTENTOSMAXIMO @ INTENTOS @ - . ." intentos. "
	." El numero a adivinar es " NUMEROADIVINAR @ STR ." ."
;

: ME-RINDO   RESUELVE ;
\ v1.22 RES es como RESUELVE antes era R
: RES   RESUELVE ;

\ v1.20 defino todo esto después de HELP1 y HELP2 porque en PISTA se usa HELP1

\ v1.19 mostrar textos según las posibilidades que tenga de adivinarlo.
\ v1.106 cambio HUMOR-HINT por HUMOR-PISTA
: HUMOR-PISTA
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
: PISTA
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
: NIVEL?   
	\ comprobar si el NIVEL es correcto 
	\ si el nivel es menor de 1, asignar un nivel aleatorio entre 1 y NIVELMAXIMO 
	ELNIVEL @ 1 < 
	IF 
		\ Sacar un valor aleatorio
		NIVEL-RANDOM  
		\ ." (nivel aleatorio, el nuevo nivel es " ELNIVEL ? ." )"
	THEN
	\ si el nivel es mayor de NIVELMAXIMO, asignar NIVELMAXIMO
	ELNIVEL @ NIVELMAXIMO @ > 
	IF NIVELMAXIMO @ ELNIVEL !  THEN
;

\ v1.22 crear un numero aleatorio según el nivel 
\ Se comprueba si el nivel es correcto y si no, se asigna del 1 al NIVELMAXIMO
\ Se muestra el nivel a usar, etc.
: NUEVO-NUM   
	NIVEL? 
	\ asignar el número aleatorio
	1 100 ELNIVEL @ * random2 NUMEROADIVINAR ! 
;

\ Reiniciar el juego, asignando los valores predeterminados, etc.
: REINICIAR 
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
	\ CR ." Se han reiniciado los valores y el numero a adivinar." CR
	\ v1.102 Si no hay valor en la pila, mostrar los niveles de juego.
	\ Si hay, quitarlo
	DEPTH 0= 
	IF
		CR ." Se han reiniciado los valores y el numero a adivinar." CR
		VER-NIVELES
	ELSE DROP
	THEN
;

\ Iniciar el juego, poner todos los valores a cero
\ No mostrar la ayuda ni nada
: JUGAR   
	\ v1.102 poner un valor en la pila para que no se muestren los niveles
	1 REINICIAR 
	\ Asignar que juega el humano
	_HUMANO QUIENJUEGA !
	CR
	." Adivina el numero que he elegido." CR 
	."     Es un numero entre 1 y " EL-MAXIMO . ." ambos inclusive." CR
	."     Tienes " NIVELDIFICULTAD @ DIFICULTAD-N . ." intentos para adivinarlo." CR
	." Si quieres cambiar el nivel o el numero de intentos escribe " CR
	."     n NIVEL o n DIFICULTAD." CR
	." Escribe tu numero seguido de ADIVINA (o A-N o ??)."
	\ No mostrar ok
	QUIT
;

\ v1.101 Nivel solo cambia el nivel, no inicia el juego

\ Si se indica un valor asignar el nivel, reiniciar los valores y mostrar el nivel actual.
\ v1.80 si no se indica el nivel, mostrar el nivel actual.
: NIVEL   ( n -- ) 
	\ Solo asignar si hay número indicado, 03-ene-2023 15.18
	\ Si es así, llamar a REINICIAR de forma que muestre el nivel.
	DEPTH 0> 
	IF ELNIVEL ! REINICIAR 
	ELSE CR NIVEL-MOSTRAR
	THEN
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
	1 REINICIAR
	\ Asignar que juega la máquina
	_MAQUINA QUIENJUEGA !
	\ Mostrar que se juega automáticamente
	CR
	." Juego automaticamente, ire mostrando los numeros elegidos y si lo acierto. " CR
	." Estoy jugando con el NIVEL: " ELNIVEL ? 
	." tengo que adivinar un numero del 1 al " EL-MAXIMO STR ." ." CR
	." El nivel de DIFICULTAD es " NIVELDIFICULTAD @ DIFICULTAD-$ CR
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
	SOLUCIONMOSTRADA @
	IF CR CR ." Me he pasado del numero de intentos :-( " CR
		."     Tengo que mejorar con el NIVEL: " ELNIVEL ? 
		." y el nivel de DIFICULTAD " NIVELDIFICULTAD @ DIFICULTAD-$ CR
		1000 MS
	THEN
;

\ JUGAR-SOLO-AUTO elige al azar el NIVEL y DIFICULTAD
: JUGAR-SOLO-AUTO
	1 NIVELMAXIMO @ random2 ELNIVEL !
	_SENCILLO _MAESTRO random2 NIVELDIFICULTAD !
	JUGAR-SOLO
;

\ JUGAR-SOLO-FACIL juega con un NIVEL entre 1 y 5 y con el nivel de DIFICULTAD entre _SENCILLO y _MEDIO
: JUGAR-SOLO-FACIL
	1 5 random2 ELNIVEL !
	_SENCILLO _MEDIO random2 NIVELDIFICULTAD !
	JUGAR-SOLO
;

\ JUGAR-SOLO-DIFICIL para probar con nivel NIVELMAXIMO - 4 a NIVELMAXIMO y DIFICULTAD _DIFICIL a _MAESTRO
: JUGAR-SOLO-DIFICIL
	NIVELMAXIMO @ 4 - NIVELMAXIMO @ random2 ELNIVEL !
	_DIFICIL _MAESTRO random2 NIVELDIFICULTAD !
	JUGAR-SOLO
;

\ *******************************************************************
\ Para mostrar la ayuda                           (30/dic/22 16.46) *
\ *******************************************************************

\ Convertir el contenido de QUE.AYUDA en mayúsculas
: QUEAYUDA-TOUPPER
    QUE.AYUDA MAX_AYUDA -TRAILING BOUNDS
    ?DO I c@ toupper I c! LOOP 
;

\ El número de elementos de $AYUDAS
6 CONSTANT %AYUDAS
\ Definir el array de las ayudas
CREATE $AYUDAS
    $" GENERAL" ,
    $" JUGAR" ,
    $" NIVEL" ,
    $" DIFICULTAD" ,
    $" PISTA" , 
    $" ADIVINA" ,
    $" FORTH" ,

\ Se accede siempre de 0 a 5 %AYUDAS
: $AYUDA
    \ Que solo acepte valores entre %AYUDAS y 0  03-ene-2023 13.25
    %AYUDAS MIN 0 MAX 
    \ Deja en la pila la dirección de $AYUDAS del índice que está en la pila
    $AYUDAS SWAP CELLS + @ 
    \ Dejar también cuántos caracteres tiene
    COUNT
;

: AYUDA-SEE
	LIMPIAR-PILA
    QUEAYUDA-TOUPPER
    QUE.AYUDA MAX_AYUDA -TRAILING
    %AYUDAS 1+ 0
    DO 
    	2DUP
        I $AYUDA COMPARE 0=
        IF 2DROP I LEAVE THEN
    LOOP
    \ Cuando llegue aquí solo debe haber un valor en la pila
    \ Si hay más es que no se ha encontrado
    DEPTH 1 > IF LIMPIAR-PILA 0 THEN
    \ Mostrar la ayuda del valor dejado en la pila
	CASE 
		0 OF AYUDA-GENERAL ENDOF
		1 OF AYUDA-JUGAR ENDOF
		2 OF AYUDA-NIVEL ENDOF
		3 OF AYUDA-DIFICULTAD ENDOF
		4 OF AYUDA-PISTA ENDOF
		5 OF AYUDA-ADIVINA ENDOF
		6 OF AYUDA-FORTH ENDOF
	ENDCASE
;
	

( Comentado 02-ene-2023 23.58

\ Esto usa el "array" AYUDAS con longitud fija de 10 caracteres
\ Esto solo sirve si se usa AYUDA-SEE con las comparaciones
: AYUDAS  \ -- addr
   \ C" JUGAR     jugar     NIVEL     nivel     DIFICULTADdificultadPISTA     pista     ADIVINA   adivina   " ;
   \ C" JUGAR     NIVEL     DIFICULTADPISTA     ADIVINA   " ;
   C" GENERAL   JUGAR     NIVEL     DIFICULTADPISTA     ADIVINA   " ;

: .AYUDAS  \ index -- addr
   10 *  AYUDAS 1+  +  10 -TRAILING
;

: AYUDA-SEE-OK
    \ Convierte en mayúsculas el contenido de QUE.AYUDA
    QUEAYUDA-TOUPPER
    \ Devuelve la dirección de memoria y longitud de QUE.AYUDA
    QUE.AYUDA MAX_AYUDA -TRAILING
    \ Hacer copia para cada una de las comparaciones menos una
    2DUP 2DUP 2DUP 2DUP 2DUP
    \ Comnprobarlo con cada uno de los valores del array "AYUDAS"
    1 .AYUDAS COMPARE 0= IF LIMPIAR-PILA AYUDA-JUGAR EXIT THEN
    2 .AYUDAS COMPARE 0= IF LIMPIAR-PILA AYUDA-NIVEL EXIT THEN
    3 .AYUDAS COMPARE 0= IF LIMPIAR-PILA AYUDA-DIFICULTAD EXIT THEN
    4 .AYUDAS COMPARE 0= IF LIMPIAR-PILA AYUDA-PISTA EXIT THEN
    5 .AYUDAS COMPARE 0= IF LIMPIAR-PILA AYUDA-ADIVINA EXIT THEN
    LIMPIAR-PILA AYUDA-GENERAL
;
)

(
\ Usar "punteros" a las palabras para acceder a las ayudas
Create *AYUDAS 
	' AYUDA-GENERAL , 
	' AYUDA-JUGAR , 
	' AYUDA-NIVEL , 
	' AYUDA-DIFICULTAD , 
	' AYUDA-PISTA , 
	' AYUDA-ADIVINA , 

: QUEAYUDA-INDEX   \ -- #index
	QUEAYUDA-TOUPPER
    QUE.AYUDA MAX_AYUDA -TRAILING
    2DUP 2DUP 2DUP 2DUP 2DUP
    1 .AYUDAS COMPARE 0= IF LIMPIAR-PILA 1 EXIT THEN
    2 .AYUDAS COMPARE 0= IF LIMPIAR-PILA 2 EXIT THEN
    3 .AYUDAS COMPARE 0= IF LIMPIAR-PILA 3 EXIT THEN
    4 .AYUDAS COMPARE 0= IF LIMPIAR-PILA 4 EXIT THEN
    5 .AYUDAS COMPARE 0= IF LIMPIAR-PILA 5 EXIT THEN
    LIMPIAR-PILA 0
;

\ Usando *AYUDAS y QUEAYUDA-INDEX, 01-ene-2023 20.40
: AYUDA-SEE-PUNTEROS
    \ Averiguar el índice en .AYUDAS
    QUEAYUDA-INDEX
    \ Si no hay nada en la pila usar 0
    DEPTH 0= IF 0 THEN
    \ Esto ejecuta la definicion de *AYUDAS del índice indicado
    CELLS *AYUDAS + @ EXECUTE
;
)

: AYUDA
    \ Acepta más de una palabra, hasta que se pulsa INTRO
    1 TEXT PAD QUE.AYUDA MAX_AYUDA MOVE
    AYUDA-SEE
;

\ v1.64 borrar el contenido de la pantalla
PAGE 

\ Iniciar la semilla del número aleatorio
randomize 
\ Empezar un un nivel al azar
NIVEL-RANDOM
\ Jugar con el nivel _MEDIO de DIFICULTAD
\ _MEDIO DIFICULTAD
\ Usar esto para que no se muestre el nivel de dificultad
_MEDIO DIFICULTAD!
\ DIFICULTAD-RANDOM

\ v1.63 empezar mostrando la ayuda general
AYUDA-GENERAL
\ AYUDA
