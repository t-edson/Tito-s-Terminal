{Unidad que implementa la ejecución de comandos de tipo: $EDIT, $EXPLORER, ...}
unit Comandos;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, MisUtils, FrameTabSession, Globales, FrameTabSessions,
  process, Parser;

const INI_COMM = '%';  //Initial character for commands

  function ExecSFTP(usr, pwd, ip, cmds: string): boolean;
  function ProcessCommand(lin: string; ses: TfraTabSession; tabSessions: TfraTabSessions): boolean;

implementation
function ExecSFTP(usr, pwd, ip, cmds: string): boolean;
//Ejecuta el cliente SFTP. Devuelve FALSE si hubo error
var
  p : TProcess;   //el proceso a manejar
begin
  Result := true;
  StringToFile(cmds,  'killme.tmp');  //Ceea archivo en blanco.
  p := TProcess.Create(nil); //Crea proceso
  p.Options:= p.Options + [poNoConsole, poWaitOnExit];
  p.Executable:='psftp.exe';
  p.Parameters.Clear;
  p.Parameters.Add(usr+ '@' + ip);
  p.Parameters.Add('-pw');
  p.Parameters.Add(pwd);
  p.Parameters.Add('-b');
  p.Parameters.Add('killme.tmp');
  try
    p.Execute;
  except
    Result := false;
    MsgBox('Fallo al iniciar aplicativo: '+ p.Executable);;
  end;
  p.Free;
  DeleteFile('killme.tmp');  //Limpia la casa
end;

function ProcessCommand(lin: string; ses: TfraTabSession; tabSessions: TfraTabSessions): boolean;
{Procesa una línea que debe contener un comando. Si no encuentra un comando, devuelve
FALSE.}
var
  linCommand: TStringList;
begin
  if copy(lin, 1, 1) = INI_COMM then begin    //Es un comando.
    //Comando equivalente al lenguaje de macros
    linCommand := TStringList.Create;
    linCommand.Text := copy(lin, 2, length(lin));
    cxp.Compilar('current file', linCommand);
    if cxp.HayError then begin
      cxp.ShowError;
    end;
    linCommand.Destroy;
    exit(true);
  end else begin   //No se reconoce como comando.
    exit(false);
  end;
end;


end.

