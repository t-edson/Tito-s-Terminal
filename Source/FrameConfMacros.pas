unit FrameConfMacros;

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
  end;

implementation

{$R *.lfm}

procedure TfcMacros.Iniciar(secINI0: string);
begin
  secINI := secINI0;  //sección INI
  //crea las relaciones variable-control
  Asoc_Int_TEdit(@TpoMax, edTpoMax, 'TpoMax', 10, 1, 180);
  Asoc_Bol_TChkB(@marLin, chkMarLin, 'MarLin', false);
end;

end.

