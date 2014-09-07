unit FormSelFuente;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ButtonPanel;

type

  TTipFuente = (tfTod, tfSel, tfLin);
  { TfrmSelFuente }

  TfrmSelFuente = class(TForm)
    ButtonPanel1: TButtonPanel;
    Label1: TLabel;
    optTod: TRadioButton;
    optSel: TRadioButton;
    optLin: TRadioButton;
    procedure CancelButtonClick(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    cancelado: boolean;
  end;

var
  frmSelFuente: TfrmSelFuente;
implementation

{$R *.lfm}

{ TfrmSelFuente }

procedure TfrmSelFuente.OKButtonClick(Sender: TObject);
begin
  cancelado := false;
  frmSelFuente.Close;
end;

procedure TfrmSelFuente.CancelButtonClick(Sender: TObject);
begin
  cancelado := true;
  frmSelFuente.Close;
end;


end.

