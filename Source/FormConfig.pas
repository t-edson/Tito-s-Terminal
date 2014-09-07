{Unidad con formulario de configuración para manejar las propiedades de
 una aplicación. Está pensado para usarse con frames de la clase Tframe,
 definida en la unidad "PropertyFrame".
 }
unit FormConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, StdCtrls, ExtCtrls,
  EditBtn, SynEdit, SynEditHighlighter,
  dialogs, Buttons, ComCtrls, UnTerminal, MisUtils,
  FrameCfgDetPrompt, FrameCfgConex, FrameCfgEdit, frameCfgPantTerm, FrameCfgGener,
  frameConfExpRem, FrameConfMacros, FrameCfgComandRec, FrameCfgRutasCnx, FrameCfgPanCom
  ,ConfigFrame;   //para interceptar TFrame

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
    fraError: TFrame;
    msjError: string;
    arIni   : String;      //Archivo de configuración
    edTerm  : TSynEdit;    //referencia al editor SynEdit
    edPCom  : TSynEdit;    //referencia al editor panel de comando
    edMacr  : TSynEdit;    //referencia al editor panel de comando
    edRemo  : TSynEdit;    //referencia al editor remoto
    prTel   : TConexProc;
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
    procedure Iniciar;
    procedure LeerArchivoIni(iniFile: string='');
    procedure escribirArchivoIni(iniFile: string='');
    procedure Configurar(grupo: string='');
    function ContienePrompt(const linAct, prIni, prFin: string): integer;
    function ContienePrompt(const cad: string): boolean;
    function EsPrompt(const cad: string): boolean;
  end;

var
  Config: TConfig;

implementation
{$R *.lfm}
const MAX_ARC_REC = 5;  //si se cambia, actualizar ActualMenusReciente()

  { TConfig }

procedure TConfig.FormCreate(Sender: TObject);
begin
  //Crea frames de configuración
  fcConex:= TFraConexion.Create(Self);
  fcConex.parent := self;
  fcComRec := TfraComandRec.Create(Self);
  fcComRec.parent := self;
  fcRutArc := TfraCfgRutArc.Create(Self);
  fcRutArc.parent := self;

  fcEdTerm:= TfcEdit.Create(Self);
  fcEdTerm.Name := 'ter';  //para que no de error de nombre
  fcEdTerm.parent := self;
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

  fcPantTerm:= TfraPantTerm.Create(Self);
  fcPantTerm.parent := self;
  fcDetPrompt:= TfraDetPrompt.Create(Self);
  fcDetPrompt.parent := self;
  fcGener := TfraCfgGener.Create(Self);
  fcGener.parent := self;

  fcExpRem    := TfcExpRem.Create(self);
  fcExpRem.parent := self;

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

procedure TConfig.Iniciar;
//Inicia el formulario de configuración. Debe llamarse antes de usar el formulario y
//después de haber cargado todos los frames.
begin
  //inicia Frames
  fcConex.Iniciar('conexion', prTel);
  fcComRec.Iniciar('comand_rec');
  fcRutArc.Iniciar('rutas_conex');
  fcEdTerm.Iniciar('terminal', edTerm, clBlack);
  fcEdPcom.Iniciar('panelCom', edPCom);
  fcPanCom.Iniciar('fcPanCom');
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
var
  selec: String;
  nivel: Integer;
begin
  if TreeView1.Selected = nil then exit;
  Hide_AllConfigFrames(self);  //oculta todos
  nivel := TreeView1.Selected.Level;
  if nivel = 1 then  //de dos niveles
    selec := TreeView1.Selected.Parent.Text +'-'+TreeView1.Selected.Text
  else  //de un nivel
    selec := TreeView1.Selected.Text;
  case selec of
  'Conexión',
  'Conexión-General'         :fcConex.ShowPos(145,0) ;
  'Conexión-Detec.de Prompt' :fcDetPrompt.ShowPos(145,0);
  'Conexión-Rutas/Archivos'   : fcRutArc.ShowPos(145,0);
  'Terminal',
  'Terminal-Pantalla'        :fcPantTerm.ShowPos(145,0);
  'Terminal-Editor'          :fcEdTerm.ShowPos(145,0);
  'Terminal-Comando Recurrente': fcComRec.ShowPos(145,0);
  'Panel de Comandos',
  'Panel de Comandos-Editor' :fcEdPcom.ShowPos(145,0);
  'Panel de Comandos-Otros'  :fcPanCom.ShowPos(145,0);
  'Macros',
  'Macros-Configuración'     :fcMacros.ShowPos(145,0);
  'Macros-Editor'            :fcEdMacr.ShowPos(145,0);
  'Editor Remoto',
  'Editor Remoto-Editor'     :fcEdRemo.ShowPos(145,0);
  'Otros',
  'Otros-Explorador Remoto'  :fcExpRem.ShowPos(145,0);
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
procedure TConfig.Configurar(grupo: string='');
//Muestra el formulario, de modo que permita configurar la sesión actual
var
  it: TTreeNode;
begin
  if grupo<> '' then begin  /////se pide mostrar un grupo en especial
    //oculta los demás
    for it in TreeView1.Items do if it.Level=0 then begin
        if it.Text=grupo then it.Selected:=true;
    end;
{    //selecciona el primer visible
    for it in TreeView1.Items do if it.Visible then begin
      it.Selected:=true; break;
    end;}
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

end.

