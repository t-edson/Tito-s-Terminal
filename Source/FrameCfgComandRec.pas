unit FrameCfgComandRec;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, Spin
  ,ConfigFrame;   //para interceptar TFrame

type

  TTipEnvio = (teComando, teArchivo);

  { TfraComandRec }

  TfraComandRec = class(TFrame)
    cmdProbar: TButton;
    chkActivo: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    optComando: TRadioButton;
    optScript: TRadioButton;
    speTempo: TSpinEdit;
    txtComando: TEdit;
    txtArchivo: TEdit;
    procedure chkActivoChange(Sender: TObject);
    procedure cmdProbarClick(Sender: TObject);
  public
    Activar : boolean;
    Tempo   : integer;
    tipEnvio: TTipEnvio;
    tipEnvio0: TTipEnvio;  //temporal
    Comando : string;
    Comando0 : string;
    Archivo : string;
    Archivo0 : string;
    OnProbar: procedure of object;
    procedure Iniciar(secINI0: string);
  end;

implementation

{$R *.lfm}

{ TfraComandRec }

procedure TfraComandRec.cmdProbarClick(Sender: TObject);
//Prueba la configuración actual
begin
  //guarda estado actual, para no perderlo
  tipEnvio0 := tipEnvio;
  Comando0 := Comando;
  Archivo0 := Archivo;
  WindowToProp;  //mueve valores de controles a variables
  //lama al evento para probar la temporización
  OnProbar;
  //Retorna valores
  tipEnvio := tipEnvio0;
  Comando := Comando0;
  Archivo := Archivo0;
end;

procedure TfraComandRec.chkActivoChange(Sender: TObject);
begin
  speTempo.Enabled:=chkActivo.checked;
  label1.Enabled:=chkActivo.checked;
  GroupBox1.Enabled:=chkActivo.checked;
  cmdProbar.Enabled:=chkActivo.checked;
end;

procedure TfraComandRec.Iniciar(secINI0: string);
begin
  secINI := secINI0;  //sección INI
  //crea las relaciones variable-control
  Asoc_Bol_TChkB(@Activar, chkActivo, 'Activar', false);
  Asoc_Int_TSpnEdi(@Tempo, speTempo, 'Tempo', 5, 1, 120);
  Asoc_Enum_TRadBut(@tipEnvio, SizeOf(tipEnvio),[optComando,optScript],'tipEnvio',0);
  Asoc_Str_TEdit(@Comando, txtComando, 'Comando','');
  Asoc_Str_TEdit(@Archivo, txtArchivo, 'Archivo','');
  cmdProbar.OnClick:=@cmdProbarClick;  //evento
  chkActivoChange(self);  //para actualizar
end;

end.

