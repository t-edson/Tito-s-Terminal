{**********************************************************************************
                                      uPreBasicos
Unidad con las definiciones y funciones básicas para el tratamiento de los errores
y contextos del pre-procesador PreSQL.
Un contexto es una abstracción de datos materializada en una estructura que
permite almacenar texto, generalmente destinado a ser preprocesado por el PreSQL.
En el contexto se tiende considera siempre, el salto de línea como si fuera
un sólo caracter porque se lee con una sola llamada a las funciones VerCar() y
CogCar().
En el tratamiento del contexto, se asume que todas las líneas, excepto la
última, tienen un caracter FIN_LIN como delimitador final.

Esta unidad se ha adaptado del código Visual Basic del PreSQL 1.3.
                                          Adaptado Por Tito Hinostroza  23/08/2013
***********************************************************************************
}
unit uPreBasicos;   {$mode objfpc}{$H+}
interface

uses  Classes, SysUtils, Fgl;

Const
  FIN_LIN = #13;   //Fin de línea
  FIN_CON = #0;    //Fin de contexto

  //Tipos de contextos
  TC_ARC = 0 ;     //contexto de tipo archivo
  TC_TXT = 1 ;     //contexto de tipo texto
Type
  //Tipo de operando
  TPTipOper = (TIP_DES,    //tipo desconocido
               TIP_NUM,    //tipo número
               TIP_CAD);    //tipo cadena

  //Categoría para clasificar a los operandos
  TPCatOper = (COP_VACIO, //Operando nulo
//    COP_VARPUNTO, //Variable Punto
    COP_DEFINIC,    //es una variable (definición)
    COP_FUNCION,     //Es una función
    COP_CONST,       //Es una constante
    COP_EXPRESION);  //Es resultado de una expresión

  //Tipo expresión. Se usa para manejo de evaluación aritmética.

  { Texpre }

  Texpre = object      //Tipo expresión
    txt: String;      //Texto de la expresión
    tip: TPTipOper;    //Tipo de dato que devuelve la expresión
    cat: TPCatOper;   //Categoría de expresión
//      uop: String ;   //último operador que se ejecutó de la expresión
  private
    fTxt: String;    //Valor numérico de la expresión
    fNum: Single;    //Valor numérico de la expresión
    procedure FijTxt(txt0: string);
    function LeeTxt: string;
    procedure FijNum(n0: single);
    function LeeNum: single;
    function LeeFec: TDateTime;
  public
    def : pointer;   //referencia a la definición (en caso de que lo sea)
    property valTxt: string read LeeTxt write FijTxt;
    property valNum: single read LeeNum write FijNum;
    property valFec: TDateTime read LeeFec;
  End;

  //ID para categorizar a los tokens
  TtkTokenKind = (tkComment, tkIdentifier, tkKey, tkNull, tkNumber, tkSpace, tkString,
       tkUnknown, tkMacro);

  TContexto = class;

  {Posición dentro de un contexto. A diferecnia de "Tcontexto", es un registro y siempre
   guardará una copia permanente. Además no guarda el texto del contexto}
  TPosCont = record
    arc   : String    ;     //Nombre de archivo
    fil   : LongInt   ;     //Fila
    col   : Integer   ;     //Columna
    nlin  : LongInt   ;     //Número de líneas
    fCon  : TContexto;      //Referencia al Contexto
  End;

  { TPError }
  {Define al objeto PError, el que se usa para tratar los errores del preprocesador. Solo se
   espera que haya uno de estos objetos, por eso se ha declarado como OBJECT}
  TPError = object
  private
    numER : Integer;   //codigo de error
    arcER :  String;   //nombre de archivo que origino el error
    fil : integer;     //número de línea del error
    col : integer;     //número de columna del error
  public
    cadError :  String;   //cadena de error
    NombPrograma: string;  //Usado para poner en el encabezado del mensaje
    procedure IniError;
    procedure GenError(num: Integer; msje : String; archivo: String = '';  nlin: integer = 0);
    procedure GenError(msje: String; posCon: TPosCont);
    function GenTxtError: string;
//    procedure MosError;
    function ArcError: string;
    function nLinError: longint;
    Function nColError: longint;
    function HayError: boolean;
  end;

  { TContexto }
  {Estructura que define a un objeto contexto. Se usa tanto para leer la entrada como para
   escribir en la salida.}
  TContexto = class
    tip      : integer;
    arc      : String;      //nombre de archivo
    fil      : LongInt;     //fila actual
    col      : Integer;     //columna actual
    nlin     : LongInt;     //Número de líneas del Contexto
    lin      : TStringList; {Líneas de texto. Se almacena en TStringList porque es rápida la
                            carga desde un archivo y porque es compatible con el almacenamiento
                            en el Control Editor.}
    constructor Create;
    destructor Destroy; override;
    //Métodos de lectura
    Function IniCont:Boolean;
    Function FinCont:Boolean;
    Function VerCar:Char;
    Function CogCar:Char;
    Function VerCarAnt: Char;
    Function VerCarSig: Char;
    Function CapBlancos:Boolean;

    //Métodos de escritura
    procedure CurPosIni;
    procedure CurPosFin;
    procedure PonSalto;           //Agrega Salto de línea
    procedure SacLinea;           //quita la última línea
    procedure PonCar(c: char);    //Agrega caracter
    procedure PonCad(s: String);  //Agrega cadena
    procedure SacCar;             //Quita un caracter
    //Métodos de llenado/lectura
    function LeeCad: string;          //Lee el contenido del contexto
    procedure FijCad(cad : string);   //Fija el contenido del contexto con cadena
    procedure FijArc(arc0: string);   //Fija el contenido del contexto con archivo
  End;

  //Define una lista de Contextos
  TListaCont = specialize TFPGObjectList<TContexto>;

  { TPPro }

  TPPro = object
  private
    Function LeePosContAct: TPosCont;
    procedure FijPosContAct(pc:TPosCont);
    function LeeCadSal: String;
    procedure FijCadSal(cad: string);
  public
    constructor Create;
    destructor Destroy; //override;
    procedure Iniciar;   //Prepara la secuencia de preprocesamiento
    //rutinas de entrada
    procedure NuevoContexEntTxt(txt: string; arc0: String);
    procedure NuevoContexEntArc(arc0: String);
    procedure QuitaContexEnt;   //quita contexto de entrada actual
    //rutinas basicas de lectura
    Function IniCont:Boolean;
    Function FinCont:Boolean;
    Function VerCar: Char;
    Function VerCarN(numcar:Integer): String;
    Function CogCar:Char;
//    Function VerCarAnt:Char;
    Function CapBlancos:Boolean;
    function Capturar(cap: String): Boolean;
    property PosAct: TPosCont read LeePosContAct write FijPosContAct;
    //rutinas avanzadas de lectura
    Function VerIdentificador:String;
    Function VerIdentifM:String;  //VE identificador en mayúscula
    Function VerPalabra():String;
    Function VerElemento():String;
    Function CogIdentificador:String;
    function CogIdentificador(var ide, ideM: string; var uc: char): boolean;
    function CogIdentificador(var ideM: string): boolean;
    Function cogPalabra():String;
    Function CogElemento():String;
    Function CogNumero:Single;
    Function CogNumero(var n:Single):boolean;
    Function CogCadena:String;
    Function CogCadena(var s: string):boolean;
    Function coger_ruta():String;
    function TipoSigToken: TtkTokenKind;  //Devuelve el tipo del siguiente token
    Function VerSiEsComentario():Boolean;
    Function CogerHastaFinLinea():String;
    Function CogerHastaComent():String;
    Function VerHastaFinLinea():String;
    function CogerComent: boolean;
    function CogerLista(lista: TStringList; delims: string): string;
    function cogOperador: String;           //coge operador
    function jerOp(oper: String): Integer;  //jerarquía de operador
    function Evaluar(Op1: Texpre; opr: String; Op2: Texpre): Texpre;

    //rutinas de salida
    procedure NuevoContexSal;   //Crea nuevo contexto de salida actual
    procedure QuitaContexSal;   //quita contexto de salida actual
    procedure PonCar(c: char);    //Agrega caracter
    procedure Escribe(palabra: string);
    procedure EscribeSalto;
    procedure SacCar;
    procedure GenArchivo(ArcSal0: string);  //Genera archivo de salida
    function TextSalida: string;  //Devuelve el texto preprocesado
    property cadenaSal: String read LeeCadSal write FijCadSal;   //Cadena se salida del contexto actual
  private
    ConsE: TListaCont;      //Lista de contextos de entrada
    ConsS: TListaCont;      //Lista de contextos de salida
    //Variables del Contexto actual
    cEnt : TContexto;   //referencia al contexto de entrada actual
    cSal : TContexto;   //referencia al contexto de salida actual
  end;

var
  PErr : TPError;   //Objeto de Error
  PPro : TPPro;     //Objeto Pre-Procesador

////////////////////////////////////////////////////////////////////////////////////////////
implementation
//caracteres iniciales  válidos para idntificador
{ TODO : Debe desaparecer porque debe poder identificarse el token en la función "TipoSiguienteToken" }
const CAR_INI_IDENT    = ['$','a'..'z','A'..'Z','_'];   //No se incluye 'ñ'
//caracteres válidos para idntificador
const CAR_IDENT       = ['$','a'..'z','A'..'Z','_','0'..'9'];  //No se incluye 'ñ'
  //caracteres válidos para idntificador
const CAR_VAL_PALABRA = ['$','a'..'z','A'..'Z','_','0'..'9','.'];  //¿'ñ'?

{ Texpre }

procedure Texpre.FijTxt(txt0: string);
//Fija valor de texto de un operando
begin
  tip := TIP_CAD;  //se fija como cadeana, de otra forma no podría recibir este valor
  fTxt := txt0;
end;

function Texpre.LeeTxt: string;
//Lee la variable como texto
begin
  if tip = TIP_CAD then  //si ya es texto, la lectura es directa
    Result := ftxt
  else if tip = TIP_NUM then //Si es numérico, se hace una transformación
    //siempre se podrá transformar
    Result := FloatToStr(fNum)   //pero no deja de ser numérico
  else
    Result := '';
end;

procedure Texpre.FijNum(n0: single);
begin
  tip := TIP_NUM;  //se fija como número, de otra forma no podría recibir este valor
  fNum := n0;
end;

function Texpre.LeeNum: single;
begin
  if tip = TIP_CAD then begin //si es texto, se hace una transformación
    //puede que no se pueda transformar
    if not TryStrToFloat(trim(ftxt), Result) then  //pero no deja de ser texto
      PErr.GenError( 1, 'Número inválido.')
  end else if tip = TIP_NUM then //Si ya es numérico, la lectura es directa
    Result := fNum
  else
    Result := 0;
end;

function Texpre.LeeFec: TDateTime;
begin
  if tip = TIP_CAD then begin  //si es texto, se hace una transformación
    //puede que no se pueda transformar
    ftxt := trim(ftxt);
    if not TryStrToDateTime(ftxt, Result) then  //pero no deja de ser texto
      PErr.GenError( 1, 'Fecha inválida.')
  end else if tip = TIP_NUM then //Si ya es numérico, la lectura es directa
    Result := fNum
  else
    Result := 0;
end;

  { TPPro }
constructor TPPro.Create;
begin
  //Crea lista de Contextos
  ConsE := TListaCont.Create(true);  //crea contenedor de Contextos, con control de objetos.
  cEnt := nil;
  ConsS := TListaCont.Create(true);  //crea contenedor de Contextos con control.
  cSal := nil;
end;
destructor TPPro.Destroy;
begin
  //Limpia lista de Contextos
  ConsE.Free;
  //Limpia Contextos de salida
  ConsS.Free;
end;
procedure TPPro.Iniciar;
//Inicia la maquinaria de manejo de Contextos
begin
  ConsE.Clear;       //elimina todos los Contextos de entrada
  ConsS.Clear;       //elimina
end;
procedure TPPro.NuevoContexEntTxt(txt: string; arc0: String);
//Crea un Contexto a partir de una cadena.
//Fija el Contexto Actual "cEnt" como el Contexto creado.
begin
  cEnt := TContexto.Create; //crea Contexto
  ConsE.Add(cEnt);      //Registra Contexto
  cEnt.FijCad(txt);     //inicia con texto
  cEnt.arc := arc0;     {Se guarda el nombre del archivo actual, solo para poder procesar
                           las funciones $NOM_ACTUAL y $DIR_ACTUAL}
  cEnt.CurPosIni;       //posiciona al inicio
end;
procedure TPPro.NuevoContexEntArc(arc0: String);
//Crea un Contexto a partir de un archivo. Devuelve el manejador del Contexto
//Fija el Contexto Actual "cEnt" como el Contexto creado.
begin
  If not FileExists(arc0)  Then  begin  //ve si existe
      PErr.GenError( 1, 'No se encuentra archivo: ' + arc0);
      Exit;
  end;
  cEnt := TContexto.Create; //crea Contexto
  ConsE.Add(cEnt);      //Registra Contexto
  cEnt.FijArc(arc0);    //inicia con archivo
  cEnt.CurPosIni;       //posiciona al inicio
end;
procedure TPPro.QuitaContexEnt;
//Elimina el contexto de entrada actual. Deja apuntando al anterior en la misma posición.
begin
  if ConsE.Count = 0 then exit;  //no sep uede quitar más
  ConsE.Delete(ConsE.Count-1);
  if ConsE.Count = 0 then
    cEnt := nil
  else  //apunta al último
    CEnt := ConsE[ConsE.Count-1];
end;

function TPPro.LeePosContAct: TPosCont;
//Devuelve Contexto actual y su posición
begin
    Result.fCon := cEnt;
    if cEnt = nil then begin
      //aún no hay Contexto definido
      Result.fil  := 1;
      Result.col  := 1;
      Result.arc  := '';
      Result.nlin := 0;
    end else begin
      Result.fil  := cEnt.fil;
      Result.col  := cEnt.col;
      Result.arc  := cEnt.arc;
      Result.nlin := cEnt.nlin;
    end;
End;
procedure TPPro.FijPosContAct(pc:TPosCont);
//Fija Contexto actual y su posición
begin
    cEnt := pc.fCon;
    if cEnt = nil then begin
      //no tiene un Contexto actual
//      filAct := 1;
//      colAct := 1;
//      cEnt.arc := '';
//      nlin := 0;
    end else begin
      cEnt.fil := pc.fil;
      cEnt.col := pc.col;
      cEnt.arc := pc.arc;
      cEnt.nlin := pc.nlin;
    end;
End;
function TPPro.LeeCadSal: String;
//Devuelve la cadena equivalente del contexto de salida actual
begin
   Result := cSal.LeeCad;
end;
procedure TPPro.FijCadSal(cad: string);
//Fija la cadena equivalente del contexto de salida actual
begin
   cSal.FijCad(cad);
end;
//********************************************************************************
//Funciones Básicas de acceso al Contexto actual. Todo acceso al Contexto actual
//debe hacerse a través de estas funciones por seguridad.
//********************************************************************************
function TPPro.IniCont: Boolean;
//Devuelve verdadero si se está al inicio del Contexto actual (fila 1, columna 1)
begin
    Result := cEnt.IniCont;
End;
function TPPro.FinCont: Boolean;
//Devuelve verdadero si se ha pasado del final del Contexto actual
begin
    Result := cEnt.FinCont;
End;
function TPPro.VerCar: Char;
//Devuelve el caracter actual a partir de la posición actual, del Contexto actual.
//Si no hay texto en el Contexto actual o si se ha llegado al final del
//texto, devuelve FIN_CON.
//Si está al final de una línea devuelve siempre "FIN_LIN"
begin
   Result := cEnt.VerCar;
End;
function TPPro.VerCarN(numcar: Integer): String;
//Devuelve los N caracteres a partir de la posición actual, del Contexto actual.
//Si no hay texto en el Contexto actual o si se ha llegado al final del
//texto, devuelve FIN_CON.
//Si está al final de una línea devuelve siempre "FIN_LIN"
var linact:String;
begin
    If FinCont Then Exit(FIN_CON);
    linact := cEnt.lin[cEnt.fil-1];    //línea actual
    If cEnt.col = Length(linact) + 1 Then begin
        //Se está al fin de la línea. Se considera que cada línea
        //tiene un salto de línea al final, excepto la última línea.
        //En este caso siempre se devuelve FIN_LIN
        Result := FIN_LIN
    end Else       //No se está al fin de la línea
        Result := copy(linact, cEnt.col, numcar);
End;
function TPPro.CogCar: Char;
//Devuelve el caracter actual del Contexto actual e incrementa
//el puntero a la siguiente posición.
//La siguiente posición del fin de una línea es el caracter "salto de
//línea", que son en realidad dos caracteres.
begin
  Result :=cEnt.CogCar;
End;
{Function TPPro.VerCarAnt: Char;
//echa un vistazo al caracter anterior del Contexto
//Si no hay caracter anterior, devuelve cadena vacía
Var linact:String;
begin
    Result := #0;
    If cEnt.FinCont Then Exit;     //Realmente debería devolver el caracter final
    If IniCont Then Exit;        //No hay caracter anterior
    linact := cEnt.lin[cEnt.fil-1];    //línea actual
    If cEnt.col = 1 Then
        //Está al inicio de una línea
        Result := FIN_LIN     //devuelve el salto anterior
    Else
        Result := linact[cEnt.col-1];
End;}
function TPPro.CapBlancos: Boolean;
//Coge los blancos iniciales del contexto de entrada.
//Si no encuentra algun blanco al inicio, devuelve falso
begin
    Result := cEnt.CapBlancos;
End;
function TPPro.Capturar(cap: String): Boolean;
//coge la cadena dada ignorando los blancos iniciales.
Var i:Integer;
begin
    Result := False;
    cEnt.CapBlancos;     //quita blancos iniciales
    i := 1;
    While Not cEnt.FinCont And (i <= Length(cap)) do begin
        If cEnt.VerCar = cap[i] Then begin
            cEnt.CogCar;
            i := i + 1;
        end Else
            Exit;     //fallo en algun caracter
    End;
    If i > Length(cap) Then    //encontró toda la cadena
        Capturar := True;
End;

//********************************************************************************
//Funciones de mayor nivel para acceso al Contexto actual.
//********************************************************************************
function TPPro.VerIdentificador: String;
//devuelve una palabra correspondiente a un identificador
//empieza a buscar desde el principio
Var col0:Integer;
begin
    col0 := cEnt.col;
    VerIdentificador := CogIdentificador;
    cEnt.col := col0;
End;
function TPPro.VerIdentifM: String;
//Devuleve el dientificador en mayúscula
begin
  Result := UpCase(VerIdentificador);
end;
function TPPro.VerPalabra: String;
//devuelve una palabra correspondiente a un identificador
//empieza a buscar desde el principio
Var ncolTmp:Integer;
begin
    ncolTmp := cEnt.col;
    VerPalabra := cogPalabra;
    cEnt.col := ncolTmp;
End;
function TPPro.VerElemento: String;
//devuelve una palabra correspondiente a un identificador
//empieza a buscar desde el principio
Var fil0, col0: integer;
begin
    col0 := cEnt.col;  //guarda todo el contexto, porque "CogElemento", puede cambiar de línea
    fil0 := cEnt.fil;
    VerElemento := CogElemento;
    cEnt.col := col0;  //recupera
    cEnt.fil := fil0;
End;
function TPPro.CogIdentificador: String;
//Coge una palabra correspondiente a un identificador desde la posicion actual del
//contexto.
Var temp:String;
    car1, car: char;
begin
    Result := '';     //no hay identificador inicialmente
    //CapBlancos;     //no debe eliminar espacios
    temp := '';
    car1 := VerCar;    //lee caracter inicial
    If FinCont Then Exit;        //Fin de Contexto
    If Not (car1 in CAR_INI_IDENT) Then     //primer caracter valido
       Exit;     //no es identificador
    temp += CogCar;     //acumula
    //busca hasta encontar fin de identificador
    car := VerCar;
    While car in CAR_IDENT do begin
       if (car = '$') then  begin  //verifica regla de nombre de identif.
          //verifica si es delimitador o inicio de otro identificador
          if (car1='$') then   //es delimitador
             temp += CogCar;     //acumula
          break;
       end;
       temp += CogCar;     //acumula
       car := VerCar;
    end;
    //se llego al final del archivo
    Result := temp      //copia hasta el final
End;
function TPPro.CogIdentificador(var ide, ideM: string; var uc:char): boolean;
{Versión que lee el identificador normal y en mayúscula. Si no encuentra ningún identificador
 devuelve FALSE. Devuelve además el último caracter leido antes del identificador (uc).}
begin
   if TipoSigToken = tkIdentifier then begin
      uc := cEnt.VerCarAnt;  //lee caracter anterior
      ide := CogIdentificador();
      ideM := UpCase(ide);  //en mayúscula
      exit(true);  //sale con TRUE
   end else  //no hay identificador
      exit(false);
end;

function TPPro.CogIdentificador(var ideM: string): boolean;
//Versión sencilal que devuelve el identificador en mayúscula
begin
   if TipoSigToken = tkIdentifier then begin
      ideM := UpCase(CogIdentificador());  //en mayúscula
      exit(true);  //sale con TRUE
   end else  //no hay identificador
      exit(false);
end;

function TPPro.cogPalabra: String;
//coge una palabra completa (alfanumerico y punto decimal)
//desde la posicion donde se encuentra el archivo
Var temp:String;
    car:char;
begin
    cogPalabra := '';  //no hay identificador inicialmente
    CapBlancos;        //quita blancos iniciales
    temp := '';
    car := VerCar;
    If car = '' Then Exit;
    If Not (car in CAR_VAL_PALABRA) Then      //primer caracter valido
        Exit;        //no es identificador
    temp := temp + CogCar;     //acumula
    //busca hasta encontrar fin de identificador
    While VerCar <> '' do begin
        car := VerCar;
        If car in CAR_VAL_PALABRA Then begin
            CogCar;           //toma el caracter
            temp += car;     //acumula
        end Else begin
            cogPalabra := temp;     //copia el identificador
            Exit;
        End;
    end;
    //se llego al final del archivo
    cogPalabra := temp;     //copia hasta el final
End;
function TPPro.CogElemento: String;
{Toma un elemento de una cadena. El elemento puede ser un identificador,
 un símbolo o una frase. Los elementos se separan por caracteres "blancos".
 Por ejemplo, la cadena:
   casa 1 'nueva casa'
 Tiene 3 elementos: "casa", "1" y "nueva casa".}
Var temp:String;
    car:char;
begin
    CapBlancos;     //quita blancos iniciales
    If cEnt.VerCar = '''' Then       //Inicio de cadena
        Result := CogCadena
    Else begin
        temp := '';
        While cEnt.VerCar <> '' do begin
            car := cEnt.VerCar;
            If not (car in [' ',#9,FIN_LIN, FIN_CON]) Then begin
                cEnt.CogCar;         //toma el caracter
                temp += car;    //acumula
            end Else begin
                Result := temp; //copia el identificador
                Exit;
            End;
        end;
        //se llego al final del archivo
        Result := temp;     //copia hasta el final
    End;
End;
function TPPro.CogNumero: Single;
{Coge una cifra numerica, del contexto actual, desde la posicón actual.
 Primero elimina los blancos. Si no encuentra algún caracter numérico al inicio, o el
 signo menos, sale }
begin
    CogNumero(Result);
End;

function TPPro.CogNumero(var n: Single): boolean;
Var car:char;
    temp:String;
begin
    Result :=  false ;     //no hay numero
    CapBlancos;
    car := cEnt.VerCar;
    If Not (car in ['0'..'9','.','-']) Then      //primer caracter no valido
       Exit;        //no es numero
    if (car in ['.','-']) and not (cEnt.VerCarSig in ['0'..'9']) then
       Exit;    //no es válido
    temp := cEnt.CogCar;   //acumula primer dígito
    //busca hasta encontar fin de identificador
    While cEnt.VerCar in ['0'..'9','.'] do begin
      car := cEnt.CogCar;     //toma el caracter
      temp += car;     //acumula
    end;
    //se llego al final del número
    n := StrToFloat(temp);     //copia hasta el final
    Result := true;  //indica que hubo número
end;

function TPPro.CogCadena: String;
begin
   CogCadena(Result);
End;
function TPPro.CogCadena(var s: string): boolean;
{Coge una constante de tipo cadena (entre apóstrofos) desde la posicion
 donde se encuentra el archivo, hasta el delimitador o fin de línea.
 Si no encuentra una cadena, devuelve FALSE}
Var car : char;
begin
    PErr.IniError;
    Result := false;     //no hay cadena
    CapBlancos;     //quita blancos iniciales
    s := '';
    car := cEnt.VerCar;
    If car <> '''' Then   //primer caracter no valido
        Exit;        //no es constante cadena
    cEnt.CogCar;     //toma el caracter
    Result := true;    //indica que se encontró cadena
    //busca hasta encontar fin de identificador
    While not(cEnt.VerCar in [FIN_LIN, FIN_CON]) do begin
        car := cEnt.CogCar;
        If car <> '''' Then begin
            s += car;     //acumula
        end Else begin
            Exit;
        End;
    end;
    //se llego al final del archivo
    PErr.GenError('No se encontro fin de cadena', PosAct);
end;

function TPPro.coger_ruta: String;
//Coge una cadena que representa la ruta de un archivo (con o sin apóstrofos)
//desde la posicion donde se encuentra el archivo
Var temp:String;
    car:String;
begin
    PErr.IniError;
    coger_ruta := '';     //no hay cadena
    CapBlancos;     //quita blancos iniciales
    temp := '';
    car := VerCar;
    If car = '' Then Exit;
    If car = '''' Then begin    //ruta en formato de cadena
        temp := CogCadena;
        If PErr.HayError Then Exit;
        coger_ruta := temp;
        Exit;       //no es constante cadena
    end Else begin
        //busca hasta encontar blanco (espacio o salto de línea, o tab)
        While Not FinCont And Not (VerCar in [' ',#9,FIN_LIN]) do
            temp += CogCar;     //acumula
        Result := temp;     //copia
        //se llego al final del archivo
//        GenError 1, "No se encontro fin de cadena", ArcActual, filAct
    End;
End;
function TPPro.TipoSigToken: TtkTokenKind;
//Identifica el token que inicia en la posición actual.
begin
   case VerCar of
    '$','a'..'z','A'..'Z','_': Result := tkIdentifier;
   else
     Result := tkUnknown;
   end;
end;
function TPPro.VerSiEsComentario: Boolean;
//devuelve verdad si la posicion actual del archivo de entrada corresponde
//al inicio de un comentario. No Filtra blancos iniciales ni salta lineas
var cad: string[2];
begin
    VerSiEsComentario := False;
    cad := VerCarN(2);
    Result  := (cad = '--') or (cad = '/*');
End;
function TPPro.CogerHastaFinLinea: String;
//coge una cadena correspondiente a los caracteres desde el punto actual hasta el fin de la linea
Var temp:String;
begin
    temp := '';
    While Not cEnt.FinCont And (cEnt.VerCar <> FIN_LIN) do
        temp += cEnt.CogCar;
    cEnt.CogCar;     //Coge el fin de línea
    //se llego al final del archivo o al fin de linea
    Result := temp;     //copia hasta el final
End;
function TPPro.CogerHastaComent: String;
//Coge texto hasta encontrar el inicio de un comentario o un salto de línea
var linact  : string;
    i,j, min: integer;
begin
  linact := cEnt.lin[cEnt.fil-1];    //línea actual
  //busca posiicón de comentario
  min := length(linact)+1;  //valor inicial
  i := Pos('--',linAct);
  if i<>0 then min := i;   //primer valor
  j := Pos('/*',linAct);
  if j < cEnt.col then j := 0;  //comentarios anteriores (/* ... */), se ignoran.
  if j<>0 then  //hay otro
    if j < min then min := j;   //compara valor
  //toma los caracteres necesarios
  Result := Copy(linAct,cEnt.col,min-cEnt.col);  //copia hasta el final
  cEnt.col := min;  //pone kasta posición leida
  if min = length(linact) + 1 then CogCar;     //Coge el fin de línea
end;
function TPPro.CogerComent: boolean;
{Coge un comantario, de tipo /* .. */. Debe llamarse cuando se ha detectado
 el inicio de este comentario. Puede coger varias líneas.}
begin
  Result := false;
  while not FinCont  do begin
    if cEnt.CogCar = '*' then begin
      //puede ser delimitador final
      if cEnt.VerCar = '/' then begin
        cEnt.CogCar;   //toma el delimitador
        Result := true;
        exit;   //sale
      end;
    end;
  end;
end;
function TPPro.CogerLista(lista: TStringList; delims: string): string;
{Estrae una lista de elementos del contexto actual, hasta encontrar uno de los
 delimitadores indicados en "delims". Si termina por encontrar un delimitador,
 devuelve el delimitador encontrado (siempre en mayúscula). Los delimitadores
 deben indicarse separados por coma, sin esapcios entre ellos}
var tmp: string;
    l_delims : TstringList;
begin
  Result:='';
  l_delims := TStringList.Create;  //crea lista
  l_delims.Delimiter:=',';
  l_delims.DelimitedText:=delims;  //descompone lista
{ --VERSIÓN SIN COGER ELEMENTO
  tmp := VerElemento;  //toma primero
  While Not FinCont do begin
     If l_delims.IndexOf(tmp) <> -1 Then  //busca delimitador
       begin Result:= tmp; break end;   //encontro delimitador, sale.
     lista.add(CogElemento);         //agrega elemento
     tmp := VerElemento;    //toma siguiente
  end;}
  repeat
    tmp := CogElemento;    //toma siguiente
    if tmp = '' then break;  //es fin de contexto, porque CogElemento toma cualquier cosa
    If l_delims.IndexOf(tmp) <> -1 Then begin  //busca delimitador
       Result:= Upcase(tmp); break; //encontro delimitador, sale.
    end;
    lista.add(tmp);         //agrega elemento
  until Cent.FinCont;
  //aquí puede haber llegado por fin de contexto o por haber encontrado
  //algún delimitador.
  l_delims.Free;
end;

function TPPro.VerHastaFinLinea: String;
//Devuelve una cadena correspondiente a los caracteres desde el punto actual hasta el fin de
//la linea. Empieza a buscar desde el principio.
Var nfilTmp:LongInt;
    ncolTmp:Integer;
begin
    nfilTmp := cEnt.fil;
    ncolTmp := cEnt.col;
    VerHastaFinLinea := CogerHastaFinLinea;
    cEnt.fil := nfilTmp;     //devuelve el numero de linea inicial
    cEnt.col := ncolTmp;
End;
//********************************************************************************
//Funciones para manejo de la salida
//********************************************************************************
procedure TPPro.NuevoContexSal;
//Crea un nuevo contexto de salida y pone cursor al inicio.
begin
  //Crea Contexto de salida
  cSal := TContexto.Create;
  ConsS.Add(cSal);   //Registra Contexto
  cSal.FijCad('');   //Iniicia cadena y posiciona cursor al final
end;
procedure TPPro.QuitaContexSal;
//Elimina el contexto de salida actual. Deja apuntando al anterior en la misma posición.
begin
  if ConsS.Count = 0 then exit;  //no sep uede quitar más
  ConsS.Delete(ConsS.Count-1);
  if ConsS.Count = 0 then
    cSal := nil
  else  //apunta al último
    CSal := ConsS[ConsS.Count-1];
end;

procedure TPPro.PonCar(c: char);
begin
  cSal.PonCar(c);
end;
procedure TPPro.Escribe(palabra: string);
//Escribe un palabra en el archivo de salida. Este debe ser el único punto
//de acceso al archivo de salida.
begin
  cSal.PonCad(palabra);
end;
procedure TPPro.EscribeSalto;
//Escribe un salto de línea en el archivo de salida.
begin
  cSal.PonSalto;
end;
procedure TPPro.SacCar;
//Quita un caracter del dispositivo de salida, borrando la información previamente escrita.
begin
  cSal.SacCar;
end;
procedure TPPro.GenArchivo(ArcSal0: string);
//Genera el archivo de salida
begin
  if ArcSal0 = '' then exit;   //protección
  cSal.lin.SaveToFile(ArcSal0);
end;

function TPPro.TextSalida: string;
begin
  Result := cSal.lin.Text;
end;

function TPPro.cogOperador: String;
{Coge un operador en la posición del contexto actual. Si no encuentra
 devuelve cadena vacía y no coge caracteres, salvo espacios iniciales.}
begin
  cogOperador := '';
  CapBlancos;     //quita blancos iniciales
  Case VerCar of //completa con operador de más caracteres
  '+': begin
         Result := CogCar;
//           If VerCar = '+' Then begin CogCar; Result := '++' end;
//           If VerCar = '=' Then begin CogCar; Result := '+=' end;
        end;
  '-': begin
         Result := CogCar;
//           If VerCar() = '-' Then begin CogCar; Result := '--' end;
//           If VerCar() = '=' Then begin CogCar; Result := '-=' end;
      end;
  '*': begin
        Result := CogCar;
//          If VerCar() = '=' Then begin CogCar; Result := '*=' end;
      end;
  '/': begin
        Result := CogCar;
//          If VerCar() = '=' Then begin CogCar; Result := '/=' end;
      end;
//    '=': begin
//          Result := CogCar;
//          If VerCar() = '=' Then begin CogCar; Result := '==' end;
//          If VerCar() = '<' Then begin CogCar; Result := '=<' end;     //operador 'menor'
//          If VerCar() = '>' Then begin CogCar; Result := '=>' end;     //operador 'mayor'
//        end;
//    '>': begin
//          Result := CogCar;
//          If VerCar() = '=' Then begin CogCar; Result := '>=' end;
//          If VerCar() = '>' Then begin CogCar; Result := '>>' end;
//          If VerCar() = '+' Then begin CogCar; Result := '>+' end;
//          If VerCar() = '-' Then begin CogCar; Result := '>-' end;
//        end;
//    '<': begin
//          Result := CogCar;
//          If VerCar() = '=' Then begin CogCar; Result := '<=' end;
//          If VerCar() = '>' Then begin CogCar; Result := '<>' end;
//          If VerCar() = '<' Then begin CogCar; Result := '<<' end;
//        end;
//    '|': begin
//          Result := CogCar;
//          If VerCar() = '|' Then begin CogCar; Result := '||' end;    //OR
//          If VerCar() = '!' Then begin CogCar; Result := '|!' end;    //XOR
//        end;
//    '~': begin                            //operador LIKE
//          Result := CogCar;
//        end;
//    '&': begin
//          Result := CogCar;
//          If VerCar = '&' Then begin CogCar; Result := '&&' end;     //AND
//        end;
  End;
End;

function TPPro.jerOp(oper: String): Integer;
//Devuelve la jerarquía de un operador ver documentación técnica.
begin
    Case oper of
//    '>>', '<<', '>+', '>-': jerOp = 1: Exit Function
//    '=': jerOp := 2;
//    '&&', '||', '!', '|!': jerOp := 3;
//    '==', '<>', '>', '>=', '<', '<=', '~': jerOp := 4;
    '+', '-'{, '|', '&'}: jerOp := 5;
    '*', '/'{, '\', '%'}: jerOp := 6;
//    '=<', '=>': jerOp := 7;
//    '^', '++', '--', '+=', '-=', '*=', '/=': jerOp := 8;
    Else jerOp := 0;
    End;
End;
function TPPro.Evaluar(Op1: Texpre; opr: String; Op2: Texpre): Texpre;
//Devuelve el resultado y tipo de una operación
begin
    PErr.IniError;
    Evaluar.cat := COP_EXPRESION;    //ahora es expresión por defecto
    Case opr of
    '': begin     //Sin operador. Y se supone sin Op2
          //no hay nada que hacer, ya está en la pila
          Evaluar := Op1;
        end;
{    '=': begin    //Asignación
           If Op1.cat = COP_DEFINIC Then begin  //Asignación a una variable
//              Evaluar.val := Op2.val;
//              Evaluar.tip := Op2.tip;
             Op1 := Op2;
             tDefi Op1.def:=;
             Evaluar:= Op1
           end Else
             Perr.GenError('Sólo se puede asignar valor a una variable', PosAct);
         end;}
    '+': begin
          Evaluar.valNum := Op1.valNum + Op2.valNum;  //Fuerza a Evaluar.tip := TIP_NUM
         end;
    '-': begin
          Evaluar.valNum := Op1.valNum - Op2.valNum;
         end;
    '*': begin
          Evaluar.valNum := Op1.valNum * Op2.valNum;
         end;
    '/': begin
          If Op2.valNum = 0 Then
              Perr.GenError('No se puede dividir por cero.', PosAct)
          Else begin   //error
              Evaluar.valNum := Op1.valNum / Op2.valNum;
          End;
         end;
{    '\': begin
          If val(Op2.val) = 0 Then
              Perr.GenError('No se puede dividir por cero.', PosAct);
          Else begin   //error
              Evaluar.val := val(Op1.val) \ val(Op2.val);
              Evaluar.tip := TIP_NUM;
          End;
         end;
    '%': begin
          If val(Op2.val) = 0 Then
              Perr.GenError('No se puede dividir por cero.', PosAct);
          Else begin    //error
              Evaluar.val := val(Op1.val) Mod val(Op2.val);
              Evaluar.tip := TIP_NUM;
          End;
         end;
    '^': begin
          If val(Op2.val) = 0 And val(Op2.val) = 0 Then
              Perr.GenError('No se puede Evaluar 0^0', PosAct);
          Else begin   //error
              Evaluar.val := val(Op1.val) ^ val(Op2.val);
              Evaluar.tip := TIP_NUM;
          End;
         end;
    '++': begin       //mono-operando, sólo Op1
          Op1.val := val(Op1.val) + 1  //incrementa
          Evaluar.val := Op1.val;
          Evaluar.tip := TIP_NUM;
         end;
    '--': begin       //mono-operando
          Op1.val := val(Op1.val) - 1  //decrementa
          Evaluar.val := Op1.val;
          Evaluar.tip := TIP_NUM;
    //operadores de comparación
         end;
    '==': begin
          If Op1.val := Op2.val Then
              Evaluar.val := 1
          Else    //error
              Evaluar.val := 0
          Evaluar.tip := TIP_NUM
         end;
    '<>': begin
          If Op1.val <> Op2.val Then
              Evaluar.val := 1
          Else    //error
              Evaluar.val := 0
          Evaluar.tip := TIP_NUM
         end;
    '>': begin
          If Op1.val > Op2.val Then
              Evaluar.val := 1
          Else    //error
              Evaluar.val := 0
          Evaluar.tip := TIP_NUM
         end;
    '<': begin
          If Op1.val < Op2.val Then
              Evaluar.val := 1
          Else    //error
              Evaluar.val := 0
          Evaluar.tip := TIP_NUM
         end;
    '>=': begin
          If Op1.val >= Op2.val Then
              Evaluar.val := 1
          Else    //error
              Evaluar.val := 0
          Evaluar.tip := TIP_NUM
         end;
    '<=': begin
          If Op1.val <= Op2.val Then
              Evaluar.val := 1
          Else    //error
              Evaluar.val := 0
          Evaluar.tip := TIP_NUM
         end;
    '|': begin    //concatenación de cadenas
          Evaluar.val := Op1.val & Op2.val
          Evaluar.tip := TIP_CAD
         end;
    '~': begin    //comparación de cadenas
          If (Op1.val Like Op2.val) Then
              Evaluar.val := 1
          Else    //no cuadra
              Evaluar.val := 0
          Evaluar.tip := TIP_NUM
         end;
    '&&': begin   //And lógico
          If (val(Op1.val) = 1 And val(Op2.val) = 1) Then
              Evaluar.val := 1
          Else    //no cuadra
              Evaluar.val := 0
          Evaluar.tip := TIP_NUM
         end;
    '||': begin
          If (val(Op1.val) = 0 And val(Op2.val) = 0) Then
              Evaluar.val := 0
          Else    //no cuadra
              Evaluar.val := 1
          Evaluar.tip := TIP_NUM
         end;
    '!': begin
          If val(Op1.val) = 1 Then
              Evaluar.val := 0
          Else    //no cuadra
              Evaluar.val := 1
          Evaluar.tip := TIP_NUM
         end;}
    Else begin
        Perr.GenError('No se reconoce operador: ' + opr, PosAct);
        Exit;
         End;
    end;
    //Completa campos de evaluar
    Evaluar.txt := Op1.txt + opr + Op2.txt;   //texto de la expresión
//    Evaluar.uop := opr;   //última operación ejecutada
End;


  { TPError }
procedure TPError.IniError;
begin
  numER := 0;
  cadError := '';
  arcER := '';
  fil := 0;
  col := 0;
end;
procedure TPError.GenError(num: Integer; msje: String; archivo: String;
  nlin: integer = 0);
//Genera un error
begin
  numER := num;
  cadError := msje;
  arcER := archivo;
  fil := nlin;
end;
procedure TPError.GenError(msje: String; posCon: TPosCont);
//Genera un error en la posición indicada
begin
  numER := 1;
  cadError := msje;
  arcER := posCon.arc;
  fil := posCon.fil;
  col := posCon.col;
end;
function TPError.GenTxtError: string;
//Genera una cadena con el mensaje de error de acuerdo al nivel de detalle que tenga.
begin
  Result :=cadError;
  If arcER <> '' Then begin  //agrega información de archivo
    Result += LineEnding + arcER;
  end;
  If fil <> 0 Then begin       //Hay número de línea
//    Result := Pchar('[' + arcER + ']: ' + cadError + ' Línea: ' + IntToStr(fil);
    Result += LineEnding + '(' +IntToStr(fil) + ',' + IntToStr(col) + ') ';
  end;
end;
{procedure TPError.MosError;
//Muestra un mensaje de error
begin
   writeln(TxtError);  No debe ser dependiente del tipo de Aplicación
end;}
function TPError.ArcError: string;
//Devuelve el nombre del archivo de error
begin
  ArcError := arcER;
end;
function TPError.nLinError: longint;
//Devuelve el número de línea del error
begin
  nLinError := fil;
end;
function TPError.nColError: longint;
//Devuelve el número de línea del error
begin
  nColError := col;
end;
function TPError.HayError: boolean;
begin
  HayError := numER <> 0;
end;

{ TContexto }
//********************************************************************************
//Funciones Básicas para administración de los Contextos
//********************************************************************************
constructor TContexto.Create;
begin
inherited;   //solo se pone por seguridad, ya que no es necesario.
  lin := TStringList.Create;    //crea lista de cadenas para almacenar el texto
  nlin := 0;
  CurPosFin;   //inicia fil y col
end;
destructor TContexto.Destroy;
begin
  lin.Free;     //libera lista
  inherited Destroy;
end;
function TContexto.IniCont: Boolean;
//Devuelve verdadero si se está al inicio del Contexto (fila 1, columna 1)
begin
    Result := (fil = 1) And (col = 1);
end;
function TContexto.FinCont: Boolean;
//Devuelve verdadero si se ha pasado del final del Contexto actual
begin
  //Protección a Contexto vacío
  If nlin = 0 Then begin
      Result := True;
      Exit;
  End;
  //Verifica optimizando verificando primero la condición más probable
  If fil < nlin Then
      Result := False
  Else If fil > nlin Then
      Result := True
  Else If fil = nlin Then begin
      //Verifica si estamos en la línea final.
      //OJO, en la línea final no existe un salto de línea adicional
      If col >= Length(lin[fil-1]) + 1 Then
          Result := True
      Else
          Result := False
  End;
end;
function TContexto.VerCar: Char;
//Devuelve el caracter actual
begin
  If FinCont Then Exit(FIN_CON);
  If col = Length(lin[fil-1]) + 1 Then begin
     //Se está al fin de la línea. Se considera que cada línea
     //tiene un salto de línea al final, excepto la última línea.
     //En este caso siempre se devuelve FIN_LIN
     Result := FIN_LIN
  end Else        //No se está al fin de la línea
     Result := lin[fil-1][col];
end;
function TContexto.CogCar: Char;
//Lee un caracter del contexto y avanza el cursor una posición.
begin
   If FinCont Then Exit(FIN_CON);
   If col >= Length(lin[fil-1]) + 1 Then begin
      //Se está al fin de la línea. Trabaja igual que VerCar().
      Result := FIN_LIN;
      col := 1;
      fil := fil + 1;  //Pasa a siguiente fila, puede ser que se
                       //haya pasado la cantidad de líneas disponibles
   end Else begin       //No se está al fin de la línea
      Result := lin[fil-1][col];
      inc(col);
   End;
end;
function TContexto.VerCarAnt: Char;
//echa un vistazo al caracter anterior del Contexto
//Si no hay caracter anterior, devuelve cadena vacía
Var linact:String;
begin
    Result := #0;
    If IniCont Then Exit;        //No hay caracter anterior
    linact := lin[fil-1];    //línea actual
    If col = 1 Then
        //Está al inicio de una línea
        Result := FIN_LIN     //devuelve el salto anterior
    Else
        Result := linact[col-1];
end;
function TContexto.VerCarSig: Char;
//Devuelve el catacter siguiente al actual. OJO: Solo mira la línea actual.
begin
  If FinCont Then Exit(FIN_CON);
  If col >= Length(lin[fil-1])  Then begin
    Result := FIN_LIN
  end Else        //No se está al fin de la línea
    Result := lin[fil-1][col+1];
end;

function TContexto.CapBlancos: Boolean;
//Coge los blancos iniciales del contexto de entrada.
//Si no encuentra algun blanco al inicio, devuelve falso
begin
    Result := False;
    if not (VerCar in [' ', FIN_LIN, #9]) then exit;  //no hay blancos
    repeat
      CogCar
    until FinCont or not (VerCar in [' ', FIN_LIN, #9]);
end;
procedure TContexto.CurPosIni;
//Mueve la posición al inicio del contenido.
begin
  if lin.Count = 0 then begin
    fil := 0; col := 0;
  end else
  begin
    fil := 1;
    col := 1;   //posiciona al inicio
  end;
end;
procedure TContexto.CurPosFin;
//Mueve la posición al final del contenido.
begin
  if lin.Count = 0 then begin
    fil := 0; col := 0;
  end else
  begin
    fil := lin.Count;
    col := length(lin[fil-1])+1;   //posiciona al final
  end;
end;
procedure TContexto.PonSalto;
//Escribe un salto de línea en el contexto
begin
  lin.Add('');
  fil := lin.Count;  //actualiza filas
  col := 1;   //posiciona en primera columna
end;
procedure TContexto.SacLinea;
//Saca la última línea del contexto. Debe haber por lo menos una línea
begin
   if lin.Count = 0 then exit;
   lin.Delete(lin.Count-1);    //elimina última línea
   CurPosFin;   //actualiza posición de cursor
end;
procedure TContexto.PonCar(c: char);
//Escribe un caracter en el contexto. Debe haber por lo menos una línea
begin
   if lin.Count = 0 then  exit; //sin datos
   if c = FIN_LIN then  //caracter de salto de línea
     PonSalto
   else begin //caracter normal
     lin[lin.Count-1] := lin[lin.Count-1] + c;  //agrega a línea actual
     inc(col);   //actualiza columna
   end;
end;
procedure TContexto.PonCad(s: String);
//Escribe una cadena (sin saltos) en el contexto. Debe haber por lo menos una línea
begin
   if lin.Count = 0 then  exit; //sin datos
   lin[lin.Count-1] := lin[lin.Count-1] + s;  //agrega a línea actual
   col += length(s);   //actualiza columna
end;
procedure TContexto.SacCar;
//Quita un caracter del contexto
var n:integer;
begin
   n := lin.Count;
   if n = 0 then  exit; //sin datos
   if (n = 1) and (length(lin[0])=0) then  exit; //sin datos
   //hay datos
   if col = 1 then    //al inicio de línea
     SacLinea
   else begin
     lin[n-1] := copy(lin[n-1],1,col-2);  //recorta
     CurPosFin;   //actualiza posición de cursor
   end;
end;

function TContexto.LeeCad: string;
//Devuelve el contenido del contexto en una cadena.
begin
  Result := lin.text;
end;
procedure TContexto.FijCad(cad: string);
//Fija el contenido del contexto con una cadena.
begin
  tip := TC_TXT;        //indica que contenido es Texto
  if cad='' then begin
    //cadena vacía, crea una línea vacía
    lin.Clear;
    lin.Add('');
    nlin := 1;    //actualiza número de líneas
  end else begin
    lin.Text := cad;
    nlin := lin.Count;    //actualiza número de líneas
  end;
  CurPosFin;   //actualiza posición de cursor
  arc := '';            //No se incluye información de archivo
end;
procedure TContexto.FijArc(arc0: string);
//Fija el contenido del contexto con un archivo
begin
  tip := TC_TXT;        //indica que contenido es Texto
  lin.LoadFromFile(arc0);
  nlin := lin.Count;    //actualiza número de líneas
  CurPosFin;   //actualiza posición de cursor
  arc := arc0;            //No se incluye información de archivo
end;

initialization
   PPro.Create;
finalization
   PPro.Destroy;
end.

