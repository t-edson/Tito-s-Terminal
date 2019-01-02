unit GenCod;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Graphics, Forms, SynEditHighlighter,
  MisUtils, SynFacilBasic, XpresParser, XpresTypes, XpresElements, strutils;

{Implementación de un interprete sencillo para el lenguaje Xpres.
Este módulo no generará código sino que lo ejecutará directamente.
Este intérprete, solo reconoce tipos de datos enteros y de cadena.
Para los enteros se implementan las operaciones aritméticas básicas, y
para las cadenas se implementa solo la concatenación(+)
Se pueden crear nuevas variables.

En este archivo, se pueden declarar tipos, variables, constantes,
procedimientos y funciones. Hay rutinas obligatorias que siempre se deben
implementar.

Este intérprete, está implementado con una arquitectura de pila.

* Todas las operaciones recibe sus dos parámetros en las variables p1 y p2.
* El resultado de cualquier expresión se debe dejar indicado en el objeto "res".
* Los valores enteros y enteros sin signo se cargan en valInt
* Los valores string se cargan en valStr
* Las variables están mapeadas en el arreglo vars[]
* Cada variable, de cualquier tipo, ocupa una celda de vars[]
* Los parámetros de las funciones se pasan siempre usando la pila.

Los procedimientos de operaciones, deben actualizar en el acumulador:

* El tipo de resultado (para poder evaluar la expresión completa como si fuera un
operando nuevo)
* La categoría del operador (constante, expresión, etc), para poder optimizar la generación
de código.

Ceerado Por Tito Hinostroza  30/07/2014
Modificado Por Tito Hinostroza  8/08/2015
Modificado Por Tito Hinostroza  29/11/2016
Modificado Por Tito Hinostroza  27/12/2016
}

const STACK_SIZE = 32;
var
  /////// Tipos de datos del lenguaje ////////////
  tipInt : TType;   //entero flotante
  tipStr : Ttype;   //cadena
  tipBol  : TType;  //booleano
  //Pila virtual
  {La pila virtual se representa con una tabla. Cada vez que se agrega un valor con
  pushResult, se incrementa "sp". Para retornar "sp" a su valor original, se debe llamar
  a PopResult(). Luego de eso, se accede a la pila, de acuerdo al seguienet esquema:
  Cuando se usa cpara almacenar los parámetros de las funciones, queda así:
  stack[sp]   -> primer parámetro
  stack[sp+1] -> segundo parámetro
  ...
  }
  sp: integer;  //puntero de pila
  stack: array[0..STACK_SIZE-1] of TOperand;
  //variables auxiliares
  Timeout: integer; //variable de límite de cuenta de tiempo
type

  { TGenCod }

  TGenCod = class(TCompilerBase)
  private
    procedure bol_asig_bol;
    procedure bol_procLoad;
    procedure fun_clear(fun: TxpEleFun);
    procedure fun_close(fun: TxpEleFun);
    procedure fun_connect(fun: TxpEleFun);
    procedure fun_connectSSH(fun: TxpEleFun);
    procedure fun_connectTelnet(fun: TxpEleFun);
    procedure fun_detect_prompt(fun: TxpEleFun);
    procedure fun_disconnect(fun: TxpEleFun);
    procedure fun_fileopen(fun: TxpEleFun);
    procedure fun_logclose(fun: TxpEleFun);
    procedure fun_logopen(fun: TxpEleFun);
    procedure fun_logpause(fun: TxpEleFun);
    procedure fun_logstart(fun: TxpEleFun);
    procedure fun_logwrite(fun: TxpEleFun);
    procedure fun_messagebox(fun: TxpEleFun);
    procedure fun_messageboxI(fun: TxpEleFun);
    procedure fun_pause(fun: TxpEleFun);
    procedure fun_puts(fun: TxpEleFun);
    procedure fun_putsI(fun: TxpEleFun);
    procedure fun_sendln(fun: TxpEleFun);
    procedure fun_stop(fun: TxpEleFun);
    procedure fun_wait(fun: TxpEleFun);
    procedure fun_write(fun: TxpEleFun);
    procedure int_asig_int;
    procedure int_idiv_int;
    procedure int_igual_int;
    procedure int_mayori_int;
    procedure int_mayor_int;
    procedure int_menori_int;
    procedure int_menor_int;
    procedure int_mult_int;
    procedure int_procLoad;
    procedure int_resta_int;
    procedure int_suma_int;
    procedure LoadResBol(val: Boolean; catOp: TCatOperan);
    procedure LoadResInt(val: int64; catOp: TCatOperan);
    procedure LoadResStr(val: string; catOp: TCatOperan);
    procedure PopResult;
    procedure PushResult;
    procedure str_asig_str;
    procedure str_concat_str;
    procedure str_igual_str;
    procedure str_procLoad;
  protected
    //referencias de tipos adicionales de tokens
    tkStruct   : TSynHighlighterAttributes;
    tnStruct   : integer;
    tkExpDelim : TSynHighlighterAttributes;
    tnExpDelim : integer;
    tkBlkDelim : TSynHighlighterAttributes;
    tnBlkDelim : integer;
    tnOthers   : integer;
    ejec: boolean;       //permite poner al intérprete en modo "No Ejecución"
    procedure Cod_StartData;
    procedure Cod_StartProgram;
    procedure Cod_EndProgram;
    procedure expr_start;
    procedure expr_end(isParam: boolean);
  public
    stop: boolean;   //Bandera general para detener la ejecución. No se usa la de TCompilerBase
    procedure StartSyntax;
  end;

implementation
uses
  FormPrincipal, FormConfig, FrameCfgConex, UnTerminal;

{ TGenCod }
procedure TGenCod.LoadResInt(val: int64; catOp: TCatOperan);
//Carga en el resultado un valor entero
begin
    res.typ := tipInt;
    res.valInt:=val;
    res.catOp:=catOp;
end;
procedure TGenCod.LoadResStr(val: string; catOp: TCatOperan);
//Carga en el resultado un valor string
begin
    res.typ := tipStr;
    res.valStr:=val;
    res.catOp:=catOp;
end;
procedure TGenCod.LoadResBol(val: Boolean; catOp: TCatOperan);
//Carga en el resultado un valor string
begin
    res.typ := tipBol;
    res.valBool:=val;
    res.catOp:=catOp;
end;
procedure TGenCod.PushResult;
//Coloca el resultado de una expresión en la pila
begin
  if sp>=STACK_SIZE then begin
    GenError('Desborde de pila.');
    exit;
  end;
  stack[sp].typ := res.typ;
  case res.Typ.cat of
  t_string:  stack[sp].valStr  := res.ReadStr;
  t_integer: stack[sp].valInt  := res.ReadInt;
  end;
  Inc(sp);
end;
procedure TGenCod.PopResult;
//Reduce el puntero de pila, de modo que queda apuntando al último dato agregado
begin
  if sp<=0 then begin
    GenError('Desborde de pila.');
    exit;
  end;
  Dec(sp);
end;
////////////rutinas obligatorias
procedure TGenCod.Cod_StartData;
//Codifica la parte inicial de declaración de variables estáticas
begin
end;
procedure TGenCod.Cod_StartProgram;
//Codifica la parte inicial del programa
begin
  sp := 0;  //inicia pila
  Timeout := config.fcMacros.tpoMax;   //inicia variable
  stop := false;
  //////// variables predefinidas ////////////
  CreateVariable('timeout', 'int');
  CreateVariable('curIP', 'string');
  CreateVariable('curTYPE', 'string');
  CreateVariable('curPORT', 'int');
  CreateVariable('curENDLINE', 'string');
  CreateVariable('curAPP', 'string');
  CreateVariable('promptDETECT', 'boolean');
  CreateVariable('promptSTART', 'string');
  CreateVariable('promptEND', 'string');
end;
procedure TGenCod.Cod_EndProgram;
//Codifica la parte inicial del programa
begin
end;
procedure TGenCod.expr_start;
//Se ejecuta siempre al StartSyntax el procesamiento de una expresión
begin
  if exprLevel=1 then begin //es el primer nivel
    res.typ := tipInt;   //le pone un tipo por defecto
  end;
end;
procedure TGenCod.expr_end(isParam: boolean);
//Se ejecuta al final de una expresión, si es que no ha habido error.
begin
  if isParam then begin
    //Se terminó de evaluar un parámetro
    PushResult;   //pone parámetro en pila
    if HayError then exit;
  end;
end;
////////////operaciones con Enteros
procedure TGenCod.int_procLoad;
begin
  //carga el operando en res
  res.typ := tipInt;
  res.valInt := p1^.ReadInt;
end;
procedure TGenCod.int_asig_int;
begin
  if p1^.catOp <> coVariab then begin  //validación
    GenError('Solo se puede asignar a variable.'); exit;
  end;
  if not ejec then exit;
  //en la VM se puede mover directamente res memoria sin usar el registro res
  p1^.rVar.valInt := p2^.ReadInt;
//  res.used:=false;  //No hay obligación de que la asignación devuelva un valor.
  if Upcase(p1^.rVar.name) = 'TIMEOUT' then begin
    //variable interna
    config.fcMacros.TpoMax := p2^.ReadInt;
    config.fcConex.UpdateChanges;  //actualiza
  end else if Upcase(p1^.rVar.name) = 'curPORT' then begin
    //variable interna
    config.fcConex.Port := IntToStr(p2^.ReadInt);
    config.fcConex.UpdateChanges;  //actualiza
  end;
end;
procedure TGenCod.int_suma_int;
begin
  LoadResInt(p1^.ReadInt+p2^.ReadInt, coExpres);
end;
procedure TGenCod.int_resta_int;
begin
  LoadResInt(p1^.ReadInt-p2^.ReadInt, coExpres);
end;
procedure TGenCod.int_mult_int;
begin
  LoadResInt(p1^.ReadInt*p2^.ReadInt, coExpres);
end;
procedure TGenCod.int_idiv_int;
begin
  if not ejec then  //evitamos evaluar en este modo, para no generar posibles errores
    LoadResInt(0, coExpres)
  else
    LoadResInt(p1^.ReadInt div p2^.ReadInt, coExpres);
end;
procedure TGenCod.int_igual_int;
begin
  LoadResBol(p1^.ReadInt = p2^.ReadInt, coExpres);
end;
procedure TGenCod.int_mayor_int;
begin
  LoadResBol(p1^.ReadInt > p2^.ReadInt, coExpres);
end;
procedure TGenCod.int_mayori_int;
begin
  LoadResBol(p1^.ReadInt >= p2^.ReadInt, coExpres);
end;
procedure TGenCod.int_menor_int;
begin
  LoadResBol(p1^.ReadInt < p2^.ReadInt, coExpres);
end;
procedure TGenCod.int_menori_int;
begin
  LoadResBol(p1^.ReadInt <= p2^.ReadInt, coExpres);
end;

////////////operaciones con string
procedure TGenCod.str_procLoad;
begin
  //carga el operando en res
  res.typ := tipStr;
  res.valStr := p1^.ReadStr;
end;
procedure TGenCod.str_asig_str;
begin
  if p1^.catOp <> coVariab then begin  //validación
    GenError('Solo se puede asignar a variable.'); exit;
  end;
  if not ejec then exit;
  //aquí se puede mover directamente res memoria sin usar el registro res
  p1^.rVar.valStr := p2^.ReadStr;
  //  res.used:=false;  //No hay obligación de que la asignación devuelva un valor.
  if Upcase(p1^.rVar.name) = 'CURIP' then begin
    //variable interna
    config.fcConex.IP := p2^.ReadStr;
    config.fcConex.UpdateChanges;  //actualiza
  end else if Upcase(p1^.rVar.name) = 'CURTYPE' then begin
    //variable interna
    case UpCase(p2^.ReadStr) of
    'TELNET': config.fcConex.tipo := TCON_TELNET;  //Conexión telnet común
    'SSH'   : config.fcConex.tipo := TCON_SSH;     //Conexión ssh
    'SERIAL': config.fcConex.tipo := TCON_SERIAL;  //Serial
    'OTHER' : config.fcConex.tipo := TCON_OTHER;   //Otro proceso
    end;
    config.fcConex.UpdateChanges;  //actualiza
  end else if Upcase(p1^.rVar.name) = 'CURENDLINE' then begin
    //variable interna
    if UpCase(p2^.ReadStr) = 'CRLF' then
      config.fcConex.LineDelimSend := LDS_CRLF;
    if UpCase(p2^.ReadStr) = 'CR' then
      config.fcConex.LineDelimSend := LDS_CR;
    if UpCase(p2^.ReadStr) = 'LF' then
      config.fcConex.LineDelimSend := LDS_LF;
    config.fcConex.UpdateChanges;  //actualiza
  end else if Upcase(p1^.rVar.name) = 'CURAPP' then begin
    //indica aplicativo actual
    config.fcConex.Other := p2^.ReadStr;
    config.fcConex.UpdateChanges;  //actualiza
  end else if Upcase(p1^.rVar.name) = 'PROMPTSTART' then begin
    //indica aplicativo actual
    config.fcDetPrompt.prIni:= p2^.ReadStr;
    config.fcDetPrompt.detecPrompt := true;  //por defecto
    config.fcDetPrompt.ConfigCambios;  //actualiza
  end else if Upcase(p1^.rVar.name) = 'PROMPTEND' then begin
    //indica aplicativo actual
    config.fcDetPrompt.prFin:= p2^.ReadStr;
    config.fcDetPrompt.detecPrompt := true;  //por defecto
    config.fcDetPrompt.ConfigCambios;  //actualiza
  end;
end;

procedure TGenCod.str_concat_str;
begin
  LoadResStr(p1^.ReadStr + p2^.ReadStr, coExpres);
end;
procedure TGenCod.str_igual_str;
begin
  LoadResBol(p1^.ReadStr = p2^.ReadStr, coExpres);
end;
////////////operaciones con boolean
procedure TGenCod.bol_procLoad;
begin
  //carga el operando en res
  res.typ := tipStr;
  res.valBool := p1^.ReadBool;
end;
procedure TGenCod.bol_asig_bol;
begin
  if p1^.catOp <> coVariab then begin  //validación
    GenError('Solo se puede asignar a variable.'); exit;
  end;
  if not ejec then exit;
  //en la VM se puede mover directamente res memoria sin usar el registro res
  p1^.rVar.valBool := p2^.ReadBool;
//  res.used:=false;  //No hay obligación de que la asignación devuelva un valor.
  if Upcase(p1^.rVar.name) = 'PROMPTDETECT' then begin
    //variable interna
    config.fcDetPrompt.detecPrompt := p2^.ReadBool;
    config.fcDetPrompt.ConfigCambios;  //actualiza
  end;
end;

//funciones básicas
procedure TGenCod.fun_puts(fun :TxpEleFun);
//envia un texto a consola
begin
  PopResult;  //saca parámetro 1
  if HayError then exit;
  if not ejec then exit;
  msgbox(stack[sp].valStr);  //sabemos que debe ser String
  //el tipo devuelto lo fijará el framework, al tipo definido
end;
procedure TGenCod.fun_putsI(fun :TxpEleFun);
//envia un texto a consola
begin
  PopResult;  //saca parámetro 1
  if HayError then exit;
  if not ejec then exit;
  msgbox(IntToStr(stack[sp].valInt));  //sabemos que debe ser Entero
  //el tipo devuelto lo fijará el framework, al tipo definido
end;
procedure TGenCod.fun_disconnect(fun :TxpEleFun);
//desconecta la conexión actual
begin
//  msgbox('desconectado');  //sabemos que debe ser String
  if not ejec then exit;
  frmPrincipal.AcTerDesconExecute(nil);
end;
procedure TGenCod.fun_connectTelnet(fun :TxpEleFun);
//conecta con telnet
begin
  PopResult;  //saca parámetro 1
  if not ejec then exit;
  frmPrincipal.InicConectTelnet(stack[sp].valStr);   //inicia conexión
end;
procedure TGenCod.fun_connect(fun :TxpEleFun);
//Inicia la conexión actual
begin
  if not ejec then exit;
  frmPrincipal.InicConect;   //inicia conexión
end;
procedure TGenCod.fun_connectSSH(fun :TxpEleFun);
//conecta con SSH
begin
  PopResult;  //saca parámetro 1
  if not ejec then exit;
  frmPrincipal.InicConectSSH(stack[sp].valStr);   //inicia conexión
end;
procedure TGenCod.fun_sendln(fun :TxpEleFun);
//desconecta la conexión actual
var
  lin: String;
begin
  PopResult;  //saca parámetro 1
  if not ejec then exit;
  if frmPrincipal.proc = nil then exit;
  lin := stack[sp].valStr;
  frmPrincipal.proc.SendLn(lin);
end;
procedure TGenCod.fun_wait(fun :TxpEleFun);
//espera por una cadena
var
  lin: String;
  tic: Integer;
begin
  PopResult;  //saca parámetro 1
  if frmPrincipal.proc = nil then exit;
  //lazo de espera
  if not ejec then exit;
  lin := stack[sp].valStr;
  tic := 0;
  while (tic<Timeout*10) and Not stop do begin
    Application.ProcessMessages;
    sleep(100);
    if AnsiEndsStr(lin, frmPrincipal.proc.LastLine) then break;
    Inc(tic);
  end;
  if tic>=Timeout*10 then begin
    GenError('Tiempo de espera excedido, para cadena: "'+lin+'"');
    exit;
//  end else begin
//    msgbox('eureka');
  end;
end;
procedure TGenCod.fun_pause(fun :TxpEleFun);
//espera un momento
var
  tic: Integer;
  n10mil: Integer;
begin
  PopResult;  //saca parámetro 1
  if frmPrincipal.proc = nil then exit;
  n10mil := stack[sp].valInt * 100;
  //lazo de espera
  if not ejec then exit;
  tic := 0;
  while (tic<n10mil) and Not stop do begin
    Application.ProcessMessages;
    sleep(10);
    Inc(tic);
  end;
end;

procedure TGenCod.fun_messagebox(fun :TxpEleFun);
begin
  PopResult;  //saca parámetro 1
  if HayError then exit;
  if not ejec then exit;
  msgbox(stack[sp].valStr);  //sabemos que debe ser String
  //el tipo devuelto lo fijará el framework, al tipo definido
end;
procedure TGenCod.fun_messageboxI(fun :TxpEleFun);
begin
  PopResult;  //saca parámetro 1
  if HayError then exit;
  if not ejec then exit;
  msgbox(IntToStr(stack[sp].valInt));  //sabemos que debe ser String
  //el tipo devuelto lo fijará el framework, al tipo definido
end;
procedure TGenCod.fun_detect_prompt(fun :TxpEleFun);
begin
  if not ejec then exit;
  frmPrincipal.AcTerDetPrmExecute(nil);
  //el tipo devuelto lo fijará el framework, al tipo definido
end;
procedure TGenCod.fun_clear(fun :TxpEleFun);
begin
  if not ejec then exit;
  frmPrincipal.AcTerLimBufExecute(nil);
  //el tipo devuelto lo fijará el framework, al tipo definido
end;
procedure TGenCod.fun_stop(fun: TxpEleFun);
begin
  if not ejec then exit;
  stop := true;  //manda mensaje para detener la macro
  //el tipo devuelto lo fijará el framework, al tipo definido
end;
procedure TGenCod.fun_logopen(fun: TxpEleFun);
begin
  PopResult;  //saca parámetro 1
  if not ejec then exit;
  if not frmPrincipal.StartLog(stack[sp].valStr) then begin
    GenError('Error abriendo registro: ' + stack[sp].valStr);
  end;
end;
procedure TGenCod.fun_logwrite(fun: TxpEleFun);
begin
  PopResult;  //saca parámetro 1
  if not ejec then exit;
  if not frmPrincipal.WriteLog(stack[sp].valStr) then begin
    GenError('Error escribiendo en registro: ' + frmPrincipal.logName);
  end;
end;
procedure TGenCod.fun_logclose(fun: TxpEleFun);
begin
  if not ejec then exit;
  frmPrincipal.EndLog;
end;
procedure TGenCod.fun_logpause(fun: TxpEleFun);
begin
  if not ejec then exit;
  frmPrincipal.PauseLog;
end;
procedure TGenCod.fun_logstart(fun: TxpEleFun);
begin
  if not ejec then exit;
  frmPrincipal.StartLog;
end;
procedure TGenCod.fun_fileopen(fun: TxpEleFun);
var
  nom: String;
  modo: Int64;
  n: THandle;
begin
  PopResult;
  PopResult;
  PopResult;
  if not ejec then exit;
//  AssignFile(filHand, stack[sp].valStr);
//  Rewrite(filHand);
  nom := stack[sp+1].valStr;
  modo := stack[sp+2].valInt;
  if modo = 0 then begin
    if not FileExists(nom) then begin
      //Si no existe. lo crea
      n := FileCreate(nom);
      FileClose(n);
    end;
    n := FileOpen(nom, fmOpenReadWrite);
    stack[sp].valInt:= Int64(n);
  end else begin
    n := FileOpen(nom, fmOpenRead);
    stack[sp].valInt:=Int64(n);
  end;
end;
procedure TGenCod.fun_close(fun: TxpEleFun);
begin
  PopResult;  //manejador de archivo
  if not ejec then exit;
  fileclose(stack[sp].valInt);
end;
procedure TGenCod.fun_write(fun: TxpEleFun);
var
  cad: String;
begin
  PopResult;  //manejador de archivo
  PopResult;  //cadena
  if not ejec then exit;
  cad := stack[sp+1].valStr;
  filewrite(stack[sp].valInt, cad , length(cad));
end;
procedure TGenCod.StartSyntax;
//Se ejecuta solo una vez al inicio
var
  opr: TxpOperator;
  f: TxpEleFun;
begin
  OnExprStart := @expr_start;
  OnExprEnd := @expr_End;
  ///////////define la sintaxis del compilador
  //Crea tipos de tokens personalizados
  tnExpDelim := xLex.NewTokType('ExpDelim', tkExpDelim);//delimitador de expresión ";"
  tnBlkDelim := xLex.NewTokType('BlkDelim', tkBlkDelim); //delimitador de bloque
  tnStruct   := xLex.NewTokType('Struct', tkStruct);   //personalizado
  tnOthers   := xLex.NewTokType('Others');   //personalizado
  //Configura apariencia
  tkKeyword.Style := [fsBold];     //en negrita
  tkBlkDelim.Foreground:=clGreen;
  tkBlkDelim.Style := [fsBold];     //en negrita
  tkStruct.Foreground:=clGreen;
  tkStruct.Style := [fsBold];     //en negrita
  //inicia la configuración
  xLex.ClearMethodTables;           //limpìa tabla de métodos
  xLex.ClearSpecials;               //para empezar a definir tokens
  //crea tokens por contenido
  xLex.DefTokIdentif('[$A-Za-z_]', '[A-Za-z0-9_]*');
  xLex.DefTokContent('[0-9]', '[0-9.]*', tnNumber);
  //Define palabras claves.
  {Notar que si se modifica aquí, se debería también, actualizar el archivo XML de
  sintaxis, para que el resaltado y completado sea consistente.}
  xLex.AddIdentSpecList('ENDIF ELSE ELSEIF', tnBlkDelim);
  xLex.AddIdentSpecList('true false', tnBoolean);
  xLex.AddIdentSpecList('CLEAR CONNECT CONNECTSSH DISCONNECT SENDLN WAIT PAUSE STOP', tnSysFunct);
  xLex.AddIdentSpecList('LOGOPEN LOGWRITE LOGCLOSE LOGPAUSE LOGSTART', tnSysFunct);
  xLex.AddIdentSpecList('FILEOPEN FILECLOSE FILEWRITE', tnSysFunct);
  xLex.AddIdentSpecList('MESSAGEBOX CAPTURE ENDCAPTURE EDIT DETECT_PROMPT', tnSysFunct);
  xLex.AddIdentSpecList('IF', tnStruct);
  xLex.AddIdentSpecList('THEN', tnKeyword);
  //símbolos especiales
  xLex.AddSymbSpec(';',  tnExpDelim);
  xLex.AddSymbSpec(',',  tnExpDelim);
  xLex.AddSymbSpec('+',  tnOperator);
  xLex.AddSymbSpec('-',  tnOperator);
  xLex.AddSymbSpec('*',  tnOperator);
  xLex.AddSymbSpec('/',  tnOperator);
  xLex.AddSymbSpec(':=', tnOperator);
  xLex.AddSymbSpec('=', tnOperator);
  xLex.AddSymbSpec('>', tnOperator);
  xLex.AddSymbSpec('>=', tnOperator);
  xLex.AddSymbSpec('<', tnOperator);
  xLex.AddSymbSpec('<=', tnOperator);
  xLex.AddSymbSpec('(',  tnOthers);
  xLex.AddSymbSpec(')',  tnOthers);
  xLex.AddSymbSpec(':',  tnOthers);
  //crea tokens delimitados
  xLex.DefTokDelim('''','''', tnString);
  xLex.DefTokDelim('"','"', tnString);
  xLex.DefTokDelim('//','', xLex.tnComment);
  xLex.DefTokDelim('/\*','\*/', xLex.tnComment, tdMulLin);
  //define bloques de sintaxis
  xLex.AddBlock('{','}');
  xLex.Rebuild;   //es necesario para terminar la definición

  ///////////Crea tipos y operaciones
  ClearTypes;
  tipInt  :=CreateType('int',t_integer,4);   //de 4 bytes
  //debe crearse siempre el tipo char o string para manejar cadenas
//  tipStr:=CreateType('char',t_string,1);   //de 1 byte
  tipStr:=CreateType('string',t_string,-1);   //de longitud variable
  tipBol:=CreateType('boolean',t_boolean,1);

  //////// Operaciones con Int ////////////
  {Los operadores deben crearse con su precedencia correcta}
  tipInt.OperationLoad:=@int_procLoad;
  opr:=tipInt.CreateBinaryOperator(':=',2,'asig');  //asignación
  opr.CreateOperation(tipInt,@int_asig_int);

  opr:=tipInt.CreateBinaryOperator('+',5,'suma');
  opr.CreateOperation(tipInt,@int_suma_int);

  opr:=tipInt.CreateBinaryOperator('-',5,'resta');
  opr.CreateOperation(tipInt,@int_resta_int);

  opr:=tipInt.CreateBinaryOperator('*',6,'mult');
  opr.CreateOperation(tipInt,@int_mult_int);

  opr:=tipInt.CreateBinaryOperator('/',6,'mult');
  opr.CreateOperation(tipInt,@int_idiv_int);

  opr:=tipInt.CreateBinaryOperator('=',6,'mult');
  opr.CreateOperation(tipInt,@int_igual_int);
  opr:=tipInt.CreateBinaryOperator('>',6,'may');
  opr.CreateOperation(tipInt,@int_mayor_int);
  opr:=tipInt.CreateBinaryOperator('>=',6,'may');
  opr.CreateOperation(tipInt,@int_mayori_int);
  opr:=tipInt.CreateBinaryOperator('<',6,'men');
  opr.CreateOperation(tipInt,@int_menor_int);
  opr:=tipInt.CreateBinaryOperator('<=',6,'men');
  opr.CreateOperation(tipInt,@int_menori_int);

  //////// Operaciones con String ////////////
  tipStr.OperationLoad:=@str_procLoad;
  opr:=tipStr.CreateBinaryOperator(':=',2,'asig');  //asignación
  opr.CreateOperation(tipStr,@str_asig_str);
  opr:=tipStr.CreateBinaryOperator('+',7,'concat');
  opr.CreateOperation(tipStr,@str_concat_str);
  opr:=tipStr.CreateBinaryOperator('=',7,'igual');
  opr.CreateOperation(tipStr,@str_igual_str);

  //////// Operaciones con Boolean ////////////
  tipBol.OperationLoad:=@bol_procLoad;
  opr:=tipBol.CreateBinaryOperator(':=',2,'asig');  //asignación
  opr.CreateOperation(tipBol,@bol_asig_bol);

  //////// Funciones básicas ////////////
  f := CreateSysFunction('puts', tipInt, @fun_puts);
  f.CreateParam('',tipStr);
  f := CreateSysFunction('puts', tipInt, @fun_putsI);  //sobrecargada
  f.CreateParam('',tipInt);
  f := CreateSysFunction('disconnect', tipInt, @fun_disconnect);
  f := CreateSysFunction('connect', tipInt, @fun_connectTelnet);
  f.CreateParam('',tipStr);
  f := CreateSysFunction('connect', tipInt, @fun_connect);  //sobrecargada

  f := CreateSysFunction('connectSSH', tipInt, @fun_connectSSH);
  f.CreateParam('',tipStr);
  f := CreateSysFunction('sendln', tipInt, @fun_sendln);
  f.CreateParam('',tipStr);
  f := CreateSysFunction('wait', tipInt, @fun_wait);
  f.CreateParam('',tipStr);
  f := CreateSysFunction('pause', tipInt, @fun_pause);
  f.CreateParam('',tipInt);
  f := CreateSysFunction('messagebox', tipInt, @fun_messagebox);
  f.CreateParam('',tipStr);
  f := CreateSysFunction('messagebox', tipInt, @fun_messageboxI);
  f.CreateParam('',tipInt);
  if FindDuplicFunction then exit;
  f := CreateSysFunction('detect_prompt', tipInt, @fun_detect_prompt);
  f := CreateSysFunction('clear', tipInt, @fun_clear);
  f := CreateSysFunction('stop', tipInt, @fun_stop);
  f := CreateSysFunction('logopen', tipInt, @fun_logopen);
  f.CreateParam('',tipStr);
  f := CreateSysFunction('logwrite', tipInt, @fun_logwrite);
  f.CreateParam('',tipStr);
  f := CreateSysFunction('logclose', tipInt, @fun_logclose);
  f := CreateSysFunction('logpause', tipInt, @fun_logpause);
  f := CreateSysFunction('logstart', tipInt, @fun_logstart);
  f := CreateSysFunction('fileopen', tipInt, @fun_fileopen);
  f.CreateParam('',tipInt);
  f.CreateParam('',tipStr);
  f.CreateParam('',tipInt);
  f := CreateSysFunction('fileclose', tipInt, @fun_close);
  f.CreateParam('',tipInt);
  f := CreateSysFunction('filewrite', tipInt, @fun_write);
  f.CreateParam('',tipInt);
  f.CreateParam('',tipStr);
//  f := CreateSysFunction('capture', tipInt, @fun_connectTelnet);
//  f := CreateSysFunction('endcapture', tipInt, @fun_connectTelnet);
//  f := CreateSysFunction('edit', tipInt, @fun_connectTelnet);}
end;


end.

