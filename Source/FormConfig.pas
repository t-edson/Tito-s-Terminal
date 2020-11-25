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
  FrameCfgGener, frameCfgDetPrompt, FrameCfgEdit, frameCfgPantTerm,
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
    //edTerm  : TSynEdit;    //referencia al editor SynEdit
    edPCom  : TSynEdit;    //referencia al editor panel de comando
    edMacr  : TSynEdit;    //referencia al editor panel de comando
    edRemo  : TSynEdit;    //referencia al editor remoto
    //frames de configuración
    fcGener   : TfraCfgGener;   //configuraciones generales (no visible)
    //fcComRec  : TfraComandRec;  //comando recurrente
    fcRutArc  : TfraCfgRutArc;  //Rutas-archivos de conexión
    //fcEdTerm  : TfcEdit;   //terminal
    //fcEdPcom  : TfcEdit;   //Panel de comandos
    fcEdMacr  : TfcEdit;   //editor de macros
    fcEdRemo  : TfcEdit;   //editor remoto
    //fcPantTerm: TfraPantTerm;
    //fcDetPrompt: TfraDetPrompt;
    fcExpRem   : TfcExpRem;
    fcMacros   : TfcMacros;
    //fcPanCom   : TfraPanCom;
    //propiedades globales
    VerPanCom   : boolean;  //panel de comandos
    VerBHerPcom : boolean;   //barra de herramientas
    VerBHerTerm : boolean;   //barra de herramientas
    VerBarEst   : boolean;   //barra de estado
    TipAlineam  : integer;   //tipo de alineamiento de pantalla
    procedure Iniciar();
    procedure LeerArchivoIni(iniFile: string='');
    procedure escribirArchivoIni(iniFile: string='');
    procedure Configurar(Id: string='');
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
  fcRutArc := TfraCfgRutArc.Create(Self);
  fcRutArc.parent := self;

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
procedure TConfig.Iniciar();
//Inicia el formulario de configuración. Debe llamarse antes de usar el formulario y
//después de haber cargado todos los frames.
begin
  //inicia Frames
  fcRutArc.Iniciar('rutas_conex');

  fcMacros.Iniciar('cfgMacros');
  fcEdMacr.Iniciar('edMacros', edMacr, $E8FFE8);
  fcEdRemo.Iniciar('edRemoto', edRemo);
  //fcPantTerm.Iniciar('panTerm',prTel);
  //fcDetPrompt.Iniciar('detPrompt', edTerm, prTel);
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
//  '1.1'  : ;
  '1.2'  : fcRutArc.ShowPos(155,0);
  '2',
  '2.1'  : fcMacros.ShowPos(155,0);
  '2.2'  : fcEdMacr.ShowPos(155,0);
  '3',
  '3.1'  : fcEdRemo.ShowPos(155,0);
  '4'    : fcExpRem.ShowPos(155,0);
  end;
end;

procedure TConfig.bitAceptarClick(Sender: TObject);
begin
  bitAplicarClick(Self);
  if fraError<>nil then exit;  //hubo error
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
//  if edTerm<>nil then edTerm.Invalidate;     //para que refresque los cambios
//  if edPCom<>nil then edPCom.Invalidate;     //para que refresque los cambios
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
  fcRutArc.SetLanguage(lang);
  fcMacros.SetLanguage(lang);
  fcExpRem.SetLanguage(lang);
end;

end.

