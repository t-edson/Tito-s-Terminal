{                               TSynFacilSyn 0.9.2
* Corregido el problema en el que no se reconocía el color Transparente en las secciones.
* Corregido un problema con la deteccion de identificadores duplicados en el archivo XML

                                    Por Tito Hinostroza  15/08/2014 - Lima Perú
}
unit SynFacilHighlighter;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Graphics, SynEditHighlighter, DOM, XMLRead,
  Dialogs, Fgl, Lazlogger, SynEditHighlighterFoldBase, SynEditTypes, LCLIntf;
const
  COL_TRANSPAR = $FDFEFF;  //color transparente
type
  //identifica si un token es el delimitador inicial
  TFaTypeDelim =(tdNull,     //no es delimitado
                 tdUniLin,   //es delimitador inicial de token delimitado de una línea
                 tdMulLin,   //es delimitador inicial de token delimitado multilínea
                 tdConten1, //es delimitador inicial de token por contenido 1
                 tdConten2, //es delimitador inicial de token por contenido 2
                 tdConten3, //es delimitador inicial de token por contenido 3
                 tdConten4); //es delimitador inicial de token por contenido 4
  //tipos de coloreado de bloques
  TFaColBlock = (cbNull,     //sin coloreado
                 cbLevel,    //colorea bloques por nivel
                 cbBlock);   //colorea bloques usando el color definido para cada bloque

  TFaProcMetTable = procedure of object;   //Tipo de procedimiento para procesar el token de
                                         //acuerdo al caracter inicial.
  TFaProcRange = procedure of object;      //Procedimiento para procesar en medio de un rango.

  TFaSynBlock = class;   //definición adelantada
  //Descripción de tokens especiales (identificador o símbolo)
  TTokEspec = record
    txt   : string;        //palabra clave (puede cambiar la caja y no incluir el primer caracter)
    orig  : string;        //palabra clave tal cual se indica
    TokPos: integer;       //posición del token dentro de la línea
    tTok  : TSynHighlighterAttributes;  //tipo de token
    tipDel: TFaTypeDelim;  {indica si el token especial actual, es en realidad, el
                            delimitador inicial de un token delimitado o por contenido}
    dEnd  : string;        //delimitador final (en caso de que sea delimitador)
    pRange: TFaProcRange;    //procedimiento para procesar el token o rango(si es multilinea)
    folTok: boolean;       //indica si el token delimitado, tiene plegado
    //propiedades para manejo de bloques y plegado de código
    bloIni : boolean;       //indica si el token es inicio de bloque de plegado
    bloIniL: array of TFaSynBlock;  //lista de referencias a los bloques que abre
    bloFin : boolean;       //indica si el token es fin de bloque de plegado
    bloFinL: array of TFaSynBlock;  //lista de referencias a los bloques que cierra
    secIni : boolean;       //indica si el token es inicio de sección de bloque
    secIniL: array of TFaSynBlock;  //lista de bloques de los que es inicio de sección
    firstSec: TFaSynBlock;     //sección que se debe abrir al abrir el bloque
  end;

  TArrayTokEspec = array of TTokEspec;
  //clase para manejar la definición de bloques de sintaxis
  TFaSynBlock = class
    name        : string;    //nombre del bloque
    index       : integer;   //indica su posición dentro de TFaListBlocks
    showFold    : boolean;   //indica si se mostrará la marca de plegado
    parentBlk   : TFaSynBlock; //bloque padre (donde es válido el bloque)
    BackCol     : TColor;    //color de fondo de un bloque
    IsSection   : boolean;   //indica si es un bloque de tipo sección
    UniqSec     : boolean;   //índica que es sección única
  end;

  TPtrATokEspec = ^TArrayTokEspec;     //puntero a tabla
  TPtrTokEspec = ^TTokEspec;     //puntero a tabla

  //guarda información sobre un atributo de un nodo XML
  TFaXMLatrib = record  //atributo XML
    hay: boolean;    //bandera de existencia
    val: string;     //valor en cadena
    n  : integer;    //valor numérico
    bol: boolean;    //valor booleando (si aplica)
    col: TColor;     //valor de color (si aplica)
  end;

  //Para manejo del plegado
  TFaListBlocks = specialize TFPGObjectList<TFaSynBlock>;   //lista de bloques

  //Descripción de token. Usado solamente para el trabajo del método ExploreLine()
  TFaTokInfo = record
     txt    : string;        //texto del token
     TokPos : integer;       //posición del token dentro de la línea
     TokTyp : TSynHighlighterAttributes;  //atributo de token
     posIni : integer;       //posición de inicio en la línea
     curBlk : TFaSynBlock;     //referencia al bloque del token
  end;
  TATokInfo = array of TFaTokInfo;

  //Estructura para almacenar la descripción de los token por contenido
  tFaTokContent = record
    TokTyp    : TSynHighlighterAttributes;   //categoría de token por contenido
    CharsToken: array[#0..#255] of ByteBool; //caracteres válidos para token por contenido
    carValFin : string[64];                  //caracteres válidos para el fin
  end;

  { TSynFacilSyn }

  TSynFacilSyn = class(TSynCustomFoldHighlighter)
  protected   //variables internas
    fLine      : PChar;         //puntero a línea de trabajo
    tamLin     : integer;       //tamaño de línea actual
    fAtriTable : array[#0..#255] of TSynHighlighterAttributes;   //tabla de atributos de tokens
    fProcTable : array[#0..#255] of TFaProcMetTable;   //tabla de métodos
    posIni     : Integer;       //índice a inicio de token
    posFin     : Integer;       //índice a siguiente token
    fStringLen : Integer;       //Tamaño del token actual
    fToIdent   : PChar;         //Puntero a identificador
    fTokenID   : TSynHighlighterAttributes;  //Id del token actual
    carIni     : char;          //caracter al que apunta fLine[posFin]
    lisBlocks  : TFaListBlocks; //lista de bloques de sintaxis
    delTok     : string;        //delimitador del bloque actual
    folTok     : boolean;       //indica si hay folding que cerrar en token delimitado
    car_ini_iden: Set of char;  //caracteres iniciales de identificador
    nTokenCon  : integer;       //cantidad de tokens por contenido
    fRange     : ^TTokEspec;    //para trabajar con tokens multilínea
    BlkToClose : TFaSynBlock;   //bandera-variable para posponer el cierre de un bloque
    posTok     : integer;       //para identificar el ordinal del token en una línea
    procedure SetTokContent(var tc: tFaTokContent; dStart: string;
      charsCont: string; TypDelim: TFaTypeDelim; charsEnd: string;
      typToken: TSynHighlighterAttributes);
    function ValidateInterval(var cars: string): boolean;
    procedure ValidateParamStart(var Start: string);
    //manejo de bloques
    procedure StartBlock(ABlockType: Pointer; IncreaseLevel: Boolean);
    procedure EndBlock(DecreaseLevel: Boolean);
    function TopBlock: TFaSynBlock;
    function TopBlockOpac: TFaSynBlock;
    function LeeAtrib(n: TDOMNode; nomb: string): TFaXMLatrib;
  protected   //Funciones de bajo nivel
    function HayEnMatInfo(var mat: TArrayTokEspec; cad: string; var n: integer;
      TokPos: integer=0): boolean;
    procedure ValidAsigDelim(delAct, delNue: TFaTypeDelim; delim: string);
    function CreaBuscTokEspec(var mat: TArrayTokEspec; cad: string; var i: integer;
      TokPos: integer=0): boolean;
    function CreaBuscIdeEspec(var mat: TPtrATokEspec; cad: string; var i: integer;
      TokPos: integer=0): boolean;
    function CreaBuscSymEspec(var mat: TPtrATokEspec; cad: string; var i: integer;
      TokPos: integer=0): boolean;
    function CreaBuscEspec(var tok: TPtrTokEspec; cad: string; TokPos: integer
      ): boolean;
    procedure TableIdent(iden: string; var mat: TPtrATokEspec; var met: TFaProcMetTable);
    procedure VerifDelim(delim: string);
    function KeyComp(var r: TTokEspec): Boolean;
    function IsAttributeName(txt: string): boolean;
    procedure FirstXMLExplor(doc: TXMLDocument);
    function ValidarAtribs(n: TDOMNode; listAtrib: string): boolean;
  public    //funciones públicas de alto nivel
    Err       : string;         //mensaje de error
    LangName  : string;         //nombre del lengauje
    Extensions: String;         //extensiones de archivo
    CaseSensitive: boolean;
    MainBlk   : TFaSynBlock;    //Bloque global
    MulTokBlk : TFaSynBlock;    //Bloque reservado para bloques multitokens
    ColBlock  : TFaColBlock;      //coloreado por bloques
    function GetAttribByName(txt: string): TSynHighlighterAttributes;
    procedure ClearMethodTables; //Limpia la tabla de métodos
    //definición de tokens por contenido
    procedure DefTokIdentif(dStart, charsCont: string);
    procedure DefTokContent(dStart, charsCont, charsEnd: string; typToken: TSynHighlighterAttributes);
    //manejo de identificadores especiales
    procedure ClearSpecials;        //Limpia identif, y símbolos especiales
    procedure AddIdentSpec(iden: string; tokTyp: TSynHighlighterAttributes; TokPos: integer=0);
    procedure AddIdentSpecList(listIden: string; tokTyp: TSynHighlighterAttributes; TokPos: integer=0);
    procedure AddKeyword(iden: string);
    procedure AddSymbSpec(symb: string; tokTyp: TSynHighlighterAttributes; TokPos: integer=0);
    procedure AddSymbSpecList(listSym: string; tokTyp: TSynHighlighterAttributes; TokPos: integer=0);
    procedure DefTokDelim(dStart, dEnd: string; tokTyp: TSynHighlighterAttributes;
      tipDel: TFaTypeDelim=tdUniLin; havFolding: boolean=false);
    procedure RebuildSymbols;
    procedure LoadFromFile(Arc: string); virtual;     //Para cargar sintaxis
    procedure Rebuild; virtual;

    procedure AddIniBlockToTok(dStart: string; TokPos: integer; blk: TFaSynBlock);
    procedure AddFinBlockToTok(dEnd: string; TokPos: integer; blk: TFaSynBlock);
    procedure AddIniSectToTok(dStart: string; TokPos: integer; blk: TFaSynBlock);
    procedure AddFirstSectToTok(dStart: string; TokPos: integer; blk: TFaSynBlock);
    function CreateBlock(blkName: string; showFold: boolean=true;
      parentBlk: TFaSynBlock=nil): TFaSynBlock;
    function AddBlock(dStart, dEnd: string; showFold: boolean=true;
      parentBlk: TFaSynBlock=nil): TFaSynBlock;
    function AddSection(dStart: string; showFold: boolean=true;
      parentBlk: TFaSynBlock=nil): TFaSynBlock;
    function AddFirstSection(dStart: string; showFold: boolean=true;
      parentBlk: TFaSynBlock=nil): TFaSynBlock;
    //funciones para obtener información de bloques
    function NestedBlocks: Integer;
    function NestedBlocksBegin(LineNumber: integer): Integer;
    function SearchBeginBlock(level: integer; PosY: integer): integer;
    function SearchEndBlock(level: integer; PosY: integer): integer;
    procedure SearchBeginEndBlock(level: integer; PosX, PosY: integer; out
      pIniBlock, pEndBlock: integer);
    function TopCodeFoldBlock(DownIndex: Integer=0): TFaSynBlock;
    function SetHighlighterAtXY(XY: TPoint): boolean;
    function ExploreLine(XY: TPoint; out toks: TATokInfo; out CurTok: integer
      ): boolean;
    function GetBlockInfoAtXY(XY: TPoint; out blk: TFaSynBlock; out level: integer
      ): boolean;
    function GetBlockInfoAtXY(XY: TPoint; out blk: TFaSynBlock; out
      BlockStart: TPoint; out BlockEnd: TPoint): boolean;
    function GetXY: TPoint;  //devuelve la posición actual del resaltador
    procedure CreateAttributes;  //limpia todos loa atributos
  private   //procesamiento de identificadores especiales
    CharsIdentif: array[#0..#255] of ByteBool; //caracteres válidos para identificadores
    tc1, tc2, tc3, tc4: tFaTokContent;
    //tablas para identificadores especiales
    mA, mB, mC, mD, mE, mF, mG, mH, mI, mJ, mK, mL, mM,  //para mayúsculas
    mN, mO, mP, mQ, mR, mS, mT, mU, mV, mW, mX, mY, mZ,
    mA_,mB_,mC_,mD_,mE_,mF_,mG_,mH_,mI_,mJ_,mK_,mL_,mM_, //para minúsculas
    mN_,mO_,mP_,mQ_,mR_,mS_,mT_,mU_,mV_,mW_,mX_,mY_,mZ_,
    m_, mDol, mArr, mPer, mAmp, mC3 : TArrayTokEspec;
    mSym        :  TArrayTokEspec;   //tabla de símbolos especiales
    mSym0       :  TArrayTokEspec;   //tabla temporal para símbolos especiales.
    TabMayusc   : array[#0..#255] of Char;     //Tabla para conversiones rápidas a mayúscula
    //métodos para identificadores especiales
    procedure metA;
    procedure metB;
    procedure metC;
    procedure metD;
    procedure metE;
    procedure metF;
    procedure metG;
    procedure metH;
    procedure metI;
    procedure metJ;
    procedure metK;
    procedure metL;
    procedure metM;
    procedure metN;
    procedure metO;
    procedure metP;
    procedure metQ;
    procedure metR;
    procedure metS;
    procedure metT;
    procedure metU;
    procedure metV;
    procedure metW;
    procedure metX;
    procedure metY;
    procedure metZ;
    procedure metA_;
    procedure metB_;
    procedure metC_;
    procedure metD_;
    procedure metE_;
    procedure metF_;
    procedure metG_;
    procedure metH_;
    procedure metI_;
    procedure metJ_;
    procedure metK_;
    procedure metL_;
    procedure metM_;
    procedure metN_;
    procedure metO_;
    procedure metP_;
    procedure metQ_;
    procedure metR_;
    procedure metS_;
    procedure metT_;
    procedure metU_;
    procedure metV_;
    procedure metW_;
    procedure metX_;
    procedure metY_;
    procedure metZ_;
    procedure metUnd;
    procedure metDol;
    procedure metArr;
    procedure metPer;
    procedure metAmp;
    procedure metC3;
  private   //procesamiento de otros elementos
    procedure metNull;
    procedure metSpace;
    procedure metSymbol;
    procedure metIdent;
    procedure metIdentUTF8;
    procedure metTokCont1;
    procedure metTokCont2;
    procedure metTokCont3;
    procedure metTokCont4;

    procedure ProcTokenDelim(const d: TTokEspec);
    procedure ProcIdentEsp(var mat: TArrayTokEspec);
    procedure metSimbEsp;
    //funciones rápidas para la tabla de métodos
    procedure metUniLin1;
    procedure metFinLinea;
    procedure metSym1Car;
    //funciones llamadas en medio de rangos
    procedure ProcFinLinea;
    procedure ProcRangeEndSym;
    procedure ProcRangeEndSym1;
    procedure ProcRangeEndIden;
  public     //métodos OVERRIDE
    procedure SetLine(const NewValue: String; LineNumber: Integer); override;
    procedure Next; override;
    function  GetEol: Boolean; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer); override;
    function  GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
    function GetToken: String; override;
    function GetTokenPos: Integer; override;
    function GetTokenKind: integer; override;
    procedure ResetRange; override;
    function GetRange: Pointer; override;
    procedure SetRange(Value: Pointer); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  public     //atributos y sus propiedades de acceso
    //ID para los atributos predefinidos
    tkEol     : TSynHighlighterAttributes;  //id para los tokens salto de línea
    tkSymbol  : TSynHighlighterAttributes;  //id para los símbolos
    tkSpace   : TSynHighlighterAttributes;  //id para los espacios
    tkIdentif : TSynHighlighterAttributes;  //id para los identificadores
    tkNumber  : TSynHighlighterAttributes;  //id para los números
    tkKeyword : TSynHighlighterAttributes;  //id para las palabras claves
    tkString  : TSynHighlighterAttributes;  //id para las cadenas
    tkComment : TSynHighlighterAttributes;  //id para los comentarios
    function NewTokType(TypeName: string): TSynHighlighterAttributes;
{    fEofAttri      : TSynHighlighterAttributes;  //atributo para salto de línea
    fSymbolAttri   : TSynHighlighterAttributes;
    fSpaceAttri    : TSynHighlighterAttributes;
    fIdentifAttri  : TSynHighlighterAttributes;
    fNumberAttri   : TSynHighlighterAttributes;
    fKeywordAttri  : TSynHighlighterAttributes;
    fStringAttri   : TSynHighlighterAttributes;
    fCommentAttri  : TSynHighlighterAttributes;
//published   //Se crean accesos a las propiedades
    property SymbolAttri: TSynHighlighterAttributes read fSymbolAttri write fSymbolAttri;
    property SpaceAttri: TSynHighlighterAttributes read fSpaceAttri write fSpaceAttri;
    property IdentifierAttri: TSynHighlighterAttributes read fIdentifAttri write fIdentifAttri;
    property NumberAttri: TSynHighlighterAttributes read fNumberAttri write fNumberAttri;
    property KeywordAttri: TSynHighlighterAttributes read fKeywordAttri write fKeywordAttri;
    property StringAttri: TSynHighlighterAttributes read fStringAttri write fStringAttri;
    property CommentAttri: TSynHighlighterAttributes read fCommentAttri write fCommentAttri;}
  end;

implementation
const
  ERR_TOK_DELIM_NULL = 'Delimitador de token no puede ser nulo';
  ERR_TOK_DEL_IDE_ERR = 'Delimitador de token erróneo: %s (debe ser identificador)';
  ERR_START_NO_EMPTY = 'Parámetro "Start" No puede ser nulo';
  ERR_IDEN_ALREA_DEL = 'Identificador "%s" ya es delimitador inicial.';
  ERR_EXP_MUST_BE_BR = 'Expresión debe ser de tipo [lista de caracteres]';
  ERR_DEF_INTERVAL = 'Error en definición de intervalo: %s';
  ERR_IDENTIF_EMPTY = 'Identificador vacío.';
  ERR_IDENT_NO_VALID = 'Identificador no válido.';
  ERR_IDENTIF_EXIST = 'Ya existe identificador: ';
  ERR_EMPTY_SYMBOL = 'Símbolo vacío';
  ERR_EMPTY_IDENTIF = 'IDentificador vacío';
  ERR_SYMBOL_EXIST = 'Ya existe símbolo.';
  ERR_INVAL_ATTR_LAB = 'Atributo "%s" no válido para etiqueta <%s>';
  ERR_MUST_DEF_CHARS = 'Debe indicarse atributo "CharsStart=" en etiqueta <IDENTIFIERS ...>';
  ERR_MUST_DEF_CONT = 'Debe indicarse atributo "Content=" en etiqueta <IDENTIFIERS ...>';
  ERR_UNKNOWN_LABEL = 'Etiqueta no reconocida <%s> en: %s';
  ERR_INVAL_LBL_IDEN = 'Etiqueta "%s" no válida para etiqueta <IDENTIFIERS ...>';
  ERR_BAD_PAR_STR_IDEN = 'Parámetro "Start" debe ser de la forma: [A..Z], en identificadores';
  ERR_INVAL_LBL_IN_LBL = 'Etiqueta "%s" no válida para etiqueta <SYMBOLS ...>';
  ERR_BLK_NO_DEFINED = 'No se encuentra definido el bloque: ';

  { TSynFacilSyn }

//funciones de bajo nivel
function TSynFacilSyn.HayEnMatInfo(var mat: TArrayTokEspec; cad: string;
                         var n: integer; TokPos: integer = 0): boolean;
//Busca una cadena en una matriz TArrayTokEspec. Si la ubica devuelve el índice en "n".
var i : integer;
begin
  Result := false;
  if TokPos = 0 then begin //búsqueda normal
    for i := 0 to High(mat) do
      if mat[i].txt = cad then begin
        n:= i; exit(true);
      end
  end else begin  //búsqueda con TokPos
      for i := 0 to High(mat) do
        if (mat[i].txt = cad) and (TokPos = mat[i].TokPos) then begin
          n:= i; exit(true);
        end
  end;
end;
function TSynFacilSyn.ValidateInterval(var cars: string): boolean;
//Valida un conjunto de caracteres para ser usado en la definición de tokens por contenido
//Si hay error sale con TRUE
var i: integer;
  bajos: string[128];
  altos: string[128];
  p: SizeInt;
  car1, car2, c: char;
  expanded: string;
begin
  //prepara definición de comodines
  bajos[0] := #127;
  for i:=1 to 127 do bajos[i] := chr(i);  //todo menos #0
  altos[0] := #128;
  for i:=1 to 128 do altos[i] := chr(i+127);
  //reemplaza intervalos
  Result := false;  //por defecto
  if cars = '' then exit(true);   //validación
  p:= Pos('..',cars);
  while  p <> 0 do begin
    if (p=1) or (p=length(cars)-1) then begin
      Err:=Format(ERR_DEF_INTERVAL,[cars]);
      exit(true);
    end;
    //hay intervalo, reemplaza
    car1 := cars[p-1]; car2 := cars[p+2];
    expanded := '';
    for c:=car1 to car2  //construye intervalo explícito
      do expanded += c;
    cars := copy(cars,1,p-2)+expanded+copy(cars,p+3,1000);
    p:= Pos('..',cars);   //busca si hay más
  end;
  cars := StringReplace(cars, '%HIGH%', altos,[rfReplaceAll]);
  cars := StringReplace(cars, '%ALL%', bajos+altos,[rfReplaceAll]);
  //podría actualizar la variable "Err"
end;
procedure TSynFacilSyn.ValidateParamStart(var Start: string);
//Valida si la expresión del parámetro es de tipo <literal> o [<lista>]. En los casos de
//listas de caracteres, expande los intervalos de tipo: A..Z.
//Si encuentra error, devuelve mensaje en "Err".
var
  list: String;
begin
  if Start= '' then begin
    Err := ERR_START_NO_EMPTY;
    exit;
  end;
  if Start[1] = '[' then begin    //Es lista de caracteres
    if Start[length(Start)]<>']' then begin
      Err := ERR_EXP_MUST_BE_BR;
      exit;
    end;
    list := copy(Start,2,length(Start)-2);  //toma interior
    //valida si hay intervalos de caracteres y los reemplaza
    if ValidateInterval(list) then exit;
    //Actualiza cadena expandida
    Start := '['+list+']';
  end else if length(Start) = 1 then begin  //Es un literal de un solo caracter.
    //Lo tratamos como lista de caracteres para mejorar el desempeño
    Start := '['+Start+']';
  end else begin
    //aquí se puede suponer que es de tipo <literal>. No se puede verificar
    VerifDelim(Start);   //valida reglas
    if Err <> '' then exit;
  end;
end;
procedure TSynFacilSyn.ValidAsigDelim(delAct, delNue: TFaTypeDelim; delim: string);
//Verifica si la asignación de delimitadores es válida. Si no lo es devuelve error.
begin
  if delAct = tdNull then  exit;  //No estaba inicializado, es totalente factible
  //valida asignación de delimitador
  if (delAct in [tdUniLin, tdMulLin]) and
     (delNue in [tdUniLin, tdMulLin]) then begin
    Err := Format(ERR_IDEN_ALREA_DEL,[delim]);
    exit;
  end;
end;
function TSynFacilSyn.CreaBuscTokEspec(var mat: TArrayTokEspec; cad: string;
                                       var i:integer; TokPos: integer = 0): boolean;
{Busca o crea el token especial indicado en "cad". Si ya existe, devuelve TRUE y
 actualiza "i" con su posición. Si no existe. Crea el token especial y devuelve la referencia
 en "i". Se le debe indicar la tabla a buscar en "mat"}
var r:TTokEspec;
begin
  if not CaseSensitive then cad:= UpCase(cad);  //cambia caja si es necesario
  if HayEnMatInfo(mat,cad, i, TokPos) then exit(true);  //ya existe, devuelve en "i"
  //no existe, hay que crearlo. Aquí se definen las propiedades por defecto
  r.txt:=cad;         //se asigna el nombre
  r.TokPos:=TokPos;   //se asigna ordinal del token
  r.tTok:=nil;        //sin tipo asignado
  r.tipDel:=tdNull;   //no es delimitador
  r.dEnd:='';         //sin delimitador final
  r.pRange:=nil;      //sin función de rango
  r.folTok:=false;    //sin plegado de token
  r.bloIni:=false;    //sin plegado de bloque
  r.bloFin:=false;    //sin plegado de bloque
  r.secIni:=false;    //no es sección de bloque
  r.firstSec:=nil;     //inicialmente no abre ningún bloque

  i := High(mat)+1;   //siguiente posición
  SetLength(mat,i+1); //hace espacio
  mat[i] := r;        //copia todo el registro
  //sale indicando que se ha creado
  Result := false;
end;
function TSynFacilSyn.CreaBuscIdeEspec(var mat: TPtrATokEspec; cad: string;
                                          var i:integer; TokPos: integer = 0): boolean;
{Busca o crea el identificador especial indicado en "cad". Si ya existe, devuelve TRUE, y
 actualiza "i" con su posición. Si no existe, crea el token especial y devuelve la referencia
 en "i". En "mat" devuelve la referencia a la tabla que corresponda al identificador.}
var met: TFaProcMetTable;
    c: Char;
begin
  Result := false;  //valor por defecto
  TableIdent(cad, mat, met);  //busca tabla y método
  if Err<>'' then exit;  //Identificador vacío o no hay tabla apropiada
  //Verifica si existe
  if CreaBuscTokEspec(mat^, copy(cad,2,length(cad)), i, TokPos) then begin
    exit(true);  //Ya existe
  end;
  //No existía, pero se creó. Ahora hay que actualizar la tabla de métodos
  mat^[i].orig:=cad;  //guarda el identificador original
  c := cad[1]; //primer caracter
  if CaseSensitive then begin //sensible a la caja
    fProcTable[c] := met;
  end else begin
    fProcTable[LowerCase(c)] := met;
    fProcTable[UpCase(c)] := met;
  end;
end;
function TSynFacilSyn.CreaBuscSymEspec(var mat: TPtrATokEspec; cad: string;
                                          var i:integer; TokPos: integer = 0): boolean;
{Busca o crea el símbolo especial indicado en "cad". Si ya existe, devuelve TRUE, y
 actualiza "i" con su posición. Si no existe, crea el token especial y devuelve la referencia
 en "i". En "mat" devuelve la referencia a la tabla que corresponda al símbolo (por ahora
 siempre será mSymb0).}
begin
  Result := false;  //valor por defecto
  mat := @mSym0;  //no hace falta buscarlo
  //Verifica si existe
  if CreaBuscTokEspec(mSym0, cad, i, TokPos) then
    exit(true);  //Ya existe.
  //No existía, pero se creó.
end;
function TSynFacilSyn.CreaBuscEspec(var tok: TPtrTokEspec; cad: string;
                                          TokPos: integer): boolean;
{Busca o crea un token especial (identificador o símbolo), con texto "cad" y posición en
 "TokPos". Si ya existe, devuelve TRUE, y su posición en "i". Si no existe, crea el token
 especial y devuelve su posición en "i". En "mat" devuelve la referencia a la matriz que
 corresponda al identificador o símbolo especial.}
var mat: TPtrATokEspec;
    i: integer;
begin
  if cad[1] in car_ini_iden then begin  //delimitador es identificador
    Result := CreaBuscIdeEspec(mat, cad, i, TokPos); //busca o crea
    if Err<>'' then exit; //puede haber error
    if not Result then
      mat^[i].tTok:=tkIdentif;  //es token nuevo, hay que darle atributo por defecto
  end else begin   //el delimitador inicial es símbolo
    Result := CreaBuscSymEspec(mat, cad, i, TokPos);  //busca o crea
    if not Result then
      mat^[i].tTok:=tkSymbol;  //es token nuevo, hay que darle atributo por defecto
  end;
  tok := @mat^[i];   //devuelve referencia a token especial
end;

procedure TSynFacilSyn.TableIdent(iden: string; var mat: TPtrATokEspec;
  var met: TFaProcMetTable);
{Devuelve uan referencia a la tabla que corresponde a un identificador y el método que debe
 procesarlo.}
var
  c: char;
begin
  if iden = '' then begin
    Err := ERR_IDENTIF_EMPTY;
    exit;
  end;
  c := iden[1]; //primer caracter
  mat :=nil; met := nil;   //valores por defecto
  if CaseSensitive then begin //sensible a la caja
    case c of
    'A': begin mat:= @mA;  met := @metA; end;
    'B': begin mat:= @mB;  met := @metB; end;
    'C': begin mat:= @mC;  met := @metC; end;
    'D': begin mat:= @mD;  met := @metD; end;
    'E': begin mat:= @mE;  met := @metE; end;
    'F': begin mat:= @mF;  met := @metF; end;
    'G': begin mat:= @mG;  met := @metG; end;
    'H': begin mat:= @mH;  met := @metH; end;
    'I': begin mat:= @mI;  met := @metI; end;
    'J': begin mat:= @mJ;  met := @metJ; end;
    'K': begin mat:= @mK;  met := @metK; end;
    'L': begin mat:= @mL;  met := @metL; end;
    'M': begin mat:= @mM;  met := @metM; end;
    'N': begin mat:= @mN;  met := @metN; end;
    'O': begin mat:= @mO;  met := @metO; end;
    'P': begin mat:= @mP;  met := @metP; end;
    'Q': begin mat:= @mQ;  met := @metQ; end;
    'R': begin mat:= @mR;  met := @metR; end;
    'S': begin mat:= @mS;  met := @metS; end;
    'T': begin mat:= @mT;  met := @metT; end;
    'U': begin mat:= @mU;  met := @metU; end;
    'V': begin mat:= @mV;  met := @metV; end;
    'W': begin mat:= @mW;  met := @metW; end;
    'X': begin mat:= @mX;  met := @metX; end;
    'Y': begin mat:= @mY;  met := @metY; end;
    'Z': begin mat:= @mZ;  met := @metZ; end;
    'a': begin mat:= @mA_; met := @metA_;end;
    'b': begin mat:= @mB_; met := @metB_;end;
    'c': begin mat:= @mC_; met := @metC_;end;
    'd': begin mat:= @mD_; met := @metD_;end;
    'e': begin mat:= @mE_; met := @metE_;end;
    'f': begin mat:= @mF_; met := @metF_;end;
    'g': begin mat:= @mG_; met := @metG_;end;
    'h': begin mat:= @mH_; met := @metH_;end;
    'i': begin mat:= @mI_; met := @metI_;end;
    'j': begin mat:= @mJ_; met := @metJ_;end;
    'k': begin mat:= @mK_; met := @metK_;end;
    'l': begin mat:= @mL_; met := @metL_;end;
    'm': begin mat:= @mM_; met := @metM_;end;
    'n': begin mat:= @mN_; met := @metN_;end;
    'o': begin mat:= @mO_; met := @metO_;end;
    'p': begin mat:= @mP_; met := @metP_;end;
    'q': begin mat:= @mQ_; met := @metQ_;end;
    'r': begin mat:= @mR_; met := @metR_;end;
    's': begin mat:= @mS_; met := @metS_;end;
    't': begin mat:= @mT_; met := @metT_;end;
    'u': begin mat:= @mU_; met := @metU_;end;
    'v': begin mat:= @mV_; met := @metV_;end;
    'w': begin mat:= @mW_; met := @metW_;end;
    'x': begin mat:= @mX_; met := @metX_;end;
    'y': begin mat:= @mY_; met := @metY_;end;
    'z': begin mat:= @mZ_; met := @metZ_;end;
    //adicionales
    '_': begin mat:= @m_  ;met := @metUnd;end;
    '$': begin mat:= @mDol;met := @metDol;  end;
    '@': begin mat:= @mArr;met := @metArr;  end;
    '%': begin mat:= @mPer;met := @metPer;  end;
    '&': begin mat:= @mAmp;met := @metAmp;  end;
    end;
  end else begin  //no es sensible a la caja
    case c of
    'A','a': begin mat:= @mA;  met:= @metA;  end;
    'B','b': begin mat:= @mB;  met:= @metB; end;
    'C','c': begin mat:= @mC;  met:= @metC; end;
    'D','d': begin mat:= @mD;  met:= @metD; end;
    'E','e': begin mat:= @mE;  met:= @metE; end;
    'F','f': begin mat:= @mF;  met:= @metF; end;
    'G','g': begin mat:= @mG;  met:= @metG; end;
    'H','h': begin mat:= @mH;  met:= @metH; end;
    'I','i': begin mat:= @mI;  met:= @metI; end;
    'J','j': begin mat:= @mJ;  met:= @metJ; end;
    'K','k': begin mat:= @mK;  met:= @metK; end;
    'L','l': begin mat:= @mL;  met:= @metL; end;
    'M','m': begin mat:= @mM;  met:= @metM; end;
    'N','n': begin mat:= @mN;  met:= @metN; end;
    'O','o': begin mat:= @mO;  met:= @metO; end;
    'P','p': begin mat:= @mP;  met:= @metP; end;
    'Q','q': begin mat:= @mQ;  met:= @metQ; end;
    'R','r': begin mat:= @mR;  met:= @metR; end;
    'S','s': begin mat:= @mS;  met:= @metS; end;
    'T','t': begin mat:= @mT;  met:= @metT; end;
    'U','u': begin mat:= @mU;  met:= @metU; end;
    'V','v': begin mat:= @mV;  met:= @metV; end;
    'W','w': begin mat:= @mW;  met:= @metW; end;
    'X','x': begin mat:= @mX;  met:= @metX; end;
    'Y','y': begin mat:= @mY;  met:= @metY; end;
    'Z','z': begin mat:= @mZ;  met:= @metZ; end;
    '_'    : begin mat:= @m_  ;met:= @metUnd;end;
    '$'    : begin mat:= @mDol;met:= @metDol;end;
    '@'    : begin mat:= @mArr;met:= @metArr;end;
    '%'    : begin mat:= @mPer;met:= @metPer;end;
    '&'    : begin mat:= @mAmp;met:= @metAmp;end;
    #$C3   : begin mat:= @mC3; met:= @metC3; end;  //página 195 de UTF-8
    end;
  end;
  //verifica error
  if mat = nil then begin
    Err := ERR_IDENT_NO_VALID+': '+iden; exit;
  end;
end;
procedure TSynFacilSyn.VerifDelim(delim: string);
//Verifica la validez de un delimitador para un token delimitado
var c:char;
    tmp: string;
begin
  //verifica contenido
  if delim = '' then begin
    Err := ERR_TOK_DELIM_NULL;
    exit;
  end;
  //verifica si inicia con caracter de identificador.
  if  delim[1] in car_ini_iden then begin
    //Empieza como identificador. Hay que verificar todos los demás caracteres sean
    //también de identificador, De otra forma no se podrá reconocer el token.
    tmp := copy(delim, 2, length(delim) );
    for c in tmp do
      if not CharsIdentif[c] then begin
        Err:= format(ERR_TOK_DEL_IDE_ERR,[delim]);
        exit;
      end;
  end;
end;
procedure TSynFacilSyn.SetTokContent(var tc: tFaTokContent; dStart: string;
                                     charsCont: string;
                                     TypDelim: TFaTypeDelim;
                                     charsEnd: string;
                                     typToken: TSynHighlighterAttributes);
//Configura la definición de un token por contenido. De ser así devuelve TRUE y
//actualiza la tabla de métodos con el método indicado. No hace la validación completa de
//la expresión. Esta debe haber sido ya previemente analizada.
var
  c: Char;
  tok: TPtrTokEspec;
begin
  tc.CarValFin := charsEnd;
  tc.TokTyp:= typToken;  //fija categoría de token
  /////// Configura detección de inicio
  if dStart[1] = '[' then begin  //es intervalo
    dStart := copy(dStart,2,length(dStart)-2);  //quita corchetes
    //Agrega cada caracter como símbolo especial, aunque parezca ineficiente. Pero de esta
    //forma se podrán procesar tokens por contenido que empiecen con el mismo caracter.
    //Además, de ser posible, la función Rebuild() optimizará luego el procesamiento.
    for c in dStart do begin
        CreaBuscEspec(tok, c, 0);  //busca o crea
        if Err<>'' then exit;
        //actualiza sus campos. Cambia, si ya existía
        tok^.tipDel:=TypDelim;  //solo es necesario marcarlo como que es por contenido
    end;
  end else begin
    //Es un literal. Configura token especial
    CreaBuscEspec(tok, dStart, 0);  //busca o crea
    if Err<>'' then exit;
    //actualiza sus campos. Cambia, si ya existía
    tok^.tipDel:=TypDelim;  //solo es necesario marcarlo como que es por contenido
  end;
  /////// Configura caracteres de contenido
  //limpia matriz y marca las posiciones apropiadas
  for c := #0 to #255 do tc.CharsToken[c] := False;
  for c in charsCont do tc.CharsToken[c] := True;
end;
function TSynFacilSyn.KeyComp(var r: TTokEspec): Boolean; inline;
{Compara rápidamente una cadena con el token actual, apuntado por "fToIden".
 El tamaño del token debe estar en "fStringLen"}
var
  i: Integer;
  Temp: PChar;
begin
  Temp := fToIdent;
  if Length(r.txt) = fStringLen then begin  //primera comparación
    if (r.TokPos <> 0) and (r.TokPos<>posTok) then exit(false);  //no coincide
    Result := True;  //valor por defecto
    for i := 1 to fStringLen do begin
      if TabMayusc[Temp^] <> r.txt[i] then exit(false);
      inc(Temp);
    end;
  end else  //definitívamente es diferente
    Result := False;
end;
function TSynFacilSyn.GetAttribByName(txt: string): TSynHighlighterAttributes;
//Devuelve el identificador de un atributo, recibiendo su nombre. Si no lo encuentra
//devuelve NIL.
var
  i: Integer;
begin
  Result := nil;     //por defecto es null
  txt := UpCase(txt);   //ignora la caja
  if txt = 'EOL'        then Result := tkEol else
  if txt = 'SYMBOL'     then Result := tkSymbol else
  if txt = 'SPACE'      then Result := tkSpace else
  if txt = 'IDENTIFIER' then Result := tkIdentif else
  if txt = 'NUMBER'     then Result := tkNumber else
  if txt = 'KEYWORD'    then Result := tkKeyword else
  if txt = 'STRING'     then Result := tkString else
  if txt = 'COMMENT'    then Result := tkComment
  else begin
    for i:=0 to AttrCount-1 do begin
        if Upcase(Attribute[i].Name) = txt then
          Result := Attribute[i];  //devuleve índice
    end;
  end;
end;
function TSynFacilSyn.IsAttributeName(txt: string): boolean;
//Verifica si una cadena corresponde al nombre de un atributo.
begin
  //primera comparación
  if GetAttribByName(txt) <> nil then exit(true);
  //puede que haya sido "NULL"
  if UpCase(txt) = 'NULL' then exit(true);
  //definitivamente no es
  Result := False;
end;
function TSynFacilSyn.LeeAtrib(n: TDOMNode; nomb:string): TFaXMLatrib;
//Explora un nodo para ver si existe un atributo, y leerlo. Ignora la caja.
var i: integer;
    cad: string;
    atri: TDOMNode;
    r,g,b: integer;
function EsEntero(txt: string; var num: integer): boolean;
//convierte un texto en un número entero. Si es numérico devuelve TRUE
var i: integer;
begin
  Result := true;  //valor por defecto
  num := 0; //valor por defecto
  for i:=1 to length(txt) do begin
    if not (txt[i] in ['0'..'9']) then exit(false);  //no era
  end;
  //todos los dígitos son numéricos
  num := StrToInt(txt);
end;
function EsHexa(txt: string; var num: integer): boolean;
//Convierte un texto en un número entero. Si es numérico devuelve TRUE
var i: integer;
begin
  Result := true;  //valor por defecto
  num := 0; //valor por defecto
  for i:=1 to length(txt) do begin
    if not (txt[i] in ['0'..'9','a'..'f','A'..'F']) then exit(false);  //no era
  end;
  //todos los dígitos son numéricos
  num := StrToInt('$'+txt);
end;
begin
  Result.hay := false; //Se asume que no existe
  Result.val:='';      //si no encuentra devuelve vacío
  Result.bol:=false;   //si no encuentra devuelve Falso
  Result.n:=0;         //si no encuentra devuelve 0
  for i:= 0 to n.Attributes.Length-1 do begin
    atri := n.Attributes.Item[i];
    if UpCase(atri.NodeName) = UpCase(nomb) then begin
      Result.hay := true;          //marca bandera
      Result.val := atri.NodeValue;  //lee valor
      Result.bol := UpCase(atri.NodeValue) = 'TRUE';  //lee valor booleano
      cad := trim(atri.NodeValue);  //valor sin espacios
      //lee número
      if (cad<>'') and (cad[1] in ['0'..'9']) then  //puede ser número
        EsEntero(cad,Result.n); //convierte
      //lee color
      if (cad<>'') and (cad[1] = '#') and (length(cad)=7) then begin
        //es código de color. Lo lee de la mejor forma
        EsHexa(copy(cad,2,2),r);
        EsHexa(copy(cad,4,2),g);
        EsHexa(copy(cad,6,2),b);
        Result.col:=RGB(r,g,b);
      end else begin  //constantes de color
        case UpCase(cad) of
        'WHITE'      : Result.col:=rgb($FF,$FF,$FF);
        'RED'        : Result.col:=rgb($FF,$00,$00);
        'GREEN'      : Result.col:=rgb($00,$FF,$00);
        'BLUE'       : Result.col:=rgb($00,$00,$FF);
        'MAGENTA'    : Result.col:=rgb($FF,$00,$FF);
        'CYAN'       : Result.col:=rgb($00,$FF,$FF);
        'YELLOW'     : Result.col:=rgb($FF,$FF,$00);
        'BLACK'      : Result.col:=rgb($00,$00,$00);
        'AQUA'       : Result.col:=rgb($70,$DB,$93);
        'BLUE VIOLET': Result.col:=rgb($9F,$5F,$9F);
        'BRASS'      : Result.col:=rgb($B5,$A6,$42);
        'BRIGHT GOLD': Result.col:=rgb($D9,$D9,$19);
        'BROWN'      : Result.col:=rgb($A6,$2A,$2A);
        'BRONZE'     : Result.col:=rgb($8C,$78,$53);
        'COPPER'     : Result.col:=rgb($B8,$73,$33);
        'CORAL'      : Result.col:=rgb($FF,$7F,$00);
        'GRAY'       : Result.col:=rgb($C0,$C0,$C0);
        'LIME'       : Result.col:=rgb($32,$CD,$32);
        'MAROON'     : Result.col:=rgb($8E,$23,$6B);
        'NAVY'       : Result.col:=rgb($23,$23,$8E);
        'SILVER'     : Result.col:=rgb($E6,$E8,$FA);
        'VIOLET'     : Result.col:=rgb($4F,$2F,$4F);
        'VIOLET RED' : Result.col:=rgb($CC,$32,$99);
        end;
      end;
    end;
  end;
end;
function TSynFacilSyn.ValidarAtribs(n: TDOMNode; listAtrib: string): boolean;
//Valida la existencia completa de los nodos indicados. Si encuentra alguno más
//actualiza la bandera "Err" y devuelve TRUE. Los nodos deben estar separados por espacios.
var i,j   : integer;
    atri  : TDOMNode;
    nombre, tmp : string;
    Idens : TStringList;
    hay   : boolean;
begin
  //Carga lista de atributos
  Idens :=TStringList.Create;
  Idens.Delimiter := ' ';
  //StringReplace(listSym, #13#10, ' ',[rfReplaceAll]);
  IDens.DelimitedText := listAtrib;
  //Realiza la verificación
  Result := false;  //Se asume que todo va bien
  for i:= 0 to n.Attributes.Length-1 do begin
    atri := n.Attributes.Item[i];
    nombre := UpCase(atri.NodeName);
    //verifica existencia
    hay := false;
    for j:= 0 to IDens.Count -1 do begin
      tmp := trim(IDens[j]);
      if nombre = UpCase(tmp) then begin
         hay := true; break;
      end;
    end;
    //verifica si no existe
    if not hay then begin
      //este atributo está demás
      Err := format(ERR_INVAL_ATTR_LAB,[atri.NodeName, n.NodeName]);
      Result := true;  //marca resultado
      break;
    end;
  end;
  Idens.Free;
end;
procedure TSynFacilSyn.FirstXMLExplor(doc: TXMLDocument);
{Hace al primera explración al archivo XML, para procesar la definición de Symbolos e
 Identificadores. Si encuentra algún error, sale actualizando el campo "Err".
 Si no encuentra definición de Identificadores, crea uan definición por defecto}
var
  nodo, atri   : TDOMNode;
  i,j            : integer;
  nombre         : string;
  hayIDENTIF     : boolean;  //bandera
  haySIMBOLO     : boolean;  //bandera
  tipTok         : TSynHighlighterAttributes;
  tExt, tName, tCasSen: TFaXMLatrib;
  tCharsStart, tContent, tAtrib: TFaXMLatrib;
  tColBlk: TFaXMLatrib;
  tTokPos: TFaXMLatrib;
  tBackCol: TFaXMLatrib;
  Atrib: TSynHighlighterAttributes;
  tForeCol: TFaXMLatrib;
  tFrameCol: TFaXMLatrib;
  tStyBold: TFaXMLatrib;
  tStyItal: TFaXMLatrib;
  tStyUnder: TFaXMLatrib;
  tStyStrike: TFaXMLatrib;
  tStyle: TFaXMLatrib;
  tFrameEdg: TFaXMLatrib;
  tFrameSty: TFaXMLatrib;
begin
  hayIDENTIF := false;
  haySIMBOLO := false;
  //////////// explora atributos del lenguaje//////////
  tExt  := LeeAtrib(doc.DocumentElement, 'Ext');
  tName := LeeAtrib(doc.DocumentElement, 'Name');
  tCasSen :=LeeAtrib(doc.DocumentElement, 'CaseSensitive');
  tColBlk :=LeeAtrib(doc.DocumentElement, 'ColorBlock');
  //carga atributos leidos
  ValidarAtribs(doc.DocumentElement, 'Ext Name CaseSensitive ColorBlock');
  LangName := tName.val;
  Extensions := tExt.val;
  CaseSensitive := tCasSen.bol;
  case UpCase(tColBlk.val) of  //coloreado de bloque
  'LEVEL': ColBlock := cbLevel;
  'BLOCK': ColBlock := cbBlock;
  else ColBlock:= cbNull;
  end;

  ////////////// explora nodos ////////////
  for i:= 0 to doc.DocumentElement.ChildNodes.Count - 1 do begin
     if Err <> '' then  break;  //si hay error, sale
     // Lee un Nodo o Registro
     nodo := doc.DocumentElement.ChildNodes[i];
     nombre := UpCase(nodo.NodeName);
     if nombre = 'IDENTIFIERS' then begin
       hayIDENTIF := true;      //hay definición de identificadores
       ////////// Lee atributos //////////
       tCharsStart  := LeeAtrib(nodo,'CharsStart');
       tContent:= LeeAtrib(nodo,'Content');
       if ValidarAtribs(nodo, 'CharsStart Content') then break; //valida
       ////////// verifica los atributos indicados
       if tCharsStart.hay and tContent.hay then  //lo normal
         DefTokIdentif('['+tCharsStart.val+']', tContent.val)   //Fija caracteres
       else if not tCharsStart.hay and not tContent.hay then  //etiqueta vacía
         DefTokIdentif('[A..Za..z$_]', 'A..Za..z0..9_')  //def. por defecto
       else if not tCharsStart.hay  then
         Err := ERR_MUST_DEF_CHARS
       else if not tContent.hay  then
         Err := ERR_MUST_DEF_CONT;
       if Err <> '' then  break;  //si hay error, sale
       ////////// explora nodos hijos //////////
       for j := 0 to nodo.ChildNodes.Count-1 do begin
         atri := nodo.ChildNodes[j];
         nombre := UpCase(atri.NodeName);
         if nombre = 'TOKEN' then begin  //definición completa
           //lee atributos
           tAtrib:= LeeAtrib(atri,'Attribute');
           tTokPos:= LeeAtrib(atri,'TokPos');  //posición de token
           if ValidarAtribs(atri, 'Attribute TokPos') then break; //valida
           tipTok := GetAttribByName(tAtrib.val);
           //crea los identificadores especiales
           AddIdentSpecList(atri.TextContent, tipTok, tTokPos.n);
         end else if IsAttributeName(nombre) then begin  //definición simplificada
           //lee atributos
           tTokPos:= LeeAtrib(atri,'TokPos');  //posición de token
           if ValidarAtribs(atri, 'TokPos') then break; //valida
           //crea los identificadores especiales
           AddIdentSpecList(atri.TextContent, GetAttribByName(nombre), tTokPos.n);
           if Err<>'' then break;
         end else begin
           Err := Format(ERR_INVAL_LBL_IDEN, [atri.NodeName]);
           break;
         end;
       end;
     end else if nombre = 'SYMBOLS' then begin
       haySIMBOLO := true;      //hay definición de símbolos
       ////////// Lee atributos //////////
       tCharsStart  := LeeAtrib(nodo,'CharsStart');
       tContent:= LeeAtrib(nodo,'Content');
       ////////// Aún no se leen los atributos
       ////////// explora nodos hijos //////////
       for j := 0 to nodo.ChildNodes.Count-1 do begin
         atri := nodo.ChildNodes[j];
         nombre := UpCase(atri.NodeName);
         if nombre = 'TOKEN' then begin  //definición completa
           //lee atributos
           tAtrib:= LeeAtrib(atri,'Attribute');
           tTokPos:= LeeAtrib(atri,'TokPos');  //posición de token
           if ValidarAtribs(atri, 'Attribute TokPos') then break; //valida
           tipTok := GetAttribByName(tAtrib.val);
           //crea los símbolos especiales
           AddSymbSpecList(atri.TextContent, tipTok, tTokPos.n);
         end else if IsAttributeName(nombre) then begin  //definición simplificada
           //lee atributos
           tTokPos:= LeeAtrib(atri,'TokPos');  //posición de token
           if ValidarAtribs(atri, 'TokPos') then break; //valida
           //crea los símbolos especiales
           AddSymbSpecList(atri.TextContent, GetAttribByName(nombre), tTokPos.n);
         end else begin
           Err := Format(ERR_INVAL_LBL_IN_LBL, [atri.NodeName]);
           break;
         end;
       end;
     end else if nombre = 'ATTRIBUTE' then begin
//       haySIMBOLO := true;      //hay definición de símbolos
       ////////// Lee atributos //////////
       tName    := LeeAtrib(nodo,'Name');
       tBackCol := LeeAtrib(nodo,'BackCol');
       tForeCol := LeeAtrib(nodo,'ForeCol');
       tFrameCol:= LeeAtrib(nodo,'FrameCol');
       tFrameEdg:= LeeAtrib(nodo,'FrameEdg');
       tFrameSty:= LeeAtrib(nodo,'FrameSty');
       tStyBold := LeeAtrib(nodo,'Bold');
       tStyItal := LeeAtrib(nodo,'Italic');
       tStyUnder:= LeeAtrib(nodo,'Underline');
       tStyStrike:=LeeAtrib(nodo,'StrikeOut');
       tStyle   := LeeAtrib(nodo,'Style');
       if ValidarAtribs(nodo, 'Name BackCol ForeCol FrameCol FrameEdg FrameSty '+
                              'Bold Italic Underline StrikeOut Style') then
         break; //valida
       ////////// cambia atributo //////////
       if IsAttributeName(tName.val)  then begin
         tipTok := GetAttribByName(tName.val);   //tipo de atributo
       end else begin
         //No existe, se crea.
         tipTok := NewTokType(tName.val);
       end;
       //obtiene referencia
       Atrib := tipTok;
       //asigna la configuración del atributo
       if Atrib <> nil then begin
          if tBackCol.hay then Atrib.Background:=tBackCol.col;
          if tForeCol.hay then Atrib.Foreground:=tForeCol.col;
          if tFrameCol.hay then Atrib.FrameColor:=tFrameCol.col;
          if tFrameEdg.hay then begin
            case UpCase(tFrameEdg.val) of
            'AROUND':Atrib.FrameEdges:=sfeAround;
            'BOTTOM':Atrib.FrameEdges:=sfeBottom;
            'LEFT':  Atrib.FrameEdges:=sfeLeft;
            'NONE':  Atrib.FrameEdges:=sfeNone;
            end;
          end;
          if tFrameSty.hay then begin
            case UpCase(tFrameSty.val) of
            'SOLID': Atrib.FrameStyle:=slsSolid;
            'DASHED':Atrib.FrameStyle:=slsDashed;
            'DOTTED':Atrib.FrameStyle:=slsDotted;
            'WAVED': Atrib.FrameStyle:=slsWaved;
            end;
          end;
          if tStyBold.hay then begin  //negrita
             if tStyBold.bol then Atrib.Style:=Atrib.Style+[fsBold]
             else Atrib.Style:=Atrib.Style-[fsBold];
          end;
          if tStyItal.hay then begin  //cursiva
             if tStyItal.bol then Atrib.Style:=Atrib.Style+[fsItalic]
             else Atrib.Style:=Atrib.Style-[fsItalic];
          end;
          if tStyUnder.hay then begin  //subrayado
             if tStyUnder.bol then Atrib.Style:=Atrib.Style+[fsUnderline]
             else Atrib.Style:=Atrib.Style-[fsUnderline];
          end;
          if tStyStrike.hay then begin //tachado
             if tStyStrike.bol then Atrib.Style:=Atrib.Style+[fsStrikeOut]
             else Atrib.Style:=Atrib.Style-[fsStrikeOut];
          end;
          if tStyle.hay then begin  //forma alternativa
            Atrib.Style:=Atrib.Style-[fsBold]-[fsItalic]-[fsUnderline]-[fsStrikeOut];
            if Pos('b', tStyle.val)<>0 then Atrib.Style:=Atrib.Style+[fsBold];
            if Pos('i', tStyle.val)<>0 then Atrib.Style:=Atrib.Style+[fsItalic];
            if Pos('u', tStyle.val)<>0 then Atrib.Style:=Atrib.Style+[fsUnderline];
            if Pos('s', tStyle.val)<>0 then Atrib.Style:=Atrib.Style+[fsStrikeOut];
          end;
       end;
     end;
     //ignora las otras etiquetas, en esta pasada.
  end;
  //verifica configuraciones por defecto
  if not hayIDENTIF then //no se indicó etiqueta IDENTIFIERS
    DefTokIdentif('[A..Za..z$_]', 'A..Za..z0..9_');  //def. por defecto
//  if not haySIMBOLO then //no se indicó etiqueta SYMBOLS
end;

// ************* funciones de más alto nivel *****************
procedure TSynFacilSyn.ClearMethodTables;
{Limpia la tabla de métodos, usada para identificar a los tokens de la sintaxis.
 También limpia las definiciones de tokens por contenido.
 Proporciona una forma rápida de identificar la categoría de token.}
var i: Char;
begin
  lisBlocks.Clear;   //inicia lista de bloques
  nTokenCon := 0;    //inicia contador de tokens por contenido
  tc1.carValFin := '';
  tc2.carValFin := '';
  tc3.carValFin := '';
  tc4.carValFin := '';
  for i := #0 to #255 do
    case i of
      //caracteres blancos, son fijos
      #1..#32 : fProcTable[i] := @metSpace;
      //fin de línea
      #0      : fProcTable[i] := @metNull;   //Se lee el caracter de marca de fin de cadena
      else //los otros caracteres (alfanuméricos o no)
        fProcTable[i] := @metSymbol;  //se consideran símbolos
    end;
end;
//definición de tokens por contenido
procedure TSynFacilSyn.DefTokIdentif(dStart, charsCont: string );
{Define token para identificadores.
Se debe haber limpiado previamente con "ClearMethodTables"}
var c     : char;
begin
  if dStart = '' then exit;   //protección
  if dStart[1] <> '[' then begin  //debe ser lista de caracteres
    Err := ERR_BAD_PAR_STR_IDEN; exit;
  end;
  ValidateParamStart(dStart);   //valida el primer parámetro
  if Err<>'' then exit;
  /////// Configura caracteres iniciales
  dStart := copy(dStart,2,length(dStart)-2);  //quita corchetes
  //agrega evento manejador
  car_ini_iden := [];  //inicia
  for c in dStart do begin //permite cualquier caracter inicial
    if c<#128 then begin  //caracter normal
      fProcTable[c] := @metIdent;
      car_ini_iden += [c];  //agrega
    end else begin   //caracter UTF-8
      fProcTable[c] := @metIdentUTF8;
      car_ini_iden += [c];  //agrega
    end;
  end;
  /////// Configura caracteres de contenido
  if ValidateInterval(charsCont) then exit;   //validación
  //limpia matriz
  for c := #0 to #255 do begin
    CharsIdentif[c] := False;
    //aprovecha para crear la tabla de mayúsculas para comparaciones
    if CaseSensitive then TabMayusc[c] := c
    else begin  //pasamos todo a mayúscula
      TabMayusc[c] := UpCase(c);
    end;
  end;
  //marca las posiciones apropiadas
  for c in charsCont do CharsIdentif[c] := True;
end;
procedure TSynFacilSyn.DefTokContent(dStart, charsCont, charsEnd: string;
  typToken: TSynHighlighterAttributes);
{Define un token por contenido. Se debe haber limpiado previamente con "ClearMethodTables"
 Solo se permite definir hasta 4 tokens}
begin
  ValidateParamStart(dStart);   //valida el primer parámetro
  if Err<>'' then exit;
  if ValidateInterval(charsCont) then exit;   //validación
  if nTokenCon = 0 then begin       //está libre el 1
    SetTokContent(tc1, dStart, charsCont, tdConten1, charsEnd, typToken);
    if Err<>'' then exit;
    inc(nTokenCon);
  end else if nTokenCon = 1 then begin //está libre el 2
    SetTokContent(tc2, dStart, charsCont, tdConten2, charsEnd, typToken);
    if Err<>'' then exit;
    inc(nTokenCon);
  end else if nTokenCon = 2 then begin //está libre el 3
    SetTokContent(tc3, dStart, charsCont, tdConten3, charsEnd, typToken);
    if Err<>'' then exit;
    inc(nTokenCon);
  end else if nTokenCon = 3 then begin //está libre el 4
    SetTokContent(tc4, dStart, charsCont, tdConten4, charsEnd, typToken);
    if Err<>'' then exit;
    inc(nTokenCon);
  end;  //las demás declaraciones, se ignoran
end;
//manejo de identificadores y símbolos especiales
procedure TSynFacilSyn.ClearSpecials;
//Limpia la lista de identificadores especiales y de símbolos delimitadores.
begin
  //ídentificadores
  SetLength(mA,0); SetLength(mB,0); SetLength(mC,0); SetLength(mD,0);
  SetLength(mE,0); SetLength(mF,0); SetLength(mG,0); SetLength(mH,0);
  SetLength(mI,0); SetLength(mJ,0); SetLength(mK,0); SetLength(mL,0);
  SetLength(mM,0); SetLength(mN,0); SetLength(mO,0); SetLength(mP,0);
  SetLength(mQ,0); SetLength(mR,0); SetLength(mS,0); SetLength(mT,0);
  SetLength(mU,0); SetLength(mV,0); SetLength(mW,0); SetLength(mX,0);
  SetLength(mY,0); SetLength(mZ,0);
  SetLength(mA_,0); SetLength(mB_,0); SetLength(mC_,0); SetLength(mD_,0);
  SetLength(mE_,0); SetLength(mF_,0); SetLength(mG_,0); SetLength(mH_,0);
  SetLength(mI_,0); SetLength(mJ_,0); SetLength(mK_,0); SetLength(mL_,0);
  SetLength(mM_,0); SetLength(mN_,0); SetLength(mO_,0); SetLength(mP_,0);
  SetLength(mQ_,0); SetLength(mR_,0); SetLength(mS_,0); SetLength(mT_,0);
  SetLength(mU_,0); SetLength(mV_,0); SetLength(mW_,0); SetLength(mX_,0);
  SetLength(mY_,0); SetLength(mZ_,0);
  SetLength(m_,0); SetLength(mDol,0); SetLength(mArr,0);
  SetLength(mPer,0); SetLength(mAmp,0); SetLength(mC3,0);
  //símbolos
  SetLength(mSym,0);
  SetLength(mSym0,0);  //limpia espacio temporal
end;
procedure TSynFacilSyn.AddIdentSpec(iden: string; tokTyp: TSynHighlighterAttributes; TokPos: integer
  );
//Método público para agregar un identificador especial cualquiera.
var i: integer;
    mat: TPtrATokEspec;
begin
  Err := '';
  if iden = '' then begin Err := ERR_EMPTY_IDENTIF; exit; end;
  //Verifica si existe
  if CreaBuscIdeEspec(mat, iden, i, TokPos) then begin
    Err := ERR_IDENTIF_EXIST+iden; exit;
  end;
  if Err<>'' then exit;  //pudo haber dado error
  //se ha creado uno nuevo
  mat^[i].tTok:=tokTyp;  //solo cambia atributo
end;
procedure TSynFacilSyn.AddIdentSpecList(listIden: string; tokTyp: TSynHighlighterAttributes;
  TokPos: integer);
//Permite agregar una lista de identificadores especiales separados por espacios.
var
  Idens  : TStringList;
  iden   : string;
  i      : integer;
begin
  //Carga identificadores
  Idens :=TStringList.Create;
  Idens.Delimiter := ' ';
  //StringReplace(listIden, #13#10, ' ',[rfReplaceAll]);
  IDens.DelimitedText := listIden;
  for i:= 0 to IDens.Count -1 do
    begin
      iden := trim(IDens[i]);
      if iden = '' then continue;
      AddIdentSpec(iden, tokTyp, TokPos);
      if Err <> '' then break;
    end;
  Idens.Free;
end;
procedure TSynFacilSyn.AddKeyword(iden: string);
//Método público que agrega un identificador "Keyword" a la sintaxis
begin
  AddIdentSpec(iden, tkKeyword);
end;
procedure TSynFacilSyn.AddSymbSpec(symb: string; tokTyp: TSynHighlighterAttributes; TokPos: integer);
//Método público para agregar un símbolo especial cualquiera.
var i: integer;
    mat: TPtrATokEspec;
begin
  Err := '';
  if symb = '' then begin Err := ERR_EMPTY_SYMBOL; exit; end;
  //Verifica si existe
  if CreaBuscSymEspec(mat, symb, i, TokPos) then begin //busca o crea
    Err := ERR_SYMBOL_EXIST; exit;
  end;
  //se ha creado uno nuevo
  mat^[i].tTok:=tokTyp;  //solo cambia atributo
end;
procedure TSynFacilSyn.AddSymbSpecList(listSym: string; tokTyp: TSynHighlighterAttributes;
  TokPos: integer);
//Permite agregar una lista de símbolos especiales separados por espacios.
var
  Idens  : TStringList;
  iden   : string;
  i      : integer;
begin
  //Carga identificadores
  Idens :=TStringList.Create;
  Idens.Delimiter := ' ';
  //StringReplace(listSym, #13#10, ' ',[rfReplaceAll]);
  IDens.DelimitedText := listSym;
  for i:= 0 to IDens.Count -1 do
    begin
      iden := trim(IDens[i]);
      if iden = '' then continue;
      AddSymbSpec(iden, tokTyp, TokPos);
      if Err <> '' then break;
    end;
  Idens.Free;
end;
//definición de tokens delimitados
procedure TSynFacilSyn.DefTokDelim(dStart, dEnd: string; tokTyp: TSynHighlighterAttributes;
  tipDel: TFaTypeDelim; havFolding: boolean);
{Función genérica para agregar un token delimitado a la sintaxis. Si encuentra error, sale
 con el mensaje en "Err"}
var tok  : TPtrTokEspec;
  procedure ActProcRange(var r: TTokEspec);
  //Configura el puntero pRange() para la función apropiada de acuerdo al delimitador final.
  begin
    if r.tipDel = tdNull then begin  //no es delimitador
      r.pRange:=nil;
      exit;
    end;
    if r.dEnd = '' then exit;
    if r.dEnd = #13 then begin   //Como comentario de una línea
      //no puede ser multilínea
      r.pRange := @ProcFinLinea;
      exit;
    end;
    //los siguientes casos pueden ser multilínea
    if r.dEnd[1] in car_ini_iden then begin //es identificador
      r.pRange:=@ProcRangeEndIden;
    end else begin  //es símbolo
      if length(r.dEnd) = 1 then begin
        r.pRange:=@ProcRangeEndSym1;  //es más óptimo
      end else begin
        r.pRange:=@ProcRangeEndSym;
      end;
    end;
  end;
begin
  if dEnd='' then dEnd := #13;  //no se permite delimitador final vacío
  VerifDelim(dStart);
  if Err <> '' then exit;
  VerifDelim(dEnd);
  if Err <> '' then exit;
  //configura token especial
  CreaBuscEspec(tok, dStart, 0); //busca o crea
  if Err<>'' then exit; //puede haber error
  //actualiza sus campos. Cambia, si ya existía
  tok^.dEnd  :=dEnd;
  tok^.tipDel:=tipDel;
  tok^.tTok  :=tokTyp;
  tok^.folTok:=havFolding;
  ActProcRange(tok^);  //completa .pRange()
end;
procedure TSynFacilSyn.RebuildSymbols;
{Crea entradas en la tabla de métodos para procesar los caracteres iniciales de los símbolos
 especiales. Así se asegura que se detectarán siempre.
Se debe llamar después de haber agregado los símbolos especiales a mSym[]}
var i,j,maximo: integer;
    aux: TTokEspec;
    c        : char;
begin
  {ordena mSym[], poniendo los de mayor tamaño al inicio, para que la búsqueda considere
  primero a los símbolos de mayor tamaño}
  maximo := High(mSym);
  for i:=0 to maximo-1 do
    for j:=i+1 to maximo do begin
      if (length(mSym[i].txt) < length(mSym[j].txt)) then begin
        aux:=mSym[i];
        mSym[i]:=mSym[j];
        mSym[j]:=aux;
      end;
    end;
  //muestra los símbolos especiales que existen
//DebugLn('------ delimitadores símbolo, ordenados --------');
//for tokCtl in mSym do DebugLn('  delim: '+ tokCtl.cad );
DebugLn('---------actualizando tabla de funciones----------');
  {Captura los caracteres válidos para delimitadores y asigna las funciones
   para el procesamiento de delimitadores, usando el símbolo inicial}
  i := 0;
  while i <= High(mSym) do begin
    c := mSym[i].txt[1];   //toma primer caracter
    if fProcTable[c] <> @metSimbEsp then begin  //prepara procesamiento de delimitador
      DebugLn('  puntero a funcion en: [' + c + '] -> @ProcSimbEsp');
      fProcTable[c] := @metSimbEsp;  //prepara procesamiento de delimitador
    end;
    { Para hacerlo más óptimo se debería usar una matriz para cada símbolo, de
     la misma forma a como se hace con los identificadores.}
    inc(i);
  end;
end;

procedure TSynFacilSyn.LoadFromFile(Arc: string);
//Carga una sintaxis desde archivo
var
  doc          : TXMLDocument;
  nodo  : TDOMNode;
  i            : integer;
  nombre       : string;
  tipTok       : TSynHighlighterAttributes;
  tStart, tEnd, tContent, tAtrib : TFaXMLatrib;
  tCharsStart, tCharsEnd, tMultiline, tFolding : TFaXMLatrib;

  function ProcSeccion(nodo: TDOMNode; blqPad: TFaSynBlock): boolean; forward;
  function BuscarBloque(blk: string): TFaSynBlock;
  var i: integer;
  begin
    Result := nil;  //valor por defecto
    if UpCase(blk) = 'NONE' then exit;
    if UpCase(blk) = 'MAIN' then begin
      Result := MainBlk; exit;
    end;
    for i := 0 to lisBlocks.Count-1 do
      if Upcase(lisBlocks[i].name) = Upcase(blk) then begin
         Result := lisBlocks[i];  //devuelve referencia
         exit;
      end;
    //no se encontró el blqPad pedido
    Err := ERR_BLK_NO_DEFINED + blk;
  end;
  function ProcBloque(nodo: TDOMNode; blqPad: TFaSynBlock): boolean;
  //Verifica si el nodo tiene la etiqueta <BLOCK>. De ser así, devuelve TRUE y lo procesa.
  //Si encuentra error, actualiza "Err"
  var
    i: integer;
    tStart, tFolding, tName, tParent : TFaXMLatrib;
    tBackCol, tTokPos: TFaXMLatrib;
    blq : TFaSynBlock;
    nodo2  : TDOMNode;
  begin
    if UpCase(nodo.NodeName) <> 'BLOCK' then exit(false);
    Result := true;  //encontró
    //Lee atributos
    tStart    := LeeAtrib(nodo,'Start');
    tEnd      := LeeAtrib(nodo,'End');
    tName     := LeeAtrib(nodo,'Name');
    tFolding  := LeeAtrib(nodo,'Folding');    //Falso, si no existe
    tParent   := LeeAtrib(nodo,'Parent');
    tBackCol  := LeeAtrib(nodo,'BackCol');
    //validaciones
    if not tFolding.hay then tFolding.bol:=true;  //por defecto
    if not tName.hay then tName.val:='Blk'+IntToStr(lisBlocks.Count+1);
    if ValidarAtribs(nodo, 'Start End Name Folding Parent BackCol') then exit;
    if tParent.hay then begin //se especificó blqPad padre
      blqPad := BuscarBloque(tParent.val);  //ubica blqPad
      if Err<>'' then exit;  //no encontró nombre blqPad
    end;
    //crea el blqoue, con el bloque padre indicado, o el que viene en el parámetro
    blq := CreateBlock(tName.val, tFolding.bol, blqPad);
    if tStart.hay then AddIniBlockToTok(tStart.val, 0, blq);
    if Err<>'' then exit;
    if tEnd.hay   then AddFinBlockToTok(tEnd.val, 0, blq);
    if Err<>'' then exit;
    if tBackCol.hay then begin //lee color
      if UpCase(tBackCol.val)='TRANSPARENT' then blq.BackCol:= COL_TRANSPAR
      else blq.BackCol:= tBackCol.col;
    end;
    ////////// explora nodos hijos //////////
    for i := 0 to nodo.ChildNodes.Count-1 do begin
      nodo2 := nodo.ChildNodes[i];
      if UpCAse(nodo2.NodeName)='START' then begin  //definición alternativa de delimitador
        tTokPos := LeeAtrib(nodo2,'TokPos');
        if ValidarAtribs(nodo2, 'TokPos') then exit;
        //agrega la referecnia del bloque al nuevo token delimitador
        AddIniBlockToTok(trim(nodo2.TextContent), tTokPos.n, blq);
      end else if UpCAse(nodo2.NodeName)='END' then begin  //definición alternativa de delimitador
        tTokPos := LeeAtrib(nodo2,'TokPos');
        if ValidarAtribs(nodo2, 'TokPos') then exit;
        //agrega la referecnia del bloque al nuevo token delimitador
        AddFinBlockToTok(trim(nodo2.TextContent), tTokPos.n, blq);
      end else if ProcSeccion(nodo2, blq) then begin  //definición de sección
        if Err<>'' then exit;  //solo verifica error
      end else if ProcBloque(nodo2, blq) then begin  //definición de bloque anidado
        if Err<>'' then exit;  //solo verifica error
      end else begin
        Err := 'Etiqueta "' + nodo2.NodeName +
               '" no válida para etiqueta <BLOCK ...>';
        exit;
      end;
    end;
  end;
  function ProcSeccion(nodo: TDOMNode; blqPad: TFaSynBlock): boolean;
  //Verifica si el nodo tiene la etiqueta <SECCION>. De ser así, devuelve TRUE y lo procesa.
  //Si encuentra error, actualiza "Err"
  var
    i: integer;
    tStart, tFolding, tName, tParent : TFaXMLatrib;
    blq : TFaSynBlock;
    tBackCol, tUnique: TFaXMLatrib;
    nodo2  : TDOMNode;
    tStartPos: TFaXMLatrib;
    tFirstSec: TFaXMLatrib;
  begin
    if UpCase(nodo.NodeName) <> 'SECTION' then exit(false);
    Result := true;  //encontró
    //lee atributos
    tStart    := LeeAtrib(nodo,'Start');
    tName     := LeeAtrib(nodo,'Name');
    tFolding  := LeeAtrib(nodo,'Folding');    //Falso, si no existe
    tParent   := LeeAtrib(nodo,'Parent');
    tBackCol  := LeeAtrib(nodo,'BackCol');
    tUnique   := LeeAtrib(nodo,'Unique');
    tFirstSec := LeeAtrib(nodo,'FirstSec');
    //validaciones
    if not tFolding.hay then tFolding.bol:=true;  //por defecto
    if not tName.hay then tName.val:='Sec'+IntToStr(lisBlocks.Count+1);
    if ValidarAtribs(nodo, 'Start Name Folding Parent BackCol Unique FirstSec') then
       exit; //valida
    if tParent.hay then begin //se especificó blqPad padre
      blqPad := BuscarBloque(tParent.val);  //ubica blqPad
      if Err<>'' then exit;  //no encontró nombre blqPad
    end;
    //crea la sección, con el bloque padre indicado, o el que viene en el parámetro
    blq := CreateBlock(tName.val, tFolding.bol, blqPad);
    blq.IsSection:=true;
    if tFirstSec.hay then begin  //hay primera sección
      if tStart.hay then AddFirstSectToTok(tStart.val, 0, blq)
    end else begin               //sección normal
      if tStart.hay then AddIniSectToTok(tStart.val, 0, blq);
    end;
    if Err<>'' then exit;
    if tBackCol.hay then begin
      if UpCase(tBackCol.val)='TRANSPARENT' then blq.BackCol:= COL_TRANSPAR
      else blq.BackCol:= tBackCol.col;   //lee color
    end;
    if tUnique.hay then blq.UniqSec:=tUnique.bol;  //lee Unique
    ////////// explora nodos hijos //////////
    for i := 0 to nodo.ChildNodes.Count-1 do begin
        nodo2 := nodo.ChildNodes[i];
        if UpCAse(nodo2.NodeName)='START' then begin  //definición alternativa de delimitador
          tStartPos := LeeAtrib(nodo2,'StartPos');
          if ValidarAtribs(nodo2, 'StartPos') then exit;
          //agrega la referecnia del bloque al nuevo token delimitador
          AddIniSectToTok(trim(nodo2.TextContent), tStartPos.n, blq);
        end else if ProcSeccion(nodo2, blq) then begin  //definición de sección
          if Err<>'' then exit;  //solo verifica error
        end else if ProcBloque(nodo2, blq) then begin  //definición de bloque anidado
          if Err<>'' then exit;  //solo verifica error
        end else begin
          Err := 'Etiqueta "' + nodo2.NodeName +
                 '" no válida para etiqueta <SECTION ...>';
          exit;
        end;
    end;
  end;
begin
DebugLn('');
DebugLn(' === Cargando archivo de sintaxis ===');
  Err := '';
  ClearSpecials;     //limpia tablas de identif. y simbolos especiales
  CreateAttributes;  //Limpia todos los atributos y crea los predefinidos.
  ClearMethodTables; //Limpia tabla de caracter inicial, y los bloques
  try
    ReadXMLFile(doc, Arc);  //carga archivo de lenguaje
    ////////Primera exploración para capturar elementos básicos de la sintaxis/////////
    FirstXMLExplor(doc);  //Hace la primera exploración
    if Err <> '' then begin  //verifica si hay error
      Err +=  #13#10 + Arc;  //completa mensaje con nombre de archivo
      ShowMessage(Err);
      doc.Free;          //libera
      exit;
    end;
    ///////////Segunda exploración para capturar elementos complementarios///////////
    //inicia exploración
    for i:= 0 to doc.DocumentElement.ChildNodes.Count - 1 do begin
       // Lee un Nodo o Registro
       nodo := doc.DocumentElement.ChildNodes[i];
       nombre := UpCase(nodo.NodeName);
       if (nombre = 'IDENTIFIERS') or (nombre = 'SYMBOLS') OR
          (nombre = 'ATTRIBUTE') or (nombre = 'COMPLETION') then begin
         //solo se incluye para evitar error de "etiqueta desconocida"
//     end else if IsAttributeName(nombre)  then begin
       end else if nombre =  'KEYWORD' then begin
         //forma corta de <TOKEN ATTRIBUTE='KEYWORD'> lista </TOKEN>
         AddIdentSpecList(nodo.TextContent, tkKeyword);  //Carga Keywords
       end else if nombre = 'COMMENT' then begin
         //Lee atributos
         tStart   := LeeAtrib(nodo,'Start');
         tEnd     := LeeAtrib(nodo,'End');
         tMultiline:=LeeAtrib(nodo,'Multiline');  //Falso, si no existe
         tFolding := LeeAtrib(nodo,'Folding');    //Falso, si no existe
         //Crea blqPad
         if ValidarAtribs(nodo, 'Start End Multiline Folding') then break;
         if tMultiline.bol then  //se asume multilínea
           DefTokDelim(tStart.val, tEnd.val, tkComment, tdMulLin, tFolding.bol)
         else
           DefTokDelim(tStart.val, tEnd.val, tkComment, tdUniLin, tFolding.bol);
       end else if nombre = 'STRING' then begin
         //Lee atributos
         tStart   := LeeAtrib(nodo,'Start');
         tEnd     := LeeAtrib(nodo,'End');
         tMultiline:=LeeAtrib(nodo,'Multiline');  //Falso, si no existe
         tFolding := LeeAtrib(nodo,'Folding');    //Falso, si no existe
         //Crea blqPad
         if ValidarAtribs(nodo, 'Start End Multiline Folding') then break;
         if tMultiline.bol then   //multilínea
           DefTokDelim(tStart.val, tEnd.val, tkString, tdMulLin, tFolding.bol)
         else
           DefTokDelim(tStart.val, tEnd.val, tkString, tdUniLin, tFolding.bol);
       end else if nombre = 'TOKEN' then begin
         //Lee atributos
         tStart    := LeeAtrib(nodo,'Start');
         tEnd      := LeeAtrib(nodo,'End');
         tCharsStart:= LeeAtrib(nodo,'CharsStart');
         tContent  := LeeAtrib(nodo,'Content');
         tCharsEnd := LeeAtrib(nodo,'CharsEnd');
         tMultiline:=LeeAtrib(nodo,'Multiline');  //Falso, si no existe
         tFolding  := LeeAtrib(nodo,'Folding');    //Falso, si no existe
         tAtrib    := LeeAtrib(nodo,'Attribute');
         tipTok := GetAttribByName(tAtrib.val);
         //verifica tipo de definición
         if tContent.hay then begin //Si hay "Content", es token por contenido
           if ValidarAtribs(nodo, 'Start CharsStart Content CharsEnd Attribute') then break;
           if tStart.hay then  //definición con token especial
             DefTokContent(tStart.val, tContent.val, tCharsEnd.val, tipTok)
           else  //definición con lista de caracteres
             DefTokContent('['+tCharsStart.val+']', tContent.val, tCharsEnd.val, tipTok);
         end else if tStart.hay then  begin //definición de token delimitado
           if ValidarAtribs(nodo, 'Start End Attribute Multiline Folding') then break;
           if tMultiline.bol then  //es multilínea
             DefTokDelim(tStart.val, tEnd.val, tipTok, tdMulLin, tFolding.bol)
           else  //es de una sola líneas
             DefTokDelim(tStart.val, tEnd.val, tipTok, tdUniLin, tFolding.bol);
         end;
       end else if ProcBloque(nodo, nil) then begin  //bloques válidos en cualquier parte
         if Err<>'' then break;  //solo verifica error
       end else if ProcSeccion(nodo, MainBlk) then begin //secciones en "MAIN"
         if Err<>'' then break;  //solo verifica error
       end else begin
          Err := Format(ERR_UNKNOWN_LABEL,[nombre,Arc]);
          break;
       end;
       if Err <> '' then begin
          Err +=  ' <' + nombre + '> en: ' + Arc;  //completa mensaje
          break;
       end;
    end;
    doc.Free;  //libera
    if Err <> '' then begin  //verifica si hay error
      ShowMessage(Err); exit
    end;
    Rebuild;  //prepara el resaltador
    if Err <> '' then begin  //verifica si hay error
      ShowMessage(Err); exit
    end;
  except
    on E: Exception do begin
      ShowMessage('Error cargando: ' + Arc + #13#10 + e.Message);
      doc.Free;
    end;
  end;
end;
procedure TSynFacilSyn.Rebuild;
{Configura los tokens delimitados de acuerdo a la sintaxis definida actualmente, de forma que
 se optimice el procesamiento.
 Todos los tokens que se procesen aquí, deben tener delimitador inicial símbolo}
var
  i,j     : integer;
  r       : TTokEspec;
  dSexc   : boolean;  //indica que el delimitador inicial es exclusivo.
  blk: TFaSynBlock;
  n: Integer;

  function delStart1Exclus(cad0: string): boolean;
  {Indica si el token símbolo es de 1 caracter de ancho y no otro token símbolo que empiece
   con ese caracter}
  var i: integer;
      cad: string;
  begin
    Result := true;  //se asume que si es exclusivo
    if length(cad0)<>1 then exit(false);
    for i := 0 to High(mSym0) do begin
      cad := mSym0[i].txt;
      if cad  <> cad0 then begin  //no considera al mismo
        if cad0[1] = cad[1] then exit(false);  //no es
      end;
    end;
  end;

begin
DebugLn('---------símbolos leidos: mSym0[]----------');
for i:=0 to High(mSym0) do
DebugLn('  bloque: '+ mSym0[i].txt + ',' + StringReplace(mSym0[i].dEnd, #13,#25,[]));
DebugLn('---------simplificando símbolos----------');

  //explora los símbolos para optimizar el procesamiento
  setlength(mSym,0);  //limpia, porque vamos a reconstruir
  for i := 0 to High(mSym0) do begin
    r := mSym0[i];
    dSexc:=delStart1Exclus(r.txt);  //ve si es de 1 caracter y exclusivo
    if dSexc and (r.tipDel = tdConten1) then begin
      //Token por contenido, que se puede optimizar
DebugLn('  [' + r.txt[1] + '] -> @metTokCont1 (Token Por Conten. inicio exclusivo)');
      fProcTable[r.txt[1]] := @metTokCont1;
    end else if dSexc and (r.tipDel=tdConten2) then begin
      //Token por contenido, que se puede optimizar
DebugLn('  [' + r.txt[1] + '] -> @metTokCont2 (Token Por Conten. inicio exclusivo)');
      fProcTable[r.txt[1]] := @metTokCont2;
    end else if dSexc and (r.tipDel=tdConten3) then begin
      //Token por contenido, que se puede optimizar
DebugLn('  [' + r.txt[1] + '] -> @metTokCont3 (Token Por Conten. inicio exclusivo)');
      fProcTable[r.txt[1]] := @metTokCont3;
    end else if dSexc and (r.tipDel=tdConten4) then begin
      //Token por contenido, que se puede optimizar
DebugLn('  [' + r.txt[1] + '] -> @metTokCont4 (Token Por Conten. inicio exclusivo)');
      fProcTable[r.txt[1]] := @metTokCont4;
    end else if dSexc and (r.tipDel=tdUniLin) and (r.txt=r.dEnd) then begin
      //Caso típico de cadenas. Es procesable por nuestra función "metUniLin1"
DebugLn('  [' + r.txt[1] + '] -> @metUniLin1 (uniLin c/delims iguales de 1 car)');
      fProcTable[r.txt[1]] := @metUniLin1;
      fAtriTable[r.txt[1]] := r.tTok; //para que metUniLin1() lo pueda recuperar
    //busca tokens una línea con delimitador de un caracter
    end else if dSexc and (r.tipDel=tdUniLin) and (r.dEnd=#13) then begin
      //Caso típico de comentarios. Es procesable por nuestra función "metFinLinea"
DebugLn('  [' + r.txt[1] + '] -> @metFinLinea (uniLin con dStart de 1 car y dEnd = #13)');
      fProcTable[r.txt[1]] := @metFinLinea;
      fAtriTable[r.txt[1]] := r.tTok; //para que metFinLinea() lo pueda recuperar
      { TODO : Se podría crear un procedimiento para manejar bloques multilíneas
       con delimitador inicial exclusivo y así optimizar su procesamiento porque puede
       tornarse pesado en la forma actual. }
    end else if dSexc and (r.tipDel=tdNull) and not r.bloIni and not r.bloFin then begin
      //es símbolo especial de un caracter, exclusivo, que no es parte de token delimitado
      //ni es inicio o fin de bloque
DebugLn('  [' + r.txt[1] + '] -> @metSym1Car (símbolo simple de 1 car)');
      fProcTable[r.txt[1]] := @metSym1Car;
      fAtriTable[r.txt[1]] := r.tTok; //para que metSym1Car() lo pueda recuperar
    end else begin //no se puede simplificar.
      //Lo agrega a la tabla de símbolos para búsqueda normal.
      CreaBuscTokEspec(mSym, r.txt, j);  //No puede usar CreaBuscSymEspec(), porque usa mSymb0
      mSym[j] := r;  //actualiza o agrega
      if Err<> '' then break;  //sale del lazo
    end
  end;
  //termina el proceso
  RebuildSymbols;
  if CurrentLines <> nil then  //Hay editor asignado
    ScanAllRanges;  {Necesario, porque se ha reconstruido los TTokEspec y
                       los valores de "fRange" de las líneas, están "perdidos"}
DebugLn('--------------------------------');
//  lisBlocksTmp.Free;
end;
//******************** proc. de identificadores especiales ******************
procedure TSynFacilSyn.metA;begin ProcIdentEsp(mA);end;
procedure TSynFacilSyn.metB;begin ProcIdentEsp(mB);end;
procedure TSynFacilSyn.metC;begin ProcIdentEsp(mC);end;
procedure TSynFacilSyn.metD;begin ProcIdentEsp(mD);end;
procedure TSynFacilSyn.metE;begin ProcIdentEsp(mE);end;
procedure TSynFacilSyn.metF;begin ProcIdentEsp(mF);end;
procedure TSynFacilSyn.metG;begin ProcIdentEsp(mG);end;
procedure TSynFacilSyn.metH;begin ProcIdentEsp(mH);end;
procedure TSynFacilSyn.metI;begin ProcIdentEsp(mI);end;
procedure TSynFacilSyn.metJ;begin ProcIdentEsp(mJ);end;
procedure TSynFacilSyn.metK;begin ProcIdentEsp(mK);end;
procedure TSynFacilSyn.metL;begin ProcIdentEsp(mL);end;
procedure TSynFacilSyn.metM;begin ProcIdentEsp(mM);end;
procedure TSynFacilSyn.metN;begin ProcIdentEsp(mN);end;
procedure TSynFacilSyn.metO;begin ProcIdentEsp(mO);end;
procedure TSynFacilSyn.metP;begin ProcIdentEsp(mP);end;
procedure TSynFacilSyn.metQ;begin ProcIdentEsp(mQ);end;
procedure TSynFacilSyn.metR;begin ProcIdentEsp(mR);end;
procedure TSynFacilSyn.metS;begin ProcIdentEsp(mS);end;
procedure TSynFacilSyn.metT;begin ProcIdentEsp(mT);end;
procedure TSynFacilSyn.metU;begin ProcIdentEsp(mU);end;
procedure TSynFacilSyn.metV;begin ProcIdentEsp(mV);end;
procedure TSynFacilSyn.metW;begin ProcIdentEsp(mW);end;
procedure TSynFacilSyn.metX;begin ProcIdentEsp(mX);end;
procedure TSynFacilSyn.metY;begin ProcIdentEsp(mY);end;
procedure TSynFacilSyn.metZ;begin ProcIdentEsp(mZ);end;

procedure TSynFacilSyn.metA_; begin ProcIdentEsp(mA_);end;
procedure TSynFacilSyn.metB_; begin ProcIdentEsp(mB_);end;
procedure TSynFacilSyn.metC_; begin ProcIdentEsp(mC_);end;
procedure TSynFacilSyn.metD_; begin ProcIdentEsp(mD_);end;
procedure TSynFacilSyn.metE_; begin ProcIdentEsp(mE_);end;
procedure TSynFacilSyn.metF_; begin ProcIdentEsp(mF_);end;
procedure TSynFacilSyn.metG_; begin ProcIdentEsp(mG_);end;
procedure TSynFacilSyn.metH_; begin ProcIdentEsp(mH_);end;
procedure TSynFacilSyn.metI_; begin ProcIdentEsp(mI_);end;
procedure TSynFacilSyn.metJ_; begin ProcIdentEsp(mJ_);end;
procedure TSynFacilSyn.metK_; begin ProcIdentEsp(mK_);end;
procedure TSynFacilSyn.metL_; begin ProcIdentEsp(mL_);end;
procedure TSynFacilSyn.metM_; begin ProcIdentEsp(mM_);end;
procedure TSynFacilSyn.metN_; begin ProcIdentEsp(mN_);end;
procedure TSynFacilSyn.metO_; begin ProcIdentEsp(mO_);end;
procedure TSynFacilSyn.metP_; begin ProcIdentEsp(mP_);end;
procedure TSynFacilSyn.metQ_; begin ProcIdentEsp(mQ_);end;
procedure TSynFacilSyn.metR_; begin ProcIdentEsp(mR_);end;
procedure TSynFacilSyn.metS_; begin ProcIdentEsp(mS_);end;
procedure TSynFacilSyn.metT_; begin ProcIdentEsp(mT_);end;
procedure TSynFacilSyn.metU_; begin ProcIdentEsp(mU_);end;
procedure TSynFacilSyn.metV_; begin ProcIdentEsp(mV_);end;
procedure TSynFacilSyn.metW_; begin ProcIdentEsp(mW_);end;
procedure TSynFacilSyn.metX_; begin ProcIdentEsp(mX_);end;
procedure TSynFacilSyn.metY_; begin ProcIdentEsp(mY_);end;
procedure TSynFacilSyn.metZ_; begin ProcIdentEsp(mZ_);end;

procedure TSynFacilSyn.metDol;
begin ProcIdentEsp(mDol);
end;
procedure TSynFacilSyn.metArr;
begin ProcIdentEsp(mArr);
end;
procedure TSynFacilSyn.metPer;
begin ProcIdentEsp(mPer);
end;
procedure TSynFacilSyn.metAmp;
begin ProcIdentEsp(mAmp);
end;
procedure TSynFacilSyn.metC3;
begin ProcIdentEsp(mC3);
end;
procedure TSynFacilSyn.metUnd;
begin ProcIdentEsp(m_);
end;
procedure TSynFacilSyn.metNull;
//Procesa la ocurrencia del cacracter #0
begin
  fTokenID := tkEol;   //Solo necesita esto para indicar que se llegó al final de la línae
end;

//********************* procesamiento de otros elementos ********************
procedure TSynFacilSyn.metSpace;
//Procesa caracter que es inicio de espacio
begin
  fTokenID := tkSpace;
  repeat  //captura todos los que sean espacios
    Inc(posFin);
  until (fLine[posFin] > #32) or (posFin = tamLin);
end;
procedure TSynFacilSyn.metSymbol;
begin
  inc(posFin);
  while (fProcTable[fLine[posFin]] = @metSymbol)
  do inc(posFin);
  fTokenID := tkSymbol;
end;
procedure TSynFacilSyn.metIdent;
//Procesa el identificador actual
begin
  inc(posFin);  {debe incrementarse, para pasar a comparar los caracteres siguientes,
                 o de otra forma puede quedarse en un lazo infinito}
  while CharsIdentif[fLine[posFin]] do inc(posFin);
  fTokenID := tkIdentif;  //identificador común
end;
procedure TSynFacilSyn.metIdentUTF8;
//Procesa el identificador actual. considerando que empieza con un caracter (dos bytes) UTF8
begin
  inc(posFin);  {es UTF8, solo filtra por el primer caracter (se asume que el segundo
                 es siempre válido}
  inc(posFin);  {debe incrementarse, para pasar a comparar los caracteres siguientes,
                 o de otra forma puede quedarse en un lazo infinito}
  while CharsIdentif[fLine[posFin]] do inc(posFin);
  fTokenID := tkIdentif;  //identificador común
end;
procedure TSynFacilSyn.metTokCont1; //Procesa tokens por contenido 1
begin
  fTokenID := tc1.TokTyp;   //pone tipo
  repeat inc(posFin);
  until not tc1.CharsToken[fLine[posFin]];
  //verifica si hay validación de caracter final
  if length(tc1.carValFin)>0 then begin
    while (posFin>posIni+1) and (Pos(fLine[posFin-1],tc1.carValFin)<>0) do
      dec(posFin);
  end;
end;
procedure TSynFacilSyn.metTokCont2; //Procesa tokens por contenido 2
begin
  fTokenID := tc2.TokTyp;   //pone tipo
  repeat inc(posFin);
  until not tc2.CharsToken[fLine[posFin]];
  //verifica si hay validación de caracter final
  if length(tc2.carValFin)>0 then begin
    while (posFin>posIni+1) and (Pos(fLine[posFin-1],tc2.carValFin)<>0) do
      dec(posFin);
  end;
end;
procedure TSynFacilSyn.metTokCont3; //Procesa tokens por contenido 3
begin
  fTokenID := tc3.TokTyp;   //pone tipo
  repeat inc(posFin);
  until not tc3.CharsToken[fLine[posFin]];
  //verifica si hay validación de caracter final
  if length(tc3.carValFin)>0 then begin
    while (posFin>posIni+1) and (Pos(fLine[posFin-1],tc3.carValFin)<>0) do
      dec(posFin);
  end;
end;
procedure TSynFacilSyn.metTokCont4; //Procesa tokens por contenido 3
begin
  fTokenID := tc4.TokTyp;   //pone tipo
  repeat inc(posFin);
  until not tc4.CharsToken[fLine[posFin]];
  //verifica si hay validación de caracter final
  if length(tc4.carValFin)>0 then begin
    while (posFin>posIni+1) and (Pos(fLine[posFin-1],tc4.carValFin)<>0) do
      dec(posFin);
  end;
end;
/////////// manejo de bloques
procedure TSynFacilSyn.StartBlock(ABlockType: Pointer; IncreaseLevel: Boolean); inline;
//Procedimiento geenral para abrir un bloque en el resaltador
begin
//  StartCodeFoldBlock(ABlockType, IncreaseLevel);
  CodeFoldRange.Add(ABlockType, IncreaseLevel);
end;
procedure TSynFacilSyn.EndBlock(DecreaseLevel: Boolean); inline;
//Procedimiento geenral para cerrar un bloque en el resaltador
begin
//  EndCodeFoldBlock(DecreaseLevel);
  CodeFoldRange.Pop(DecreaseLevel);
end;
function TSynFacilSyn.TopBlock: TFaSynBlock;
//Función genérica para devolver el último bloque abierto. Si no hay ningún bloque
//abieto, devuelve "MainBlk".
//Es una forma personalizada de TopCodeFoldBlockType()
var
  Fold: TSynCustomCodeFoldBlock;
begin
//  Result := TFaSynBlock(TopCodeFoldBlockType);
//  if Result = nil then Result := MainBlk;  //protección
  Fold := CodeFoldRange.Top;  //CodeFoldRange nunca denería ser NIL
  if Fold = nil then
    Result := MainBlk  //está en el primer nivel
  else begin
    Result := TFaSynBlock(Fold.BlockType);
    if Result = nil then
      Result := MainBlk;  //protección
  end;
end;
function TSynFacilSyn.TopBlockOpac: TFaSynBlock;
//Función genérica para devolver el último bloque abierto con color de fondo.
var
  Fold: TSynCustomCodeFoldBlock;
begin
  //profundiza hasta encontrar un bloque con color opaco
   Fold := CodeFoldRange.Top;
   while (Fold <> nil) and (Fold.BlockType<>nil) and
         (TFaSynBlock(Fold.BlockType).BackCol=COL_TRANSPAR) do begin
     Fold := Fold.Parent;
   end;
   //si no encontró devuelve el bloque principal
   if (Fold = nil) or (Fold.BlockType=nil) then begin
     Result := MainBlk
   end else begin
     Result := TFaSynBlock(Fold.BlockType);
   end;
end;

procedure TSynFacilSyn.ProcTokenDelim(const d: TTokEspec);
//Procesa un posible token delimitador. Debe llamarse después de que se ha reconocido
//el token especial y el puntero apunte al siguiente token.
  procedure AbreBloqueAct(const d: TTokEspec); //inline;
  {Abre el bloque actual, verificando si está en el bloque valído}
  var i:integer;
      TopBlk: TFaSynBlock;
      bloIni: TFaSynBlock;
  begin
    for i:=0 to High(d.bloIniL) do begin
      bloIni := d.bloIniL[i];
      if bloIni.parentBlk = nil then begin //se abre en cualquier parte
        StartBlock(bloIni, bloIni.showFold);
        //verifica si hay primera sección para abrir
        if d.firstSec <> nil then StartBlock(d.firstSec, d.firstSec.showFold);
        break;   //sale
      end else begin  //se abre en un bloque específico
        TopBlk := TopBlock();  //lee bloque superior
        if TopBlk = bloIni.parentBlk then begin
          StartBlock(bloIni, bloIni.showFold);
          //verifica si hay primera sección para abrir
          if d.firstSec <> nil then StartBlock(d.firstSec, d.firstSec.showFold);
          break;     //sale
        end;
      end;
    end;
  end;
  function AbreSeccionAct(const secIniL: array of TFaSynBlock): boolean; //inline;
  {Verifica si el bloque más reciente del plegado, está en la lista de bloques
   que cierra "d.secIniL". De ser así cierra el bloque y devuelve TRUE}
  var i:integer;
      TopBlk: TFaSynBlock;
  begin
    TopBlk := TopBlock();  //lee bloque superior
    if TopBlk.IsSection then begin //verifica si es bloque de sección
      //Es bloque de sección. ¿Será de alguna de las secciones que maneja?
      for i:=0 to High(secIniL) do
        if TopBlk.parentBlk = secIniL[i].parentBlk then begin
          //debe cerrar primero la sección anterior, porque las secciones no se anidan
          if (TopBlk=secIniL[i]) and TopBlk.UniqSec then exit(false); //verificación
          EndBlock(TopBlk.showFold);  //cierra primero la sección anterior
          //abre una nueva sección
          StartBlock(secIniL[i], secIniL[i].showFold);
          exit(true);  //sale con TRUE
        end;
      Result := false;  //no abrió
    end else begin   //no está en bloque de sección
      //verifica si corresponde abrir esta sección
      for i:=0 to High(secIniL) do
        if TopBlk = secIniL[i].parentBlk then begin  //es su bloque válido
          StartBlock(secIniL[i], secIniL[i].showFold);
          exit(true);  //sale con TRUE
        end;
      Result := false;  //no abrió
    end;
  end;
  procedure CierraBloqueAct(const bloFinL: array of TFaSynBlock); //inline;
  {Verifica si el bloque más reciente del plegado, está en la lista de bloques
   que cierra "d.bloFinL". De ser así cierra el bloque}
  var i:integer;
      TopBlk: TFaSynBlock;
      eraSec: TFaSynBlock;
  begin
    TopBlk := TopBlock();  //lee bloque superior
    //verifica si estamos en medio de una sección
    eraSec := nil;
    if (TopBlk<>nil) and TopBlk.IsSection then begin //verifica si es bloque de sección
      //es sección, vemos el bloque anterior
      eraSec := TopBlk;  //guarda referencia
      TopBlk := TFaSynBlock(TopCodeFoldBlockType(1));  //lee bloque superior
    end;
    //busca
    for i:=0 to High(bloFinL) do
      if TopBlk = bloFinL[i] then begin  //coincide
        BlkToClose := TopBlk; //marca para cerrar en el siguuiente token
//        EndBlock(TopBlk.showFold);  //cierra bloque
        break;
      end;
    //verifica si cierra debajo de la sección
    if (BlkToClose<>nil) and (eraSec<>nil) then
      //se debe cerrar el bloque debajo de la sección
      EndBlock(eraSec.showFold);  //cierra primero la sección
  end;
begin
  case d.tipDel of
  tdNull: begin       //token que no es delimitador de token
      fTokenID := d.tTok; //no es delimitador de ningún tipo, pone su atributo
      //un delimitador común puede tener plegado de bloque
      if d.bloFin then begin //verifica primero, si es cierre de algún bloque
        CierraBloqueAct(d.bloFinL);  //cierra primero
      end;
      if d.secIni then begin //Verifica primero si es bloque de sección
        if not AbreSeccionAct(d.secIniL) then  //prueba si abre como sección
           if d.bloIni then AbreBloqueAct(d); //verifica como bloque normal
      end else if d.bloIni then  //verifica si abre bloque
        AbreBloqueAct(d);
    end;
  tdUniLin: begin  //delimitador de token de una línea.
      //Se resuelve siempre en la misma línea.
      fTokenID := d.tTok;   //asigna token
      delTok := d.dEnd;   //para que esté disponible al explorar la línea actual.
      folTok := false;    //No tiene sentido el plegado, en token de una línea.
      if posFin=tamLin then exit;  //si está al final, necesita salir con fTokenID fijado.
      d.pRange;  //ejecuta función de procesamiento
    end;
  tdMulLin: begin  //delimitador de token multilínea
      //Se pueden resolver en la línea actual o en las siguientes líneas.
      fTokenID := d.tTok;   //asigna token
      delTok := d.dEnd;    //para que esté disponible al explorar las sgtes. líneas.
      folTok := d.folTok;  //para que esté disponible al explorar las sgtes. líneas.
      if folTok then StartBlock(MulTokBlk, MulTokBlk.showFold);  //abre al inicio del token
      fRange := @d;    //asigna rango apuntando a este registro
      if posFin=tamLin then exit;  //si está al final, necesita salir con fTokenID fijado.
      d.pRange;  //ejecuta función de procesamiento
    end;
  tdConten1: begin  //delimitador de token por contenido 1
      dec(posFin);    //ajusta para que se procese correctamente
      metTokCont1;    //este método se encarga
    end;
  tdConten2: begin  //delimitador de token por contenido 1
      dec(posFin);    //ajusta para que se procese correctamente
      metTokCont2;    //este método se encarga
    end;
  tdConten3: begin  //delimitador de token por contenido 1
      dec(posFin);    //ajusta para que se procese correctamente
      metTokCont3;    //este método se encarga
    end;
  tdConten4: begin  //delimitador de token por contenido 1
      dec(posFin);    //ajusta para que se procese correctamente
      metTokCont4;    //este método se encarga
    end;
  else
    fTokenID := d.tTok; //no es delimitador, solo toma su atributo.
  end;
end;
procedure TSynFacilSyn.ProcIdentEsp(var mat: TArrayTokEspec); //inline;
//Procesa el identificador actual con la matriz indicada
var i: integer;
begin
  repeat inc(posFin)
  until not CharsIdentif[fLine[posFin]];
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := Fline + posIni + 1;  //puntero al identificador + 1
  fTokenID := tkIdentif;  //identificador común
  for i := 0 to High(mat) do begin
    if KeyComp(mat[i])  then begin
      ProcTokenDelim(mat[i]); //verifica si es delimitador
      exit;
    end;
  end;
end;
procedure TSynFacilSyn.metSimbEsp;
//Procesa un caracter que es inicio de símbolo y podría ser origen de un símbolo especial.
var i: integer;
  nCarDisp: Integer;
begin
  fTokenID := tkSymbol;  //identificador inicial por defecto
  //prepara para las comparaciones
  nCarDisp := tamLin-posIni;   //calcula caracteres disponibles hasta fin de línea
  fToIdent := Fline + posIni;  //puntero al identificador. Lo guarda para comparación
  //hay un nuevo posible delimitador. Se hace la búsqueda
  for i := 0 to High(mSym) do begin  //se empieza con los de mayor tamaño
    //fijamos nuevo tamaño para comaprar
    fStringLen := length(mSym[i].txt);  //suponemos que tenemos esta cantidad de caracteres
    if fStringLen > nCarDisp then continue;  //no hay suficientes, probar con el siguiente
    if KeyComp(mSym[i]) then begin
      //¡Es símbolo especial!
      inc(posFin,fStringLen);  //apunta al siguiente token
      ProcTokenDelim(mSym[i]); //verifica si es delimitador
      exit;   //sale con el atributo asignado
    end;
  end;
  {No se encontró coincidencia.
   Ahora debemos continuar la exploración al siguiente caracter}
  posFin := posIni + 1;  //a siguiente caracter, y deja el actual como: fTokenID := tkSymbol
end;
//************** funciones rápidas para la tabla de métodos ****************
procedure TSynFacilSyn.metUniLin1;
//Procesa tokens de una sola línea y con delimitadores iguales y de un solo caracter.
begin
  fTokenID := fAtriTable[carIni];   //lee atributo
  Inc(posFin);  {no hay peligro en incrmentar porque siempre se llama "metUniLin1" con
                 el carcater actual <> #0}
  while posFin <> tamLin do begin
    if fLine[posFin] = carIni then begin //busca fin de cadena
      Inc(posFin);
      if (fLine[posFin] <> carIni) then break;  //si no es doble caracter
    end;
    Inc(posFin);
  end;
end;
procedure TSynFacilSyn.metFinLinea;
//Procesa tokens de una sola línea que va hasta el fin de línea.
begin
  fTokenID := fAtriTable[carIni];   //lee atributo
  Inc(posFin);  {no hay peligro en incrmentar porque siempre se llama "metFinLinea" con
                 el caracter actual <> #0}
  posFin := tamLin;  //salta rápidamente al final
end;
procedure TSynFacilSyn.metSym1Car;
//Procesa tokens símbolo de un caracter de ancho.
begin
  fTokenID := fAtriTable[carIni];   //lee atributo
  Inc(posFin);  //pasa a la siguiente posición
end;
//****** funciones llamadas por puntero y/o en medio de rangos  *************
procedure TSynFacilSyn.ProcFinLinea;
//Procesa hasta encontrar el fin de línea.
begin
  posFin := tamLin;  //salta rápidamente al final
end;
procedure TSynFacilSyn.ProcRangeEndSym;
{Procesa la línea actual buscando un delimitador símbolo (delBlk).
 Si lo encuentra pone fRange a NIL. El tipo de token, debe estar ya asignado.}
var p: PChar;
begin
  //busca delimitador final
  p := strpos(fLine+posFin,PChar(delTok));
  if p = nil then begin   //no se encuentra
     posFin := tamLin;  //apunta al fin de línea
  end else begin  //encontró
     posFin := p + length(delTok) - fLine;
     fRange := nil;               //no necesario para tokens Unilínea
     if folTok then BlkToClose := MulTokBlk; //marca para cerrar en el siguuiente token
  end;
end;
procedure TSynFacilSyn.ProcRangeEndSym1;
{Procesa la línea actual buscando un delimitador símbolo de un caracter.
 Si lo encuentra pone fRange a NIL. El tipo de token, debe estar ya asignado.}
var p: PChar;
begin
  //busca delimitador final
  p := strscan(fLine+posFin,delTok[1]);
  if p = nil then begin   //no se encuentra
     posFin := tamLin;  //apunta al fin de línea
  end else begin  //encontró
     posFin := p + 1 - fLine;
     fRange := nil;              //no necesario para tokens Unilínea
     if folTok then BlkToClose := MulTokBlk; //marca para cerrar en el siguuiente token
  end;
end;
procedure TSynFacilSyn.ProcRangeEndIden;
{Procesa la línea actual buscando un delimitador identificador (delBlk).
 Si lo encuentra pone fRange a rsUnknown. El tipo de token, debe estar ya asignado.}
var p: Pchar;
    c1, c2: char;
begin
  //busca delimitador final
  p := strpos(fLine+posFin,PChar(delTok));
  while p <> nil do begin   //definitivamente no se encuentra
    //verifica si es inicio de identificador
    c1:=(p-1)^;  {Retrocede. No debería haber problema en retroceder siempre, porque se supone que
           se ha detectado el delimitador inicial, entonces siempre habrá al menos un caracter}
    c2:=(p+length(delTok))^;   //apunta al final, puede ser el final de línea #0
    if (c1 in car_ini_iden) or CharsIdentif[c1] or CharsIdentif[c2] then begin
      //está en medio de un identificador. No es válido.
      p := strpos(p+length(delTok),PChar(delTok));  //busca siguiente
    end else begin  //es el identificador buscado
      posFin := p + length(delTok) - fLine;  //puede terminar apuntándo a #0
      fRange := nil;               //no necesario para tokens Unilínea
      if folTok then BlkToClose := MulTokBlk; //marca para cerrar en el siguuiente token
      exit;
    end;
  end;
  //definitívamente no se encuentra
  posFin := tamLin;  //apunta al fin de línea
end;

procedure TSynFacilSyn.AddIniBlockToTok(dStart: string; TokPos: integer; blk: TFaSynBlock);
  //Agrega a un token especial, la referencia a un bloque, en la parte inicial.
var n: integer;
    tok : TPtrTokEspec;
begin
  VerifDelim(dStart);
  if Err <> '' then exit;
  CreaBuscEspec(tok, dStart, TokPos); //busca o crea
  if Err<>'' then exit; //puede haber error
  //agrega referencia
  tok^.bloIni:=true;
  n:=High(tok^.bloIniL)+1;  //lee tamaño
  setlength(tok^.bloIniL,n+1);  //aumenta
  tok^.bloIniL[n]:=blk;  //escribe referencia
end;
procedure TSynFacilSyn.AddFinBlockToTok(dEnd: string; TokPos: integer; blk: TFaSynBlock);
  //Agrega a un token especial, la referencia a un bloque, en la parte final.
var n: integer;
    tok : TPtrTokEspec;
begin
  VerifDelim(dEnd);
  if Err <> '' then exit;
  CreaBuscEspec(tok, dEnd, TokPos); //busca o crea
  if Err<>'' then exit; //puede haber error
  //agrega referencia
  tok^.bloFin:=true;
  n:=High(tok^.bloFinL)+1;  //lee tamaño
  setlength(tok^.bloFinL,n+1);  //aumenta
  tok^.bloFinL[n]:=blk;  //escribe referencia
end;
procedure TSynFacilSyn.AddIniSectToTok(dStart: string; TokPos: integer; blk: TFaSynBlock);
//Agrega a un token especial, la referencia a una sección.
var n: integer;
    tok : TPtrTokEspec;
begin
  VerifDelim(dStart);
  if Err <> '' then exit;
  CreaBuscEspec(tok, dStart, TokPos); //busca o crea
  if Err<>'' then exit; //puede haber error
  //agrega referencia
  tok^.secIni:=true;
  n:=High(tok^.secIniL)+1;  //lee tamaño
  setlength(tok^.secIniL,n+1);  //aumenta
  tok^.secIniL[n]:=blk;  //escribe referencia
end;
procedure TSynFacilSyn.AddFirstSectToTok(dStart: string; TokPos: integer; blk: TFaSynBlock);
//Agrega a un token especial, la referencia a una sección.
var n: integer;
    tok : TPtrTokEspec;
begin
  VerifDelim(dStart);
  if Err <> '' then exit;
  CreaBuscEspec(tok, dStart, TokPos); //busca o crea
  if Err<>'' then exit; //puede haber error
  //agrega referencia
  tok^.firstSec := blk; //agrega referencia
end;
function TSynFacilSyn.CreateBlock(blkName: string; showFold: boolean = true;
                                  parentBlk: TFaSynBlock = nil): TFaSynBlock;
//Crea un bloque en el resaltador y devuelve una referencia al bloque creado.
var blk : TFaSynBlock;
begin
  Result := nil;    //valor por defecto
  //if blkName = '' //No se verifica el nombre del bloque
  //Crea bloque
  blk:= TFaSynBlock.Create;
  blk.name     :=blkName;     //nombre de bloque
  blk.index    :=lisBlocks.Count; //calcula su posición
  blk.showFold := showFold;   //inidca si se muestra la marca de plegado
  blk.parentBlk:= parentBlk;  //asigna bloque padre
  blk.BackCol  := clNone;     //inicialmente sin color
  blk.IsSection:= false;
  blk.UniqSec  := false;
  lisBlocks.Add(blk);        //agrega a lista
  Result := blk;             //devuelve referencia
end;
function TSynFacilSyn.AddBlock(dStart, dEnd: string; showFold: boolean = true;
                               parentBlk: TFaSynBlock = nil): TFaSynBlock;
{Función pública para agregar un bloque a la sintaxis. Si encuentra error, sale con
 el mensaje en "Err"}
var blk : TFaSynBlock;
begin
  Result := nil;    //valor por defecto
  //Crea bloque
  blk:= CreateBlock('',showFold,parentBlk);
  Result := blk;           //devuelve referencia
  //procesa delimitador inicial
  AddIniBlockToTok(dStart, 0, blk);  //agrega referencia
  if Err<>'' then exit; //puede haber error
  //procesa delimitador final
  AddFinBlockToTok(dEnd, 0, blk);  //agrega referencia
  if Err<>'' then exit; //puede haber error
end;
function TSynFacilSyn.AddSection(dStart: string; showFold: boolean = true;
                                 parentBlk: TFaSynBlock = nil): TFaSynBlock;
{Función pública para agregar una sección a un bloque a la sintaxis. Si encuentra error,
 sale con el mensaje en "Err"}
var blk : TFaSynBlock;
begin
  Result := nil;    //valor por defecto
  //verificaciones
  if parentBlk = nil then begin
    parentBlk := MainBlk;  //NIL significa que es válido en el bloque principal
  end;
  //Crea bloque
  blk:= CreateBlock('',showFold,parentBlk);
  blk.IsSection:=true;
  Result := blk;           //devuelve referencia
  //procesa delimitador inicial
  AddIniSectToTok(dStart, 0, Blk);  //agrega referencia
  if Err<>'' then exit; //puede haber error
end;
function TSynFacilSyn.AddFirstSection(dStart: string; showFold: boolean = true;
                                      parentBlk: TFaSynBlock = nil): TFaSynBlock;
{Función pública para agregar una sección que se abre siempre al inicio de un bloque. Si
 encuentra error, sale con el mensaje en "Err"}
var blk : TFaSynBlock;
    tok : TPtrTokEspec;
    n: integer;
begin
  Result := nil;    //valor por defecto
  //Una sección es también un bloque. Crea bloque
  blk:= CreateBlock('',showFold,parentBlk);
  blk.IsSection:=true;
  Result := blk;           //devuelve referencia
  //procesa delimitador inicial
  AddFirstSectToTok(dStart, 0, blk);
//  if Err<>'' then exit; //puede haber error
end;
//funciones para obtener información de bloques
function TSynFacilSyn.NestedBlocks: Integer;
//Devuelve la cantidad de bloques anidados en la posición actual. No existe un contador
//en el resaltador para este valor (solo para bloques con marca de pleagdo visible).
var
  Fold: TSynCustomCodeFoldBlock;
begin
  Result:=-1;  //para compensar el bloque que se crea al inicio
  if (CodeFoldRange<>nil) then begin
    Fold := CodeFoldRange.Top;
    while Fold <> nil do begin
//if Fold.BlockType = nil then debugln('--NIL') else debugln('--'+TFaSynBlock(Fold.BlockType).name);
      inc(Result);
      Fold := Fold.Parent;
    end;
  end;
end;
function TSynFacilSyn.NestedBlocksBegin(LineNumber: integer): Integer;
//Devuelve la cantidad de bloques anidados al inicio de la línea.
var
  Fold: TSynCustomCodeFoldBlock;
begin
  if LineNumber = 0 then  //primera línea
    Result := 0
  else begin
    SetRange(CurrentRanges[LineNumber - 1]);
    Result := NestedBlocks;
  end;
end;
function TSynFacilSyn.TopCodeFoldBlock(DownIndex: Integer): TFaSynBlock;
//Función pública para TopCodeFoldBlockType() pero no devuelve puntero.
begin
  Result := TFaSynBlock(TopCodeFoldBlockType(DownIndex));
end;
function TSynFacilSyn.SetHighlighterAtXY(XY: TPoint): boolean;
//Pone al resaltador en una posición específica del texto, como si estuviera
//haciendo la exploración normal. Así se puede leer el estado.
//La posición XY, empieza en (1,1). Si tuvo exito devuelve TRUE.
var
  PosX, PosY: integer;
  Line: string;
  Start: Integer;
begin
  Result := false;  //valor por defecto
  //validaciónes
  PosY := XY.Y -1;
  if (PosY < 0) or (PosY >= CurrentLines.Count) then exit;
  PosX := XY.X;
  if (PosX <= 0) then exit;
  Line := CurrentLines[PosY];
  //validación
{  if PosX >= Length(Line)+1 then begin
    //Está al final o más. Simula el estado al final de la línea
    //Este bloque se puede quitar
    SetLine(Line);
    SetRange(CurrentRanges[PosY]);   //carga estado de rango al final
    fTokenId := tkEol;        //marca final
    posFin := length(Line)+1;
    posIni := posFin;
    //posTok := ??? no se puede regenerar sin explorar
    Result := TRUE;
    exit;
  end;}
  //explora línea
  StartAtLineIndex(PosY);   //posiciona y hace el primer Next()
  while not GetEol do begin
    Start := GetTokenPos + 1;
    if (PosX >= Start) and (PosX < posFin+1) then begin
      //encontró
      //Token := GetToken;  //aquí se puede leer el token
      Result := TRUE;
      exit;
    end;
    Next;
  end;
  //No lo ubicó. Está más allá del fin de línea
  Result := TRUE;
end;
function TSynFacilSyn.ExploreLine(XY: TPoint; out toks: TATokInfo;
                                  out CurTok: integer): boolean;
//Explora la línea en la posición indicada. Devuelve la lista de tokens en toks[].
//También indica el orden del token actual.
//La posición XY, empieza en (1,1). Si tuvo exito devuelve TRUE.
var
  PosX, PosY: integer;
  Line: string;
  tam: Integer;
begin
  Result := false;  //valor por defecto
  CurTok :=-1;       //valor por defecto
  tam := 0;          //tamaño inicial
  setlength(toks,tam);  //inicia
  //validaciónes
  PosY := XY.Y -1;
  if (PosY < 0) or (PosY >= CurrentLines.Count) then exit;
  PosX := XY.X;
  if (PosX <= 0) then exit;
  Line := CurrentLines[PosY];
  //explora línea
  StartAtLineIndex(PosY);   //posiciona y hace el primer Next()
  while not GetEol do begin
    //hay token
    setlength(toks, tam+1);  //crea espacio
    toks[tam].TokPos:=tam;
    toks[tam].txt := GetToken;
    toks[tam].TokTyp:=fTokenID;
    toks[tam].posIni:=PosIni;
    toks[tam].curBlk := TopCodeFoldBlock(0);  //lee el rango
    Inc(tam);  //actualiza tamaño

    if (PosX > PosIni) and (PosX < posFin+1) then begin
      //encontró
      CurTok := tam-1;  //devuelve índice del token
      Result := TRUE;
    end;
    Next;
  end;
  //agrega el token final
  setlength(toks, tam+1);  //crea espacio
  toks[tam].TokPos:=tam;
  toks[tam].txt := GetToken;
  toks[tam].TokTyp:=fTokenID;
  toks[tam].posIni:=PosIni;
  toks[tam].curBlk := TopCodeFoldBlock(0);  //lee el rango
  Inc(tam);  //actualiza tamaño
  //verifica si lo ubicó.
  if CurTok = -1 then begin
    //No lo ubicó. Está más allá del fin de línea
    CurTok := tam-1;  //devuelve índice del token
    Result := TRUE;
  end;
end;
function TSynFacilSyn.SearchBeginBlock(level: integer; PosY: integer): integer;
//Busca en la linea "PosY", el inicio del bloque con nivel "level". Si no lo encuentra
//en esa línea, devuelve -1, indicando que debe estar en la línea anterior.
var
  niv1, niv2: Integer;   //niveles anterior y posterior
  ultApert : integer;    //posición de última apertura
begin
  ultApert := -1; //valor por defecto
  niv1 := NestedBlocksBegin(PosY); //Verifica el nivel al inicio de la línea
  //explora línea
  StartAtLineIndex(PosY);   //posiciona y hace el primer Next()
  while not GetEol do begin
    niv2 := NestedBlocks;   //lee nivel después de hacer Next()
    if (niv1 < level) and (niv2>=level) then begin
      ultApert:= posIni+1;   //último cambio de nivel que incluye al nivel pedido (posición inicial)
    end;
    niv1 := niv2;
    Next;
  end;
  //Terminó de explorar.
  Result := ultApert;
end;
function TSynFacilSyn.SearchEndBlock(level: integer; PosY: integer): integer;
//Busca en la linea "PosY", el fin del bloque con nivel "level". Si no lo encuentra
//en esa línea, devuelve MAXINT, indicando que debe estar en la línea siguiente.
var
  niv1, niv2: Integer;   //niveles anterior y posterior
begin
  Result := MAXINT; //valor por defecto
  niv1 := NestedBlocksBegin(PosY); //Verifica el nivel al inicio de la línea
  //explora línea
  StartAtLineIndex(PosY);   //posiciona y hace el primer Next()
  while not GetEol do begin
    niv2 := NestedBlocks;   //lee nivel después de hacer Next()
    if (niv1 >= level) and (niv2 < level) then begin
      Result := posIni+1; //cambio de nivel que incluye al nivel pedido
      exit;       //ya tiene los datos requeridos
    end;
    niv1 := niv2;
    Next;
  end;
  //Terminó de explorar y no encontró el cierre de blqoue.
  //hace la verificación del último token
  niv2 := NestedBlocks;   //lee nivel después del último Next()
  if (niv1 >= level) and (niv2 < level) then begin
    Result:= posIni+1; //cambio de nivel que incluye al nivel pedido
    exit;       //ya tiene los datos requeridos
  end;
  //Ya verificó el último token y no encontró el cierre. Sale com MAXINT
end;
procedure TSynFacilSyn.SearchBeginEndBlock(level: integer; PosX, PosY: integer;
                                      out pIniBlock, pEndBlock: integer);
//Explora una línea y devuelve el punto en la línea en que se abre y cierra el bloque de la
//posición PosX. "level" debe indicar el nivel del bloque buscado.
//Si no encuentra el inicio del bloque en la línea, devuelve -1
var
  niv1, niv2: Integer;   //niveles anterior y posterior
  Despues: boolean;      //bandera para indicar si se alcanzó al token
begin
  pIniBlock := -1; //valor por defecto
  pEndBlock := MAXINT;  //valor por defecto
  Despues := false;
  niv1 := NestedBlocksBegin(PosY); //Verifica el nivel al inicio de la línea
  //explora línea
  StartAtLineIndex(PosY);   //posiciona y hace el primer Next()
  while not GetEol do begin
    niv2 := NestedBlocks;   //lee nivel después de hacer Next()
    //verifica cambio de nivel
    if Despues then begin  //ya pasó al token actual
      if (niv1 >= level) and (niv2 < level) then begin
        pEndBlock:= posIni+1; //cambio de nivel que incluye al nivel pedido
        exit;       //ya tiene los datos requeridos
      end;
    end else begin        //aún no pasa al token actual
      if (niv1 < level) and (niv2>=level) then begin
        pIniBlock:= posIni+1;   //último cambio de nivel que incluye al nivel pedido (posición inicial)
      end;
    end;
    //verifica
    if (PosX >= posIni + 1) and (PosX < posFin+1) then begin
      //llegó a la posición pedida
      Despues := true;
//      exit;    //Sale con el último "pIniBlock"
    end;
    niv1 := niv2;
    Next;
  end;
  //terminó de explorar la línea y no encontró el cierre de bloque
  if Despues then begin  //ya pasó al token actual, pero no encontró el cierre
    //hace la verificación del último token
    niv2 := NestedBlocks;   //lee nivel después del último Next()
    if (niv1 >= level) and (niv2 < level) then begin
      pEndBlock:= posIni+1; //cambio de nivel que incluye al nivel pedido
      exit;       //ya tiene los datos requeridos
    end;
  end else begin      //aún no pasa al token actual
    //No lo ubicó. PosX está más allá del fin de línea. Sale con el último "pIniBlock"
  end;
end;
function TSynFacilSyn.GetBlockInfoAtXY(XY: TPoint; out blk: TFaSynBlock;
                                       out level: integer): boolean;
//Da información sobre el bloque en la posición indicada.
begin
  SetHighlighterAtXY(XY);        //posiciona
  blk := TopBlock();  //lee bloque
  //level := CodeFoldRange.CodeFoldStackSize; no considera los que tienen IncreaseLevel=FALSE
  level := NestedBlocks;
end;
function TSynFacilSyn.GetBlockInfoAtXY(XY: TPoint; out blk: TFaSynBlock;
  out BlockStart: TPoint; out BlockEnd: TPoint): boolean;
//Da información sobre el bloque en la posición indicada. Si hay error devuelve FALSE.
//BlockStart y BlockEnd, tienen sus coordenadas empezando en 1.
var
  nivel: Integer;
//  PosY: integer;
begin
  Result := SetHighlighterAtXY(XY);        //posiciona
  if Result=false then begin  //hubo error
    blk := nil;
    exit;
  end;
  blk := TopBlock();  //lee bloque
  //busca coordenadas del bloque
  nivel := NestedBlocks;   //ve el nivel actual
  BlockStart.y := XY.y;
  BlockEnd.y := XY.y;
  SearchBeginEndBlock(nivel, XY.x, BlockStart.y-1,BlockStart.x, BlockEnd.x);
  //busca posición de inicio
  if BlockStart.x = -1 then begin  //no se encontró en la línea actual
    while (BlockStart.y>1) do begin
      Dec(BlockStart.y);  //busca en la anterior
      BlockStart.x := SearchBeginBlock(nivel, BlockStart.y-1);
      if BlockStart.x<>-1 then break;  //encontró
    end;
  end;
  //busca posición de fin de bloque
  if BlockEnd.x = MAXINT then begin  //no se encontró en la línea actual
    while (BlockEnd.y < CurrentLines.Count) do begin
      Inc(BlockEnd.y);  //busca en la anterior
      BlockEnd.x := SearchEndBlock(nivel, BlockEnd.y-1);
      if BlockEnd.x<>MAXINT then break;  //encontró
    end;
//    if BlockEnd.x = MAXINT then   //llegó al final, y no encontró el final
//      BlockEnd.x := length(CurrentLines[BlockEnd.y-1])+1;
  end;
end;

function TSynFacilSyn.GetXY: TPoint;
//Devuelve las coordenadas de la posicón actual de exploración.
//El inicio del texto inicia en (1,1)
begin
  Result.x:=posIni+1;  //corrige
  Result.y:=lineIndex;  //aquí se guarda
end;

// ******************** métodos OVERRIDE ********************//
procedure TSynFacilSyn.SetLine(const NewValue: String; LineNumber: Integer);
{Es llamado por el editor, cada vez que necesita actualizar la información de coloreado
 sobre una línea. Despues de llamar a esta función, se espera que GetTokenEx, devuelva
 el token actual. Y también después de cada llamada a "Next".}
begin
  inherited;
  fLine := PChar(NewValue); //solo copia la dirección para optimizar
//debugln('SetLine('+ IntToStr(LineNumber)+'): ' + fLine );
  tamLin := length(NewValue);
  posTok := 0;  //inicia contador
  posFin := 0;  //apunta al primer caracter
  BlkToClose := nil;   //inicia bandera
  Next;
end;
procedure TSynFacilSyn.Next;
{Es llamado por SynEdit, para acceder al siguiente Token. Y es ejecutado por cada token de la
 línea en curso.
 En nuestro caso "posIni" debe quedar apuntando al inicio del token y "posFin" debe
 quedar apuntando al inicio del siguiente token o al caracter NULL (fin de línea).}
begin
  //verifica si hay cerrado de bloque pendiente del token anterior
  if BlkToClose<>nil then begin
    EndBlock(BlkToClose.showFold);
    BlkToClose := nil;
  end;
  Inc(posTok);  //lleva la cuenta del orden del token

  posIni := posFin;   //apunta al primer elemento
  if fRange = nil then begin
      carIni:=fLine[posFin]; //guardar para tenerlo disponible en el método que se va a llamar.
      fProcTable[carIni];    //Se ejecuta la función que corresponda.
  end else begin
    if posFin = tamLin then begin  //para acelerar la exploración
      fTokenID:=tkEol; exit;
    end;
    {Debe actualizar el estado del rango porque las líneas no necesariamente se exploran
     consecutivamente}
    fTokenID:=fRange^.tTok;  //tipo de token
    delTok := fRange^.dEnd;  //delimitador de rango
    folTok := fRange^.folTok; //bandera para cerrar plegado
    fRange^.pRange;   //ejecuta método
  end;
end;
function TSynFacilSyn.GetEol: Boolean;
begin
  Result := fTokenId = tkEol;
end;
procedure TSynFacilSyn.GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
begin
  TokenLength := posFin - posIni;
  TokenStart := FLine + posIni;
end;
function TSynFacilSyn.GetTokenAttribute: TSynHighlighterAttributes;
{Debe devolver el atributo para el token actual. El token actual se actualiza con
 cada llamada a "Next", (o a "SetLine", para el primer token de la línea.)
 Esta función es la que usa SynEdit para definir el atributo del token actual}
var topblk: TFaSynBlock;
begin
  Result := fTokenID;  //podría devolver "tkEol"
  if Result<> nil then begin
    //verifica coloreado de bloques
    case ColBlock of
    cbLevel: begin  //pinta por nivel
        Result.Background:=RGB(255- CodeFoldRange.CodeFoldStackSize*25,255- CodeFoldRange.CodeFoldStackSize*25,255);
      end;
    cbBlock: begin  //pinta por tipo de bloque
        topblk := TopBlockOpac;  //bloque con color
        //asigna color
        Result.Background:=topblk.BackCol;
      end;
    end;
  end;
end;
function TSynFacilSyn.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
{Este método es llamado por la clase "TSynCustomHighlighter", cuando se accede a alguna de
 sus propiedades:  CommentAttribute, IdentifierAttribute, KeywordAttribute, StringAttribute,
 SymbolAttribute o WhitespaceAttribute.}
begin
  case Index of
    SYN_ATTR_COMMENT   : Result := tkComment;
    SYN_ATTR_IDENTIFIER: Result := tkIdentif;
    SYN_ATTR_KEYWORD   : Result := tkKeyword;
    SYN_ATTR_WHITESPACE: Result := tkSpace;
    SYN_ATTR_STRING    : Result := tkString;
    SYN_ATTR_SYMBOL    : Result := tkSymbol;
    else Result := nil;
  end;
end;
function TSynFacilSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := posFin - posIni;
  SetString(Result, (FLine + posIni), Len);
end;
function TSynFacilSyn.GetTokenPos: Integer;
begin
  Result := posIni;
end;
function TSynFacilSyn.GetTokenKind: integer;
begin
  Result := PtrUInt(fTokenId);
end;
{Implementación de las funcionalidades de rango}
procedure TSynFacilSyn.ResetRange;
begin
  inherited;
  fRange := nil;
end;
function TSynFacilSyn.GetRange: Pointer;
begin
  CodeFoldRange.RangeType := fRange;
  Result := inherited GetRange;
  //debugln('  GetRange: ' + fLine + '=' + IntToStr(Integer(fRange)) );
end;
procedure TSynFacilSyn.SetRange(Value: Pointer);
begin
//debugln(' >SetRange: ' + fLine + '=' + IntToStr(PtrUInt(Value)) );
  inherited SetRange(Value);
  fRange := CodeFoldRange.RangeType;
end;
function TSynFacilSyn.NewTokType(TypeName: string): TSynHighlighterAttributes;
//Crea un nuevo atributo y lo agrega al resaltador.
//No hay funciones para eliminar atributs creados.
begin
  Result := TSynHighlighterAttributes.Create(TypeName);
  AddAttribute(Result);   //lo registra
end;
procedure TSynFacilSyn.CreateAttributes;
//CRea los atributos por defecto
begin
  //Elimina todos los atributos creados, los fijos y los del usuario.
  FreeHighlighterAttributes;
  { Crea los atributos que siempre existirán. }
  tkEol     := NewTokType('Eol');      //atributo de nulos
  tkSymbol  := NewTokType('Symbol');   //atributo de símbolos
  tkSpace   := NewTokType('Space');    //atributo de espacios.
  tkIdentif := NewTokType('Identifier'); //Atributo para identificadores.
  tkNumber  := NewTokType('Number');   //atributo de números
  tkNumber.Foreground := clFuchsia;
  tkKeyword := NewTokType('Key');      //atribuuto de palabras claves
//  tkKeyword.Style := [fsBold];
  tkKeyword.Foreground:=clGreen;
  tkString  := NewTokType('String');   //atributo de cadenas
  tkString.Foreground := clBlue;
  tkComment := NewTokType('Comment');  //atributo de comentarios
  tkComment.Style := [fsItalic];
  tkComment.Foreground := clGray;
end;
constructor TSynFacilSyn.Create(AOwner: TComponent);
var
  i: Integer;
begin
  inherited Create(AOwner);
  CaseSensitive := false;
  fRange := nil;     //inicia rango

  ClearSpecials;     //Inicia matrices
  CreateAttributes;  //crea los atributos
  lisBlocks:=TFaListBlocks.Create(true);  //crea lista de bloques con control
  //Crea bloque global
  MainBlk   := TFaSynBlock.Create;
  MainBlk.name:='Main';   //Nombre especial
  MainBlk.index:=-1;
  MainBlk.showFold:=false;
  MainBlk.parentBlk:=nil;  //no tiene ningún padre
  MainBlk.BackCol:=clNone;
  MainBlk.UniqSec:=false;
  //Crea bloque para tokens multilínea
  MulTokBlk  := TFaSynBlock.Create;
  MulTokBlk.name:='MultiToken';
  MulTokBlk.index:=-2;
  MulTokBlk.showFold:=true;  //Dejar en TRUE, porque así trabaja
  MulTokBlk.parentBlk:=nil;
  MulTokBlk.BackCol:=clNone;
  MulTokBlk.UniqSec:=false;

  ClearMethodTables;   //Crea tabla de funciones
  DefTokIdentif('[A..Za..z$_]','A..Za..z0123456789_');
end;
destructor TSynFacilSyn.Destroy;
begin
  MulTokBlk.Free;
  MainBlk.Free;
  lisBlocks.Free;            //libera
  //no es necesario destruir los attrributos, porque  la clase ya lo hace
  inherited Destroy;
end;

end.

