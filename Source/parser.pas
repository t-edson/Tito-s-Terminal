{}
//{$DEFINE mode_inter}  //mode_inter->Modo intérprete  mode_comp->Modo compilador
unit Parser;
{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, LCLType, Dialogs, lclProc, Graphics, Forms, Strutils,
  SynEditHighlighter, SynFacilBasic, XPresParser, XpresBas, XpresTypes, XpresElements,
  FrameCfgConex, UnTerminal,
  MisUtils, FormConfig;

type

 { TCompiler }

  TCompiler = class(TCompilerBase)
  private
    //referencias de tipos adicionales de tokens
    tkStruct   : TSynHighlighterAttributes;
    tkExpDelim : TSynHighlighterAttributes;
    tkBlkDelim : TSynHighlighterAttributes;
    tkOthers   : TSynHighlighterAttributes;
  protected
    //function GetOperand: TOperand; override;
    procedure CaptureParams; override;
    procedure SkipWhites; override;
  public
    mem   : TStringList;   //Para almacenar el código de salida del compilador
    function EOBlock: boolean;
    function EOExpres: boolean;
    procedure CompileCurBlock;
    procedure CompilarArc;
    procedure Compilar(NombArc: string; LinArc: Tstrings);
    //estos métodos solo sirven para hacer públicos los métodos protegidos
    procedure CreateVariable(const varName: string; typ: ttype);
    procedure CreateVariable(varName, varType: string);
    procedure StartSyntax;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

//procedure Compilar(NombArc: string; LinArc: Tstrings);
var
  cxp : TCompiler;
  DetEjec: boolean;   //Bander general para detener la ejecución. No se usa la de TCompilerBase

implementation
uses FormPrincipal;

//Funciones de acceso al compilador. Facilitan el acceso de forma resumida.
procedure Code(cod: string);
begin
  cxp.mem.Add(cod);
end;
procedure GenError(msg: string);
begin
  cxp.GenError(msg);
end;
function HayError: boolean;
begin
  Result := cxp.HayError;
end;
procedure CreateVariable(varName, varType: string);
begin
  cxp.CreateVariable(varName, varType);
end;
{Incluye el código del compilador. Aquí tendrá acceso a todas las variables públicas
 de XPresParser}
{$I GenCod.pas}
//Métodos OVERRIDE
function TCompiler.EOBlock: boolean;
//Indica si se ha llegado el final de un bloque
begin
  Result := cIn.tokType = tkBlkDelim;
end;
function TCompiler.EOExpres: boolean;
//Indica si se ha llegado al final de una expresión
begin
  Result := (cIn.tokType = tkExpDelim) or (cIn.tokType = tkEol);
end;
procedure TCompiler.CompileCurBlock;
//Compila el bloque de código actual hasta encontrar un delimitador de bloque.
function Asign_Identif_Descon(var newvar: string; var vartipe: TType): boolean;
  {Verifica si la instrucción actuak es una asignación a un identificador que no sea
   variable o función declarada. Esta es la forma en que se asume la declaración de
   una variable}
  var
    posc: TPosCont;
    ex: TOperand;
  begin
    Result := false;
    if cIn.tokType <> tkIdentif then exit;
    //verifica si ya ha sido declarado
    if FindPredefName(cIn.tok) <> eltNone then exit;
    //Sigue un identificador desconocido. falta ver si es asignación.
    posc := cIn.PosAct;    //Guarda posición
    newvar := Cin.tok;
    cIn.Next;   //toma identificador
    cIn.SkipWhitesNoEOL;
    if (cIn.tokType = tkOperator) and (cIn.tok = ':=') then begin
      cIn.Next;   //toma operador
      cIn.SkipWhitesNoEOL;
      //deduce tipo
      ex := GetOperand;  //puede generar error
      if Perr.HayError then exit;   //sale con el puntero en la posición del error
      vartipe:=ex.typ;   //devuelve referencia a tipo
      cIn.PosAct := posc;  //retorna posición
      exit(true);        //si es asignación
    end;
    //no sigue asignación
    cIn.PosAct := posc;    //solo retorna posición
  end;
var
  tmp: string;
  varType: TType;
  EsAsignNueva: Boolean;
begin
  cIn.SkipWhites;  //ignora comentarios inciales
  //if config.fcMacros.marLin then ;
  while not cIn.Eof and not EOBlock do begin
    //Se espera una expresión o estructura
    EsAsignNueva := Asign_Identif_Descon(tmp, varType);  //Verifica si es asignación
    if Perr.HayError then exit;   //puede que se haya encontrado un error
    if EsAsignNueva then begin  //hay identificador nuevo
      //se asume que es la declaración de una variable
  //      MsgBox('variable nueva: ' + tmp );
      CreateVariable(tmp, varType);
      if Perr.HayError then exit;
      GetExpression(0);   //procesa la expresión
    end else if cIn.tokType = tkStruct then begin  //es una estructura
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
        if cIn.tokL<> 'endif' then begin
          GenError('Se esperaba "endif".');
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
    end else if EOBlock then begin  //hay delimitador de bloque
      exit;  //no lo toma
    end else begin  //hay otra cosa, debe ser un error.
      GenError('Error de sintaxis.');
      exit;
    end;
  end;
end;
procedure TCompiler.CompilarArc;
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
  Cod_StartProgram;
  //codifica el contenido
  CompileCurBlock;   //compila el cuerpo
  if Perr.HayError then exit;
  if cIn.Eof then begin
//      GenError('Inesperado fin de archivo. Se esperaba "end".');
    exit;       //sale
  end;
  cIn.Next;   //coge "end"
end;
procedure TCompiler.Compilar(NombArc: string; LinArc: Tstrings);
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
    //tareas de finalización
    frmPrincipal.ejecMac := false;
    frmPRincipal.ActualizarInfoPanel0;
  end;
end;
procedure TCompiler.CreateVariable(const varName: string; typ: ttype);
begin
  Inherited;
end;
procedure TCompiler.CreateVariable(varName, varType: string);
begin
  Inherited;
end;
procedure TCompiler.CaptureParams;
//Lee los parámetros de una función en la función interna funcs[0]
begin
  cIn.SkipWhitesNoEOL;
  func0.ClearParams;   //inicia parámetros
  if EOBlock or EOExpres then begin
    //no tiene parámetros
  end else begin
    //debe haber parámetros
    repeat
      GetExpression(0, true);  //captura parámetro
      if perr.HayError then exit;   //aborta
      //guarda tipo de parámetro, para después comparar todos los parámetros leídos
      func0.CreateParam('', res.typ);
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

procedure TCompiler.SkipWhites;
{En este lenguaje, se consideran delimitadores a los saltos de línea, así que no se
 deben saltar.}
begin
  cIn.SkipWhitesNoEOL;
end;

//procedure TCompilerBase.ShowError
constructor TCompiler.Create;
begin
  inherited Create;
  mem := TStringList.Create;  //crea lista para almacenar ensamblador
  //se puede definir la sintaxis aquí o dejarlo para StartSyntax()
  StartSyntax;   //Debe hacerse solo una vez al inicio
  if HayError then ShowError;
end;

destructor TCompiler.Destroy;
begin
  mem.Free;  //libera
  inherited Destroy;
end;

initialization
  //Es necesario crear solo una instancia del compilador.
  cxp := TCompiler.Create;  //Crea una instancia del compilador

finalization
  cxp.Destroy;
end.

