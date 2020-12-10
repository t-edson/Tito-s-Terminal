unit FormRemoteExplor;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  FrameExpRemoto, strutils, FormRemoteEditor, FrameTabSession, MisUtils;

type

  { TfrmRemoteExplor }

  TfrmRemoteExplor = class(TForm)
    procedure explorDblClickArch;
    procedure explorEnter(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    ses: TfraTabSession;
    explor: TfraExpRemoto;
    actualizar: boolean;
  public
    procedure Init(ses0: TfraTabSession);
  end;

var
  frmRemoteExplor: TfrmRemoteExplor;

implementation
{$R *.lfm}

{ TfrmRemoteExplor }

procedure TfrmRemoteExplor.FormCreate(Sender: TObject);
begin
  explor:= TfraExpRemoto.Create(self);
  explor.Parent := self;
  explor.Align:=alClient;
  explor.OnDblClickArch:=@explorDblClickArch;
//  explor.OnEnter:=@explorEnter;
end;
procedure TfrmRemoteExplor.FormDestroy(Sender: TObject);
begin
  explor.Destroy;
end;

procedure TfrmRemoteExplor.FormShow(Sender: TObject);
begin
  Caption:= 'Remote Explorer';
  actualizar := true;
end;

procedure TfrmRemoteExplor.explorEnter(Sender: TObject);
begin
   msgbox('Enter');
end;

procedure TfrmRemoteExplor.explorDblClickArch;
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
     then
  begin
     //Los tipos conocidos, se editan.
    //Se abre el editor en el modo definido en la sesión.
    frmRemoteEditor.Init(ses);
    frmRemoteEditor.Open(it.Caption);
  end;
end;

procedure TfrmRemoteExplor.FormActivate(Sender: TObject);
begin
  if actualizar then begin
    explor.Actualizar;  //lee archivos
    actualizar := false;
  end;
end;

procedure TfrmRemoteExplor.Init(ses0: TfraTabSession);
begin
  ses := ses0;
end;

end.

