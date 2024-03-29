{Frame que contiene un control similar a un TPageControl pero que abre ventanas de
sesión (un panel de texto y una pantalla de Terminal.)
Este frame es similar al usado en los compiladores PicPas y P65Pas.}
unit FrameTabSessions;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, LazUTF8, LazFileUtils, Forms, Controls, Dialogs,
  ComCtrls, ExtCtrls, Graphics, LCLProc, Menus, LCLType, StdCtrls,
  fgl, Types, SynEdit, SynEditKeyCmds, Globales,
  uResaltTerm, FrameTabSession, SynFacilUtils, SynFacilBasic, MisUtils;
type
  { TPage }
  TPage = class
    procedure SetVisible(state: boolean); virtual; abstract;
  end;
  TRecentLinks = specialize TFPGObjectList<TLabel>;

  TSessionTabEvent = procedure(ed: TfraTabSession) of object;
  { TfraTabSessions }
  TfraTabSessions = class(TFrame)
  published
    ImgCompletion: TImageList;
    lblNewSession: TLabel;
    lblOpenSession: TLabel;
    lblRecents: TLabel;
    mnCloseOthers: TMenuItem;
    mnCloseAll: TMenuItem;
    mnNewTab: TMenuItem;
    mnCloseTab: TMenuItem;
    mnNewTab1: TMenuItem;
    OpenDialog1: TOpenDialog;
    panHeader: TPanel;
    Panel2: TPanel;
    panContent: TPanel;
    PopUpTabs: TPopupMenu;
    UpDown1: TUpDown;
    procedure lblNewSessionMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblNewSessionMouseEnter(Sender: TObject);
    procedure lblNewSessionMouseLeave(Sender: TObject);
    procedure lblOpenSessionMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblOpenSessionMouseEnter(Sender: TObject);
    procedure lblOpenSessionMouseLeave(Sender: TObject);
    procedure lblRecentsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure lblRecentsMouseEnter(Sender: TObject);
    procedure lblRecentsMouseLeave(Sender: TObject);
    procedure mnCloseOthersClick(Sender: TObject);
    procedure mnCloseAllClick(Sender: TObject);
    procedure mnCloseTabClick(Sender: TObject);
    procedure mnNewTabClick(Sender: TObject);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
  private  //Métodos para dibujo de las lenguetas
    xIniTabs : integer;  //Coordenada inicial desde donde se dibujan las lenguetas
    tabDrag  : integer;
    tabSelec : integer;
    procedure lblRecentLinkClick(Sender: TObject);
    procedure MakeActiveTabVisible;
    procedure Panel1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Panel1DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure Panel1EndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure RefreshTabs;
    procedure SetTabIndex(AValue: integer);
    procedure DibLeng(x1, x2: integer; coltex: TColor; Activo: boolean; txt: string
      );   //dibuja una lengueta
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UpdateX1CoordTabs;
    procedure Panel1Paint(Sender: TObject);
    procedure InitTabs;
  private
    FTabIndex  : integer;
    recentLinks: TRecentLinks;  //Lista de enlaces para archivos recientes.
    showRecents: boolean;
    function LastIndex: integer;
    function NewName(prefix, ext: string): string;
    procedure DeleteEdit;
  public  //Manejo de pestañas y páginas
    pages    : TPages;
    property TabIndex: integer read FTabIndex write SetTabIndex;   //panel actualmente activo
    function Count: integer;
    function ActivePage: TfraTabSession;
    function SearchEditorIdxByTab(tabName: string): integer;
    procedure SelectNextEditor;
    procedure SelectPrevEditor;
    function HasFocus: boolean;
    procedure SetFocus; override;
    procedure UpdateTabWidth(pag: TfraTabSession);
  public  //Eventos
    OnSelectEditor: procedure of object;  //Cuando cambia la selección de editor
    OnRequireSynEditConfig: procedure(ed: TsynEdit) of object;
    OnRequireSetCompletion: procedure(ed: TfraTabSession) of object;
  public
    {Evento general asociado a una página del control.
    El parámetro "event" es una cadena con el nombre del evento.
    La página se pasa en "page" como "TObject" para soportar cualquier tipo de "frame"
    como página.
    El parámetro "res" es la respuesta que se da al evento.}
    OnPageEvent: procedure(event: string; page: TObject; out res: string) of object;
    procedure PageEvent(event: string; page: TObject; out res: string);
  public  //Administración de páginas
    tmpPath: string;  //ruta usada para crear archivos temporales para los editores
    function AddPage(ext: string): TfraTabSession;
    function ClosePage: boolean;
    function CloseAll(out lstClosedFiles: string): boolean;
  public   //Inicialización
    procedure UpdateSynEditConfig;
    procedure UpdateSynEditCompletion;
    procedure UpdateRecents(recents: TStringList);
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetLanguage;
  end;

implementation
{$R *.lfm}
const
  SEPAR_TABS = 2;  //Separación adicional, entre pestañas
  WIDTH_ADD_TAB = 40;  //Ancho de botón "Agregar página"

{ TfraTabSessions }
procedure TfraTabSessions.SetLanguage;
begin
  //{$I ..\language\tra_FrameEditView.pas}
end;
procedure TfraTabSessions.RefreshTabs;
begin
  if pages.Count=0 then begin
    panHeader.Visible := false;
  end else begin
    panHeader.Visible := true;
  end;
  panHeader.Invalidate;   //para refrescar
  //Botones de desplazamiento horizontal
  if pages.Count > 1 then begin
    UpDown1.Enabled := true;
  end else begin
    UpDown1.Enabled := false;
  end;
end;
procedure TfraTabSessions.SetTabIndex(AValue: integer);
{Define la sesión que se hará visible}
var
  res: string;
begin
  if AValue>pages.Count-1 then AValue := pages.Count-1;
  if FTabIndex = AValue then Exit;
  if FTabIndex<>-1 then begin  //Que no sea la primera vez
    pages[FTabIndex].SetHide;  //Oculta la sesión anterior.
  end;
  FTabIndex := AValue;   //cambia valor
//  pages[FTabIndex].Visible := true;  //Muestra la nueva sesión.
  PageEvent('req_activate', pages[FTabIndex], res);
  if OnSelectEditor<>nil then OnSelectEditor;  //Dispara evento.

  RefreshTabs;
end;
//Métodos pàra el dibujo de lenguetas
procedure TfraTabSessions.DibLeng(x1, x2: integer; coltex: TColor; Activo: boolean;
  txt: string);
{Dibuja la lengueta en la posición indicada. Si "txt" es '+', se dibuja la lengueta
para agregar página.}
  procedure GetX1X2(const xrmin: integer; y: integer; out xr1, xr2: integer);
  {devuelve las coordenadas x1 y x2 de la línea "y" de la lengueta}
  begin
    case y of
    0: begin  //Primera fila
        xr1 := x1+4;
        xr2 := xrmin -4;
      end;
    1: begin
        xr1 := x1+2;
        xr2 := xrmin -2;
      end;
    2: begin
        xr1 := x1+1;
        xr2 := xrmin ;
      end;
    3: begin
        xr1 := x1+1;
        xr2 := xrmin + 1;
      end;
    else  //otras filas
      xr1 := x1;
      xr2 := xrmin + (y div 2);
    end;
  end;
var
  cv: TCanvas;
  y1, y2, alto, xr1, xr2, xrmin, xrmin2, i: Integer;
  r: TRect;
  colBorde: TColor;
begin
  //Lee coordenadas horizontales
  alto := panHeader.Height;
  y1 := 0;
  y2 := y1 + alto;
  //Inicia dibujo
  cv := panHeader.canvas;
  cv.Font.Size:= FONT_TAB_SIZE;
  cv.Font.Bold := false;
  cv.Font.Color := clBlack;
  cv.Font.Color := coltex;   //Color de texto
  //Fija Línea y color de fondo
  cv.Pen.Style := psSolid;
  cv.Pen.Width := 1;
  if Activo then cv.Pen.Color := clWhite else cv.Pen.Color := clMenu;
  //Dibuja fondo de lengueta. El dibujo es línea por línea
  xrmin := x2 - (alto div 4);    //Corrige inicio, para que el punto medio de la pendiente, caiga en x2.
  xrmin2 := x2 + (alto div 4)+1; //Corrige inicio, para que el punto medio de la pendiente, caiga en x2.
  for i:=0 to alto-1 do begin
    GetX1X2(xrmin, i, xr1, xr2);
    cv.Line(xr1, i, xr2, i);
  end;
  //Dibuja borde de lengueta
  colBorde := clGray;
  cv.Pen.Color := colBorde;
  cv.Line(x1,y1+4,x1,y2);  //lateral izquierdo
  cv.Line(x1+4,y1, xrmin-4, y1);  //superior
  cv.Line(xrmin+2, y1+4, xrmin2, y2);  //lateral derecho
  //Bordes
  GetX1X2(xrmin, 0, xr1, xr2);
  cv.Pixels[xr1,0] := colBorde;
  cv.Pixels[xr2,0] := colBorde;
  GetX1X2(xrmin, 1, xr1, xr2);
  cv.Pixels[xr1,1] := colBorde;
  cv.Pixels[xr1+1,1] := colBorde;
  cv.Pixels[xr2,1] := colBorde;
  cv.Pixels[xr2-1,1] := colBorde;
  GetX1X2(xrmin, 2, xr1, xr2);
  cv.Pixels[xr1,2] := colBorde;
  cv.Pixels[xr2,2] := colBorde;
  cv.Pixels[xr2-1,2] := colBorde;
  GetX1X2(xrmin, 3, xr1, xr2);
  cv.Pixels[xr1,3] := colBorde;
  cv.Pixels[xr2,3] := colBorde;
  if txt = '+' then begin  //Lengueta para agregar
    //Elimina objetos y pone texto
    r.Top := y1;
    r.Bottom := y2;
    r.Left := x1+8;  //Deja espacio para el ícono
    r.Right := x2-7;  //Deja espacio para el botón de cierre
    cv.Font.Size:= 12;
    cv.Font.Bold := true;
    cv.TextRect(r, x1+13, 0, '+');
  end else begin  //Lengueta normal
    //Dibuja ícono
    ImgCompletion.Draw(cv, x1+4, 6, 1);
    //Elimina objetos y pone texto
    r.Top := y1;
    r.Bottom := y2;
    r.Left := x1+20;  //Deja espacio para el ícono
    r.Right := x2-7;  //Deja espacio para el botón de cierre
    cv.TextRect(r, x1+23, 4 ,txt);
  end;
end;
procedure TfraTabSessions.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  x2, i: Integer;
  edi: TfraTabSession;
  res: string;
begin
  {Se asuma que las lenguetas ya tienen su coordenada x1, actualizada, porque ya
  han sido dibujadas, así que no llamaremos a UpdateX1CoordTabs.}
  for i := 0 to pages.Count-1 do begin
    edi := pages[i];
    x2 := edi.x1 + edi.tabWidth;
    if (X>edi.x1) and (X<x2) then begin
      TabIndex := i;  //Selecciona
      if Shift = [ssRight] then begin
        PopUpTabs.PopUp;
      end else if Shift = [ssMiddle] then begin
        //Cerrar el archivo
        ClosePage;
      end else if Shift = [ssLeft] then begin
        //Solo selección
        MakeActiveTabVisible;
        //Inicia el arrastre
        panHeader.BeginDrag(false, 10);
        tabDrag := i;  //gaurda el índice del arrastrado
      end;
      exit;
    end;
  end;
  //Verifica si se pulsó en el botón '+'
  if pages.Count>0 then begin  //Solo cuando se dibuja.
    if (X>x2) and (X<x2 + WIDTH_ADD_TAB) then begin
      PageEvent('req_new_page', nil, res);
      SetFocus;
    end;
  end;
end;
procedure TfraTabSessions.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
//  debugln('Move');
end;
procedure TfraTabSessions.Panel1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  x2, i, x2Mid: Integer;
  edi: TfraTabSession;
begin
  Accept := true;
  //Ve a cual lengüeta selecciona
  tabSelec := -1;
  for i := 0 to pages.Count-1 do begin
    edi := pages[i];
    x2Mid := edi.x1 + edi.tabWidth div 2;
    x2 := edi.x1 + edi.tabWidth;
    if (X>edi.x1) and (X<x2) then begin
      if X<x2Mid then begin
        //Está en la primera mitad.
        tabSelec := i;  //Selecciona
      end else begin
        //En la mitad final, selecciona el siguiente
        tabSelec := i+1;  //Selecciona
      end;
    end;
  end;
  //Genera marca en la lengüeta
  if tabSelec<>-1 then begin
//    debugln('leng selec: %d', [tabselec]);
    panHeader.Invalidate;
  end;
end;
procedure TfraTabSessions.Panel1EndDrag(Sender, Target: TObject; X, Y: Integer);
{Se termina el arrastre, sea que se soltó en alguna parte, o se canceló.}
begin
  tabSelec := -1;
  panHeader.Invalidate;
end;
procedure TfraTabSessions.Panel1DragDrop(Sender, Source: TObject; X, Y: Integer);
{Se soltó la lengueta en el panel.}
begin
  if TabIndex<0 then exit;
  if tabSelec<0 then exit;
  //Corrección
  if tabSelec>TabIndex then tabSelec := tabSelec-1;
  if tabSelec>pages.Count-1 then exit;
//  debugln('Panel1DragDrop: %d a %d', [TabIndex, tabSelec]);
  pages.Move(TabIndex, tabSelec);
  TabIndex := tabSelec;
  panHeader.Invalidate;
end;
procedure TfraTabSessions.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //Pasa el enfoque al editor que se ha seleccionado
  if TabIndex=-1 then exit;
  try
    if pages[TabIndex].Visible  then begin  //Si el "frame" es visible.
      pages[TabIndex].edPCom.SetFocus;
    end;
  except

  end;
end;
procedure TfraTabSessions.UpdateX1CoordTabs;
{Actualiza la coordenada x1, de las lenguetas, considerando el valor actual de
"xIniTabs". El valor x1, representa la coordenada en que se dibuajaría la lengueta.}
var
  i, x1: integer;
  pag: TfraTabSession;
begin
  {Este algoritmo debe ser igual a Panel1Paint(), para que no haya inconsistencias.}
  x1 := xIniTabs;
  for i := 0 to pages.Count-1 do begin
    pag := pages[i];
    pag.x1 := x1;   //Actualiza coordenada
    //Calcula siguiente coordenada
    x1 := x1 + pag.tabWidth + SEPAR_TABS;
  end;
end;
procedure TfraTabSessions.MakeActiveTabVisible;
{Configura "xIniTabs", de modo que haga visible la pestaña del editor activo.
Solo trabaja sobre la prestaña o lengueta. No maneja a la ventana de la sesión.}
var
  x1, x2: integer;
begin
  if Count=0 then exit;
  UpdateX1CoordTabs;
  x1 := ActivePage.x1;
  x2 := ActivePage.x1 + ActivePage.tabWidth;
  if x2 > self.Width then begin
    //Pestaña sale de página, por la derecha
    xIniTabs := xIniTabs - (x2-self.Width);
  end else if x1 < Panel2.Width then begin
    //Pestaña sale de página, por la izquierda
    xIniTabs := xIniTabs + (Panel2.Width - x1);
  end else begin
//    debugln('Pestaña se dibuja adentro');
  end;
end;
procedure TfraTabSessions.Panel1Paint(Sender: TObject);
var
  i, x1, xfin: Integer;
  cv: TCanvas;
  pag: TfraTabSession;
begin
  //Actualiza coordenadas
  UpdateX1CoordTabs;
  //Dibuja las pestañas
  for i := 0 to pages.Count-1 do begin
    pag := pages[i];
    if i <> TabIndex then begin
      //Dibuja todo menos al activo, lo deja para después.
      DibLeng(pag.x1, pag.x1 + pag.tabWidth, clBlack, false, pag.Caption);
    end;
  end;
  //Dibuja lengueta "+"
  if pages.Count>0 then begin
    //Solo se dibuja si hay página seleccionada.
    pag := pages[pages.Count-1];  //ültima página
    xfin := pag.x1 + pag.tabWidth;
    DibLeng(xfin, xfin + WIDTH_ADD_TAB, clBlack, false, '+');
  end;

  //Dibuja al final al activo, para que aparezca encima
  if TabIndex<>-1 then begin
    pag := pages[TabIndex];
    DibLeng(pag.x1, pag.x1 + pag.tabWidth, clBlack, true, pag.Caption);
  end;

  //Dibuja la marca de movimiento de lengüeta
  if (tabSelec>=0) and (tabSelec<pages.Count) then begin
    pag := pages[tabSelec];
    x1 := pag.x1+2;
    cv := panHeader.canvas;
    cv.Pen.Width := 5;
    cv.Pen.Color := clGray;
    cv.Line(x1 ,0, x1, panHeader.Height);
  end else if tabSelec = pages.Count then begin
    //Se marca al final de la última pestaña
    pag := pages[pages.Count-1];  //el útlimo
    x1 := pag.x1 + pag.tabWidth +2;
    cv := panHeader.canvas;
    cv.Pen.Width := 5;
    cv.Pen.Color := clGray;
    cv.Line(x1 ,0, x1, panHeader.Height);
  end;
end;
procedure TfraTabSessions.UpdateTabWidth(pag: TfraTabSession);
var
  w: Integer;
begin
  panHeader.Canvas.Font.Size := FONT_TAB_SIZE;  {Fija atrubutos de texto, para que el
                                        cálculo con "TextWidth", de ancho sea correcto}
  w := panHeader.Canvas.TextWidth(pag.Caption) + 30;
  if w < MIN_WIDTH_TAB then w := MIN_WIDTH_TAB;
  pag.tabWidth := w;
  panHeader.Invalidate;   //Para refrescar el dibujo
end;
procedure TfraTabSessions.PageEvent(event: string; page: TObject; out
  res: string);
{Forma corta de llamar al evento OnPageEvent. }
begin
  if OnPageEvent=nil then begin
    //Fija salida por seguridad.
    res := '';
  end else begin
    //Llama al evento
    OnPageEvent(event, page, res);
  end;
end;
procedure TfraTabSessions.InitTabs;
{Configura eventos para el control de las lenguetas}
begin
  xIniTabs := panel2.Width;  //Empeiza dibujando al lado de las flechas
  panHeader.OnMouseMove := @Panel1MouseMove;
  panHeader.OnMouseDown := @Panel1MouseDown;
  panHeader.OnMouseUp   := @Panel1MouseUp;
  panHeader.OnDragOver := @Panel1DragOver;
  panHeader.OnDragDrop := @Panel1DragDrop;
  panHeader.OnEndDrag := @Panel1EndDrag;
end;
//////////////////////////////////////////////////////////////
function TfraTabSessions.LastIndex: integer;
{Devuelve el índice de la última pestaña.}
begin
  Result :=pages.Count - 1;
end;
function TfraTabSessions.NewName(prefix, ext: string): string;
{Genera un nombre de archivo, a partir de "prefix", que no se repita entre las pestañas
abiertas y que no exista en disco.}
var
  n: Integer;
begin
  n := 0;
  repeat
    inc(n);
    Result := prefix + IntToStr(n) + ext;
  until (SearchEditorIdxByTab(Result)=-1) and (not FileExists(Result));
end;
function TfraTabSessions.AddPage(ext: string): TfraTabSession;
{Agrega una nueva ventana de eición a la vista, y devuelve la referencia.}
var
  page: TfraTabSession;
  res: string;
begin
  //Crea página.
  page := TfraTabSession.Create(nil);  //No se define "Owner" porque se administrará dentro de muestra propia lista.
  page.Parent := self.panContent;
  page.Align := alClient;
  page.Name := 'Page'+IntToStr(pages.Count);  //Nombre único. Se usaría NewName(ext), pero incuye un caracter punto.
  page.Caption := NewName('Page', ext); //Fija nombre de la pestaña. El nombre del archivo lo decidirá el frame.
  UpdateTabWidth(page);  //Cambia el título Hay que actualizar ancho de lengueta.
  pages.Add(page);     //Agrega a la lista.
  //Evento de requerimiento de inicialización de página.
  PageEvent('req_init', page, res);
  //Activa la página. Debe hacerse después de llamar a 'req_init'.
  TabIndex := LastIndex; //Selecciona la última sesión agregada
  //Configura desplazamiento para asegurarse que la pestaña se mostrará visible.
  MakeActiveTabVisible;
  //Actualiza referencias.
  Result := page;
end;
procedure TfraTabSessions.DeleteEdit;
{Elimina al editor activo.}
begin
  if TabIndex=-1 then exit;
  pages.Delete(TabIndex);
  //Hay que actualiza TabIndex
  if pages.Count = 0 then begin
    //Era el único
    FTabIndex := -1;
  end else begin
    //Había al menos 2
    if TabIndex > pages.Count - 1 then begin
      //Quedó apuntando fuera
      FTabIndex := pages.Count - 1;   //limita
      //No es necesario ocultar el anterior, porque se eliminó
      pages[FTabIndex].Visible := true;  //muestra el nuevo
    end else begin
      //Queda apuntando al siguiente. No es necesario modificar.
      //No es necesario ocultar el anterior, porque se eliminó
      pages[FTabIndex].Visible := true;  //muestra el nuevo
    end;
  end;
  MakeActiveTabVisible;
  if OnSelectEditor<>nil then OnSelectEditor;
  RefreshTabs;
end;
///Manejo de pestañas
function TfraTabSessions.Count: integer;
begin
  Result := pages.Count;
end;
function TfraTabSessions.ActivePage: TfraTabSession;
{Devuelve el editor SynEditor, activo, es decir el que se encuentra en la lengueta
activa. }
var
  i: Integer;
begin
  if pages.Count = 0 then exit(nil);
  i := TabIndex;
  Result := pages[i];   //Solo funcionará si no se desordenan las enguetas
end;
function TfraTabSessions.SearchEditorIdxByTab(tabName: string): integer;
var
  ed: TfraTabSession;
  i: integer;
begin
  for i:=0 to pages.Count-1 do begin
    ed := pages[i];
    if Upcase(ed.Caption) = UpCase(tabName) then exit(i);
  end;
  exit(-1);
end;
procedure TfraTabSessions.SelectNextEditor;
{Selecciona al siguiente editor.}
begin
  if Count = 0 then exit;
  if TabIndex=-1 then exit;
  if TabIndex = LastIndex then TabIndex := 0 else TabIndex := TabIndex + 1;
  SetFocus;
  MakeActiveTabVisible;
end;
procedure TfraTabSessions.SelectPrevEditor;
{Selecciona al editor anterior.}
begin
  if Count = 0 then exit;
  if TabIndex=-1 then exit;
  if TabIndex = 0 then TabIndex := LastIndex else TabIndex := TabIndex -1;
  SetFocus;
  MakeActiveTabVisible;
end;
function TfraTabSessions.HasFocus: boolean;
{Indica si alguno de los editores, tiene el enfoque.}
var
  i: Integer;
begin
  for i:=0 to pages.Count-1 do begin
    if pages[i].edPCom.Focused then exit(true);
  end;
  exit(false);
end;
procedure TfraTabSessions.SetFocus;
begin
//  inherited SetFocus;
  if TabIndex = -1 then exit;
  if pages[TabIndex].Visible then begin  //Si el "frame" es visible.
    pages[TabIndex].edPCom.SetFocus;
  end;
end;
function TfraTabSessions.ClosePage: boolean;
{Cierra la página actual.
Si se cierra la página, o no hay página actual, se devuelve TRUE.
Si no se puede cerrar, devuelve FALSE}
var
  res: string;
begin
  if ActivePage=nil then exit(true);
  PageEvent('query_close', ActivePage, res);
  if (res='N') or (res='') then exit(false);  //Cancelado. No se debe cerrar.
  //Hay que proceder con el cierre
  DeleteEdit;
  exit(true);
end;
function TfraTabSessions.CloseAll(out lstClosedFiles: string): boolean;
{Cierra todas las ventanas, pidiendo confirmación. Si se cancela, devuelve FALSE.
Se devuelve en "lstOpenedFiles" una lista con los archivos que estaban abiertos.}
var
  res: string;
begin
  lstClosedFiles := '';
  while pages.Count>0 do begin
    lstClosedFiles := lstClosedFiles + ActivePage.ePCom.FileName + LineEnding;
    if ActivePage = nil then exit(true);
    PageEvent('query_close', ActivePage, res);
    if (res='N') or (res='') then exit(false);  //Cancelado. No se debe cerrar.
    DeleteEdit;
  end;
  exit(true);
end;
//Inicialización
procedure TfraTabSessions.UpdateSynEditConfig;
{Indica que se desea cambiar la configuración de todos los SynEdit abiertos.}
var
  i: Integer;
begin
  //Pide configuración para todos los editores abiertos
  for i:=0 to pages.Count-1 do begin
    if OnRequireSynEditConfig<>nil then begin
      OnRequireSynEditConfig(pages[i].edPCom);
    end;
  end;
end;
procedure TfraTabSessions.UpdateSynEditCompletion;
var
  i: Integer;
begin
  //Pide configurar completado para todos los editores abiertos
  for i:=0 to pages.Count-1 do begin
    if OnRequireSetCompletion<>nil then OnRequireSetCompletion(pages[i]);
  end;
end;
procedure TfraTabSessions.lblRecentLinkClick(Sender: TObject);
var
  res: string;
begin
  //MsgBox(TLabel(Sender).Caption);
  PageEvent('req_open_ses', Sender, res);
  SetFocus;
end;
procedure TfraTabSessions.UpdateRecents(recents: TStringList);
{Actualiza la lista de la sesiones recientes que se mostrará en este frame.}
var
  rec: String;
  lblRecentLink: TLabel;
  i: Integer;
begin
  i := 0;
  for rec in recents do begin
//    MsgBox(rec);
    lblRecentLink := TLabel.Create(nil);
    lblRecentLink.Name := 'lbl' + IntToStr(i);
    lblRecentLink.Visible:= false;
    lblRecentLink.Caption:= rec;
    lblRecentLink.Parent := panContent;
    lblRecentLink.left:= 70;
    lblRecentLink.Top:= 20*i + lblRecents.Top + lblRecents.Height;
    lblRecentLink.Font.Size:=11;
    lblRecentLink.Font.Color:=clBlue;
    lblRecentLink.OnClick:=@lblRecentLinkClick;
    recentLinks.Add(lblRecentLink);
    inc(i);
  end;
end;
constructor TfraTabSessions.Create(AOwner: TComponent);
begin
  inherited;
  pages:= TPages.Create(true);
  panHeader.OnPaint := @Panel1Paint;
  FTabIndex := -1;
  InitTabs;
  tabSelec := -1;
  RefreshTabs;
  recentLinks:= TRecentLinks.Create(true);
end;
destructor TfraTabSessions.Destroy;
begin
  recentLinks.Destroy;
  pages.Destroy;
  inherited Destroy;
end;
//Menú
procedure TfraTabSessions.mnNewTabClick(Sender: TObject);
var
  res: string;
begin
  PageEvent('req_new_page', nil, res);
  SetFocus;
end;
procedure TfraTabSessions.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin
  case Button of
  btNext: SelectNextEditor;
  btPrev: SelectPrevEditor;
  end;
end;
procedure TfraTabSessions.mnCloseTabClick(Sender: TObject);
begin
  ClosePage;
  SetFocus;
end;
procedure TfraTabSessions.mnCloseAllClick(Sender: TObject);
begin
  while self.Count>0 do begin
    if not ClosePage then
      break;  //Se canceló
  end;
  SetFocus;
end;
procedure TfraTabSessions.mnCloseOthersClick(Sender: TObject);
var
  nBefore, i, nAfter: Integer;
begin
  //Cierra anteriores
  nBefore := TabIndex;
  for i:= 1 to nBefore do begin
    TabIndex := 0;
    if not ClosePage then
      break;  //Se canceló
  end;
  //Cierra posteriores
  nAfter := Count - TabIndex - 1;
  for i:= 1 to nAfter do begin
    TabIndex := Count-1;
    if not ClosePage then
      break;  //Se canceló
  end;
  SetFocus;
end;
//Eventos del botón "Nueva Sesión".
procedure TfraTabSessions.lblNewSessionMouseEnter(Sender: TObject);
begin
  lblNewSession.Font.Bold := true;
end;
procedure TfraTabSessions.lblNewSessionMouseLeave(Sender: TObject);
begin
  lblNewSession.Font.Bold := false;
end;
procedure TfraTabSessions.lblNewSessionMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  res: string;
begin
  PageEvent('req_new_page', nil, res);
  SetFocus;
end;
//Eventos del botón "Abrir Sesión".
procedure TfraTabSessions.lblOpenSessionMouseEnter(Sender: TObject);
begin
  lblOpenSession.Font.Bold := true;
end;
procedure TfraTabSessions.lblOpenSessionMouseLeave(Sender: TObject);
begin
  lblOpenSession.Font.Bold := false;
end;
procedure TfraTabSessions.lblOpenSessionMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  res: string;
begin
  PageEvent('req_open_page', nil, res);
  SetFocus;
end;
//Eventos del botón "Recientes".
procedure TfraTabSessions.lblRecentsMouseEnter(Sender: TObject);
begin
  lblRecents.Font.Bold := true;
end;
procedure TfraTabSessions.lblRecentsMouseLeave(Sender: TObject);
begin
  lblRecents.Font.Bold := false;
end;
procedure TfraTabSessions.lblRecentsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  lbl: TLabel;
begin
  showRecents := not showRecents;
  for lbl in recentLinks do lbl.Visible := showRecents;
end;

end.
//1482
