{Unidad que implementa la ejecución de comandos de tipo: $EDIT, $EXPLORER, ...}
unit Comandos;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, MisUtils, FrameTabSession, Globales, FrameTabSessions,
  FormRemoteEditor, process;

  function GetCommand(lin: string; out comm, pars: string): boolean;
  function ExecSFTP(usr, pwd, ip, cmds: string): boolean;
  function ProcessCommand(lin: string; ses: TfraTabSession; tabSessions: TfraTabSessions): boolean;

implementation
function GetCommand(lin: string; out comm, pars: string): boolean;
{Analiza una linea para ver si contiene un comando como $EDITOR o $EXPLORER.
Si encuentra un comando, devuelve TRUE, el texto del comando en "comm" y el
parámetro en "pars".}
var
  p: SizeInt;
begin
  lin := trim(lin);
  if lin='' then exit(false);
  if lin[1] = '$' then begin
    p := pos(' ', lin);
    if p=0 then begin
      //Sin separacion
      comm := lin;
      pars := '';
      exit(true);
    end else  begin
      //Hay separación
      comm := copy(lin, 1, p-1);
      pars := copy(lin, p+1, length(lin));
      exit(true);
    end;
  end else exit(false);
end;

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
{Procesa una línea que debe contener un comando, si procesa el comando. Si no encuentra
un comando, devuelve FALSE.}
var
  comm, pars, res: string;
  edit: TfrmRemoteEditor;
begin
  if GetCommand(lin, comm, pars)  then begin
    //Es un comando
    if comm = ses.commandEx then begin   //Comando $EXPLORER
      if ses.explorMode = expBashComm then begin
        //Explorador Bash
        tabSessions.PageEvent('exec_explor', ses, res);  //Lanza explorador
      end else begin
        //Explorador de comando
        Exec(ses.exterEditor, '');
      end;
    end else if comm = ses.commandEd then begin
      if ses.editMode = edtLocal then begin
        //Editor local por comando
        //Exec(ses.exterEditor, '');
        frmRemoteEditor.Init(ses);
        frmRemoteEditor.Open(pars);
      end else if ses.editMode = edtBashComm then begin
        //Editor remoto por comandos bash
        tabSessions.PageEvent('exec_edit', ses, res);  //Lanza explorador
      end else if ses.editMode = edtRemotSFTP then begin
        //Editor remoto usando SFTP
        if pars<>'' then begin
          //Se espera que se haya indicado el archivo a editar
          frmRemoteEditor.Init(ses);
          frmRemoteEditor.Open(pars);
          //edit := TfrmRemoteEditor.Create(nil);
          //edit.Init(ses);
          //edit.Open(pars);
        end else begin
          Exec('notepad', '');
        end;
      end else begin
        MsgExc('Invalid option');
      end;
    end else begin
      //No se reconoce el comando.
      exit(false);
    end;
    exit(true);
  end else begin
    //No es comando
    exit(false)
  end;
end;


end.

