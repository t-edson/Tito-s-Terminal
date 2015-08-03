unit FrameCfgMacros;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls
  ,ConfigFrame;   //para interceptar TFrame

type

  { TfcMacros }

  TfcMacros = class(TFrame)
    chkMarLin: TCheckBox;
    edTpoMax: TEdit;
    Label1: TLabel;
  private
    { private declarations }
  public
    TpoMax : integer;
    marLin : boolean;
    procedure Iniciar(secINI0: string);
    procedure SetLanguage(lang: string);
  end;

implementation

{$R *.lfm}

procedure TfcMacros.Iniciar(secINI0: string);
begin
  secINI := secINI0;  //sección INI
  //crea las relaciones variable-control
  Asoc_Int_TEdit(@TpoMax, edTpoMax, 'TpoMax', 10, 1, 180);
  Asoc_Bol_TChkBox(@marLin, chkMarLin, 'MarLin', false);
end;

procedure TfcMacros.SetLanguage(lang: string);
//Rutina de traducción
begin
  case lowerCase(lang) of
  'es': begin
      chkMarLin.Caption:='Marcar línea que se está ejecutando.';
      Label1.Caption:='Tiempo de espera máx. (seg)';
    end;
  'en': begin
      chkMarLin.Caption:='Highlight line that is running.';
      Label1.Caption:='Timeout. (seconds)';
    end;
  end;
end;

end.

