unit FrameCfgRutasCnx;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, EditBtn, IniFiles
  ,MisUtils ,ConfigFrame;

type

  { TfraCfgRutArc }

  TfraCfgRutArc = class(TFrame)
    chkAbrirUltScr: TCheckBox;
    DirectoryEdit1: TDirectoryEdit;
    DirectoryEdit2: TDirectoryEdit;
    DirectoryEdit3: TDirectoryEdit;
    mnRutScript: TLabel;
    mnRutScript1: TLabel;
    mnRutScript2: TLabel;
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
  Asoc_Bol_TChkB(@AbrirUltScr, chkAbrirUltScr, 'AbrirUltScr', true);
  Asoc_Str_TEdit(@Scripts, DirectoryEdit1,'Scripts', rutScripts);
  Asoc_Str_TEdit(@Macros, DirectoryEdit2,'Macros', rutMacros);
  Asoc_Str_TEdit(@Lenguajes, DirectoryEdit3,'Lenguajes', rutLenguajes);
end;

procedure TfraCfgRutArc.ReadFileToProp(var arcINI: TIniFile);
begin
  inherited ReadFileToProp(arcINI);
  //valida las rutas leidas
  if not DirectoryExists(Scripts) then begin
    MsgExc('No se encuentra carpeta: '+Scripts);
    Scripts := rutScripts;
  end;
  if not DirectoryExists(Macros) then begin
    MsgExc('No se encuentra carpeta: '+Macros);
    Macros := rutMacros;
  end;
  if not DirectoryExists(Lenguajes) then begin
    MsgExc('No se encuentra carpeta: '+Lenguajes);
    Lenguajes := rutLenguajes;
  end;
end;

end.

