UnTerminal 0.9
==============

Unidad en Lazarus, para el control de procesos tipo consola, con detección de "prompt".

Esta unidad permite procesar la entrada y salida de procesos que manejen entrada y salida estándar de texto. Permite además detectar el prompt y el estado de "ocupado" y "listo".

Los procesos a controlar con esta unidad deben cumplir las siguientes condiciones:

1. Que se puedan lanzar como procesos de tipo consola.
2. Que su entrada y salida estándar sea de tipo texto.
3. Que tengan prompt. (No necesario si no importa detectar el prompt).
4. Que acepten comandos (Si se quiere enviar información al proceso).

Los procesos que se pueden controlar con esta unidad son diversos, como clientes de telnet, ftp, o el mismo shell del sistema operativo, como se muestra en el ejemplo incluido.

En la versión actual no se puede leer el flujo de salida de errores independientemente. Solo se controlan dos flujos: 

1. De entrada 
2. De salida (salida estándar y de errores).

Conexión
--------

Para conectarse mediante un proceso, se debe crear una instancia de TConsoleProc, y seguir la secuencia de conexión:

```
  p := TConsoleProc.Create(StatusBar1.Panels[1]);  //Crea conexión
  ...
  p.Free;
```

Opcionalmente se le puede pasar la referencia a un panel de una barra de estado, para que se muestren íconos que indiquen el estado de la conexión (poner en NIL si no se usará). En este caso se debe manejar el evento OnDrawPanel() de la Barra de estado:

```
 StatusBar1.OnDrawPanel:=@SBDrawPanel;
 ...
 procedure Form1.SBDrawPanel(StatusBar:TStatusBar; Panel:TStatusPanel; const Rect:TRect);
 begin
  if panel.Index = 1 then p.DrawStatePanel(StatusBar.Canvas, Rect);
 end;
```

La conexión se maneja por estados. Los estados posibles del proceso son:

* ECO_STOPPED .- El Proceso no se ha iniciado. Esta condición se da siempre después de crer la conexión, o después de cerrrar una conexión abierta. Puede que haya datos pendientes en el "buffer".
* ECO_CONNECTING .- Esta condición se da después de abrir la conexión con el proceso indicado. Termina cuando se detecta el prompt. Si no se detecta el prompt, (sea que no llegue, o no se haya configruado correctamente), el proceso se mantendrá siempre en este estado.
* ECO_ERROR_CON .- Se produce cuando después de intentar abrir el proceso, se produce un error, por ejemplo, cuando se referencia a un archivo que no existe.
* ECO_READY .- Este proceso se inicia cuando se detecta el prompt (si es que se usa la detección de prompt). Indica que el proceso está listo para aceptar comandos. Se mantiene en este estado hasta que se reciba algún comando para enviar al proceso.
* ECO_BUSY .- Este estado se inicia después de mandar un comando, cuando el proceso se encontraba en estado ECO_READY. Se mantiene en este estado, hasta que se detecte el prompt y se pase nuevamente al estado ECO_READY.

El proceso solo puede estar en uno de estos estados a la vez. La transición entre estados tiene una secuencia lógica, pero puede tener cambios.

Una secuencia típica de estados al iniciar una conexión exitosa es:
 
 ECO_STOPPED -> ECO_CONNECTING -> ECO_READY

El estado de ECO_READY indica que el proceso está listo para recibir comandos y, se detecta cuando se recibe el prompt. Por lo tanto para que se pueda considerar a un proceso como ECO_READY, se debe cumplir que tenga un prompt y que el terminal esté configurado para detectarlo.

La secuencia de una conexión con error sería:
 
 ECO_STOPPED -> ECO_CONNECTING -> ...

Es decir, que no se detecta el prompt, sino que probablemente, el proceso se detiene con un mensaje de error. La detección de los mensajes de error, no se hace en esta unidad, porque pueden ser muy diversos. Se recomienda implementarlos en otra unidad o derivando una clase adicional.
 
Una vez el proceso se encuentre disponible. Un comando cualquiera, tendría el siguiente flujo:

ECO_READY -> ECO_BUSY -> ECO_READY

Está unidad está pensada para ser usada en conexiones lentas, y con volúmenes
considerables de datos, por ello se maneja la llegada de datos completamente por eventos.

Para el manejo de la pantalla usa un terminal VT100 sencillo, de la unidad TermVT. Sin
embargo, esta unidad ha sido diseñada para poder recibir el texto del VT100, en un
TStringList, y poder registrar permanentemente el contenido.

El proceso a lanzar, se inicia con el método Open() y se termina con el método Close().

Por defecto, los saltos de línea se enviarán al proceso como el caracter LF (que es usual en conexiones de tipo Telnet). Para cambiar a CR+LF (que es usual en el entorno Windows), se debe fijar la propiedad 'sendCRLF' en TRUE. 

Esta unidad solo ha sido probada en Windows, pero podría funcionar también en Linux.

Configurando un Editor para mostrar la salida
=============================================

El objetivo del uso de un terminal es poder mostrar la salida de forma cómoda para el usuario.

"UnTerminal", ha sido diseñado para manejar procesos lentos y con salida masiva de datos. Por ello la salida de datos se maneja enteramente por eventos. Además se supone que se requiere guardar un registro en pantalla, de la información que se va campturando. Por ello los eventos están orientado a manejar un objeto "TStrings", que permite ir agregando líneas nuevas e ir guardando las líneas anteriores (registro de salida).

Existen diversos grupos de eventos para manejar la salida de datos. Se definen 4 métodos para el control de la salida de datos:

1. Salida como terminal VT100.
2. Salida línea por línea.
3. Salida línea por línea con línea parcial.
4. Salida línea por línea con línea parcial en prompt.

Cada uno de estos métodos tiene sus ventajas y desventajas. Y se debe usar el que se adecue mejor a las necesidades de la aplicación. Así para implementar un cliente de Telnet, se debería usar el método 1 (el más completo), pero para otros procesos bastará usar métodos más simples.

Podría implementarse un método adicional que consiste en interceptar directamente los eventos del terminal (propiedad term: TTermVT100) de TConsoleProc, para mostrar la información en pantalla. Sin embargo este método de trabajo, es de nivel más bajo, pero puede servir para capturar el contenido completo del terminal VT100, cada vez que se produzca un cambio (lo cual no sería muy eficiente, desde luego). 

Implementar la salida de datos, no afecta en la detección del prompt. Las rutinas de detección trabajan directamente sobre los bloques de datos que van llegando del proceso, sin necesidad de que estos datos se muestren.

Salida como Terminal VT100
--------------------------

Este es el método más completo de manejo de salida del terminal. Permite reconocer las secuencias de escape que controlan el cursor, o manipulan el texto del terminal. 

Se puede decir que este es el método oficial para manejo de cualquier proceso, inclusive si genera secuencias de escape ANSI.

Para configurar un editor en esta forma, se deben usar los eventos: OnInitScreen(), OnRefreshLine(), OnRefreshLines() y OnAddLine().

En el siguiente código, se usa un editor SynEdit, como salida para un proceso cualquiera. 

```
  proc.OnInitScreen:=@procInitScreen;
  proc.OnRefreshLine:=@procRefreshLine;
  proc.OnRefreshLines:=@procRefreshLines;
  proc.OnAddLine:=@procAddLine;
...

procedure TfrmPrincipal.procInitScreen(const grilla: TtsGrid; fIni, fFin: integer);
begin
  for i:=fIni to fFin do SynEdit1.Lines.Add(grilla[i]);
end;

procedure TfrmPrincipal.procRefreshLine(const grilla: TtsGrid; fIni, HeightScr: integer);
begin
  yvt := SynEdit1.Lines.Count-HeightScr-1;
  SynEdit1.Lines[yvt+fIni] := grilla[fIni];
end;

procedure TfrmPrincipal.procRefreshLines(const grilla: TtsGrid; fIni, fFin, HeightScr: integer);
begin
  yvt := SynEdit1.Lines.Count-HeightScr-1;  //calcula fila equivalente a inicio de VT100
  for f:=fIni to fFin do SynEdit1.Lines[yvt+ f] := grilla[f];
end;

procedure TfrmPrincipal.procAddLine;
begin
  SynEdit1.Lines.Add('');
end;
```

El evento OnInitScreen(), es llamado solo una vez al inicio para dimensionar el StringList, de modo que pueda contener a todas las líneas del terminal VT100. Es necesario que el editor de salida tenga al menos la cantidad de líneas que tiene el terminal VT100 (25 por defecto), de otra forma se geenrará un error en tiempo de ejecución. Esta condición es compresible, si tenemos en cuenta que se trata de "encajar" una pantalla virtual de un termninal (que puede ser de 80 * 25 líneas) en un contenedor TString.

Para posicionar el cursor virtual del terminal en alguna línea del TString, se debe hace primero el cálculo[1]:

  yvt := SynEdit1.Lines.Count-HeightScr-1;

donde 'HeightScr' es la altura actual del terminal VT100, que es porporcionado por loe eventos de  TConsoleProc.

[1] Desde luego si no se quisiera guardar el registro de las líneas anteriores, no sería necesario complicarnos con los cálculos y solamente necesitaríamos tener un TString con la misma cantidad de líneas del VT100, y evitaríamos calcular la posición vertical porque sería la misma en el terminal y en el TString.

Para limpiar el contenido del terminal, se debe llamar al método ClearTerminal(), que además, reinicia la posición del cursor, poniéndolo en (1,1).

Llamar a ClearTerminal(), no tendrá efecto, sobre el estado de la conexión o del proceso en curso, sino solamente en el contenido del terminal.

Salida Línea por Línea
----------------------

El método descrito en la sección anterior (usando los eventos OnInitScreen(), OnRefreshLine(), OnRefreshLines() y OnAddLine()), es por así decirlo, la manera formal de controlar la salida. Este método considera que el proceso puede manejar secuencias ANSI de escape para el control de la pantalla del terminal virtual. 

Sin embargo, este método puede resultar complicado al momento de manejar la posición del cursor o cuando se quiere conmutar desde un editor de salida a otro.

Si nuestro proceso a controlar, no manejará secuencias ANSI, sino que simplemente enviará texto plano sin comandos de borrado o manejo de cursor, entonces podemos usar formas alternativas más simples de mostrar la información en pantalla.

El método más simple sería usar solamente el evento OnLineCompleted():

OnLineCompleted:TEvLinCompleted;

Que se genera cada vez que se detecta un salto de línea en la llegada de datos. Así podríamos usar este método para ir agregando líneas a nuestro editor de salida, sin preocuparnos en iniciar la pantalla, o de la información anterior que pueda contener.

Nuestro código sería algo como esto:

```
  proc.OnLineCompleted:=@procOnLineCompleted;
...

procedure TForm1.procOnLineCompleted(const lin: string);
begin
  SynEdit1.Lines.Add(lin);
end;
```

Esta forma minimalista funcionará bien, mostrando los datos de llegada, pero con un aparente retraso, porque para que se muestre una línea, esta debe estar completa. De modo que cuando llegue el prompt (o una línea incompleta), esta línea no se mostrará en el editor (a pesar de que el proceso podría pasar al estado ECO_READY). 

El hecho de que no se muestre la última línea, no implica que no se mostrará más. Esta se hará visible al recibir el salto de línea correpsondiente, a menos que se  cierre la conexión antes.

Este método de captura de salida es útil cuando se requiere capturar la salida masiva de datos sin que se amuy importante la correcta visualización del prompt o líneas intermedias.

Para determinar cuando se termina de recibir los datos, se puede usar la detección del prompt, si es que el proceso lo permite.

Salida línea por línea con línea parcial
----------------------------------------

El método de línea por línea es simple y seguro. Pero no muestra la última línea. Para que se muestre la última línea completa, es necesario que se reciba el salto de línea correspondiente. Así podemos decir que en este modo de trabajo, no se mostrará nunca la última línea recibida (a menos claro, que el último caracter recibido sea el salto de línea y consideremos que la última línea es la anterior al salto).

Para salvar este inconveniente, se puede usar la conbinación de eventos:

  OnLineCompleted: TEvLinCompleted; 
  OnReadData     : TEvReadData;   
 	
El evento OnReadData(), se genera cuando se termina de leer un bloque de datos y por lo general, se termina con una línea final sin salto (puede ser el prompt). Entonces, lo que deberíamos hacer es completar reemplazar esta línea, si es que luego recibimos el evento OnLineCompleted().

El código de trabajo, se parecerá a este:

```
var LinPartial: boolean = false;

  proc.OnLineCompleted:=@sqlConLineCompleted;
  proc.OnReadData:=@procReadData;
...
  
procedure TForm1.procLineCompleted(const lin: string);
begin
  if LinPartial then begin
    //Estamos en la línea del prompt
    Memo1.Lines[Memo1.Lines.Count-1] := lin;  //reemplaza última línea
    LinPartial := false;
  end else begin  //caso común
    Memo1.Lines.Add(lin);
  end;
end;

procedure TForm1.procReadData(nDat: integer; const lastLin: string);
begin
  LinPartial := true;   //marca bandera
  Memo1.Lines.Add(lastLin);   //agrega la línea que contiene al prompt
end;
```

La variable 'LinPartial' nos sirve para saber cuando se ha recibido una línea parcial.

Este método de trabajo funcionará bastante bien y es simple, pero podría darse el caso (poco común), en el que se reciban dos veces seguidas el evento OnReadData(), haciendo que se genere una línea adicional en el editor. Este caso se podría dar cuando, se genera una línea muy larga que llegue en más de un bloque, o en conexiones muy lentas.

Para evitar este efecto, se podría incluir una rutina de protección adicional que verificara que el evento OnReadData(), se está produciendo dos veces seguidas y de ser así, evitar agregar una línea más.

El uso de los eventos OnLineCompleted()-OnReadData() es una forma sencilla de recbir los datos "linea por línea", pero no debemos olvidar que solo debe aplicarse a procesos con salida simple de texto sin saltos de línea o borrado de texto. La mayoría de procesos caen en esta categoría (como clientes de FTP o hasta el mismo shell de DOS), pero procesos como un cliente de Telnet o SSH, usan secuencias de escape que pueden requerir posicionar el cursor para sobreescribir bloques. 

En estos casos no se debería implementar este método de captura de salida; pero inclusive si se implementara aquí, podríamos tarbajar bien, mientras no se generen saltos del cursor o borrado de texto. Las secuencias de escape que cambian atributos del texto no afectan en la salida del texto, porque son procesadas (o mejor dicho ignoradas) por TConsoleProc, de modo que los eventos de salida de texto no contienen secuencias ANSI de ningún tipo, en sus parámetros.

Salida línea por línea con línea parcial en Prompt
--------------------------------------------------

Como una variación del método anterior, se presenta este método que es muy similar, pero con la diferencia que la detección de líneas parciales se hace solo para cuando se detecte el promtp.
 
De esta forma, se evita generar muchas sobre-escrituras de líneas, ya que solo se hará en la línea del prompt. Este método es más eficiente cuando se tiene varios paquetes de datos entre prompt y prompt.

Una desventaja de este método es que, es necesario que se tenga configurado el prompt, y este aparezca siempre al final de un bloque de datos, para que se refresque la última línea, en caso contrario no se refrescará de ninguna forma.

Por lo tanto solo es recomendable para procesos que siempre muestran el prompt. No es recomendable por ejemplo, en un proceso que el algún momento mostrará un mensaje como  "Ingrese un valor: ", esperando una entrada del usuario. Por lo tanto hay que ser cauteloso cuando se use este método de captura de salida. 

La implementación de la captura, es igual al caso anterior, solo que se usa otro par de eventos:

  OnLineCompleted: TEvLinCompleted; 
  OnLinePrompt: TEvLinCompleted; 

El evento OnLinePrompt(), se genera cuando se recibe la línea que contiene al prompt, aunque no esté completa. Entonces, lo que deberíamos hacer es completar reemplazar esta línea, si es que luego recibimos el evento OnLineCompleted().

El código de trabajo, se parecerá a este:

```
var LinPrompt: boolean = false;

  proc.OnLineCompleted:=@procLineCompleted;
  proc.OnLinePrompt:=@procLinePrompt;
...
  
procedure TForm1.procLineCompleted(const lin: string);
begin
  if LinPrompt then begin
    //Estamos en la línea del prompt
    SynEdit1.Lines[SynEdit1.Lines.Count-1] := lin;  //reemplaza última línea
    LinPrompt := false;
  end else begin  //caso común
    SynEdit1.Lines.Add(lin);
  end;
end;

procedure TForm1.procLinePrompt(const lin: string);
begin
  LinPrompt := true;   //marca bandera
  SynEdit1.Lines.Add(lin);   //agrega la línea que contiene al prompt
end;
```

La variable 'LinPrompt', nos sirve para detectar cuando se ha recibido el prompt en una línea.

Este método de trabajo también también puede sufrir del problema del método anterior si, es que se recibe una línea larga (donde se detecte el prompt) que viene en más de un bloque. La solución a aplicar es la misma.

Aunque el efecto de este caso extremo puede no ser muy crítico, ya que solo generará una línea adicional con el prompt en el editor de salida. Esta línea adicional no quitará la legibilidad del código pero de todas formas, es una falta de fidelidad en la salida del proceso.
  
Manejo del Terminal 
===================

## Envío de comandos

Los comandos (o cualquier cadena en general), se envían al proceso con los método Send(), SendLn() o SendFile(). SendLn() es similar a Send(), pero envía adicionalmente un salto de línea al final. El salto de línea es necesario, en la mayoría de procesos, para que se reconozca a la cadena enviada, como un comando.

El método SendFile(), envía el contenido completo de un archivo al terminal.

El salto de línea a enviar depende del valor de "LineDelimSend".

Para enviar caracteres de control, se debe usar el método SendVT100Key(), porque los caracteres de control, deben convertirse primero en secuencias de escape, al menos para los aplicativos que reconozcan las secuencias de escape. Por ejemplo si se envía la tecla direccional derecha, con SendVT100Key(), primero se transformará en la secuencia ESC+[C.

Para enviar simples comandos (que son secuencias de caracteres imprimibles), basta con usar SenLn().

En principio, solo debería mandarse un solo comando por SendLn() porque, enviar más de un comando podría hacer que el proceso pase repetidamente por  las fases:

ECO_BUSY -> ECO_READY -> ECO_BUSY ... -> ECO_READY.

Haciendo que se pase de un estado de libre a ocupado de forma automática, y pudiendo complicar a alguna rutina que esté programada para enviar más comandos cuando detecte que el proceso se encuentre libre.

Los datos de salida que van llegando del proceso, no se guardan completamente en la
clase. Solo se mantienen las líneas de trabajo del terminal VT100 en el objeto "term".
Así se ahorra memoria, porque por lo general, el texto de salida está destinado a ser almacenado en algún otro control como un editor de texto o una grilla.
Es responsabilidad del programador, limitar el tamaño de los datos almacenados.

Los datos de salida que llegan por el terminal, se recuperan por sondeo del flujo de salida. Por defecto, se explora la salida en intervalos de 50 milisegundos(20 veces por segundo), y usando un "buffer" interno de 2048 bytes.

Para cambiar el periodo de sondeo de la salida del proceso, se debe cambiar el valor de la propiedad 'clock.interval' (en milisegundos). Se puede trabajar bien con periodos de 100 mseg o aún más, si la cantidad de información es baja. Pero no es recomendable bajar a menos de 50 mseg, porque se genera una carga adicional de CPU (aún cuando no llegen datos). Solo se debería bajar este periodo cuando se requiera procesar los datos de llegada, de forma inmediata.

## Saltos de línea al enviar

Dentro de UnTerminal, se pueden configurar los caracteres de salto de línea que se usarán, tanto para el envío, como para la recepción.

Para configurar los caracteres de salto de línea, en el envío, se debe usar la propiedad "LineDelimSend", que puede tomar los siguientes valores: 

* LDS_CRLF   //Envía los caracteres CR y LF
* LDS_CR     //Envía solo CR (caracter #13)
* LDS_LF     //Envía solo LF (caracter #10) 

Configurar el salto de línea para envío, implica que se agregarán los caracteres configurados, cada vez que se usen los métodos TConsoleProc.SendLn o TConsoleProc.SendFile, independientemente del tipo de delimitador que se haya incluido en la cadena. Lso siguientes ejemplos, ilustrarán el conportamiento de SendLn, cuandos se configura "LineDelimSend".

Si se ha definido LineDelimSend en LDS_LF, entonces:

SendLn('aaa');             //Enviará realmente 'aaa'#10
SendLn('aaa'#10);          //Enviará realmente 'aaa'#10
SendLn('aaa'#13);          //Enviará realmente 'aaa'#10
SendLn('aaa'#13#10);       //Enviará realmente 'aaa'#10
SendLn('aaa'#13#10'bbb');  //Enviará realmente 'aaa'#10'bbb'#10

Como se ve, cuando se configura un caracter de salto de línea, se cambian todos los saltos de línea para que se use solo el salto de línea configurado.

En general, se debe poner a "LineDelimSend" en LDS_LF, para los procesos en Linux/UNIX y se debe dejar en LDS_CRLF, para los procesos en Windows.

La propiedad "LineDelimSend", no tiene efecto sobre el método TConsoleProc.Send(), que seguirá enviando siempre, los caracteres indicados.

## Saltos de línea al recibir

Para configurar los caracteres de salto de línea, en la recepción, se debe usar la propiedad "LineDelimRecv", que puede tomar los siguientes valores: 

* LDR_CRLF  //El salto de línea es CR-LF (o LF-CR)
* LDR_CR    //El salto de línea es este caracter. Se ignora LF
* LDR_LF    //El salto de línea es este caracter. Se ignora CR
* LDR_CR_LF //El salto de línea es este CR o LF
   
Cuando se configura "LineDelimRecv", se estará indicando a las rutinas de recepción, cómo es que deben interpretar los caracteres CR y LF. Si por ejemplo se configura a "LineDelimRecv" en LDR_LF, entonces cada vez que se reciba el caracter LF, se interpretará como un salto de línea, ignorando al caracter CR.

En general, se debe poner a "LineDelimRecv" en LDR_LF, para los procesos en Linux/UNIX y se debe dejar en LDR_CRLF, para los procesos en Windows.

El evento TTermVT100.OnLineCompleted(), se genera cuando se detecta la llegada del caracter (o caracteres) de salto de línea. Además se pasa como parámetro, a la línea actual. 


# Detección del Prompt

La detección del Prompt se hace explorando las cadenas de texto que van llegando del proceso, para ver si coinciden con los parámetros de la detección. Esta forma puede no ser muy confiable si el Prompt del proceso es muy cambiante.

Los datos de salida que van generando el proceso, se reciben en bloques que pueden tener tamaño variable, pero que no exceden a UBLOCK_SIZE. La búsqueda del prompt se hace siempre en la última línea de cada bloque de datos que se recibe del proceso (En el método ReadData()). Si el proceso debe enviar demasiada información, esta suele llegar en varios bloques, pero siempre se espera que el prompt (al menos la parte final), llegue en el último bloque recibido. No se explora cada línea recibida, para disminuir la carga de procesamiento.

Para configurar la detección del Prompt se debe poner la propiedad 'detecPrompt' en TRUE y fijar valores para 'promptIni' y 'promptFin'. Estas cadenas determinan la parte inicial y final del prompt.

Si el prompt es fijo y no cambia, se puede poner su valor directamente en 'promptIni' y se deja 'promptFin' vacío. Pero si el prompt es variable, se puede poner la parte inicial en 'promptIni' y la parte final en 'promptFin', pero eligiendo valores que no den lugar a confusión con líneas de datos.

Así, por ejemplo para detectar un prompt de tipo:

```[usuario@localhost ~]$ ```

Se puede configurar: promptIni='[' y promptFin = '$ '. Los espacios son también parte del texto que se debe configurar.

Por defecto se espera que el prompt encontrado sea exactamnente igual a la última línea del texto que llega por el terminal. Pero existen opciones adicionales. El tipo de coincidencia se puede configurar en la variable 'promptMatch'. Puede tener los siguientes valores:

*   prmExactly,   //prompt es la línea entera
*   prmAtBegin,   //prompt aparece al inicio de la línea
*   prmAtEnd,     //prompt aparece al final de la línea
*   prmAtAnyPos   //prompt aparece en cualquier parte de la línea

Por defecto, 'promptMatch' está en 'prmExactly'.

Tambíen se puede usar la función de configuración automática del prompt, que se ejecuta llamando al método AutoConfigPrompt. Pero este método debe ser llamado cuando se tenga el Pprompt visible en la última línea del terminal.

'AutoConfigPrompt' lee la última línea asumiendo que es el prompt y fija valores automáticamente para 'promptIni' y 'promptFin'.

Se puede usar también una rutina personalizada para la detección del prompt. Esta se debe enganchar al evento OnChkForPrompt() que tiene la forma:

function(lin: string): boolean;

El evento recibe la línea a explorar y debe devolver TRUE, si es que se determina que la línea actual contiene al prompt. Al activar este evento, se desactiva la detección interna de la unidad.