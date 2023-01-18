# Forth programming language
Ejemplos y trucos utilizando el lenguaje de programación Forth

Aquí te pondré algunas cosas relacionadas con el lenguaje Forth.

<br>

Por ahora tengo un par de juegos:

[Adivina-Forth](https://github.com/elGuille-info/Adivina-FORTH)

[Digits-Forth](https://github.com/elGuille-info/DIGITS-FORTH)

<br>

## ¿Qué es Forth?

```
Forth o FORTH es un lenguaje de programacion y un ambiente de programacion
  para ordenadores inventado por Charles H. Moore en 1968 y usado en 1970
  para controlar el telescopio de 30ft del National Radio Astronomy Observatory de Kitt Peak, Arizona.
Inicialmente disenado para una aplicacion muy concreta, la astronomia
  (calculo de trayectorias de cuerpos en orbita, cromatografias, analisis de espectros de emision),
  ha evolucionado hasta ser aplicable a casi todos los demas campos relacionados o no con esa rama
  de la ciencia (calculos de probabilidad, bases de datos, analisis estadisticos y hasta financieros).
Forth es un lenguaje de programacion procedimental, estructurado, imperativo, reflexivo,
  basado en pila y sin comprobacion de tipos.
Una de sus importantes caracteristicas es la utilizacion de una pila de datos
  para pasar los argumentos entre las palabras, que son los constituyentes de un programa en Forth.
En Forth para el manejo de la pila se usa la notacion postfija (notacion polaca inversa)
  de forma que para sumar dos numeros se escriba de esta forma: 3 2 +
  Se ponen los numeros en la pila y despues se indica la operacion a realizar con esos numeros,
    dejando en la pila el resultado.
  Si queremos sumar 3+2 y el resultado multiplicarlo por 7 lo hariamos asi: 7 2 3 + *
    Primero se suman 2+3 y el resultado (que estara en la pila) se multiplica por 7.

Para mas informacion e implementaciones populares de Forth ver:
   Forth en Wikipedia                       https://es.wikipedia.org/wiki/Forth
   Forth Interest Group (FIG)               http://www.forth.org/
   Forth Standard                           https://forth-standard.org/
   GForth del Proyecto GNU                  https://gforth.org/
   Sitio web oficial de FORTH, Inc.         https://www.forth.com/
   Starting FORTH (tutorial de Leo Brodie)  https://www.forth.com/starting-forth/
       Este es el que he usado yo para empaparme de Forth.
```
