{Unidad con formulario de configuración para manejar las propiedades de
 una aplicación. Está pensado para usarse con frames de la clase Tframe,
 definida en la unidad "PropertyFrame".
 }
unit FormConfig;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Forms, Graphics, SynEdit, Buttons, ComCtrls,
  UnTerminal, MisUtils, SynFacilCompletion,
  FrameCfgConex, FrameCfgGener, frameCfgDetPrompt, FrameCfgEdit, frameCfgPantTerm,
  FrameCfgExpRem, FrameCfgMacros, FrameCfgComandRec, FrameCfgRutasCnx, FrameCfgPanCom
  ,ConfigFrame;

type
  TEvCambiaProp = procedure of object;  //evento para indicar que hay cambio

  { TConfig }

  TConfig = class(TForm)
    bitAceptar: TBitBtn;
    bitAplicar: TBitBtn;
    bitCancel: TBitBtn;
    TreeView1: TTreeView;
    procedure bitAceptarClick(Sender: TObject);
    procedure bitAplicarClick(Sender: TObject);
    procedure bitCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
  private
    procedure LeerDeVentana;
    procedure MostEnVentana;
    { private declarations }
  public
    fraError: TCfgFrame;
    msjError: string;
    arIni   : String;      //Archivo de configuración
    edTerm  : TSynEdit;    //referencia al editor SynEdit
    edPCom  : TSynEdit;    //referencia al editor panel de comando
    edMacr  : TSynEdit;    //referencia al editor panel de comando
    edRemo  : TSynEdit;    //referencia al editor remoto
    prTel   : TConsoleProc;
    //frames de configuración
    fcGener   : TfraCfgGener;   //configuraciones generales (no visible)
    fcConex   : TFraConexion;   //conexión
    fcComRec  : TfraComandRec;  //comando recurrente
    fcRutArc  : TfraCfgRutArc;  //Rutas-archivos de conexión
    fcEdTerm  : TfcEdit;   //terminal
    fcEdPcom  : TfcEdit;   //Panel de comandos
    fcEdMacr  : TfcEdit;   //editor de macros
    fcEdRemo  : TfcEdit;   //editor remoto
    fcPantTerm: TfraPantTerm;
    fcDetPrompt: TfraDetPrompt;
    fcExpRem   : TfcExpRem;
    fcMacros   : TfcMacros;
    fcPanCom   : TfraPanCom;
    //propiedades globales
    VerPanCom   : boolean;  //panel de comandos
    VerBHerPcom : boolean;   //barra de herramientas
    VerBHerTerm : boolean;   //barra de herramientas
    VerBarEst   : boolean;   //barra de estado
    TipAlineam  : integer;   //tipo de alineamiento de pantalla
    procedure Iniciar(hl0: TSynFacilComplet);
    procedure LeerArchivoIni(iniFile: string='');
    procedure escribirArchivoIni(iniFile: string='');
    procedure Configurar(Id: string='');
    function ContienePrompt(const linAct, prIni, prFin: string): integer;
    function ContienePrompt(const cad: string): boolean;
    function EsPrompt(const cad: string): boolean;
    procedure SetLanguage(lang: string);
  end;

var
  Config: TConfig;

implementation
{$R *.lfm}

  { TConfig }

procedure TConfig.FormCreate(Sender: TObject);
begin
  //Crea frames de configuración
  fcConex:= TFraConexion.Create(Self);
  fcConex.parent := self;
  fcDetPrompt:= TfraDetPrompt.Create(Self);
  fcDetPrompt.parent := self;
  fcRutArc := TfraCfgRutArc.Create(Self);
  fcRutArc.parent := self;

  fcPantTerm:= TfraPantTerm.Create(Self);
  fcPantTerm.parent := self;
  fcEdTerm:= TfcEdit.Create(Self);
  fcEdTerm.Name := 'ter';  //para que no de error de nombre
  fcEdTerm.parent := self;
  fcComRec := TfraComandRec.Create(Self);
  fcComRec.parent := self;

  fcEdPcom:= TfcEdit.Create(Self);
  fcEdPcom.Name := 'pcom'; //para que no de error de nombre
  fcEdPcom.parent := self;
  fcPanCom:= TfraPanCom.Create(Self);
  fcPanCom.parent := self;

  fcMacros    := TfcMacros.Create(self);
  fcMacros.Parent := self;
  fcEdMacr:= TfcEdit.Create(Self);
  fcEdMacr.Name := 'emac'; //para que no de error de nombre
  fcEdMacr.parent := self;

  fcEdRemo:= TfcEdit.Create(Self);
  fcEdRemo.Name := 'erem'; //para que no de error de nombre
  fcEdRemo.parent := self;

  fcExpRem    := TfcExpRem.Create(self);
  fcExpRem.parent := self;

  fcGener := TfraCfgGener.Create(Self);
  fcGener.parent := self;

  //Obtiene nombre de archivo INI
  arIni := GetIniName;
  //selecciona primera opción
  TreeView1.Items[0].Selected:=true;
  TreeView1Click(self);
end;
procedure TConfig.FormDestroy(Sender: TObject);
begin
  Free_AllConfigFrames(self);  //Libera los frames de configuración
end;
procedure TConfig.FormShow(Sender: TObject);
begin
  MostEnVentana;   //carga las propiedades en el frame
end;
procedure TConfig.Iniciar(hl0: TSynFacilComplet);
//Inicia el formulario de configuración. Debe llamarse antes de usar el formulario y
//después de haber cargado todos los frames.
begin
  //inicia Frames
  fcConex.Iniciar('conexion', prTel);
  fcComRec.Iniciar('comand_rec');
  fcRutArc.Iniciar('rutas_conex');
  fcEdTerm.Iniciar('terminal', edTerm, clBlack);
  fcEdPcom.Iniciar('panelCom', edPCom);
  fcPanCom.Iniciar('fcPanCom', hl0);
  fcMacros.Iniciar('cfgMacros');
  fcEdMacr.Iniciar('edMacros', edMacr, $E8FFE8);
  fcEdRemo.Iniciar('edRemoto', edRemo);
  fcPantTerm.Iniciar('panTerm',prTel);
  fcDetPrompt.Iniciar('detPrompt', edTerm, prTel);
  fcExpRem.Iniciar('expRemoto');
  //crea Frame y sus variables desde afuera, para facilitar acceso
  fcGener.Iniciar('general');
  fcGener.Asoc_Bol(@VerPanCom  , 'VerPanCom',true);
  fcGener.Asoc_Bol(@VerBHerPcom, 'VerBHerPcom',true);
  fcGener.Asoc_Bol(@VerBHerTerm, 'VerBHerTerm',true);
  fcGener.Asoc_Bol(@VerBarEst  , 'VerBarEst',true);
  fcGener.Asoc_Int(@TipAlineam , 'TipAlineam', 0);

  //lee parámetros del archivo de configuración.
  LeerArchivoIni;
end;
procedure TConfig.TreeView1Click(Sender: TObject);
begin
  if TreeView1.Selected = nil then exit;
  //hay ítem seleccionado
  Hide_AllConfigFrames(self);  //oculta todos
  case IdFromTTreeNode(TreeView1.Selected) of
  '1',
  '1.1'  : fcConex.ShowPos(145,0) ;
  '1.2'  : fcDetPrompt.ShowPos(145,0);
  '1.3'  : fcRutArc.ShowPos(145,0);
  '2',
  '2.1'  : fcPantTerm.ShowPos(145,0);
  '2.2'  : fcEdTerm.ShowPos(145,0);
  '2.3'  : fcComRec.ShowPos(145,0);
  '3',
  '3.1'  : fcEdPcom.ShowPos(145,0);
  '3.2'  : fcPanCom.ShowPos(145,0);
  '4',
  '4.1'  : fcMacros.ShowPos(145,0);
  '4.2'  : fcEdMacr.ShowPos(145,0);
  '5',
  '5.1'  : fcEdRemo.ShowPos(145,0);
  '6'    : fcExpRem.ShowPos(145,0);
  end;
end;

procedure TConfig.bitAceptarClick(Sender: TObject);
begin
  bitAplicarClick(Self);
  if fraError<>nil then exit;  //hubo error
  fcConex.GrabarIP;
  self.Close;   //porque es modal
end;
procedure TConfig.bitAplicarClick(Sender: TObject);
begin
  LeerDeVentana;       //Escribe propiedades de los frames
  if fraError<>nil then begin

    msgerr(fraError.MsjErr);
    exit;
  end;
  escribirArchivoIni;   //guarda propiedades en disco
  if edTerm<>nil then edTerm.Invalidate;     //para que refresque los cambios
  if edPCom<>nil then edPCom.Invalidate;     //para que refresque los cambios
end;
procedure TConfig.bitCancelClick(Sender: TObject);
begin
  self.Hide;
end;
procedure TConfig.Configurar(Id: string='');
//Muestra el formulario, de modo que permita configurar la sesión actual
var
  it: TTreeNode;
begin
  if Id<> '' then begin  /////se pide mostrar un Id en especial
    //oculta los demás
    it := TTreeNodeFromId(Id,TreeView1);
    if it <> nil then it.Selected:=true;
    TreeView1Click(self);
  end else begin ////////muestra todos
    for it in TreeView1.Items do begin
      it.Visible:=true;
    end;
  end;
  Showmodal;
end;

function TConfig.ContienePrompt(const linAct, prIni, prFin: string): integer;
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
function TConfig.ContienePrompt(const cad: string): boolean;
//Forma siple de  ContienePrompt
begin
  Result := ContienePrompt(cad, fcDetPrompt.prIni, fcDetPrompt.prFin)>0;
end;
function TConfig.EsPrompt(const cad: string): boolean;
//Indica si la línea dada, es el prompt, de acuerdo a los parámetros dados. Esta función
//se pone aquí, porque aquí se tiene fácil acceso a las configuraciones del prompt.
var
  n: Integer;
begin
  if fcDetPrompt.DetecPrompt then begin  //si hay detección activa
    n := ContienePrompt(cad, fcDetPrompt.prIni, fcDetPrompt.prFin);
    Result := (n>0) and  (n = length(cad));
  end else begin
    Result := false;
  end;
end;

procedure TConfig.LeerDeVentana;
//Lee las propiedades de la ventana de configuración.
begin
  fraError := WindowToProp_AllFrames(self);
end;
procedure TConfig.MostEnVentana;
//Muestra las propiedades en la ventana de configuración.
begin
  fraError := PropToWindow_AllFrames(self);
end;
procedure TConfig.LeerArchivoIni(iniFile: string = '');
begin
  if iniFile = '' then
    msjError := ReadFileToProp_AllFrames(self, arINI)
  else
    msjError := ReadFileToProp_AllFrames(self, iniFile);
end;

procedure TConfig.escribirArchivoIni(iniFile: string='');
//Escribe el archivo de configuración
begin
  if iniFile ='' then
    msjError := SavePropToFile_AllFrames(self, arINI)
  else
    msjError := SavePropToFile_AllFrames(self, iniFile);
end;

procedure TConfig.SetLanguage(lang: string);
//Rutina de traducción
begin
  fcGener.SetLanguage(lang);

  fcConex.SetLanguage(lang);
  fcDetPrompt.SetLanguage(lang);
  fcRutArc.SetLanguage(lang);

  fcPantTerm.SetLanguage(lang);
  fcEdTerm.SetLanguage(lang);
  fcComRec.SetLanguage(lang);

  fcEdPcom.SetLanguage(lang);
  fcPanCom.SetLanguage(lang);

  fcMacros.SetLanguage(lang);
  fcEdMacr.SetLanguage(lang);

  fcEdRemo.SetLanguage(lang);

  fcExpRem.SetLanguage(lang);

  case lowerCase(lang) of
  'es': begin
      TTreeNodeFromId('1',TreeView1).Text:='Conexión';
      TTreeNodeFromId('1.1',TreeView1).Text:='General';
      TTreeNodeFromId('1.2',TreeView1).Text:='Detec.de Prompt';
      TTreeNodeFromId('1.3',TreeView1).Text:='Rutas/Archivos';
      TTreeNodeFromId('2',TreeView1).Text:='Terminal';
      TTreeNodeFromId('2.1',TreeView1).Text:='Pantalla';
      TTreeNodeFromId('2.2',TreeView1).Text:='Editor';
      TTreeNodeFromId('2.3',TreeView1).Text:='Comando Recurrente';
      TTreeNodeFromId('3',TreeView1).Text:='Panel de Comandos';
      TTreeNodeFromId('3.1',TreeView1).Text:='Editor';
      TTreeNodeFromId('3.2',TreeView1).Text:='Otros';
      TTreeNodeFromId('4',TreeView1).Text:='Macros';
      TTreeNodeFromId('4.1',TreeView1).Text:='Configuración';
      TTreeNodeFromId('4.2',TreeView1).Text:='Editor';
      TTreeNodeFromId('5',TreeView1).Text:='Editor Remoto';
      TTreeNodeFromId('5.1',TreeView1).Text:='Editor';
      TTreeNodeFromId('6',TreeView1).Text:='Explorador Remoto';
    end;
  'en': begin
      TTreeNodeFromId('1',TreeView1).Text:='Connection';
      TTreeNodeFromId('1.1',TreeView1).Text:='General';
      TTreeNodeFromId('1.2',TreeView1).Text:='Prompt detection';
      TTreeNodeFromId('1.3',TreeView1).Text:='Paths/Files';
      TTreeNodeFromId('2',TreeView1).Text:='Terminal';
      TTreeNodeFromId('2.1',TreeView1).Text:='Screen';
      TTreeNodeFromId('2.2',TreeView1).Text:='Editor';
      TTreeNodeFromId('2.3',TreeView1).Text:='Recurring command';
      TTreeNodeFromId('3',TreeView1).Text:='Command Panel';
      TTreeNodeFromId('3.1',TreeView1).Text:='Editor';
      TTreeNodeFromId('3.2',TreeView1).Text:='Others';
      TTreeNodeFromId('4',TreeView1).Text:='Macros';
      TTreeNodeFromId('4.1',TreeView1).Text:='Setup';
      TTreeNodeFromId('4.2',TreeView1).Text:='Editor';
      TTreeNodeFromId('5',TreeView1).Text:='Remote Editor';
      TTreeNodeFromId('5.1',TreeView1).Text:='Editor';
      TTreeNodeFromId('6',TreeView1).Text:='Remote Explorer';
    end;
  end;
end;

end.

