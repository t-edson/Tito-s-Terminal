unit FormRemoteOpenDial;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Buttons,
  ExtCtrls, FrameExpRemoto, MisUtils;

type

  { TfrmRemoteOpenDial }

  TfrmRemoteOpenDial = class(TForm)
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
//    actualizar: boolean;
  public
    archivo : string;
  end;

var
  frmRemoteOpenDial: TfrmRemoteOpenDial;

implementation

{$R *.lfm}

{ TfrmRemoteOpenDial }

procedure TfrmRemoteOpenDial.FormCreate(Sender: TObject);
begin
  explor:= TfraExpRemoto.Create(self);
  explor.Parent := self;
  explor.Align:=alClient;
  explor.StatusBar1.Visible:=false;
  explor.OnDblClickArch:=@explorDblClickArch;
end;

procedure TfrmRemoteOpenDial.FormDestroy(Sender: TObject);
begin
  explor.Destroy;
end;

procedure TfrmRemoteOpenDial.FormShow(Sender: TObject);
begin
  archivo := '';
//  actualizar := true;
  explor.Actualizar;  //lee archivos
  Caption := 'Open Remote ...';
end;

procedure TfrmRemoteOpenDial.FormActivate(Sender: TObject);
begin
{  if actualizar then begin
    explor.Actualizar;  //lee archivos
    actualizar := false;
  end;}
end;

procedure TfrmRemoteOpenDial.butAceptarClick(Sender: TObject);
begin
  if explor.ItemSeleccionado = nil then begin
    msgexc('You must select a file.');
    exit;
  end;
  if explor.ItemSeleccionado.ImageIndex = IMG_CARPETA then begin
    msgexc('You must select a file.');
    exit;
  end;
  //se supone que se ha seleccionado un archivo
  archivo := explor.ItemSeleccionado.Caption;
  self.Close;
end;

procedure TfrmRemoteOpenDial.explorDblClickArch;
//DOble click en explorador
begin
  //se supone que se ha seleccionado un archivo
  archivo := explor.ItemSeleccionado.Caption;
  self.Close;
end;

end.

