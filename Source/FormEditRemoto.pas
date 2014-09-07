{Programa ejemplo de uso de la librería para implementar editores "utilEditSyn".
                                        Por Tito Hinostroza   11/07/2014 }
unit FormEditRemoto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs, Menus,
  ComCtrls, ActnList, StdActns, SynEditMiscClasses,
  MisUtils, Globales, SynFacilUtils, FormAbrirRemoto;

type

  { TfrmEditRemoto }

  TfrmEditRemoto = class(TForm)
  published
    acArcAbrir: TAction;
    acArcGuaCom: TAction;
    acArcGuardar: TAction;
    acArcNuevo: TAction;
    acArcSalir: TAction;
    acBusBuscar: TAction;
    acBusBusSig: TAction;
    acBusRem: TAction;
    acEdiCopy: TEditCopy;
    acEdiCut: TEditCut;
    acEdiModCol: TAction;
    acEdiPaste: TEditPaste;
    acEdiRedo: TAction;
    acEdiSelecAll: TAction;
    acEdiUndo: TAction;
    AcHerConfig: TAction;
    ActionList: TActionList;
    acVerPanArc: TAction;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    mnLenguaje: TMenuItem;
    mnRecientes: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    StatusBar1: TStatusBar;
    ed: TSynEdit;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    acVerBarEst: TAction;
    acVerNumLin: TAction;
    procedure acArcAbrirExecute(Sender: TObject);
    procedure acArcGuaComExecute(Sender: TObject);
    procedure acArcGuardarExecute(Sender: TObject);
    procedure acArcNuevoExecute(Sender: TObject);
    procedure acArcSalirExecute(Sender: TObject);
    procedure acEdiRedoExecute(Sender: TObject);
    procedure acEdiSelecAllExecute(Sender: TObject);
    procedure acEdiUndoExecute(Sender: TObject);
    procedure AcHerConfigExecute(Sender: TObject);
    procedure ChangeEditorState;
    procedure editChangeFileInform;
    procedure edSpecialLineMarkup(Sender: TObject; Line: integer;
      var Special: boolean; Markup: TSynSelectedColor);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
  private
    edit: TSynFacilEditor;
    lineas: TStringList;    //lista temporal
  public
    NomArcLocal: string;  //nombre de archivo local
    procedure AbrirRemoto(arc: string);
  end;

var
  frmEditRemoto: TfrmEditRemoto;

implementation
uses FormPrincipal, FormConfig;
{$R *.lfm}

{ TfrmEditRemoto }

procedure TfrmEditRemoto.FormCreate(Sender: TObject);
begin
  InicEditorC1(ed);     //inicia editor con configuraciones por defecto
  ed.OnSpecialLineMarkup:=@edSpecialLineMarkup;  //solo para corregir falla de resaltado de línea actual

  edit := TSynFacilEditor.Create(ed,'SinNombre', 'sh');
  edit.OnChangeEditorState:=@ChangeEditorState;
  edit.OnChangeFileInform:=@editChangeFileInform;
  //define paneles
  edit.PanFileSaved := StatusBar1.Panels[0]; //panel para mensaje "Guardado"
  edit.PanCursorPos := StatusBar1.Panels[1];  //panel para la posición del cursor
  edit.PanForEndLin := StatusBar1.Panels[2];  //panel para el tipo de delimitador de línea
  edit.PanCodifFile := StatusBar1.Panels[3];  //panel para la codificación del archivo
  edit.PanLangName  := StatusBar1.Panels[4];  //panel para el nombre del lenguaje

  edit.NewFile;        //para actualizar estado
  edit.InitMenuLanguages(mnLenguaje, rutLenguajes);
  edit.LoadSyntaxFromPath;  //para que busque el archivo apropiado
  edit.InitMenuRecents(mnRecientes,nil);  //inicia el menú "Recientes"

  lineas := TStringList.Create;
end;

procedure TfrmEditRemoto.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  rpta: Byte;
begin
  if edit.Modified then begin  //primero pregunta
    rpta := MsgYesNoCancel('El archivo ha sido modificado. ¿Guardar en el servidor?');
    if rpta = 3 then begin  //Cancel
      CanClose := false;  //no deja cerrar
      exit;
    end;
    if rpta = 1 then begin //Yes
      acArcGuardarExecute(self);  //primero guarda
    end;
  end;
  //se debe cerrar.
  //Limpiar el contenido, ya que solo se ocultará, y no queremos que aparezca el último
  //archivo cargado.
  edit.NewFile(false);
end;

procedure TfrmEditRemoto.FormDestroy(Sender: TObject);
begin
  lineas.Destroy;
  edit.Destroy;
end;

procedure TfrmEditRemoto.FormDropFiles(Sender: TObject; const FileNames: array of String);
begin
  //Carga archivo arrastrados
  if edit.SaveQuery then Exit;   //Verifica cambios
  edit.LoadFile(FileNames[0]);
  edit.LoadSyntaxFromPath;  //para que busque el archivo apropiado
end;

procedure TfrmEditRemoto.ChangeEditorState;
begin
  acArcGuardar.Enabled:=edit.Modified;
  acEdiUndo.Enabled:=edit.CanUndo;
  acEdiRedo.Enabled:=edit.CanRedo;
  //Para estas acciones no es necesario controlarlas, porque son acciones pre-determinadas
//  acEdiCortar.Enabled  := edit.canCopy;
//  acEdiCopiar.Enabled := edit.canCopy;
//  acEdiPegar.Enabled:= edit.CanPaste;
end;

procedure TfrmEditRemoto.editChangeFileInform;
begin
  //actualiza nombre de archivo
  Caption := 'Editor Remoto - ' + edit.NomArc;
end;

procedure TfrmEditRemoto.edSpecialLineMarkup(Sender: TObject; Line: integer;
  var Special: boolean; Markup: TSynSelectedColor);
begin
  //vacío
end;

/////////////////// Acciones de Archivo /////////////////////
procedure TfrmEditRemoto.acArcNuevoExecute(Sender: TObject);
begin
  edit.NewFile;
  edit.LoadSyntaxFromPath;  //para que busque el archivo apropiado
end;
procedure TfrmEditRemoto.acArcAbrirExecute(Sender: TObject);
begin
//  OpenDialog1.Filter:='Text files|*.txt|All files|*.*';
//  edit.OpenDialog(OpenDialog1);
  frmAbrirRemoto.ShowModal;
  if frmAbrirRemoto.archivo <> '' then begin
    AbrirRemoto(frmAbrirRemoto.archivo);
  end;
end;

procedure TfrmEditRemoto.acArcGuardarExecute(Sender: TObject);
var
  txt: String;
  MsjErr: String;
begin
  txt := edit.Text;   //toma texto
  txt := StringReplace(txt, '\', '\\',[rfReplaceAll]);  //para proteger del comando
  txt := StringReplace(txt, '$', '\$',[rfReplaceAll]);
  txt := StringReplace(txt, '`', '\`',[rfReplaceAll]);
  txt := StringReplace(txt, '"', '\"',[rfReplaceAll]);
  txt := StringReplace(txt, '\\\\"', '\\\\\"',[rfReplaceAll]); //esta combinación debe ser así en ksh
  txt := StringReplace(txt, #9, '\t',[rfReplaceAll]);

  ed.Enabled := False;
  MsjErr := frmPrincipal.EnviarComando('echo "' + txt + '" > "' + edit.NomArc+'"', lineas);
  ed.Enabled := True;
  //para actualizar controles
  edit.Modified:=false;  //Este método no es público en la librería original)
//  edit.SaveFile;
end;

procedure TfrmEditRemoto.acArcGuaComExecute(Sender: TObject);
var
  arc0: String;
  resp: TModalResult;
begin
//  edit.SaveAsDialog(SaveDialog1);
  if not SaveDialog1.Execute then begin  //se canceló
    exit;    //se canceló
  end;
  arc0 := SaveDialog1.FileName;
  if FileExists(arc0) then begin
    resp := MessageDlg('', Format(MSG_OVERWRITE,[arc0]),
                       mtConfirmation, [mbYes, mbNo, mbCancel],0);
    if (resp = mrCancel) or (resp = mrNo) then Exit;
  end;
  NomArcLocal := UTF8ToSys(arc0);   //asigna nuevo nombre
//  if ExtractFileExt(NomArc) = '' then NomArc += '.'+extDef;  //completa extensión
  edit.SaveFile;   //lo guarda
end;

procedure TfrmEditRemoto.acArcSalirExecute(Sender: TObject);
begin
  frmEditRemoto.Close;
end;
//////////// Acciones de Edición ////////////////
procedure TfrmEditRemoto.acEdiUndoExecute(Sender: TObject);
begin
  edit.Undo;
end;

procedure TfrmEditRemoto.AcHerConfigExecute(Sender: TObject);
begin
  config.Configurar('Editor Remoto');
end;

procedure TfrmEditRemoto.acEdiRedoExecute(Sender: TObject);
begin
  edit.Redo;
end;
procedure TfrmEditRemoto.acEdiSelecAllExecute(Sender: TObject);
begin
  ed.SelectAll;
end;

procedure TfrmEditRemoto.AbrirRemoto(arc: string);
//Permite editar una macro almacenada en un archivo externo
var
  MsjErr: String;
begin
  if self.Visible and edit.SaveQuery then Exit;   //Verifica cambios
  if not self.Visible then self.Show;
  MsjErr := frmPrincipal.EnviarComando('cat "'+arc+'"', lineas);
  ed.Lines.Clear;
  ed.Lines.AddStrings(lineas);
  edit.NomArc:=arc;
  //para actualizar controles
  edit.Modified:=false;  //Este método no es público en la librería original)
   //para actualizar nombre
  edit.ChangeFileInform;   //Este método no es público en la librería original)
  edit.LoadSyntaxFromPath;  //para que busque el archivo apropiado
end;
end.

