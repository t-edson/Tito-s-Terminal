unit FormAcercaDe;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Globales;

type

  { TfrmAcercaDe }

  TfrmAcercaDe = class(TForm)
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  frmAcercaDe: TfrmAcercaDe;

implementation

{$R *.lfm}

{ TfrmAcercaDe }

procedure TfrmAcercaDe.FormCreate(Sender: TObject);
begin
  Caption := 'Acerca de...';
  Label1.Caption := NOM_PROG + ' ' + VER_PROG;
  Label2.Caption := 'Por Tito Hinostroza' + LineEnding +
                    'Lima - Perú 2017' + LineEnding +
                    LineEnding +
                    'Derechos Reservados';
end;

end.

