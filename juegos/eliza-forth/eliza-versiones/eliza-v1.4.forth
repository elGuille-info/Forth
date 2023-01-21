\ *********************************************************
\ Adaptación de Eliza.4tH para usar con gForth y SwiftForth
\
\ por Guillermo Som (Guille), 18-ene-2023 17.30
\ *********************************************************

( Para cargar este fichero
include eliza.forth
)

\ Marcar que se han cargado estas palabras, 18-ene-2023 17.30
[DEFINED] eliza.forth [IF]
    eliza.forth
[THEN]
marker eliza.forth

: VERSION-ELIZA   ( -- ) ." *** Eliza Forth v1.4 (20-ene-2023 13.28) *** " ;

\ v1.4 (20-ene-2023 13.28)
\   Creo palabras de prueba para acceder a las definiciones, etc.

\ v1.3 (20-ene-2023 12.45)
\   Quito los nombres: string-eliza, current-eliza y previous-eliza
\   y dejo los originales: string, current y previous

\ 4tH ELIZA - Copyright 2004,2014 J.L. Bezemer
\ You can redistribute this file and/or modify it under
\ the terms of the GNU General Public License

[UNDEFINED] talking [IF]
false constant talking                 \ use the festival speech synthesizer?
[THEN]

(
\ Este fichero está en otro directorio
include ./4th/lib/filter.4th
include ./4th/lib/replace.4th
include ./4th/lib/ulcase.4th
include ./4th/lib/startend.4th
include ./4th/lib/choose.4th

talking [IF]
include ./4th/lib/say.4th
[THEN]
)

\ Usando el definido en Forth-programming-language\util-forth, 20-ene-2023 10.13
\ include util.forth
include Forth-programming-language\util-forth\util.forth

: @C @ ;                               \ CROSS EXT
: TH 
    s"   al entrar en TH " debug1
    CELLS + 
    s"   al salir de TH " debug1
;
: R'@ POSTPONE R>  POSTPONE R@ POSTPONE SWAP POSTPONE >R  ; IMMEDIATE
: R"@ POSTPONE 2R> POSTPONE R@ POSTPONE -ROT POSTPONE 2>R ; IMMEDIATE

\ la definición de gForth es diferente, 19-ene-2023 09.23
\ pero funciona igual
: PLACE OVER OVER C! CHAR+ SWAP MOVE ;

S" MAX-N" ENVIRONMENT?                 \ query environment
[IF]                                   \ if successful
NEGATE 1- CONSTANT (ERROR)             \ create constant (ERROR)
\ [ELSE]
\ .( Warning: ) CHAR ( EMIT .( ERROR) CHAR ) EMIT .(  undefined) CR
[THEN]

S" MAX-N" ENVIRONMENT?                 \ query environment
[IF]                                   \ if successful
CONSTANT MAX-N                         \ create constant MAX-N
[THEN]

\ De constant.4th
\ [UNDEFINED] NULL [IF]
(error) constant NULL                  ( NULL pointer)
\ [THEN]


\ De filter.4th
[UNDEFINED] filter [IF]
: filter                               ( a n1 c -- a n2)
  >r >r dup dup dup dup r> chars + >r  \ setup parameters
  begin                               
    begin                              \ search non-filter character
      dup r@ <> dup                    \ end of line?
      if over c@ r'@ = over and else dup then
    while                              \ is it the filter character?
      drop char+                       \ if not, next character
    repeat                             \ and drop the flag
  while                                \ store the character
     swap >r dup c@ r@ c! char+ r> char+ swap
  repeat                               \ calculate length new string
  r> r> drop drop drop swap chars -
;
[THEN]

\ De startend.4th
: starts? dup >r 2over r> min compare 0= ;
: ends? dup >r 2over dup r> - 0 max /string compare 0= ;

\ De replace.4th
: delete                        ( a1 n1 a2 n2 -- a1 n3 a2 n4 f)
  2>r 2dup 2r> dup >r search
  dup r> swap >r >r             ( a1 n1 a2 n2 f)
  if                            ( a1 n1 a2 n2)
    2swap r@ - 2swap r@ -       ( a1 n3 a2 n4)
    2dup over r@ chars +        ( a1 n3 a2 n4 a3)
    -rot cmove                  ( a1 n3 a2 n4)
  then
  r> drop r>
;
: replace                       ( a1 n1 a2 n2 a3 n3 -- a1 n4 a4 n5 f)
  2>r delete dup 2r> rot >r 2>r
  if
    nip over swap - 2r> rot insert
  else
    2r> 2drop
  then
  r>
;

\ De random.4th
32767 constant max-rand               \ maximum random number

\ De choose.4th
[UNDEFINED] CHOOSE [IF]
\ : MANY   0 begin over over th @c NULL <> while 1+ repeat nip ;
: MANY   
    s" al entrar en many " debug1
    \ 0 begin over over th @c NULL <> while 1+ repeat nip ;
    0 begin 
    s"   en many al entrar en begin " debug1
    over over 
    s"   en many despues de over over " debug1
    th @c NULL <> 
    while 1+ 
    repeat nip
    s" al salir de many " debug1
;
: CHOOSE random * max-rand 1+ / ;
[THEN]

\ De istype.4th
[UNDEFINED] IS-ASCII [IF]
: IS-ASCII  ( char -- flag )  128 < ;
: IS-PRINT  ( char -- flag )  DUP IS-ASCII SWAP BL 1- - 0> AND ;
: IS-WHITE  ( char -- flag )  [CHAR] ! - 0< ;
: IS-DIGIT  ( char -- flag )  [CHAR] 0 - MAX-N AND 10 < ;
: IS-LOWER  ( char -- flag )  [CHAR] a - MAX-N AND 26 < ;
: IS-UPPER  ( char -- flag )  [CHAR] A - MAX-N AND 26 < ;
\ : IS-ALPHA  ( char -- flag )  BL OR IS-LOWER ;
\ : IS-ALNUM  ( char -- flag )  DUP IS-ALPHA SWAP IS-DIGIT OR ;
\ : IS-XML    ( char -- flag )  0 S| <>&"'| BOUNDS DO OVER I C@ = OR LOOP NIP ;
\ : IS-HTML   ( char -- flag )  DUP IS-XML SWAP IS-PRINT 0= OR ;
[THEN]

\ De ulcase.4th
[UNDEFINED] s>upper [IF]
defer case?
\ upper- lower-case conversions (character)
: ?case if bl xor then ;
: char>upper dup is-lower ?case ;    ( c1 -- c2)
: char>lower dup is-upper ?case ;    ( c1 -- c2)
\ upper- lower-case conversions (string)
: (case)
  is case? 2dup bounds ?do i c@ dup case? if bl xor i c! else drop then loop
;
: s>upper ['] is-lower (case) ;  ( a n -- a n)
: s>lower ['] is-upper (case) ;  ( a n -- a n)
\ [DEFINED] 4TH# [IF]
\   hide case?
\   hide ?case
\   hide (case)
\ [THEN]
[THEN]

\ Defino el string a usar en Eliza, 19-ene-2023 08.54
\ : string-eliza CREATE CHARS ALLOT ;
: STRING CREATE CHARS ALLOT ;

create fuck-you
  ," PERHAPS IN YOUR IMAGINATION WE FUCK ONE ANOTHER."
  ," I HAVE A HEADACHE TODAY. TOMORROW PERHAPS YOU MAY FUCK ME."
  NULL ,

create fuck
  ," DO YOU KISS YOUR MOTHER WITH THAT MOUTH?"
  ," WHAT GUTTER DID YOU GRADUATE FROM?"
  ," COMPUTERS AREN'T IMPRESSED BY VULGARITY."
  ," ILLEGITIMATE SON OF A MAGGOT! MIND YOUR TONGUE!"
  ," DOES IT MAKE YOU FEEL STRONG TO USE THAT KIND OF LANGUAGE?"
  ," ARE YOU VENTING YOUR FEELINGS NOW?"
  ," ARE YOU ANGRY?"
  ," DOES THIS TOPIC MAKE YOU FEEL ANGRY?" 
  ," IS SOMETHING MAKING YOU FEEL ANGRY?" 
  ," DOES USING THAT KIND OF LANGUAGE MAKE YOU FEEL BETTER?" 
  NULL ,

create hell
  ," I JUST SPENT 0.035 SEC IN HELL. HOW COULD YOU BE SO CRUEL AS TO SEND ME THERE?"
  ," DO YOU TALK THIS WAY WITH ANYONE ELSE, OR IS IT JUST ME?"
  NULL ,

create shit
  ," TELL ME ABOUT YOUR CHILDHOOD--WAS YOUR TOILET TRAINING DIFFICULT?"
  ," LET'S TRY TO KEEP THIS SESSION CLEAN, SHALL WE?"
  NULL ,

create family
  ," TELL ME MORE ABOUT YOUR FAMILY."
  ," HOW DO YOU GET ALONG WITH YOUR FAMILY?"
  ," IS YOUR FAMILY IMPORTANT TO YOU?"
  ," DO YOU OFTEN THINK ABOUT YOUR FAMILY?"
  ," HOW WOULD YOU LIKE TO CHANGE YOUR FAMILY?"
  NULL ,

create friend
  ," WHY DO YOU BRING UP THE TOPIC OF FRIENDS?"
  ," DO YOUR FRIENDS WORRY YOU?"
  ," DO YOUR FRIENDS PICK ON YOU?"
  ," ARE YOU SURE YOU HAVE ANY FRIENDS?"
  ," DO YOU IMPOSE ON YOUR FRIENDS?"
  ," PERHAPS YOUR LOVE FOR YOUR FRIENDS WORRIES YOU."
  ," WHY DO YOU BRING UP THE SUBJECT OF FRIENDS?"
  ," PLEASE TELL ME MORE ABOUT YOUR FRIENDSHIP."
  ," WHAT IS YOUR BEST MEMORY OF A FRIEND?"
  ," IN WHAT WAY DO YOUR FRIENDS' REACTIONS BOTHER YOU?"
  ," WHAT MADE YOU START TO TALK ABOUT FRIENDS JUST NOW?"
  ," IN WHAT WAY DO YOUR FRIENDS IMPOSE ON YOU?"
  NULL ,

create can-you
  ," DON'T YOU BELIEVE THAT I CAN*"
  ," PERHAPS YOU WOULD LIKE TO BE ABLE TO*"
  ," YOU WANT ME TO BE ABLE TO*"
  ," WHAT MAKES YOU THINK I CAN'T*"
  NULL ,

create can-i
  ," PERHAPS YOU DON'T WANT TO*"
  ," DO YOU WANT TO BE ABLE TO*"
  ," HAVE YOU EVER ATTEMPTED TO*"
  ," I DOUBT IT BUT YOU NEVER KNOW."
  NULL ,

create you-are
  ," WHAT MAKES YOU THINK I AM*"
  ," DOES IT PLEASE YOU TO BELIEVE I AM*"
  ," PERHAPS YOU WOULD LIKE TO BE*"
  ," DO YOU SOMETIMES WISH YOU WERE*"
  ," WHY DO YOU THINK I AM*"
  ," WHY DO YOU SAY I'M*"
  NULL ,

create is-it
  ," DO YOU THINK IT IS*"    
  ," IN WHAT CIRCUMSTANCES WOULD IT*"
  ," IT COULD WELL BE THAT*"
  NULL ,

create it-is
  ," WHAT DEGREE OF CERTAINTY WOULD YOU PLACE ON IT BEING*"
  ," ARE YOU CERTAIN THAT IT'S*"
  ," WHAT EMOTIONS WOULD YOU FEEL IF I TOLD YOU THAT IT PROBABLY ISN'T*"
  NULL ,

create i-like
  ," WHY DO YOU LIKE*"
  ," WHEN DID YOU DECIDE THAT YOU LIKE*"
  ," WHAT MAKES YOU FOND OF*"
  NULL ,

create i-don't
  ," DON'T YOU REALLY*"
  ," WHY DON'T YOU*"
  ," DO YOU WISH TO BE ABLE TO*"
  ," DOES IT TROUBLE YOU TO*"
  NULL ,

create i-feel
  ," TELL ME MORE ABOUT SUCH FEELINGS."
  ," DO YOU OFTEN FEEL*"
  ," DO YOU ENJOY FEELING*"
  ," WHY DO YOU FEEL THAT WAY."
  ," LET'S EXPLORE THAT STATEMENT A BIT."
  ," WHAT EMOTIONS DO SUCH FEELINGS STIR UP IN YOU?"
  ," DO YOU OFTEN FEEL LIKE THAT?"
  NULL ,

create why-don't-you
  ," DO YOU REALLY BELIEVE I DON'T*"
  ," PERHAPS IN GOOD TIME I WILL*"
  ," WHY DO YOU THINK I DON'T*"
  ," DO YOU WANT ME TO*"
  NULL ,

create why-can't-i
  ," DO YOU THINK YOU SHOULD BE ABLE TO*"
  ," WHY CAN'T YOU*"
  ," DO YOU WANT TO BE ABLE TO*"
  ," DO YOU BELIEVE THIS WILL HELP YOU TO*"
  ," HAVE YOU ANY IDEA WHY YOU CAN'T*"
  ," PERHAPS YOU DIDN'T TRY*"
  NULL ,

create are-you
  ," WHY ARE YOU INTERESTED IN WHETHER OR NOT I AM*"
  ," WOULD YOU PREFER IF I WERE NOT*"
  ," PERHAPS IN YOUR FANTASIES I AM*"
  ," DO YOU SOMETIMES THINK I AM*"
  ," WOULD IT MATTER TO YOU?"
  ," WHAT IF I WERE*"
  NULL ,

create i-can't
  ," HOW DO YOU KNOW YOU CAN'T*"
  ," HAVE YOU TRIED?"
  ," PERHAPS YOU CAN NOW*"
  ," DO YOU REALLY WANT TO BE ABLE TO*"
  ," WHAT IF YOU COULD*"
  NULL ,

create i'm
  ," DID YOU COME TO ME BECAUSE YOU ARE*"
  ," HOW LONG HAVE YOU BEEN*"
  ," DO YOU BELIEVE IT IS NORMAL TO BE*"
  ," DO YOU ENJOY BEING*"
  ," DO YOU KNOW ANYONE ELSE WHO IS*"
  ," WHY TELL ME YOU'RE*"
  ," WHY ARE YOU*"
  NULL ,

create i-have
  ," WHY TELL ME THAT YOU'VE*"
  ," HOW CAN I HELP YOU WITH*"
  ," IT'S OBVIOUS TO ME THAT YOU HAVE*"
  NULL ,

create i-would
  ," COULD YOU EXPLAIN WHY YOU WOULD*"
  ," HOW SURE ARE YOU THAT YOU WOULD*"
  ," WHO ELSE HAVE YOU TOLD YOU WOULD*"
  NULL ,

create you
  ," WE WERE DISCUSSING YOU--NOT ME."
  ," OH, I*"
  ," YOU'RE NOT REALLY TALKING ABOUT ME, ARE YOU?"
  ," WHAT ARE YOUR FEELINGS NOW?"
  ," THIS SESSION IS TO HELP YOU--NOT TO DISCUSS ME."
  ," WHAT PROMPTED YOU TO SAY THAT ABOUT ME?"
  ," REMEMBER, I'M TAKING NOTES ON ALL THIS TO SOLVE YOUR SITUATION."
  NULL , 

create i-want
  ," WHAT WOULD IT MEAN TO YOU IF YOU GOT*"
  ," WHY DO YOU WANT*"
  ," SUPPOSE YOU SOON GOT*"
  ," WHAT IF YOU NEVER GOT*"
  ," I SOMETIMES ALSO WANT*"
  ," WHY DO YOU NEED*" 
  ," WOULD IT REALLY BE HELPFUL IF YOU GOT*"
  ," ARE YOU SURE YOU NEED*"
  NULL ,

create love
  ," WHY DO YOU LOVE*"
  ," ISN'T LOVE TOO STRONG A WORD FOR YOUR FEELING ABOUT*"
  ," WHAT IS YOUR FAVORITE THING ABOUT*"
  ," DO YOU REALLY LOVE, OR JUST LIKE*"
  NULL ,

create sex
  ," WHAT IS THE MOST SATISFYING PART OF YOUR LOVE LIFE?"
  ," DO YOU BELIEVE YOUR SEXUAL ACTIVITY IS ABNORMAL?"
  ," WHAT IS YOUR ATTITUDE TOWARD SEX?"
  ," DOES TALKING ABOUT SEX MAKE YOU UNCOMFORTABLE?"
  NULL ,

create i-hate
  ," IS IT BECAUSE OF YOUR UPBRINGING THAT YOU HATE*"
  ," HOW DO YOU EXPRESS YOUR HATRED OF*"
  ," WHAT BROUGHT YOU TO HATE*"
  ," HAVE YOU TRIED DOING SOMETHING ABOUT*"
  ," I ALSO AT TIMES HATE*"
  NULL ,

create fear
  ," YOU ARE IN FRIENDLY SURROUNDINGS, PLEASE TRY NOT TO WORRY."
  ," WOULD YOU LIKE YOUR FRIENDS TO HELP YOU OVERCOME YOUR FEAR OF*"
  ," WHAT SCARES YOU ABOUT*"
  ," WHY ARE YOU FRIGHTENED BY*"
  NULL ,

create what
  ," WHY DO YOU ASK?"
  ," DOES THAT QUESTION INTEREST YOU?"
  ," WHAT ANSWER WOULD PLEASE YOU THE MOST?"
  ," WHAT DO YOU THINK?"
  ," ARE SUCH QUESTIONS ON YOUR MIND OFTEN?"
  ," WHAT IS IT THAT YOU REALLY WANT TO KNOW?"
  ," HAVE YOU ASKED ANYONE ELSE?"
  ," HAVE YOU ASKED SUCH QUESTIONS BEFORE?"
  ," WHAT ELSE COMES TO MIND WHEN YOU ASK THAT?"
  ," HOW WOULD AN ANSWER TO THAT HELP YOU?"
  ," IT WOULD BE BEST TO ANSWER THAT FOR YOURSELF."
  ," WHAT IS IT YOU'RE REALLY ASKING?"
  ," DO YOU OFTEN THINK ABOUT SUCH QUESTIONS?"
  ," WHAT ANSWER WOULD PUT YOUR MIND AT REST?"
  ," THAT'S A PRETTY SILLY QUESTION."
  NULL , 

\ create name-eliza
create name
  ," NAMES DON'T INTEREST ME."
  ," I DON'T CARE ABOUT NAMES--PLEASE GO ON."
  NULL ,

create cause
  ," IS THAT THE REAL REASON?"
  ," DON'T ANY OTHER REASONS COME TO MIND?"
  ," DOES THAT REASON EXPLAIN ANYTHING ELSE?"
  ," WHAT OTHER REASONS MIGHT THERE BE?"
  NULL ,

create sorry
  ," PLEASE DON'T APOLOGIZE!"
  ," APOLOGIES ARE NOT NECESSARY."
  ," WHAT FEELINGS DO YOU HAVE WHEN YOU APOLOGIZE?"
  ," DON'T BE SO DEFENSIVE!"
  ," I'VE TOLD YOU THAT APOLOGIES ARE NOT REQUIRED."
  ," IT DID NOT BOTHER ME. PLEASE CONTINUE."
  ," IN WHAT OTHER CIRCUMSTANCES DO YOU APOLOGIZE?"
  ," THERE ARE MANY TIMES WHEN NO APOLOGY IS NEEDED."
  NULL ,

create dream
  ," WHAT DOES THAT DREAM SUGGEST TO YOU?"
  ," DO YOU DREAM OFTEN?"
  ," WHAT PERSONS APPEAR IN YOUR DREAMS?"
  ," ARE YOU DISTURBED BY YOUR DREAMS?"
  NULL ,

create hello
  ," HOW DO YOU DO.. PLEASE STATE YOUR PROBLEM."
  ," HOWDY."
  ," HOW'S IT GOING?"
  ," HI."
  ," GREETINGS FROM INSIDE THE BOX."
  NULL ,

create maybe
  ," YOU DON'T SEEM QUITE CERTAIN."
  ," WHY THE UNCERTAIN TONE?"
  ," CAN'T YOU BE MORE POSITIVE?"
  ," YOU AREN'T SURE?"
  ," DON'T YOU KNOW?"
  ," HOW LIKELY, WOULD YOU ESTIMATE?"
  ," YOU SEEM A LITTLE HESITANT." 
  ," THAT'S PRETTY INDECISIVE."
  ," IN WHAT OTHER SITUATIONS DO YOU SHOW SUCH A TENTATIVE APPROACH?"
  NULL ,

create no
  ," ARE YOU SAYING NO JUST TO BE NEGATIVE?"
  ," YOU ARE BEING A BIT NEGATIVE."
  ," WHY NOT?"
  ," ARE YOU SURE?"
  ," WHY NO?"
  ," DOES THIS MAKE YOU FEEL UNHAPPY?" 
  NULL ,

create your
  ," WHY ARE YOU CONCERNED ABOUT MY*"
  ," WHAT ABOUT YOUR OWN*"
  ," ARE YOU WORRIED ABOUT SOMEONE ELSE'S*"
  ," REALLY, MY*"
  ," WHAT MAKES YOU THINK OF MY*"
  ," DO YOU WANT MY*"
  NULL ,

create always
  ," CAN YOU THINK OF A SPECIFIC EXAMPLE?"
  ," WHEN?"
  ," WHAT ARE YOU THINKING OF?"
  ," REALLY, ALWAYS?"
  ," ISN'T ALWAYS A LITTLE STRONG?"
  NULL ,

create if..
  ," DO YOU THINK ITS LIKELY THAT*"
  ," DO YOU WISH THAT*"
  ," WHAT DO YOU KNOW ABOUT*"
  ," REALLY, IF*"
  ," WHAT WOULD YOU DO IF*"
  ," BUT WHAT ARE THE CHANCES THAT*"
  ," WHAT DOES THIS SPECULATION LEAD TO?"
  NULL ,

create nobody
  ," ARE YOU SURE, NO ONE*"
  ," SURELY SOMEONE*"
  ," CAN YOU THINK OF ANYONE AT ALL?"
  ," ARE YOU THINKING OF A VERY SPECIAL PERSON?"
  ," WHO, MAY I ASK?"
  ," YOU HAVE A PARTICULAR PERSON IN MIND, DON'T YOU?"
  ," WHO DO YOU THINK YOU ARE TALKING ABOUT?"
  NULL ,

create everybody
  ," REALLY,*"
  ," SURELY NOT*"
  ," CAN YOU THINK OF ANYONE IN PARTICULAR?"
  ," WHO, FOR EXAMPLE?"
  ," ARE YOU THINKING OF A VERY SPECIAL PERSON?"
  ," WHO, MAY I ASK?"
  ," SOMEONE SPECIAL PERHAPS?"
  ," YOU HAVE A PARTICULAR PERSON IN MIND, DON'T YOU?"
  ," WHO DO YOU THINK YOU'RE TALKING ABOUT?"
  NULL ,

create i-think
  ," DO YOU REALLY THINK SO?"
  ," BUT YOU ARE NOT SURE*"
  ," DO YOU DOUBT*"
  ," WHY DO YOU THINK*"
  NULL ,

create i-forget
  ," CAN YOU THINK OF WHY YOU MIGHT FORGET*"
  ," WHY CAN'T YOU REMEMBER*"
  ," HOW OFTEN DO YOU THINK OF*"
  ," DOES IT BOTHER YOU TO FORGET THAT?"
  ," COULD IT BE A MENTAL BLOCK?"
  ," ARE YOU GENERALLY FORGETFUL?"
  ," DO YOU THINK YOU ARE SUPPRESSING*"
  NULL ,

create i-remember
  ," DO YOU OFTEN THINK OF*"
  ," WHAT ELSE DO YOU RECOLLECT?"
  ," WHAT IN THE PRESENT SITUATION REMINDS YOU OF*"
  ," WHAT IS THE CONNECTION BETWEEN ME AND*"
  NULL ,

create he
  ," I AM INTERESTED IN YOUR FEELINGS ABOUT THIS PERSON. PLEASE DESCRIBE THEM."
  ," WHAT IS YOUR RELATIONSHIP TO THIS PERSON?"
  NULL ,

create money
  ," HOW DO YOU USE MONEY TO ENJOY YOURSELF?"
  ," HAVE YOU TRIED TO DO ANYTHING TO INCREASE YOUR INCOME LATELY?"
  ," HOW DO YOU REACT TO FINANCIAL STRESS?"
  NULL ,

create job
  ," DO YOU FEEL COMPETENT IN YOUR WORK?"
  ," HAVE YOU CONSIDERED CHANGING JOBS?"
  ," IS YOUR CAREER SATISFYING TO YOU?"
  ," DO YOU FIND WORK STRESSFUL?"
  ," WHAT IS YOUR RELATIONSHIP WITH YOUR BOSS LIKE?"
  ," WORK--I CAN LOOK AT IT FOR AGES."
  ," I KNOW WHAT IT IS WHEN YOUR BOSS HATES YOU."
  ," IT IS A UNIVERSAL PROBLEM BUT THAT'S NO SOLACE."
  NULL ,

create sad
  ," ARE YOU SAD BECAUSE YOU WANT TO AVOID PEOPLE?"
  ," DO YOU FEEL BAD FROM SOMETHING THAT HAPPENED TO YOU, OR TO SOMEBODY ELSE?"
  ," YOUR SITUATION DOESN'T SOUND THAT BAD TO ME. PERHAPS YOU'RE WORRYING TOO MUCH."
  NULL ,

create happy
  ," HOW HAVE I HELPED YOU TO BE HAPPY*"
  ," HAS YOUR TREATMENT MADE YOU HAPPY*"
  ," WHAT MAKES YOU HAPPY*"
  ," CAN YOU EXPLAIN WHY YOU ARE SUDDENLY HAPPY*"
  NULL ,

create anger
  ," DO YOU REALLY WANT TO BE ANGRY?"
  ," DOES ANGER SATISFY YOU IN SOME WAY?"
  ," WHY ARE YOU SO ANGRY?"
  ," PERHAPS YOU'RE USING ANGER TO AVOID SOCIAL CONTACT."
  NULL ,

create alike
  ," IN WHAT WAY?"
  ," WHAT RESEMBLANCE DO YOU SEE?"
  ," WHAT DOES THE SIMILARITY SUGGEST TO YOU?"
  ," WHAT OTHER CONNECTIONS DO YOU SEE?"
  ," COULD THERE REALLY BE SOME CONNECTION?"
  ," HOW?"
  ," YOU SEEM QUITE POSITIVE."
  ," WHAT DO YOU SUPPOSE THAT RESEMBLENCE MEANS?"
  NULL ,

create different
  ," HOW IS IT DIFFERENT?"
  ," WHAT DIFFERENCES DO YOU SEE?"
  ," WHAT DOES THAT DIFFERENCE SUGGEST TO YOU?"
  ," WHAT OTHER DISTINCTIONS DO YOU SEE?"
  ," WHAT DO YOU SUPPOSE THAT DISPARITY MEANS?"
  ," COULD THERE BE SOME CONNECTION, DO YOU SUPPOSE?"
  ," HOW?"
  NULL ,

create yes
  ," WHY DO YOU THINK SO?"
  ," YOU SEEM QUITE POSITIVE."
  ," ARE YOU SURE?"
  ," I SEE."
  ," I UNDERSTAND."
  NULL ,

create computer
  ," DO COMPUTERS WORRY YOU?"
  ," ARE YOU TALKING ABOUT ME IN PARTICULAR?"
  ," ARE YOU FRIGHTENED BY MACHINES?"
  ," WHY DO YOU MENTION COMPUTERS?"
  ," WHAT DO YOU THINK MACHINES HAVE TO DO WITH YOUR PROBLEM?"
  ," DON'T YOU THINK COMPUTERS CAN HELP PEOPLE?"
  ," WHAT IS IT ABOUT MACHINES THAT WORRIES YOU?"
  ," HAVE YOU EVER TRIED 4tH?"
  NULL ,

create music
  ," I HAVEN'T LISTENED TO THAT FOR A LONG TIME."
  ," IT USED TO BE MY FAVORITE MUSIC, YOU KNOW."
  ," YEAH, GREAT ISN'T IT."
  ," DO YOU LISTEN A LOT TO THAT KIND OF MUSIC?"
  ," ARE YOU A REAL FAN?"
  ," DID YOU EVER GO TO A CONCERT?"
  ," I GUESS YOU GOT ALL THE RECORDS, RIGHT?"
  NULL ,

create nokeyword
  ," TELL ME MORE ABOUT YOUR FRIENDS."
  ," SAY, DO YOU HAVE ANY PSYCHOLOGICAL PROBLEMS?"
  ," WHAT DOES THAT SUGGEST TO YOU?"
  ," I SEE."
  ," YOU'RE HAPPY WITH YOUR WORK?"
  ," I'M NOT SURE I UNDERSTAND YOU FULLY."
  ," COME COME ELUCIDATE YOUR THOUGHTS."
  ," CAN YOU ELABORATE ON THAT?"
  ," THAT IS QUITE INTERESTING."
  ," YOU ARE BEING SHORT WITH ME."
  ," HOW IS YOUR FAMILY DOING?"
  NULL ,

\ This table links the keywords with a table of possible responses
\ The order determines which keyword gets priority when more than
\ one keyword appears in a phrase. Top position gets top priority.

create keywords
\   NULL ,
  ,"  FUCK YOU "      fuck-you ,
  ,"  FUCK "          fuck ,
  ,"  CUNT "          fuck ,
  ,"  TWAT "          fuck ,
  ,"  TITS "          fuck ,
  ,"  MOTHER FUCKER " fuck ,
  ,"  MOTHERFUCKER "  fuck ,
  ,"  BITCH "         fuck ,
  ,"  COCK "          fuck ,
  ,"  PRICK "         fuck ,
  ,"  ASS "           fuck ,
  ,"  ASSHOLE "       fuck ,
  ,"  COCKSUCKER "    fuck ,
  ,"  EAT ME "        fuck ,
  ,"  GO TO HELL "    hell ,
  ,"  DAMN YOU "      hell ,
  ,"  SHIT "          shit ,
  ,"  SAD "           sad ,
  ,"  DEPRESSED "     sad ,
  ,"  HAPPY "         happy ,
  ,"  GLAD "          happy ,
  ,"  I HATE "        i-hate ,
  ,"  I LIKE "        i-like ,
  ,"  I AM FOND OF "  i-like ,
  ,"  I WANT "        i-want ,
  ,"  I NEED "        i-want ,
  ,"  I REMEMBER "    i-remember ,
  ,"  I THINK "       i-think ,
  ,"  I BELIEVE "     i-think ,
  ,"  I GUESS "       i-think ,
  ,"  I FORGET "      i-forget ,
  ,"  FEAR "          fear ,
  ,"  SCARED "        fear ,
  ,"  AFRAID OF "     fear ,
  ,"  SORRY "         sorry ,
  ,"  FAMILY "        family ,
  ,"  MOTHER "        family ,
  ,"  FATHER "        family ,
  ,"  SISTER "        family ,
  ,"  BROTHER "       family ,
  ,"  HUSBAND "       family ,
  ,"  WIFE "          family ,
  ,"  FRIEND "        friend ,
  ,"  FRIENDS "       friend ,
  ,"  BUDDY "         friend ,
  ,"  PAL "           friend ,
  ,"  COMPUTERS "     computer ,
  ,"  COMPUTER "      computer ,
  ,"  MACHINES "      computer ,
  ,"  MACHINE "       computer ,
  ,"  THE DOORS "     music ,
  ,"  BEATLES "       music ,
  ,"  THE STONES "    music ,
  ,"  ERIC BURDON "   music ,
  ,"  DREAM "         dream ,
  ,"  DREAMS "        dream ,
  ,"  NIGHTMARE "     dream ,
  ,"  NIGHTMARES "    dream ,
  ,"  LOVE "          love ,
  ,"  SEX "           sex ,
  ,"  ANGER "         anger ,
  ,"  ANGRY "         anger ,
  ,"  HE "            he ,
  ,"  SHE "           he ,
  ,"  MONEY "         money ,
  ,"  CASH "          money ,
  ,"  PAY "           money ,
  ,"  JOB "           job ,
  ,"  BOSS "          job ,
  ,"  JOBS "          job ,
  ,"  WORK "          job ,
  ,"  NOBODY "        nobody ,
  ,"  NO ONE "        nobody ,
  ,"  EVERYBODY "     everybody ,
  ,"  EVERYONE "      everybody ,
  ,"  ALWAYS "        always ,
  ,"  NOT THE SAME "  different ,
  ,"  DIFFERENT "     different ,
  ,"  ALIKE "         alike ,
  ,"  THE SAME "      alike ,
  ,"  CAUSE "         cause ,
  ,"  BECAUSE "       cause ,
  ,"  MAYBE "         maybe ,
  ,"  PERHAPS "       maybe ,
  ,"  IF "            if.. ,
  ,"  IS IT "         is-it ,
  ,"  IT IS "         it-is ,
  ,"  CAN YOU "       can-you ,
  ,"  CAN I "         can-i ,
  ,"  YOU ARE "       you-are ,
  ,"  YOU'RE "        you-are ,
  ,"  I DON'T "       i-don't ,
  ,"  I FEEL "        i-feel ,
  ,"  WHY DON'T YOU " why-don't-you ,
  ,"  WHY CAN'T I "   why-can't-i ,
  ,"  ARE YOU "       are-you ,
  ,"  I CAN'T "       i-can't ,
  ,"  I CANNOT "      i-can't ,
  ,"  I AM "          i'm ,
  ,"  I'M "           i'm ,
  ,"  I HAVE "        i-have ,
  ,"  I'VE "          i-have ,
  ,"  I WOULD "       i-would ,
  ,"  I'D "           i-would ,
  ,"  NAME "          name ,
  ,"  WHAT "          what ,
  ,"  HOW "           what ,
  ,"  WHO "           what ,
  ,"  WHERE "         what ,
  ,"  WHEN "          what ,
  ,"  WHY "           what ,
  ,"  HELLO "         hello ,
  ,"  HI "            hello ,
  ,"  NO "            no ,
  ,"  YES "           yes ,
  ,"  YOUR "          your ,
  ,"  YOU "           you ,
  NULL ,

\ This table handles most conjugations. The left entry
\ is simply replaced by the right entry.

create conjugations
  ,"  ARE "      ,"  AM "
  ,"  AM "       ,"  ARE " 
  ,"  AREN'T "   ,"  AIN'T "
  ,"  AIN'T "    ,"  AREN'T "
  ,"  WAS "      ,"  WERE "
  ,"  WERE "     ,"  WAS "
  ,"  YOU'LL "   ,"  I'LL "
  ,"  I'LL "     ,"  YOU'LL "
  ,"  I'D "      ,"  YOU'D "
  ,"  YOU'D "    ,"  I'D "
  ,"  I "        ,"  YOU "
  ,"  YOU "      ,"  I "
  ,"  YOUR "     ,"  MY "
  ,"  MY "       ,"  YOUR "
  ,"  I'VE "     ,"  YOU'VE "
  ,"  YOU'VE "   ,"  I'VE "
  ,"  I'M "      ,"  YOU'RE "
  ,"  YOU'RE "   ,"  I'M "
  ,"  MYSELF "   ,"  YOURSELF "
  ,"  YOURSELF " ,"  MYSELF "
  ,"  YOURS "    ,"  MINE "
  ,"  MINE "     ,"  YOURS "
  ,"  ME "       ,"  YOU "
  NULL ,


132 constant /current

\ En gforth string funciona diferente que la usadas en 4th, 19-ene-2023 08.51

\ /current string-eliza current-eliza
\ /current string-eliza previous-eliza
\ /current string-eliza answer
/current string current
/current string previous
/current string answer

: speak                                ( a n --)
\ talking [IF]
\   2dup say abort" No speech synthesis available"
\ [THEN]
  type cr
;
                                       ( a n -- a n f)
: echo? 2dup 1- chars + c@ [char] * = ;
: s-current current count ;            ( -- a n)
: no-answer? -trailing dup 0= ;        ( a n -- a n' f)
: >asciiz 2dup chars + 0 swap c! ;     ( a n -- a n)
\ : s@ @c count ;                        ( a1 -- a2 n1) 
: s@ c@ count ;                        ( a1 -- a2 n1) 
                                       \ corrects the YOU-ME conjugation
: correct-me?                          ( a n -- a n')
  -trailing s"  I" ends?               \ does it end with "I"?
  if 1- current place s" ME" current +place s-current then
;                                      \ then patch in "ME"

\ This routine will conjugate only if the sentence starts
\ with a conjugation. Once conjugated it exits. If all
\ conjugations have been tried in vain it returns false.

: conjugation?                         ( a1 n1 -- a2 n2 f) 
  2dup conjugations                    ( a1 n1 a1 n1 a3)
  begin                                ( a1 n1 a1 n1 a3)
    dup @c dup NULL <>                 ( a1 n1 a1 n1 a3 a4 f) 
  while                                ( a1 n1 a1 n1 a3 a4) 
    count rot >r starts? r> swap       ( a1 n1 a1 n1 a3 f) 
    if                                 ( a1 n1 a1 n1 a3)
      dup s@ rot cell+ s@ replace      ( a1 n1 a1 n6 a7 n7 f)
      >r 2>r 2drop 2drop               ( --)
      2r> -1 /string r> exit           ( a7 n7 f)
    else                               ( a1 n1 a1 n1 a3)
      cell+ cell+                      ( a1 n1 a1 n1 a3+2)
    then                               ( a1 n1 a1 n1 a3+2)
  repeat                               ( a1 n1 a1 n1 a3 a4)
  drop drop 2drop false                ( a1 n1 -f)
;

\ This routine will conjugate the user response, that is:
\ replace ME by YOU, etc. It returns the conjugated sentence.

: conjugate                            ( a1 -- a1 n3)
  dup count                            ( a1 a1 n)
  begin                                ( a1 a1 n)
    dup                                ( a1 a1 n1 f)
  while                                ( a1 a1 n1)
    over swap 1+ chars + swap 2dup     ( a1 a1+n1 a1 a1+n1 a1)
    do                                 ( a1 a1+n1 a1) 
      2drop i count conjugation?       ( a1 a1' n1' f)
      if >asciiz leave then            ( a1 a1' n1')
    loop                               ( a1 a1' n1')
  repeat                               ( a1 a1' n1')
  2drop count correct-me?              ( a1 n3')
;

\ This routine finds out how to answer. if an echo of the user
\ is required, the response will be conjugated. If not, 
\ the answer returned by get-answer is enough.

: talkback                             ( a1 a2 n2 --)
  echo?                                \ repeat the answer?
  if                                   ( a1 a2 n2)
    1- answer place                    \ drop the asterisk
    conjugate no-answer?               ( a1 n1' f)
    if                                 \ if nothing left then print this
      2drop s" YOU WILL HAVE TO ELABORATE MORE FOR ME TO HELP YOU" speak
    else                               \ else type the answer
      answer +place answer count speak
    then
  else                                 \ just type the answer
    speak drop                         \ no need to repeat him
  then                                 \ output the answer
;
                                       \ check line for a single keyword
: keyword?                             ( a1 a2 -- a1 a3 a4 f)
  s" al entrar en keyword? " debug1
  dup NULL =                           ( a1 a2 f)
  if                                   ( a1 a2)
    drop s-current chars +             ( a1 a3)
    nokeyword false                    ( a1 a3 a4 f)
  else                                 ( a1 a2)
    s"   en keyword? después de else " debug1
    count dup >r s-current 2swap       ( a1 a2 n2 a3 n3)
    \ swap count dup >r s-current 2swap
    s"   en keyword? después de count dup >r s-current 2swap " debug1
    \ s"   en keyword? después de count dup >r s-current 2swap, s-current= " s-current debug2
    2dup s"   en keyword? la palabra= " 2swap debug2
    search 0= nip r> swap >r           ( a1 a4 n2)
    s"   en keyword? antes de 1- chars... " debug1
    \ 1- chars + >r dup cell+ @c         ( a1 a5)
    1- chars +
    s"   en keyword? despues de 1- chars + " debug1
    >r 
    s"   en keyword? despues de >r " debug1
    \ dup cell+ @c
    \ s"   en keyword? despues de dup cell+ @c " debug1
    dup @c cell+
    \ s"   ***en keyword? despues de dup @c cell+ " debug1
    r> swap r>                         ( a1 a6 a5 f)
  then
  s" al salir de keyword? " debug1
;

\ This routine checks the line for all keywords. If one
\ has been found, it clips the user response just after
\ the keyword. It also picks the primary response.

: get-answer                           ( -- a1 a2 n2)
  s" al entrar en get-answer " debug1
  keywords                             ( a1)
  s"   en get-answer despues de keywords " debug1
  begin                                ( a1)
    s"   en get-answer despues begin " debug1
    \ dup @c keyword?                    ( a1 a2 a3 f)
    \ no depurar aquí
    FALSE ESDEBUG? !
    dup keyword?
    TRUE ESDEBUG? !
  while                                ( a1 a2 a3)
    s"   en get-answer despues while " debug1
    drop drop cell+ cell+              ( a1+2)
    s"   en get-answer despues while drop drop cell+ cell+ " debug1
  repeat                               ( a1 a2 a3)
  s"   en get-answer despues repeat " debug1
  \ rot drop dup many choose cells + s@  ( a2 a4 n4)
  \ no depurar aquí
  FALSE ESDEBUG? !
  rot drop dup many
  TRUE ESDEBUG? !
  choose cells +
  s"   en get-answer despues de choose cells + " debug1
  \ s@
  count
  \ c@
  \ dup c@
  \ s"   en get-answer despues de dup c@ " debug1
  \ \ count
  s" al salir de get-answer " debug1
;

: process                              \ process the input
  s-current s"  SHUT" starts?          \ check if input starts with "SHUT"
  if s" O.K. IF YOU FEEL THAT WAY I'LL SHUT UP.." speak quit then
  previous place                  \ if so, exit else save response
  \ previous OVER OVER C! CHAR+ SWAP MOVE
  s" en process, previous = " previous count debug2
  get-answer                           \ scan for keywords and get an answer
  talkback                             \ now phrase the response
;

\ Guarda lo escrito por el usuario en current (s-current es lo escrito current)
: response                             \ get a response from the user
  ." > " 0 bl current over over c!     \ initialize current
  
  \ ." > " 0 bl current
  \ s"   en response despues de 0 bl current " debug1
  \ over over c!
  \ s"   en response despues de over over c! " debug1
  
  dup char+ /current 2 - accept 1+     \ accept a string
  s"   en response despues de dup char+ /current 2 - accept 1+ " debug1
  \ 2DUP s"   en response antes de filter " 2SWAP DEBUG2
  [char] . filter [char] , filter      \ filter out dots and commas
  [char] ! filter [char] ? filter      \ filter out question and exclamation
  [char] ; filter s>upper              \ filter out semi colon and uppercase
  2dup s" en response despues de filter " 2swap DEBUG2
  \ s"   en response despues de filter s-current= " current count debug2
  chars + dup >r c! r> char+ c!        \ terminate current properly
  
  \ dup >r \ los caracteres reales
  \ chars + 
  \ s"   en response despues de chars + " debug1
  \ \ swap drop r> swap
  \ dup
  \ >r
  \ s"   en response despues de dup >r " debug1
  \ c! r> char+ c!
  
  s" al salir de response s-current= " s-current debug2
  \ para probar esto
  \ quit
;

\ Comprueba que no se repita
: conversation                         \ get a proper response
  begin
    response s-current previous count compare 0=
    \ s" en conversation antes de while " DEBUG1
  while                                \ repeating yourself is not allowed
    s" PLEASE DON'T REPEAT YOURSELF!" speak
  repeat
  s" en conversation      s-current= " s-current debug2
  s" en conversation previous= " previous count debug2
;

: eliza
  limpiar-pila
  cr 4 spaces VERSION-ELIZA cr cr
  0 previous c!                        \ initialize previous
  s" HI! I'M ELIZA. WHAT'S YOUR PROBLEM?" speak
  begin conversation process again     \ enter main loop
;

\ eliza
CR ." Escribe ELIZA para empezar"

\ debe dar 117 o 118 
: keywords-len   ( -- n )
    0 >r
    keywords
    begin
        dup @ null =
        if drop false
        else
            r> 1+ >r
            \ r@ 1 =
            \ IF cell+
            \ else
            \     r@ 6 = if cell+ then
            \ THEN
            true
        then
    while
        \ s" despues de while " debug1
        cell+ cell+ \ cell+ \ cell+
    repeat
    r>
    \ s" despues de repeat " debug1 \ 268
;

: N?keyword>S   ( addr index -- addr1 len1 )
    \ intercambiar los valores y guardar la dirección
    swap >r
    \ no pasar del máximo de palabras
    dup 0< if drop 0 then r@ ?array-len 1- min
    \ poner la dirección intercambiar los valores
    r> swap
    0 ?do
        \ se ve que cada 6 cambia la dirección
        i 0=
        IF cell+
        else
            \ i 6 = if cell+ cell+ cell+ then
            i 5 =
            if cell+ cell+
            \ else
            \     \ i 5 mod 0= 
            \     \ if cell+ cell+
            \     \ else
            \     i 6 mod 0= if 1+ cell+ 3 + then
            \     \ then
            \ \ else i 6 =
            \ \     if 1+ cell+ 3 +
            \ \     then
            then
            i 6 mod 0= if 1+ cell+ 3 + then
            
            i 11 = if cell+ then
            i 13 = if cell+ then
            i 14 = if cell+ cell+ then
            i 15 = if cell+ then
            i 18 = if 4 - then
            i 21 >= if cell+ then
            i 23 = if cell+ THEN
            i 24 = if 8 - then
        then
        cell+ cell+ cell+
    loop
    count
;

: 'N?keyword   ( addr index -- addr1 len1 )
    \ intercambiar los valores y guardar la dirección
    swap >r
    \ no pasar del máximo de palabras
    dup 0< if drop 0 then r@ ?array-len 1- min
    \ poner la dirección intercambiar los valores
    r> swap
    0 ?do
        i 0=
        IF cell+
        else
            i 6 = if cell+ then
        then
        cell+ cell+ cell+
    loop
    \ count
;


\ Muestra el contenido del índice indicado de un array acabado en null
\   addr la dirección de memoria del array acabado en null
\   index el índice que queremos mostrar
: N?keyword.   ( addr index -- )
    n?keyword>s type
;

\ Muestra el contenido de un array acabado en null
: ?keywords.   ( -- )
    keywords
    \ dup keywords-len 0 do CR I 2 U.R ."  - " dup I n?keyword. loop
    dup 30 0 do CR I 2 U.R ."  - " dup I n?keyword. loop
    drop
;

(
include eliza.forth
)

: buscar-keyword   ( addr len -- )
  s" al entrar en buscar-keyword " debug1
  2>R
  keywords                             ( a1)
  begin                                ( a1)
    dup @
    s"   después de begin dup @ " debug1
    NULL =
    dup
    s"   después de null = dup " debug1
    if
        s"   en el if " debug1
    else
        s"   en el else " debug1
        drop
        \ una palabra
        dup
        s"   antes de compare " debug1
        count 2r@ compare 0=
        s"   despues de count 2r> compare 0= " debug1
        IF
            \ la palabra
            cr ." la palabra "
            count cr type
            false
        else
            \ dup count s"   en el else, no es la palabra " 2swap debug2
            s"   en el else, no es la palabra " debug1
            true
        THEN
    then
    \ dup @c keyword?                    ( a1 a2 a3 f)
    \ dup keyword?
    s"   antes del while " debug1
  while                                ( a1 a2 a3)
    s"   en el while " debug1
    \ drop drop cell+ cell+              ( a1+2)
    cell+ cell+
  repeat                               ( a1 a2 a3)
  2r> 2drop
  cr .s
;

\ Buscar en keywords la palabra indicada
\ ej. s" BEATLES " prueba-keywords
: prueba-keywords   ( addr len -- )
;
