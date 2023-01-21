(
    Basado en el ejemplo de DIGITS de CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY
    de la carpeta 4th\apps\basic\digits.bas

include digits-bas.forth
)

\ Marcar que se han cargado las palabras
[DEFINED] digits-bas.forth [IF]
    digits-bas.forth
[THEN]
marker digits-bas.forth

\ Algunas palabras genéricas
include util.forth

: VERSION-DIGITS   ( -- ) ." *** Digits Forth v1.9 (18-ene-2023 09.37) *** " ;

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
: RESPUESTA!   ( addr len -- ) 'RESPUESTA >LIMPIAR RESPUESTA SWAP MOVE ;
\ La longitud actual de RESPUESTA
: RESPUESTA-LEN   ( -- len ) 'RESPUESTA SWAP DROP ;
\ Limpiar el contenido de RESPUESTA con espacios
: RESPUESTA-LIMPIAR   ( -- ) 'RESPUESTA BLANK ;


\ : INPUT   ( addr1 len1 addr2 len2 -- ) PREGUNTA? ;

\ Pide un número
\   addr1 len1 el texto a mostrar
\   devuelve un número
: INPUTN   ( addr1 len1 -- n )
    RESPUESTA MAX_RESP
    PREGUNTA?
    \ Si no se ha escrito nada, poner 0 como respuesta
    RESPUESTA-LEN 0 = IF s" 0" RESPUESTA! THEN
    'RESPUESTA to?u
    \ si el top de la pila es false, es que tenía letras,
    \   en ese caso, dejar NO_NUM en la pila
    NOT IF DROP NO_NUM THEN
;

\ Muestra por consola el texto indicado y un cambio de línea
: PRINT   ( addr len -- )
    TYPE CR ;

\ Defino las variables con sufijo -digits
\ 360 A = 0 : B = 1 : C = 3
VARIABLE A-digits
\ B está definida en SwiftForth
VARIABLE B-digits
VARIABLE C-digits
\ 480 Z=26: K=8: L=2
VARIABLE Z-digits
\ K... k? son palabras en gForth
VARIABLE K-digits
\ L está definida en SwiftForth
VARIABLE L-digits
\ 510 X=0
VARIABLE X-digits
\ 570 W=@(117+I)-1
\ VARIABLE W-digits
\ 670 N=@(U+117): S=0
\ N está definida en SwiftForth
VARIABLE N-digits
VARIABLE S-digits
\ 700 D=A*@(L*3+J+81)+B*@(K*3+J+90)+C*@(Z*3+J)
VARIABLE D-digits
\ 740 S=D: G=J
\ G está definida en SwiftForth
VARIABLE G-digits

150 CONSTANT MAX_NUMS
MAX_NUMS ARRAY NUMS

\ : NUMS!   ( n INDEX# -- ) NUMS ! ;
\ : NUMS@   ( INDEX# -- n ) NUMS @ ;
\ : NUMS?   ( INDEX# -- ) NUMS ? ;
\ Incrementa en 1 el índice indicado
: NUMS+1   ( INDEX# -- ) DUP NUMS @ 1+ SWAP NUMS ! ;

\ 380 REM DIM M(27,3),K(3,3)=81,L(9,3)=90:N(10)=117
\ M => NUMS de 0 a 27
\ K => NUMS +81
\ L => NUMS + 90
\ N => NUMS + 117

\ Para salir de los BEGIN/UNTIL
VARIABLE TERMINAR

\ : digits-bas   ( -- )
: digits   ( -- )
    \ flag para saber si terminamos el juego
    FALSE TERMINAR !
    CR 15 SPACES VERSION-DIGITS 
    CR
    \ 10 REM PRINT TAB(33);"DIGITS"
    33 SPACES ." DIGITS" CR
    \ 20 REM PRINT TAB(15);"CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY"
    16 SPACES ." CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY" CR
    \ 30 REM PRINT:PRINT:PRINT
    CR CR CR
    ." THIS IS A GAME OF GUESSING." CR
    \ 220 INPUT "FOR INSTRUCTIONS, TYPE '1', ELSE TYPE '0' ";E
    s" FOR INSTRUCTIONS, TYPE '1', TO END GAME TYPE '3' ELSE START GAME ? "
    INPUTN
    DUP 3 = IF DROP CR CR ." TO PLAY THE GAME TYPE 'DIGITS'" CR EXIT THEN
    \ RESPUESTA MAX_RESP INPUT \ 230
    \ 240 IF E=0 THEN GOTO 360
    \ RESPUESTA C@ [CHAR] 1 = 
    1 = 
    IF RESPUESTA 
        CR \ 250 PRINT
        s" PLEASE TAKE A PIECE OF PAPER AND WRITE DOWN" PRINT \ 260
        s" THE DIGITS '0', '1', OR '2' THIRTY TIMES AT RANDOM." PRINT \ 270
        s" ARRANGE THEM IN THREE LINES OF TEN DIGITS EACH." PRINT \ 280
        s" I WILL ASK FOR THEN TEN AT A TIME." PRINT \ 290
        s" I WILL ALWAYS GUESS THEM FIRST AND THEN LOOK AT YOUR" PRINT \ 300
        s" NEXT NUMBER TO SEE IF I WAS RIGHT. BY PURE LUCK," PRINT \ 310
        s" I OUGHT TO BE RIGHT TEN TIMES. BUT I HOPE TO DO BETTER" PRINT \ 320 
        s" THAN THAT *****" PRINT \ 330 
        CR CR \ 340 PRINT:PRINT
    THEN 
    \ 360 A = 0 : B = 1 : C = 3
    0 A-digits ! 1 B-digits ! 3 C-digits !
    \ 380 REM DIM M(27,3),K(3,3)=81,L(9,3)=90:N(10)=117
    BEGIN
        \ 400 FOR I=0 TO 26: FOR J=0 TO 2: @(I*3+J)=1: NEXT J: NEXT I
        27 0 DO 3 0 DO 1 J 3 * I + NUMS ! LOOP LOOP \ J es bucle exterior, I es el interior
        \ 410 FOR I=0 TO 2: FOR J=0 TO 2: @(I*3+J+81)=9: NEXT J: NEXT I
        3 0 DO 3 0 DO 9 J 3 * I + 81 + NUMS ! LOOP LOOP \ J es bucle exterior, I es el interior
        \ 420 FOR I=0 TO 8: FOR J=0 TO 2: @(I*3+J+90)=3: NEXT J: NEXT I
        9 0 DO 3 0 DO 3 J 3 * I + 90 + NUMS ! LOOP LOOP \ J es bucle exterior, I es el interior
        \ 450 @(90)=2: @(4*3+91)=2: @(8*3+92)=2
        2 90 NUMS ! 2 4 3 * 91 + NUMS ! 2 8 3 * 92 + NUMS !
        \ 480 Z=26: K=8: L=2
        26 Z-digits ! 8 K-digits ! 2 L-digits !
        \ 510 X=0
        0 X-digits !
        \ 520 FOR T=1 TO 3
        4 1
        DO 
            CR \ 530 PRINT
            CR s" TEN NUMBERS, PLEASE" PRINT \ 540 PRINT "TEN NUMBERS, PLEASE"
            \ 550 FOR M=1 TO 10 : PRINT M;": "; : INPUT @(117+M) : NEXT M
            11 1
            DO 
                BEGIN
                    \ mostrar el número con 2 espacios
                    I 2 U.R S" : ( 0, 1 OR 2, 3= END GAME)? " INPUTN
                    DUP 3 = IF DROP CR ." END ACTUAL GAME" CR TRUE TERMINAR ! LEAVE THEN
                    DUP 0 3 WITHIN
                    IF TRUE
                    ELSE 
                        DROP FALSE CR s" ONLY USE THE DIGITS '0', '1', OR '2'." PRINT
                    THEN
                UNTIL
                \ s" despues de until en do M " DEBUG1
                \ INPUT @(117+M) \ M es la variable del bucle
                I 117 + NUMS !
                CR
            LOOP \ NEXT M
            \ s" despues de loop M " DEBUG1
            TERMINAR @ TRUE = IF LEAVE THEN
            \ 560 FOR I=1 TO 10
            \ 570 W=@(117+I)-1
            \ 580 IF (W>-2) * (W<2) THEN GOTO 620
            \ 590 PRINT "ONLY USE THE DIGITS '0', '1', OR '2'."
            \ 600 PRINT "LET'S TRY AGAIN.":GOTO 530
            \ 620 NEXT I
            \ 630 PRINT: PRINT "MY GUESS","YOUR NO.","RESULT","NO. RIGHT":PRINT
            CR 
            ." MY GUESS YOUR NO. RESULT   NO. RIGHT" CR
            ." -------- -------- -------- ---------" CR
            \ 660 FOR U=1 TO 10
            11 1 
            DO 
                \ 670 N=@(U+117): S=0 \ U = la variable del bucle
                I 117 + NUMS @ N-digits ! 0 S-digits !
                \ 690 FOR J=0 TO 2
                3 0 
                DO
                    \ 700 D=A*@(L*3+J+81)+B*@(K*3+J+90)+C*@(Z*3+J) / J es la variable del bucle
                    L-digits @ 3 * I + 81 + A-digits @ *
                    K-digits @ 3 * I + 90 + B-digits @ * +
                    Z-digits @ 3 * I + C-digits @ * +
                    D-digits !
                    \ 710 IF S>D THEN GOTO 760 \ Si no se cumple pasa a 720
                    S-digits @ D-digits @ > NOT
                    IF
                        \ 720 IF S<D THEN GOTO 740 \ Si no se cumple pasa a 730
                        S-digits @ D-digits @ DUP < NOT
                        IF
                            \ 730 IF RND(100)<50 THEN GOTO 760 \ Si no se cumple pasa a 740
                            DROP
                            100 random 50 < NOT
                        THEN
                        IF
                            \ 740 S=D: G=J \ J es la variable del bucle
                            D-digits @ S-digits ! I G-digits !
                        THEN
                    THEN
                LOOP \ 760 NEXT J
                \ 770 PRINT "  ";G,"   ";@(U+117), \ U es la variable del bucle
                G-digits @ 8 U.R ."  " 117 I + NUMS @ 8 U.R
                \ 780 IF G=@(U+117) THEN GOTO 810 \ U es la variable del bucle
                I 117 + NUMS @ G-digits @ =
                IF
                    \ 810 X=X+1
                    X-digits @ 1 + X-digits !
                    \ 820 PRINT " RIGHT",X
                    ."  RIGHT    " X-digits @ 8 U.R CR
                    \ donde se asigna se pone al final
                    \ Líneas 830, 840 y 850 incrementan 1 el contenido del índice indicado
                    \ 830 @(Z*3+N)=@(Z*3+N)+1
                    \ Z-digits @ 3 * N-digits @ + NUMS @ 1+   Z-digits @ 3 * N-digits @ + NUMS !
                    Z-digits @ 3 * N-digits @ + NUMS+1
                    \ 840 @(K*3+N+90)=@(K*3+N+90)+1
                    \ K-digits @ 3 * N-digits @ + 90 + NUMS @ 1+   K-digits @ 3 * N-digits @ + 90 + NUMS !
                    K-digits @ 3 * N-digits @ + 90 + NUMS+1
                    \ 850 @(L*3+N+81)=@(L*3+N+81)+1
                    \ L-digits @ 3 * N-digits @ + 81 + NUMS @ 1+    L-digits @ 3 * N-digits @ + 81 + NUMS !
                    L-digits @ 3 * N-digits @ + 81 + NUMS+1
                    \ 860 Z=Z-(Z/9)*9
                    Z-digits @ 9 / 9 * Z-digits @ -   Z-digits !
                    \ 870 Z=3*Z+@(U+117)
                    Z-digits @ 3 * I 117 + NUMS @ +   Z-digits !
                ELSE
                    \ 790 PRINT " WRONG",X
                    ."  WRONG    " X-digits @ 8 U.R CR
                    \ 800 GOTO 880
                THEN
                \ 880 K=Z-(Z/9)*9
                Z-digits @ 9 / 9 * Z-digits @ -   K-digits !
                \ 890 L=@(U+117)
                I 117 + NUMS @   L-digits !
            LOOP \ 900 NEXT U
            TERMINAR @ TRUE = IF LEAVE THEN
        LOOP \ 910 NEXT T
        TERMINAR @ FALSE = 
        IF
            CR \ 920 PRINT
            \ 930 IF X>10 THEN GOTO 980
            X-digits @ 10 >
            IF
                \ 980 PRINT "I GUESSED MORE THAN 1/3 OF YOUR NUMBERS."
                \ 990 PRINT "I WIN."
                \ 1000 GOTO 1030
                s" I GUESSED MORE THAN 1/3 OF YOUR NUMBERS." PRINT
                s" I WIN." PRINT
            ELSE
                \ 940 IF X<10 THEN GOTO 1010
                X-digits @ 10 <
                IF
                    \ 1010 PRINT "I GUESSED LESS THAN 1/3 OF YOUR NUMBERS."
                    \ 1020 PRINT "YOU BEAT ME.  CONGRATULATIONS *****"
                    s" I GUESSED LESS THAN 1/3 OF YOUR NUMBERS." PRINT
                    s" YOU BEAT ME.  CONGRATULATIONS *****" PRINT
                ELSE
                    \ 950 PRINT "I GUESSED EXACTLY 1/3 OF YOUR NUMBERS."
                    \ 960 PRINT "IT'S A TIE GAME."
                    \ 970 GOTO 1030
                    s" I GUESSED EXACTLY 1/3 OF YOUR NUMBERS." PRINT
                    s" IT'S A TIE GAME." PRINT
                THEN
            THEN
        THEN
        CR \ 1030 PRINT
        \ 1040 INPUT "DO YOU WANT TO TRY AGAIN (1 FOR YES, 0 FOR NO) ";X
        S" DO YOU WANT TO TRY AGAIN (1 FOR YES, 0 FOR NO) ? " INPUTN
        X-digits !
        \ 1070 IF X=1 THEN GOTO 400
        X-digits @ 1 =
        IF CR FALSE ELSE TRUE THEN
    UNTIL
    \ 1080 PRINT:PRINT "THANKS FOR THE GAME."
    CR s" THANKS FOR THE GAME." PRINT
    \ 1090 END
;

: prueba-input
    cr s" Escribe 1, 0 o X ? "
    INPUTN
    \ DUP
    CR ." Tu respuesta es: " .
;

CR CR ." Escribe DIGITS para jugar " CR
\ CR CR ." Empezamos el juego"
\ digits
