{Define a la ventana de sesión. Esta ventana permite mostrar el texto que va llegando
 de un proceso. Servirá para visualizar como se interactúa con la sesión y para poder
 iniciar conexiones a sqlplus mediante el telnet.}

unit FormPrincipal;
{$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, FileUtil, LazUTF8, SynEdit, Forms, Controls, Graphics,
  Dialogs, Menus, ActnList, ExtCtrls, ComCtrls, SynEditKeyCmds,
  SynEditMarkupHighAll, SynEditMiscClasses, LCLType, LCLProc, LCLIntf, StdActns,
  UnTerminal, Clipbrd, FormConexRapida, FormConfig, FormExpRemoto,
  FormEditMacros, MisUtils, Globales, FrameCfgConex, FormSelFuente,
  FrameCfgComandRec, TermVT, uResaltTerm, SynFacilUtils, FormEditRemoto,
  uPreBasicos, uPreProces;
type
  TlogState = (logStopped, logRunning, logPaused);

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
  published
    AcArcSalir: TAction;
    AcArcConec: TAction;
    AcArcNueVen: TAction;
    AcArcDescon: TAction;
    AcArcIniReg: TAction;
    AcArcDetReg: TAction;
    acEdCopy: TEditCopy;
    acEdCut: TEditCut;
    acEdModCol: TAction;
    acEdRedo: TAction;
    acEdSelecAll: TAction;
    acEdUndo: TAction;
    AcHerCfg: TAction;
    AcTerDetPrm: TAction;
    AcTerDescon: TAction;
    AcTerConec: TAction;
    AcTerLimBuf: TAction;
    AcArcGuaSesC: TAction;
    AcPcmOcul: TAction;
    AcPcmCamPos: TAction;
    AcPCmEnvLin: TAction;
    AcPCmEnvTod: TAction;
    AcPcmVerBHer: TAction;
    AcTerVerBHer: TAction;
    AcPcmAbrir: TAction;
    AcPcmGuardar: TAction;
    AcPcmNuevo: TAction;
    AcPcmGuaCom: TAction;
    AcTerPrmArr: TAction;
    AcTerPrmAba: TAction;
    AcPcmConfig: TAction;
    AcTerConfig: TAction;
    acPCmEnvCtrC: TAction;
    AcArcAbrSes: TAction;
    AcArcGuaSes: TAction;
    AcArcNueSes: TAction;
    AcTerEnvCtrlC: TAction;
    AcTerEnvEnter: TAction;
    AcTerEnvCR: TAction;
    AcTerEnvCRLF: TAction;
    AcTerEnvLF: TAction;
    acEdPaste: TAction;
    AcHerGraMac: TAction;
    AcTerCopNomRut: TAction;
    AcTerCopRut: TAction;
    AcTerCopNom: TAction;
    AcTerCopPal: TAction;
    acAyuAyu: TAction;
    acAyuAcer: TAction;
    AcVerBarEst: TAction;
    AcVerExpRem: TAction;
    AcVerEdiRem: TAction;
    AcVerEdiMac: TAction;
    AcVerPanCom: TAction;
    ActionList1: TActionList;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    mnAyuAyu: TMenuItem;
    mnEdicion: TMenuItem;
    mnVer: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    mnArchivo: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem41: TMenuItem;
    MenuItem42: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem44: TMenuItem;
    MenuItem45: TMenuItem;
    MenuItem46: TMenuItem;
    MenuItem48: TMenuItem;
    MenuItem49: TMenuItem;
    MenuItem50: TMenuItem;
    MenuItem51: TMenuItem;
    MenuItem52: TMenuItem;
    MenuItem53: TMenuItem;
    MenuItem54: TMenuItem;
    MenuItem55: TMenuItem;
    MenuItem56: TMenuItem;
    MenuItem57: TMenuItem;
    MenuItem58: TMenuItem;
    MenuItem59: TMenuItem;
    MenuItem60: TMenuItem;
    MenuItem61: TMenuItem;
    MenuItem62: TMenuItem;
    MenuItem63: TMenuItem;
    MenuItem64: TMenuItem;
    MenuItem65: TMenuItem;
    MenuItem66: TMenuItem;
    mnTerSend: TMenuItem;
    MenuItem68: TMenuItem;
    MenuItem69: TMenuItem;
    MenuItem70: TMenuItem;
    MenuItem71: TMenuItem;
    MenuItem72: TMenuItem;
    MenuItem73: TMenuItem;
    MenuItem74: TMenuItem;
    MenuItem75: TMenuItem;
    MenuItem76: TMenuItem;
    MenuItem77: TMenuItem;
    MenuItem78: TMenuItem;
    MenuItem79: TMenuItem;
    MenuItem80: TMenuItem;
    MenuItem81: TMenuItem;
    MenuItem82: TMenuItem;
    MenuItem83: TMenuItem;
    MenuItem84: TMenuItem;
    MenuItem85: TMenuItem;
    MenuItem86: TMenuItem;
    mnPopComAlm: TMenuItem;
    mnComandosAlm: TMenuItem;
    mnSesionesAlm: TMenuItem;
    mnPopLeng: TMenuItem;
    mnLenguajes: TMenuItem;
    mnGraMacro: TMenuItem;
    MenuItem47: TMenuItem;
    mnAbrMacro: TMenuItem;
    mnEjecMacro: TMenuItem;
    mnPanCom: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem35: TMenuItem;
    mnAyuda: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem38: TMenuItem;
    mnHerram: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem40: TMenuItem;
    MenuItem5: TMenuItem;
    mnTerminal: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    edTerm: TSynEdit;
    edPCom: TSynEdit;
    tbPCom: TToolBar;
    tbTerm: TToolBar;
    Timer1: TTimer;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    ToolButton17: TToolButton;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    ToolButton2: TToolButton;
    ToolButton20: TToolButton;
    ToolButton21: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    procedure AcArcAbrSesExecute(Sender: TObject);
    procedure AcArcDetRegExecute(Sender: TObject);
    procedure AcArcGuaSesCExecute(Sender: TObject);
    procedure AcArcGuaSesExecute(Sender: TObject);
    procedure AcArcConecExecute(Sender: TObject);
    procedure AcArcIniRegExecute(Sender: TObject);
    procedure AcArcNueSesExecute(Sender: TObject);
    procedure AcArcNueVenExecute(Sender: TObject);
    procedure AcArcSalirExecute(Sender: TObject);
    procedure acAyuAyuExecute(Sender: TObject);
    procedure acEdPasteExecute(Sender: TObject);
    procedure acEdRedoExecute(Sender: TObject);
    procedure acEdUndoExecute(Sender: TObject);
    procedure AcHerGraMacExecute(Sender: TObject);
    procedure AcPcmAbrirExecute(Sender: TObject);
    procedure AcPcmCamPosExecute(Sender: TObject);
    procedure AcPcmConfigExecute(Sender: TObject);
    procedure acPCmEnvCtrCExecute(Sender: TObject);
    procedure AcPCmEnvLinExecute(Sender: TObject);
    procedure AcPCmEnvTodExecute(Sender: TObject);
    procedure AcPcmGuaComExecute(Sender: TObject);
    procedure AcPcmGuardarExecute(Sender: TObject);
    procedure AcPcmNuevoExecute(Sender: TObject);
    procedure AcPcmOculExecute(Sender: TObject);
    procedure AcPcmVerBHerExecute(Sender: TObject);
    procedure AcHerCfgExecute(Sender: TObject);
    procedure AcTerConecExecute(Sender: TObject);
    procedure AcTerConfigExecute(Sender: TObject);
    procedure AcTerCopNomExecute(Sender: TObject);
    procedure AcTerCopNomRutExecute(Sender: TObject);
    procedure AcTerCopPalExecute(Sender: TObject);
    procedure AcTerCopRutExecute(Sender: TObject);
    procedure AcTerDesconExecute(Sender: TObject);
    procedure AcTerDetPrmExecute(Sender: TObject);
    procedure AcTerEnvCRExecute(Sender: TObject);
    procedure AcTerEnvCRLFExecute(Sender: TObject);
    procedure AcTerEnvCtrlCExecute(Sender: TObject);
    procedure AcTerEnvEnterExecute(Sender: TObject);
    procedure AcTerEnvLFExecute(Sender: TObject);
    procedure AcTerLimBufExecute(Sender: TObject);
    procedure AcTerPrmAbaExecute(Sender: TObject);
    procedure AcTerPrmArrExecute(Sender: TObject);
    procedure AcVerEdiRemExecute(Sender: TObject);
    function BuscaUltPrompt: integer;
    procedure AcVerBarEstExecute(Sender: TObject);
    procedure AcVerEdiMacExecute(Sender: TObject);
    procedure AcVerExpRemExecute(Sender: TObject);
    procedure AcVerPanComExecute(Sender: TObject);
    procedure ChangeEditorState;
    procedure edPComDropFiles(Sender: TObject; X, Y: integer; AFiles: TStrings);
    procedure edPComEnter(Sender: TObject);
    procedure edPComKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edPComKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edPComSpecialLineMarkup(Sender: TObject; Line: integer;
      var Special: boolean; Markup: TSynSelectedColor);
    procedure edTermEnter(Sender: TObject);
    procedure edTermSpecialLineMarkup(Sender: TObject; Line: integer;
      var Special: boolean; Markup: TSynSelectedColor);
    procedure ePComFileOpened;
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
    procedure mnComandosAlmClick(Sender: TObject);
    procedure mnEjecMacroClick(Sender: TObject);
    procedure mnSesionesAlmClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure proc_ChangeState(info: string; pFinal: TPoint);
    procedure proc_InitScreen(const grilla: TtsGrid; fIni, fFin: integer);
    procedure proc_AddLine(HeightScr: integer);
    procedure proc_LlegoPrompt(prmLine: string; pIni: TPoint; HeightScr: integer);
    procedure proc_RefreshLine(const grilla: TtsGrid; fIni, HeightScr: integer);
    procedure proc_RefreshLines(const grilla: TtsGrid; fIni, fFin, HeightScr: integer);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure Timer1Timer(Sender: TObject);
  private
    hlTerm    : TResaltTerm;
    ePCom     : TSynFacilEditor;  //ventana de editor
    eTerm     : TSynFacilEditor;  //ventana de terminal
    LlegoPrompt: boolean;   //bandera
    parpadPan0: boolean;   //para activar el parpadeo del panel0
    ticComRec : integer;   //contador para comando recurrente
    procedure AbrirSesion(ses: string);
    function BuscaPromptAba: integer;
    function BuscaPromptArr: integer;
    procedure ConfiguraEntorno;
    procedure DistribuirPantalla;
    procedure EnviarTxt(txt: string);
    procedure EnvioTemporizado;
    procedure InicTerminal;
    procedure itemAbreComando(Sender: TObject);
    procedure itemAbreSesion(Sender: TObject);
    procedure MostrarBarEst(visibilidad: boolean);
    procedure MostrarBHerPcom(visibilidad: boolean);
    procedure MostrarBHerTerm(visibilidad: boolean);
    procedure MostrarPanCom(visibilidad: boolean);
    procedure PosicionarCursor(HeightScr: integer);
    procedure proc_LineCompleted(const lin: string);
  public
    proc   : TConsoleProc; //referencia al proceso actual
    ejecMac: boolean;   //indica que está ejecutando una macro
    ejecCom: boolean;   //indica que está ejecutando un comando (editor remoto, exp. remoto ...)
    SesAct : string;    //nombre de la sesión actual
    procedure InicConect;
    procedure InicConectTelnet(ip: string);
    procedure InicConectSSH(ip: string);
    procedure ActualizarInfoPanel0;
    function ConexDisponible: boolean;
    function EnviarComando(com: string; var salida: TStringList): string;
    procedure SetLanguage(lang: string);
  public  //Campos para manejo del registro
    logState: TlogState;  //estado del registro
    logFile : text;
    logName : string;   //archvio de registro
    function StartLog(logName0: string): boolean;
    procedure PauseLog;
    procedure StartLog;
    procedure EndLog;
    function WriteLog(txt: string): boolean;
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation
{$R *.lfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  SesAct := '';
  ticComRec  := 0;

  ejecMac := false;
  hlTerm := TResaltTerm.Create(Self);  //crea resaltador

  //configura editor de terminal
  eTerm := TSynFacilEditor.Create(edTerm,'SinNombre','sh');   //Crea Editor
  eTerm.PanCursorPos := StatusBar1.Panels[2];  //panel para la posición del cursor
  InicTerminal;  //configura ventana de terminal

  //configura editor de Panel de comando
  InicEditorC1(edPCom); //configura panel de comandos
  edPCom.OnSpecialLineMarkup:=@edPComSpecialLineMarkup; //solo para corregir bug de SynEdit (falla de resaltado de línea actual)
  ePCom := TSynFacilEditor.Create(edPCom,'SinNombre','sh');   //Crea Editor
  ePCom.OnChangeEditorState:=@ChangeEditorState;
  ePCom.OnKeyUp:=@edPComKeyUp;    //evento
  ePCom.OnKeyDown:=@edPComKeyDown; //evento
  ePcom.OnFileOpened:=@ePComFileOpened;
  ePCom.PanCursorPos := StatusBar1.Panels[2];  //panel para la posición del cursor
  ePCom.PanLangName := StatusBar1.Panels[4];  //lenguaje

  ePCom.NewFile;   //para actualizar estado
  ePCom.InitMenuLanguages(mnLenguajes, rutLenguajes);
  ePCom.LoadSyntaxFromPath;

  //inicia proceso
  proc := TConsoleProc.Create(StatusBar1.Panels[1]);
  StatusBar1.OnDrawPanel:=@StatusBar1DrawPanel;

  //proc.OnRefreshAll:=@procRefreshEdit;
  proc.OnInitScreen :=@proc_InitScreen;
  proc.OnRefreshLine:=@proc_RefreshLine;
  proc.OnRefreshLines:=@proc_RefreshLines;
  proc.OnAddLine:=@proc_AddLine;

  proc.OnGetPrompt:=@proc_LlegoPrompt;
  proc.OnChangeState:=@proc_ChangeState;

  proc.OnLineCompleted:=@proc_LineCompleted;  //usado para el registro
  AcTerDescon.Enabled:=false;  //Se supone que inicia siempre sin conectar

end;
procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  EndLog;  //por si se estaba registrando
  ePCom.Free;
  eTerm.Free;
  proc.Free;
  hlTerm.Free;
end;
procedure TfrmPrincipal.FormDropFiles(Sender: TObject;
  const FileNames: array of String);
begin
  //Carga archivo arrastrados
  if ePCom.SaveQuery then Exit;   //Verifica cambios
  ePCom.LoadFile(FileNames[0]);
end;
procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  TranslateMsgs := true;  //activa la traducción en los mensajes
  SetLanguage('en');
  Config.SetLanguage('en');
  frmExpRemoto.SetLanguage('en');
  frmEditRemoto.SetLanguage('en');
  frmEditMacros.SetLanguage('en');
  Caption := NOM_PROG + ' ' + VER_PROG;
  //aquí ya sabemos que Config está creado. Lo configuramos
  Config.edTerm := edTerm;  //pasa referencia de editor.
  Config.edPCom := edPCom;  //pasa referencia de Panel de comando
  Config.edMacr := frmEditMacros.ed;
  COnfig.edRemo := frmEditRemoto.ed;
  Config.prTel := proc;     //pasa referencia a proceso
  Config.fcComRec.OnProbar:=@EnvioTemporizado;

  Config.Iniciar(ePCom.hl);  //Inicia la configuración
  ConfiguraEntorno;
  DistribuirPantalla; //ubica componentes
  //muestra dirección IP actual
  ActualizarInfoPanel0;
  //actualiza menús
  mnSesionesAlmClick(self);
  mnComandosAlmClick(self);
  mnEjecMacroClick(self);
  mnAbrMacroClick(self);
  //Verrifica si debe abrir archivo de script
  if Config.fcRutArc.AbrirUltScr then begin
    if FileExists(Config.fcRutArc.UltScript) then begin
      ePCom.LoadFile(Config.fcRutArc.UltScript);
    end;
  end else begin
    ePComFileOpened; //para actualizar barra de título
  end;
end;

procedure TfrmPrincipal.InicTerminal;
var
  SynMarkup: TSynEditMarkupHighlightAllCaret;  //para resaltar palabras iguales
begin
  edTerm.Highlighter := hlTerm;  //asigna resaltador

  //Inicia resaltado de palabras iguales
  SynMarkup := TSynEditMarkupHighlightAllCaret(edTerm.MarkupByClass[TSynEditMarkupHighlightAllCaret]);
  SynMarkup.MarkupInfo.FrameColor := clSilver;
  SynMarkup.MarkupInfo.Background := clBlack;
  SynMarkup.MarkupInfo.StoredName:='ResPalAct';  //para poder identificarlo

  SynMarkup.WaitTime := 250; // millisec
  SynMarkup.Trim := True;     // no spaces, if using selection
  SynMarkup.FullWord := True; // only full words If "Foo" is under caret, do not mark it in "FooBar"
  SynMarkup.IgnoreKeywords := False;

  //  edTerm.Font.Name:='Courier New';
 //  edTerm.Font.Size:=10;
 //resalta
  edTerm.Options:=[eoBracketHighlight];
  //Limita posición X del cursor para que no escape de la línea
  edTerm.Options := edTerm.Options + [eoKeepCaretX];
  //permite indentar con <Tab>
  edTerm.Options := edTerm.Options + [eoTabIndent];
  //trata a las tabulaciones como un caracter
  edTerm.Options2 := edTerm.Options2 + [eoCaretSkipTab];
  edTerm.OnSpecialLineMarkup:=@edTermSpecialLineMarkup;  //solo para corregir falla de resaltado de línea actual
end;
procedure TfrmPrincipal.edTermSpecialLineMarkup(Sender: TObject; Line: integer;
  var Special: boolean; Markup: TSynSelectedColor);
begin
//vacío
end;
procedure TfrmPrincipal.ePComFileOpened;
begin
  ePCom.LoadSyntaxFromPath;  //para que busque el archivo apropiado
  Config.fcRutArc.UltScript := ePCom.FileName;  //guarda archivo abierto
  //actualiza encabezado
  if SesAct = '' then begin
    Caption := NOM_PROG + dic(' - Archivo: ')+ ePCom.FileName;
  end else begin
    Caption := NOM_PROG + ' - Sesión: ' + ExtractFileName(SesAct) +
                          dic(' - Archivo: ')+ ePCom.FileName;
  end;
end;
procedure TfrmPrincipal.edPComSpecialLineMarkup(Sender: TObject; Line: integer;
  var Special: boolean; Markup: TSynSelectedColor);
begin
//vacío
end;
procedure TfrmPrincipal.edTermEnter(Sender: TObject);
begin
  ChangeEditorState;  //para actualizar los menús
  eTerm.PanCursorPos := nil; //para forzar a actualiazr la posición del cursor
  eTerm.PanCursorPos := StatusBar1.Panels[2];
end;
procedure TfrmPrincipal.PopupMenu1Popup(Sender: TObject);  //abre menú contextual
//prepara el menú de "lenguajes", en el menú contextual
begin
  CopiarMemu(mnLenguajes, mnPopLeng);
  CopiarMemu(mnComandosAlm, mnPopComAlm)
end;

/////////////// Funciones para manejo de macros///////////////
procedure TfrmPrincipal.mnSesionesAlmClick(Sender: TObject);
begin
  mnSesionesAlm.Clear;
  LeeArchEnMenu(rutSesiones + DirectorySeparator +'*.ses', mnSesionesAlm,@itemAbreSesion);
end;
procedure TfrmPrincipal.mnComandosAlmClick(Sender: TObject);
begin
  mnComandosAlm.Clear;
  LeeArchEnMenu(config.fcRutArc.scripts + DirectorySeparator +'*.sh', mnComandosAlm,@itemAbreComando);
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

procedure TfrmPrincipal.AbrirSesion(ses: string);
//Abre una sesión
var
  arc0: String;
  rpta: Byte;
begin
  if proc.state <> ECO_STOPPED then begin
    rpta := MsgYesNoCancel('Hay una conexión abierta. ¿Cerrarla?');
    if rpta in [2,3] then begin  //cancelar
      exit;    //sale
    end;
    if rpta = 1 then begin  //detener primero
      AcTerDesconExecute(nil);
    end;
  end;
  SesAct := ses;  //actualiza sesión actual
  arc0 := SesAct;    //el archivo de sesión debe incluir el contendio además de la ocnfig.
  config.LeerArchivoIni(arc0);  //carga configuración
  //actualiza menús
  mnSesionesAlmClick(self);
  mnComandosAlmClick(self);
  mnEjecMacroClick(self);
  mnAbrMacroClick(self);

  ConfiguraEntorno;
  DistribuirPantalla; //ubica componentes
  //muestra dirección IP actual
  ActualizarInfoPanel0;
  //Verifica si debe abrir archivo de script
  if Config.fcRutArc.AbrirUltScr then begin
    if FileExists(Config.fcRutArc.UltScript) then begin
      ePCom.LoadFile(Config.fcRutArc.UltScript);
    end else begin
      msgExc('No se encuentra archivo: %s', [Config.fcRutArc.UltScript]);
    end;
  end;
  //Verifica si debe ejecutar macro
{  if Config.fcRutArc.EjecMacro then begin
    if FileExists(Config.fcRutArc.MacroIni) then begin
      frmEditMacros.Ejecutar(Config.fcRutArc.MacroIni);
    end else begin
      msgExc('No se encuentra archivo: %s', Config.fcRutArc.MacroIni);
    end;
  end;}
  ePComFileOpened; //para actualizar barra de título
end;
procedure TfrmPrincipal.itemAbreSesion(Sender: TObject);
begin
  AbrirSesion(rutSesiones + DirectorySeparator + TMenuItem(Sender).Caption);
end;
procedure TfrmPrincipal.itemAbreComando(Sender: TObject);
var
  tmp: String;
begin
  tmp := config.fcRutArc.scripts + DirectorySeparator + TMenuItem(Sender).Caption;
  ePCom.LoadFile(tmp);
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
  MostrarBHerPcom(Config.VerBHerPcom);
  MostrarBHerTerm(Config.VerBHerTerm);
  MostrarBarEst(Config.VerBarEst);
  MostrarPanCom(Config.VerPanCom);
//  MostrarPanBD(VerPanBD);
//  MostrarVEnSes(VerVenSes);
end;

procedure TfrmPrincipal.PosicionarCursor(HeightScr: integer);
//Coloca el cursor del editor, en la misma posición que tiene el cursor del
//terminal VT100 virtual.
var
  yvt: Integer;
begin
  if Config.fcPantTerm.curSigPrm then begin
    yvt := edTerm.Lines.Count-HeightScr-1;  //calcula fila equivalente a inicio de VT100
    edTErm.CaretXY := Point(proc.term.curX, yvt+proc.term.CurY+1);
  end;
end;
procedure TfrmPrincipal.proc_InitScreen(const grilla: TtsGrid; fIni, fFin: integer);
var
  i: Integer;
begin
//  debugln('procAddLastLins: '+IntToStr(fIni)+','+IntToSTr(fFin));
  for i:=fIni to fFin do
    edTerm.Lines.Add(grilla[i]);
end;
procedure TfrmPrincipal.proc_RefreshLine(const grilla: TtsGrid; fIni, HeightScr: integer);
var
  yvt: Integer;
begin
//  debugln('procRefreshLine: '+IntToStr(fIni));
  yvt := edTerm.Lines.Count-HeightScr-1;  //calcula fila equivalente a inicio de VT100
  edTerm.Lines[yvt+fIni] := grilla[fIni];
  PosicionarCursor(HeightScr);
end;
procedure TfrmPrincipal.proc_RefreshLines(const grilla: TtsGrid; fIni, fFin, HeightScr: integer);
var
  yvt: Integer;
  f: Integer;
begin
//  debugln('procRefreshLines: '+IntToStr(fIni)+','+IntToSTr(fFin));
  yvt := edTerm.Lines.Count-HeightScr-1;  //calcula fila equivalente a inicio de VT100
  edTerm.BeginUpdate();
  for f:=fIni to fFin do
    edTerm.Lines[yvt+ f] := grilla[f];
  PosicionarCursor(HeightScr);
  edTerm.EndUpdate;
  edTerm.Refresh;  //para mostrar el cambio
end;
procedure TfrmPrincipal.proc_LlegoPrompt(prmLine: string; pIni: TPoint; HeightScr: integer);
begin
  LlegoPrompt := true;  //activa bandera
//  yvt := edTerm.Lines.Count-HeightScr-1;  //calcula fila equivalente a inicio de VT100
//debugln('  llegoPrompt en:'+IntToStr(yvt + pIni.y+1));
end;
procedure TfrmPrincipal.proc_ChangeState(info: string; pFinal: TPoint);
//Hubo un cambio de estado
begin
  AcTerConec.Enabled := proc.state = ECO_STOPPED;
  AcTerDescon.Enabled:= not (proc.state = ECO_STOPPED);
end;
procedure TfrmPrincipal.proc_AddLine(HeightScr: integer);
var
  i: Integer;
begin
//  debugln('procAddLine: ');
  edTerm.BeginUpdate();
  if edTerm.Lines.Count> Config.fcPantTerm.maxLinTer then begin
    //hace espacio
    for i:= 1 to 100 do
      edTerm.Lines.Delete(0);   { TODO : Debe verificarse que no se deba eliminar tanto
como para dejar menos líneas que la que tiene el VT100 }
  end;
  edTerm.Lines.Add('');
//  edTerm.ExecuteCommand(ecEditorBottom,'', nil);  //mueve al final
  edTerm.EndUpdate;
  edTerm.ExecuteCommand(ecLineEnd,'', nil);  //mueve al final
end;
procedure TfrmPrincipal.proc_LineCompleted(const lin: string);
begin
  if logState = logRunning then begin
    writeln(logFile, lin);
  end;
end;
procedure TfrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   if edTerm.Focused then begin
     case Key of
     VK_RETURN:
       proc.Sendln('');  //se envía con la configuración de saltos
     VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END : begin
         //teclas direccionales
         if Config.fcPantTerm.interDirec then begin
           //se interceptan, no se envían
         end else begin  //se envían como secuencias de escape
           proc.SendVT100Key(Key, Shift);
           Key := 0;  //para que nos e procesen
         end;
       end;
     VK_TAB:
       if Shift = [ssCtrl] then begin  //Ctrl+Tab
         edPCom.SetFocus;  //pasa el enfoque
       end else begin
         proc.SendVT100Key(Key, Shift);  //envía
       end;
     else
       proc.SendVT100Key(Key, Shift);
     end;
//     debugln('KeyDown:');
   end else if edPCom.Focused then begin
     case Key of
     VK_TAB: if Shift = [ssCtrl] then begin  //Ctrl+Tab
         edterm.SetFocus;  //pasa el enfoque
       end;
     end;
   end;
end;
procedure TfrmPrincipal.FormKeyPress(Sender: TObject; var Key: char);
//Aaquí se interceptan el teclado a los controles
begin
  if edTerm.Focused then begin
    proc.Send(Key);
//    debugln('KeyPress:'+Key);
  end;
end;
procedure TfrmPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  Config.escribirArchivoIni;  //guarda configuración
end;
procedure TfrmPrincipal.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  rpta: Byte;
begin
  if ejecMac then begin
    if MsgYesNo('En este momento, se está ejecutando una macro. ¿Detenerla?') = 1 then begin
      frmEditMacros.DetenerEjec;
      exit;
    end;
    canClose := false;  //cancela el cierre
  end;
  if proc.state <> ECO_STOPPED then begin
    rpta := MsgYesNoCancel('Hay una conexión abierta. ¿Cerrarla?');
    if rpta in [2,3] then begin  //cancelar
      canClose := false;  //cancela el cierre
      exit;    //sale
    end;
    if rpta = 1 then begin  //detener primero
      AcTerDesconExecute(nil);
      exit;
    end;
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
  if panel.Index = 1 then proc.DrawStatePanel(StatusBar.Canvas, Rect);
end;
procedure TfrmPrincipal.EnvioTemporizado;
//Envía el comando o archivo que se ha programado
var
  fcComRec: TfraComandRec;
begin
  fcComRec := config.fcComRec;  //parac facilidad de acceso
  case fcComRec.tipEnvio of
  teComando:
      proc.SendLn(fcComRec.Comando);
  teArchivo: begin
      if not FileExists(fcComRec.archivo) then begin
        MsgErr('No se encuentra archivo: %s', [fcComRec.archivo]);
        exit;
      end;
      proc.SendLn(StringFromFile(fcComRec.archivo));
    end;
  end;
end;
procedure TfrmPrincipal.Timer1Timer(Sender: TObject);
//Temporizador cada de 0.5 segundos
begin
  //muestra mensaje de ejecución
  if ejecMac then begin
    //fuerza refresco del panel
    parpadPan0 := not parpadPan0;  //para el parpadeo
    StatusBar1.InvalidatePanel(0,[ppText]);
  end;
  if (config<>nil) and  //por si se dispara antes (Ya pasó una vez)
      config.fcComRec.Activar then begin
    inc(ticComRec);
    if ticComRec mod (config.fcComRec.Tempo * 2 * 60) = 0 then begin
      //hay envío recurrente de comando
      EnvioTemporizado;
    end;
  end;
end;
procedure TfrmPrincipal.MostrarBHerPcom(visibilidad:boolean );
//Solo por esta función se debe cambiar la visibilidad de la barra de herramientas
begin
   tbPCom.Visible:=visibilidad;
   AcPcmVerBHer.Checked:=visibilidad;
   Config.VerBHerPcom :=visibilidad; //Actualiza variable global}
   Config.escribirArchivoIni; //guarda cambio
end;
procedure TfrmPrincipal.MostrarBHerTerm(visibilidad: boolean);
//Solo por esta función se debe cambiar la visibilidad de la barra de herramientas
begin
  tbTerm.Visible:=visibilidad;
  AcTerVerBHer.Checked:=visibilidad;
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
procedure TfrmPrincipal.MostrarPanCom(visibilidad:boolean);
//Solo por esta función se debe cambiar la visibilidad del panel
begin
   if not Panel1.Visible and visibilidad then begin
     //se hace visible
//     edPCom.UbicarArchivoArbol(e.NomArc);  //ubica archivo actual
   end;
   Panel1.Visible := visibilidad;
   Splitter1.Visible := visibilidad;
   AcVerPanCom.Checked := visibilidad;
   mnPanCom.Visible:=visibilidad;
   Config.VerPanCom :=visibilidad; //Actualiza variable global
   Config.escribirArchivoIni; //guarda cambio
end;

procedure TfrmPrincipal.InicConect;  //Inicia la conexión actual
begin
  //se supone que el proceso ya está configurado y listo para abrir
  proc.Open(Config.fcConex.Command, '');  //lo abre
  if msjError<>'' then begin
    msgerr(msjError);
  end;
  ActualizarInfoPanel0;  //por si ha cambiado la conexión
end;
procedure TfrmPrincipal.InicConectTelnet(ip: string);  //Inicia una conexión telnet
begin
  //configura conexión rápida Telnet
  config.fcConex.tipo := TCON_TELNET;
  config.fcConex.ip := ip;
  config.fcConex.port := '23';
  config.fcConex.LineDelimSend := LDS_LF;
  config.fcConex.LineDelimRecv := LDR_LF;
  config.fcConex.UpdateChanges;  //actualiza
  InicConect;
end;
procedure TfrmPrincipal.InicConectSSH(ip: string);  //Inicia una conexión SSH
begin
  //configura conexión rápida Telnet
  config.fcConex.tipo := TCON_SSH;
  config.fcConex.ip := ip;
  config.fcConex.port := '22';
  config.fcConex.LineDelimSend := LDS_LF;
  config.fcConex.LineDelimRecv := LDR_LF;
  config.fcConex.UpdateChanges;  //actualiza
  InicConect;
end;
procedure TfrmPrincipal.ActualizarInfoPanel0;
//Actualiza el panel 0, con información de la conexión o de la ejecución de macros
var
  conAct: TfraConexion;
begin
   conAct := Config.fcConex;
   case conAct.Tipo of
   TCON_TELNET:
      StatusBar1.Panels[0].Text:='Telnet: '+conAct.IP;
   TCON_SSH:
      StatusBar1.Panels[0].Text:='SSH: '+conAct.IP;
   TCON_SERIAL:
      StatusBar1.Panels[0].Text:='Serial: '+conAct.cmbSerPort.Text;
   TCON_OTHER:
      StatusBar1.Panels[0].Text:='Proc: '+Config.fcConex.Other;
   end;
   //refresca para asegurarse, porque el panel 0 está en modo gráfico
   StatusBar1.InvalidatePanel(0,[ppText]);
end;
function TfrmPrincipal.ConexDisponible: boolean;
//Indica si la conexión está en estado ECO_READY, es decir, que puede
//recibir un comando
begin
   Result := (proc.state = ECO_READY);
end;
function TfrmPrincipal.BuscaPromptArr: integer;
//Busca el primer prompt desde la posición actual hacia arriba
//Si no lo encuentra devuelve -1
var
  cy: Integer;
begin
  cy := edterm.CaretY;
  repeat
    dec(cy)
  until (cy<1) or config.ContienePrompt(edTerm.Lines[cy-1]);
  if cy<1 then exit(-1) else exit(cy);
end;
function TfrmPrincipal.BuscaPromptAba: integer;
//Busca el primer prompt desde la posición actual hacia abajo
//Si no lo encuentra devuelve -1
var
  cy: Integer;
begin
  cy := edterm.CaretY;
  repeat
    inc(cy)
  until (cy>edTerm.Lines.Count) or config.ContienePrompt(edTerm.Lines[cy-1]);
  if cy>edTerm.Lines.Count then exit(-1) else exit(cy);
end;
function TfrmPrincipal.BuscaUltPrompt: integer;
//Busca el último prompt de todo el terminal
//Si no lo encuentra devuelve -1
var
  cy: Integer;
begin
  cy := edterm.Lines.Count+1;
  repeat
    dec(cy)
  until (cy<1) or config.ContienePrompt(edTerm.Lines[cy-1]);
  if cy<1 then exit(-1) else exit(cy);
end;
function TfrmPrincipal.EnviarComando(com: string; var salida: TStringList): string;
{Función para enviar un comando por el Terminal. Espera hasta que aparezca de
nuevo el "prompt" y devuelve el texto generado, por el comando, en "salida".
Si hay error devuelve el mensaje de error.}
var
  n: Integer;
  y1: Integer;
  y2: Integer;
  i: Integer;
begin
  Result := '';
  if not ConexDisponible then begin
    Result := dic('No hay conexión disponible');
    MsgExc(Result);
    exit;
  end;
//  if config.fcDetPrompt then begin
//    msgExc('Para ejecutar comandos se debe tener la detección de prompt configurada');
//  end;
  ejecCom := true;  //marca estado
  LlegoPrompt := False;
  salida.Clear;   //por defecto limpia la lista
//debugln('Inicio envío comando: '+ com);
  proc.SendLn(com);
//debugln('Fin envío comando: '+ com);
  //Espera hasta la aparición del "prompt"
  n := 0;
  While Not LlegoPrompt And (n < Config.fcExpRem.TpoMax*10) do begin
    Sleep(100);
    Application.ProcessMessages;
    Inc(n);
  end;
  If n >= Config.fcExpRem.TpoMax*10 then begin    //Hubo desborde
    Result := dic('Tiempo de espera agotado');
    MsgExc(Result);
    exit;
  end else begin
    //llegó el promt (normalmente es por que hay datos)
    y2 := BuscaUltPrompt;  //por si el cursor estaba fuera de foco
//debugln('Fin comando con prompt en: '+ IntToStr(y2));
//debugln('');
    edTerm.CaretY:=y2;  //posiciona como ayuda para ver si lo hizo bien
    y1 := BuscaPromptArr;  //busca al prompt anterior
    if y1 = -1 then begin
      Result := dic('Error detectando el prompt del comando. ') +
      dic('Probablemente deba ampliar la cantidad de líneas de la pantalla.');
      MsgExc(Result);
      exit;
    end;
    //copia la salida
    for i:= y1+1 to y2-1 do  //sin contar los prompt
       salida.Add(edTerm.Lines[i-1]);
  end;
  ejecCom := false;
end;
procedure TfrmPrincipal.edPComKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Enter, SendLnEnter, SendLnCtrEnter: Boolean;
begin
  Enter := (key = VK_RETURN);
  SendLnEnter := Config.fcPanCom.SendLnEnter;
  SendLnCtrEnter := Config.fcPanCom.SendLnCtrEnter;
  //Verificaciones
  if (Shift = []) and Enter and SendLnEnter then begin
    //Envíará línea actual
    Key := 0;
  end else if (Shift = [ssCtrl]) and Enter and SendLnCtrEnter  then begin
    //Envíará línea actual
    Key := 0;
  end else if (Shift = [ssCtrl]) and Enter and not SendLnCtrEnter then begin
    Key := 0;
  end;
end;
procedure TfrmPrincipal.edPComKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
  procedure EnviarActual;  //Envía la línea actual y controla el cursor
  begin
    AcPCmEnvLinExecute(self);
    if edPCom.SelAvail then begin  //había selección
      //no se cambia la selección
    end else if edPCom.CaretY = edPCom.Lines.Count then begin
      //estamos en la última línea
      if edPCom.LineText = '' then exit; //no hay nada que enviar ni agregar
      edpCom.Lines.Add('');  //agrega una línea
      edPCom.ExecuteCommand(ecDown, '',nil);  //baja cursor
    end else begin
      //es una línea normal
      edPCom.ExecuteCommand(ecDown, '',nil);  //baja cursor
    end;
  end;
var
  Enter, SendLnEnter, SendLnCtrEnter: Boolean;
begin
  Enter := (key = VK_RETURN);
  SendLnEnter := Config.fcPanCom.SendLnEnter;
  SendLnCtrEnter := Config.fcPanCom.SendLnCtrEnter;
  //Verificaciones
  if (Shift = []) and Enter and SendLnEnter then begin
    //Envía línea actual
    EnviarActual;
    Key := 0;  //para que ya no lo procese
  end else if (Shift = [ssCtrl]) and Enter and SendLnCtrEnter then begin
    //Envía línea actual
    EnviarActual;
    Key := 0;  //para que ya no lo procese
  end else if (Shift = [ssCtrl]) and Enter and not SendLnCtrEnter then begin
    //<Control>+<Enter>, pero no está configurado
    edPCom.ExecuteCommand(ecInsertLine, '',nil);  //inserta salto
    edPCom.ExecuteCommand(ecDown, '',nil);  //baja cursor
    Key := 0;  //para que ya no lo procese
  end else if (Shift = [ssCtrl]) and (key = VK_UP) then begin
    AcTerPrmArrExecute(nil);
  end else if (Shift = [ssCtrl]) and (key = VK_DOWN) then begin
    AcTerPrmAbaExecute(nil);
  end else if (Shift = [ssCtrl]) and (key = VK_C) then begin  //Ctrl + C
    AcTerEnvCtrlCExecute(nil)  //envía Ctrl+C al terminal
  end;
end;
procedure TfrmPrincipal.DistribuirPantalla;
//Redistribuye los paneles de la pantalla
begin
  //primero quita alineamiento de componentes móviles
  PAnel2.Align:=alNone;
  Panel1.Align:=alNone;
  Splitter1.Align:=alNone;
  //alinea de acuerdo a TipAlineam
  case Config.TipAlineam of
  0: begin  //panel a la izquierda
      Panel1.Align:=alLeft;
      Splitter1.Align:=alLeft;
      Panel2.Align:=alClient;
      if Panel1.Width > Trunc(0.9*self.Width) then Panel1.Width := Trunc(0.5*self.Width);
    end;
  1: begin  //panel a la derecha
      Panel1.Align:=alRight;
      Splitter1.Align:=alRight;
      PAnel2.Align:=alClient;
      if Panel1.Width > Trunc(0.9*self.Width) then Panel1.Width := Trunc(0.5*self.Width);
    end;
  2: begin  //panel abajo
      Panel1.Align:=alBottom;
      Splitter1.Align:=alBottom;
      PAnel2.Align:=alClient;
      if Panel1.Height > Trunc(0.9*self.Height) then Panel1.Height := Trunc(0.5*self.Height);
    end;
  else  //por defecto
    Panel1.Align:=alLeft;
    Splitter1.Align:=alLeft;
    PAnel2.Align:=alClient;
  end;
end;
procedure TfrmPrincipal.ChangeEditorState;
//Si llega aquí es porque cambia el estado del editor. Actualiza los menús:
begin
  if edPCom.Focused then begin
    AcPcmGuardar.Enabled:=ePCom.Modified;
    //este es el único editor que acepta Undo/Redo
    acEdUndo.Enabled:=ePCom.CanUndo;
    acEdRedo.Enabled:=ePCom.CanRedo;
    acEdPaste.Enabled := ePCom.CanPaste;
    //Cut Copy son acciones predefinidas, se activan solas.
  end else begin
    acEdUndo.Enabled:=false;
    acEdRedo.Enabled:=false;
    acEdPaste.Enabled := true;   //para poder pegar lo que haya en el portapapeles
  end;

end;
function TfrmPrincipal.StartLog(logName0: string): boolean;
{Inicia el registro de la salida.
Si encuentra errorm devuelve FALSE.}
begin
  if logState = logRunning then exit;  //verifica
  logName := logName0;   //actualiza nombre de archivo
  try
    AssignFile(logFile, logName);
    Rewrite(logFile);
    logState:=logRunning;
    exit(true);
  except
    logState:=logStopped;
    exit(false);
  end;
end;
procedure TfrmPrincipal.PauseLog;
{Pausa el registro del terminal.}
begin
  if logState = logRunning then
    logState := logPaused;
end;
procedure TfrmPrincipal.StartLog;
{Reinicia el registro, después de haber sido pausado.}
begin
  if logState = logPaused then
    logState := logRunning;
end;
procedure TfrmPrincipal.EndLog;
begin
  if logState=logStopped then
    exit;
  //Está abierto. Se debe cerrar.
  if proc.LastLine<>'' then begin
    //La última línea, siempre debe escribirse
    WriteLog(proc.LastLine);
  end;
  CloseFile(logFile);
  logState := logStopped;
end;
function TfrmPrincipal.WriteLog(txt: string): boolean;
{Escribe una línea de texto en el registro. SI se genera error devuelve FALSE.}
begin
  if logState <> logRunning then exit(true);
  try
    write(logFile, txt);
    exit(true);
  except
    exit(false);
  end;
end;
/////////////////////// ACCIONES ////////////////////////
procedure TfrmPrincipal.AcArcConecExecute(Sender: TObject);  //conexión rápida
var
  rpta: Byte;
begin
  if proc.state <> ECO_STOPPED then begin
    rpta := MsgYesNoCancel('Hay una conexión abierta. ¿Cerrarla?');
    if rpta in [2,3] then begin  //cancelar
      exit;    //sale
    end;
    if rpta = 1 then begin  //detener primero
      AcTerDesconExecute(nil);
    end;
  end;
  frmConexRap.ShowModal;
  if frmConexRap.Cancel then exit;
  case frmConexRap.tipo of
  TCON_TELNET: InicConectTelnet(frmConexRap.ip);
  TCON_SSH   : InicConectSSH(frmConexRap.ip);
  end;
  InicConect;   //inicia conexión
  //almacena conexión
  Config.escribirArchivoIni;  //guarda en configuración}
end;
procedure TfrmPrincipal.AcArcNueVenExecute(Sender: TObject);
//Abre una nueva ventana de la aplicación
begin
   Exec('TTerm.exe','');
end;
procedure TfrmPrincipal.AcArcNueSesExecute(Sender: TObject);  //Genera una nueva sesión
var F:textfile;
  rpta: Byte;
begin
  if proc.state <> ECO_STOPPED then begin
    rpta := MsgYesNoCancel('Hay una conexión abierta. ¿Cerrarla?');
    if rpta in [2,3] then begin  //cancelar
      exit;    //sale
    end;
    if rpta = 1 then begin  //detener primero
      AcTerDesconExecute(nil);
    end;
  end;
  AcTerLimBufExecute(self);  //limpia pantalla
  //Limpia archivo ini, para que cargue opciones por defecto
  AssignFile(F, Config.arIni);
  Rewrite(F);
  CloseFile(F);
  //lo lee de nuevo
  Config.LeerArchivoIni;
  frmEditMacros.acArcNuevoExecute(self);   //limpia ventana de macros
  AcPcmNuevoExecute(self);                 //limpìa panel de comandos

  ConfiguraEntorno;
  DistribuirPantalla; //ubica componentes
  //muestra dirección IP actual
  ActualizarInfoPanel0;

  Config.Configurar('1,1');   //muesta para configurar
  SesAct:='';   //Sin nombre
  ePComFileOpened; //para actualizar barra de título
end;
procedure TfrmPrincipal.AcArcAbrSesExecute(Sender: TObject); //Abrir sesión
begin
  OpenDialog1.Filter := dic('Archivo de sesión|*.ses|Todos los archivos|*.*');
  OpenDialog1.InitialDir:=rutSesiones;  //busca aquí por defecto
//  if SaveQuery then Exit;   //Verifica cambios
//  if Error<>'' then exit;  //hubo error
  if not OpenDialog1.Execute then exit;    //se canceló
  AbrirSesion(OpenDialog1.FileName);
end;
procedure TfrmPrincipal.AcArcIniRegExecute(Sender: TObject);
var
  arc0: TComponentName;
begin
  if logName='' then begin
    SaveDialog2.Filter := dic('Archivo de registro|*.log|Todos los archivos|*.*');
    SaveDialog2.InitialDir:=rutApp;  //busca aquí por defecto
    if not SaveDialog2.Execute then begin  //se canceló
      exit;    //se canceló
    end;
    arc0:=SaveDialog2.FileName;
    if FileExists(arc0) then begin
      if MsgYesNoCancel('El archivo %s ya existe.' + LineEnding + '¿Deseas sobreescribirlo?',
                        [arc0]) in [2,3] then exit;
    end;
  end;
  logName := arc0;
  if not StartLog(logName) then begin
    MsgErr('Error abriendo registro: ' + logName);
  end;
end;
procedure TfrmPrincipal.AcArcDetRegExecute(Sender: TObject);
begin
  EndLog;
end;
procedure TfrmPrincipal.AcArcGuaSesExecute(Sender: TObject);  //guardar sesión
begin
  if SesAct = '' then
    AcArcGuaSesCExecute(self)
  else begin
    config.escribirArchivoIni(SesAct);
  end;
end;
procedure TfrmPrincipal.AcArcGuaSesCExecute(Sender: TObject); //guarda sesión como
var
  arc0: String;
  NomArc: String;
begin
  SaveDialog1.Filter := dic('Archivo de sesión|*.ses|Todos los archivos|*.*');
  SaveDialog1.InitialDir:=rutSesiones;  //busca aquí por defecto
  if not SaveDialog1.Execute then begin  //se canceló
    exit;    //se canceló
  end;
  arc0 := SaveDialog1.FileName;
  if FileExists(arc0) then begin
    if MsgYesNoCancel('El archivo %s ya existe.' + LineEnding + '¿Deseas sobreescribirlo?',
                      [arc0]) in [2,3] then exit;
  end;
  NomArc := UTF8ToSys(arc0);   //asigna nuevo nombre
  if ExtractFileExt(NomArc) = '' then NomArc += '.'+'ses';  //completa extensión
//  SaveFile;   //lo guarda
  SesAct := NomArc;
  config.escribirArchivoIni(SesAct);
  ePComFileOpened; //para actualizar barra de título
end;
procedure TfrmPrincipal.AcArcSalirExecute(Sender: TObject);
begin
  Close;
end;

procedure TfrmPrincipal.acEdUndoExecute(Sender: TObject);
begin
  if edPCom.Focused then begin //El único editor que acepta Undo/Redo
    ePCom.Undo;
  end;
end;
procedure TfrmPrincipal.acEdRedoExecute(Sender: TObject);
begin
  if edPCom.Focused then begin //El único editor que acepta Undo/Redo
    ePCom.Redo;
  end;
end;
procedure TfrmPrincipal.acEdPasteExecute(Sender: TObject);
begin
  if edpCom.Focused then begin
    ePCom.Paste;  //pega en el editor
  end;
  if edTerm.Focused then begin
    proc.SendLn(ClipBoard.AsText);  //envía al terminal
  end;
end;

procedure TfrmPrincipal.AcVerBarEstExecute(Sender: TObject);
begin
  MostrarBarEst(not AcVerBarEst.Checked);
end;
procedure TfrmPrincipal.AcVerPanComExecute(Sender: TObject);
begin
  MostrarPanCom(not AcVerPanCom.Checked);
end;
procedure TfrmPrincipal.edPComDropFiles(Sender: TObject; X, Y: integer;
  AFiles: TStrings);
begin
  //Carga archivo arrastrados
  if ePCom.SaveQuery then Exit;   //Verifica cambios
  ePCom.LoadFile(AFiles[0]);
end;
procedure TfrmPrincipal.edPComEnter(Sender: TObject);  //Toma el enfoque
begin
  ChangeEditorState;  //para actualizar los menús
  ePCom.PanCursorPos := nil; //para forzar a actualiazr la posición del cursor
  ePCom.PanCursorPos := StatusBar1.Panels[2];
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

procedure TfrmPrincipal.AcPcmNuevoExecute(Sender: TObject);
begin
  if ePCom.SaveQuery then Exit;   //Verifica cambios
  ePCom.NewFile(false);
  ePComFileOpened;
  ePCom.Text:=dic('#Archivo de comandos')+LineEnding;
end;
procedure TfrmPrincipal.AcPcmAbrirExecute(Sender: TObject);
begin
  //Pone como primera opción todos los archivos, porque no se restringe solo a *.sh
  OpenDialog1.Filter:='Todos los archivos|*.*|Archivo de comandos|*.sh|Archivos de texto|*.txt';
  OpenDialog1.InitialDir:=config.fcRutArc.scripts;  //busca aquí por defecto
  ePCom.OpenDialog(OpenDialog1);
end;
procedure TfrmPrincipal.AcPcmCamPosExecute(Sender: TObject);  //cambia posición
begin
  if not panel1.Visible then exit;
  if Config.TipAlineam < 2 then inc(Config.TipAlineam) else Config.TipAlineam := 0;
  DistribuirPantalla;
  Config.escribirArchivoIni;  //para mantener cambios
end;
procedure TfrmPrincipal.AcPcmGuardarExecute(Sender: TObject);
begin
  ePCom.SaveFile;
end;
procedure TfrmPrincipal.AcPcmGuaComExecute(Sender: TObject);
begin
  SaveDialog1.Filter:='Archivo de comandos|*.sh|Todos los archivos|*.*';
  sAVEDialog1.InitialDir:=config.fcRutArc.scripts;  //busca aquí por defecto
  ePCom.SaveAsDialog(SaveDialog1);
end;
procedure TfrmPrincipal.EnviarTxt(txt: string);
//Envía un tetxo al terminal, aplicando el preprocesamiento si es necesario
var
  usu: string;
begin
  if Config.fcPanCom.UsarPrep then begin
    //se debe usar el preprocesador PreSQL
    PreProcesar('',txt, usu);
    if PErr.HayError Then begin
      msgerr(Perr.GenTxtError);
      exit;  //verificación
    end;
    proc.SendLn(PPro.TextSalida);
  end else begin   //envío común
    proc.SendLn(txt);
  end;
end;
procedure TfrmPrincipal.AcPCmEnvLinExecute(Sender: TObject);
var
  lin: String;
begin
  if proc = nil then exit;
  if edPCom.SelAvail then begin  //hay selección
    //envía texto seleccionado
    EnviarTxt(edPCom.SelText);
  end else begin  //no hay selección, envía la línea actual
    lin := edPCom.LineText;  //línea actual
    EnviarTxt(lin);
  end;
end;
procedure TfrmPrincipal.AcPCmEnvTodExecute(Sender: TObject);
//Envía todo el texto
begin
  if proc = nil then exit ;
  if Config.fcPanCom.SaveBefSend then
    AcPcmGuardarExecute(Self);
  if edPCom.SelAvail then begin
    //hay selección
    frmSelFuente.optSel.Checked := true;
    frmSelFuente.optLin.Enabled := false;
    frmSelFuente.ShowModal;
    If frmSelFuente.cancelado Then Exit;  //cancelado
    //se eligió
    If frmSelFuente.optTod.Checked Then begin  //todo
      EnviarTxt(edPCom.Text);
    end else if frmSelFuente.optSel.Checked Then begin  //selección
      EnviarTxt(edPCom.SelText);
    end Else begin   //solo la línea actual
      EnviarTxt(edPCom.LineText);
    End;
  end else begin
    //no hay selección, envía todo
    EnviarTxt(edPCom.Text);
  end;
end;
procedure TfrmPrincipal.acPCmEnvCtrCExecute(Sender: TObject); //Envía Ctrl+C
begin
  proc.Send(#3);
end;
procedure TfrmPrincipal.AcPcmOculExecute(Sender: TObject);
begin
  MostrarPanCom(false);
end;
procedure TfrmPrincipal.AcPcmVerBHerExecute(Sender: TObject);
begin
  MostrarBHerPcom(not AcPcmVerBHer.Checked);
end;
procedure TfrmPrincipal.AcPcmConfigExecute(Sender: TObject);
begin
  Config.Configurar('3.1');
end;

procedure TfrmPrincipal.AcTerConecExecute(Sender: TObject);
begin
  InicConect;   //inicia conexión
end;
procedure TfrmPrincipal.AcTerDesconExecute(Sender: TObject); //desconectar
begin
   if not proc.Close then
     msgerr('No se puede cerrar el proceso actual.');
end;
procedure TfrmPrincipal.AcTerConfigExecute(Sender: TObject); //configurar
begin
   Config.Configurar('2.1');
end;
procedure TfrmPrincipal.AcTerCopPalExecute(Sender: TObject);
const CARS = ['a'..'z','A'..'Z','0'..'9','_','-'];
var
  p, q: Integer;
  linAct: String;
  CurX: Integer;
begin
  CurX := edTerm.CaretX;
  linAct := edTerm.LineText;
  p := CurX; if p>length(linact) then exit;
  while (p>1) and (linAct[p] in CARS) do
    dec(p);
  if not (linAct[p] in CARS) then inc(p); //corrige
  q := CurX;
  while (q<=length(linAct)) and (linAct[q] in CARS) do
    inc(q);
  edTerm.BlockBegin:=Point(p,edTerm.CaretY);
  edTerm.BlockEnd :=Point(q,edTerm.CaretY);
  edTerm.CopyToClipboard;
end;
procedure TfrmPrincipal.AcTerCopNomExecute(Sender: TObject); //copia nombre
const CARS = ['a'..'z','A'..'Z','0'..'9','-','_','.'];
var
  p, q: Integer;
  linAct: String;
  CurX: Integer;
begin
  CurX := edTerm.CaretX;
  linAct := edTerm.LineText;
  p := CurX; if p>length(linact) then exit;
  while (p>1) and (linAct[p] in CARS) do
    dec(p);
  if not (linAct[p] in CARS) then inc(p); //corrige
  q := CurX;
  while (q<=length(linAct)) and (linAct[q] in CARS) do
    inc(q);
  edTerm.BlockBegin:=Point(p,edTerm.CaretY);
  edTerm.BlockEnd :=Point(q,edTerm.CaretY);
  edTerm.CopyToClipboard;
end;
procedure TfrmPrincipal.AcTerCopRutExecute(Sender: TObject); //copia ruta
const CARS = ['a'..'z','A'..'Z','0'..'9','-','_','\','/','.'];
var
  p, q: Integer;
  linAct: String;
  CurX: Integer;
begin
  CurX := edTerm.CaretX;
  linAct := edTerm.LineText;
  p := CurX; if p>length(linact) then exit;
  while (p>1) and (linAct[p] in CARS) do
    dec(p);
  if not (linAct[p] in CARS) then inc(p); //corrige
  q := CurX;
  while (q<=length(linAct)) and (linAct[q] in CARS) do
    inc(q);
  edTerm.BlockBegin:=Point(p,edTerm.CaretY);
  edTerm.BlockEnd :=Point(q,edTerm.CaretY);
  edTerm.CopyToClipboard;
end;
procedure TfrmPrincipal.AcTerCopNomRutExecute(Sender: TObject); //copia ruta y nombre
const CARS = ['a'..'z','A'..'Z','0'..'9','-','_','\','/','.'];
var
  p, q: Integer;
  linAct: String;
  CurX: Integer;
begin
  CurX := edTerm.CaretX;
  linAct := edTerm.LineText;
  p := CurX; if p>length(linact) then exit;
  while (p>1) and (linAct[p] in CARS) do
    dec(p);
  if not (linAct[p] in CARS) then inc(p); //corrige
  q := CurX;
  while (q<=length(linAct)) and (linAct[q] in CARS) do
    inc(q);
  edTerm.BlockBegin:=Point(p,edTerm.CaretY);
  edTerm.BlockEnd :=Point(q,edTerm.CaretY);
  edTerm.CopyToClipboard;
end;

procedure TfrmPrincipal.AcTerDetPrmExecute(Sender: TObject); //Detecta prompt
begin
  proc.AutoConfigPrompt;  //auto-detección
  config.fcDetPrompt.DetecPrompt := proc.detecPrompt;
  config.fcDetPrompt.prIni := proc.promptIni;
  config.fcDetPrompt.prFin := proc.promptFin;
  config.fcDetPrompt.TipDetec:=proc.promptMatch;
  config.fcDetPrompt.OnUpdateChanges;  //actualiza resaltador y al mismo proceso
end;
procedure TfrmPrincipal.AcTerEnvCtrlCExecute(Sender: TObject);  //Ctrl+C
begin
  proc.Send(#3);
end;
procedure TfrmPrincipal.AcTerEnvEnterExecute(Sender: TObject);  //Enter
begin
  proc.SendLn('');
end;
procedure TfrmPrincipal.AcTerEnvCRExecute(Sender: TObject);
begin
  proc.Send(#13);
end;
procedure TfrmPrincipal.AcTerEnvLFExecute(Sender: TObject);
begin
  proc.Send(#10);
end;
procedure TfrmPrincipal.AcTerEnvCRLFExecute(Sender: TObject);
begin
  proc.Send(#13#10);
end;
procedure TfrmPrincipal.AcTerLimBufExecute(Sender: TObject);
//limpia la salida
begin
  edterm.ClearAll;
  proc.ClearTerminal;  //generará el evento OnInitLines()
end;

procedure TfrmPrincipal.AcTerPrmArrExecute(Sender: TObject);
//Mueve al prompt anterior
var
  cy: Integer;
begin
  cy := BuscaPromptArr;
  if cy = -1 then begin
//    msgexc('No se encuentra el prompt anterior');
  end else begin
    edTerm.CaretXY := point(1,cy);
    edterm.SelectLine;
  end;
end;
procedure TfrmPrincipal.AcTerPrmAbaExecute(Sender: TObject);
//Mueve al prompt siguiente
var
  cy: Integer;
begin
  cy := BuscaPromptAba;
  if cy = -1 then begin
//    msgexc('No se encuentra el prompt siguiente');
  end else begin
    edTerm.CaretXY := point(1,cy);
    edterm.SelectLine;
  end;
end;

procedure TfrmPrincipal.AcHerGraMacExecute(Sender: TObject);
begin
  frmEditMacros.AcHerGrabExecute(self);
end;
procedure TfrmPrincipal.AcHerCfgExecute(Sender: TObject);
begin
  Config.Configurar;
  ActualizarInfoPanel0;
end;

procedure TfrmPrincipal.acAyuAyuExecute(Sender: TObject);
begin
  OpenURL('https://github.com/t-edson/Tito-s-Terminal/tree/master/Docs');
end;

procedure TfrmPrincipal.SetLanguage(lang: string);
//Rutina de traducción
begin
  frmConexRap.SetLanguage(Lang);
  case lowerCase(lang) of
  'es': begin
      mnArchivo.Caption:='&Archivo';
      mnEdicion.Caption:='&Edición';
      mnVer.Caption:='&Ver';
      mnPanCom.Caption:='Panel de &Comandos';
      mnTerminal.Caption:='&Terminal';
      mnHerram.Caption:='&Herramientas';
      mnAyuda.Caption:='Ay&uda';

      mnSesionesAlm.Caption:='&Sesiones Almacenadas';
      mnLenguajes.Caption:='&Lenguaje';
      mnComandosAlm.Caption:='Comandos A&lmacenados';
      mnEjecMacro.Caption:='&Ejecutar Macro';
      mnAbrMacro.Caption:='&Abrir Macro';
      mnGraMacro.Caption:='&Grabar Macro';
      mnTerSend.Caption:='&Enviar';
      MenuItem82.Caption:='Copiar Elemento';
      MenuItem72.Caption:='&Enviar';

      AcArcNueSes.Caption := '&Nueva Sesión';
      AcArcAbrSes.Caption := '&Abrir Sesión ...';
      AcArcGuaSes.Caption := '&Guardar Sesión';
      AcArcGuaSesC.Caption := 'G&uardar Sesión Como ...';
      AcArcDescon.Caption := '&Desconectar';
      AcArcIniReg.Caption := '&Iniciar Registro...';
      AcArcDetReg.Caption := 'De&tener Registro';
      AcArcSalir.Caption := '&Salir';
      AcArcConec.Caption := '&Conexión Rápida...';
      AcArcNueVen.Caption := 'Nueva &Ventana...';
      acEdUndo.Caption := '&Deshacer';
      acEdRedo.Caption := '&Rehacer';
      acEdCut.Caption := 'Cor&tar';
      acEdCopy.Caption := '&Copiar';
      acEdPaste.Caption := '&Pegar';
      acEdSelecAll.Caption := 'Seleccionar &Todo';
      acEdModCol.Caption := 'Modo Columna';
      AcVerPanCom.Caption := '&Panel de Comandos';
      AcVerBarEst.Caption := 'Barra de estado';
      AcVerEdiMac.Caption := 'Editor de &Macros';
      AcVerEdiRem.Caption := '&Editor Remoto';
      AcVerExpRem.Caption := 'E&xplorador Remoto';
      AcPcmNuevo.Caption := '&Nuevo';
      AcPcmAbrir.Caption := '&Abrir...';
      AcPcmGuardar.Caption := '&Guardar';
      AcPcmGuaCom.Caption := 'G&uardar Como...';
      AcPCmEnvLin.Caption := 'Enviar &Línea';
      AcPCmEnvTod.Caption := 'Enviar &Todo';
      acPCmEnvCtrC.Caption := 'Enviar Ct&rl+C';
      AcPcmOcul.Caption := 'Ocultar';
      AcPcmCamPos.Caption := 'Cambiar posición';
      AcPcmVerBHer.Caption := 'Ver Barra de &Herramientas';
      AcPcmConfig.Caption := 'Confi&gurar';
      AcTerConec.Caption := '&Conectar';
      AcTerDescon.Caption := '&Desconectar';
      AcTerLimBuf.Caption := '&Limpiar Buffer';
      AcTerDetPrm.Caption := 'Detectar &Prompt';
      AcTerVerBHer.Caption := 'Ver Barra de &Herramientas';
      AcTerPrmArr.Caption := '&Subir a prompt';
      AcTerPrmAba.Caption := '&Bajar a prompt';
      AcTerConfig.Caption := 'Confi&gurar';
      AcTerEnvCtrlC.Caption := 'Enviar &Ctrl-C';
      AcTerEnvEnter.Caption := 'Enviar &Enter';
      AcTerEnvCR.Caption := 'Enviar &CR';
      AcTerEnvCRLF.Caption := 'Enviar CR+&LF';
      AcTerEnvLF.Caption := 'Enviar LF';
      AcTerCopPal.Caption := 'Copiar &Palabra';
      AcTerCopNom.Caption := '&Nombre de Archivo';
      AcTerCopRut.Caption := 'R&uta de Archivo';
      AcTerCopNomRut.Caption := 'Copiar N&ombre y Ruta';
      AcHerCfg.Caption := 'Confi&guración...';
      AcHerGraMac.Caption := '&Grabar Macro';
      acAyuAyu.Caption:='Ay&uda';
      dicClear;  //los mensajes ya están en español
    end;
  'en': begin
      mnArchivo.Caption:='&File';
      mnEdicion.Caption:='&Edit';
      mnVer.Caption:='&View';
      mnPanCom.Caption:='&Command Panel';
      mnTerminal.Caption:='&Terminal';
      mnHerram.Caption:='&Tools';
      mnAyuda.Caption:='&Help';

      mnSesionesAlm.Caption:='&Stored Sesions';
      mnLenguajes.Caption:='&Language';
      mnComandosAlm.Caption:='Stored Commands';
      mnEjecMacro.Caption:='&Execute Macro';
      mnAbrMacro.Caption:='&Open Macro';
      mnGraMacro.Caption:='&Record Macro';
      mnTerSend.Caption:='&Send';
      MenuItem82.Caption:='Copy Element';
      MenuItem72.Caption:='&Send';

      AcArcNueSes.Caption := '&New Sesion';
      AcArcAbrSes.Caption := '&Open Sesion ...';
      AcArcGuaSes.Caption := '&Save Sesion';
      AcArcGuaSesC.Caption := 'Sa&ve Sesion as ...';
      AcArcDescon.Caption := '&Disconnect';
      AcArcIniReg.Caption := '&Start Log...';
      AcArcDetReg.Caption := 'S&top Log';
      AcArcSalir.Caption := '&Exit';
      AcArcConec.Caption := '&Quick Connection...';
      AcArcNueVen.Caption := 'New &Window...';
      acEdUndo.Caption := '&Undo';
      acEdRedo.Caption := '&Redo';
      acEdCut.Caption := 'C&ut';
      acEdCopy.Caption := '&Copy';
      acEdPaste.Caption := '&Paste';
      acEdSelecAll.Caption := 'Select &All';
      acEdModCol.Caption := 'Column Mode';
      AcVerPanCom.Caption := '&Comand Panel';
      AcVerBarEst.Caption := 'Status Bar';
      AcVerEdiMac.Caption := '&Macro Editor';
      AcVerEdiRem.Caption := 'Remote &Editor';
      AcVerExpRem.Caption := 'Remote E&xplorer';
      AcPcmNuevo.Caption := '&New';
      AcPcmAbrir.Caption := '&Open...';
      AcPcmGuardar.Caption := '&Save';
      AcPcmGuaCom.Caption := 'Sa&ve As...';
      AcPCmEnvLin.Caption := 'Send &Line';
      AcPCmEnvTod.Caption := 'Send &All';
      acPCmEnvCtrC.Caption := 'Send Ct&rl+C';
      AcPcmOcul.Caption := 'Hide';
      AcPcmCamPos.Caption := 'Change position';
      AcPcmVerBHer.Caption := 'Show &Toolbar';
      AcPcmConfig.Caption := 'Confi&gure';
      AcTerConec.Caption := '&Connect';
      AcTerDescon.Caption := '&Disconnect';
      AcTerLimBuf.Caption := '&Clean Buffer';
      AcTerDetPrm.Caption := 'Detect &Prompt';
      AcTerVerBHer.Caption := 'Show &Tollbar';
      AcTerPrmArr.Caption := 'Move &Up to prompt';
      AcTerPrmAba.Caption := 'Move &Down to prompt';
      AcTerConfig.Caption := 'Confi&gure';
      AcTerEnvCtrlC.Caption := 'Send &Ctrl-C';
      AcTerEnvEnter.Caption := 'Send &Enter';
      AcTerEnvCR.Caption := 'Send &CR';
      AcTerEnvCRLF.Caption := 'Send CR+&LF';
      AcTerEnvLF.Caption := 'Send LF';
      AcTerCopPal.Caption := 'Copy &Word';
      AcTerCopNom.Caption := '&File Name';
      AcTerCopRut.Caption := 'File &Path';
      AcTerCopNomRut.Caption := 'Copy Name and Path';
      AcHerCfg.Caption := 'Confi&gure...';
      AcHerGraMac.Caption := '&Record Macro';
      acAyuAyu.Caption:='&Help';
      //traducción
      dicSet('Hay una conexión abierta. ¿Cerrarla?','There is an opened connection. Close?');
      dicSet(' - Archivo: ', ' - File: ');
      dicSet('No se encuentra archivo: %s','File not found: %s');
      dicSet('En este momento, se está ejecutando una macro. ¿Detenerla?',
             'There is a Macro runnig. Stop it?');
      dicSet('Ejecutando macro','Running macro');
      dicSet('No hay conexión disponible','No available connection');
      dicSet('Tiempo de espera agotado','Timeout');
      dicSet('Error detectando el prompt del comando. ','Error detecting prompt.');
      dicSet('Probablemente deba ampliar la cantidad de líneas de la pantalla.',
             'Probably you must increase the max number of lines in screen');
      dicSet('Archivo de sesión|*.ses|Todos los archivos|*.*','Sesion file|*.ses|All files|*.*');
      dicSet('El archivo %s ya existe.' + LineEnding + '¿Deseas sobreescribirlo?',
             'File % salready exists. Overwrite?');
      dicSet('#Archivo de comandos','#Command file');
    end;
  end;
end;

end.

