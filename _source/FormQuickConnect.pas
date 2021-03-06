unit FormQuickConnect;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, Globales;

type

  { TfrmQuickConnect }

  TfrmQuickConnect = class(TForm)
    btnAceptar: TBitBtn;
    btnCancelar: TBitBtn;
    cmbHost: TComboBox;
    Label1: TLabel;
    optTelnet: TRadioButton;
    optSSH: TRadioButton;
    procedure btnAceptarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    Cancel: boolean;
    //parámetros de conexión
    ip   : string;     //dirección IP
    tipo : TTipCon;    //tipo de conexión
  end;

var
  frmQuickConnect: TfrmQuickConnect;

implementation

{$R *.lfm}

{ TfrmQuickConnect }

procedure TfrmQuickConnect.btnAceptarClick(Sender: TObject);
begin
  //lee parámetros
  ip := cmbHost.Text;
  if optTelnet.Checked then tipo := TCON_TELNET;
  if optSSH.Checked    then tipo := TCON_SSH;
  Cancel := false;
  Self.Hide;
end;
procedure TfrmQuickConnect.btnCancelarClick(Sender: TObject);
begin
  ip := '';
  Cancel := true;
  self.Hide;
end;

procedure TfrmQuickConnect.FormShow(Sender: TObject);
begin
  Cancel := true;
  cmbHost.Clear;
  cmbHost.Text := '192.168.1.1';
  optTelnet.Checked:=true;
{  if Config.ConRecientes.Count > 0 then begin
    cmbHost.Items.AddStrings(Config.ConRecientes);
    cmbHost.ItemIndex:=0;  //selecciona al primero
  end;}
end;

end.

