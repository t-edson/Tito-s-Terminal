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
    lblRutScript: TLabel;
    lblRutMac: TLabel;
    lblRutLeng: TLabel;
  private
  public
    UltScript: string;   //último script editado
    AbrirUltScr: boolean;
    Scripts  : string;
    Macros   : string;
    Lenguajes: string;
    procedure Iniciar(secINI0: string);
    procedure ReadFileToProp(var arcINI: TIniFile); override;
    procedure SetLanguage(lang: string);
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
  Asoc_Bol_TChkBox(@AbrirUltScr, chkAbrirUltScr, 'AbrirUltScr', true);
  Asoc_Str_TEditButton(@Scripts, DirectoryEdit1,'Scripts', rutScripts);
  Asoc_Str_TEditButton(@Macros, DirectoryEdit2,'Macros', rutMacros);
  Asoc_Str_TEditButton(@Lenguajes, DirectoryEdit3,'Lenguajes', rutLenguajes);
end;

procedure TfraCfgRutArc.ReadFileToProp(var arcINI: TIniFile);
begin
  inherited ReadFileToProp(arcINI);
  //valida las rutas leidas
  if not DirectoryExists(Scripts) then begin
    MsgExc('No se encuentra carpeta: %s',[Scripts]);
    Scripts := rutScripts;
  end;
  if not DirectoryExists(Macros) then begin
    MsgExc('No se encuentra carpeta: %s', [Macros]);
    Macros := rutMacros;
  end;
  if not DirectoryExists(Lenguajes) then begin
    MsgExc('No se encuentra carpeta: %s', [Lenguajes]);
    Lenguajes := rutLenguajes;
  end;
end;

procedure TfraCfgRutArc.SetLanguage(lang: string);
//Rutina de traducción
begin
  case lowerCase(lang) of
  'es': begin
      lblRutScript.Caption:='Ruta de &Scripts:';
      lblRutMac.Caption:='Ruta de &Macros:';
      lblRutLeng.Caption:='Ruta de &Lenguajes:';
      chkAbrirUltScr.Caption:='&Abrir último archivo editado, al iniciar.';
      dicClear;  //ya está en español
    end;
  'en': begin
      lblRutScript.Caption:='&Scripts path:';
      lblRutMac.Caption:='&Macros path:';
      lblRutLeng.Caption:='&Languages path:';
      chkAbrirUltScr.Caption:='&Open last edited file on Start.';
      //diccionario
      dicSet('No se encuentra carpeta: %s','Folder not found: %s');
    end;
  end;
end;

end.

