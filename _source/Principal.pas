unit Principal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, FormPrincipal;

type

  { TForm1 }

  TForm1 = class(TForm)
    procedure FormActivate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormActivate(Sender: TObject);
begin
//  frmVentSesion.Show;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  frmVentSesion.Show;
  frmVentSesion.InicSesion;
end;

end.

