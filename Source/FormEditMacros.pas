unit FormEditMacros;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs, LCLProc,
  Menus, ComCtrls, ActnList, StdActns,
  MisUtils, SynFacilUtils, Parser, Globales, FrameCfgConex;

type

  { TfrmEditMacros }

  TfrmEditMacros = class(TForm)
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
    AcHerEjec: TAction;
    AcHerDeten: TAction;
    AcHerGrab: TAction;
    ActionList: TActionList;
    acVerPanArc: TAction;
    ImageList1: TImageList;
    MainMenu1: TMainMenu;
    mnArchivo: TMenuItem;
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
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    mnRecientes: TMenuItem;
    mnHerram: TMenuItem;
    mnEdicion: TMenuItem;
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
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
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
    procedure AcHerDetenExecute(Sender: TObject);
    procedure AcHerEjecExecute(Sender: TObject);
    procedure AcHerGrabExecute(Sender: TObject);
    procedure ChangeEditorState;
    procedure editChangeFileInform;
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
  private
    edit: TSynFacilEditor;
    procedure MarcarError(nLin, nCol: integer);
  public
    { public declarations }
    procedure Ejecutar(arc: string);
    procedure DetenerEjec;
    procedure Abrir(arc: string);
    procedure SetLanguage(lang: string);
  end;

var
  frmEditMacros: TfrmEditMacros;

implementation
uses FormConfig;
{$R *.lfm}

{ TfrmEditMacros }

procedure TfrmEditMacros.FormCreate(Sender: TObject);
begin
  edit := TSynFacilEditor.Create(ed,'SinNombre', 'ttm');
  edit.OnChangeEditorState:=@ChangeEditorState;
  edit.OnChangeFileInform:=@editChangeFileInform;
  //define paneles
  edit.PanFileSaved := StatusBar1.Panels[0]; //panel para mensaje "Guardado"
  edit.PanCursorPos := StatusBar1.Panels[1];  //panel para la posición del cursor
//  edit.PanForEndLin := StatusBar1.Panels[2];  //panel para el tipo de delimitador de línea
  edit.PanCodifFile := StatusBar1.Panels[3];  //panel para la codificación del archivo
  edit.NewFile;
  edit.LoadSyntaxFromFile(rutLenguajes+'\Terminal Macro.xml');
  edit.InitMenuRecents(mnRecientes, nil);  //inicia el menú "Recientes"
  InicEditorC1(ed);     //inicia editor con configuraciones por defecto
end;

procedure TfrmEditMacros.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
  if edit.SaveQuery then CanClose := false;   //cancela
end;

procedure TfrmEditMacros.FormDestroy(Sender: TObject);
begin
  edit.Free;
end;

procedure TfrmEditMacros.FormDropFiles(Sender: TObject; const FileNames: array of String);
begin
  //Carga archivo arrastrados
  if edit.SaveQuery then Exit;   //Verifica cambios
  edit.LoadFile(FileNames[0]);
end;

procedure TfrmEditMacros.ChangeEditorState;
begin
  acArcGuardar.Enabled:=edit.Modified;
  acEdiUndo.Enabled:=edit.CanUndo;
  acEdiRedo.Enabled:=edit.CanRedo;
  //Para estas acciones no es necesario controlarlas, porque son acciones pre-determinadas
//  acEdiCortar.Enabled  := edit.canCopy;
//  acEdiCopiar.Enabled := edit.canCopy;
//  acEdiPegar.Enabled:= edit.CanPaste;
end;

procedure TfrmEditMacros.editChangeFileInform;
begin
  //actualiza nombre de archivo
  Caption := 'Editor de Macros - ' + edit.NomArc;
end;

/////////////////// Acciones de Archivo /////////////////////
procedure TfrmEditMacros.acArcNuevoExecute(Sender: TObject);
begin
  edit.NewFile;
  ed.Lines[0] := dic('// Macro de ejemplo para ')+NOM_PROG;
  ed.Lines.Add(dic('// Creada: ') + DateTimeToStr(Now) );
  ed.Lines.Add('disconnect    '+dic('//Desconecta por si había alguna conexión'));
  ed.Lines.Add('connect "192.168.1.1"    '+dic('//Conecta a nueva dirección'));
  ed.Lines.Add('wait "login: "');
  ed.Lines.Add('sendln "usuario"');
  ed.Lines.Add('wait "password: "');
  ed.Lines.Add('sendln "clave"');
  ed.Lines.Add('pause 3    '+dic('//espera 3 segundos'));
  ed.Lines.Add('sendln "cd /folder"');
end;
procedure TfrmEditMacros.acArcAbrirExecute(Sender: TObject);
begin
  OpenDialog1.Filter:='Tito''s Telnet Macro |*.ttm|Todos los archivos|*.*';
  OpenDialog1.InitialDir:=config.fcRutArc.macros;  //busca aquí por defecto
  edit.OpenDialog(OpenDialog1);
end;
procedure TfrmEditMacros.acArcGuardarExecute(Sender: TObject);
begin
  edit.SaveFile;
end;
procedure TfrmEditMacros.acArcGuaComExecute(Sender: TObject);
begin
  SaveDialog1.InitialDir:=config.fcRutArc.macros;  //busca aquí por defecto
  edit.SaveAsDialog(SaveDialog1);
end;
procedure TfrmEditMacros.acArcSalirExecute(Sender: TObject);
begin
  frmEditMacros.Close;
end;
procedure TfrmEditMacros.MarcarError(nLin, nCol: integer);
begin
  //posiciona curosr
  ed.CaretX := nCol;
  ed.CaretY := nLin;
  //define línea con error
  edit.linErr := nLin;
  ed.Invalidate;  //refresca
end;

//////////// Acciones de Edición ////////////////
procedure TfrmEditMacros.acEdiUndoExecute(Sender: TObject);
begin
  edit.Undo;
end;
procedure TfrmEditMacros.acEdiRedoExecute(Sender: TObject);
begin
  edit.Redo;
end;
procedure TfrmEditMacros.acEdiSelecAllExecute(Sender: TObject);
begin
  ed.SelectAll;
end;
//////////// Acciones de Herramientas  ////////////////
procedure TfrmEditMacros.AcHerEjecExecute(Sender: TObject);
begin
  cxp.Compilar(edit.NomArc, ed.Lines);
  if cxp.HayError then begin
    MarcarError(cxp.nLinError,cxp.nColError);
    cxp.ShowError;
  end;
end;
procedure TfrmEditMacros.AcHerGrabExecute(Sender: TObject);
//Graba la onexión actual
begin
  //Inicialización
  ed.ClearAll;
  ed.Lines.Add(dic('// Macro generada para ')+NOM_PROG);
  ed.Lines.Add(dic('// Fecha: ') + DateTimeToStr(Now) );
  ed.Lines.Add('DISCONNECT    '+dic('//Desconecta por si había alguna conexión'));
  ed.Lines.Add('CLEAR         '+dic('//Limpia la pantalla'));
  //lee parámetros de la configuración actual
  case Config.fcConex.tipo of
  TCON_TELNET: begin
      ed.Lines.Add('curTYPE := "Telnet"');
    end;
  TCON_SSH   : begin
      ed.Lines.Add('curTYPE := "SSH"');
    end;
  TCON_SERIAL: begin
      ed.Lines.Add('curTYPE := "Serial"');
    end;
  TCON_OTHER : begin
      ed.Lines.Add('curTYPE := "Other"    //Este es el tipo para otros procesos');
      ed.Lines.Add('curAPP := "'+ Config.fcConex.Other +'"   //El proceso que vamoa a lanzar');
    end;
  end;
  if Config.fcConex.SendCRLF then
    ed.Lines.Add('curENDLINE := "CRLF"  //El tipo de salto de línea a enviar')
  else
    ed.Lines.Add('curENDLINE := "LF"  //El tipo de salto de línea a enviar');
  //conecta
  ed.Lines.Add('CONNECT               '+dic('//Inicia conexión'));
//  PAUSE 3               //Espera unos segundos
//  DETECT_PROMPT         //Configura la línea actual como el prompt

end;
procedure TfrmEditMacros.AcHerDetenExecute(Sender: TObject);
begin
  DetenerEjec;
end;
procedure TfrmEditMacros.AcHerConfigExecute(Sender: TObject);
begin
  config.Configurar('Macros');
end;
procedure TfrmEditMacros.DetenerEjec;
//Detiene la ejecución de la macro en curso
begin
  if not cxp.ejecProg then exit;
  DetEjec := true;  //manda mensaje para detener la macro
end;
procedure TfrmEditMacros.Ejecutar(arc: string);
//Permite ejecutar una macro almacenada en un archivo externo
var
  larc: TStringList;
begin
  larc := Tstringlist.Create;
  larc.LoadFromFile(UTF8toSys(arc));
  cxp.Compilar(arc, larc);
  if cxp.HayError then begin
    self.Show;   //por si no estaba visible
    //muestra error en el editor
    if edit.NomArc = arc then begin
      //lo tiene en el editor
      MarcarError(cxp.nLinError,cxp.nColError);
      cxp.ShowError;
    end else begin
      //no está abierto
      Abrir(arc);   //lo abre
      MarcarError(cxp.nLinError,cxp.nColError);
      cxp.ShowError;
    end;
  end;
  larc.Free;
end;
procedure TfrmEditMacros.Abrir(arc: string);
//Permite editar una macro almacenada en un archivo externo
begin
  if edit.SaveQuery then Exit;   //Verifica cambios
  edit.LoadFile(arc);
end;

procedure TfrmEditMacros.SetLanguage(lang: string);
//Rutina de traducción
begin
  edit.SetLanguage(lang);
  case lowerCase(lang) of
  'es': begin
    acArcNuevo.Caption := '&Nuevo';
    acArcAbrir.Caption := '&Abrir...';
    acArcGuardar.Caption := '&Guardar';
    acArcGuaCom.Caption := 'G&uardar Como...';
    acArcSalir.Caption := '&Salir';
    acEdiUndo.Caption := '&Deshacer';
    acEdiRedo.Caption := '&Rehacer';
    acEdiCut.Caption := 'Cor&tar';
    acEdiCopy.Caption := '&Copiar';
    acEdiPaste.Caption := '&Pegar';
    acEdiSelecAll.Caption := 'Seleccionar &Todo';
    acEdiModCol.Caption := 'Modo Columna';
    acVerNumLin.Caption := 'Ver &Núm. de Línea';
    acVerBarEst.Caption := 'Ver Barra de &Estado';
    acBusBuscar.Caption := 'Buscar...';
    acBusBusSig.Caption := 'Buscar &Siguiente';
    acBusRem.Caption := '&Remplazar...';
    acVerPanArc.Caption := 'Panel de &Archivos';
    AcHerEjec.Caption := '&Ejecutar';
    AcHerDeten.Caption := '&Detener';
    AcHerGrab.Caption := '&Grabar';
    AcHerConfig.Caption := 'C&onfigurar';
    //menús
    mnArchivo.Caption := '&Archivo';
    mnRecientes.Caption:='&Recientes';
    mnEdicion.Caption:='&Edición';
    mnHerram.Caption:='&Herramientas';
    //textos
    dicClear;  //ya está en español
    end;
  'en': begin
    acArcNuevo.Caption := '&New';
    acArcAbrir.Caption := '&Open...';
    acArcGuardar.Caption := '&Save';
    acArcGuaCom.Caption := 'Sa&ve As...';
    acArcSalir.Caption := '&Quit';
    acEdiUndo.Caption := '&Undo';
    acEdiRedo.Caption := '&Redo';
    acEdiCut.Caption := 'Cu&t';
    acEdiCopy.Caption := '&Copy';
    acEdiPaste.Caption := '&Paste';
    acEdiSelecAll.Caption := 'Select &All';
    acEdiModCol.Caption := 'Column Mode';
    acVerNumLin.Caption := 'View Line &Number';
    acVerBarEst.Caption := 'View &Statusbar';
    acBusBuscar.Caption := 'Find...';
    acBusBusSig.Caption := 'Find &Next';
    acBusRem.Caption := '&Replace...';
    acVerPanArc.Caption := '&File Panel';
    AcHerEjec.Caption := '&Execute';
    AcHerDeten.Caption := '&Stop';
    AcHerGrab.Caption := '&Record';
    AcHerConfig.Caption := '&Setup';
    //menús
    mnArchivo.Caption := '&File';
    mnRecientes.Caption:='&Recents';
    mnEdicion.Caption:='&Edit';
    mnHerram.Caption:='&Tools';
    //textos
    dicSet('// Macro de ejemplo para ','// Sample of macro for ');
    dicSet('// Creada: ','// Created: ');
    dicSet('// Macro generada para ','// Macro generated for ');
    dicSet('// Fecha: ','// Date: ');
    dicSet('//Desconecta por si había alguna conexión','//Disconnect if it''s connected');
    dicSet('//Conecta a nueva dirección','//Connect to a new IP');
    dicSet('//espera 3 segundos','//wait for 3 seconds');
    dicSet('//Limpia la pantalla','//Clear the terminal');
    dicSet('//Inicia conexión','//Start connection');
    end;
  end;
end;

end.

