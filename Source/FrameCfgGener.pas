{Frame para configurar las propiedades generales}
unit FrameCfgGener;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls
  ,ConfigFrame;   //para interceptar TFrame

type

  { TfraCfgGener }

  TfraCfgGener = class(TFrame)
  private
    { private declarations }
  public
    { public declarations }
    procedure Iniciar(secINI0: string); //Inicia el frame
  end;

implementation

{$R *.lfm}

{ TfraCfgGener }

procedure TfraCfgGener.Iniciar(secINI0: string);
begin
  secINI := secINI0;  //sección INI
end;

end.

