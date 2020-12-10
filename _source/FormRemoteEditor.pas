{Programa ejemplo de uso de la librería para implementar editores "utilEditSyn".
                                        Por Tito Hinostroza   11/07/2014 }
unit FormRemoteEditor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LazUTF8, SynEdit, Forms, Controls, Graphics,
  Dialogs, Menus, ComCtrls, ActnList, StdActns, SynEditMiscClasses, MisUtils,
  Globales, SynFacilUtils, FormRemoteOpenDial, FrameTabSession;

type
//  TEditionMode = (
//    temLocal,    //Edición normal de un archivo local
//    temRemSFTP,  //Edición remota pro SFTP
//    temRemShell  //Ediicón remota por comandos SSH (No recomendable)
//  );
  { TfrmRemoteEditor }
  TfrmRemoteEditor = class(TForm)
  published
    acFilOpen: TAction;
    acFilSaveAs: TAction;
    acFilSave: TAction;
    acFilNew: TAction;
    acFilExit: TAction;
    acSrchSearch: TAction;
    acSrchSearchNext: TAction;
    acSrchReplace: TAction;
    acEdiCopy: TEditCopy;
    acEdiCut: TEditCut;
    acEdiPaste: TEditPaste;
    acEdiRedo: TAction;
    acEdiSelecAll: TAction;
    acEdiUndo: TAction;
    AcToolSettings: TAction;
    ActionList: TActionList;
    acViewFilPanel: TAction;
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
    mnRecents: TMenuItem;
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
    acViewStaBar: TAction;
    acViewLinNum: TAction;
    procedure acFilOpenExecute(Sender: TObject);
    procedure acFilSaveAsExecute(Sender: TObject);
    procedure acFilSaveExecute(Sender: TObject);
    procedure acFilNewExecute(Sender: TObject);
    procedure acFilExitExecute(Sender: TObject);
    procedure acEdiRedoExecute(Sender: TObject);
    procedure acEdiSelecAllExecute(Sender: TObject);
    procedure acEdiUndoExecute(Sender: TObject);
    procedure AcToolSettingsExecute(Sender: TObject);
    procedure ChangeEditorState;
    procedure editChangeFileInform;
    procedure edSpecialLineMarkup(Sender: TObject; Line: integer;
      var Special: boolean; Markup: TSynSelectedColor);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
    procedure FormShow(Sender: TObject);
  private
    ses: TfraTabSession;
    edit: TSynFacilEditor;
    lineas: TStringList;    //lista temporal
    localFile, destFile: String;  //Rutas de archivo
  public
    MsjErr: String;
    NomArcLocal: string;  //nombre de archivo local
    procedure Open(destFile0: string);
    procedure Init(ses0: TfraTabSession);
  end;

var
  frmRemoteEditor: TfrmRemoteEditor;

implementation
uses FormPrincipal, FormConfig, Comandos;
{$R *.lfm}

{ TfrmRemoteEditor }
procedure TfrmRemoteEditor.FormCreate(Sender: TObject);
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

  lineas := TStringList.Create;
end;
procedure TfrmRemoteEditor.FormShow(Sender: TObject);
begin
  edit.NewFile;        //para actualizar estado
  mnLenguaje.Clear;
  edit.InitMenuLanguages(mnLenguaje, patSyntax);
  edit.LoadSyntaxFromPath;  //para que busque el archivo apropiado
  edit.InitMenuRecents(mnRecents,nil);  //inicia el menú "Recientes"
end;
procedure TfrmRemoteEditor.FormCloseQuery(Sender: TObject; var CanClose: boolean);
var
  rpta: Byte;
begin
  if edit.Modified then begin  //primero pregunta
    rpta := MsgYesNoCancel('File modified. Save on Server?');
    if rpta = 3 then begin  //Cancel
      CanClose := false;  //no deja cerrar
      exit;
    end;
    if rpta = 1 then begin //Yes
      acFilSaveExecute(self);  //Primero guarda
    end;
  end;
  //se debe cerrar.
  //Limpiar el contenido, ya que solo se ocultará, y no queremos que aparezca el último
  //archivo cargado.
  edit.NewFile(false);
end;
procedure TfrmRemoteEditor.FormDestroy(Sender: TObject);
begin
  lineas.Destroy;
  edit.Destroy;
end;
procedure TfrmRemoteEditor.FormDropFiles(Sender: TObject; const FileNames: array of String);
begin
  //Carga archivo arrastrados
  if edit.SaveQuery then Exit;   //Verifica cambios
  edit.LoadFile(FileNames[0]);
  edit.LoadSyntaxFromPath;  //para que busque el archivo apropiado
end;
procedure TfrmRemoteEditor.ChangeEditorState;
begin
  acFilSave.Enabled:=edit.Modified;
  acEdiUndo.Enabled:=edit.CanUndo;
  acEdiRedo.Enabled:=edit.CanRedo;
  //Para estas acciones no es necesario controlarlas, porque son acciones pre-determinadas
//  acEdiCortar.Enabled  := edit.canCopy;
//  acEdiCopiar.Enabled := edit.canCopy;
//  acEdiPegar.Enabled:= edit.CanPaste;
end;
procedure TfrmRemoteEditor.editChangeFileInform;
begin
  //actualiza nombre de archivo
  Caption := 'Remote Editor - ' + edit.FileName;
end;
procedure TfrmRemoteEditor.edSpecialLineMarkup(Sender: TObject; Line: integer;
  var Special: boolean; Markup: TSynSelectedColor);
begin
  //vacío
end;
/////////////////// Acciones de Archivo /////////////////////
procedure TfrmRemoteEditor.acFilNewExecute(Sender: TObject);
begin
  edit.NewFile;
  edit.LoadSyntaxFromPath;  //para que busque el archivo apropiado
end;
procedure TfrmRemoteEditor.acFilOpenExecute(Sender: TObject);
begin
//  OpenDialog1.Filter:='Text files|*.txt|All files|*.*';
//  edit.OpenDialog(OpenDialog1);
  frmRemoteOpenDial.ShowModal;
  if frmRemoteOpenDial.archivo <> '' then begin
    Open(frmRemoteOpenDial.archivo);
  end;
end;
procedure TfrmRemoteEditor.acFilSaveExecute(Sender: TObject);
var
  txt: String;
begin
  if ses.editMode = edtLocal then begin
    //Edición normal en archivo local
    edit.SaveFile;
  end else if ses.editMode = edtRemotSFTP then begin
    if destFile='' then begin
      MsgExc('There isn''t a file opened');
      exit;
    end;
    //Modo SFTP
    edit.SaveFile;  //Guarda localmente
    //Transfiere archivo usando la misma IP de la conexión.
    ExecSFTP(ses.ftpEditUser, ses.ftpEditPass, ses.ip,
        'lcd "'+ patTemp + '"' + LineEnding +
        'cd "'+ ExtractFileDir(destFile) + '"' + LineEnding +
        'put "' + ExtractFileName(destFile) + '"' + LineEnding +
        'quit');

  end else if ses.editMode = edtBashComm then begin
    //Modo de puro comandos del shell
    txt := edit.Text;   //toma texto
    {Usa comillas simples para evitar sustitución, porque las comillas simples ponen todo
    literalmente. El problema está cuando se quiere imprimir precisamente, comilla simple.
    Para ello se debe hacer una sustitución}
    ed.Enabled := False;
    txt := StringReplace(txt, '''', '''"''"''',[rfReplaceAll]);
    if ses<>nil then begin
      ses.EnviarComando('echo ''' + txt + ''' > "' + edit.FileName+'"', lineas);
    end;
    ed.Enabled := True;
    //para actualizar controles
    edit.Modified:=false;  //Este método no es público en la librería original
  end;
end;

procedure TfrmRemoteEditor.acFilSaveAsExecute(Sender: TObject);
var
  arc0: String;
begin
//  edit.SaveAsDialog(SaveDialog1);
  if not SaveDialog1.Execute then begin  //se canceló
    exit;    //se canceló
  end;
  arc0 := SaveDialog1.FileName;
  if FileExists(arc0) then begin
    if MsgYesNoCancel('File already exists. Overwrite?',[arc0]) in [2,3] then exit;
  end;
  NomArcLocal := UTF8ToSys(arc0);   //asigna nuevo nombre
//  if ExtractFileExt(NomArc) = '' then NomArc += '.'+extDef;  //completa extensión
  edit.SaveFile;   //lo guarda
end;

procedure TfrmRemoteEditor.acFilExitExecute(Sender: TObject);
begin
  frmRemoteEditor.Close;
end;
//////////// Acciones de Edición ////////////////
procedure TfrmRemoteEditor.acEdiUndoExecute(Sender: TObject);
begin
  edit.Undo;
end;
procedure TfrmRemoteEditor.AcToolSettingsExecute(Sender: TObject);
begin
  config.Configurar('3');
end;
procedure TfrmRemoteEditor.acEdiRedoExecute(Sender: TObject);
begin
  edit.Redo;
end;
procedure TfrmRemoteEditor.acEdiSelecAllExecute(Sender: TObject);
begin
  ed.SelectAll;
end;
procedure TfrmRemoteEditor.Open(destFile0: string);  //Opcional para archivos locales
//Permite editar un archivo almacenado en un archivo externo
begin
  destFile := destFile0;   //Guarda archivo abierto
  if self.Visible and edit.SaveQuery then Exit;   //Verifica cambios
  if not self.Visible then self.Show;
  if ses.editMode = edtLocal then begin
    //Edición normal
    edit.LoadFile(destFile);
  end else if ses.editMode = edtRemotSFTP then begin   //Edición por SFTP
    //Crea ruta de archivo local
    localFile := patTemp + DirectorySeparator + ExtractFileName(destFile);
    //Elimina si ya existe
    if FileExists(localFile) then DeleteFile(localFile);
    //Trae archivo usando la misma IP de la conexión.
    ExecSFTP(ses.ftpEditUser, ses.ftpEditPass, ses.ip,
        'lcd "'+ patTemp + '"' + LineEnding +
        'get ' + destFile + LineEnding +
        'quit');
    //Carga archivo local
    //edit.Text := StringFromFile(patTemp + DirectorySeparator + localFile);
    edit.LoadFile(localFile);

  end else if ses.editMode = edtBashComm then begin
    //Ediicón por comandos
    if ses<>nil then begin
      MsjErr := ses.EnviarComando('cat "'+destFile+'"', lineas);
    end;
    ed.Lines.Clear;
    ed.Lines.AddStrings(lineas);
    edit.FileName:=destFile;
    //para actualizar controles
    edit.Modified:=false;  //Este método no es público en la librería original)
     //para actualizar nombre
    edit.ChangeFileInform;   //Este método no es público en la librería original)
    edit.LoadSyntaxFromPath;  //para que busque el archivo apropiado
  end;
end;

procedure TfrmRemoteEditor.Init(ses0: TfraTabSession);
{Inicializa parámetros que necesita la herramienta Editor.
Para mostrar el editor se necesita simplemente llamar a .Show }
begin
  //Se necesita acceder a la sesión para determinar el modo de edición.
  ses := ses0;
end;


end.

