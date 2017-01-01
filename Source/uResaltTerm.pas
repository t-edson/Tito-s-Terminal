{Resaltador de sintaxis sencillo usado para el terminal.
 Se basa en el ejemplo de resaltador con plegado publicado en "La Biblia del SynEdit"

                                     Por Tito Hinostroza 27/06/2014
}
unit uResaltTerm;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Graphics, SynEditHighlighter, SynEditHighlighterFoldBase;
type
  {Clase para la creación de un resaltador}
  TRangeState = (rsUnknown, rsComment);
  //ID para categorizar a los tokens
  TtkTokenKind = (tkIndentif, tkComment, tkKey, tkNull, tkSpace, tkString, tkUnknown,
                  tkPrompt, tkDirect);

  TProcTableProc = procedure of object; //Tipo procedimiento para procesar el
                                        //token por el carácter inicial.
  { TResaltTerm }
  TResaltTerm = class(TSynCustomFoldHighlighter)
  protected
    posIni, posFin: Integer;
    fStringLen: Integer;  //Tamaño del token actual
    fToIdent: PChar;      //Puntero a identificcdor
    linAct   : PChar;
    fProcTable: array[#0..#255] of TProcTableProc; //tabla de procedimientos
    fTokenID : TtkTokenKind;  //Id del token actual
    fRange: TRangeState;
    //define las categorías de los "tokens"
    fAtriIdentif : TSynHighlighterAttributes;
    fAtriComent  : TSynHighlighterAttributes;
    fAtriClave   : TSynHighlighterAttributes;
    fAtriEspac   : TSynHighlighterAttributes;
    fAtriCadena  : TSynHighlighterAttributes;
    fAtriPrompt  : TSynHighlighterAttributes;
    fAtriDirect  : TSynHighlighterAttributes;
  public
    detecPrompt : boolean;    //activa la detección del prompt
    prIni, prFin: string;  //cadena inicial, internedia y final del prompt
    procedure SetLine(const NewValue: String; LineNumber: Integer); override;
    procedure Next; override;
    function  GetEol: Boolean; override;
    procedure GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
              override;
    function  GetTokenAttribute: TSynHighlighterAttributes; override;
    function GetToken: String; override;
    function GetTokenPos: Integer; override;
    function GetTokenKind: integer; override;
    constructor Create(AOwner: TComponent); override;
    function GetDefaultAttribute(Index: integer): TSynHighlighterAttributes; override;
  private
    posTok     : integer;       //para identificar el ordinal del token en una línea
    procedure CommentProc;
    procedure CreaTablaDeMetodos;
    function KeyComp(const aKey: String): Boolean;
    procedure ProcComent;
    procedure ProcIdent;
    procedure ProcNull;
    procedure ProcSpace;
    procedure ProcString;
    procedure ProcUnknown;

    //Funciones de procesamiento de identificadores
    procedure ProcA;
    procedure ProcB;
    procedure ProcC;
    procedure ProcD;
    procedure ProcE;
    procedure ProcF;
    procedure ProcG;
    procedure ProcH;
    procedure ProcI;
    procedure ProcK;
    procedure ProcJ;
    procedure ProcL;
    procedure ProcM;
    procedure ProcP;
    procedure ProcR;
    procedure ProcS;
    procedure ProcT;
    procedure ProcU;
    procedure ProcV;
    procedure ProcW;
    procedure ProcZ;
  public
    function GetRange: Pointer; override;
    procedure SetRange(Value: Pointer); override;
    procedure ResetRange; override;
  end;


implementation
uses FormConfig; //para la detección de prompt
var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable: array[#0..#255] of Integer;

procedure CreaTablaIdentif;
var  i, j: Char;
begin
  for i := #0 to #255 do
  begin
    Case i of
      '_', '0'..'9', 'a'..'z', 'A'..'Z': Identifiers[i] := True;
    else Identifiers[i] := False;
    end;
    j := UpCase(i);
    Case i in ['_', 'A'..'Z', 'a'..'z'] of
      True: mHashTable[i] := Ord(j) - 64
    else
      mHashTable[i] := 0;
    end;
  end;
end;

constructor TResaltTerm.Create(AOwner: TComponent);
//Constructor de la clase. Aquí se deben crear los atributos a usar.
begin
  inherited Create(AOwner);
  //atributo de identificadores
  fAtriIdentif  := TSynHighlighterAttributes.Create('Identif');
  fAtriIdentif.Foreground := clWhite;    //color de letra
  AddAttribute(fAtriIdentif);
  //atributo de comentarios
  fAtriComent  := TSynHighlighterAttributes.Create('Comment');
//  fAtriComent.Style := [fsItalic];     //en cursiva
  fAtriComent.Foreground := clLtGray;    //color de letra gris
  AddAttribute(fAtriComent);
  //atribuuto de palabras claves
  fAtriClave   := TSynHighlighterAttributes.Create('Key');
  fAtriClave.Style := [fsBold];       //en negrita
  fAtriClave.Foreground:=TColor($40D040);;     //color de letra verde
  AddAttribute(fAtriClave);
  //atributo de espacios. Sin atributos
  fAtriEspac   := TSynHighlighterAttributes.Create('space');
  AddAttribute(fAtriEspac);
  //atributo de cadenas
  fAtriCadena  := TSynHighlighterAttributes.Create('String');
  fAtriCadena.Foreground :=  TColor($FFFF00);   //color de letra celeste
  AddAttribute(fAtriCadena);
  //atributo de prompt
  fAtriPrompt  := TSynHighlighterAttributes.Create('Prompt');
  fAtriPrompt.Foreground := clWhite;   //color de letra
  fAtriPrompt.Background:= clGreen;
  AddAttribute(fAtriPrompt);
  //atributo de directorio
  fAtriDirect  := TSynHighlighterAttributes.Create('Direct');
  fAtriDirect.Foreground := clYellow;   //color de letra
  AddAttribute(fAtriDirect);
  //atributo desconocido
//  fAtriDescon  := TSynHighlighterAttributes.Create('Otros');
//  fAtriDescon.Foreground := clYellow;   //color de letra
//  AddAttribute(fAtriDirect);


  CreaTablaDeMetodos;  //Construye tabla de métodos
end;

procedure TResaltTerm.CreaTablaDeMetodos;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '#'    : fProcTable[I] := @ProcComent;
      '"'    : fProcTable[I] := @ProcString;
      'a': fProcTable[I] := @ProcA;
      'b': fProcTable[I] := @ProcB;
      'c': fProcTable[I] := @ProcC;
      'd': fProcTable[I] := @ProcD;
      'e': fProcTable[I] := @ProcE;
      'f': fProcTable[I] := @ProcF;
      'g': fProcTable[I] := @ProcG;
      'h': fProcTable[I] := @ProcH;
      'i': fProcTable[I] := @ProcI;
      'j': fProcTable[I] := @ProcJ;
      'k': fProcTable[I] := @ProcK;
      'l': fProcTable[I] := @ProcL;
      'm': fProcTable[I] := @ProcM;
      'n': fProcTable[I] := @ProcIdent;
      'o': fProcTable[I] := @ProcIdent;
      'p': fProcTable[I] := @ProcP;
      'q': fProcTable[I] := @ProcIdent;
      'r': fProcTable[I] := @ProcR;
      's': fProcTable[I] := @ProcS;
      't': fProcTable[I] := @ProcT;
      'u': fProcTable[I] := @ProcU;
      'v': fProcTable[I] := @ProcV;
      'w': fProcTable[I] := @ProcW;
      'x': fProcTable[I] := @ProcIdent;
      'y': fProcTable[I] := @ProcIdent;
      'z': fProcTable[I] := @ProcZ;
      'A'..'Z': fProcTable[I] := @ProcIdent;
      #0     : fProcTable[I] := @ProcNull;   //Se lee el caracter de marca de fin de cadena
      #1..#9, #11, #12, #14..#32: fProcTable[I] := @ProcSpace;
      else fProcTable[I] := @ProcUnknown;
    end;
end;
function TResaltTerm.KeyComp(const aKey: String): Boolean;
var
  I: Integer;
  Temp: PChar;
begin
  Temp := fToIdent;
  if Length(aKey) = fStringLen then
  begin
    Result := True;
    for i := 1 to fStringLen do
    begin
      if Temp^ <> aKey[i] then
      begin
        Result := False;
        break;
      end;
      inc(Temp);
    end;
  end else Result := False;
end;
procedure TResaltTerm.ProcComent;
//Procesa el símbolo '#'
begin
  begin
    fTokenID := tkComment;
    inc(PosFin);       //salta a siguiente token
    while not (linAct[PosFin] in [#0, #10, #13]) do Inc(PosFin);
  end;
end;
procedure TResaltTerm.ProcString;
//Procesa el caracter comilla.
begin
  fTokenID := tkString;   //marca como cadena
  Inc(PosFin);
  while (not (linAct[PosFin] in [#0, #10, #13])) do begin
    if linAct[PosFin] = '"' then begin //busca fin de cadena
      Inc(PosFin);
      if (linAct[PosFin] <> '"') then break;  //si no es doble comilla
    end;
    Inc(PosFin);
  end;
end;
procedure TResaltTerm.ProcIdent;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fTokenID := tkIndentif;  //identificador común
end;

procedure TResaltTerm.ProcA;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('lias')     then fTokenID := tkKey else
  if KeyComp('propos')     then fTokenID := tkKey else
  if KeyComp('wk')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcB;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('anner')     then fTokenID := tkKey else
  if KeyComp('reak')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcC;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('al')     then fTokenID := tkKey else
  if KeyComp('aller')     then fTokenID := tkKey else
  if KeyComp('ase')     then fTokenID := tkKey else
  if KeyComp('at')     then fTokenID := tkKey else
  if KeyComp('d')     then fTokenID := tkKey else
  if KeyComp('hgrp')     then fTokenID := tkKey else
  if KeyComp('hmod')     then fTokenID := tkKey else
  if KeyComp('hown')     then fTokenID := tkKey else
  if KeyComp('lear')     then fTokenID := tkKey else
  if KeyComp('mp')     then fTokenID := tkKey else
  if KeyComp('ommand')     then fTokenID := tkKey else
  if KeyComp('ontinue')     then fTokenID := tkKey else
  if KeyComp('p')     then fTokenID := tkKey else
  if KeyComp('rontab')     then fTokenID := tkKey else
  if KeyComp('ut')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcD;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('ate')     then fTokenID := tkKey else
  if KeyComp('eclare')     then fTokenID := tkKey else
  if KeyComp('f')     then fTokenID := tkKey else
  if KeyComp('iff')     then fTokenID := tkKey else
  if KeyComp('ir')     then fTokenID := tkKey else
  if KeyComp('u')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcE;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('cho')     then fTokenID := tkKey else
  if KeyComp('lse')     then fTokenID := tkKey else
  if KeyComp('nv')     then fTokenID := tkKey else
  if KeyComp('val')     then fTokenID := tkKey else
  if KeyComp('xit')     then fTokenID := tkKey else
  if KeyComp('xport')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcF;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('alse')     then fTokenID := tkKey else
  if KeyComp('c')     then fTokenID := tkKey else
  if KeyComp('i')     then fTokenID := tkKey else
  if KeyComp('ile')     then fTokenID := tkKey else
  if KeyComp('ind')     then fTokenID := tkKey else
  if KeyComp('mt')     then fTokenID := tkKey else
  if KeyComp('or')     then fTokenID := tkKey else
  if KeyComp('unction')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcG;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('etopts')     then fTokenID := tkKey else
  if KeyComp('rep')     then fTokenID := tkKey else
  if KeyComp('unzip')     then fTokenID := tkKey else
  if KeyComp('zip')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcH;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('alt')     then fTokenID := tkKey else
  if KeyComp('ash')     then fTokenID := tkKey else
  if KeyComp('ead')     then fTokenID := tkKey else
  if KeyComp('elp')     then fTokenID := tkKey else
  if KeyComp('istory')     then fTokenID := tkKey else
  if KeyComp('ostname')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcI;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('d')     then fTokenID := tkKey else
  if KeyComp('f')     then fTokenID := tkKey else
  if KeyComp('nfo')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcJ;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('obs')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcK;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('ill')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcL;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('dd')     then fTokenID := tkKey else
  if KeyComp('ess')     then fTokenID := tkKey else
  if KeyComp('n')     then fTokenID := tkKey else
  if KeyComp('ocal')     then fTokenID := tkKey else
  if KeyComp('ocate')     then fTokenID := tkKey else
  if KeyComp('ogout')     then fTokenID := tkKey else
  if KeyComp('s')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //sin atributos
end;
procedure TResaltTerm.ProcM;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('ail')     then fTokenID := tkKey else
  if KeyComp('an')     then fTokenID := tkKey else
  if KeyComp('esg')     then fTokenID := tkKey else
  if KeyComp('kdir')     then fTokenID := tkKey else
  if KeyComp('ore')     then fTokenID := tkKey else
  if KeyComp('v')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcP;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('asswd')     then fTokenID := tkKey else
  if KeyComp('r')     then fTokenID := tkKey else
  if KeyComp('rintenv')     then fTokenID := tkKey else
  if KeyComp('rintf')     then fTokenID := tkKey else
  if KeyComp('s')     then fTokenID := tkKey else
  if KeyComp('wd')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcR;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('ead')     then fTokenID := tkKey else
  if KeyComp('eadonly')     then fTokenID := tkKey else
  if KeyComp('eboot')     then fTokenID := tkKey else
  if KeyComp('eset')     then fTokenID := tkKey else
  if KeyComp('eturn')     then fTokenID := tkKey else
  if KeyComp('m')     then fTokenID := tkKey else
  if KeyComp('mdir')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcS;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('ed')     then fTokenID := tkKey else
  if KeyComp('elect')     then fTokenID := tkKey else
  if KeyComp('eq')     then fTokenID := tkKey else
  if KeyComp('et')     then fTokenID := tkKey else
  if KeyComp('h')     then fTokenID := tkKey else
  if KeyComp('hift')     then fTokenID := tkKey else
  if KeyComp('hutdown')     then fTokenID := tkKey else
  if KeyComp('leep')     then fTokenID := tkKey else
  if KeyComp('ort')     then fTokenID := tkKey else
  if KeyComp('pell')     then fTokenID := tkKey else
  if KeyComp('uspend')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcT;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('ac')     then fTokenID := tkKey else
  if KeyComp('ail')     then fTokenID := tkKey else
  if KeyComp('alk')     then fTokenID := tkKey else
  if KeyComp('ar')     then fTokenID := tkKey else
  if KeyComp('est')     then fTokenID := tkKey else
  if KeyComp('hen')     then fTokenID := tkKey else
  if KeyComp('ime')     then fTokenID := tkKey else
  if KeyComp('imes')     then fTokenID := tkKey else
  if KeyComp('ouch')     then fTokenID := tkKey else
  if KeyComp('r')     then fTokenID := tkKey else
  if KeyComp('rap')     then fTokenID := tkKey else
  if KeyComp('rue')     then fTokenID := tkKey else
  if KeyComp('ype')     then fTokenID := tkKey else
  if KeyComp('ypeset')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcU;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('limit')     then fTokenID := tkKey else
  if KeyComp('mask')     then fTokenID := tkKey else
  if KeyComp('nalias')     then fTokenID := tkKey else
  if KeyComp('name')     then fTokenID := tkKey else
  if KeyComp('ncompress')     then fTokenID := tkKey else
  if KeyComp('niq')     then fTokenID := tkKey else
  if KeyComp('nset')     then fTokenID := tkKey else
  if KeyComp('ntil')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcV;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('dir')     then fTokenID := tkKey else
  if KeyComp('i')     then fTokenID := tkKey else
  if KeyComp('im')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcW;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('ait')     then fTokenID := tkKey else
  if KeyComp('c')     then fTokenID := tkKey else
  if KeyComp('hatis')     then fTokenID := tkKey else
  if KeyComp('whence')     then fTokenID := tkKey else
  if KeyComp('hereis')     then fTokenID := tkKey else
  if KeyComp('hich')     then fTokenID := tkKey else
  if KeyComp('hile')     then fTokenID := tkKey else
  if KeyComp('ho')     then fTokenID := tkKey else
  if KeyComp('hoami')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;
procedure TResaltTerm.ProcZ;
begin
  while Identifiers[linAct[posFin]] do inc(posFin);
  fStringLen := posFin - posIni - 1;  //calcula tamaño - 1
  fToIdent := linAct + posIni + 1;  //puntero al identificador + 1
  if KeyComp('cat')     then fTokenID := tkKey else
    fTokenID := tkIndentif;  //identificador común
end;

procedure TResaltTerm.ProcNull;
//Procesa la ocurrencia del caracter #0
begin
  fTokenID := tkNull;   //Solo necesita esto para indicar que se llegó al final de la línae
end;
procedure TResaltTerm.ProcSpace;
//Procesa caracter que es inicio de espacio
begin
  fTokenID := tkSpace;
  repeat
    Inc(posFin);
  until (linAct[posFin] > #32) or (linAct[posFin] in [#0, #10, #13]);
end;
procedure TResaltTerm.ProcUnknown;
begin
  inc(posFin);
  while (linAct[posFin] in [#128..#191]) OR // continued utf8 subcode
   ((linAct[posFin]<>#0) and (fProcTable[linAct[posFin]] = @ProcUnknown)) do inc(posFin);
  fTokenID := tkUnknown;
end;

procedure TResaltTerm.SetLine(const NewValue: String; LineNumber: Integer);
begin
  inherited;
  linAct := PChar(NewValue);  //copia la línea actual
  posFin := 0;                //apunta al primer caracter
  posTok := 0;    //inicia contador de token
  Next;
end;

procedure TResaltTerm.Next;
var
  l: Integer;
begin
  Inc(posTok);  //lleva la cuenta del orden del token
  posIni := PosFin;   //apunta al primer elemento
  //busca prompt en el inicio de la línea
  if (posTok=1) then begin
    //Estamos al inicio
    //verifica si hay prompt
    if detecPrompt then begin
      l:=Config.ContienePrompt(linAct, prIni, prFin);
      if l>0 then begin
        posFin += l;   //pasa a siguiente token
        fTokenID := tkPrompt;  //de tipo prompt
        EndCodeFoldBlock();  //cierra plegado
        StartCodeFoldBlock(nil);  //abre plegado
        exit;
      end;
    end;
    //verifica si es listado detallado de arcchivos "ls -l"
//    tmp := copy(linAct,1,3);
    if length(linAct)>43 then begin //un listado común de archivos tiene al menos este tamaño
      if (linAct[0] = 'd') and
         (linAct[1] in ['r','-']) and (linAct[2] in ['w','-']) then begin
         //es listado detallado de un directorio
         posFin := length(linAct);
         fTokenID := tkDirect;  //de tipo directorio
         exit;
      end;
    end;
  end;
  //caso normal
//  if fRange = rsComment then begin
//     CommentProc
//  end else begin
      fRange := rsUnknown;
      fProcTable[linAct[PosFin]]; //Se ejecuta la función que corresponda.
//  end;
end;

function TResaltTerm.GetEol: Boolean;
{Indica cuando se ha llegado al final de la línea}
begin
  Result := fTokenId = tkNull;
end;

procedure TResaltTerm.GetTokenEx(out TokenStart: PChar; out TokenLength: integer);
{Devuelve información sobre el token actual}
begin
  TokenLength := posFin - posIni;
  TokenStart := linAct + posIni;
end;

function TResaltTerm.GetTokenAttribute: TSynHighlighterAttributes;
//Devuelve información sobre el token actual
begin
  case fTokenID of
    tkIndentif: Result := fAtriIdentif;
    tkComment : Result := fAtriComent;
    tkKey     : Result := fAtriClave;
    tkSpace   : Result := fAtriEspac;
    tkString  : Result := fAtriCadena;
    tkPrompt  : Result := fAtriPrompt;
    tkDirect  : Result := fAtriDirect;
    else
      Result := nil;  //tkUnknown, tkNull
  end;
end;
function TResaltTerm.GetDefaultAttribute(Index: integer): TSynHighlighterAttributes;
{Este método es llamado por la clase "TSynCustomHighlighter", cuando se accede a alguna de
 sus propiedades:  CommentAttribute, IdentifierAttribute, KeywordAttribute, StringAttribute,
 SymbolAttribute o WhitespaceAttribute.}
begin
  case Index of
    SYN_ATTR_COMMENT   : Result := fAtriComent;
    SYN_ATTR_IDENTIFIER: Result := fAtriIdentif;
    SYN_ATTR_KEYWORD   : Result := fAtriClave;
    SYN_ATTR_WHITESPACE: Result := fAtriEspac;
    SYN_ATTR_STRING    : Result := fAtriCadena;
    else Result := nil;
  end;
end;

{Las siguientes funciones, son usadas por SynEdit para el manejo de las
 llaves, corchetes, parentesis y comillas. No son cruciales para el coloreado
 de tokens, pero deben responder bien.}
function TResaltTerm.GetToken: String;
begin
  Result := '';
end;
function TResaltTerm.GetTokenPos: Integer;
begin
  Result := posIni - 1;
end;
function TResaltTerm.GetTokenKind: integer;
begin
  Result := 0;
end;
procedure TResaltTerm.CommentProc;
begin
  fTokenID := tkComment;
  case linAct[PosFin] of
    #0:
      begin
        ProcNull;
        exit;
      end;
  end;
  while linAct[PosFin] <> #0 do
    case linAct[PosFin] of
      '*':
        if linAct[PosFin + 1] = '/' then
        begin
          inc(PosFin, 2);
          fRange := rsUnknown;
          break;
        end
        else inc(PosFin);
      #10: break;
      #13: break;
    else inc(PosFin);
    end;
end;

///////// Implementación de las funcionalidades de rango //////////
procedure TResaltTerm.ResetRange;
begin
  inherited;
  fRange := rsUnknown;
end;
function TResaltTerm.GetRange: Pointer;
begin
  CodeFoldRange.RangeType := Pointer(PtrInt(fRange));
  Result := inherited;
end;
procedure TResaltTerm.SetRange(Value: Pointer);
begin
  inherited;
  fRange := TRangeState(PtrUInt(CodeFoldRange.RangeType));
end;

initialization
   CreaTablaIdentif;   //Crea la tabla para búsqueda rápida
end.

