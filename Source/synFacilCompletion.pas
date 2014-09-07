{
SynFacilCompletion 0.4b
======================
Por Tito Hinostroza 14/08/2014
* Se corrigió una interferencia con el evento OnKeyUp().
* Se ponen diversas propiedades privadas a Protected, para poder acceder a ellas.
* Se ponen los métodos AddCompItem() y AddCompItemL(), como públicos para facilitar
agregar palabras para autocompletado, usando código en lugar del archivo XML.
* Se hace pública la propiedad "Range", para facilitar la implementación de
analizadores léxicos.
* Se incluye la propiedad "state" y se define el tipo "TFaLexerState", para
facilitar la implementación de analizadores léxicos.

Descripción
============
Unidad que expande al resaltador TSynFacilSyn, para que pueda soportar configuraiones
de autocompletado de texto.
Requiere de la unidad SynCompetionQ, que es una versión modificada de SynCompletion

Se usa de froma similar a SynFacilSyn. Se debe crear un resaltador, pero ahora de la
clase TSynFacilComplet:

uses ... , SynFacilCompletion;

procedure TForm1.FormShow(Sender: TObject);
begin
 //configure highlighter
  hlt := TSynFacilComplet.Create(self);  //my highlighter
  SynEdit1.Highlighter := hlt;  //optional if we are going to use SelectEditor()
  hlt.LoadFromFile('./languages/ObjectPascal.xml');  //load syntax
  hlt.SelectEditor(SynEdit1);  //assign to editor
end;

Luego se debe interceptar los evento KeyUp y UTF8KeyPress, del SynEdit:

procedure TForm1.SynEdit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  hlt.KeyUp(Sender, Key, Shift);
end;

procedure TForm1.SynEdit1UTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
begin
  hlt.UTF8KeyPress(Sender, UTF8Key);
end;

Y se debe terminar correctamente:

procedure TForm1.FormDestroy(Sender: TObject);
begin
  hlt.UnSelectEditor;   //release editor (only necessary if we are to call to SelectEditor(), again)
  hlt.Free;  //destroy the highlighter
end;

Cuando se desea desaparecer la ventana de ayuda contextual por algún evento, se debe
llamar a CloseCompletionWindow().

}
unit SynFacilCompletion;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, XMLRead, DOM, Math, LCLType, SynEditHighlighter,
  SynEdit, SynEditTypes, SynEditKeyCmds, Lazlogger, SynFacilHighlighter,
  {Debe utilizar su propia unidad SynCompletion, porque maneja de forma diferente los
  eventos del teclado, de la ventana de completado}
  SynCompletionQ;

type
  TCompletItem = record
    item   : string;      //etiqueta a mostrar en el menú
    content: string;      //contenido a reemplazar
    block  : TFaSynBlock; //bloque donde es válida la palabra
    before : string;      //palabra anterior
//    casesen: boolean;     //indica si es sensible a la caja
  end;

  //Permite leer el estado actual del resaltador. Considera la posición actual de la
  //exploración y el estado del rango, NO CONSIDERA el estado de los bloques de plegado.
  TFaLexerState = record
    //propiedades fijadas al inicio de la línea y no cambian en toda la línea.
    fLine      : PChar;         //puntero a línea de trabajo.
    tamLin     : integer;       //tamaño de línea actual
    //propiedades que van cambiando conforme se avanza en la exploración de la línea
    posTok     : integer;       //para identificar el ordinal del token en una línea
    BlkToClose : TFaSynBlock;   //bandera-variable para posponer el cierre de un bloque
    posIni     : Integer;       //índice a inicio de token
    posFin     : Integer;       //índice a siguiente token
    fRange     : ^TTokEspec;    //para trabajar con tokens multilínea
    fTokenID   : TSynHighlighterAttributes;  //Id del token actual
  end;

  TCompletItems = array of TCompletItem;
  //Posiciones de cursor en el editor
  TPosicCursor=( pcDesconocido,    //posición desconocida
                 pcEnOtro,   //al final de identificador.
                 pcEnIdent,   //en medio de identificador
                 pcDespuesIdent,   //despues de identificador (separado por espacio)
                 pcDespuesPunto);  //despues de punto

  { TSynFacilComplet }
  //clase principal
  TSynFacilComplet = class(TSynFacilSyn)
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure OnCodeCompletion(var Value: string; SourceValue: string;
      var SourceStart, SourceEnd: TPoint; KeyChar: TUTF8Char; Shift: TShiftState);
    procedure OnExecute(Sender: TObject);
    procedure FormUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
  private
    function GetState: TFaLexerState;
    procedure SetState(state: TFaLexerState);
  protected
    ed: TSynEdit;  //referencia interna al editor
    MenuComplet: TSynCompletion;   //menú contextual
    AllItems  : TCompletItems; //lista de todas las palabras disponibles para el completado
    AvailItems : TStringList;  {Lista de palabras disponible para cargar en el menú de
                                auto-completado}
    PosiCursor: TPosicCursor;  //Posición del cursor
    tok0: TFaTokInfo;          //token actual del completado
    Pos0: TPoint;  //Posición incial del cursor donde se abrió la ventana de completado
{ TODO : Pos0, debe manejarse desde dentro de esta clase y no desde SynCompeltionQ }
    IdentAct0: string;         //IDentificador actual desde el inicio hasta el cursor
    IdentAct : string;         //Identificador actual completo
    IdentAnt : string;         //Identificador anterior
    BloqueAct: TFaSynBlock;    //referecnia al bloque actual

    tokens: TATokInfo;         //lista de tokens actuales
    iCurTok  : integer;        //índice al token actual

    CaseSensComp: boolean;     //Uso de caja, en autocompletado
    utKey    : TUTF8Char;      //tecla pulsada
    vKey     : word;           //código de tecla virtual
    SpecIdentifiers: TArrayTokEspec;
    function CheckForClose: boolean;
    function EsIdentif(const tok: TFaTokInfo): boolean;
    procedure FillCompletMenuFilteredBy(str: string);
    procedure OpenCompletionWindow;
    procedure ProcCompletionLabel(nodo: TDOMNode);
    procedure ReadSpecialIdentif;
    procedure MiraEntornoCursor; virtual;
  public
    CompletionOn: boolean;  //activa o desactiva el auto-completado
    EnterSelect: boolean;   //habilita la selección con enter
    OpenOnKeyUp: boolean;   //habilita que se abra automáticamente al soltar una tecla
    procedure LoadFromFile(Arc: string); override;
    function LoadSyntaxFromPath(SourceFile: string; path: string;
      CaseSens: boolean=false): string;
    procedure SelectEditor(ed0: TSynEdit);  //inicia la ayuda contextual
    procedure UnSelectEditor;  //termina la ayuda contextual con el editor
    procedure UTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure AddCompItem(item, content: string; blk: TFaSynBlock);
    procedure AddCompItemL(list: string; blk: TFaSynBlock);
    procedure CloseCompletionWindow;
    //Utilidades para analizador léxico
    property Range: TPtrTokEspec read fRange write fRange;
    property State: TFaLexerState read GetState write SetState;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  //utilidades
  function ReadExtenFromXML(XMLfile: string): string;
  function XMLFileHaveExten(XMLfile: string; exten: string;
                CaseSens: boolean = false): boolean;

implementation
uses SynEditMiscProcs;

function ReadExtenFromXML(XMLfile: string): string;
//Lee las extensiones que tiene definidas un archivo de sintaxis.
var doc: TXMLDocument;
  atri: TDOMNode;
  i: Integer;
begin
  try
    Result := '';   //por defecto
    ReadXMLFile(doc, XMLfile);  //carga archivo
    //busca el parámetro "ext"
    for i:= 0 to doc.DocumentElement.Attributes.Length-1 do begin
      atri := doc.DocumentElement.Attributes.Item[i];
      if UpCase(atri.NodeName) = 'EXT' then begin
        Result := trim(atri.NodeValue);  //valor sin espacios
      end;
    end;
    doc.Free;  //libera
  except
    on E: Exception do begin
      ShowMessage('Error cargando: ' + XMLfile + #13#10 + e.Message);
      doc.Free;
    end;
  end;
end;
function XMLFileHaveExten(XMLfile: string; exten: string;
                CaseSens: boolean = false): boolean;
//Indica si un archivo XML de sintaxis, tiene definida la extensión que se indica
//La comparación se puede hacer con o sin diferecnia de caja
var
  lext: TStringList;
  s: String;
  tmp: String;
begin
  Result := false;  //por defecto
  lext:= TStringList.Create;  //crea lista
  tmp := ReadExtenFromXML(XMLfile);  //lee archivo
  lext.DelimitedText:=' ';
  lext.Text:=tmp;  //divide
  //busca de acuerdo a la caja
  if CaseSens then begin
    for s in lext do begin
      if s = exten then begin
        //encontró
        Result := true;
        lext.Free;
        exit;
      end;
    end;
  end else begin
    for s in lext do begin
      if Upcase(s) = Upcase(exten) then begin
        //encontró
        Result := true;
        lext.Free;
        exit;
      end;
    end;
  end;
  //No enecontró
  lext.Free;
end;

{ TSynFacilComplet }
procedure TSynFacilComplet.ReadSpecialIdentif;
//Hace una exploración para leer todos los identificadores especiales en la tabla
//SpecIdentifiers[].
var
  met: TFaProcMetTable;
  p: TPtrATokEspec;
  c: Char;
  i: Integer;
  n: Integer;
begin
  setlength(SpecIdentifiers,0);
  if CaseSensitive then begin
    for c in ['A'..'Z','a'..'z'] do begin
      TableIdent(c, p, met);
      if p<> nil then begin
        for i:= 0 to high(p^) do begin
          n := high(SpecIdentifiers)+1;  //tamaño de matriz
          setlength(SpecIdentifiers,n+1);
          SpecIdentifiers[n] := p^[i];
        end;
      end;
    end;
  end else begin  //no es sensible a la caja
    for c in ['A'..'Z'] do begin
      TableIdent(c, p, met);
      if p<> nil then begin
        for i:= 0 to high(p^) do begin
          n := high(SpecIdentifiers)+1;  //tamaño de matriz
          setlength(SpecIdentifiers,n+1);
          SpecIdentifiers[n] := p^[i];
        end;
      end;
    end;
  end;
end;
function TSynFacilComplet.LoadSyntaxFromPath(SourceFile: string; path: string;
              CaseSens: boolean = false): string;
//Carga un archivo de sintaxis, buscando el resaltador apropiado en un directorio.
//Si encuentra el archivo de sintaxis apropiado, devuelve el nombre del archivo usado
//(sin incluir la ruta), de otra forma, devuelve una cadena vacía.
var
  ext: String;
  Hay: Boolean;
  SR : TSearchRec;
  rut: String;
begin
  Result := '';
  ext := ExtractFileExt(SourceFile);
  if ext<>'' then ext := copy(ext, 2, 10);  //quita el punto
  //explora los lenguajes para encontrar alguno que soporte la extensión dada
  Hay := FindFirst(path + '\*.xml',faAnyFile - faDirectory, SR) = 0;
  while Hay do begin
     //encontró archivo, lee sus extensiones
     rut := path + '\' + SR.name;
     if XMLFileHaveExten(rut, ext, CaseSens) then  begin //encontró
       LoadFromFile(rut);  //carga sintaxis
       Result := SR.name;
       exit;
     end;
     //no encontró extensión, busca siguiente archivo
     Hay := FindNext(SR) = 0;
  end;
  //no encontró
end;
procedure TSynFacilComplet.AddCompItem(item, content: string; blk: TFaSynBlock);
//Agrega un ítem a la lsta de completado. "blk" es el bloque donde será válida el ítem para
//el completado. Si es NIL, será válido en cualquier bloque.
var
  n: Integer;
  r: TCompletItem;
begin
  r.item:=item;  //etiqueta a mostrar
  r.content:=content;
  r.block := blk;;
  //agrega
  n := high(AllItems)+1;  //tamaño de matriz
  setlength(AllItems,n+1);
  AllItems[n] := r;
end;
procedure TSynFacilComplet.AddCompItemL(list: string; blk: TFaSynBlock);
//Agrega una lista de ítems, separados por espacios, a la lista de completado
var
  n: Integer;
  r: TCompletItem;
  lst: TStringList;
  i: Integer;
begin
  //divide
  lst := TStringList.Create;
  lst.Delimiter := ' ';
  lst.DelimitedText := list;

  //agrega
  n := high(AllItems)+1;  //tamaño de matriz
  setlength(AllItems,n+lst.Count);
  for i:= 0 to lst.Count-1 do begin
    r.item:=lst[i];
    r.content:=r.item;
    r.block := blk;
    AllItems[n+i] := r;
  end;
  lst.Destroy;
end;
procedure TSynFacilComplet.ProcCompletionLabel(nodo: TDOMNode);
//Procesa la etiqueta <Completion>, que es el bloque que define todo el sistema de
//completado de código.
var
  listIden: string;
  tCasSen: TFaXMLatrib;
  i,j   : Integer;
  nodo2: TDOMNode;
  tListAttr: TFaXMLatrib;
  tipTok: TSynHighlighterAttributes;
  hayList: Boolean;
  tOpenKUp: TFaXMLatrib;
begin
  //carga los parámetros
  tCasSen :=LeeAtrib(nodo, 'CaseSensitive');
  tOpenKUp:=LeeAtrib(nodo, 'OpenOnKeyUp');

  //carga atributos leidos
  if tCasSen.hay then  //si se especifica
    CaseSensComp := tCasSen.bol  //se lee
  else  //si no
    CaseSensComp := CaseSensitive;  //toma el del resaltador
  if tOpenKUp.hay then OpenOnKeyUp:=tOpenKUp.bol;
  hayList := false;  //inicia bandera
  ////////// explora nodos hijos //////////
  for i := 0 to nodo.ChildNodes.Count-1 do begin
    nodo2 := nodo.ChildNodes[i];
    if UpCAse(nodo2.NodeName)='INCLUDE' then begin  //incluye lista de palabras por atributo
      tListAttr := LeeAtrib(nodo2,'Attribute');
      //tListBlk := LeeAtrib(nodo2,'Block');
      if ValidarAtribs(nodo2, 'Attribute') then exit;
      if tListAttr.hay then begin
        //se pide agregar la lista de identificadores de un atributo en especial
        if IsAttributeName(tListAttr.val)  then begin
          tipTok := GetAttribByName(tListAttr.val);   //tipo de atributo
          //busca los identificadores para agregarlos
          for j:= 0 to high(SpecIdentifiers) do begin
            if SpecIdentifiers[j].tTok = tipTok then begin
              AddCompItem(SpecIdentifiers[j].orig,SpecIdentifiers[j].orig, nil);
            end;
          end;
        end else begin  //atributo no existe
          Err := 'Atributo '+ nodo2.NodeValue+ ' no existe. (etiqueta <COMPLETION ...>)';
          exit;
        end;
      end;
    end else if UpCAse(nodo2.NodeName)='KEYWORD' then begin  //definición alternativa de delimitador
//      tTokPos := LeeAtrib(nodo2,'TokPos');
//      if ValidarAtribs(nodo2, 'TokPos') then exit;
//      //agrega la referecnia del bloque al nuevo token delimitador
//      AddFinBlockToTok(trim(nodo2.TextContent), tTokPos.n, blq);

    end else if UpCAse(nodo2.NodeName)='LIST' then begin  //forma alternativa para lista de palabras
      //Esta forma de declaración permite definir un orden en la carga de listas
      hayList :=true;   //marca para indicar que hay lista
      //lee parámetros
//      tListAttr := LeeAtrib(nodo2,'TokenType');
      //ve contenido
      listIden := nodo2.TextContent;
      if listIden<>'' then begin
         //Se ha especificado lista de palabras. Los carga en AllItems[]
         AddCompItemL(listIden,nil);
      end;
    end else if nodo2.NodeName='#text' then begin
      //éste nodo aparece siempre que haya espacios, saltos o tabulaciones
    end else begin
      Err := 'Etiqueta "' + nodo2.NodeName +
             '" no válida para etiqueta <COMPLETION ...>';
      exit;
    end;
  end;
  //verifica si se especificaron listas
  if not hayList then begin
    //No se definieron listas.
    //Se verifica si hay lista en el cuerpo de <completion></completion>
    listIden := nodo.TextContent;
    if listIden<>'' then begin
       //Se ha especificado lista de palabras directamente. Los carga en AllItems[]
       AddCompItemL(listIden,nil);
    end;
  end;
end;
procedure TSynFacilComplet.LoadFromFile(Arc: string);
var
  doc: TXMLDocument;
  i: Integer;
  nodo: TDOMNode;
  nombre: WideString;
begin
  inherited LoadFromFile(Arc);
  if Err<>'' then exit;
  OpenOnKeyUp := true;   //por defecto
  ReadSpecialIdentif;    //carga los identificadores especiales
  setlength(AllItems,0);  //inicia lista
  try
    ReadXMLFile(doc, Arc);  //carga archivo
    //procede a la carga de la etiqueta <COMPLETION>
    for i:= 0 to doc.DocumentElement.ChildNodes.Count - 1 do begin
       // Lee un Nodo o Registro
       nodo := doc.DocumentElement.ChildNodes[i];
       nombre := UpCase(nodo.NodeName);
       if nombre = 'COMPLETION' then  begin
         //forma corta de <TOKEN ATTRIBUTE='KEYWORD'> lista </TOKEN>
         ProcCompletionLabel(nodo);  //Carga Keywords
       end;
       if Err <> '' then begin
          Err +=  ' <' + nombre + '> en: ' + Arc;  //completa mensaje
          break;
       end;
    end;
    doc.Free;  //libera
  except
    on E: Exception do begin
      ShowMessage('Error cargando: ' + Arc + #13#10 + e.Message);
      doc.Free;
    end;
  end;
end;
procedure TSynFacilComplet.SelectEditor(ed0: TSynEdit);
//Inicia el motor de ayuda contextual, en el editor indicado
begin
  ed := ed0;    //guarda referencia
  if ed = nil then begin
    showmessage('ERROR: Se requiere un editor para el autocompletado.');
    ed := nil;   //para indicar que no es válido
    exit;
  end;
  //asigna por si acaso no se había hecho
  ed.Highlighter :=  self;
  MenuComplet:=TSynCompletion.Create(ed.Owner);   //crea menú contextual en el formulario
  MenuComplet.Editor:=ed;     //asigna editor
  MenuComplet.Width:=200;     //ancho inicial
  MenuComplet.OnExecute:=@OnExecute;
  MenuComplet.OnCodeCompletion:=@OnCodeCompletion;
  //iintercepta eventos de teclado, para cambiar comportamiento
  MenuComplet.OnKeyDown:=@FormKeyDown;
  MenuComplet.OnUTF8KeyPress:=@FormUTF8KeyPress;  //eventos del teclado de la ventana de completado
end;
procedure TSynFacilComplet.UnSelectEditor;
//Método que quita la ayuda contextual al formulario indicado y al editor.
//Se debería llamar siempre si se ha llamado a SelectEditor().
begin
  if MenuComplet = nil then exit;  //nunca se creó
  MenuComplet.Destroy;
  MenuComplet := nil;  //lo marca como  liberado
end;

function TSynFacilComplet.CheckForClose: boolean;
//Verifica y cierra la ventana de completado si el cursor está fuera del token actual.
//SI se cierra devuelve TRUE.
begin
  Result := false;
  //verifica si sale de token actual
  if ed.CaretX <= Pos0.x then begin
    MenuComplet.Deactivate;
    Result := true;
  end;
end;
function TSynFacilComplet.EsIdentif(const tok: TFaTokInfo): boolean;
//Permite saber los tipos de tokens que se consideran como identificador
begin
  if (tok.TokTyp = self.tkIdentif) or (tok.TokTyp = self.tkKeyword) then
    Result := true
  else
    Result := false;
end;
procedure TSynFacilComplet.MiraEntornoCursor;
{Analiza el estado del cursor en el editor. Se supone que se debe llamar, después de
 actualizar el editor. Actualiza: PosiCursor, IdentAct, IdentAct0, IdentAnt, BloqueAct }
var
  curTok: integer;
  tok_1, tok_2, tok_3: TFaTokInfo; //tokens anteriores
  CurX: Integer;
begin
  //valores por defecto
  PosiCursor := pcDesconocido;  //inicialmente
  IdentAct:='';
  IdentAct0:='';
  IdentAnt:='';
  BloqueAct := nil;
  //explora la línea con el resaltador
  self.ExploreLine(ed.CaretXY, tokens, curTok);
  if curTok=-1 then exit;   //no ubica al token actual
  //Ubica el token de trabajo. Puede ser el actual o el anterior
  //ve si estamos al inicio de un token
  if tokens[curTok].posIni+1 = ed.CaretX then begin
    //Estamos justo al inicio del token (después de un token)
    iCurTok:=curTok-1;  //toma el anterior
    if iCurTok<0 then iCurTok := 0; //a menos que sea el primero
  end else begin
    //estamos en medio de un identificador
    iCurTok:=curTok;  //toma el mismo
  end;
  tok0 := tokens[icurTok];    //lee token actual
/////////////////////////////////////////////  if tok0.TokTyp = tk;
///////////////////////////////////////////////////////
////falat verificar si el token actual es identificador
///////////////////////////////////////////////////////
///////////////////////////////////////////////////////
  PosiCursor:=pcEnIdent;  //en medio de identificador
  CurX := ed.CaretX;
  IdentAct0:= copy(tok0.txt,1,CurX-tok0.posIni-1);
  IdentAct:=tok0.txt;
  IdentAnt:='';
  BloqueAct := tok0.curBlk;  //devuelve bloque
end;
procedure TSynFacilComplet.OnCodeCompletion(var Value: string;
  SourceValue: string; var SourceStart, SourceEnd: TPoint; KeyChar: TUTF8Char;
  Shift: TShiftState);
//Se genera antes de hacer el reemplazo del texto. "Value", es la cadena que se usará
//para reemplazar la palabra en el editor.
begin
  //Se puede usar "MenuComplet.Position" para saber el elemento seleccionado de la lista
//  value := 'hola';
//  showmessage(value);
end;
procedure TSynFacilComplet.OnExecute(Sender: TObject);
//Este evento se genera antes de abrir el menú de completado.
//Llena la lista "AvailItems", con los ítems que correspondan de acuerdo a la posición
//actual del cursor y de la configuración del archivo XML.
//Luego llena el menú contextual con los ítems filtrados de acuerdo a la posición actual.
var
  i: Integer;
begin
  //limpìa listas
  AvailItems.Clear;
  MenuComplet.ItemList.Clear;  //inicia en cero,  por si no se llena.
  //Analiza entorno de cursor
  MiraEntornoCursor;  //actualiza IdentAct, IdentAnt, BloqueAct, PosiCursor
  //Veriifca si se va a abrir la lista por un evento de teclado o por un atajo
  if MenuComplet.CurrentString='<KeyUp>' then begin
//    debugln('Abierto por teclado utKey='+utKey+',vKey='+IntToStr(vKey));
    if utKey='' then begin
      //La tecla pulsada no es un caracter imprimible
      exit;
    end;
    //Verifica si es tecla válida
    if not (utKey[1] in ['a'..'z','A'..'Z']) then begin
      exit;
    end;
  end;
  //Verifica condiciones para mostrar ventana
  case PosiCursor of
  pcEnIdent:  begin //en medio o al final de un identificador
      for i:=0 to high(AllItems) do begin
        if (AllItems[i].block = nil) then  //es válido para todos los bloques
          AvailItems.Add(AllItems[i].item);
      end;
      FillCompletMenuFilteredBy(IdentAct0);
    end;
  pcEnOtro: begin  //caso típico. no se identifica situación especifica
{      for i:=0 to high(AllItems) do begin
        if (AllItems[i].block = nil) then  //es válido para todos los bloques
          AvailItems.Add(AllItems[i].item);
      end;
      FillCompletMenuFilteredBy(IdentAct0);}
    end;
  pcDespuesIdent: begin   //después de identificador
{        If (IdentAnt = 'RETURN') Then begin
         LlenaAyudContextual_TIPO;
      end else If (IdentAnt = 'CONNECT') Then begin
         LlenaConAyudContextual;
      end}
    end;
  else      //'pcDesconocido' no se identifica el contexto del código
    begin  end;
  end;
  //Después de llenar la lista, se puede ver si tiene o no elementos
  if MenuComplet.ItemList.Count <> 0 then begin  //se abrirá
    //aprovechamos para gaurdar la posición de inicio del token identificador
    if PosiCursor = pcEnIdent then begin  //en identificador
      Pos0 := Point(tok0.posIni+1, ed.CaretY);   //guarda la posición de origen del token actual
    end else begin  //es otra cosa
      Pos0 := Point(ed.CaretX, ed.CaretY);   //guarda la posición de origen del token actual
    end;
//    debugln('Fij.Pos0.X='+IntToStr(Pos0.x));
  end;
end;
procedure TSynFacilComplet.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//debugln('Form.OnKeyDown:'+IdentAct0+':'+IntToStr(ed.CaretX));
  case Key of
// added the VK_XXX codes to make it more readable / maintainable
{    VK_RETURN:
      if Assigned(MenuComplet.OnValidate) then
        MenuComplet.OnValidate(Self, '', Shift);
    VK_ESCAPE:
      if Assigned(OnCancel) then OnCancel(Self);
    // I do not think there is a worst way to do this, but laziness rules :-)
    VK_PRIOR:
      for i := 1 to NbLinesInWindow do
        SelectPrec;
    VK_NEXT:
      for i := 1 to NbLinesInWindow do
        SelectNext;
    VK_UP:
      if ssCtrl in Shift then
        Position := 0
      else
        SelectPrec;
    VK_DOWN:
      if ssCtrl in Shift then
        Position := ItemList.count - 1
      else
        SelectNext;}
    VK_HOME: begin
        if Shift = [] then begin  //envía al editor
           ed.CommandProcessor(ecLineStart, #0, nil);
           MenuComplet.Deactivate;  //desactiva
        end else if Shift = [ssShift] then begin
          ed.CommandProcessor(ecSelLineStart, #0, nil);
          MenuComplet.Deactivate;  //desactiva
        end;
        Key:=VK_UNKNOWN;   //marca para que no lo procese SynCompletion
      end;
    VK_END: begin
        if Shift = [] then begin  //envía al editor
           ed.CommandProcessor(ecLineEnd, #0, nil);
           MenuComplet.Deactivate;  //desactiva
        end else if Shift = [ssShift] then begin
          ed.CommandProcessor(ecSelLineEnd, #0, nil);
          MenuComplet.Deactivate;  //desactiva
        end;
        Key:=VK_UNKNOWN;   //marca para que no lo procese SynCompletion
      end;
    VK_BACK: begin
        if Shift = [] then begin  //son Ctrl o Shift
           ed.CommandProcessor(ecDeleteLastChar, #0, nil);  //envía al editor
           if CheckForClose then begin Key:=VK_UNKNOWN;; exit end;
           MiraEntornoCursor;  //solo para actualizar el identificador actual
           FillCompletMenuFilteredBy(IdentAct0);
        end;
        Key:=VK_UNKNOWN;   //marca para que no lo procese SynCompletion
      end;
    VK_LEFT: begin
        if Shift = [] then begin  //envía al editor
          ed.CommandProcessor(ecLeft, #0, nil);
          if CheckForClose then begin Key:=VK_UNKNOWN;; exit end;
        end else if Shift = [ssShift] then begin
          ed.CommandProcessor(ecSelLeft, #0, nil);
          MenuComplet.Deactivate;  //desactiva
        end else if Shift = [ssCtrl] then begin
          ed.CommandProcessor(ecWordLeft, #0, nil);
          MenuComplet.Deactivate;  //desactiva
        end else if Shift = [ssShift,ssCtrl] then begin
          ed.CommandProcessor(ecSelWordLeft, #0, nil);
          MenuComplet.Deactivate;  //desactiva
        end;
        Key:=VK_UNKNOWN;   //marca para que no lo procese SynCompletion
      end;
    VK_Right: begin
        if Shift = [] then begin  //envía al editor
          ed.CommandProcessor(ecRight, #0, nil);
          MenuComplet.Deactivate;  //desactiva
        end else if Shift = [ssShift] then begin
          ed.CommandProcessor(ecSelRight, #0, nil);
          MenuComplet.Deactivate;  //desactiva
        end else if Shift = [ssCtrl] then begin
          ed.CommandProcessor(ecWordRight, #0, nil);
          MenuComplet.Deactivate;  //desactiva
        end else if Shift = [ssShift,ssCtrl] then begin
          ed.CommandProcessor(ecSelWordRight, #0, nil);
          MenuComplet.Deactivate;  //desactiva
        end;
        Key:=VK_UNKNOWN;   //marca para que no lo procese SynCompletion
      end;
    VK_TAB:
      begin
        MenuComplet.OnValidate(MenuComplet.TheForm, '', Shift);  //selecciona
        Key:=VK_UNKNOWN;   //marca para que no lo procese SynCompletion
      end;
  end;
  //si no lo procesó aquí, lo procesará SynCompletion
end;
procedure TSynFacilComplet.FormUTF8KeyPress(Sender: TObject;
  var UTF8Key: TUTF8Char);
//Este evento se dispara cuando ya está visible la ventana de autocompletado y por
//lo tanto no se generará el evento KeyUp
begin
  //Como este evento se genera apneas pulsar una tecla, primero pasamos la tecla al
  //editor para que lo procese y así tendremos el texto modificado, como si estuviéramos
  //después de un KeyUp().
  ed.CommandProcessor(ecChar, UTF8Key, nil);
  UTF8Key := '';  //limpiamos para que ya no lo procese SynCompletion
  //ahora ya tenemos al editor cambiado
//debugln('Form.OnKeyPress:'+IdentAct0+':'+IntToStr(ed.CaretX));
//Las posibles opciones ya se deben haber llenado. Aquí solo filtramos.
  MiraEntornoCursor;  //solo para actualizar el identificador actual
  if CheckForClose then exit;
  FillCompletMenuFilteredBy(IdentAct0);
end;
procedure TSynFacilComplet.UTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
{Debe recibir la tecla pulsada aquí, y guardarla para KeyUp, porque allí no se puede
reconocer caracteres ASCII. Se usa UTF para hacerlo más fléxible}
begin
  utKey:=UTF8Key;  //guarda tecla
end;
procedure TSynFacilComplet.KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
{Verifica la tecla pulsada, para determinar si abrir o no el menú de ayuda contextual
 Debe llamarse después de que el editor ha procesado el evento, para tener
 el estado final del editor
 Este evento solo se ejecutará una vez antes de abrir la ventana de autocompletado}
begin
  if not CompletionOn then exit;
  if not OpenOnKeyUp then exit;
  //verificación principal
  if MenuComplet.IsActive then begin
    //verifica si debe desaparecer la ventana, por mover el cursor a una posición anterior
//    if CompareCarets(Pos0, CurrentEditor.CaretXY) < 0 then
//      Deactivate;
    exit;   //ya está mostrado
  end;
  if ed = NIL then exit;     //no hay editor
  if ed.SelectionMode <> smNormal then exit;  //para no interferir en modo columna
  //captura las teclas pulsadas y llama a OnExecute(), para ver si correspodne mostrar
  //la ventana de completado
  vKey := Key;   //guarda
  //Dispara evento OnExecute con el valor de "vKey" y "utKey" actualizados
  OpenCompletionWindow;  //solo se mostrará si hay ítems
  vKey := 0;
  utKey := '';  //limpia por si la siguiente tecla pulsada no dispara a UTF8KeyPress()
End;
procedure TSynFacilComplet.FillCompletMenuFilteredBy(str: string);
//Llena el menú de completado a partir de "AvailItems", filtrando solo las
//palabras que coincidan con "str"
var
  l: Integer;
  i: Integer;
begin
  l := length(str);
//debugln('  FilCompl:'+str);
  //Genera la lista que coincide
  { TODO : Este proceso es lento si se actualizan muchas opciones en la lista }
  MenuComplet.ItemList.Clear;
  if CaseSensComp then begin
    for i:=0 to AvailItems.Count-1 do begin
      if str = copy(AvailItems[i],1,l) then
         MenuComplet.ItemList.Add(AvailItems[i]);
    end;
  end else begin  //ignora la caja
    str := UpCase(str);
    for i:=0 to AvailItems.Count-1 do begin
      if str = upcase(copy(AvailItems[i],1,l)) then begin
        MenuComplet.ItemList.Add(AvailItems[i]);
      end;
    end;
  end;
  if MenuComplet.ItemList.Count = 0 then begin
    //cierra por no tener elementos
    MenuComplet.Deactivate;
  end else begin
    //hay elementos
    MenuComplet.Position:=0;  //selecciona el primero
  end;
  MenuComplet.TheForm.Invalidate;  //para que se actualice
end;
procedure TSynFacilComplet.OpenCompletionWindow;
//Abre la ayuda contextual, en la posición del cursor.
var p:TPoint;
begin
  //calcula posición donde aparecerá el menú de completado
  p := Point(ed.CaretXPix,ed.CaretYPix + ed.LineHeight);
  p.X:=Max(0,Min(p.X, ed.ClientWidth - MenuComplet.Width));
  p := ed.ClientToScreen(p);
  //Abre menú contextual, llamando primero a OnExecute(). Solo se mostrará si tiene elementos.
  MenuComplet.Execute('<KeyUp>', p.x, p.y);   //pasa una clave cualquiera para identificación posterior
End;
procedure TSynFacilComplet.CloseCompletionWindow;
//Cierra la ventana del menú contextual
begin
  MenuComplet.Deactivate;
end;
//Utilidades para analizadores léxicos
function TSynFacilComplet.GetState: TFaLexerState;
//Devuelve el estado actual del resaltador, pero sin considerar el estado de los bloque,
//solo el estado de tokens y rangos.
begin
  //propiedades fijadas al inicio de la línea y no cambian en toda la línea.
  Result.fLine    := fLine;
  Result.tamLin   := tamLin;
  //propiedades que van cambiando conforme se avanza en la exploración de la línea
  Result.posTok   := posTok;
  Result.BlkToClose:= BlkToClose;
  Result.posIni   := posIni;
  Result.posFin   := posFin;
  Result.fRange   := fRange;
  Result.fTokenID := fTokenID;
end;
procedure TSynFacilComplet.SetState(state: TFaLexerState);
//Configura el estado actual del resaltador, pero sin considerar el estado de los bloque,
//solo el estado de tokens y rangos.
//Al cambiar el estado actual del resaltador, se pierde el estado que tenía.
begin
  //propiedades fijadas al inicio de la línea y no cambian en toda la línea.
  fLine      := state.fLine;
  tamLin     := state.tamLin;
  //propiedades que van cambiando conforme se avanza en la exploración de la línea
  posTok     := state.posTok;
  BlkToClose := state.BlkToClose;
  posIni     := state.posIni;
  posFin     := state.posFin;
  fRange     := state.fRange;
  fTokenID   := state.fTokenID;
end;
constructor TSynFacilComplet.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CaseSensComp := false;  //por defecto
  CompletionOn := true;  //activo por defecto
  EnterSelect := true;
  AvailItems := TStringList.Create;  //crea lista
  vKey := 0;     //limpia
  utKey := '';   //limpia
end;
destructor TSynFacilComplet.Destroy;
begin
  if MenuComplet<>nil then MenuComplet.Destroy;  //por si no lo liberaron
  AvailItems.Destroy;
  inherited Destroy;
end;

end.

