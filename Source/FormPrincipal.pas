{Define a la ventana de sesión. Esta ventana permite mostrar el texto que va llegando
 de un proceso. Servirá para visualizar como se interactúa con la sesión y para poder
 iniciar conexiones a sqlplus mediante el telnet.}

unit FormPrincipal;
{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, Types, FileUtil, LazUTF8, SynEdit, Forms, Controls,
  Graphics, Dialogs, Menus, ActnList, ExtCtrls, ComCtrls, SynEditKeyCmds,
  SynEditMiscClasses, LCLType, LCLProc, LCLIntf, UnTerminal, Clipbrd,
  FormConexRapida, FormConfig, FormExpRemoto, FormEditMacros, MisUtils,
  Globales, FrameCfgComandRec, SynFacilUtils, FormEditRemoto,
  FrameTabSessions, FrameTabSession, uPreBasicos, uPreProces, StrUtils;
type
  TlogState = (logStopped, logRunning, logPaused);

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
  published
    AcFilExit: TAction;
    AcFilConec: TAction;
    AcFilNewWin: TAction;
    AcToolSett: TAction;
    AcFilSavSesAs: TAction;
    AcFIlOpeSes: TAction;
    AcFilSavSes: TAction;
    AcFilNewSes: TAction;
    AcToolRecMac: TAction;
    acHlpHelp: TAction;
    acHlpAbout: TAction;
    AcVerBarEst: TAction;
    AcVerExpRem: TAction;
    AcVerEdiRem: TAction;
    AcVerEdiMac: TAction;
    ActionList1: TActionList;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    mnAyuAyu: TMenuItem;
    mnView: TMenuItem;
    mnFile: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem62: TMenuItem;
    MenuItem63: TMenuItem;
    MenuItem64: TMenuItem;
    MenuItem65: TMenuItem;
    MenuItem66: TMenuItem;
    mnSesionesAlm: TMenuItem;
    mnGraMacro: TMenuItem;
    MenuItem47: TMenuItem;
    mnAbrMacro: TMenuItem;
    mnEjecMacro: TMenuItem;
    mnHelp: TMenuItem;
    MenuItem37: TMenuItem;
    mnTools: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem40: TMenuItem;
    MenuItem5: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    procedure AcFIlOpeSesExecute(Sender: TObject);
    procedure AcFilSavSesAsExecute(Sender: TObject);
    procedure AcFilSavSesExecute(Sender: TObject);
    procedure AcFilConecExecute(Sender: TObject);
    procedure AcFilNewSesExecute(Sender: TObject);
    procedure AcFilNewWinExecute(Sender: TObject);
    procedure AcFilExitExecute(Sender: TObject);
    procedure acHlpHelpExecute(Sender: TObject);
    procedure AcToolRecMacExecute(Sender: TObject);
    procedure AcToolSettExecute(Sender: TObject);
    procedure AcVerEdiRemExecute(Sender: TObject);
    procedure AcVerBarEstExecute(Sender: TObject);
    procedure AcVerEdiMacExecute(Sender: TObject);
    procedure AcVerExpRemExecute(Sender: TObject);
    procedure edPComSpecialLineMarkup(Sender: TObject; Line: integer;
      var Special: boolean; Markup: TSynSelectedColor);
    procedure UpdateHeader;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure itemEjecMacro(Sender: TObject);
    procedure itemAbreMacro(Sender: TObject);
    procedure mnAbrMacroClick(Sender: TObject);
    procedure mnEjecMacroClick(Sender: TObject);
    procedure mnSesionesAlmClick(Sender: TObject);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure Timer1Timer(Sender: TObject);
  private
    parpadPan0: boolean;   //para activar el parpadeo del panel0
    ticComRec : integer;   //contador para comando recurrente
    TabSessions: TfraTabSessions;   //Panel de editores
    procedure AbrirSesion(fileSession: string);
    procedure ConfiguraEntorno;
    procedure TabSessionsPageEvent(event: string; page: TObject; out res: string);
    procedure InitMenuLanguages(menLanguage0: TMenuItem; LangPath0: string);
    procedure itemAbreComando(Sender: TObject);
    procedure itemAbreSesion(Sender: TObject);
    procedure MostrarBarEst(visibilidad: boolean);
    procedure MostrarBHerTerm(visibilidad: boolean);
  public
//    proc   : TConsoleProc; //referencia al proceso actual
    curProc: TConsoleProc2; //referencia al proceso actual
    ejecMac: boolean;   //indica que está ejecutando una macro
    ejecCom: boolean;   //indica que está ejecutando un comando (editor remoto, exp. remoto ...)
    function ConexDisponible: boolean;
  public  //Acciones sobre la session actual.
    function GetCurSession(out pag: TfraTabSession): boolean;
    procedure SetCurPort(port: integer);
    procedure SetCurIP(ip: string);
    procedure SetCurConnType(ctyp: TTipCon);
    procedure SetCurLineDelimSend(delim: TUtLineDelSend);
    procedure SetCurOther(txt: string);
  private  //Manejo de menús recientes
    mnRecents   : TMenuItem;  //Menú de archivos recientes
    RecentFiles : TStringList;  //Lista de archivos recientes
    MaxRecents  : integer;    //Máxima cantidad de archivos recientes
    procedure RecentClick(Sender: TObject);
    procedure ActualMenusReciente(Sender: TObject);
    procedure AddRecentFile(arch: string);
    procedure LoadLastFileEdited;
    procedure LoadListFiles(lst: string);
    procedure InitMenuRecents(menRecents0: TMenuItem; RecentList: TStringList;
      MaxRecents0: integer = 5);
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation
{$R *.lfm}
resourcestring
  MSG_NOFILES  = 'No files';
  MSG_FILE_EXT = '.ses';          //Extensión de archivo a usar.
  MSG_FILE_DES = 'Session Files';  //Descripción de archivo
  MSG_ALLFILES = 'All files';

{ TfrmPrincipal }
procedure TfrmPrincipal.InitMenuLanguages(menLanguage0: TMenuItem; LangPath0: string);
//Inicia un menú con la lista de archivos XML (que representan a lenguajes) que hay
//en una carpeta en particular y les asigna un evento.
var
  Hay: Boolean;
  SR : TSearchRec;
  mnLanguages: TMenuItem;
  LangPath: String;
begin
//  if menLanguage0 = nil then exit;
//  mnLanguages := menLanguage0;  //guarda referencia a menú
//  LangPath := LangPath0;        //guarda ruta
//  if (LangPath<>'') and (LangPath[length(LangPath)] <> DirectorySeparator) then
//     LangPath+=DirectorySeparator;
//  //configura menú
//  mnLanguages.Caption:= dic('&Lenguajes');
//  //explora archivos
//  Hay := FindFirst(LangPath + '*.xml', faAnyFile - faDirectory, SR) = 0;
//  while Hay do begin
//     //encontró archivo
//    AddItemToMenu(mnLanguages, '&'+ChangeFileExt(SR.name,''), @DoSelectLanguage);
//    Hay := FindNext(SR) = 0;
//  end;
end;
procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  ticComRec  := 0;

  ejecMac := false;

  //Inicia proceso
  StatusBar1.OnDrawPanel:=@StatusBar1DrawPanel;

  ///////////// Crea controlador de páginas
  TabSessions := TfraTabSessions.Create(self);
  TabSessions.Parent := self;
  TabSessions.Left := 0;
  TabSessions.Top := 0;
  TabSessions.Align := alClient;
  //Manejador de todos los eventos de una página
  TabSessions.OnPageEvent := @TabSessionsPageEvent;
end;
procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
end;
procedure TfrmPrincipal.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
begin
  //Carga archivo arrastrados
//  if ePCom.SaveQuery then Exit;   //Verifica cambios
//  ePCom.LoadFile(FileNames[0]);
end;
procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  TranslateMsgs := true;  //activa la traducción en los mensajes
  Config.SetLanguage('en');
  frmEditRemoto.SetLanguage('en');
  frmEditMacros.Init(TabSessions);
  Caption := NOM_PROG + ' ' + VER_PROG;
  //aquí ya sabemos que Config está creado. Lo configuramos
  //Config.edTerm := edTerm;  //pasa referencia de editor.
//  Config.edPCom := edPCom;  //pasa referencia de Panel de comando
  Config.edMacr := frmEditMacros.ed;
  COnfig.edRemo := frmEditRemoto.ed;

  Config.Iniciar();  //Inicia la configuración
  ConfiguraEntorno;
  //muestra dirección IP actual
  //ActualizarInfoPanel0;
  //actualiza menús
  mnSesionesAlmClick(self);
  mnEjecMacroClick(self);
  mnAbrMacroClick(self);

  UpdateHeader; //para actualizar barra de título
end;
procedure TfrmPrincipal.UpdateHeader;
var
  pag: TfraTabSession;
begin
  //Actualiza encabezado
  if GetCurSession(pag) then begin
    Caption := NOM_PROG + '-' + VER_PROG + ' - ' + pag.FileName;
  end else begin
    Caption := NOM_PROG;
  end;
end;
procedure TfrmPrincipal.edPComSpecialLineMarkup(Sender: TObject; Line: integer;
  var Special: boolean; Markup: TSynSelectedColor);
begin
//vacío
end;
//procedure TfrmPrincipal.PopupMenu1Popup(Sender: TObject);  //abre menú contextual
////prepara el menú de "lenguajes", en el menú contextual
//begin
//  CopiarMemu(mnLenguajes, mnPopLeng);
//end;

/////////////// Funciones para manejo de macros///////////////
procedure TfrmPrincipal.mnSesionesAlmClick(Sender: TObject);
begin
  mnSesionesAlm.Clear;
  LeeArchEnMenu(patSesiones + DirectorySeparator +'*.ses', mnSesionesAlm,@itemAbreSesion);
end;
procedure TfrmPrincipal.mnEjecMacroClick(Sender: TObject);
begin
  mnEjecMacro.Clear;
  LeeArchEnMenu(config.fcRutArc.macros + DirectorySeparator +'*.ttm', mnEjecMacro,@itemEjecMacro);
end;
procedure TfrmPrincipal.mnAbrMacroClick(Sender: TObject);
begin
  mnAbrMacro.Clear;
  LeeArchEnMenu(config.fcRutArc.macros + DirectorySeparator +'*.ttm', mnAbrMacro,@itemAbreMacro);
end;
procedure TfrmPrincipal.AbrirSesion(fileSession: string);
//Abre una sesión
var
  pag: TfraTabSession;
  i: Integer;
begin
//  //Actualiza menús
//  mnSesionesAlmClick(self);  //Actualiza menú "Sesiones almacenadas"
//  mnEjecMacroClick(self);
//  mnAbrMacroClick(self);
//  ConfiguraEntorno;

  //Si es ruta relativa, la vuelve absoluta.
  if Pos(DirectorySeparator, fileSession) = 0 then begin
    fileSession := patApp + fileSession;
  end;
  //Verifica si ya está abierto
  for i:=0 to TabSessions.pages.Count-1 do begin
    pag := TabSessions.pages[i];
    if UpCase(pag.fileName) = fileSession then begin
      //Ya está abierto
      TabSessions.TabIndex := i;  //Selecciona
      exit;
    end;
  end;
  //Crea nueva página
  pag := TabSessions.AddPage(MSG_FILE_EXT);
  pag.fileName := fileSession;
  //Carga archivo
  pag.LoadFromFile;  //Podría generar error.
  //Actualiza la barra de título.
  UpdateHeader;
end;
procedure TfrmPrincipal.itemAbreSesion(Sender: TObject);
begin
  AbrirSesion(patSesiones + DirectorySeparator + TMenuItem(Sender).Caption);
end;
procedure TfrmPrincipal.itemAbreComando(Sender: TObject);
var
  tmp: String;
begin
  tmp := config.fcRutArc.scripts + DirectorySeparator + TMenuItem(Sender).Caption;
  //ePCom.LoadFile(tmp);
end;
procedure TfrmPrincipal.itemEjecMacro(Sender: TObject);
//Ejecuta la macro elegida
begin
  frmEditMacros.Ejecutar(config.fcRutArc.macros + DirectorySeparator + TMenuItem(Sender).Caption);
end;
procedure TfrmPrincipal.itemAbreMacro(Sender: TObject);
begin
  frmEditMacros.Show;
  frmEditMacros.Abrir(config.fcRutArc.macros + DirectorySeparator + TMenuItem(Sender).Caption);
end;
procedure TfrmPrincipal.ConfiguraEntorno;
//Configura el entorno (IDE) usando variables globales
begin
  //Inicia visibilidad de paneles. Estas son propiedades del entrono, no de un editor en particular
  MostrarBHerTerm(Config.VerBHerTerm);
  MostrarBarEst(Config.VerBarEst);
//  MostrarPanCom(Config.VerPanCom);
//  MostrarPanBD(VerPanBD);
//  MostrarVEnSes(VerVenSes);
end;
procedure TfrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
     case Key of
     VK_TAB: if Shift = [ssCtrl] then begin  //Ctrl+Tab
         //edterm.SetFocus;  //pasa el enfoque
       end;
     end;
end;
procedure TfrmPrincipal.FormKeyPress(Sender: TObject; var Key: char);
//Aaquí se interceptan el teclado a los controles
begin
//  if edTerm.Focused then begin
//    proc.Send(Key);
////    debugln('KeyPress:'+Key);
//  end;
end;
procedure TfrmPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  Config.escribirArchivoIni;  //guarda configuración
end;
procedure TfrmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  rpta: Byte;
  lstClosedFiles: string;
begin
  if ejecMac then begin
    if MsgYesNo('En este momento, se está ejecutando una macro. ¿Detenerla?') = 1 then begin
      frmEditMacros.DetenerEjec;
      exit;
    end;
    canClose := false;  //cancela el cierre
  end;
  //Prueba cerrando todas las ventanas
  if not TabSessions.CloseAll(lstClosedFiles) then begin
    canClose := false;  //Se canceló
  end;
end;
procedure TfrmPrincipal.StatusBar1DrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
begin
  if panel.Index = 0 then begin
    if ejecMac then begin
      if parpadPan0 then begin
//        StatusBar.Canvas.Font.Bold := true;
        StatusBar.Canvas.Font.Color:=clBlue;
        StatusBar.Canvas.Pen.Color := clWhite;
        StatusBar.Canvas.Brush.Color := clWhite;
        StatusBar.Canvas.Rectangle(Rect);
        StatusBar.Canvas.TextRect(Rect, 2 + Rect.Left, 2 + Rect.Top, dic('Ejecutando macro'));
      end else begin
//        StatusBar.Canvas.Font.Bold := true;
        StatusBar.Canvas.Font.Color:=clWhite;
        StatusBar.Canvas.Pen.Color := clBlue;
        StatusBar.Canvas.Brush.Color := clBlue;
        StatusBar.Canvas.Rectangle(Rect);
        StatusBar.Canvas.TextRect(Rect, 2 + Rect.Left, 2 + Rect.Top, dic('Ejecutando macro'));
      end;
    end else begin
      StatusBar.Canvas.Font.Color:=clBlack;
//      StatusBar.Canvas.Font.Bold := true;
      StatusBar.Canvas.TextRect(Rect, 2 + Rect.Left, 2 + Rect.Top, StatusBar1.Panels[0].Text);
    end;
  end;
  if panel.Index = 1 then begin
    if curProc<>nil then begin
      curProc.DrawStatePanel(StatusBar.Canvas, Rect);
    end;
  end;
end;
procedure TfrmPrincipal.TabSessionsPageEvent(event: string; page: TObject; out res: string);
var
  pag: TfraTabSession;
begin
  pag := TfraTabSession(page);
  res := '';  //Por defecto
  case event of
  'req_init': begin  //Solicitud de inicialización de página
    pag.Init();
  end;
  'req_activate': begin //Solicita activar la página
    pag.Activate();
  end;
  'req_conn_gui': begin  //Una sesión requiere conectarse a la GUI, para mostrar información o su estado.
    curProc := pag.proc;  //Apunta al proceso actual. Usado para refrescar StatusBar1
    pag.proc.panelState    := StatusBar1.Panels[1];
    pag.PanInfoConn        := StatusBar1.Panels[0];
    pag.ePCom.PanCursorPos := StatusBar1.Panels[2];
    pag.ePCom.PanLangName  := StatusBar1.Panels[4];
    UpdateHeader;  //Actualiza encabezado.
  end;
  'query_close': begin  //Se consulta antes de cerrar una ventana
    if pag.queryClose then begin
      //SE va a cerrar.
      res := 'Y';
      //Verfica si se va a eliminar al que apuntamos con "curProc".
      if curProc = pag.proc then curProc := nil;
    end  else begin
      res := 'N';
    end;
  end;
  'reg_def_ext': begin  //Se pide extensión por defecto para archivos.
    res := MSG_FILE_EXT;
  end;
  'req_filt_save': begin  //Se pide el filtro del diálogo "Save as...".
     res := MSG_FILE_DES + '|*' + MSG_FILE_EXT + '|' +
            MSG_ALLFILES + '|*.*'
  end;
  'reg_rec_file': begin  //Se pide registrar archivo en el histórico
    //AddRecentFile(pag.FileName);
  end;
  'req_new_page': begin  //Se pide agregar una nueva página. Desde el menú de las lenguetas.
     AcFilNewSesExecute(self);
  end;
  end;
end;
procedure TfrmPrincipal.Timer1Timer(Sender: TObject);
//Temporizador cada de 0.5 segundos
begin
  //Muestra mensaje de ejecución
  if ejecMac then begin
    //fuerza refresco del panel
    parpadPan0 := not parpadPan0;  //para el parpadeo
    StatusBar1.InvalidatePanel(0,[ppText]);
  end;
end;
procedure TfrmPrincipal.MostrarBHerTerm(visibilidad: boolean);
//Solo por esta función se debe cambiar la visibilidad de la barra de herramientas
begin
  //tbTerm.Visible:=visibilidad;
  //AcTerVerBHer.Checked:=visibilidad;
  Config.VerBHerTerm :=visibilidad; //Actualiza variable global}
  Config.escribirArchivoIni; //guarda cambio
end;
procedure TfrmPrincipal.MostrarBarEst(visibilidad:boolean );
//Solo por esta función se debe cambiar la visibilidad de la barra de estado
begin
   StatusBar1.Visible:=visibilidad;
   AcVerBarEst.Checked:=visibilidad;
   Config.VerBarEst :=visibilidad; //Actualiza variable global
   Config.escribirArchivoIni; //guarda cambio
end;
function TfrmPrincipal.ConexDisponible: boolean;
//Indica si la conexión está en estado ECO_READY, es decir, que puede
//recibir un comando
var
  pag: TfraTabSession;
begin
  if not GetCurSession(pag) then exit(false);
  Result := (pag.proc.state = ECO_READY);
end;
//Acciones sobre la session actual.
function TfrmPrincipal.GetCurSession(out pag: TfraTabSession): boolean;
{Devuelve en "pag" la referencia a la sesión actual. Si no hay sesión actual,
devuelve FALSE.}
begin
  if TabSessions.TabIndex = -1 then exit(false);
  pag := TabSessions.ActivePage;
  exit(true);
end;
procedure TfrmPrincipal.SetCurPort(port: integer);
begin
  if TabSessions.TabIndex = -1 then exit;
  TabSessions.ActivePage.Port := IntToStr(port);
  TabSessions.ActivePage.UpdateCommand;
end;
procedure TfrmPrincipal.SetCurIP(ip: string);
begin
  if TabSessions.TabIndex = -1 then exit;
  TabSessions.ActivePage.IP := ip;
  TabSessions.ActivePage.UpdateCommand;
end;
procedure TfrmPrincipal.SetCurConnType(ctyp: TTipCon);
begin
  if TabSessions.TabIndex = -1 then exit;
  TabSessions.ActivePage.Tipo := ctyp;
  TabSessions.ActivePage.UpdateCommand;
end;
procedure TfrmPrincipal.SetCurLineDelimSend(delim: TUtLineDelSend);
begin
  if TabSessions.TabIndex = -1 then exit;
  TabSessions.ActivePage.LineDelimSend := delim;
  TabSessions.ActivePage.UpdateCommand;  { TODO : ¿Es necesario? }
end;
procedure TfrmPrincipal.SetCurOther(txt: string);
begin
  if TabSessions.TabIndex = -1 then exit;
  TabSessions.ActivePage.Other := txt;
  TabSessions.ActivePage.UpdateCommand;
end;
procedure TfrmPrincipal.RecentClick(Sender: TObject);
//Se selecciona un archivo de la lista de recientes
var
  cap, recFile: string;
begin
  cap := TMenuItem(Sender).Caption;
  recFile := MidStr(cap, 4,150);
  if not FileExists(recFile) then exit;
  AbrirSesion(recFile);
end;
procedure TfrmPrincipal.ActualMenusReciente(Sender: TObject);
{Actualiza el menú de archivos recientes con la lista de los archivos abiertos
recientemente. }
var
  i: Integer;
begin
  if mnRecents = nil then exit;
  if RecentFiles = nil then exit;
  //proteciión
  if RecentFiles.Count = 0 then begin
    mnRecents[0].Caption := MSG_NOFILES;
    mnRecents[0].Enabled:=false;
    for i:= 1 to mnRecents.Count-1 do begin
      mnRecents[i].Visible:=false;
    end;
    exit;
  end;
  //hace visible los ítems
  mnRecents[0].Enabled:=true;
  for i:= 0 to mnRecents.Count-1 do begin
    if i<RecentFiles.Count then
      mnRecents[i].Visible:=true
    else
      mnRecents[i].Visible:=false;
  end;
  //pone etiquetas a los menús, incluyendo un atajo numérico
  for i:=0 to RecentFiles.Count-1 do begin
    mnRecents[i].Caption := '&'+IntToStr(i+1)+' '+RecentFiles[i];
  end;
end;
procedure TfrmPrincipal.AddRecentFile(arch: string);
//Agrega el nombre de un archivo reciente
var hay: integer; //bandera-índice
    i: integer;
begin
  if RecentFiles = nil then exit;
  //verifica si ya existe
  hay := -1;   //valor inicial
  for i:= 0 to RecentFiles.Count-1 do
    if RecentFiles[i] = arch then hay := i;
  if hay = -1 then  //no existe
    RecentFiles.Insert(0,arch)  //agrega al inicio
  else begin //ya existe
    RecentFiles.Delete(hay);     //lo elimina
    RecentFiles.Insert(0,arch);  //lo agrega al inicio
  end;
  while RecentFiles.Count>MaxRecents do  //mantiene tamaño máximo
    RecentFiles.Delete(MaxRecents);
end;
procedure TfrmPrincipal.LoadLastFileEdited;
{Carga el último archivo de la lista de recientes}
begin
  if mnRecents.Count = 0 then exit;
  ActualMenusReciente(self);
  mnRecents.Items[0].Click;
end;
procedure TfrmPrincipal.LoadListFiles(lst: string);
var
  a: TStringDynArray;
  i: Integer;
  filName: String;
begin
  a := Explode(LineEnding, lst);
  for i:=0 to high(a) do begin
     filName := trim(a[i]);
     if filName = '' then continue;
     AbrirSesion(filName);
  end;
end;
procedure TfrmPrincipal.InitMenuRecents(menRecents0: TMenuItem; RecentList: TStringList;
      MaxRecents0: integer=5);
//Configura un menú, con el historial de los archivos abiertos recientemente
//"nRecents", es el número de archivos recientes que se guardará
var
  i: Integer;
begin
  mnRecents := menRecents0;
  RecentFiles := RecentList;  //gaurda referencia a lista
  MaxRecents := MaxRecents0;
  //configura menú
  mnRecents.OnClick:=@ActualMenusReciente;
  for i:= 1 to MaxRecents do begin
    AddItemToMenu(mnRecents, '&'+IntToStr(i), @RecentClick);
  end;
end;
/////////////////////// ACCIONES ////////////////////////
procedure TfrmPrincipal.AcFilConecExecute(Sender: TObject);  //conexión rápida
var
  ses: TfraTabSession;
begin
  frmConexRap.ShowModal;
  if frmConexRap.Cancel then exit;
  if not StringLike(frmConexRap.ip, '*.*.*.*') then begin
    MsgErr('Invalid IP address.');
    exit;
  end;
  case frmConexRap.tipo of
  TCON_TELNET: begin
     ses := TabSessions.AddPage(MSG_FILE_EXT);
     ses.InicConectTelnet(frmConexRap.ip);
  end;
  TCON_SSH   : begin
     ses := TabSessions.AddPage(MSG_FILE_EXT);
     ses.InicConectSSH(frmConexRap.ip);
  end;
  end;
  //InicConect;   //inicia conexión
  //Almacena conexión
  Config.escribirArchivoIni;  //guarda en configuración}
end;
procedure TfrmPrincipal.AcFilNewWinExecute(Sender: TObject);
//Abre una nueva ventana de la aplicación
begin
   Exec('TTerm.exe','');
end;
procedure TfrmPrincipal.AcFilNewSesExecute(Sender: TObject);  //Genera una nueva sesión
var
  ses: TfraTabSession;
  l: TStrings;
begin
  ses := TabSessions.AddPage(MSG_FILE_EXT);
  TabSessions.SetFocus;
  ses.ExecSettings;  //Muestra ventana de configuración
  l := ses.edPCom.Lines;
  case ses.Tipo of
  TCON_SSH: begin
     l.Add('###########################################');
     l.Add('## New SSH session created ' + DateTimeToStr(now));
     l.Add('###########################################');
     l.Add('IP: ' + ses.IP);
     l.Add('Port: ' + ses.Port);
  end;
  end;
  ses.setModified(true);  //Marca como modificado
end;
procedure TfrmPrincipal.AcFIlOpeSesExecute(Sender: TObject); //Abrir sesión
begin
  OpenDialog1.Filter := MSG_FILE_DES + '|*' + MSG_FILE_EXT + '|' +
                        MSG_ALLFILES + '|*.*';
  //OpenDialog1.InitialDir:=patSesiones;  //busca aquí por defecto
  if not OpenDialog1.Execute then exit;    //se canceló
  AbrirSesion(OpenDialog1.FileName);
end;

procedure TfrmPrincipal.AcFilSavSesExecute(Sender: TObject);  //guardar sesión
var
  ses: TfraTabSession;
begin
  if GetCurSession(ses) then begin
    ses.SaveToFile;
  end;
end;
procedure TfrmPrincipal.AcFilSavSesAsExecute(Sender: TObject); //guarda sesión como
var
  ses: TfraTabSession;
begin
  if GetCurSession(ses) then begin
    ses.SaveAsDialog;
    UpdateHeader;   //Actualiza barra de título
  end;
end;
procedure TfrmPrincipal.AcFilExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.AcVerBarEstExecute(Sender: TObject);
begin
  MostrarBarEst(not AcVerBarEst.Checked);
end;
procedure TfrmPrincipal.AcVerEdiMacExecute(Sender: TObject);
begin
  frmEditMacros.Show;
end;
procedure TfrmPrincipal.AcVerExpRemExecute(Sender: TObject);
begin
  frmExpRemoto.Show;
end;
procedure TfrmPrincipal.AcVerEdiRemExecute(Sender: TObject);
begin
  frmEditRemoto.Show;
end;

procedure TfrmPrincipal.AcToolRecMacExecute(Sender: TObject);
begin
  frmEditMacros.AcHerGrabExecute(self);
end;
procedure TfrmPrincipal.AcToolSettExecute(Sender: TObject);
begin
  Config.Configurar;
end;

procedure TfrmPrincipal.acHlpHelpExecute(Sender: TObject);
begin
  OpenURL('https://github.com/t-edson/Tito-s-Terminal/tree/master/Docs');
end;

end.
//1810
