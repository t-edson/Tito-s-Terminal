unit FormAbrirRemoto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  ExtCtrls, FrameExpRemoto, MisUtils;

type

  { TfrmAbrirRemoto }

  TfrmAbrirRemoto = class(TForm)
    butAceptar: TBitBtn;
    butCancel: TBitBtn;
    Panel1: TPanel;
    procedure butAceptarClick(Sender: TObject);
    procedure explorDblClickArch;
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    explor: TfraExpRemoto;
    actualizar: boolean;
  public
    archivo : string;
    procedure SetLanguage(lang: string);
  end;

var
  frmAbrirRemoto: TfrmAbrirRemoto;

implementation

{$R *.lfm}

{ TfrmAbrirRemoto }

procedure TfrmAbrirRemoto.FormCreate(Sender: TObject);
begin
  explor:= TfraExpRemoto.Create(self);
  explor.Parent := self;
  explor.Align:=alClient;
  explor.StatusBar1.Visible:=false;
  explor.OnDblClickArch:=@explorDblClickArch;
end;

procedure TfrmAbrirRemoto.FormDestroy(Sender: TObject);
begin
  explor.Destroy;
end;

procedure TfrmAbrirRemoto.FormShow(Sender: TObject);
begin
  archivo := '';
//  actualizar := true;
  explor.Actualizar;  //lee archivos
  Caption := dic('Abrir Remoto ...');
end;

procedure TfrmAbrirRemoto.FormActivate(Sender: TObject);
begin
{  if actualizar then begin
    explor.Actualizar;  //lee archivos
    actualizar := false;
  end;}
end;

procedure TfrmAbrirRemoto.butAceptarClick(Sender: TObject);
begin
  if explor.ItemSeleccionado = nil then begin
    msgexc('Debe seleccionar un archivo');
    exit;
  end;
  if explor.ItemSeleccionado.ImageIndex = IMG_CARPETA then begin
    msgexc('Debe seleccionar un archivo');
    exit;
  end;
  //se supone que se ha seleccionado un archivo
  archivo := explor.ItemSeleccionado.Caption;
  self.Close;
end;

procedure TfrmAbrirRemoto.explorDblClickArch;
//DOble click en explorador
begin
  //se supone que se ha seleccionado un archivo
  archivo := explor.ItemSeleccionado.Caption;
  self.Close;
end;

procedure TfrmAbrirRemoto.SetLanguage(lang: string);
//Rutina de traducción
begin
  explor.SetLanguage(lang);
  case lowerCase(lang) of
  'es': begin
      dicClear;  //ya está en español.
    end;
  'en': begin
      dicSet('Abrir Remoto ...','Open Remote ...');
    end;
  end;
end;

end.

