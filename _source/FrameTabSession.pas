unit FrameTabSession;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, fgl, Forms, Controls, ExtCtrls, ComCtrls, Dialogs,
  Graphics, LCLType, LCLProc, ActnList, StdActns, Menus, StdCtrls,
  SynPluginMultiCaret, SynPluginSyncroEdit, SynFacilUtils, FormSelFuente,
  MisUtils, MiConfigXML, MiConfigBasic, UnTerminal, TermVT, SynEdit,
  SynEditMarkupHighAll, SynEditKeyCmds, SynEditMarkup, SynEditTypes,
  uResaltTerm, Globales, FormSesProperty, FormConfig, uPreProces, uPreBasicos;
const
  FONT_TAB_SIZE = 9;
  MIN_WIDTH_TAB = 50;  //Ancho por defecto de la lengueta
  MAX_LIN_TER = 32000;

type
  TlogState = (logStopped, logRunning, logPaused);

  { TMarkup }
  {Marcador para resltar errores de sintaxis en SynEdit}
  TMarkup = class(TSynEditMarkupHighlightMatches)
    public
      procedure SetMark(p1, p2: TPoint);
  end;

  {Versión de "TConsoleProc" que permite acceder al campo "panel", donde se muestra el
  estado de la conexión}
  TConsoleProc2 = class(TConsoleProc)
    property panelState: TStatusPanel read panel write panel;
  end;
  {Parámetros de configuración de SynEdit}
  TEditCfg = record
    FontName   : string;   //Tipo de letra.
    FontSize   : integer;  //Tamaño de letra.
    MarLinAct  : boolean;  //Marcar línea actual.
    VerBarDesV : boolean;  //Ver barras de desplazamiento.
    VerBarDesH : boolean;  //Ver barras de desplazamiento.
    ResPalCur  : boolean;  //Resaltar palabra bajo el cursor.
    cTxtNor    : TColor;   //Color de texto normal.
    cFonEdi    : TColor;   //Color de fondo del control de edición.
    //cFonSel    : TColor;   //Color del fondo de la selección.
    //cTxtSel    : TColor;   //Color del texto de la selección.
    cLinAct    : TColor;   //Color de la línea actual.
    cResPal    : TColor;   //Color de la palabra actual.
    //Panel vertical
    VerPanVer  : boolean;  //Ver pánel vertical.
    VerNumLin  : boolean;  //Ver número de línea.
    VerMarPle  : boolean;  //Ver marcas de plegado.
    cFonPan    : TColor;   //Color de fondo del panel vertical.
    cTxtPan    : TColor;   //Color de texto del panel vertical.
  end;

  { TfraTabSession }
  TfraTabSession = class(TFrame)
  published
    acEdCopy: TEditCopy;
    acEdCut: TEditCut;
    acEdPaste: TAction;
    acEdRedo: TAction;
    acEdSelecAll: TAction;
    acEdUndo: TAction;
    AcFilNewSes: TAction;
    AcFIlOpeSes: TAction;
    AcFilSavSes: TAction;
    AcFilSavSesAs: TAction;
    AcFilStarLog: TAction;
    AcFilStopLog: TAction;
    AcHerCfg: TAction;
    AcHerGraMac: TAction;
    AcPCmCamPos: TAction;
    acPCmEnvCtrC: TAction;
    AcPCmEnvLin: TAction;
    AcPCmEnvTod: TAction;
    AcPCmOcul: TAction;
    AcTerConec: TAction;
    AcTerCopNom: TAction;
    AcTerCopNomRut: TAction;
    AcTerCopPal: TAction;
    AcTerCopRut: TAction;
    AcTerDescon: TAction;
    AcTerDetPrm: TAction;
    AcTerEnvCR: TAction;
    AcTerEnvCRLF: TAction;
    AcTerEnvEnter: TAction;
    AcTerEnvLF: TAction;
    AcTerLimBuf: TAction;
    AcTerPrmAba: TAction;
    AcTerPrmArr: TAction;
    AcTerVerBHer: TAction;
    acFindFind: TAction;
    acFindNext: TAction;
    acFindPrev: TAction;
    acFindReplace: TAction;
    ActionList1: TActionList;
    FindDialog1: TFindDialog;
    ImageList1: TImageList;
    imgBookMarks: TImageList;
    MenuItem2: TMenuItem;
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
    MenuItem72: TMenuItem;
    MenuItem73: TMenuItem;
    MenuItem74: TMenuItem;
    MenuItem75: TMenuItem;
    MenuItem76: TMenuItem;
    MenuItem77: TMenuItem;
    MenuItem78: TMenuItem;
    MenuItem80: TMenuItem;
    MenuItem81: TMenuItem;
    MenuItem82: TMenuItem;
    MenuItem83: TMenuItem;
    MenuItem84: TMenuItem;
    MenuItem85: TMenuItem;
    MenuItem86: TMenuItem;
    mnPopComAlm: TMenuItem;
    mnPopLeng: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    ReplaceDialog1: TReplaceDialog;
    SaveDialog1: TSaveDialog;
    SaveDialog2: TSaveDialog;
    Splitter1: TSplitter;
    edPCom: TSynEdit;
    edTerm: TSynEdit;
    Timer1: TTimer;
    ToolBar1: TToolBar;
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
    ToolButton22: TToolButton;
    ToolButton23: TToolButton;
    ToolButton24: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    procedure acFindFindExecute(Sender: TObject);
    procedure AcFilSavSesAsExecute(Sender: TObject);
    procedure AcFilSavSesExecute(Sender: TObject);
    procedure AcFilStarLogExecute(Sender: TObject);
    procedure AcFilStopLogExecute(Sender: TObject);
    procedure acFindNextExecute(Sender: TObject);
    procedure acFindPrevExecute(Sender: TObject);
    procedure acFindReplaceExecute(Sender: TObject);
    procedure AcHerCfgExecute(Sender: TObject);
    procedure acPCmEnvCtrCExecute(Sender: TObject);
    procedure AcPCmEnvLinExecute(Sender: TObject);
    procedure AcPCmEnvTodExecute(Sender: TObject);
    procedure AcTerConecExecute(Sender: TObject);
    procedure AcTerCopNomExecute(Sender: TObject);
    procedure AcTerCopNomRutExecute(Sender: TObject);
    procedure AcTerCopPalExecute(Sender: TObject);
    procedure AcTerCopRutExecute(Sender: TObject);
    procedure AcTerDesconExecute(Sender: TObject);
    procedure AcTerDetPrmExecute(Sender: TObject);
    procedure AcTerEnvCRExecute(Sender: TObject);
    procedure AcTerEnvCRLFExecute(Sender: TObject);
    procedure AcTerEnvEnterExecute(Sender: TObject);
    procedure AcTerEnvLFExecute(Sender: TObject);
    procedure AcTerLimBufExecute(Sender: TObject);
    procedure AcTerPrmAbaExecute(Sender: TObject);
    procedure AcTerPrmArrExecute(Sender: TObject);
    procedure AcTerVerBHerExecute(Sender: TObject);
    procedure edPComEnter(Sender: TObject);
    procedure edTermEnter(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    ejecCom: boolean;   //indica que está ejecutando un comando (editor remoto, exp. remoto ...)
    hlTerm  : TResaltTerm;
    LlegoPrompt: boolean;   //bandera
    parpadPan0: boolean;   //para activar el parpadeo del panel0
    ticComRec : integer;   //contador para comando recurrente
    edFocused : TSynEdit;  //Editor con enfoque
    function BuscaPromptArr: integer;
    function BuscaPromptAba: integer;
    function BuscaUltPrompt: integer;
    function ConexDisponible: boolean;
    procedure ConfigEditor(ed: TSynEdit; cfgEdit: TEditCfg);
    procedure DistribuirPantalla;
    procedure UpdateActionsState(Sender: TObject);
    procedure edPComKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EnvioTemporizado;
    procedure ePComMenLangSelected(langName, xmlFile: string);
    procedure eScript_MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure TestRecurringCommand;
    function InfoConnection: string;
    procedure edPComKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure proc_AddLine(HeightScr: integer);
    procedure proc_ChangeState(info: string; pIni: TPoint);
    procedure proc_InitScreen(const grilla: TtsGrid; fIni, fFin: integer);
    procedure proc_LineCompleted(const lin: string);
    procedure proc_LlegoPrompt(prmLine: string; pIni: TPoint; HeightScr: integer
      );
    procedure proc_RefreshLine(const grilla: TtsGrid; fIni, HeightScr: integer);
    procedure proc_RefreshLines(const grilla: TtsGrid; fIni, fFin,
      HeightScr: integer);
    procedure EnviarTxt(txt: string);
  public  //Propiedades de lengueta
    { TODO : Para mejor separación de funciones, estos atributos no deberían estar aqui, sino en FrameTabSessions }
    x1      : integer;  //Coordenada inicial de dibujo
    tabWidth: integer;  //Ancho de lengueta
  public
    proc  : TConsoleProc2; //Referencia al proceso actual
    ePCom : TSynFacilEditor;
    PanInfoConn: TStatusPanel;  //Panel de información sobre la conexión
    procedure ConnectToGUI;
    procedure SetHide;
    procedure Activate; reintroduce;
    function getModified: boolean;
    procedure setModified(AValue: boolean);
    procedure PosicionarCursor(HeightScr: integer);
    function EnviarComando(com: string; var salida: TStringList): string;
    procedure UpdatePanInfoConn;
    procedure UpdatePanelState;
    procedure UpdatePanelLangName;
    procedure UpdateCommand;
    procedure PropertiesChanged;
  public   //Parámetros de conexión
    Tipo      : TTipCon;  //Tipo de conexión
    IP        : String;   //Direción IP (solo válido con el tipo TCON_TELNET Y TCON_SSH)
    Port      : String;   //Puerto (solo válido con el tipo TCON_TELNET Y TCON_SSH)
    Command   : string;   //comando a ejecutar en el proceso
    Other     : String;   //Ruta del aplicativo (solo válido con el tipo TCON_OTHER)
    LineDelimSend: TUtLineDelSend;  //Tipo de delimitador de línea a enviar.
    LineDelimRecv: TUtLineDelRecv;  //Tipo de delimitador de línea a recibir.
    ConRecientes : TStringList;  //Lista de conexiones recientes
  public   //Parámetros de detección de prompt
    detecPrompt: boolean;
    prIni      : string;
    prFin      : string;
    TipDetec   : TPrompMatch;
  public   //Parámetros de pantalla del Terminal
    maxLinTer  : integer;  //Máxima cantidad de líneas que se nantienen en el terminal
    maxColTer  : integer;  //Máxima cantidad de columnas que se muestran en el terminal
    interDirec : boolean;  //Interceptar teclas direccionales
    curSigPrm  : boolean;  //cursor sigue a prompt
  public    //Parámetros del editor del Terminal
    cfgEdTerm  : TEditCfg;
  public   //Parámetros de Comando recurrente
    Activar  : boolean;
    Tempo    : integer;
    tipEnvio: TTipEnvio;
    tipEnvio0: TTipEnvio;  //temporal
    Comando  : string;
    Comando0 : string;
    Archivo  : string;
    Archivo0 : string;
  public   //Parámetros del panel de comandos
    CompletCode: boolean;   // Habilita el completado de código.
    CodFolding : boolean;   // Habilita el plegado de código.
    SendLnEnter: boolean;   // Enviar la línea actual con <Enter>.
    SendLnCtrEnter: boolean;// Enviar la línea actual con <Ctrl>+<Enter>.
    UsarPrep   : boolean;   // Usar preprocesador.
  public   //Parámetros del editor del comandos
    cfgEdPCom  : TEditCfg;
  public   //Parámetros adicionales
    langFile   : string;    //Archivo del lenguaje para el resaltador.
    textPCom   : TStrings;  //Texto del panel de comandos
    textTerm   : TStrings;  //Texto del terminal.
    pComWidth  : integer;   //Ancho de panel de comando.
    showPCom   : boolean;   //Visibilidad del panel de comandos
    showTerm   : boolean;   //Visibilidad del Terminal
  public   //Detección de prompt
    procedure UpdatePromptProc;
    function ContienePrompt(const linAct: string): integer;
    function EsPrompt(const cad: string): boolean;
  private  //Acceso a disco
    procedure UpdateCaption(filName: string);
    function getFileName: string;
    procedure setFileName(AValue: string);
  public   //Acceso a disco
    property fileName: string read getFileName write setFileName;
    function SaveToFile: boolean;
    function SaveAsDialog: boolean;
    procedure LoadFromFile;
  public   //Campos para manejo del registro
    logState: TlogState;  //estado del registro
    logFile : text;
    logName : string;   //archvio de registro
    function StartLog(logName0: string): boolean;
    procedure PauseLog;
    procedure StartLog;
    procedure EndLog;
    function WriteLog(txt: string): boolean;
  public   //Manejadores de eventos
    function queryClose: boolean;
  public   //Inicialización
    prop : TMiConfigXML;
    function ShowProperties: TModalResult;
    procedure InicConect;
    procedure InicConectTelnet(ip0: string);
    procedure InicConectSSH(ip0: string);
    constructor Create(AOwner: TComponent); override;
    procedure Init;
    procedure ExecSettings;
    destructor Destroy; override;
  end;

  TPages = specialize TFPGObjectList<TfraTabSession>;

procedure InicTerminal(edTerm: TSynEdit; hlTerm: TResaltTerm);

implementation
uses FrameTabSessions;
{$R *.lfm}
resourcestring
  MSG_MODIFSAV = 'File %s has been modified. Save?';

function GetTabSessions(pag: TfraTabSession; out tabSessions: TfraTabSessions): boolean;
{Devuelve la referencia al contenedor de páginas de este frame. Si no lo encuentra,
devuelve FALSE.}
var
  panContent: TWinControl;
begin
  panContent := pag.Parent;  //Panel contenedor.
  if panContent = nil then exit(false);
  tabSessions := TfraTabSessions(panContent.Parent);  //Debe ser TFraTabSessions, sino fallará.
  //if tabSessions.ClassName<>'TFraTabSessions' then exit(false);  //Verifica clase
  if tabSessions=nil then exit(false);
  exit(true);
end;
procedure InicTerminal(edTerm: TSynEdit; hlTerm: TResaltTerm);
var
  SynMarkup: TSynEditMarkupHighlightAllCaret;  //para resaltar palabras iguales
begin
  edTerm.Highlighter := hlTerm;  //asigna resaltador
  edTerm.Color := clBlack;
  edTerm.Gutter.Width := 37;
  edTerm.Gutter.Parts[0].Visible := false;
  edTerm.Gutter.Parts[2].Visible := false;
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
end;
{ TMarkup }
procedure TMarkup.SetMark(p1, p2: TPoint);
begin
  Matches.StartPoint[0] := p1;
  Matches.EndPoint[0]   := p2;
  InvalidateSynLines(p1.y, p2.y);
end;
{ TfraTabSession }
procedure TfraTabSession.edPComKeyUp(Sender: TObject; var Key: Word;
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
  Enter: Boolean;
begin
  Enter := (key = VK_RETURN);
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
  //end else if (Shift = [ssCtrl]) and (key = VK_C) then begin  //Ctrl + C
  //  AcTerEnvCtrlCExecute(nil)  //envía Ctrl+C al terminal
  end;
end;
procedure TfraTabSession.proc_AddLine(HeightScr: integer);
var
  i: Integer;
begin
//  debugln('procAddLine: ');
  edTerm.BeginUpdate();
  if edTerm.Lines.Count>maxLinTer then begin
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
procedure TfraTabSession.proc_ChangeState(info: string; pIni: TPoint);
//Hubo un cambio de estado
begin
  AcTerConec.Enabled := proc.state = ECO_STOPPED;
  AcTerDescon.Enabled := not (proc.state = ECO_STOPPED);
end;
procedure TfraTabSession.proc_InitScreen(const grilla: TtsGrid; fIni,
  fFin: integer);
var
  i: Integer;
begin
//  debugln('procAddLastLins: '+IntToStr(fIni)+','+IntToSTr(fFin));
  for i:=fIni to fFin do
    edTerm.Lines.Add(grilla[i]);
end;
procedure TfraTabSession.proc_LineCompleted(const lin: string);
begin
  if logState = logRunning then begin
    writeln(logFile, lin);
  end;
end;
procedure TfraTabSession.proc_LlegoPrompt(prmLine: string; pIni: TPoint;
  HeightScr: integer);
begin
  LlegoPrompt := true;  //activa bandera
//  yvt := edTerm.Lines.Count-HeightScr-1;  //calcula fila equivalente a inicio de VT100
//debugln('  llegoPrompt en:'+IntToStr(yvt + pIni.y+1));
end;
procedure TfraTabSession.proc_RefreshLine(const grilla: TtsGrid; fIni,
  HeightScr: integer);
var
  yvt: Integer;
begin
//  debugln('procRefreshLine: '+IntToStr(fIni));
  yvt := edTerm.Lines.Count-HeightScr-1;  //calcula fila equivalente a inicio de VT100
  edTerm.Lines[yvt+fIni] := grilla[fIni];
  PosicionarCursor(HeightScr);
end;
procedure TfraTabSession.proc_RefreshLines(const grilla: TtsGrid; fIni, fFin,
  HeightScr: integer);
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
procedure TfraTabSession.EnviarTxt(txt: string);
//Envía un tetxo al terminal, aplicando el preprocesamiento si es necesario
var
  usu: string;
begin
  if UsarPrep then begin
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
function TfraTabSession.InfoConnection: string;
//Actualiza el panel 0, con información de la conexión o de la ejecución de macros
begin
   case Tipo of
   TCON_TELNET:
      Result :='Telnet: ' + IP;
   TCON_SSH:
      Result :='SSH: '    + IP;
   TCON_SERIAL:
      Result :='Serial: ' + frmSesProperty.cmbSerPort.Text;
   TCON_OTHER:
      Result :='Proc: '   + Other;
   end;
end;
procedure TfraTabSession.ConnectToGUI;
var
  tabSessions: TfraTabSessions;
  res: string;
begin
  if not GetTabSessions(self, tabSessions) then exit;
  tabSessions.PageEvent('req_conn_gui', self, res);  //Requiere conexión a GUI
end;
procedure TfraTabSession.SetHide;
begin
  self.Hide;
end;
procedure TfraTabSession.Activate;
{Hace visible este frame. Se usa cuando se conmuta entre varias páginas.}
begin
  Show;              //Primero se hace visible.
  ConnectToGUI;      //Pide configurar eventos.
  UpdatePanInfoConn; //Actualiza panel con información de la conexión.
  UpdatePanelState;  //Actualiza panel de estado de la conexión
  ePCom.RefreshPanCursor;  //Refresca el panel de posición del cursor.
  UpdatePanelLangName; //Actualiza nombre del lenguaje.
end;
procedure TfraTabSession.UpdatePanInfoConn;
{Actualiza el panel de información de la conexión.}
begin
  if PanInfoConn<>nil then PanInfoConn.Text := InfoConnection;
end;
procedure TfraTabSession.UpdatePanelState;
{Actualiza el panel de estado de la conexión.}
begin
  proc.RefPanelEstado;
end;
procedure TfraTabSession.UpdatePanelLangName;
{Actualiza el panel del lenguaje del resaltador.}
begin
  ePCom.PanLangName.Text := ePCom.hl.LangName;
end;
function TfraTabSession.getModified: boolean;
begin
  Result := edPCom.Modified;
end;
procedure TfraTabSession.setModified(AValue: boolean);
begin
  edPCom.Modified := AValue;
end;
procedure TfraTabSession.PosicionarCursor(HeightScr: integer);
//Coloca el cursor del editor, en la misma posición que tiene el cursor del
//terminal VT100 virtual.
var
  yvt: Integer;
begin
  if curSigPrm then begin
    yvt := edTerm.Lines.Count-HeightScr-1;  //calcula fila equivalente a inicio de VT100
    edTErm.CaretXY := Point(proc.term.curX, yvt+proc.term.CurY+1);
  end;
end;
procedure TfraTabSession.PropertiesChanged;
{Rutinas a ejecutar cuando han cambiado las propiedades de la sesión, como cuando se
cargan de archivo o se cambian con la ventana de propiedades.}
begin
  UpdatePromptProc;   //Actualiza los parámetros de detección del "prompt" en "proc".
  UpdatePanInfoConn;  //Actualiza información de la conexión
  UpdatePanelState;   //Actualiza panel del estado de la conexión
  ePCom.RefreshPanCursor;  //Refresca el panel de posición del cursor.
  if langFile<>'' then begin  //Carga coloreado de sintaxis, actualiza menú y panel.
    ePCom.LoadSyntaxFromFile(langFile);
  end;
  //Actualiza controles que dependen de las propiedades.
  ConfigEditor(edTerm, cfgEdTerm);       //Configura editor.
  ConfigEditor(edPCom, cfgEdPCom);       //Configura editor.
  edTerm.Invalidate; //Para que refresque los cambios.
  edPCom.Invalidate; //Para que refresque los cambios.
  edPCom.Width := pComWidth;
  //Visibilidad del panel de comando Y del terminal
  if showPCom and showTerm then begin  //Mostrar ambos
    edPCom.Visible := true;
    edPCom.Align := alLeft;
    Splitter1.Visible := true;
    edTerm.Visible := true;
    edTerm.Align := alClient;
  end else if showPCom then begin  //Solo panel de comandos
    edPCom.Visible := true;
    edPCom.Align := alClient;  //Toda la pantalla
    Splitter1.Visible := false;
    edTerm.Visible := false;
  end else if showTerm then begin  //Solo Terminal
    edPCom.Visible := false;
    Splitter1.Visible := false;
    edTerm.Visible := true;
    edTerm.Align := alClient;  //Toda la pantalla
  end else begin
    edPCom.Visible := false;
    edTerm.Visible := false;
  end;
end;
//Acceso a disco
procedure TfraTabSession.UpdateCaption(filName: string);
{Actualiza el nombre del "Caption" del frame. Este nombre es el que se mostrará en la
lengueta de esta página.}
var
  tabSessions: TfraTabSessions;
begin
  //La primera regla, es tomar solo el nombre del archivo.
  Caption := ExtractFileName(filName);
  if not GetTabSessions(self, tabSessions) then exit;  //Acceso a "tabSessions"
  //Pero debemos validarla en el contenedor, si no queremos que se duplique.
//  tabSessions.ValidateCaption();
  {También deberíamos actualizar la geometría que maneja el contenedor, porque si
  cambia el "Caption", puede cambiar el ancho de la lengueta.}
  tabSessions.UpdateTabWidth(self);  //Cambia el título Hay que actualizar ancho de lengueta.
end;
function TfraTabSession.getFileName: string;
begin
  //Usamos en nombre del archivo del objeto "prop"
  Result := prop.GetFileName;   //Usamos el "Caption como nombre de archivo".
end;
procedure TfraTabSession.setFileName(AValue: string);
begin
  prop.SetFileName(AValue);
end;
function TfraTabSession.SaveToFile: boolean;
{Guarda esta página en "fileName". Si se cancela el guardado o hay algún error, se
devuelve FALSE.}
begin
  if not FileExists(FileName) then begin
    //Es un archivo nuevo, que no se ha guardado.
    Result := SaveAsDialog();
  end else begin
    //Se guarda como configuración
    if not prop.PropertiesToFile then begin
      MsgErr(prop.MsjErr);
    end;
    setModified(false);
    UpdateActionsState(nil);
    Result := true;
  end;
end;
function TfraTabSession.SaveAsDialog: boolean;
{Muestra la ventana para grabar esta sesión. Si se cancela, o no se puede grabar,
devuelve FALSE.}
var
  arc0, res, filter: String;
  resp: TModalResult;
  tabSessions: TfraTabSessions;
begin
  //debugln(self.fileName);
  if not GetTabSessions(self, tabSessions) then exit;
  filter := 'Text files|*.txt|All files|*.*';  //Filtro por defecto
  //Pide filtro para el diálogo "Save As"
  tabSessions.PageEvent('req_filt_save', self, res);
  if res<>'' then filter := res;
  SaveDialog1.Filter := filter;
  //SaveDialog1.DefaultExt := MSG_FILE_EXT;
  SaveDialog1.FileName := fileName;
  if not SaveDialog1.Execute then begin  //se canceló
    exit(false);    //se canceló
  end;
  arc0 := SaveDialog1.FileName;
  if FileExists(arc0) then begin
    resp := MessageDlg('', Format('File %s already exists.',[arc0]) + LineEnding +
                  '¿Overwrite?',
                  mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if (resp = mrCancel) or (resp = mrNo) then exit(false);
  end;
  fileName := arc0;   //asigna nuevo nombre
  if ExtractFileExt(fileName) = '' then begin
    tabSessions.PageEvent('reg_def_ext', self, res);  //Pide extensión por defecto
    fileName := fileName + res;  //Completa extensión
  end;
  //Puede haber cambiado el nombre del archivo. Actualiza texto de la lengueta.
  UpdateCaption(fileName);
  //Delegamos la función de guardar históricos a la IDE
  tabSessions.PageEvent('reg_reg_file', self, res);
  //Finalmente guarda.
  if not prop.PropertiesToFile then begin
    MsgErr(prop.MsjErr);
  end;
  setModified(false);
  UpdateActionsState(nil);
  exit(true);
end;
procedure TfraTabSession.LoadFromFile;
{Actualiza el contenido de esta sesión a partir del archivo especificado en "fileName".}
var
  tabSessions: TfraTabSessions;
  res: string;
begin
  if not GetTabSessions(self, tabSessions) then exit;
  prop.FileToProperties;  //Accede a "fileName"
  if prop.MsjErr<>'' then begin  //Accede a "fileName"
    MsgErr(prop.MsjErr);
  end;
  //Puede haber cambiado el nombre del archivo. Actualiza texto de la lengueta.
  UpdateCaption(fileName);
  PropertiesChanged;   //Procesa el cambio de propiedades
  //Delegamos la función de guardar históricos a la IDE
  tabSessions.PageEvent('reg_reg_file', self, res);
end;
//Campos para manejo del registro
function TfraTabSession.StartLog(logName0: string): boolean;
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
procedure TfraTabSession.PauseLog;
{Pausa el registro del terminal.}
begin
  if logState = logRunning then
    logState := logPaused;
end;
procedure TfraTabSession.StartLog;
{Reinicia el registro, después de haber sido pausado.}
begin
  if logState = logPaused then
    logState := logRunning;
end;
procedure TfraTabSession.EndLog;
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
function TfraTabSession.WriteLog(txt: string): boolean;
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
function TfraTabSession.queryClose: boolean;
{Consulta si se puede cerrar esta ventana. De ser así se devolverá TRUE.}
var
  rpta: Byte;
  resp: TModalResult;
begin
  //Verificación del estado del proceso.
  if proc.state <> ECO_STOPPED then begin
    rpta := MsgYesNoCancel('There is an opened connection. ¿Close?');
    if rpta in [2,3] then begin  //cancelar
      exit(false);    //sale
    end;
    if rpta = 1 then begin  //detener primero
      AcTerDesconExecute(nil);
    end;
  end;
  //Verificación del texto grabado
  if edPCom.Modified then begin
    resp := MessageDlg('', Format(MSG_MODIFSAV, [ExtractFileName(fileName)]),
                       mtConfirmation, [mbYes, mbNo, mbCancel],0);
    if resp = mrCancel then begin
      exit(false);
    end;
    if resp = mrYes then begin  //guardar
      if not SaveToFile then exit(false);
    end;
  end;
  exit(true);
end;
procedure TfraTabSession.DistribuirPantalla;
//Redistribuye los paneles de la pantalla
begin
//  //primero quita alineamiento de componentes móviles
//  PAnel2.Align:=alNone;
//  Panel1.Align:=alNone;
//  Splitter1.Align:=alNone;
//  //alinea de acuerdo a TipAlineam
//  case Config.TipAlineam of
//  0: begin  //panel a la izquierda
//      Panel1.Align:=alLeft;
//      Splitter1.Align:=alLeft;
//      Panel2.Align:=alClient;
//      if Panel1.Width > Trunc(0.9*self.Width) then Panel1.Width := Trunc(0.5*self.Width);
//    end;
//  1: begin  //panel a la derecha
//      Panel1.Align:=alRight;
//      Splitter1.Align:=alRight;
//      PAnel2.Align:=alClient;
//      if Panel1.Width > Trunc(0.9*self.Width) then Panel1.Width := Trunc(0.5*self.Width);
//    end;
//  2: begin  //panel abajo
//      Panel1.Align:=alBottom;
//      Splitter1.Align:=alBottom;
//      PAnel2.Align:=alClient;
//      if Panel1.Height > Trunc(0.9*self.Height) then Panel1.Height := Trunc(0.5*self.Height);
//    end;
//  else  //por defecto
//    Panel1.Align:=alLeft;
//    Splitter1.Align:=alLeft;
//    PAnel2.Align:=alClient;
//  end;
end;
procedure TfraTabSession.UpdateActionsState(Sender: TObject);
begin
  if edPCom.Modified then begin
    AcFilSavSes.Enabled := true;
  end else begin
    AcFilSavSes.Enabled := false;
  end;
end;
function TfraTabSession.ShowProperties: TModalResult;
begin
  prop.PropertiesToWindow;  //Actualiza formulario
  //LLama a los métodos apropiados para actualizar estado de los controles.
  frmSesProperty.chkMarLinActChange(self);
  frmSesProperty.chkVerPanVerChange(self);
  frmSesProperty.chkSendRecComChange(self);
  frmSesProperty.chkDetecPromptChange(self);
  //Ejecuta ventana de propiedades.
  frmSesProperty.Exec(proc.State<>ECO_STOPPED);
  //Evalúa resultado
  case frmSesProperty.ModalResult of
  mrYes, mrOK: begin  //Botones "Aceptar y Conectar" o "Aceptar".
    //Aplica cambios.
    prop.WindowToProperties;
    if prop.MsjErr<>'' then begin
      msgerr(prop.MsjErr);
      exit;
    end;
    PropertiesChanged;   //Procesa el cambio de propiedades
    //fcConex.GrabarIP;  //Debería grabar las últimas IP
  end;
  mrCancel: begin  //Cancelar
    //MsgBox('mrCancel');
  end;
  else  //No debería pasar.
    MsgBox('Unknown option');
  end;
  Result := frmSesProperty.ModalResult;
end;
function TfraTabSession.ConexDisponible: boolean;
//Indica si la conexión está en estado ECO_READY, es decir, que puede
//recibir un comando
begin
   Result := (proc.state = ECO_READY);
end;
function TfraTabSession.BuscaUltPrompt: integer;
//Busca el último prompt de todo el terminal
//Si no lo encuentra devuelve -1
var
  cy: Integer;
begin
  cy := edterm.Lines.Count+1;
  repeat
    dec(cy)
  until (cy<1) or (ContienePrompt(edTerm.Lines[cy-1])>0);
  if cy<1 then exit(-1) else exit(cy);
end;
function TfraTabSession.EnviarComando(com: string; var salida: TStringList): string;
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
    Result := 'Not available connection.';
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
  While Not LlegoPrompt And (n < Config.TpoMax2*10) do begin
    Sleep(100);
    Application.ProcessMessages;
    Inc(n);
  end;
  If n >= Config.TpoMax2*10 then begin    //Hubo desborde
    Result := dic('Timeout');
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
      Result := 'Error detecting command prompt. ' +
      'Maybe you must increase the number of lines shown in the screen.';
      MsgExc(Result);
      exit;
    end;
    //copia la salida
    for i:= y1+1 to y2-1 do  //sin contar los prompt
       salida.Add(edTerm.Lines[i-1]);
  end;
  ejecCom := false;
end;
function TfraTabSession.BuscaPromptArr: integer;
//Busca el primer prompt desde la posición actual hacia arriba
//Si no lo encuentra devuelve -1
var
  cy: Integer;
begin
  cy := edterm.CaretY;
  repeat
    dec(cy)
  until (cy<1) or (ContienePrompt(edTerm.Lines[cy-1])>0);
  if cy<1 then exit(-1) else exit(cy);
end;
function TfraTabSession.BuscaPromptAba: integer;
//Busca el primer prompt desde la posición actual hacia abajo
//Si no lo encuentra devuelve -1
var
  cy: Integer;
begin
  cy := edterm.CaretY;
  repeat
    inc(cy)
  until (cy>edTerm.Lines.Count) or (ContienePrompt(edTerm.Lines[cy-1])>0);
  if cy>edTerm.Lines.Count then exit(-1) else exit(cy);
end;
procedure TfraTabSession.edPComKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  Enter: Boolean;
begin
  Enter := (key = VK_RETURN);
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
procedure TfraTabSession.ePComMenLangSelected(langName, xmlFile: string);
{Se ha seleccionado un lenguaje para el resaltador, usando el menú contextual.}
begin
  langFile := xmlFile;
end;
procedure TfraTabSession.eScript_MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  caret: TPoint;
begin
  //Obtiene coordenada donde cae el puntero del mouse.
  if edPCom.SelAvail then begin
    PopupMenu1.PopUp;
  end else begin
    if (Button = mbRight) then begin
      caret := edPCom.PixelsToRowColumn(Point(X,Y));
      edPCom.CaretY := caret.y;
      //MsgBox('Eureka %d', [ caret.Y ] );
      PopupMenu1.PopUp;
    end;
  end;
end;
procedure TfraTabSession.TestRecurringCommand;
begin
  //guarda estado actual, para no perderlo
  tipEnvio0 := tipEnvio;
  Comando0 := Comando;
  Archivo0 := Archivo;
  prop.WindowToProperties;  //mueve valores de controles a variables
  //lama al evento para probar la temporización
  EnvioTemporizado;
  //Retorna valores
  tipEnvio := tipEnvio0;
  Comando := Comando0;
  Archivo := Archivo0;
end;
procedure TfraTabSession.EnvioTemporizado;
//Envía el comando o archivo que se ha programado
begin
  case tipEnvio of
  teComando:
      proc.SendLn(Comando);
  teArchivo: begin
      if not FileExists(archivo) then begin
        MsgErr('File not found: %s', [archivo]);
        exit;
      end;
      proc.SendLn(StringFromFile(archivo));
    end;
  end;
end;
procedure TfraTabSession.Timer1Timer(Sender: TObject);
{Temporizador cada de 0.5 segundos. Temporiza el envío de comandos recurrentes y
el parpadeo del Panel de Información de la conexión.}
begin
  //Muestra mensaje de ejecución
//  if ejecMac then begin
//    //fuerza refresco del panel
//    parpadPan0 := not parpadPan0;  //para el parpadeo
//    StatusBar1.InvalidatePanel(0,[ppText]);
//  end;
  if Activar then begin
    inc(ticComRec);
    if ticComRec mod (Tempo * 2 * 60) = 0 then begin
      //hay envío recurrente de comando
      EnvioTemporizado;
    end;
  end;
end;
procedure TfraTabSession.UpdateCommand;
//Configura el atributo "Command" de acuerdo a los parámetros de la conexión.
begin
  case Tipo of
  TCON_TELNET: begin
      if Port='' then begin
        Command:='plink -telnet ' + IP;
      end else begin
        Command:='plink -telnet ' + ' -P '+ Port + ' ' + IP;
      end;
    end;
  TCON_SSH: begin
      if Port='' then begin
        Command:='plink -ssh ' + IP + ' ';
      end else begin
        Command:='plink -ssh -P '+ Port + ' ' + IP + ' ';
      end;
    end;
  TCON_SERIAL: begin
      Command:='plink -serial ' + frmSesProperty.cmbSerPort.Text + ' -sercfg '+frmSesProperty.txtSerCfg.Text;
    end;
  TCON_OTHER: begin
      Command:=Other;
    end;
  end;
  //Configura salto de línea
  { TODO : ¿No se podría mejor eliminar LineDelimSend y LineDelimRecv; y usar "proc"? }
  proc.LineDelimSend := LineDelimSend;
  proc.LineDelimRecv := LineDelimRecv;
end;
procedure TfraTabSession.UpdatePromptProc;
{Configura al resaltador con la detección de prompt de la sesión. Se supone que se
debe llamar, cada vez que se cambia algún parámetro de la detección del prompt.}
begin
  //Configura detección de prompt en proceso
  if DetecPrompt then begin  //hay detección
    proc.detecPrompt:=true;
    proc.promptIni:= prIni;
    proc.promptFin:= prFin;
    proc.promptMatch := TipDetec;
  end else begin //sin detección
    proc.detecPrompt:=false;
  end;
  {Actualizar terminal para redibujar contenido con el resaltador "hlTerm" que ahora
  tiene sus parámetros cambiados (accesibles mediante hlTerm.curSesObj). }
  edTerm.Invalidate;
end;
function TfraTabSession.ContienePrompt(const linAct: string): integer;
//Verifica si una cadena contiene al prompt, usando los valroes de cadena inicial (prIni)
//y cadena final (prFin). La veriifcaión se hace siempre desde el inicio de la cadena.
//Si la cadena contiene al prompt, devuelve la longitud del prompt hallado, de otra forma
//devuelve cero.
//Se usa para el resaltador de sintaxis y el manejo de pantalla. Debería ser similar a
//la detección de prompt usada en el proceso.
var
  l: Integer;
  p: SizeInt;
begin
   Result := 0;   //valor por defecto
   l := length(prIni);
   if (l>0) and (copy(linAct,1,l) = prIni) then begin
     //puede ser
     if prFin = '' then begin
       //no hace falta validar más
       Result := l;  //el tamaño del prompt
       exit;    //no hace falta explorar más
     end;
     //hay que validar la existencia del fin del prompt
     p :=pos(prFin,linAct);
     if p>0 then begin  //encontró
       Result := p+length(prFin)-1;  //el tamaño del prompt
       exit;
     end;
   end;
end;
function TfraTabSession.EsPrompt(const cad: string): boolean;
//Indica si la línea dada, es el prompt, de acuerdo a los parámetros dados. Esta función
//se pone aquí, porque aquí se tiene fácil acceso a las configuraciones del prompt.
var
  n: Integer;
begin
  if DetecPrompt then begin  //si hay detección activa
    n := ContienePrompt(cad);
    Result := (n>0) and  (n = length(cad));
  end else begin
    Result := false;
  end;
end;
//Inicialización
procedure TfraTabSession.InicConect;
begin
  //Se supone que el proceso ya está configurado y listo para abrir
  UpdateCommand;   //Actualiza "Command".
  UpdatePanInfoConn; //Actualiza información de la conexión.
  //Inicia proceso
  proc.Open(Command, '');
  if msjError<>'' then begin
    MsgErr(msjError);
  end;
end;
constructor TfraTabSession.Create(AOwner: TComponent);
var
  fSynchro: TSynPluginSyncroEdit;
  fMultiCaret: TSynPluginMultiCaret;
begin
  inherited Create(AOwner);
  textPCom := edPCom.Lines;  //Toma referencia al texto, para guardar.
  textTerm := edTerm.Lines;  //Toma referencia al texto, para guardar.
  InicEditorC1(edPCom);
  edPCom.Options := edPCom.Options + [eoRightMouseMovesCursor];  //Para fijar el cursor con click derecho
  //Fija imágenes para marcadores
  edPCom.BookMarkOptions.BookmarkImages := imgBookMarks;
  //Crea un "plugin" de edición síncrona
  fSynchro := TSynPluginSyncroEdit.Create(self);
  fSynchro.Editor := edPCom;
  //Configura múltiples cursores
  fMultiCaret := TSynPluginMultiCaret.Create(self);
  with fMultiCaret do begin
    Editor := edPCom;
    with KeyStrokes do begin
      Add.Command    := ecPluginMultiCaretSetCaret;
      Add.Key        := VK_INSERT;
      Add.Shift      := [ssShift, ssCtrl];
      Add.ShiftMask  := [ssShift,ssCtrl,ssAlt];
//      Add.Command    := ecPluginMultiCaretUnsetCaret;
//      Add.Key        := VK_DELETE;
//      Add.Shift      := [ssShift, ssCtrl];
//      Add.ShiftMask  := [ssShift,ssCtrl,ssAlt];
    end;
  end;

//  edPCom.OnSpecialLineMarkup:=@edSpecialLineMarkup;

  ePCom := TSynFacilEditor.Create(edPCom,'Noname','sh');   //Crea Editor
  //ConnectToGUI;  Won't work now
//  ePCom.OnChangeEditorState := @ChangeEditorState;  //Se debe hacer con ConnectToGUI()
  ePCom.OnEditChange := @UpdateActionsState;
  ePCom.OnKeyUp     := @edPComKeyUp;
  ePCom.OnKeyDown   := @edPComKeyDown;
  ePCom.OnMouseDown := @eScript_MouseDown;
  ePCom.NewFile;   //Pone en modo "NewFile", para actualizar estado inicial.
  ePCom.InitMenuLanguages(mnPopLeng, patSyntax);  //Inicia menú de lenguajes para el resaltador
  ePCom.OnMenLangSelected := @ePComMenLangSelected; //Controla la selección del lenguaje.

  //COnfiguración de pantalla de terminal
  hlTerm := TResaltTerm.Create(nil);  //Crea resaltador
  hlTerm.curSesObj := self;  //Fija referencia a esta sesión
  InicTerminal(edTerm, hlTerm);
  tabWidth := 30;  //valor por defecto

  //Inicia proceso
  proc := TConsoleProc2.Create(nil);  //El panel se fijará luego, cuando se conecte a la GUI.
  proc.OnInitScreen   := @proc_InitScreen;
  proc.OnRefreshLine  := @proc_RefreshLine;
  proc.OnRefreshLines := @proc_RefreshLines;
  proc.OnAddLine      := @proc_AddLine;
  proc.OnGetPrompt    := @proc_LlegoPrompt;
  proc.OnChangeState  := @proc_ChangeState;
  proc.OnLineCompleted:= @proc_LineCompleted;
  //Usado para el registro
  AcTerDescon.Enabled:=false;  //Se supone que inicia siempre sin conectar.
end;
procedure TfraTabSession.ConfigEditor(ed: TSynEdit; cfgEdit: TEditCfg);
{Configura el editor con las propiedades almacenadas}
var
  marc: TSynEditMarkup;
begin
   if ed = nil then exit;  //protección
   //tipo de texto
   if cfgEdit.FontName <> '' then ed.Font.Name := cfgEdit.FontName;  //El texto sin atributo
   if (cfgEdit.FontSize > 6) and (cfgEdit.FontSize < 32) then ed.Font.Size:=Round(cfgEdit.FontSize);

   ed.Font.Color := cfgEdit.cTxtNor;      //color de texto normal

   ed.Color:= cfgEdit.cFonEdi;           //color de fondo
   if cfgEdit.MarLinAct then          //resaltado de línea actual
     ed.LineHighlightColor.Background:=cfgEdit.cLinAct
   else
     ed.LineHighlightColor.Background:=clNone;
   //configura panel vertical
   ed.Gutter.Visible:=cfgEdit.VerPanVer;  //muestra panel vertical
   ed.Gutter.Parts[1].Visible:=cfgEdit.VerNumLin;  //Número de línea
   if ed.Gutter.Parts.Count>4 then
     ed.Gutter.Parts[4].Visible:=cfgEdit.VerMarPle;  //marcas de plegado
   ed.Gutter.Color:=cfgEdit.cFonPan;   //color de fondo del panel
   ed.Gutter.Parts[1].MarkupInfo.Background:=cfgEdit.cFonPan; //fondo del núemro de línea
   ed.Gutter.Parts[1].MarkupInfo.Foreground:=cfgEdit.cTxtPan; //texto del núemro de línea

   if cfgEdit.VerBarDesV and cfgEdit.VerBarDesH then  //barras de desplazamiento
     ed.ScrollBars:= ssBoth
   else if cfgEdit.VerBarDesV and not cfgEdit.VerBarDesH then
     ed.ScrollBars:= ssVertical
   else if not cfgEdit.VerBarDesV and cfgEdit.VerBarDesH then
     ed.ScrollBars:= ssHorizontal
   else
     ed.ScrollBars := ssNone;
   ////////Configura el resaltado de la palabra actual //////////
   marc := ed.MarkupByClass[TSynEditMarkupHighlightAllCaret];
   if marc<>nil then begin  //hay marcador
      marc.Enabled := cfgEdit.ResPalCur;  //configura
      marc.MarkupInfo.Background := cfgEdit.cResPal;
   end;
   ///////fija color de delimitadores () {} [] ///////////
   ed.BracketMatchColor.Foreground := clRed;
end;
procedure TfraTabSession.Init;
{Rutina que debe ser llamada para terminar la inicialización, después de la creación
del Frame. Debe llamarse solo una vez.
Se mantiene separada del constructor, porque depende de que el frame, tenga
un nombre ya asignado ("fileName" o "Caption" actualizado).}
var
  f: TfrmSesProperty;
  tmp: String;
begin
  {Crea archivo XML de configuración aquí, porque recién aquí se tiene el nombre del
  "Caption" (usado en la lengueta) y a partir de allí podemos generar un nombre del
  archivo para este frame.}
  prop := TMiConfigXML.Create(self.Caption);   //"prop.GetFileName() será el nombre inicial del archivo.
  f := frmSesProperty;
  //Parámetros de conexión
  prop.Asoc_Enum('tipo'   , @Tipo , SizeOf(TTipCon), [f.optTelnet,f.optSSH,f.optSerial,f.optOtro], 1);
  prop.Asoc_Str ('ip'     , @IP   , f.cmbIP     , '127.0.0.1');
  prop.Asoc_Str ('port'   , @Port , f.txtPort   , '22');
  prop.Asoc_Str ('other'  , @Other, f.txtOtro   , '');
  //prop.Asoc_StrList     (@ConRecientes, 'Recient');
  prop.Asoc_Enum('LineDelimSnd', @LineDelimSend, SizeOf(LineDelimSend), f.RadioGroup1, 2);
  prop.Asoc_Enum('LineDelimRcv', @LineDelimRecv, SizeOf(LineDelimRecv), f.RadioGroup2, 2);
  //Parámetros de detección de prompt.
  prop.Asoc_Bol ('DetecPrompt' , @detecPrompt,f.chkDetecPrompt, false);
  prop.Asoc_Str ('cadIni'      , @prIni     , f.txtCadIni, '');
  prop.Asoc_Str ('cadFin'      , @prFin     , f.txtCadFin, '');
  prop.Asoc_Enum('TipDetec'    , @TipDetec  , SizeOf(TipDetec),
         [f.RadioButton1, f.RadioButton2   , f.RadioButton3, f.RadioButton4], 0);
  //Parámetros de la pantalla del terminal.
  prop.Asoc_Int ('maxLinTer'   , @maxLinTer , f.txtMaxLinT, 5000, 200, MAX_LIN_TER);  {menos de 200 líneas puede causar problemas con la rutina de limitación de tamaño}
  prop.Asoc_Int ('maxColTer'   , @maxColTer , f.txtMaxColT, 1000, 80,10000);
  prop.Asoc_Bol ('interDirec'  , @interDirec, f.chkInterDirec,true);
  prop.Asoc_Bol ('curSigPrm'   , @curSigPrm , f.chkCurSigPrmpt,true);
  //Parámetros del editor del terminal
  prop.Asoc_TCol('t_cTxtNor'   , @cfgEdterm.cTxtNor   , f.cbutTexto    , clGray);
  prop.Asoc_TCol('t_cFonEdi'   , @cfgEdterm.cFonEdi   , f.cbutBackCol  , clBlack);
  prop.Asoc_TCol('t_cLinAct'   , @cfgEdterm.cLinAct   , f.cbutLinAct   , clYellow);
  prop.Asoc_TCol('t_cResPal'   , @cfgEdterm.cResPal   , f.cbutResPal   , clSkyBlue);
  prop.Asoc_Bol ('t_VerBarDesV', @cfgEdterm.VerBarDesV, f.chkVerBarDesV, true);
  prop.Asoc_Bol ('t_VerBarDesH', @cfgEdterm.VerBarDesH, f.chkVerBarDesH, false);
  prop.Asoc_Bol ('t_ResPalCur' , @cfgEdterm.ResPalCur , f.chkHLCurWord, true);
  prop.Asoc_Bol ('t_MarLinAct' , @cfgEdterm.MarLinAct , f.chkMarLinAct , false);
  prop.Asoc_Bol ('t_VerPanVer' , @cfgEdterm.VerPanVer , f.chkVerPanVer , true);
  prop.Asoc_Bol ('t_VerNumLin' , @cfgEdterm.VerNumLin , f.chkVerNumLin , false);
  prop.Asoc_Bol ('t_VerMarPle' , @cfgEdterm.VerMarPle , f.chkVerMarPle , true);
  prop.Asoc_TCol('t_cFonPan'   , @cfgEdterm.cFonPan   , f.cbutFonPan   , clWhite);
  prop.Asoc_TCol('t_cTxtPan'   , @cfgEdterm.cTxtPan   , f.cbutTxtPan   , clBlack);
  prop.Asoc_Int ('t_TamLet'    , @cfgEdTerm.FontSize  , f.spFontSize   , 9);
  prop.Asoc_Str ('t_TipLet'    , @cfgEdTerm.FontName  , f.cmbTipoLetra , 'Courier New');
  //Parámetros de Comando recurrente
  prop.Asoc_Bol ('Activar'     , @Activar   , f.chkSendRecCom , false);
  prop.Asoc_Int ('Tempo'       , @Tempo     , f.speTempo      , 5);
  prop.Asoc_Enum('tipEnvio'    , @tipEnvio  , SizeOf(tipEnvio), [f.optComando, f.optScript], 0);
  prop.Asoc_Str ('Comando'     , @Comando   , f.txtComando    , '');
  prop.Asoc_Str ('Archivo'     , @Archivo   , f.txtArchivo    , '');
  //Parámetros del editor de Comandos
  prop.Asoc_TCol('c_cTxtNor'   , @cfgEdPcom.cTxtNor   , f.cbutTexto1    , clBlack);
  prop.Asoc_TCol('c_cFonEdi'   , @cfgEdPcom.cFonEdi   , f.cbutBackCol1  , clWhite);
  prop.Asoc_TCol('c_cLinAct'   , @cfgEdPcom.cLinAct   , f.cbutLinAct1   , clYellow);
  prop.Asoc_TCol('c_cResPal'   , @cfgEdPcom.cResPal   , f.cbutResPal1   , clSkyBlue);
  prop.Asoc_Bol ('c_VerBarDesV', @cfgEdPcom.VerBarDesV, f.chkVerBarDesV1, true);
  prop.Asoc_Bol ('c_VerBarDesH', @cfgEdPcom.VerBarDesH, f.chkVerBarDesH1, false);
  prop.Asoc_Bol ('c_ResPalCur' , @cfgEdPcom.ResPalCur , f.chkHLCurWord1 , true);
  prop.Asoc_Bol ('c_MarLinAct' , @cfgEdPcom.MarLinAct , f.chkMarLinAct1 , true);
  prop.Asoc_Bol ('c_VerPanVer' , @cfgEdPcom.VerPanVer , f.chkVerPanVer1 , true);
  prop.Asoc_Bol ('c_VerNumLin' , @cfgEdPcom.VerNumLin , f.chkVerNumLin1 , false);
  prop.Asoc_Bol ('c_VerMarPle' , @cfgEdPcom.VerMarPle , f.chkVerMarPle1 , true);
  prop.Asoc_TCol('c_cFonPan'   , @cfgEdPcom.cFonPan   , f.cbutFonPan1   , clWhite);
  prop.Asoc_TCol('c_cTxtPan'   , @cfgEdPcom.cTxtPan   , f.cbutTxtPan1   , clBlack);
  prop.Asoc_Int ('c_TamLet'    , @cfgEdPcom.FontSize  , f.spFontSize1   , 9);
  prop.Asoc_Str ('c_TipLet'    , @cfgEdPcom.FontName  , f.cmbTipoLetra1 , 'Courier New');
  //Parámetros del panel de comandos.
  prop.Asoc_Bol ('CompletCode'  , @CompletCode   , f.chkCompletCode  , true);
  prop.Asoc_Bol ('CodFolding'   , @CodFolding    , f.chkCodFolding   , true);
  prop.Asoc_Bol ('SendLnEnter'  , @SendLnEnter   , f.chkSendLnEnter  , false);
  prop.Asoc_Bol ('SendLnCtrEnter',@SendLnCtrEnter, f.chkSendLnCtrEnter, true);
  prop.Asoc_Bol ('UsarPrep'     , @UsarPrep      , f.chkUsarPrep     , false);

  //Parámetros adicionales
  prop.Asoc_Str ('langFile'    , @langFile, '');
  prop.Asoc_StrList('textPCom' , @textPCom);
  //prop.Asoc_StrList('Term'   , @textTerm);
  prop.Asoc_Int('pComWidth'    ,  @pComWidth, 300);
  prop.Asoc_Bol('showPCom'     ,  @showPCom, f.chkShowPCom, true);
  prop.Asoc_Bol('showTerm'     ,  @showTerm, f.chkShowTerm, true);

  //Rutina para forzar la carga de valores por defecto de las propiedades.
  tmp := fileName;     //Guarda valor.
  fileName := 'killme.tmp';        //Archivo temporal.
  StringToFile('<?xml version="1.0" encoding="utf-8"?><CONFIG></CONFIG>', 'killme.tmp');  //Ceea archivo en blanco.
  if not prop.FileToProperties then begin  //FileToProperties() pondrá valores por defecto, si no encuentra la clave.
    MsgErr(prop.MsjErr);
  end;
  fileName := tmp;     //Restaura.
  DeleteFile('killme.tmp');  //Limpia la casa

  //Asigna evento a botón para probar comando recurrente
  f.OnTest := @TestRecurringCommand;
end;
procedure TfraTabSession.Splitter1Moved(Sender: TObject);
{Se está dimensionando}
begin
  pComWidth := edPCom.Width;
end;
procedure TfraTabSession.ExecSettings;
begin
  //Muestra ventana de configuración de la conexión (y los demás parámetros.)
  if ShowProperties = mrYes then begin
    //Se dio "Aceptar y conectar". Ya tenemos los parámetros. Iniciamos la conexión.
    if not (proc.state = ECO_STOPPED) then begin
      MsgExc('You need to close the current connection.');
      exit;
    end;
    InicConect;
    //Marca como modificado
    //setModified(true);
  end;
end;
procedure TfraTabSession.InicConectTelnet(ip0: string);
begin
  //configura conexión rápida Telnet
  tipo := TCON_TELNET;
  ip := ip0;
  port := '23';
  LineDelimSend := LDS_LF;
  LineDelimRecv := LDR_LF;
  InicConect;
  //Marca como modificado
  setModified(true);
end;
procedure TfraTabSession.InicConectSSH(ip0: string);
begin
  //configura conexión rápida Telnet
  tipo := TCON_SSH;
  ip := ip0;
  port := '22';
  LineDelimSend := LDS_LF;
  LineDelimRecv := LDR_LF;
  InicConect;
  //Marca como modificado
  setModified(true);
end;
destructor TfraTabSession.Destroy;
begin
  EndLog;  //por si se estaba registrando
  proc.Free;
  if prop<>nil then begin
    if FileExists(fileName) then begin
      prop.PropertiesToFile;  //Save to disk
    end;
  end;
  FreeAndNil(prop);
  hlTerm.Destroy;
  ePCom.Destroy;
  inherited Destroy;
end;
//////////////// Acciones ///////////////////
//Acciones de archivo.
procedure TfraTabSession.AcFilStarLogExecute(Sender: TObject);
var
  arc0: TComponentName;
begin
  if logName='' then begin
    SaveDialog2.Filter := dic('Log file|*.log|All files|*.*');
    SaveDialog2.InitialDir:=patApp;  //busca aquí por defecto
    if not SaveDialog2.Execute then begin  //se canceló
      exit;    //se canceló
    end;
    arc0:=SaveDialog2.FileName;
    if FileExists(arc0) then begin
      if MsgYesNoCancel('File %s already exists.' + LineEnding + '¿Overwrite?',
                        [arc0]) in [2,3] then exit;
    end;
  end;
  logName := arc0;
  if not StartLog(logName) then begin
    MsgErr('Error opening log: ' + logName);
  end;
end;
procedure TfraTabSession.AcFilSavSesExecute(Sender: TObject);
begin
  SaveToFile;
end;
procedure TfraTabSession.AcFilSavSesAsExecute(Sender: TObject);
begin
  SaveAsDialog;
end;
procedure TfraTabSession.AcFilStopLogExecute(Sender: TObject);
begin
  EndLog;
end;
procedure TfraTabSession.acFindFindExecute(Sender: TObject);
begin
  FindDialog1.Execute;
end;
procedure TfraTabSession.acFindNextExecute(Sender: TObject);
begin
  FindDialog1Find(self);
end;
procedure TfraTabSession.acFindPrevExecute(Sender: TObject);
begin
  if frDown in FindDialog1.Options then begin
    FindDialog1.Options := FindDialog1.Options - [frDown];  //Quita
    FindDialog1Find(self);
    FindDialog1.Options := FindDialog1.Options + [frDown];  //Restaura
  end else begin
    FindDialog1Find(self);
  end;
end;
procedure TfraTabSession.acFindReplaceExecute(Sender: TObject);
begin
  ReplaceDialog1.Execute;
end;
//Acciones del Panel de comando.
procedure TfraTabSession.AcPCmEnvLinExecute(Sender: TObject);
var
  lin: String;
begin
  if proc = nil then exit;
  if edPCom.SelAvail then begin  //hay selección
    //Envía texto seleccionado
    EnviarTxt(edPCom.SelText);
  end else begin  //no hay selección, envía la línea actual
    lin := edPCom.LineText;  //línea actual
    EnviarTxt(lin);
  end;
end;
procedure TfraTabSession.AcPCmEnvTodExecute(Sender: TObject);
//Envía todo el texto.
begin
  if proc = nil then exit ;
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
    //No hay selección, envía todo
    if MsgYesNoCancel('Send all the content of the editor?')<>1 then begin
      exit;
    end;
    EnviarTxt(edPCom.Text);
  end;
end;

procedure TfraTabSession.acPCmEnvCtrCExecute(Sender: TObject);
begin
  proc.Send(#3);
end;
procedure TfraTabSession.AcTerConecExecute(Sender: TObject);
begin
  InicConect;   //inicia conexión
end;
procedure TfraTabSession.AcTerDesconExecute(Sender: TObject); //desconectar
begin
   if not proc.Close then
     msgerr('Cannot clos the current process.');
end;
procedure TfraTabSession.AcTerCopPalExecute(Sender: TObject);
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
procedure TfraTabSession.AcTerCopNomExecute(Sender: TObject); //copia nombre
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
procedure TfraTabSession.AcTerCopRutExecute(Sender: TObject); //copia ruta
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
procedure TfraTabSession.AcTerCopNomRutExecute(Sender: TObject); //copia ruta y nombre
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
procedure TfraTabSession.AcTerDetPrmExecute(Sender: TObject); //Detecta prompt
begin
  proc.AutoConfigPrompt;  //auto-detección
  DetecPrompt := proc.detecPrompt;
  prIni       := proc.promptIni;
  prFin       := proc.promptFin;
  TipDetec    := proc.promptMatch;
  edTerm.Invalidate;  //Colorea con nuevos parámetros de prompt
end;
procedure TfraTabSession.AcTerEnvEnterExecute(Sender: TObject);  //Enter
begin
  proc.SendLn('');
end;
procedure TfraTabSession.AcTerEnvCRExecute(Sender: TObject);
begin
  proc.Send(#13);
end;
procedure TfraTabSession.AcTerEnvLFExecute(Sender: TObject);
begin
  proc.Send(#10);
end;
procedure TfraTabSession.AcTerEnvCRLFExecute(Sender: TObject);
begin
  proc.Send(#13#10);
end;
procedure TfraTabSession.AcTerLimBufExecute(Sender: TObject);
//limpia la salida
begin
  edterm.ClearAll;
  proc.ClearTerminal;  //generará el evento OnInitLines()
end;
procedure TfraTabSession.AcTerPrmArrExecute(Sender: TObject);
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
procedure TfraTabSession.AcTerPrmAbaExecute(Sender: TObject);
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
procedure TfraTabSession.AcTerVerBHerExecute(Sender: TObject);
begin

end;
procedure TfraTabSession.edPComEnter(Sender: TObject);
begin
  edFocused := edPCom;
end;
procedure TfraTabSession.edTermEnter(Sender: TObject);
begin
  edFocused := edTerm;
end;
procedure TfraTabSession.FindDialog1Find(Sender: TObject);
var
  encon  : integer;
  buscado : string;
  opciones: TSynSearchOptions;
  curEdit: TSynEdit;
begin
  //Busca el último editor que tuvo el enfoque.
  if edFocused = nil then begin
    exit;
  end else begin
    curEdit := edFocused;
  end;
  buscado := FindDialog1.FindText;
  opciones := [];
  if not(frDown in FindDialog1.Options) then opciones += [ssoBackwards];
  if frMatchCase in FindDialog1.Options then opciones += [ssoMatchCase];
  if frWholeWord in FindDialog1.Options then opciones += [ssoWholeWord];
  if frEntireScope in FindDialog1.Options then opciones += [ssoEntireScope];
  encon := curEdit.SearchReplace(buscado,'',opciones);
  if encon = 0 then
     MsgBox('Not found "%s"', [buscado]);
end;

procedure TfraTabSession.ReplaceDialog1Replace(Sender: TObject);
var
  encon, r : integer;
  buscado : string;
  opciones: TSynSearchOptions;
  curEdit: TSynEdit;
begin
  //Busca el último editor que tuvo el enfoque.
  if edFocused = nil then begin
    exit;
  end else begin
    curEdit := edFocused;
  end;
  buscado := ReplaceDialog1.FindText;
  opciones := [ssoFindContinue];
  if not(frDown in ReplaceDialog1.Options) then opciones += [ssoBackwards];
  if frMatchCase in ReplaceDialog1.Options then opciones += [ssoMatchCase];
  if frWholeWord in ReplaceDialog1.Options then opciones += [ssoWholeWord];
  if frEntireScope in ReplaceDialog1.Options then opciones += [ssoEntireScope];
  if frReplaceAll in ReplaceDialog1.Options then begin
    //se ha pedido reemplazar todo
    encon := curEdit.SearchReplace(buscado,ReplaceDialog1.ReplaceText,
                              opciones+[ssoReplaceAll]);  //reemplaza
    MsgBox('%d words replaced', [IntToStr(encon)]);
    exit;
  end;
  //reemplazo con confirmación
  ReplaceDialog1.CloseDialog;
  encon := curEdit.SearchReplace(buscado,'',opciones);  //búsqueda
  while encon <> 0 do begin
      //pregunta
      r := Application.MessageBox(pChar('Replace this?'), '', MB_YESNOCANCEL);
      if r = IDCANCEL then exit;
      if r = IDYES then begin
        curEdit.TextBetweenPoints[curEdit.BlockBegin,curEdit.BlockEnd] := ReplaceDialog1.ReplaceText;
      end;
      //busca siguiente
      encon := curEdit.SearchReplace(buscado,'',opciones);  //búsca siguiente
  end;
  MsgBox('No found "%s"', [buscado]);
end;

//Acciones de herramientas
procedure TfraTabSession.AcHerCfgExecute(Sender: TObject);
begin
  ExecSettings;
end;


end.

