{Rutinas principales del framework.
 Aquí se define el analizador de expresiones aritméticas, el lazo principal del
 parser y las rutinas del analizador sintáctico, que reconocen a las estructuras
 del lenguaje.
 Aquí también se incluye el archivo en donde se implementará un intérprete/compilador.
 Las variables importantes de este módulo son:

 xLex -> es el analizador léxico y resaltador de sintaxis.
 PErr -> es el objeto que administra lso errores.
 vars[]  -> almacena a las variables declaradas
 types[] -> almacena a los tipos declarados
 funcs[] -> almacena a las funciones declaradas
 cons[]  -> almacena a las constantes declaradas

}
{$DEFINE mode_inter}  //mode_inter->Modo intérprete  mode_comp->Modo compilador
unit XpresParser;
{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, fgl, Forms, LCLType, Dialogs, lclProc,
  SynEditHighlighter, SynFacilHighlighter, SynFacilBasic,
  XpresBas, Strutils, MisUtils, FormConfig, FrameCfgConex;

type
  //categorías básicas de tipo de datos
  TtipDato=(
    t_integer,  //números enteros
    t_uinteger, //enteros sin signo
    t_float,    //es de coma flotante
    t_string,   //cadena de caracteres
    t_boolean,  //booleano
    t_enum      //enumerado
  );

  //Categoría de Operando
  CatOperan = (
    coConst,     //mono-operando constante
//    coConstExp,  //expresión constante
    coVariable,  //variable
    coExpres     //expresión
  );

  //tipo de identificador
  TIdentifType = (idtNone, idtVar, idtFunc, idtCons);

  TType = class;
  TOperator = class;

  //registro para almacenar información de las variables
  Tvar = record
    nom : string;   //nombre de la variable
    typ : Ttype;    //tipo de la variable
    amb : string;   //ámbito o alcance de la variable
    //direción física. Usado para implementar un compilador
    adrr: integer;
    //Campos usados para implementar el intérprete sin máquina virtual
    //valores de la variable.
    valFloat: extended; //Valor en caso de que sea un flotante
    valInt  : Int64;    //valor en caso de que sea un entero
    valUInt : Int64;    //valor en caso de que sea un entero sin signo
    valBool  : Boolean;  //valor  en caso de que sea un booleano
    valStr  : string;     //valor  en caso de que sea una cadena
  end;

  { TOperand }
  //Operando
  TOperand = object
  private
    cons: Tvar;        //valor en caso de que sea una constante
  public
//    name : string;
    typ  : TType;     //referencia al tipo de dato
  	catTyp: tTipDato; //Categoría de Tipo de dato
    size : integer;   //tamaño del operando en bytes
    catOp: CatOperan; //Categoría de operando
    estOp: integer;   //Estado del operando (Usado para la generec. de código)
//used:   boolean;
    txt  : string;    //Texto del operando o expresión
    ivar : integer;   //índice a variables, en caso de que sea variable
    ifun : integer;   //índice a funciones, en caso de que sea función
    procedure Load;   //carga el operador en registro o pila
    function FindOperator(const oper: string): TOperator; //devuelve el objeto operador
    function GetOperator: Toperator;

    //Métodos para facilitar la implementación del intérprete
    function expres: string;  //devuelve una cadena que expresa al operando
    //permite para obtener valores del operando
    function GetValBool: boolean;
    function GetValInt: int64;
    function GetValFloat: extended;
    function GetValStr: string;
  end;

  TProcDefineVar = procedure(const varName, varInitVal: string);
  TProcLoadOperand = procedure(var Op: TOperand);
  TProcExecOperat = procedure;

  //registro para almacenar información de las funciones
  Tfunc = record
    name: string;   //nombre de la función
    typ : Ttype;    //tipo que devuelve
    pars: array of Ttype;  //parámetros de entrada
    amb : string;   //ámbito o alcance de la función
    //direción física. Usado para implementar un compilador
    adrr: integer;  //dirección física
    //Campos usados para implementar el intérprete sin máquina virtual
    proc: TProcExecOperat;  //referencia a la función que implementa
    posF: TPoint;    //posición donde empieza la función en el código
  end;

  //Tipo operación
  TxOperation = class
    OperatType : TType;   //tipo de Operando sobre el cual se aplica la operación.
    proc       : TProcExecOperat;  //Procesamiento de la operación
  end;

  TOperations = specialize TFPGObjectList<TxOperation>; //lista de bloques

  //Operador
  { TOperator }

  TOperator = class
    txt: string;    //cadena del operador '+', '-', '++', ...
    jer: byte;      //precedencia
    nom: string;    //nombre de la operación (suma, resta)
    idx: integer;   //ubicación dentro de un arreglo
    Operations: TOperations;  //operaciones soportadas. Debería haber tantos como
                              //Num. Operadores * Num.Tipos compatibles.
    function CreateOperation(OperadType: Ttype; proc: TProcExecOperat): TxOperation;  //Crea operación
    function FindOperation(typ0: Ttype): TxOperation;  //Busca una operación para este operador
    constructor Create;
    destructor Destroy; override;
  end;

  TOperators = specialize TFPGObjectList<TOperator>; //lista de bloques

  //"Tipos de datos"
  { TType }

  TType = class
    name : string;      //nombre del tipo ("int8", "int16", ...)
    cat  : TtipDato;    //categoría del tipo (numérico, cadena, etc)
    size : smallint;    //tamaño en bytes del tipo
    idx  : smallint;    //ubicación dentro de la matriz de tipos
    amb  : TFaSynBlock; //ámbito de validez del tipo
    procDefine: TProcDefineVar;  //Procesamiento de definición de una variable
    procLoad: TProcLoadOperand;  //Procesamiento de carga
    codLoad: string;   //código de carga de operando. Se usa si "procLoad" es NIL.
    Operators: TOperators;      //operadores soportados
    procedure DefineLoadOperand(codLoad0: string);  //Define carga de un operando
    function CreateOperator(txt0: string; jer0: byte; name0: string): TOperator; //Crea operador
    function FindOperator(const Opr: string): TOperator;  //indica si el operador está definido
    constructor Create;
    destructor Destroy; override;
  end;


  //Lista de tipos
  TTypes = specialize TFPGObjectList<TType>; //lista de bloques


var //variables públicas del compilador
  PErr  : TPError;     //Objeto de Error
  mem   : TStringList; //texto de salida del compilador
  p1, p2: TOperand;    //operandos de la operación actual
  res   : TOperand;    //resultado de la evaluación de la última expresión.
  xLex  : TSynFacilSyn; //resaltador - lexer
  ejecProg: boolean;   //Indica que se está ejecutando un programa o compilando
  DetEjec: boolean;   //para detener la ejecución (en intérpretes)

procedure Compilar(NombArc: string; LinArc: Tstrings);

implementation
uses FormPrincipal, Graphics;

var  //variables privadas del compilador
  //referencias obligatorias
  tkEol     : TSynHighlighterAttributes;
  tkIdentif : TSynHighlighterAttributes;
  tkKeyword : TSynHighlighterAttributes;
  tkNumber  : TSynHighlighterAttributes;
  tkString  : TSynHighlighterAttributes;
  tkOperator: TSynHighlighterAttributes;
  tkBoolean : TSynHighlighterAttributes;
  tkSysFunct: TSynHighlighterAttributes;
  //referencias adicionales
  tkExpDelim: TSynHighlighterAttributes;
  tkBlkDelim: TSynHighlighterAttributes;
  tkType    : TSynHighlighterAttributes;
  tkStruct  : TSynHighlighterAttributes;
  tkOthers  : TSynHighlighterAttributes;


  nullOper : TOperator; //Operador nulo. Usado como valor cero.
  ExprLevel: Integer;  //Nivel de anidamiento de la rutina de evaluación de expresiones

{$I XPresParser.inc}
function EOBlock: boolean; inline;
//Indica si se ha llegado el final de un bloque
begin
  Result := cIn.tokType = tkBlkDelim;
end;
function EOExpres: boolean; inline;
//Indica si se ha llegado al final de una expresión
begin
  Result := (cIn.tokType = tkExpDelim) or (cIn.tokType = tkEol);
end;
{ Rutinas del compilador }
procedure Code(cod: string);
begin
  mem.Add(cod);
end;

//Declaraciones adelantadas
function GetExpression(const prec: Integer; isParam: boolean = false): TOperand; forward;
function GetBoolExpression: TOperand; forward;
procedure CompileCurBlock; forward;
procedure CreateVariable(varName, varType: string); forward;

////////////////Rutinas de generación de código para el compilador////////////
{$I interprete_bas.pas}
function CapturaDelim: boolean;
//Verifica si sigue un delimitador de expresión. Si encuentra devuelve false.
begin
  cIn.SkipWhitesNoEOL;
  if cIn.tokType=tkExpDelim then begin //encontró
    cIn.Next;   //pasa al siguiente
    exit(true);
  end else if cIn.tokL = 'end' then begin   //es un error
    //detect apero no lo toma
    exit(true);  //sale con error
  end else begin   //es un error
    GenError('Se esperaba ";"');
    exit(false);  //sale con error
  end;

end;
procedure TipDefecString(var Op: TOperand; tokcad: string);
//Devuelve el tipo de cadena encontrado en un token
var
  i: Integer;
begin
  Op.catTyp := t_string;   //es flotante
  Op.size:=length(tokcad);
  //toma el texto
  Op.cons.valStr := copy(cIn.tok,2, length(cIn.tok)-2);   //quita comillas
  //////////// Verifica si hay tipos string definidos ////////////
  Op.typ:=nil;
  //Busca primero tipo string (longitud variable)
  for i:=0 to types.Count-1 do begin
    { TODO : Se debería tener una lista adicional  TStringTypes, para acelerar la
    búsqueda}
    if (types[i].cat = t_string) and (types[i].size=-1) then begin  //busca un char
      Op.typ:=types[i];  //encontró
      break;
    end;
  end;
  if Op.typ=nil then begin
    //no hubo "string", busca al menos "char", para generar ARRAY OF char
    for i:=0 to types.Count-1 do begin
      { TODO : Se debería tener una lista adicional  TStringTypes, para acelerar la
      búsqueda}
      if (types[i].cat = t_string) and (types[i].size=1) then begin  //busca un char
        Op.typ:=types[i];  //encontró
        break;
      end;
    end;
  end;
end;
procedure TipDefecBoolean(var Op: TOperand; tokcad: string);
//Devuelve el tipo de cadena encontrado en un token
var
  i: Integer;
begin
  Op.catTyp := t_boolean;   //es flotante
  Op.size:=1;   //se usará un byte
  //toma valor constante
  Op.cons.valBool:= (tokcad[1] in ['t','T']);
  //verifica si hay tipo boolean definido
  Op.typ:=nil;
  for i:=0 to types.Count-1 do begin
    { TODO : Se debería tener una lista adicional  TBooleanTypes, para acelerar la
    búsqueda}
    if (types[i].cat = t_boolean) then begin  //basta con que haya uno
      Op.typ:=types[i];  //encontró
      break;
    end;
  end;
end;
procedure CaptureParams;
//Lee los parámetros de una función en la función interna funcs[0]
begin
  cIn.SkipWhitesNoEOL;
  ClearParamsFunc(0);   //inicia parámetros
  if EOBlock or EOExpres then begin
    //no tiene parámetros
  end else begin
    //debe haber parámetros
    repeat
      GetExpression(0, true);  //captura parámetro
      if perr.HayError then exit;   //aborta
      //guarda tipo de parámetro
      CreateParam(0,'', res.typ);
      if cIn.tok = ',' then begin
        cIn.Next;   //toma separador
        cIn.SkipWhitesNoEOL;
      end else begin
        //no sigue separador de parámetros,
        //debe terminar la lista de parámetros
        //¿Verificar EOBlock or EOExpres ?
        break;
      end;
    until false;
  end;
end;
function GetOperand: TOperand;
//Parte de la funcion GAEE que genera codigo para leer un operando.
var
  i: Integer;
  ivar: Integer;
  ifun: Integer;
  tmp: String;
begin
  PErr.Clear;
  cIn.SkipWhitesNoEOL;
  Result.estOp:=0;  //Este estado significa NO CARGADO en registros.
  if cIn.tokType = tkNumber then begin  //constantes numéricas
    Result.estOp:=STORED_LIT;
    Result.catOp:=coConst;       //constante es Mono Operando
    Result.txt:= cIn.tok;     //toma el texto
    TipDefecNumber(Result, cIn.tok); //encuentra tipo de número, tamaño y valor
    if pErr.HayError then exit;  //verifica
    if Result.typ = nil then begin
        GenError('No hay tipo definido para albergar a esta constante numérica');
        exit;
      end;
    cIn.Next;    //Pasa al siguiente
  end else if cIn.tokType = tkIdentif then begin  //puede ser variable, constante, función
    if FindVar(cIn.tok, ivar) then begin
      //es una variable
      Result.ivar:=ivar;   //guarda referencia a la variable
      Result.catOp:=coVariable;    //variable
      Result.catTyp:= vars[ivar].typ.cat;  //categoría
      Result.typ:=vars[ivar].typ;
      Result.estOp:=STORED_VAR;
      Result.txt:= cIn.tok;     //toma el texto
      cIn.Next;    //Pasa al siguiente
    end else if FindFunc(cIn.tok, ifun) then begin  //no es variable, debe ser función
      tmp := cIn.tok;  //guarda nombre de función
      cIn.Next;    //Toma identificador
      CaptureParams;  //primero lee parámetros
      //busca como función
      case FindFuncWithParams0(tmp, i, ifun) of  //busca desde ifun
      //TFF_NONE:      //No debería pasar esto
      TFF_PARTIAL:   //encontró la función, pero no coincidió con los parámetros
         GenError('Error en tipo de parámetros de '+ tmp +'()');
      TFF_FULL:     //encontró completamente
        begin   //encontró
          Result.ifun:=i;      //guarda referencia a la función
          Result.catOp :=coExpres; //expresión
          Result.txt:= cIn.tok;    //toma el texto
    //      Result.catTyp:= funcs[i].typ.cat;  //no debería ser necesario
          Result.typ:=funcs[i].typ;
    //      Result.estOp:=STORED_VAR;  el estado lo decidirá la función
          funcs[i].proc;  //llama al código de la función
          Result.estOp:=res.estOp;
          exit;
        end;
      end;
    end else begin
      GenError('Identificador desconocido: "' + cIn.tok + '"');
      exit;
    end;
  end else if cIn.tokType = tkSysFunct then begin  //es función de sistema
    //Estas funciones debem crearse al iniciar el compilador y están siempre disponibles.
    tmp := cIn.tok;  //guarda nombre de función
    cIn.Next;    //Toma identificador
    CaptureParams;  //primero lee parámetros en func[0]
    //buscamos una declaración que coincida.
    case FindFuncWithParams0(tmp, i) of
    TFF_NONE:      //no encontró ni la función
       GenError('Función no implementada: "' + tmp + '"');
    TFF_PARTIAL:   //encontró la función, pero no coincidió con los parámetros
       GenError('Error en tipo de parámetros de '+ tmp +'()');
    TFF_FULL:     //encontró completamente
      begin   //encontró
        Result.ifun:=i;      //guarda referencia a la función
        Result.catOp :=coExpres; //expresión
        Result.txt:= cIn.tok;    //toma el texto
  //      Result.catTyp:= funcs[i].typ.cat;  //no debería ser necesario
        Result.typ:=funcs[i].typ;
  //      Result.estOp:=STORED_VAR;  el estado lo decidirá la función
        funcs[i].proc;  //llama al código de la función
        Result.estOp:=res.estOp;
        exit;
      end;
    end;
  end else if cIn.tokType = tkBoolean then begin  //true o false
    Result.estOp:=STORED_LIT;
    Result.catOp:=coConst;       //constante es Mono Operando
    Result.txt:= cIn.tok;     //toma el texto
    TipDefecBoolean(Result, cIn.tok); //encuentra tipo de número, tamaño y valor
    if pErr.HayError then exit;  //verifica
    if Result.typ = nil then begin
       GenError('No hay tipo definido para albergar a esta constante booleana');
       exit;
     end;
    cIn.Next;    //Pasa al siguiente
  end else if (cIn.tokType = tkOthers) and (cIn.tok = '(') then begin  //"("
    cIn.Next;
    Result := GetExpression(0);
    if PErr.HayError then exit;
    If cIn.tok = ')' Then begin
       cIn.Next;  //lo toma
    end Else begin
       GenError('Error en expresión. Se esperaba ")"');
       Exit;       //error
    end;
  end else if (cIn.tokType = tkString) then begin  //constante cadena
    Result.estOp:=STORED_LIT;
    Result.catOp:=coConst;     //constante es Mono Operando
//    Result.txt:= cIn.tok;     //toma el texto
    TipDefecString(Result, cIn.tok); //encuentra tipo de número, tamaño y valor
    if pErr.HayError then exit;  //verifica
    if Result.typ = nil then begin
       GenError('No hay tipo definido para albergar a esta constante cadena');
       exit;
     end;
    cIn.Next;    //Pasa al siguiente
{  end else if (cIn.tokType = tkOperator then begin
   //los únicos símbolos válidos son +,-, que son parte de un número
    }
  end else begin
    //No se reconoce el operador
    GenError('Se esperaba operando');
  end;
end;
procedure CreateVariable(varName, varType: string);
//Se debe reservar espacio para las variables indicadas. Los tipos siempre
//aparecen en minúscula.
var t: ttype;
  hay: Boolean;
  n: Integer;
  r : Tvar;
begin
  //Verifica el tipo
  hay := false;
  for t in types do begin
    if t.name=varType then begin
       hay:=true; break;
    end;
  end;
  if not hay then begin
    GenError('Tipo "' + varType + '" no definido.');
    exit;
  end;
  //verifica nombre
  if FindPredefName(varName) <> idtNone then begin
    GenError('Identificador duplicado: "' + varName + '".');
    exit;
  end;
  //registra variable en la tabla
  r.nom:=varName;
  r.typ := t;
  n := high(vars)+1;
  setlength(vars, n+1);
  vars[n] := r;
  //Ya encontró tipo, llama a evento
  if t.procDefine<>nil then t.procDefine(varName, '');
end;
procedure CompileVarDeclar;
//Compila la declaración de variables.
var
  varType: String;
  varName: String;
  varNames: array of string;  //nombre de variables
  n: Integer;
  tmp: String;
begin
  setlength(varNames,0);  //inicia arreglo
  //procesa variables res,b,c : int;
  repeat
    cIn.SkipWhitesNoEOL;
    //ahora debe haber un identificador de variable
    if cIn.tokType <> tkIdentif then begin
      GenError('Se esperaba identificador de variable.');
      exit;
    end;
    //hay un identificador
    varName := cIn.tok;
    cIn.Next;  //lo toma
    cIn.SkipWhitesNoEOL;
    //sgrega nombre de variable
    n := high(varNames)+1;
    setlength(varNames,n+1);  //hace espacio
    varNames[n] := varName;  //agrega nombre
    if cIn.tok <> ',' then break; //sale
    cIn.Next;  //toma la coma
  until false;
  //usualmente debería seguir ":"
  if cIn.tok = ':' then begin
    //debe venir el tipo de la variable
    cIn.Next;  //lo toma
    cIn.SkipWhitesNoEOL;
    if (cIn.tokType <> tkType) then begin
      GenError('Se esperaba identificador de tipo.');
      exit;
    end;
    varType := cIn.tok;   //lee tipo
    cIn.Next;
    //reserva espacio para las variables
    for tmp in varNames do begin
      CreateVariable(tmp, lowerCase(varType));
      if Perr.HayError then exit;
    end;
  end else begin
    GenError('Se esperaba ":" o ",".');
    exit;
  end;
  if not CapturaDelim then exit;
  cIn.SkipWhitesNoEOL;
end;
procedure CompileCurBlock;
//Compila el bloque de código actual hasta encontrar un delimitador de bloque.
begin
  cIn.SkipWhites;  //ignora comentarios inciales
  //if config.fcMacros.marLin then ;
  while not cIn.Eof and not EOBlock do begin
    //se espera una expresión o estructura
    if cIn.tokType = tkStruct then begin  //es una estructura
      if cIn.tokL = 'if' then begin  //condicional
        cIn.Next;  //toma IF
        GetBoolExpression; //evalua expresión
        if PErr.HayError then exit;
        if cIn.tokL<> 'then' then begin
          GenError('Se esperaba "then".');
          exit;
        end;
        cIn.Next;  //toma el THEN
        //cuerpo del if
        CompileCurBlock;  //procesa bloque
//        Result := res;  //toma resultado
        if PErr.HayError then exit;
        while cIn.tokL = 'elsif' do begin
          cIn.Next;  //toma ELSIF
          GetBoolExpression; //evalua expresión
          if PErr.HayError then exit;
          if cIn.tokL<> 'then' then begin
            GenError('Se esperaba "then".');
            exit;
          end;
          cIn.Next;  //toma el THEN
          //cuerpo del if
          CompileCurBlock;  //evalua expresión
//          Result := res;  //toma resultado
          if PErr.HayError then exit;
        end;
        if cIn.tokL = 'else' then begin
          cIn.Next;  //toma ELSE
          CompileCurBlock;  //evalua expresión
//          Result := res;  //toma resultado
          if PErr.HayError then exit;
        end;
        if cIn.tokL<> 'end' then begin
          GenError('Se esperaba "end".');
          exit;
        end;
      end else begin
        GenError('Error de diseño. Estructura no implementada.');
        exit;
      end;
    end else begin  //debe ser una expresión
      GetExpression(0);
      if perr.HayError then exit;   //aborta
    end;
    //se espera delimitador
    if cIn.Eof then break;  //sale por fin de archivo
    //busca delimitador
    cIn.SkipWhitesNoEOL;
    if cIn.tokType=tkEol then begin //encontró delimitador de expresión
      cIn.Next;   //lo toma
      cIn.SkipWhites;  //quita espacios
    end else if cIn.tokType = tkBlkDelim then begin  //hay delimitador de bloque
      exit;  //no lo toma
    end else begin  //hay otra cosa
      exit;  //debe ser un error
    end;
  end;
end;
procedure CompilarArc;
//Compila un programa en el contexto actual
begin
//  CompilarAct;
  Perr.Clear;
  cIn.SkipWhites;
  if cIn.Eof then begin
//    GenError('Se esperaba "begin", "var", "type" o "const".');
    exit;
  end;
  //empiezan las declaraciones
  Cod_StartData;
  if cIn.tokL = 'var' then begin
    cIn.Next;    //lo toma
    while (cIn.tokL <>'begin') and (cIn.tokL <>'const') and
          (cIn.tokL <>'type') and (cIn.tokL <>'var') do begin
      CompileVarDeclar;
      if pErr.HayError then exit;;
    end;
  end;
//  if cIn.tokL = 'begin' then begin
//    cIn.Next;   //coge "begin"
    Cod_StartProgram;
    //codifica el contenido
    CompileCurBlock;   //compila el cuerpo
    if Perr.HayError then exit;
    if cIn.Eof then begin
//      GenError('Inesperado fin de archivo. Se esperaba "end".');
      exit;       //sale
    end;
    if cIn.tokL <> 'end' then begin  //verifica si termina el programa
      GenError('Se esperaba "end".');
      exit;       //sale
    end;
    cIn.Next;   //coge "end"
{  end else begin
    GenError('Se esperaba "begin", "var", "type" o "const".');
    exit;
  end;}
end;
procedure Compilar(NombArc: string; LinArc: Tstrings);
//Ejecuta el contenido de un archivo
begin
  //se pone en un "try" para capturar errores y para tener un punto salida de salida
  //único
  if ejecProg then begin
    GenError('Ya se está ejecutando un programa actualmente.');
    exit;  //sale directamente
  end;
  try
    ejecProg := true;  //marca bandera
    frmPrincipal.ejecMac := true;  //indica que se está ejecutando la macro
    Perr.IniError;
    ClearVars;       //limpia las variables
    ClearFuncs;      //limpia las funciones
    mem.Clear;       //limpia salida
    cIn.ClearAll;     //elimina todos los Contextos de entrada
    ExprLevel := 0;  //inicia
    //compila el archivo abierto

  //  con := PosAct;   //Guarda posición y referencia a contenido actual
    cIn.NewContextFromFile(NombArc,LinArc);   //Crea nuevo contenido
    if PErr.HayError then exit;
    CompilarArc;     //puede dar error
    Cod_EndProgram;  //da oportunidad de hacer verificaciones
    cIn.QuitaContexEnt;   //es necesario por dejar limpio
    if PErr.HayError then exit;   //sale
  //  PosAct := con;   //recupera el contenido actual

  //  PPro.GenArchivo(ArcSal);
  //  ShowResult;  //muestra el resultado
  finally
    ejecProg := false;
    frmPrincipal.ejecMac := false;
    frmPRincipal.ActualizarInfoPanel0;
  end;
end;
function Evaluar(var Op1: TOperand; opr: TOperator; var Op2: TOperand): TOperand;
//Ejecuta una operación con dos operandos y un operador. "opr" es el operador de Op1.
var
  o: TxOperation;
begin
   debugln(space(ExprLevel)+' Eval('+Op1.txt + ',' + Op2.txt+')');
   PErr.IniError;
   //Busca si hay una operación definida para: <tipo de Op1>-opr-<tipo de Op2>
   o := opr.FindOperation(Op2.typ);
   if o = nil then begin
//      GenError('No se ha definido la operación: (' +
//                    Op1.typ.name + ') '+ opr.txt + ' ('+Op2.typ.name+')');
      GenError('Operación no válida: (' +
                    Op1.typ.name + ') '+ opr.txt + ' ('+Op2.typ.name+')');
      Exit;
    end;
   p1 := Op1;    //fija operando 1
   p2 := Op2;    //fija operando 2
   o.proc;      //Llama al evento asociado
   {$IFDEF mode_inter}
   //Para un intérprete, se debe copiar casi todos los campos
   Result := res;
   {$ELSE}
   Result.typ := res.typ;    //lee tipo
   Result.catOp:=res.catOp;  //tipo de operando
   Result.estOp:=res.estOp;  //actualiza estado
   {$ENDIF}
   //Completa campos de evaluar
   Result.txt := Op1.txt + opr.txt + Op2.txt;   //texto de la expresión
//   Evaluar.uop := opr;   //última operación ejecutada
End;
function GetOperandP(pre: integer): TOperand;
//Toma un operando realizando hasta encontrar un operador de precedencia igual o menor
//a la indicada
var
  Op1: TOperand;
  Op2: TOperand;
  opr: TOperator;
  pos: TPosCont;
begin
  debugln(space(ExprLevel)+' CogOperando('+IntToStr(pre)+')');
  Op1 :=  GetOperand;  //toma el operador
  if pErr.HayError then exit;
  //verifica si termina la expresion
  pos := cIn.PosAct;    //Guarda por si lo necesita
  cIn.SkipWhitesNoEOL;
  opr := Op1.GetOperator;
  if opr = nil then begin  //no sigue operador
    Result:=Op1;
  end else if opr=nullOper then begin  //hay operador pero, ..
    //no está definido el operador siguente para el Op1, (no se puede comaprar las
    //precedencias) asumimos que aquí termina el operando.
    cIn.PosAct := pos;   //antes de coger el operador
    Result:=Op1;
  end else begin  //si está definido el operador (opr) para Op1, vemos precedencias
    If opr.jer > pre Then begin  //¿Delimitado por precedencia de operador?
      //es de mayor precedencia, se debe evaluar antes.
      Op2 := GetOperandP(pre);  //toma el siguiente operando (puede ser recursivo)
      if pErr.HayError then exit;
      Result:=Evaluar(Op1, opr, Op2);
    End else begin  //la precedencia es menor o igual, debe salir
      cIn.PosAct := pos;   //antes de coger el operador
      Result:=Op1;
    end;
  end;
end;
function GetExpressionCore(const prec: Integer): TOperand; //inline;
//Generador de Algoritmos de Evaluacion de expresiones.
//Esta es la función más importante del compilador
var
  Op1, Op2  : TOperand;   //Operandos
  opr1: TOperator;  //Operadores
begin
  Op1.catTyp:=t_integer;    //asumir opcion por defecto
  Op2.catTyp:=t_integer;   //asumir opcion por defecto
  pErr.Clear;
  //----------------coger primer operando------------------
  Op1 := GetOperand; if pErr.HayError then exit;
//  debugln(space(ExprLevel)+' Op1='+Op1.txt);
  //verifica si termina la expresion
  cIn.SkipWhitesNoEOL;
  opr1 := Op1.GetOperator;
  if opr1 = nil then begin  //no sigue operador
    //Expresión de un solo operando. Lo carga por si se necesita
    Op1.Load;   //carga el operador para cumplir
    Result:=Op1;
    exit;  //termina ejecucion
  end;
  //------- sigue un operador ---------
  //verifica si el operador aplica al operando
  if opr1 = nullOper then begin
    GenError('No está definido el operador: '+ opr1.txt + ' para tipo: '+Op1.typ.name);
    exit;
  end;
  //inicia secuencia de lectura: <Operador> <Operando>
  while opr1<>nil do begin
    //¿Delimitada por precedencia?
    If opr1.jer <= prec Then begin  //es menor que la que sigue, expres.
      Result := Op1;  //solo devuelve el único operando que leyó
      exit;
    End;
{    //--------------------coger operador ---------------------------
	//operadores unitarios ++ y -- (un solo operando).
    //Se evaluan como si fueran una mini-expresión o función
	if opr1.id = op_incremento then begin
      case Op1.catTyp of
        t_integer: Cod_IncremOperanNumerico(Op1);
      else
        GenError('Operador ++ no es soportado en este tipo de dato.',PosAct);
        exit;
      end;
      opr1 := cogOperador; if pErr.HayError then exit;
      if opr1.id = Op_ninguno then begin  //no sigue operador
        Result:=Op1; exit;  //termina ejecucion
      end;
    end else if opr1.id = op_decremento then begin
      case Op1.catTyp of
        t_integer: Cod_DecremOperanNumerico(Op1);
      else
        GenError('Operador -- no es soportado en este tipo de dato.',PosAct);
        exit;
      end;
      opr1 := cogOperador; if pErr.HayError then exit;
      if opr1.id = Op_ninguno then begin  //no sigue operador
        Result:=Op1; exit;  //termina ejecucion
      end;
    end;}
    //--------------------coger segundo operando--------------------
    Op2 := GetOperandP(Opr1.jer);   //toma operando con precedencia
//    debugln(space(ExprLevel)+' Op2='+Op2.txt);
    if pErr.HayError then exit;
    //prepara siguiente operación
    Op1 := Evaluar(Op1, opr1, Op2);    //evalua resultado
    if PErr.HayError then exit;
    cIn.SkipWhitesNoEOL;
    opr1 := Op1.GetOperator;   {lo toma ahora con el tipo de la evaluación Op1 (opr1) Op2
                                porque puede que Op1 (opr1) Op2, haya cambiado de tipo}
  end;  //hasta que ya no siga un operador
  Result := Op1;  //aquí debe haber quedado el resultado
end;
function GetExpression(const prec: Integer; isParam: boolean = false
    //indep: boolean = false
    ): TOperand;
//Envoltura para GetExpressionCore(). Se coloca así porque GetExpressionCore()
//tiene diversos puntos de salida y Se necesita llamar siempre a expr_end() al
//terminar.
//"isParam" indica que la expresión evaluada es el parámetro de una función.
//"indep", indica que la expresión que se está evaluando es anidada pero es independiente
//de la expresion que la contiene, así que se puede liberar los registros o pila.
{ TODO : Para optimizar debería existir solo GetExpression() y no GetExpressionCore() }
begin
  Inc(ExprLevel);  //cuenta el anidamiento
//  debugln(space(ExprLevel)+'>Inic.expr');
  expr_start;  //llama a evento
  Result := GetExpressionCore(prec);
  expr_end(isParam);    //llama al evento de salida
//  debugln(space(ExprLevel)+'>Fin.expr');
  Dec(ExprLevel);
//  if ExprLevel = 0 then debugln('');
end;
function GetBoolExpression: TOperand;
//Simplifica la evaluación de expresiones booleanas, validadno el tipo
begin
  Result := GetExpression(0);  //evalua expresión
  if PErr.HayError then exit;
  if Result.Typ.cat <> t_boolean then begin
    GenError('Se esperaba expresión booleana');
  end;
end;
{function GetNullExpression(): TOperand;
//Simplifica la evaluación de expresiones sin dar error cuando encuentra algún delimitador
begin
  if
  Result := GetExpression(0);  //evalua expresión
  if PErr.HayError then exit;
end;}

initialization
  mem := TStringList.Create;
  PErr.IniError;   //inicia motor de errores
  //Inicia lista de tipos
  types := TTypes.Create(true);
  //Inicia variables, funciones y constantes
  ClearAllVars;
  ClearAllFuncs;
  ClearAllConst;
  //crea el operador NULL
  nullOper := TOperator.Create;
  //inicia la sintaxis
  xLex := TSynFacilSyn.Create(nil);   //crea lexer
  StartSyntax; //Debería hacerse solo una vez al inicio
  if HayError then PErr.Show;
  cIn := TContexts.Create(xLex); //Crea lista de Contextos
  ejecProg := false;

finalization;
  cIn.Destroy; //Limpia lista de Contextos
  xLex.Free;
  nullOper.Free;
  types.Free;
  mem.Free;  //libera
end.

