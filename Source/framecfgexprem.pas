unit FrameCfgExpRem;

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
    procedure SetLanguage(lang: string);
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

procedure TfcExpRem.SetLanguage(lang: string);
//Rutina de traducción
begin
  case lowerCase(lang) of
  'es': begin
      Label1.Caption:='Tiempo máximo de espera al terminal (seg):';
      chkMosRut.Caption:='Mostrar Información de Ruta Actual';
      chkListDet.Caption:='Mostrar lista detallada de archivos.';
      chkMosOcul.Caption:='Mostrar archivos ocultos.';
      chkRefDesp.Caption:='Refrescar lista, después de cada operación.';
  end;
  'en': begin
      Label1.Caption:='Time for waiting terminal (seconds):';
      chkMosRut.Caption:='Show currente path';
      chkListDet.Caption:='Show detailed list of files.';
      chkMosOcul.Caption:='Show hidden files.';
      chkRefDesp.Caption:='Refresh list, after any operation.';
    end;
  end;
end;

end.

