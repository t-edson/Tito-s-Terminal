unit FrameCfgExpRem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ConfigFrame;

type

  { TfcExpRem }

  TfcExpRem = class(TCfgFrame)
    chkListDet: TCheckBox;
    chkMosOcul: TCheckBox;
    chkMosRut: TCheckBox;
    chkRefDesp: TCheckBox;
    edTpoMax: TEdit;
    Label1: TLabel;
  private
    { private declarations }
  public
    ListDet: boolean;
    MosRut : boolean;  //muestra la ruta actual
    MosOcul: boolean;
    RefDesp: boolean;
    TpoMax: integer;
    procedure Iniciar(secINI0: string);
  end;

implementation

{$R *.lfm}

{ TfcExpRem }

procedure TfcExpRem.Iniciar(secINI0: string);
begin
  secINI := secINI0;  //sección INI
  //crea las relaciones variable-control
  Asoc_Int_TEdit(@TpoMax, edTpoMax, 'TpoMax', 10, 1, 180);
  Asoc_Bol_TChkBox(@MosRut, chkMosRut, 'MosRut',true);
  Asoc_Bol_TChkBox(@ListDet, chkListDet, 'ListDet',true);
  Asoc_Bol_TChkBox(@MosOcul, chkMosOcul, 'MosOcul',false);
  Asoc_Bol_TChkBox(@RefDesp, chkRefDesp, 'RefDesp',true);
end;

end.

