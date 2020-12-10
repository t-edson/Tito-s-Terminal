{Unidad con formulario de configuración para manejar las propiedades de
 una aplicación. Está pensado para usarse con frames de la clase Tframe,
 definida en la unidad "PropertyFrame".
 }
unit FormConfig;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Forms, Graphics, SynEdit, Buttons, ComCtrls, ExtCtrls,
  StdCtrls, EditBtn, Controls, MisUtils, FrameCfgSynEdit, Globales, MiConfigXML;

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
    TabRemEdEdit: TTabSheet;
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
    function GetTabFromId(id: string): TTabSheet;
    function ActivateControl(ctlRef: TComponent): boolean;
    procedure MostEnVentana;
    { private declarations }
  public
    //msjError: string;
    edMacr  : TSynEdit;    //Referencia al editor panel de comando
    edRemo  : TSynEdit;    //Referencia al editor remoto
    //Frames de configuración
    fcEdMacr  : TfraCfgSynEdit;   //Editor de macros
    fcEdRemo  : TfraCfgSynEdit;   //Editor remoto
    //Evento
    OnPropertiesChanged: procedure of object;  //Evento de cambio de propiedades
  public  //Propiedades generales
    VerPanCom   : boolean;  //Panel de comandos
    VerBHerPcom : boolean;  //Barra de herramientas
    VerBHerTerm : boolean;  //Barra de herramientas
    VerBarEst   : boolean;  //Barra de estado
    TipAlineam  : integer;  //Tipo de alineamiento de pantalla
    RecentFiles : TStringList;  //Lista de archivos recientes
    AbrirUltScr : boolean;
  public  //Propiedades de rutas de archivos
    UltScript  : string;    //Último script editado
    foldTemp      : string;  { TODO : ¿Realmente conviene personalizar estas rutas? ¿Por qué no las dejamos fijas en las rutas que se definen en la unidad "Globales"? }
    foldMacros    : string;
    foldLenguajes : string;
  public  //Configuraciones de Macros
    TpoMax : integer;
    marLin : boolean;
  public  //Configuraciones del explorador remoto
    TpoMax2: integer;  //Tiempo máximo de espera
    MosRut : boolean;  //muestra la ruta actual
    ListDet: boolean;
    MosOcul: boolean;
    RefDesp: boolean;
  public
    procedure Iniciar();
    procedure ReadFromFile(iniFile: string='');
    procedure SaveToFile(iniFile: string='');
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
  fcEdRemo.parent := TabRemEdEdit;

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
  cfgFile.Asoc_StrList('Recents_ses', @RecentFiles);
  //Propiedades de rutas de archivos
  cfgFile.Asoc_Str('UltScript'  , @UltScript ,'');
  cfgFile.Asoc_Bol('AbrirUltScr', @AbrirUltScr, chkOpenLast   , true);
  cfgFile.Asoc_Str('foldTemp'    , @foldTemp    , DirectoryEdit1, patTemp);
  cfgFile.Asoc_Str('Macros'     , @foldMacros     , DirectoryEdit2, patMacros);
  cfgFile.Asoc_Str('Lenguajes'  , @foldLenguajes  , DirectoryEdit3, patSyntax);
  //Configuraciones de foldMacros
  cfgFile.Asoc_Int('TpoMax'     , @TpoMax, edTpoMax , 10, 1, 180);
  cfgFile.Asoc_Bol('MarLin'     , @marLin, chkMarLin, false);
  //Configuración de editor de foldMacros
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
  ReadFromFile;
end;
function TConfig.GetTabFromId(id: string): TTabSheet;
{Retorna una página del PageControl, de acuerdo al ID  indicado.}
begin
  case id of
  '1',
  '1.1'  : exit(TabGeneral);
  '1.2'  : exit(TabFilePath);
  '2',
  '2.1'  : exit(TabMacSett);
  '2.2'  : exit(TabMacEdit);
  '3',
  '3.1'  : exit(TabRemEdEdit);
  '4'    : exit(TabRemExpl);
  else
    exit(nil);
  end;
end;
procedure TConfig.TreeView1Click(Sender: TObject);
var
  id: String;
begin
  if TreeView1.Selected = nil then exit;
  //hay ítem seleccionado
  id := IdFromTTreeNode(TreeView1.Selected);
  if GetTabFromId(id) <> nil then GetTabFromId(id).Show;
end;
function TConfig.ActivateControl(ctlRef: TComponent): boolean;
{Intenta seleccionar un control de la ventana de la configuración, a partir de una
referencia "TComponente". Si logra la identifiación, devuelve en:
  "ctl" -> El control como un TWinControl.
  "tab" -> El contenedor como un TTabSheet.
}
var
  pag: TComponent;
  tab: TTabSheet;
  it: TTreeNode;
  id: String;
  ctl: TWinControl;
begin
  if ctlRef=nil then exit(false);
  //Busca al contenedor
  pag := ctlRef.GetParentComponent;
  if pag.ClassName = 'TTabSheet' then begin
    //Lo contiene un TTabSheet. Lo activamos.
    tab := TTabSheet(pag);
    //tab.Show;  Esto activaría la página, pero no actualizaría el TreeView1
    //Busca el ítem del árbol que activa esa página
    for it in TreeView1.Items do begin
      id := IdFromTTreeNode(it);  //Obtiene ID
      if GetTabFromId(id)=nil then continue;
      if  GetTabFromId(id) = tab then begin
        //Encontramos el id que selecciona al "tab2.
        it.Selected := true;  //Selecciona en el TreeView1
        TreeView1Click(self); //Activa el "tab".
        //Intenta seleccionar al control
        if ctlRef is TWinControl then begin
          ctl := TWinControl(ctlRef);
          if (it.Visible=true) and (ctl.Visible = true) and ctl.CanFocus then begin
            ctl.SetFocus;
          end;
        end;
        exit(true);  //Se ubicó
      end;
    end;
    //No se encontró al ítem que selecciona a este "tab".
    exit(false);
  end else begin
    //No se conoce al contenedor
    exit(false);
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
  if not cfgFile.WindowToProperties then begin
    //Se produjo un error
    //Trata de seleccionar al control con error.
    ActivateControl(cfgFile.ctlErr.ctlRef);
    MsgErr(cfgFile.MsjErr);
    exit;
  end;
  //Valida las rutas leidas
  if not DirectoryExists(foldTemp) then begin
    MsgExc('Folder not found: %s',[foldTemp]);
    foldTemp := patTemp;
  end;
  if not DirectoryExists(foldMacros) then begin
    MsgExc('Folder not found: %s', [foldMacros]);
    foldMacros := patMacros;
  end;
  if not DirectoryExists(foldLenguajes) then begin
    MsgExc('Folder not found: %s', [foldLenguajes]);
    foldLenguajes := patSyntax;
  end;
  if OnPropertiesChanged<>nil then OnPropertiesChanged();
  SaveToFile;   //Guarda propiedades en disco
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

procedure TConfig.MostEnVentana;
//Muestra las propiedades en la ventana de configuración.
begin
  if not cfgFile.PropertiesToWindow then begin
    MsgErr(cfgFile.MsjErr);
  end;
end;
procedure TConfig.ReadFromFile(iniFile: string = '');
begin
  if not cfgFile.FileToProperties then begin
    MsgErr(cfgFile.MsjErr);
  end;
  if OnPropertiesChanged<>nil then OnPropertiesChanged();
end;
procedure TConfig.SaveToFile(iniFile: string='');
//Escribe el archivo de configuración
begin
  if not cfgFile.PropertiesToFile then begin
    MsgErr(cfgFile.MsjErr);
  end;
end;

end.

