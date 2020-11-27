{Unidad con formulario de configuración para manejar las propiedades de
 una aplicación. Está pensado para usarse con frames de la clase Tframe,
 definida en la unidad "PropertyFrame".
 }
unit FormConfig;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Forms, Graphics, SynEdit, Buttons, ComCtrls, ExtCtrls,
  StdCtrls, EditBtn, MisUtils, FrameCfgSynEdit, Globales, MiConfigXML;

type
  TEvCambiaProp = procedure of object;  //evento para indicar que hay cambio

  { TConfig }

  TConfig = class(TForm)
    bitAceptar: TBitBtn;
    bitAplicar: TBitBtn;
    bitCancel: TBitBtn;
    chkListDet: TCheckBox;
    chkMarLin: TCheckBox;
    chkMosOcul: TCheckBox;
    chkMosRut: TCheckBox;
    chkOpenLast: TCheckBox;
    chkRefDesp: TCheckBox;
    DirectoryEdit1: TDirectoryEdit;
    DirectoryEdit2: TDirectoryEdit;
    DirectoryEdit3: TDirectoryEdit;
    edTpoMax: TEdit;
    edTpoMax1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    lblRutLeng: TLabel;
    lblRutMac: TLabel;
    lblRutScript: TLabel;
    PageControl1: TPageControl;
    Panel1: TPanel;
    TabGeneral: TTabSheet;
    TabFilePath: TTabSheet;
    TabMacSett: TTabSheet;
    TabMacEdit: TTabSheet;
    TabRemEdit: TTabSheet;
    TabRemExpl: TTabSheet;
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
    //msjError: string;
    edMacr  : TSynEdit;    //Referencia al editor panel de comando
    edRemo  : TSynEdit;    //Referencia al editor remoto
    //Frames de configuración
    fcEdMacr  : TfraCfgSynEdit;   //Editor de macros
    fcEdRemo  : TfraCfgSynEdit;   //Editor remoto
  public  //Propiedades generales
    VerPanCom   : boolean;  //Panel de comandos
    VerBHerPcom : boolean;  //Barra de herramientas
    VerBHerTerm : boolean;  //Barra de herramientas
    VerBarEst   : boolean;  //Barra de estado
    TipAlineam  : integer;  //Tipo de alineamiento de pantalla
    RecentFiles : TStringList;  //Lista de archivos recientes
  public  //Propiedades de rutas de archivos
    UltScript: string;      //Último script editado
    AbrirUltScr: boolean;
    Scripts  : string;
    Macros   : string;
    Lenguajes: string;
  public  //Configruaciones de macros
    TpoMax : integer;
    marLin : boolean;
  public  //Configuraciones del explorador remoto
    ListDet: boolean;
    MosRut : boolean;  //muestra la ruta actual
    MosOcul: boolean;
    RefDesp: boolean;
    TpoMax2: integer;
  public
    procedure Iniciar();
    procedure LeerArchivoIni(iniFile: string='');
    procedure escribirArchivoIni(iniFile: string='');
    procedure Configurar(Id: string='');
  end;

var
  Config: TConfig;

implementation
{$R *.lfm}

  { TConfig }

procedure TConfig.FormCreate(Sender: TObject);
begin
  RecentFiles := TStringList.Create;
  //Crea frames de configuración de SynEdit
  fcEdMacr:= TfraCfgSynEdit.Create(Self);
  fcEdMacr.Name := 'emac'; //Para que no de error de nombre
  fcEdMacr.parent := TabMacEdit;

  fcEdRemo:= TfraCfgSynEdit.Create(Self);
  fcEdRemo.Name := 'erem'; //Para que no de error de nombre
  fcEdRemo.parent := TabRemEdit;

  //Prepara página y Selecciona primera opción
  PageControl1.ShowTabs := false;
  TreeView1.Items[0].Selected:=true;
  TreeView1Click(self);

  cfgFile.VerifyFile;
end;
procedure TConfig.FormDestroy(Sender: TObject);
begin
  RecentFiles.Destroy
end;
procedure TConfig.FormShow(Sender: TObject);
begin
  MostEnVentana;   //carga las propiedades en el frame
end;
procedure TConfig.Iniciar();
//Inicia el formulario de configuración. Debe llamarse antes de usar el formulario y
//después de haber cargado todos los frames.
begin
  //Configuraciones generales
  cfgFile.Asoc_Bol('VerPanCom'  , @VerPanCom  , true);
  cfgFile.Asoc_Bol('VerBHerPcom', @VerBHerPcom, true);
  cfgFile.Asoc_Bol('VerBHerTerm', @VerBHerTerm, true);
  cfgFile.Asoc_Bol('VerBarEst'  , @VerBarEst  , true);
  cfgFile.Asoc_Int('TipAlineam' , @TipAlineam , 0);
  //Propiedades de rutas de archivos
  cfgFile.Asoc_Str('UltScript'  , @UltScript ,'');
  cfgFile.Asoc_Bol('AbrirUltScr', @AbrirUltScr, chkOpenLast   , true);
  cfgFile.Asoc_Str('Scripts'    , @Scripts    , DirectoryEdit1, patScripts);
  cfgFile.Asoc_Str('Macros'     , @Macros     , DirectoryEdit2, patMacros);
  cfgFile.Asoc_Str('Lenguajes'  , @Lenguajes  , DirectoryEdit3, patSyntax);
  //Configuraciones de macros
  cfgFile.Asoc_Int('TpoMax'     , @TpoMax, edTpoMax , 10, 1, 180);
  cfgFile.Asoc_Bol('MarLin'     , @marLin, chkMarLin, false);
  //Configuración de editor de macros
  fcEdMacr.Iniciar('edMacros', cfgFile, $E8FFE8);
  //Configuración de editor remoto
  fcEdRemo.Iniciar('edRemoto', cfgFile);
  //Configuraciones del explorador remoto
  cfgFile.Asoc_Int('TpoMax2'    , @TpoMax2, edTpoMax1  , 10, 1, 180);
  cfgFile.Asoc_Bol('MosRut'     , @MosRut , chkMosRut , true);
  cfgFile.Asoc_Bol('ListDet'    , @ListDet, chkListDet, true);
  cfgFile.Asoc_Bol('MosOcul'    , @MosOcul, chkMosOcul, false);
  cfgFile.Asoc_Bol('RefDesp'    , @RefDesp, chkRefDesp, true);

  //lee parámetros del archivo de configuración.
  LeerArchivoIni;
end;
procedure TConfig.TreeView1Click(Sender: TObject);
begin
  if TreeView1.Selected = nil then exit;
  //hay ítem seleccionado
  case IdFromTTreeNode(TreeView1.Selected) of
  '1',
//  '1.1'  : ;
  '1.2'  : TabFilePath.Show;
  '2',
  '2.1'  : TabMacSett.Show;
  '2.2'  : TabMacEdit.Show;
  '3',
  '3.1'  : TabRemEdit.Show;
  '4'    : TabRemExpl.Show;
  end;
end;

procedure TConfig.bitAceptarClick(Sender: TObject);
begin
  bitAplicarClick(Self);
  if cfgFile.MsjErr<>'' then exit;  //hubo error
  self.Close;   //porque es modal
end;
procedure TConfig.bitAplicarClick(Sender: TObject);
begin
  LeerDeVentana;       //Escribe propiedades de los frames
  //valida las rutas leidas
  if not DirectoryExists(Scripts) then begin
    MsgExc('Folder not found: %s',[Scripts]);
    Scripts := patScripts;
  end;
  if not DirectoryExists(Macros) then begin
    MsgExc('Folder not found: %s', [Macros]);
    Macros := patMacros;
  end;
  if not DirectoryExists(Lenguajes) then begin
    MsgExc('Folder not found: %s', [Lenguajes]);
    Lenguajes := patSyntax;
  end;
  fcEdMacr.ConfigEditor(edMacr);
  fcEdRemo.ConfigEditor(edRemo);

  escribirArchivoIni;   //Guarda propiedades en disco
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
  if not cfgFile.WindowToProperties then begin
    MsgErr(cfgFile.MsjErr);
  end;
end;
procedure TConfig.MostEnVentana;
//Muestra las propiedades en la ventana de configuración.
begin
  if not cfgFile.PropertiesToWindow then begin
    MsgErr(cfgFile.MsjErr);
  end;
end;
procedure TConfig.LeerArchivoIni(iniFile: string = '');
begin
  if not cfgFile.FileToProperties then begin
    MsgErr(cfgFile.MsjErr);
  end;
end;
procedure TConfig.escribirArchivoIni(iniFile: string='');
//Escribe el archivo de configuración
begin
  if not cfgFile.PropertiesToFile then begin
    MsgErr(cfgFile.MsjErr);
  end;
end;

end.

