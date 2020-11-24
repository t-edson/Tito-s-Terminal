unit FormConexRapida;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, FrameCfgConex, Globales;

type

  { TfrmConexRap }

  TfrmConexRap = class(TForm)
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
    procedure SetLanguage(lang: string);
  end;

var
  frmConexRap: TfrmConexRap;

implementation

{$R *.lfm}

{ TfrmConexRap }

procedure TfrmConexRap.btnAceptarClick(Sender: TObject);
begin
  //lee parámetros
  ip := cmbHost.Text;
  if optTelnet.Checked then tipo := TCON_TELNET;
  if optSSH.Checked    then tipo := TCON_SSH;
  Cancel := false;
  Self.Hide;
end;
procedure TfrmConexRap.btnCancelarClick(Sender: TObject);
begin
  ip := '';
  Cancel := true;
  self.Hide;
end;

procedure TfrmConexRap.FormShow(Sender: TObject);
begin
  Cancel := true;
  cmbHost.Clear;
  optTelnet.Checked:=true;
{  if Config.ConRecientes.Count > 0 then begin
    cmbHost.Items.AddStrings(Config.ConRecientes);
    cmbHost.ItemIndex:=0;  //selecciona al primero
  end;}
end;

procedure TfrmConexRap.SetLanguage(lang: string);
//Rutina de traducción
begin
  case lowerCase(lang) of
  'es': begin
      Self.Caption :='Conexión Rápida';
    end;
  'en': begin
      Self.Caption :='Quick Connection';
    end;
  end;
end;

end.

