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
  FormQuickConnect, FormConfig, FormRemoteExplor, FormEditMacros, MisUtils,
  Globales, SynFacilUtils, FormRemoteEditor,
  FrameTabSessions, FrameTabSession, uPreBasicos, uPreProces, StrUtils;
type
  TlogState = (logStopped, logRunning, logPaused);

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
  published
    AcFilExit: TAction;
    AcFilQckConnec: TAction;
    AcFilNewWin: TAction;
    AcToolSett: TAction;
    AcFilSavSesAs: TAction;
    AcFIlOpeSes: TAction;
    AcFilSavSes: TAction;
    AcFilNewSes: TAction;
    AcMacRecord: TAction;
    acHlpHelp: TAction;
    acHlpAbout: TAction;
    AcViewStatusBar: TAction;
    AcToolRemExplor: TAction;
    AcToolRemEdit: TAction;
    AcMacEditor: TAction;
    ActionList1: TActionList;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    mnEjecMacro: TMenuItem;
    mnAbrMacro: TMenuItem;
    mnGraMacro: TMenuItem;
    mnMacros: TMenuItem;
    mnRecents: TMenuItem;
    mnAyuAyu: TMenuItem;
    mnView: TMenuItem;
    mnFile: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem62: TMenuItem;
    MenuItem63: TMenuItem;
    MenuItem64: TMenuItem;
    MenuItem65: TMenuItem;
    MenuItem66: TMenuItem;
    mnSesionesAlm: TMenuItem;
    MenuItem47: TMenuItem;
    mnHelp: TMenuItem;
    MenuItem37: TMenuItem;
    mnTools: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem40: TMenuItem;
    MenuItem5: TMenuItem;
    OpenDialog1: TOpenDialog;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    procedure AcFIlOpeSesExecute(Sender: TObject);
    procedure AcFilSavSesAsExecute(Sender: TObject);
    procedure AcFilSavSesExecute(Sender: TObject);
    procedure AcFilQckConnecExecute(Sender: TObject);
    procedure AcFilNewSesExecute(Sender: TObject);
    procedure AcFilNewWinExecute(Sender: TObject);
    procedure AcFilExitExecute(Sender: TObject);
    procedure acHlpHelpExecute(Sender: TObject);
    procedure AcMacRecordExecute(Sender: TObject);
    procedure AcToolSettExecute(Sender: TObject);
    procedure AcToolRemEditExecute(Sender: TObject);
    procedure AcViewStatusBarExecute(Sender: TObject);
    procedure AcMacEditorExecute(Sender: TObject);
    procedure AcToolRemExplorExecute(Sender: TObject);
    procedure edPComSpecialLineMarkup(Sender: TObject; Line: integer;
      var Special: boolean; Markup: TSynSelectedColor);
    procedure UpdateHeader;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
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
    procedure PropertiesChanged;
    procedure TabSessionsPageEvent(event: string; page: TObject; out res: string);
    procedure itemAbreSesion(Sender: TObject);
    procedure MostrarBarEst(visibilidad: boolean);
  public
//    proc   : TConsoleProc; //referencia al proceso actual
    curProc: TConsoleProc2; //referencia al proceso actual
    ejecMac: boolean;   //indica que está ejecutando una macro
    ejecCom: boolean;   //indica que está ejecutando un comando (editor remoto, exp. remoto ...)
    function AvailableConnection: boolean;
  public  //Acciones sobre la session actual.
    function GetCurSession(out pag: TfraTabSession): boolean;
    procedure SetCurPort(port: integer);
    procedure SetCurIP(ip: string);
    procedure SetCurConnType(ctyp: TTipCon);
    procedure SetCurLineDelimSend(delim: TUtLineDelSend);
    procedure SetCurOther(txt: string);
  private  //Manejo de menús recientes
//    mnRecents   : TMenuItem;  //Menú de archivos recientes
//    RecentFiles : TStringList;  //Lista de archivos recientes
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
var
  i: Integer;
begin
  //Carga archivo arrastrados
  for i:=0 to high(FileNames) do begin
    AbrirSesion(FileNames[i]);
  end;
end;
procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  InitMenuRecents(mnRecents, Config.RecentFiles, 8);
  TranslateMsgs := true;  //activa la traducción en los mensajes
  frmEditMacros.Init(TabSessions);
  //Aquí ya sabemos que Config está creado. Lo configuramos.
  Config.edMacr := frmEditMacros.ed;
  COnfig.edRemo := frmRemoteEditor.ed;
  Config.OnPropertiesChanged := @PropertiesChanged;
  Config.Iniciar();  //Inicia la configuración
  //muestra dirección IP actual
  //ActualizarInfoPanel0;
  //actualiza menús
  mnSesionesAlmClick(self);
  mnEjecMacroClick(self);
  mnAbrMacroClick(self);

  UpdateHeader;    //Actualiza barra de título
end;
procedure TfrmPrincipal.UpdateHeader;
var
  pag: TfraTabSession;
begin
  //Actualiza encabezado
  if GetCurSession(pag) then begin
    Caption := NOM_PROG + '-' + VER_PROG + ' - ' + pag.FileName;
  end else begin
    Caption := NOM_PROG + '-' + VER_PROG;
  end;
end;
procedure TfrmPrincipal.edPComSpecialLineMarkup(Sender: TObject; Line: integer;
  var Special: boolean; Markup: TSynSelectedColor);
begin
//vacío
end;

/////////////// Funciones para manejo de macros///////////////
procedure TfrmPrincipal.mnSesionesAlmClick(Sender: TObject);
begin
  mnSesionesAlm.Clear;
  LeeArchEnMenu(patSessions + DirectorySeparator +'*.ses', mnSesionesAlm, @itemAbreSesion);
end;
procedure TfrmPrincipal.mnEjecMacroClick(Sender: TObject);
begin
  mnEjecMacro.Clear;
  LeeArchEnMenu(config.foldMacros + DirectorySeparator +'*.ttm', mnEjecMacro,@itemEjecMacro);
end;
procedure TfrmPrincipal.mnAbrMacroClick(Sender: TObject);
begin
  mnAbrMacro.Clear;
  LeeArchEnMenu(config.foldMacros + DirectorySeparator +'*.ttm', mnAbrMacro,@itemAbreMacro);
end;
procedure TfrmPrincipal.AbrirSesion(fileSession: string);
//Abre una sesión
var
  pag: TfraTabSession;
  i: Integer;
begin
//  //Actualiza menús
//  mnEjecMacroClick(self);
//  mnAbrMacroClick(self);

  //Si es ruta relativa, la vuelve absoluta.
  if Pos(DirectorySeparator, fileSession) = 0 then begin
    fileSession := patApp + fileSession;
  end;
  //Verifica si ya está abierto
  for i:=0 to TabSessions.pages.Count-1 do begin
    pag := TabSessions.pages[i];
    if UpCase(pag.fileName) = UpCase(fileSession) then begin
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
  AbrirSesion(patSessions + DirectorySeparator + TMenuItem(Sender).Caption);
end;
procedure TfrmPrincipal.itemEjecMacro(Sender: TObject);
//Ejecuta la macro elegida
begin
  frmEditMacros.Ejecutar(config.foldMacros + DirectorySeparator + TMenuItem(Sender).Caption);
end;
procedure TfrmPrincipal.itemAbreMacro(Sender: TObject);
begin
  frmEditMacros.Show;
  frmEditMacros.Abrir(config.foldMacros + DirectorySeparator + TMenuItem(Sender).Caption);
end;
procedure TfrmPrincipal.PropertiesChanged;
//Configura el entorno (IDE) a partir de la configuración global (FormConfig).
begin
  //Inicia visibilidad de paneles. Estas son propiedades del entrono, no de un editor en particular
  //Barra de herramientas
//  tbTerm.Visible       := Config.VerBHerTerm;
//  AcTerVerBHer.Checked := Config.VerBHerTerm;
  //Barra de estado.
  MostrarBarEst(Config.VerBarEst);
  //Apariencia de los editores
  Config.fcEdMacr.ConfigEditor(frmEditMacros.ed);
  Config.fcEdRemo.ConfigEditor(frmRemoteEditor.ed);
  frmEditMacros.ed.Invalidate;
  frmRemoteEditor.ed.Invalidate;
end;
procedure TfrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  pag: TfraTabSession;
begin
     case Key of
     VK_TAB: begin
       if Shift = [ssCtrl] then begin  //Ctrl+Tab
         TabSessions.SelectNextEditor;
       end;
       if Shift = [ssShift, ssCtrl] then begin  //Shift+Ctrl+Tab
         TabSessions.SelectPrevEditor;
       end;
     end;
     VK_1: begin
       if Shift = [ssCtrl] then begin  //Ctrl+1
         if not GetCurSession(pag) then exit;
         //Selecciona panel de comandos
         pag.edPCom.SetFocus;
       end;
     end;
     VK_2: begin
       if Shift = [ssCtrl] then begin  //Ctrl+2
         if not GetCurSession(pag) then exit;
         //Selecciona Terminal
         pag.edTerm.SetFocus;
       end;
     end;
     VK_F4: begin
       if Shift = [ssCtrl] then begin  //Ctrl+F4
         TabSessions.ClosePage;
         Key := 0;  //Sino daría error en las rutinas que procesen la tecla.
       end;
     end;
     VK_F2: begin
       if not GetCurSession(pag) then exit;
       pag.showPCom := not pag.showPCom;
       pag.PropertiesChanged;  //Para actualizar cambios.
     end;
     VK_S: begin
       if Shift = [ssCtrl] then begin  //Ctrl+S
          AcFilSavSesExecute(self);  //Guarda sesión
       end;
     end;
     end;
end;
procedure TfrmPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  Config.SaveToFile;  //guarda configuración
end;
procedure TfrmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
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
  'reg_reg_file': begin  //Se pide registrar archivo en el histórico
    AddRecentFile(pag.FileName);
  end;
  'req_new_page': begin  //Se pide agregar una nueva página. Desde el menú de las lenguetas.
     AcFilNewSesExecute(self);
  end;
  'req_open_page': begin  //Se pide abrir una página
     AcFIlOpeSesExecute(self);
  end;
  'exec_explor': begin
     AcToolRemExplorExecute(self);
  end;
  'exec_edit': begin
    AcToolRemEditExecute(self);
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
procedure TfrmPrincipal.MostrarBarEst(visibilidad:boolean );
//Solo por esta función se debe cambiar la visibilidad de la barra de estado
begin
   StatusBar1.Visible:=visibilidad;
   AcViewStatusBar.Checked:=visibilidad;
   Config.VerBarEst :=visibilidad; //Actualiza variable global
   Config.SaveToFile; //guarda cambio
end;
function TfrmPrincipal.AvailableConnection: boolean;
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
  RecentFiles: TStringList;
begin
  RecentFiles := Config.RecentFiles;
  if mnRecents = nil then exit;
  if RecentFiles = nil then exit;
  //Protección
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
    RecentFiles: TStringList;
begin
  RecentFiles := Config.RecentFiles;
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
  while RecentFiles.Count>MaxRecents do  //Mantiene tamaño máximo
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
  Config.RecentFiles := RecentList;  //gaurda referencia a lista
  MaxRecents := MaxRecents0;
  //configura menú
  mnRecents.OnClick:=@ActualMenusReciente;
  for i:= 1 to MaxRecents do begin
    AddItemToMenu(mnRecents, '&'+IntToStr(i), @RecentClick);
  end;
end;
/////////////////////// ACCIONES ////////////////////////
//Acciones de archivo
procedure TfrmPrincipal.AcFilQckConnecExecute(Sender: TObject);  //conexión rápida
var
  ses: TfraTabSession;
begin
  frmQuickConnect.ShowModal;
  if frmQuickConnect.Cancel then exit;
  if not StringLike(frmQuickConnect.ip, '*.*.*.*') then begin
    MsgErr('Invalid IP address.');
    exit;
  end;
  case frmQuickConnect.tipo of
  TCON_TELNET: begin
     ses := TabSessions.AddPage(MSG_FILE_EXT);
     ses.InicConectTelnet(frmQuickConnect.ip);
  end;
  TCON_SSH   : begin
     ses := TabSessions.AddPage(MSG_FILE_EXT);
     ses.InicConectSSH(frmQuickConnect.ip);
  end;
  end;
  //InicConect;   //inicia conexión
  //Almacena conexión
  Config.SaveToFile;  //guarda en configuración}
end;
procedure TfrmPrincipal.AcFilNewWinExecute(Sender: TObject);
//Abre una nueva ventana de la aplicación
begin
   Exec('TitoTerm.exe','');
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
  TCON_TELNET: begin
     l.Add('###########################################');
     l.Add('## New Telnet session created ' + DateTimeToStr(now));
     l.Add('###########################################');
     l.Add('IP: ' + ses.IP);
     l.Add('Port: ' + ses.Port);
  end;
  TCON_SERIAL: begin
     l.Add('###########################################');
     l.Add('## New SERIAL session created ' + DateTimeToStr(now));
     l.Add('###########################################');
//     l.Add('IP: ' + ses.IP);
//     l.Add('Port: ' + ses.Port);
  end;
  end;
  ses.setModified(true);  //Marca como modificado
end;
procedure TfrmPrincipal.AcFIlOpeSesExecute(Sender: TObject); //Abrir sesión
begin
  OpenDialog1.Filter := MSG_FILE_DES + '|*' + MSG_FILE_EXT + '|' +
                        MSG_ALLFILES + '|*.*';
  //OpenDialog1.InitialDir:=patSessions;  //busca aquí por defecto
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
//Acciones de Ver
procedure TfrmPrincipal.AcViewStatusBarExecute(Sender: TObject);
begin
  MostrarBarEst(not AcViewStatusBar.Checked);
end;
//Acciones de macros
procedure TfrmPrincipal.AcMacEditorExecute(Sender: TObject);
begin
  frmEditMacros.Show;
end;
procedure TfrmPrincipal.AcMacRecordExecute(Sender: TObject);
begin
  frmEditMacros.AcHerGrabExecute(self);
end;
//Acciones de Herramientas
procedure TfrmPrincipal.AcToolRemExplorExecute(Sender: TObject);
var
  ses: TfraTabSession;
begin
  if not GetCurSession(ses) then begin
    MsgBox('There isn''t an active session.');
    exit;
  end;
  frmRemoteExplor.Init(ses);
  frmRemoteExplor.Show;
end;
procedure TfrmPrincipal.AcToolRemEditExecute(Sender: TObject);
var
  ses: TfraTabSession;
begin
  if not GetCurSession(ses) then begin
    MsgBox('There isn''t an active session.');
    exit;
  end;
  frmRemoteEditor.Init(ses);
  frmRemoteEditor.Show;
end;
procedure TfrmPrincipal.AcToolSettExecute(Sender: TObject);
begin
  Config.Configurar;
end;
//Acciones de ayuda
procedure TfrmPrincipal.acHlpHelpExecute(Sender: TObject);
begin
  OpenURL('https://github.com/t-edson/Tito-s-Terminal/tree/master/Docs');
end;

end.
//1810
