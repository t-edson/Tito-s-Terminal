unit FormExpRemoto;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  FrameExpRemoto, strutils, FormEditRemoto, MisUtils;

type

  { TfrmExpRemoto }

  TfrmExpRemoto = class(TForm)
    procedure explorDblClickArch;
    procedure explorEnter(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    explor: TfraExpRemoto;
    actualizar: boolean;
  end;

var
  frmExpRemoto: TfrmExpRemoto;

implementation
{$R *.lfm}

{ TfrmExpRemoto }

procedure TfrmExpRemoto.FormCreate(Sender: TObject);
begin
  explor:= TfraExpRemoto.Create(self);
  explor.Parent := self;
  explor.Align:=alClient;
  explor.OnDblClickArch:=@explorDblClickArch;
//  explor.OnEnter:=@explorEnter;
end;
procedure TfrmExpRemoto.FormDestroy(Sender: TObject);
begin
  explor.Destroy;
end;

procedure TfrmExpRemoto.FormShow(Sender: TObject);
begin
  Caption:= 'Remote Explorer';
  actualizar := true;
end;

procedure TfrmExpRemoto.explorEnter(Sender: TObject);
begin
   msgbox('Enter');
end;

procedure TfrmExpRemoto.explorDblClickArch;
var
  it: TListItem;
begin
  it := explor.ItemSeleccionado;
  if it = nil then exit;
  if AnsiEndsText('.txt',it.Caption)
     or AnsiEndsText('.sql',it.Caption)
     or AnsiEndsText('.sh',it.Caption)
     or AnsiEndsText('.py',it.Caption)
     or AnsiEndsText('.pas',it.Caption)
     then begin
     //tipos conocidos, se editan
     frmEditRemoto.AbrirRemoto(it.Caption);
  end;
end;

procedure TfrmExpRemoto.FormActivate(Sender: TObject);
begin
  if actualizar then begin
    explor.Actualizar;  //lee archivos
    actualizar := false;
  end;
end;

end.

