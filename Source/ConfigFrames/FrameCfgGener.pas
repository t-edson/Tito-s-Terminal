unit FrameCfgGener;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ConfigFrame;

type

  { TfraCfgGener }

  TfraCfgGener = class(TCfgFrame)
  private
    { private declarations }
  public
    procedure Iniciar(secINI0: string); //Inicia el frame
    procedure SetLanguage(lang: string);
  end;

implementation

{$R *.lfm}

{ TfraCfgGener }

procedure TfraCfgGener.Iniciar(secINI0: string);
begin
  secINI := secINI0;  //sección INI
end;

procedure TfraCfgGener.SetLanguage(lang: string);
//Rutina de traducción
begin
  //no tiene controles ni mensajes
end;

end.

