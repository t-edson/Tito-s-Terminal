unit FrameCfgRutasCnx;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, EditBtn, IniFiles,
  MisUtils ,ConfigFrame;

type

  { TfraCfgRutArc }

  TfraCfgRutArc = class(TCfgFrame)
    chkOpenLast: TCheckBox;
    DirectoryEdit1: TDirectoryEdit;
    DirectoryEdit2: TDirectoryEdit;
    DirectoryEdit3: TDirectoryEdit;
    lblRutLeng: TLabel;
    lblRutMac: TLabel;
    lblRutScript: TLabel;
  private
  public
    UltScript: string;   //último script editado
    AbrirUltScr: boolean;
    Scripts  : string;
    Macros   : string;
    Lenguajes: string;
    procedure Iniciar(secINI0: string);
    procedure ReadFileToProp(var arcINI: TIniFile); override;
  end;

implementation
uses globales;
{$R *.lfm}

{ TfraCfgRutArc }

procedure TfraCfgRutArc.Iniciar(secINI0: string);
begin
  secINI := secINI0;  //sección INI
  //crea las relaciones variable-control
  Asoc_Str(@UltScript,'UltScript','');
  Asoc_Bol_TChkBox(@AbrirUltScr, chkOpenLast, 'AbrirUltScr', true);
  Asoc_Str_TEditButton(@Scripts, DirectoryEdit1,'Scripts', patScripts);
  Asoc_Str_TEditButton(@Macros, DirectoryEdit2,'Macros', patMacros);
  Asoc_Str_TEditButton(@Lenguajes, DirectoryEdit3,'Lenguajes', patSyntax);
end;

procedure TfraCfgRutArc.ReadFileToProp(var arcINI: TIniFile);
begin
  inherited ReadFileToProp(arcINI);
  //valida las rutas leidas
  if not DirectoryExists(Scripts) then begin
    MsgExc('Folder not found: %s',[Scripts]);
    Scripts := patScripts;
  end;
  if not DirectoryExists(Macros) then begin
    MsgExc('Folder not found: %s', [Macros]);
    Macros := patMacros;
  end;
  if not DirectoryExists(Lenguajes) then begin
    MsgExc('Folder not found: %s', [Lenguajes]);
    Lenguajes := patSyntax;
  end;
end;

end.

