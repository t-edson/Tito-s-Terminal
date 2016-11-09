unit FrameCfgComandRec;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, Spin,
  ConfigFrame;

type

  TTipEnvio = (teComando, teArchivo);

  { TfraComandRec }

  TfraComandRec = class(TCfgFrame)
    chkActivo: TCheckBox;
    cmdProbar: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    optComando: TRadioButton;
    optScript: TRadioButton;
    speTempo: TSpinEdit;
    txtArchivo: TEdit;
    txtComando: TEdit;
    procedure chkActivoChange(Sender: TObject);
    procedure cmdProbarClick(Sender: TObject);
  private
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
    procedure SetLanguage(lang: string);
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
  Asoc_Bol_TChkBox(@Activar, chkActivo, 'Activar', false);
  Asoc_Int_TSpinEdit(@Tempo, speTempo, 'Tempo', 5);
  Asoc_Enum_TRadBut(@tipEnvio, SizeOf(tipEnvio),[optComando,optScript],'tipEnvio',0);
  Asoc_Str_TEdit(@Comando, txtComando, 'Comando','');
  Asoc_Str_TEdit(@Archivo, txtArchivo, 'Archivo','');
  cmdProbar.OnClick:=@cmdProbarClick;  //evento
  chkActivoChange(self);  //para actualizar
end;

procedure TfraComandRec.SetLanguage(lang: string);
//Rutina de traducción
begin
  case lowerCase(lang) of
  'es': begin
      chkActivo.Caption:='Enviar Comando &Recurrente';
      cmdProbar.Caption:='&Probar';
      Label1.Caption:='Tiempo entre envíos (min):';
      GroupBox1.Caption:='&Enviar';
      optComando.Caption:='&Comando:';
      optScript.Caption:='&Archivo de comandos:';
    end;
  'en': begin
      chkActivo.Caption:='Send &Recurring Command';
      cmdProbar.Caption:='&Test';
      Label1.Caption:='&Interval of sending (min):';
      GroupBox1.Caption:='&Send';
      optComando.Caption:='&Command:';
      optScript.Caption:='&Command file:';
    end;
  end;
end;

end.

