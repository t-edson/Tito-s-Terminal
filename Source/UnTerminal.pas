{
UnTerminal 0.4b
===============
Por Tito Hinostroza 25/08/2014

* Se crea el método SendVT100Key(), para enviar teclas de control traduciéndolas a
secuencias en VT100,
* Se agregó el evento OnChkForPrompt(), para poder agregar una rutina de verificación
externa del Prompt.
* Se agrega el evento SendFile(), para poder enviar el contenido completo de un
archivo.
* Se separan mensajes de texto en constantes para facilitar la traducción.
* Se cambia nombre de propiedad AnchoTerminal por TerminalWidth.
}
{
Descripción
===========
Derivada de la unidad ConexOraSQlP 0.5. Esta unidad permite procesar la entrada y
salida de un cliente de telnet, que trabaja como una consola.
Permite además detectar el prompt y el estado de "ocupado" y "listo".

Para conectarse mediante un proceso, se debe crear una instancia de TConexProc, y seguir la
secuencia de conexión:

  p := TConexProc.Create(StatusBar1.Panels[1]);  //Crea conexión
  ...
  p.Free.

Opcionalmente se le puede pasar la referencia a un panel de una barra de estado, para
que se muestren íconos que indiquen el estado de la conexión (poner en NIL si no se
usará). En este caso se debe manejar el evento OnDrawPanel() de la Barra de estado:

 StatusBar1.OnDrawPanel:=@SBDrawPanel;
 ...
 procedure Form1.SBDrawPanel(StatusBar:TStatusBar; Panel:TStatusPanel; const Rect:TRect);
 begin
  if panel.Index = 1 then q.DibPanelEstado(StatusBar.Canvas, Rect);
 end;


Está unidad está pensada para ser usada en conexiones lentas, y con volúmenes
considerables de datos, por ello se maneja la llegada de datos completamente por eventos.

Para el manejo de la pantalla usa un terminal VT100 sencillo, de la unidad TermVT. Sin
embargo, esta unidad ha sido diseñada para poder recibir el texto del VT100, en un
TStringList, y poder registrar permanentemente el contenido.

 Para configurar un editor para mostrar la salida del proceso, se debe usar los eventos:
 OnInitLines(), OnRefreshLine(), OnRefreshLines() y OnAddLine():


  proc.OnInitLines:=@procInitLines;
  proc.OnRefreshLine:=@procRefreshLine;
  proc.OnRefreshLines:=@procRefreshLines;
  proc.OnAddLine:=@procAddLine;

procedure TfrmPrincipal.procInitLines(const grilla: TtsGrid; fIni, fFin: integer);
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

El evento OnInitLines(), es llamado solo una vez al inicio para dimensionar el StringList,
de modo que pueda contener a todas las líneas del terminal VT100.

Los datos de salida que van llegando del proceso, no se guardan completamente en la
clase. Solo se mantienen las líneas de trabajo del terminal VT100 en el objeto "term".
Así se ahorra memoria, porque por lo general, el texto de salida está destinado a ser
almacenado en algún otro control como un editor de texto o una grilla.
Es responsabilidad del programador, limitar el tamaño de los datos almacenados.

                                                    Por Tito Hinostroza  27/06/2014
 }
unit UnTerminal;

{$mode objfpc}{$H+}
interface
uses  Classes, SysUtils, Process, ExtCtrls, Dialogs, Graphics, ComCtrls,
     LCLProc, LCLType, types, Strutils, TermVT;
const
  UBLOCK_SIZE = 2048;    //Tamaño de bloque de lectura de salida de proceso

type

TEstadoCon = (
   ECO_CONNECTING, //Iniciado y Conectando
   ECO_ERROR_CON,  //Iniciado y Con error de conexión
   ECO_BUSY,       //Iniciado y conectado, pero ejecutando algún proceso
   ECO_READY,      //Iniciado y conectado, libre para aceptar comandos.
   ECO_STOPPED     //Proceso no iniciado. Puede que haya datos pendientes en el "buffer"
);

{Evento. Pasa la cantidad de bytes que llegan y la columna y fila final de la matriz Lin[] }
TEvProcState = procedure(nDat: integer; pFinal: TPoint) of object;
TEvLlegoPrompt = procedure(prompt: string; pIni: TPoint; HeightScr: integer) of object;
TEvChkForPrompt = function(lin: string): boolean;
TEvRecSysComm = procedure(info: string; pIni: TPoint) of object;

TEvRefreshAll  = procedure(const grilla: TtsGrid; linesAdded: integer) of object;
TEvAddLines    = procedure(const grilla: TtsGrid; fIni, fFin: integer) of object;
TEvRefreshLine = procedure(const grilla: TtsGrid; fIni, HeightScr: integer) of object;
TEvRefreshLines= procedure(const grilla: TtsGrid; fIni, fFin, HeightScr: integer) of object;
TEvOnAddLine   = procedure(HeightScr: integer) of object;

{ TConexProc }
//Clase que define un proceso
TConexProc = class
protected
  panel     : TStatusPanel; //referencia a panel para nostrar estado
  lastState : TEstadoCon;  //Estado anterior
  txtState  : string;      //Cadena que describe el estado actual de la conexión
  FAnchoTerminal: integer;
  function ContienePrompt(const linAct, prIni, prFin: string): integer;
  function ContienePromptF(const linAct, prIni, prFin: string): integer;
  function EsPrompt(const cad: string): boolean;
  function GetAnchoTerminal: integer;
  procedure SetAnchoTerminal(AValue: integer);
public
  //datos del proceso
  progPath  : string;      //ruta del porgrama a lanzar
  progParam : string;      //parámetros del programa
  State     : TEstadoCon;  //Estado de la conexión
  sendCRLF  : boolean;     //envía CRLF en lugar de CR
  //manejo del prompt
  detecPrompt: boolean;    //activa la detección de prompt.
  detParcial :boolean;     //permite que la detección sea parcial
  prIni,prFin: string;     //cadena inicial, y final del prompt
  HayPrompt : boolean;     //bandera, indica si se detectó el prompt en la última línea

  msjError  : string;      //guarda el mensaje de error
  term      : TTermVT100;  //Terminal

  //eventos de cambio de estado
  OnConnecting : TEvProcState;    //indica que se inicia el proceso y trata de conectar
  OnBusy       : TEvProcState;    //indica que está esperando prompt
  OnStopped    : TEvProcState;    //indica que se terminó el proceso
  OnLlegoPrompt: TEvLlegoPrompt;  //indica que llegó el prompt
  OnChangeState: TEvRecSysComm;    //cambia de estado
  OnRecSysComm : TEvRecSysComm;   {indica que llegó información del sistema remoto (usuario,
                                  directorio actual, etc) Solo para conex. Telnet}
  OnChkForPrompt: TEvChkForPrompt; //Permite incluir una rutina externa para verificación de prompt.
  //eventos de llegada de datos
  OnRefreshAll  : TEvRefreshAll;   //Usado para refresvar todo el contenido del terminal
  OnInitLines   : TEvAddLines;     //indica que se debe agregar líneas de texto
  OnRefreshLine : TEvRefreshLine;  //indica que se deben refrescar una línea
  OnRefreshLines: TEvRefreshLines; //indica que se deben refrescar ese grupo de líneas
  OnAddLine     : TEvOnAddLine;    //inidca que se debe agregar una línea a la salida

  procedure Open;   //inicia proceso
  procedure Open(progPath0, progParam0: string); //Inicia conexión
  function Close: boolean;    //Termina la conexión
  procedure ClearTerminal;
  property TerminalWidth: integer read GetAnchoTerminal write SetAnchoTerminal;
  procedure Send(const txt: string);
  procedure SendLn(txt: string);  //Envía datos por el "stdin"
  procedure SendFile(name: string);  //Envía el contenido de un archivo
  procedure SendVT100Key(var Key: Word; Shift: TShiftState);  //Envía una tecla con secuencia de escape
  //control de barra de estado
  procedure RefPanelEstado;
  procedure DibPanelEstado(c: TCanvas; const Rect: TRect);
  function LastLine: string;  //devuelve la última línea
  procedure AutoConfigPrompt;
  //respuesta a eventos de term
  procedure termAddLine;
  procedure termRefreshLine(fil: integer);
  procedure termRefreshLines(fIni, fFin: integer);
  procedure termRefreshScreen(linesAdded: integer);
  procedure termRecSysComm(info: string);
  //constructor y destructor
  constructor Create(PanControl: TStatusPanel);     //Constructor
  destructor Destroy; override;   //Limpia los buffers
private
  p       : TProcess;   //el proceso a manejar
  bolsa   : array[0..UBLOCK_SIZE] of char;  //buffer para almacenar salidas(tiene un caracter más)
  nLeidos : LongInt;
  lstTmp  : TStringList;

  clock   : TTimer;     //temporizador para leer salida del proceso
  cAnim   : integer;    //contador para animación de ícono de estado
  angA    : integer;    //contador para animación de ícono de estado
  procedure RefresConexion(Sender: TObject);  //Refresca la conexión
  function LeeSalidaProc:boolean;
  function CambiarEstado(estado0: TEstadoCon): boolean;  //Cambia el State actual
end;

implementation
//uses FormConfig;   //se necesita acceder a las propiedades de prompt
const
  NUM_LIN_ATRAS = 12;  {número de línea a explorar, hacia atrás, para buscar mensajes de
                        error}
  STA_NAME_CONNEC  = 'Connecting';
  STA_NAME_ERR_CON = 'Connection Error';
  STA_NAME_BUSY    = 'Busy';
  STA_NAME_READY   = 'Ready';
  STA_NAME_STOPPED = 'Stopped';
  MSG_ERR_NO_APP_DEF = 'No Application specified for connection.';
  MSG_FAIL_START_APP = 'Fail Starting Application: ';
  MSG_NO_PRMP_FOUND  = 'Prompt Not Found for to configure in Terminal.';
{
  STA_NAME_CONNEC  = 'Conectando';
  STA_NAME_ERR_CON = 'Error en conexión';
  STA_NAME_BUSY    = 'Ocupado';
  STA_NAME_READY   = 'Disponible';
  STA_NAME_STOPPED = 'Detenido';
  MSG_ERR_NO_APP_DEF = 'No se especificó aplicativo para conexión.';
  MSG_FAIL_START_APP = 'Fallo al iniciar aplicativo: ';
  MSG_NO_PRMP_FOUND  = 'No se encuentra un prompt en el terminal para configurarlo.';
//}

function Explode(delimiter:string; str:string):TStringDynArray;
var
   p,cc,dsize:integer;
begin
   cc := 0;
   dsize := length(delimiter);
   while true do begin
     p := pos(delimiter,str);
     if p > 0 then begin
       inc(cc);
       setlength(result,cc);
       result[cc-1] := copy(str,1,p-1);
       delete(str,1,p+dsize-1);
     end else break;
   end;
   inc(cc);
   setlength(result,cc);
   result[cc-1] := str;
end;

function TConexProc.CambiarEstado(estado0: TEstadoCon): boolean;
{Cambia el estado de la conexión  y actualiza un panel con información sobre el estado}
begin
  lastState := State;  //pasa State actual a anterior
  State := estado0;    //fija State actual
  if lastState <> State then begin   //indica si hubo cambio
    //hubo cambio de State
    Result := true;
    case State of
    ECO_CONNECTING: begin
        txtState := STA_NAME_CONNEC;
        RefPanelEstado;  //fuerza a redibujar panel con el nuevo State
        if OnConnecting<>nil then OnConnecting(0,term.CurXY);
      end;
{    ECO_ERROR_CON: begin
        txtState := STA_NAME_ERR_CON;
        RefPanelEstado;  //fuerza a redibujar panel con el nuevo State
        if OnErrorConex <> nil then OnErrorConex(nLeidos, pErr);
      end;}
    ECO_BUSY: begin
        txtState := STA_NAME_BUSY;
        RefPanelEstado;  //fuerza a redibujar panel con el nuevo State
        if OnBusy <> nil then OnBusy(nLeidos, term.CurXY);
      end;
    ECO_READY: begin
        txtState := STA_NAME_READY;
        RefPanelEstado;  //fuerza a redibujar panel con el nuevo State
        if OnLlegoPrompt <> nil then OnLlegoPrompt('', term.CurXY, term.height);
      end;
    ECO_STOPPED: begin
        txtState := STA_NAME_STOPPED;
        RefPanelEstado;  //fuerza a redibujar panel con el nuevo State
        if OnStopped <> nil then OnStopped(nLeidos, term.CurXY);
      end;
    end;
    if OnChangeState<>nil then OnChangeState(txtState, term.CurXY);
  end;
end;
function TConexProc.LastLine: string;
//Devuelve la línea donde se encuentra el cursor. Salvo que haya, saltos en el cursor,
//devolverá siempre los últimos caracteres recibidos.
begin
  Result := term.buf[term.CurY];
end;
procedure TConexProc.RefPanelEstado;   //Refresca el estado del panel del StatusBar asociado.
begin
  if panel = nil then exit;  //protección
  //fuerza a llamar al evento OnDrawPanel del StatusBar
  panel.StatusBar.InvalidatePanel(panel.Index,[ppText]);
  //y este a us vez debe llamar a DibPanelEstado()
end;
procedure TConexProc.DibPanelEstado(c: TCanvas; const Rect: TRect);
{Dibuja un ícono y texto, de acuerdo al estado de la conexión. Este código está pensado
 para ser usado en el evento OnDrawPanel() de una barra de estado}
var
  p1,p2: Tpoint;
  procedure Torta(c: Tcanvas; x1,y1,x2,y2: integer; a1,a2: double);  //dibuja una torta
  var x3,y3,x4,y4: integer;
      xc, yc: integer;
  begin
    xc := (x1+x2) div 2; yc := (y1+y2) div 2;
    x3:=xc + round(1000*cos(a1));
    y3:=yc + round(1000*sin(a1));
    x4:=xc + round(1000*cos(a2));
    y4:=yc + round(1000*sin(a2));
    c.pie(x1,y1,x2,y2,x3,y3,x4,y4);
  end;
  procedure Circulo(c: Tcanvas; xc,yc: integer; n: integer);  //dibuja un círculo
  const r = 2;
  begin
    case n of
    5: c.Brush.Color:=$B0FFB0;
    4: c.Brush.Color:=$40FF40;
    3: c.Brush.Color:=$00E000;
    2: c.Brush.Color:=$00CC00;
    1: c.Brush.Color:=$00A000;
    0: c.Brush.Color:=$008000;
    else
     c.Brush.Color:=clWhite;
    end;
    c.Pen.Color:=c.Brush.Color;
    c.Ellipse(xc-r, yc-r+1, xc+r, yc+r+1);
  end;
begin
  if State in [ECO_CONNECTING, ECO_BUSY] then begin  //estados de espera
    c.Pen.Width:=0;  //restaura ancho
    Circulo(c,Rect.Left+5,Rect.Top+5, angA);
    inc(angA);if angA>7 then angA:=0;
    Circulo(c,Rect.Left+9,Rect.Top+3, angA);
    inc(angA);if angA>7 then angA:=0;
    Circulo(c,Rect.Left+13,Rect.Top+5, angA);
    inc(angA);if angA>7 then angA:=0;
    Circulo(c,Rect.Left+15,Rect.Top+9, angA);
    inc(angA);if angA>7 then angA:=0;
    Circulo(c,Rect.Left+13,Rect.Top+13, angA);
    inc(angA);if angA>7 then angA:=0;
    Circulo(c,Rect.Left+9,Rect.Top+15, angA);
    inc(angA);if angA>7 then angA:=0;
    Circulo(c,Rect.Left+5,Rect.Top+13, angA);
    inc(angA);if angA>7 then angA:=0;
    Circulo(c,Rect.Left+3,Rect.Top+9, angA);
    inc(angA);if angA>7 then angA:=0;

  end else if State = ECO_ERROR_CON then begin //error de conexión
    //c´rculo rojo
    c.Brush.Color:=clRed;
    c.Pen.Color:=clRed;
    c.Ellipse(Rect.Left+2, Rect.Top+2, Rect.Left+16, Rect.Top+16);
    //aspa blanca
    c.Pen.Color:=clWhite;
    c.Pen.Width:=2;
    p1.x := Rect.Left+5; p1.y := Rect.Top+5;
    p2.x := Rect.Left+12; p2.y := Rect.Top+12;
    c.Line(p1,p2);
    p1.x := Rect.Left+5; p1.y := Rect.Top+12;
    p2.x := Rect.Left+12; p2.y := Rect.Top+5;
    c.Line(p1,p2);
  end else if State = ECO_READY then begin //disponible
    c.Brush.Color:=clGreen;
    c.Pen.Color:=clGreen;
    c.Ellipse(Rect.Left+2, Rect.Top+2,Rect.Left+16, Rect.Top+16);
    c.Pen.Color:=clWhite;
    c.Pen.Width:=2;
    p1.x := Rect.Left+6; p1.y := Rect.Top+7;
    p2.x := Rect.Left+8; p2.y := Rect.Top+12;
    c.Line(p1,p2);
    p1.x := Rect.Left+12; p1.y := Rect.Top+5;
//    p2.x := Rect.Left+12; p2.y := Rect.Top+5;
    c.Line(p2,p1);
  end else begin            //estados detenido
    //círculo gris
    c.Brush.Color:=clGray;
    c.Pen.Color:=clGray;
    c.Ellipse(Rect.Left+2, Rect.Top+2, Rect.Left+16, Rect.Top+16);
    //aspa blanca
    c.Pen.Color:=clWhite;
    c.Pen.Width:=2;
    p1.x := Rect.Left+5; p1.y := Rect.Top+5;
    p2.x := Rect.Left+12; p2.y := Rect.Top+12;
    c.Line(p1,p2);
    p1.x := Rect.Left+5; p1.y := Rect.Top+12;
    p2.x := Rect.Left+12; p2.y := Rect.Top+5;
    c.Line(p1,p2);
  end;
  c.Font.Color:=clBlack;
  c.TextRect(Rect, 19 + Rect.Left, 2 + Rect.Top, txtState);
end;

function TConexProc.GetAnchoTerminal: integer;
//Devuelve el ancho del terminal
begin
  Result := term.width;
end;
procedure TConexProc.SetAnchoTerminal(AValue: integer);
//Fija el ancho del terminal
begin
  if term.width=AValue then Exit;
  term.width := AValue;
end;

procedure TConexProc.Open;
//Inicia el proceso y verifica si hubo error al lanzar el proceso.
begin
  //Inicia la salida de texto, refrescando todo el terminal
  if OnInitLines<>nil then OnInitLines(term.buf, 1, term.height);
  if p.Running then p.Terminate(0);  { TODO : ¿No debería mandar CTRL-C y EXIT si la conexión está buena? }
  // Vamos a lanzar el compilador de FreePascal
  p.CommandLine := progPath + ' ' + progParam;
  // Definimos comportamiento de 'TProccess'. Es importante direccionar los errores.
  p.Options := [poUsePipes, poStderrToOutPut, poNoConsole];
  //ejecutamos
  CambiarEstado(ECO_CONNECTING);
  try
    p.Execute;
    if not p.Running then begin
       //Falló al iniciar
       CambiarEstado(ECO_STOPPED);
       Exit;
    end;
    //Se inició, y esperamos a que RefresConexion() procese los datos recibidos
  except
    if trim(p.CommandLine) = '' then
      msjError := MSG_ERR_NO_APP_DEF
    else
      msjError := MSG_FAIL_START_APP + p.CommandLine;
    CambiarEstado(ECO_ERROR_CON); //genera evento
  end;
end;
procedure TConexProc.Open(progPath0, progParam0: string);
//Similar a Open, pero permite indicar programa
begin
  term.Clear;

  progPath := progPath0;
  progParam := progParam0;  //guarda cadena de conexión
  if trim(progPath) = '' then exit;  //protección
  Open;   //puede dar error
end;
function TConexProc.Close: boolean;
//Cierra la conexión actual. Si hay error devuelve False.
var c: integer;
begin
  Result := true;
  //verifica el proceso
  if p.Running then p.Terminate(0);  { TODO : ¿No debería mandar CTRL-C y EXIT si la conexión está buena? }
  //espera hasta 100 mseg
  c := 0;
  while p.Running and (c<20) do begin
    sleep(5);
    inc(c);
  end;
  if c>= 20 then exit(false);  //sale con error
  //Pasa de Runnig a Not Running
  CambiarEstado(ECO_STOPPED);
  //Puede que quede datos en el "stdout"
  LeeSalidaProc; //lee lo que queda
end;
procedure TConexProc.ClearTerminal;
{Reinicia el terminal iniciando en (1,1) y limpiando la grilla}
begin
  term.Clear;   //limpia grilla y reinicia cursor
  //genera evento para reiniciar salida
  if OnInitLines<>nil then OnInitLines(term.buf, 1, term.height);
end;

function TConexProc.ContienePrompt(const linAct, prIni, prFin: string): integer;
//Verifica si una cadena contiene al prompt, usando los valores de cadena inicial (prIni)
//y cadena final (prFin). La veriifcación se hace siempre desde el inicio de la cadena.
//Si la cadena contiene al prompt, devuelve la longitud del prompt hallado, de otra forma
//devuelve cero.
//Si la salida del proceso va a ir a un editor con resaltador de sintaxis, esta rutina debe
//ser similar a la del resaltador para que haya sincronía en lo que se ve. No se separra esta
//rutina en otra unidad para que esta unidad no tenga dependencias y se pueda usar como
//librería. Además la detección del prompt para el proceso, es diferente de la deteción
//para un resaltador de sintaxis.
var
  l: Integer;
  pd: SizeInt;
begin
   Result := 0;   //valor por defecto
   l := length(prIni);
   if (l>0) and (copy(linAct,1,l) = prIni) then begin
     //puede ser
     if prFin = '' then begin
       //no hace falta validar más
       Result := l;  //el tamaño del prompt
       exit;    //no hace falta explorar más
     end;
     //hay que validar la existencia del fin del prompt
     pd :=pos(prFin,linAct);
     if pd>0 then begin  //encontró
       Result := pd+length(prFin)-1;  //el tamaño del prompt
       exit;
     end;
   end;
end;
function TConexProc.ContienePromptF(const linAct, prIni, prFin: string): integer;
//Versión de ContienePrompt, pero busca siempre desde el final.
var
  l: Integer;
  pd: SizeInt;
begin
  Result := 0;   //valor por defecto
  if prIni='' then exit;
  l := length(prIni);
  if prFin = '' then begin //caso simple, solo evalúa prIni
    //Solo se valida con prIni
    if AnsiEndsStr(prIni, linAct) then
      Result := l  //el tamaño del prompt
    else
      Result := 0;
    exit;    //no hace falta explorar más
  end else begin  //debe usar prIni y prFin
    if AnsiEndsStr(prFin, linAct) then begin
      //termina con la cadena apropiada
      //vemos si contiene el inicio
      pd :=pos(prIni,linAct);
      if pd>0 then begin  //encontró
        Result := l-pd+1;  //el tamaño del prompt
      end;
      exit;
    end else begin
      //no termina como debe
      exit;
    end;
  end;
end;
function TConexProc.EsPrompt(const cad: string): boolean;
//Indica si la línea dada, es el prompt, de acuerdo a los parámetros dados. Esta función
//se pone aquí, porque aquí se tiene fácil acceso a las configuraciones del prompt.
var
  n: Integer;
begin
  if detecPrompt then begin  //si hay detección activa
    n := ContienePrompt(cad, prIni, prFin);
    if detParcial then begin
      Result := (n>0);
    end else begin  //debe ser exacto
      Result := (n>0) and  (n = length(cad));
    end;
  end else begin
    Result := false;
  end;
end;
function TConexProc.LeeSalidaProc: boolean;
{Verifica la salida del proceso. Si llegan datos los pasa a "term" y devuelve TRUE.
Lee en un solo bloque si el tamaño de los datos, es menor que UBLOCK_SIZE, en caso
contrario lee varios bloques. Actualiza "nLeidos", "HayPrompt". }
var nDis : longint;
    nBytes : LongInt;
begin
//  pIni := LeePosFin;
  Result := false;        //valor por defecto
  nLeidos := 0;
  HayPrompt := false;
  if P.Output = nil then exit;  //no hay cola
  repeat
    //vemos cuantos bytes hay "en este momento"
    nDis := P.Output.NumBytesAvailable;
    if nDis = 0 then break;  //sale del lazo
    if nDis < UBLOCK_SIZE then  begin
      //leemos solo los que hay, sino se queda esperando
      nBytes := P.Output.Read(bolsa, nDis);
      bolsa[nBytes] := #0;   //marca fin de cadena
      term.AddData(@bolsa);  //puede generar eventos
      nLeidos += nBytes;
    end else begin
      //leemos bloque de UBLOCK_SIZE bytes
      nBytes := P.Output.Read(bolsa, UBLOCK_SIZE);
      bolsa[nBytes] := #0;   //marca fin de cadena
      term.AddData(@bolsa);  //puede generar eventos
      nLeidos += nBytes;
    end;
    {aquí también se puede detetar el prompt, con más posibilidad de detectar los
    posibles prompt intermedios}
    Result := true;    //hay datos
  until not P.Running or (nBytes = 0);
  if not Result then exit;
  {Terminó de leer, aquí detectamos el prompt, porque es casi seguro que llegue
   al final de la trama.
  Se Detecta el prompt, viendo que la línea actual, sea realmente el prompt. Se probó
  viendo si la línea actual empezaba con el prompt, pero daba casos (sobretodo en
  conexiones lentas) en que llegaba una trama con pocos cracteres, de modo que se
  generaba el evento de llegada de prompt dos veces (tal vez más) en una misma línea}
  if OnChkForPrompt <> nil then begin
    //Hay rutina de verificación externa
    HayPrompt:=OnChkForPrompt(term.buf[term.CurY]);
  end else begin
    if EsPrompt(term.buf[term.CurY]) then
      HayPrompt:=true;
  end;
  {Se pone fuera, la rutina de detcción de prompt, porque también debe servir al
  resaltador de sintaxis}
end;
procedure TConexProc.RefresConexion(Sender: TObject);
//Refresca el estado de la conexión. Verifica si hay datos de salida del proceso.
begin
  if State = ECO_STOPPED then Exit;  //No está corriendo el proceso.
  if p.Running then begin
     //Se está ejecutando
     if LeeSalidaProc then begin //actualiza "HayPrompt"
        if State in [ECO_READY, ECO_BUSY] then begin
           if HayPrompt then begin
              CambiarEstado(ECO_READY);
           end else begin
              CambiarEstado(ECO_BUSY);
           end;
        end else begin
           //Se está esperando conseguir la conexión (State = ECO_CONNECTING)
           //Puede que se detenga aquí con un mensaje de error en lugar del prompt
           if HayPrompt then begin
              //se consiguió conectar por primera vez
//              State := ECO_READY;  //para que pase a ECO_BUSY
//              SendLn(COMAN_INIC); //envía comandos iniciales (lanza evento Ocupado)
              CambiarEstado(ECO_READY);
           end;
        end;
     end;
  end else begin //terminó
     CambiarEstado(ECO_STOPPED);
     LeeSalidaProc; //lee por si quedaban datos en el buffer
  end;
  //actualiza animación
  inc(cAnim);
  if (cAnim mod 4) = 0 then begin
    if State in [ECO_CONNECTING, ECO_BUSY] then begin  //estados de espera
      inc(angA);if angA>7 then angA:=0;
      RefPanelEstado;
    end;
    cAnim := 0;
  end;
end;
procedure TConexProc.Send(const txt: string);
{Envía una cadena como como flujo de entrada al proceso.
Es importante agregar el caracter #13#10 al final. De otra forma no se leerá el "stdin"}
begin
  if p = NIL then exit;
  if not p.Running then exit;
  p.Input.Write(txt[1], length(txt));  //pasa el origen de los datos
  //para que se genere un cambio de State aunque el comando sea muy corto
  if State = ECO_READY then CambiarEstado(ECO_BUSY);
end;
procedure TConexProc.SendLn(txt: string);
{Envía un comando al proceso. Incluye el salto de línea al final de la línea.
 También puede recibir cadneas de varias líneas}
begin
  //reemplaza todos los saltos por #1
  txt := StringReplace(txt,#13#10,#1,[rfReplaceAll]);
  txt := StringReplace(txt,#13,#1,[rfReplaceAll]);
  txt := StringReplace(txt,#10,#1,[rfReplaceAll]);
  //incluye el salto final
  txt += #1;
  //aplica el salto configurado
  if sendCRLF then begin
    txt := StringReplace(txt,#1,#13#10,[rfReplaceAll]); //envía CRLF
  end else begin
    txt := StringReplace(txt,#1,#10,[rfReplaceAll]);  //envía LF
//  txt := StringReplace(txt,#1,#13,[rfReplaceAll]);  //envía CR
  end;
  Send(txt);
end;

procedure TConexProc.SendFile(name: string);
//Envía el contendio completo de un archivo
var lins: TstringList;
  lin: String;
begin
  lins:= TstringList.Create;
  if not FileExists(name) then exit;
  lins.LoadFromFile(name);
  for lin in lins do
    SendLn(lin);
  lins.Free;
end;
procedure TConexProc.SendVT100Key(var Key: Word; Shift: TShiftState);
//Envía una tecla de control (obtenida del evento KeyDown), realizando primero
//la transformación a secuencias de escapa.
begin
  case Key of
  VK_END  : begin
      if Shift = [] then Send(#27'[K');
    end;
  VK_HOME : begin
      if Shift = [] then Send(#27'[H');
    end;
  VK_LEFT : begin
      if Shift = [] then Send(#27'[D');
    end;
  VK_RIGHT: begin
      if Shift = [] then Send(#27'[C');
    end;
  VK_UP   : begin
      if Shift = [] then Send(#27'[A');
    end;
  VK_DOWN : begin
      if Shift = [] then Send(#27'[B');
    end;
  VK_F1   : begin
      if Shift = [] then Send(#27'OP');
    end;
  VK_F2   : begin
      if Shift = [] then Send(#27'OQ');
    end;
  VK_F3   : begin
      if Shift = [] then Send(#27'OR');
    end;
  VK_F4   : begin
      if Shift = [] then Send(#27'OS');
    end;
  VK_BACK : begin
      if Shift = [] then Send(#8);  //no transforma
    end;
  VK_TAB : begin
      if Shift = [] then Send(#9);  //no transforma
    end;
  VK_A..VK_Z: begin
      if Shift = [ssCtrl] then begin  //Ctrl+A, Ctrl+B, ... Ctrl+Z
        Send(chr(Key-VK_A+1));
      end;
    end;
  end;
end;

//respuesta a eventos de term
procedure TConexProc.termAddLine;
//Se pide agregar líneas a la salida
begin
  if OnAddLine<>nil then OnAddLine(term.height);
end;
procedure TConexProc.termRefreshScreen(linesAdded: integer);
//EVento que indica que se debe refrescar la pantalla
begin
  if OnRefreshAll<>nil then OnRefreshAll(term.buf, linesAdded);  //evento
end;
procedure TConexProc.termRefreshLine(fil: integer);
//Se pide refrescar una línea.
//"term.height - fil" es la distancia al final de la pantalla VT100
begin
  if OnRefreshLine<> nil then OnRefreshLine(term.buf, fil, term.height);
end;
procedure TConexProc.termRefreshLines(fIni, fFin: integer);
//Se pide refrescar un rango de líneas
begin
  if OnRefreshLines<> nil then OnRefreshLines(term.buf, fIni, fFin, term.height);
end;
procedure TConexProc.termRecSysComm(info: string);
//Se ha recibido comando con información del sistema.
begin
  //se indica que se recibe información del sistema
  if OnRecSysComm<>nil then OnRecSysComm(info, term.CurXY);
  //Se puede asumir que llega el prompt pero no siempre funciona
//  HayPrompt := true;    //marca bandera
//  CambiarEstado(ECO_READY);  //cambia el State
end;
procedure TConexProc.AutoConfigPrompt;
//Configura el prompt actual como el prompt por defecto. Esta configuración no es
//para nada, precisa pero ahorrará tiempo en configurar casos sencillos
var
  ultlin: String;
  function SimbolosIniciales(cad: string): string;
  //Toma uno o dos símbolos iniciales de la cadena. Se usan símbolos porque
  //suelen ser fijos, mientras que los caracteres alfabéticos suelen cambiar
  //en el prompt.
  begin
    Result := cad[1];  //el primer caracter se tomará siempre
    if length(cad)>3 then begin
      //agrega si es un símbolo.
      if not (cad[2] in ['a'..'z','A'..'Z']) then
        Result += cad[2];
    end;
  end;
  function SimbolosFinales(cad: string): string;
  //Toma uno o dos o tres caracteres finales de la cadena. Se usan símbolos porque
  //suelen ser fijos, mientras que los caracteres alfabéticos suelen cambiar
  //en el prompt.
  var
    p: Integer;
    hayEsp: Boolean;
  begin
    p := length(cad);  //apunta al final
    hayEsp := (cad[p] = ' ');
    cad := TrimRight(cad);  //quita espacios
    if length(cad)<=2 then begin
      //hay muy pocos caracteres
      Result := cad[p-1]+cad[p];  //toma los últimos
      exit;
    end;
    //hay suficientes caracteres
    p := length(cad);  //apunta al final (sin espacios)
    Result := cad[p];
    //agrega si es un símbolo.
    if not (cad[p-1] in ['a'..'z','A'..'Z']) then
      Result := cad[p-1] + Result;
    //completa con espacio si hubiera
    if hayEsp then Result += ' ';
  end;
begin
  //utiliza la línea actual del terminal
  prIni := '';
  prFin := '';
  ultlin := LastLine;
  if ultlin = '' then begin
    ShowMessage(MSG_NO_PRMP_FOUND);
    exit;
  end;
  //casos particulares
  If ultlin = '>>> ' Then begin //caso especial
    DetecPrompt := true;
    prIni := '>>';
    prFin := ' ';
    SendLn(''); //para que detecte el prompt
    exit;
  end;
  If ultlin = 'SQL> ' Then begin //caso especial
    DetecPrompt := true;
    prIni := 'SQL> ';
    prFin := '';
    SendLn(''); //para que detecte el prompt
    exit;
  end;
  If length(ultlin)<=3 Then begin //caso especial
    DetecPrompt := true;
    prIni := ultlin;
    prFin := '';
    SendLn(''); //para que detecte el prompt
    exit;
  end;
  //caso general
  DetecPrompt := true;
  prIni := SimbolosIniciales(ultlin);
  prFin := SimbolosFinales(ultlin);
  SendLn(''); //para que detecte el prompt
end;
//constructor y destructor
constructor TConexProc.Create(PanControl: TStatusPanel);
//Constructor
begin
  progPath := '';  //ruta por defecto
  lstTmp := TStringList.Create;   //crea lista temporal
  p := TProcess.Create(nil); //Crea proceso
  CambiarEstado(ECO_STOPPED);  //State inicial. Genera el primer evento
  //configura temporizador
  clock := TTimer.Create(nil);
  clock.interval:=50;  {100 es un buen valor, pero para mayor velocidad de recepción, se
                        puede usar 50 milisegundos}
  clock.OnTimer := @RefresConexion;
  panel := PanControl;  //inicia referencia a panel
  if panel<> nil then
    panel.Style:=psOwnerDraw;  //configura panel para dibujarse por evento
  detecPrompt := true;    //activa detección de prompt por defecto
  sendCRLF := false;

  term := TTermVT100.Create; //terminal
  term.OnRefreshAll:=@termRefreshScreen;
  term.OnRefreshLine:=@termRefreshLine;
  term.OnRefreshLines:=@termRefreshLines;
  term.OnAddLine:=@termAddLine;
  term.OnRecSysComm:=@termRecSysComm; {usaremos este evento para detectar la llegada
                                      del prompt}
end;
destructor TConexProc.Destroy;
//Destructor
begin
  term.Free;
  clock.Free;  //destruye temporizador
  //verifica el proceso
  if p.Running then p.Terminate(0);
  //libera objetos
  FreeAndNIL(p);
  lstTmp.Free;    //limpia
end;

end.
