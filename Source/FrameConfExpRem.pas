unit frameConfExpRem;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls
  ,ConfigFrame;   //para interceptar TFrame

type

  { TfcExpRem }

  TfcExpRem = class(TFrame)
    chkListDet: TCheckBox;
    chkMosRut: TCheckBox;
    chkMosOcul: TCheckBox;
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
  Asoc_Bol_TChkB(@MosRut, chkMosRut, 'MosRut',true);
  Asoc_Bol_TChkB(@ListDet, chkListDet, 'ListDet',true);
  Asoc_Bol_TChkB(@MosOcul, chkMosOcul, 'MosOcul',false);
  Asoc_Bol_TChkB(@RefDesp, chkRefDesp, 'RefDesp',true);
end;

end.

