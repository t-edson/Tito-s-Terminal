Tito-s-Terminal
===============

Terminal con Interfaz gráfica, coloreado de sintaxis y automatización para telnet, y ssh.

![Tito's Terminal](http://blog.pucp.edu.pe/media/4946/20140905-tterm1red.png "Título de la imagen")

Tito's Terminal empezó como una broma, pero ahora es una aplicación bastante completa y ha migrado recientemente a Lazarus.

Este terminal puede hacer de cliente para Telnet, SSH, Serial(no disponible aún) y en general cualquier proceso que maneje consola.

Para las conexiones Telnet y SSH, usa el conocido "PLink", pero podría usarse otro cliente similar.

Este terminal incluye un panel de texto, que se usa para enviar los comandos al terminal. No es conveniente enviarlos directamente, porque la consola no está preparada para la interacción directa con el usuario.

La pantalla del terminal, responde de forma similar a un VT100, pero sin las opciones de resaltado (negrita y brillante). Sin embargo, el texto mostrado en el terminal, incluye coloreado de sintaxis (para el lenguaje del Shell de UNIX) y plegado de código. 

El ancho de la pantalla no está limitado por el tamaño del VT100 (que está por defecto en 80 caracteres), sino que puede extenderse hasta varios cientos de caracteres más.

El terminal se puede confugurar para reconocer la llegada del prompt del sistema. Además lo resalta con un color especial.

La detección del prompt, es útil visualmente y también es necesario para algunas herramientas adicionales que se incluyen el el programa como el Explorador Rremoto y el Editor Remoto.

El explorador de archivos remoto,  funciona interactuando con el terminal, mediante comandos, pero solo para las sesiones Telnet y SSH. De esta forma se puede emular un explorador de archivo en conexiones UNIX/Linux.

También se incluye un editor remoto, que interactuando, mediante comandos, con el shell permite realizar la edición de archivos pequeños, desde dentro del mismo shell UNIX/Linux.

Los editores del programa incluyen resaltado de sintaxis (para diversos lenguajes), plegado de código y autocompletado de código. Estos editores se pueden configurar en su apariencia y se pueden agregar lenguajes nuevos o modificar los que ya existen, en cuanto a resaltado de sintaxis, plegado de código o autocompletado.

Tito's Terminal también permite la automatización de las conexiones con un lenguaje de macros similar al usado para TeraTerm. Se incluye además un editor de código preparado exclusivamente para escribir y probar las macros.

![Tito's Terminal](http://blog.pucp.edu.pe/media/4946/20140905-tterm3.png "Título de la imagen")

Las funciones de ejecución de macros, así como otras comunes, tienen un acceso directo desde el menú principal o contextual del aplicativo.

El programa es fuertemente configurable, con innumerables opciones para la apariencia y el modo de trabajo. Para evitar tener que configurar constantemente el entorno, se incluye el manejo de sesiones, que pueden guardar toda la configuración en un solo archivo, y que puede luego recuperarse de forma sencilla, con un par de "Clicks".
