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
}

const STACK_SIZE = 32;
var
  /////// Tipos de datos del lenguaje ////////////
  tipInt : TType;   //entero flotante
  tipStr : Ttype;
  //pila virtual
  sp: integer;  //puntero de pila
  stack: array[0..STACK_SIZE-1] of TOperand;
  Timeout: integer; //variable de límite de cuenta de tiempo

procedure LoadResInt(val: int64; catOp: TCatOperan);
//Carga en el resultado un valor entero
begin
    res.typ := tipInt;
    res.valInt:=val;
    res.catOp:=catOp;
end;
procedure LoadResStr(val: string; catOp: TCatOperan);
//Carga en el resultado un valor string
begin
    res.typ := tipStr;
    res.valStr:=val;
    res.catOp:=catOp;
end;
procedure PushResult;
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
procedure PopResult;
//Reduce el puntero de pila, de modo que queda apuntando al último dato agregado
begin
  if sp<=0 then begin
    GenError('Desborde de pila.');
    exit;
  end;
  Dec(sp);
end;
////////////rutinas obligatorias
procedure Cod_StartData;
//Codifica la parte inicial de declaración de variables estáticas
begin
end;
procedure Cod_StartProgram;
//Codifica la parte inicial del programa
begin
  sp := 0;  //inicia pila
  Timeout := config.fcMacros.tpoMax;   //inicia variable
  DetEjec := false;
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
procedure Cod_EndProgram;
//Codifica la parte inicial del programa
begin
end;
procedure expr_start(const exprLevel: integer);
//Se ejecuta siempre al StartSyntax el procesamiento de una expresión
begin
  if exprLevel=1 then begin //es el primer nivel
    res.typ := tipInt;   //le pone un tipo por defecto
  end;
end;
procedure expr_end(const exprLevel: integer; isParam: boolean);
//Se ejecuta al final de una expresión, si es que no ha habido error.
begin
  if isParam then begin
    //Se terminó de evaluar un parámetro
    PushResult;   //pone parámetro en pila
    if HayError then exit;
  end;
end;
////////////operaciones con Enteros
procedure int_procLoad(const OpPtr: pointer);
var
  Op: ^TOperand;
begin
  Op := OpPtr;
  //carga el operando en res
  res.typ := tipInt;
  res.valInt := Op^.ReadInt;
end;
procedure int_asig_int;
begin
  if p1.catOp <> coVariab then begin  //validación
    GenError('Solo se puede asignar a variable.'); exit;
  end;
  //en la VM se puede mover directamente res memoria sin usar el registro res
  p1.rVar.valInt := p2.ReadInt;
//  res.used:=false;  //No hay obligación de que la asignación devuelva un valor.
  if Upcase(p1.rVar.nom) = 'TIMEOUT' then begin
    //variable interna
    config.fcMacros.TpoMax := p2.ReadInt;
    config.fcConex.UpdateChanges;  //actualiza
  end else if Upcase(p1.rVar.nom) = 'curPORT' then begin
    //variable interna
    config.fcConex.Port := IntToStr(p2.ReadInt);
    config.fcConex.UpdateChanges;  //actualiza
  end;
end;

procedure int_suma_int;
begin
  LoadResInt(p1.ReadInt+p2.ReadInt, coExpres);
end;
procedure int_resta_int;
begin
  LoadResInt(p1.ReadInt-p2.ReadInt, coExpres);
end;
procedure int_mult_int;
begin
  LoadResInt(p1.ReadInt*p2.ReadInt, coExpres);
end;
procedure int_idiv_int;
begin
  LoadResInt(p1.ReadInt div p2.ReadInt, coExpres);
end;


////////////operaciones con string
procedure str_procLoad(const OpPtr: pointer);
var
  Op: ^TOperand;
begin
  Op := OpPtr;
  //carga el operando en res
  res.typ := tipStr;
  res.valStr := Op^.ReadStr;
end;
procedure str_asig_str;
begin
  if p1.catOp <> coVariab then begin  //validación
    GenError('Solo se puede asignar a variable.'); exit;
  end;
  //aquí se puede mover directamente res memoria sin usar el registro res
  p1.rVar.valStr := p2.ReadStr;
  //  res.used:=false;  //No hay obligación de que la asignación devuelva un valor.
  if Upcase(p1.rVar.nom) = 'CURIP' then begin
    //variable interna
    config.fcConex.IP := p2.ReadStr;
    config.fcConex.UpdateChanges;  //actualiza
  end else if Upcase(p1.rVar.nom) = 'CURTYPE' then begin
    //variable interna
    case UpCase(p2.ReadStr) of
    'TELNET': config.fcConex.tipo := TCON_TELNET;  //Conexión telnet común
    'SSH'   : config.fcConex.tipo := TCON_SSH;     //Conexión ssh
    'SERIAL': config.fcConex.tipo := TCON_SERIAL;  //Serial
    'OTHER' : config.fcConex.tipo := TCON_OTHER;   //Otro proceso
    end;
    config.fcConex.UpdateChanges;  //actualiza
  end else if Upcase(p1.rVar.nom) = 'CURENDLINE' then begin
    //variable interna
    if UpCase(p2.ReadStr) = 'CRLF' then
      config.fcConex.SendCRLF := true
    else
      config.fcConex.SendCRLF := false;
    config.fcConex.UpdateChanges;  //actualiza
  end else if Upcase(p1.rVar.nom) = 'CURAPP' then begin
    //indica aplicativo actual
    config.fcConex.Other := p2.ReadStr;
    config.fcConex.UpdateChanges;  //actualiza
  end else if Upcase(p1.rVar.nom) = 'PROMPTSTART' then begin
    //indica aplicativo actual
    config.fcDetPrompt.prIni:= p2.ReadStr;
    config.fcDetPrompt.detecPrompt := true;  //por defecto
    config.fcDetPrompt.ConfigCambios;  //actualiza
  end else if Upcase(p1.rVar.nom) = 'PROMPTEND' then begin
    //indica aplicativo actual
    config.fcDetPrompt.prFin:= p2.ReadStr;
    config.fcDetPrompt.detecPrompt := true;  //por defecto
    config.fcDetPrompt.ConfigCambios;  //actualiza
  end;
end;

procedure str_concat_str;
begin
  LoadResStr(p1.ReadStr+p2.ReadStr, coExpres);
end;
////////////operaciones con boolean
procedure bol_procLoad(const OpPtr: pointer);
var
  Op: ^TOperand;
begin
  Op := OpPtr;
  //carga el operando en res
  res.typ := tipStr;
  res.valBool := Op^.ReadBool;
end;
procedure bol_asig_bol;
begin
  if p1.catOp <> coVariab then begin  //validación
    GenError('Solo se puede asignar a variable.'); exit;
  end;
  //en la VM se puede mover directamente res memoria sin usar el registro res
  p1.rVar.valBool := p2.ReadBool;
//  res.used:=false;  //No hay obligación de que la asignación devuelva un valor.
  if Upcase(p1.rVar.nom) = 'PROMPTDETECT' then begin
    //variable interna
    config.fcDetPrompt.detecPrompt := p2.ReadBool;
    config.fcDetPrompt.ConfigCambios;  //actualiza
  end;
end;


//funciones básicas
procedure fun_puts(fun :TxpFun);
//envia un texto a consola
begin
  PopResult;  //saca parámetro 1
  if HayError then exit;
  msgbox(stack[sp].valStr);  //sabemos que debe ser String
  //el tipo devuelto lo fijará el framework, al tipo definido
end;
procedure fun_putsI(fun :TxpFun);
//envia un texto a consola
begin
  PopResult;  //saca parámetro 1
  if HayError then exit;
  msgbox(IntToStr(stack[sp].valInt));  //sabemos que debe ser Entero
  //el tipo devuelto lo fijará el framework, al tipo definido
end;
procedure fun_disconnect(fun :TxpFun);
//desconecta la conexión actual
begin
//  msgbox('desconectado');  //sabemos que debe ser String
  frmPrincipal.AcTerDesconExecute(nil);
end;
procedure fun_connectTelnet(fun :TxpFun);
//conecta con telnet
begin
  PopResult;  //saca parámetro 1
  frmPrincipal.InicConectTelnet(stack[sp].valStr);   //inicia conexión
end;
procedure fun_connect(fun :TxpFun);
//Inicia la conexión actual
begin
  frmPrincipal.InicConect;   //inicia conexión
end;
procedure fun_connectSSH(fun :TxpFun);
//conecta con SSH
begin
  PopResult;  //saca parámetro 1
  frmPrincipal.InicConectSSH(stack[sp].valStr);   //inicia conexión
end;
procedure fun_sendln(fun :TxpFun);
//desconecta la conexión actual
var
  lin: String;
begin
  PopResult;  //saca parámetro 1
  if frmPrincipal.proc = nil then exit;
  lin := stack[sp].valStr;
  frmPrincipal.proc.SendLn(lin);
end;
procedure fun_wait(fun :TxpFun);
//espera por una cadena
var
  lin: String;
  tic: Integer;
begin
  PopResult;  //saca parámetro 1
  if frmPrincipal.proc = nil then exit;
  //lazo de espera
  lin := stack[sp].valStr;
  tic := 0;
  while (tic<Timeout*10) and Not DetEjec do begin
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
procedure fun_pause(fun :TxpFun);
//espera un momento
var
  tic: Integer;
  n10mil: Integer;
begin
  PopResult;  //saca parámetro 1
  if frmPrincipal.proc = nil then exit;
  n10mil := stack[sp].valInt * 100;
  //lazo de espera
  tic := 0;
  while (tic<n10mil) and Not DetEjec do begin
    Application.ProcessMessages;
    sleep(10);
    Inc(tic);
  end;
end;

procedure fun_messagebox(fun :TxpFun);
begin
  PopResult;  //saca parámetro 1
  if HayError then exit;
  msgbox(stack[sp].valStr);  //sabemos que debe ser String
  //el tipo devuelto lo fijará el framework, al tipo definido
end;

procedure fun_messageboxI(fun :TxpFun);
begin
  PopResult;  //saca parámetro 1
  if HayError then exit;
  msgbox(IntToStr(stack[sp].valInt));  //sabemos que debe ser String
  //el tipo devuelto lo fijará el framework, al tipo definido
end;
procedure fun_detect_prompt(fun :TxpFun);
begin
  frmPrincipal.AcTerDetPrmExecute(nil);
  //el tipo devuelto lo fijará el framework, al tipo definido
end;
procedure fun_clear(fun :TxpFun);
begin
  frmPrincipal.AcTerLimBufExecute(nil);
  //el tipo devuelto lo fijará el framework, al tipo definido
end;

procedure TCompiler.StartSyntax;
//Se ejecuta solo una vez al inicio
var
  opr: TOperator;
  f: TxpFun;
  tipBol: TType;
begin
  OnExprStart := @expr_start;
  OnExprEnd := @expr_End;
  ///////////define la sintaxis del compilador
  //crea y guarda referencia a los atributos
  tkEol      := xLex.tkEol;
  tkIdentif  := xLex.tkIdentif;
  tkKeyword  := xLex.tkKeyword;
  tkKeyword.Style := [fsBold];     //en negrita
  tkNumber   := xLex.tkNumber;
  tkString   := xLex.tkString;
  //personalizados
  tkOperator := xLex.NewTokType('Operador'); //personalizado
  tkBoolean  := xLex.NewTokType('Boolean');  //personalizado
  tkSysFunct := xLex.NewTokType('SysFunct'); //funciones del sistema
  tkExpDelim := xLex.NewTokType('ExpDelim');//delimitador de expresión ";"
  tkBlkDelim := xLex.NewTokType('BlkDelim'); //delimitador de bloque
  tkBlkDelim.Foreground:=clGreen;
  tkBlkDelim.Style := [fsBold];     //en negrita
  tkType     := xLex.NewTokType('Types');    //personalizado
  tkStruct   := xLex.NewTokType('Struct');   //personalizado
  tkStruct.Foreground:=clGreen;
  tkStruct.Style := [fsBold];     //en negrita
  tkOthers   := xLex.NewTokType('Others');   //personalizado
  //inicia la configuración
  xLex.ClearMethodTables;           //limpìa tabla de métodos
  xLex.ClearSpecials;               //para empezar a definir tokens
  //crea tokens por contenido
  xLex.DefTokIdentif('[$A-Za-z_]', '[A-Za-z0-9_]*');
  xLex.DefTokContent('[0-9]', '[0-9.]*', tkNumber);
  //define palabras claves
  xLex.AddIdentSpecList('var type program begin', tkKeyword);
  xLex.AddIdentSpecList('end else elsif', tkBlkDelim);
  xLex.AddIdentSpecList('true false', tkBoolean);
  xLex.AddIdentSpecList('int string', tkType);
  xLex.AddIdentSpecList('CONNECT CONNECTSSH DISCONNECT SENDLN WAIT PAUSE STOP', tkSysFunct);
//  xLex.AddIdentSpecList('END', tkSysFunct);
  xLex.AddIdentSpecList('LOGOPEN LOGWRITE LOGCLOSE LOGPAUSE LOGSTART', tkSysFunct);
  xLex.AddIdentSpecList('FILEOPEN FILECLOSE FILEWRITE', tkSysFunct);
  xLex.AddIdentSpecList('MESSAGEBOX CAPTURE ENDCAPTURE EDIT DETECT_PROMPT', tkSysFunct);
  //símbolos especiales
  xLex.AddSymbSpec(';',  tkExpDelim);
  xLex.AddSymbSpec(',',  tkExpDelim);
  xLex.AddSymbSpec('+',  tkOperator);
  xLex.AddSymbSpec('-',  tkOperator);
  xLex.AddSymbSpec('*',  tkOperator);
  xLex.AddSymbSpec('/',  tkOperator);
  xLex.AddSymbSpec(':=', tkOperator);
  xLex.AddSymbSpec('(',  tkOthers);
  xLex.AddSymbSpec(')',  tkOthers);
  xLex.AddSymbSpec(':',  tkOthers);
  //crea tokens delimitados
  xLex.DefTokDelim('''','''', tkString);
  xLex.DefTokDelim('"','"', tkString);
  xLex.DefTokDelim('//','', xLex.tkComment);
  xLex.DefTokDelim('/\*','\*/', xLex.tkComment, tdMulLin);
  //define bloques de sintaxis
  xLex.AddBlock('{','}');
  xLex.Rebuild;   //es necesario para terminar la definición

  ///////////Crea tipos y operaciones
  ClearTypes;
  tipInt  :=CreateType('int',t_integer,4);   //de 4 bytes
  tipInt.OnLoad:=@int_procLoad;
  //debe crearse siempre el tipo char o string para manejar cadenas
//  tipStr:=CreateType('char',t_string,1);   //de 1 byte
  tipStr:=CreateType('string',t_string,-1);   //de longitud variable
  tipStr.OnLoad:=@str_procLoad;
  tipBol:=CreateType('boolean',t_boolean,1);
  tipBol.OnLoad:=@bol_procLoad;

  //////// Operaciones con String ////////////
  opr:=tipStr.CreateOperator(':=',2,'asig');  //asignación
  opr.CreateOperation(tipStr,@str_asig_str);
  opr:=tipStr.CreateOperator('+',7,'concat');
  opr.CreateOperation(tipStr,@str_concat_str);

  //////// Operaciones con Int ////////////
  {Los operadores deben crearse con su precedencia correcta}
  opr:=tipInt.CreateOperator(':=',2,'asig');  //asignación
  opr.CreateOperation(tipInt,@int_asig_int);

  opr:=tipInt.CreateOperator('+',5,'suma');
  opr.CreateOperation(tipInt,@int_suma_int);

  opr:=tipInt.CreateOperator('-',5,'resta');
  opr.CreateOperation(tipInt,@int_resta_int);

  opr:=tipInt.CreateOperator('*',6,'mult');
  opr.CreateOperation(tipInt,@int_mult_int);

  opr:=tipInt.CreateOperator('/',6,'mult');
  opr.CreateOperation(tipInt,@int_idiv_int);

  //////// Operaciones con Boolean ////////////
  opr:=tipBol.CreateOperator(':=',2,'asig');  //asignación
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
{  f := CreateSysFunction('stop', tipInt, @fun_connectTelnet);
  f := CreateSysFunction('logopen', tipInt, @fun_connectTelnet);
  f := CreateSysFunction('logwrite', tipInt, @fun_connectTelnet);
  f := CreateSysFunction('logclose', tipInt, @fun_connectTelnet);
  f := CreateSysFunction('logpause', tipInt, @fun_connectTelnet);
  f := CreateSysFunction('logstart', tipInt, @fun_connectTelnet);
  f := CreateSysFunction('fileopen', tipInt, @fun_connectTelnet);
  f := CreateSysFunction('fileclose', tipInt, @fun_connectTelnet);
  f := CreateSysFunction('filewrite', tipInt, @fun_connectTelnet);
  f := CreateSysFunction('capture', tipInt, @fun_connectTelnet);
  f := CreateSysFunction('endcapture', tipInt, @fun_connectTelnet);
  f := CreateSysFunction('edit', tipInt, @fun_connectTelnet);}
end;

