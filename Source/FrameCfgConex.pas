unit FrameCfgConex;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, Buttons, types, IniFiles,
  globales, Masks, UnTerminal, MisUtils
  ,ConfigFrame;   //para interceptar TFrame

type
  //Tipos de conexiones
  TTipCon = (
     TCON_TELNET,    //Conexión telnet común
     TCON_SSH,       //Conexión ssh
     TCON_SERIAL,    //Serial
     TCON_OTHER      //Otro proceso
  );

  { TfraConexion }

  TfraConexion = class(TFrame)
    cmbIP: TComboBox;
    GroupBox1: TGroupBox;
    lblOtro: TLabel;
    optSerial: TRadioButton;
    lblIP: TLabel;
    lblPort: TLabel;
    optTelnet: TRadioButton;
    optSSH: TRadioButton;
    optOtro: TRadioButton;
    optLF: TRadioButton;
    optCRLF: TRadioButton;
    txtOtro: TEdit;
    txtPort: TEdit;
    procedure UpdateChanges;
    procedure optOtroChange(Sender: TObject);
    procedure optSerialChange(Sender: TObject);
    procedure optSSHChange(Sender: TObject);
    procedure optTelnetChange(Sender: TObject);
    constructor Create(AOwner: TComponent) ; override;
    destructor Destroy; override;
  private
    proc: TConexProc;
    procedure Ocultar;
    { private declarations }
  public
    //parámetros
    Nombre    : string;   //nombre de la conexión
    Tipo      : TTipCon;  //tipo de conexión
    IP        : String;   //Direción IP (solo válido con el tipo TCON_TELNET Y TCON_SSH)
    Port      : String;   //Puerto (solo válido con el tipo TCON_TELNET Y TCON_SSH)
    Other     : String;   //Ruta del aplicativo (solo válido con el tipo TCON_OTHER)
    SendCRLF  : boolean;  //tipo de salto de línea
    ConRecientes: TStringList;  //Lista de conexiones recientes
    procedure AgregIPReciente(arch: string);
    procedure GrabarIP;
    procedure PropToWindow; override;
    procedure WindowToProp; override;
    procedure Iniciar(secINI0: string; proc0: TConexProc);
  end;

implementation
{$R *.lfm}
const MAX_ARC_REC = 5;  //si se cambia, actualizar ActualMenusReciente()

{ TfraConexion }
procedure TfraConexion.Iniciar(secINI0: string; proc0: TConexProc);
begin
  secINI := secINI0;  //sección INI
  proc := proc0;
  OnUpdateChanges:=@UpdateChanges;
  //crea las relaciones variable-control
  Asoc_Str_TEdit(@Port, txtPort, 'Port', '23');
  Asoc_Str_TEdit(@Other, txtOtro, 'Other', '');
  Asoc_Enum_TRadBut(@Tipo, SizeOf(TTipCon), [optTelnet,optSSH,optSerial,optOtro],'Tipo', 0);
  Asoc_Str_TCmbBox(@IP, cmbIP,'IP','192.168.1.1');
  Asoc_Str(@Nombre,'Nombre','');
  Asoc_StrList(@ConRecientes, 'Recient');
  Asoc_Bol_TRadBut(@SendCRLF, [optLF, optCRLF], 'TipSalto', false);
//  EjecMacro: boolean;
//  MacroIni : string;
//  Asoc_Bol_TChkB(@EjecMacro, chkEjecMacro, 'EjecMacro', false);
//  Asoc_Str_TEdit(@MacroIni, FileNameMacroIni,'MacroIni', '');
end;
procedure TfraConexion.AgregIPReciente(arch: string);
//agrega el nombre de un archivo reciente
var hay: integer; //bandera-índice
    i: integer;
begin
  //verifica si ya existe
  hay := -1;   //valor inicial
  for i:= 0 to ConRecientes.Count-1 do
    if ConRecientes[i] = arch then hay := i;
  if hay = -1 then  //no existe
    ConRecientes.Insert(0,arch)  //agrega al inicio
  else begin //ya existe
    ConRecientes.Delete(hay);     //lo elimina
    ConRecientes.Insert(0,arch);  //lo agrega al inicio
  end;
  while ConRecientes.Count>MAX_ARC_REC do  //mantiene tamaño máximo
    ConRecientes.Delete(MAX_ARC_REC);
end;
procedure TfraConexion.GrabarIP;
//Agrega la IP actual a la lista de archivos recientes
begin
  if trim(cmbIP.Text) <> '' then
    AgregIPReciente(cmbIP.Text);
end;
procedure TfraConexion.Ocultar;
//Oculta todos los controles de configuración
begin
  lblIP.Visible:=false;
  cmbIP.Visible:=false;
  lblPort.Visible:=false;
  txtPort.Visible:=false;
  lblOtro.Visible:=false;
  txtOtro.Visible:=false;
//  GroupBox1.Visible:=false;
end;

constructor TfraConexion.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConRecientes := TStringList.Create;  //crea lista
  //valores por defecto de la conexión actual
  Nombre:='Sesión1';
  Tipo := TCON_TELNET;
end;
destructor TfraConexion.Destroy;
begin
  ConRecientes.Free;
  inherited Destroy;
end;

procedure TfraConexion.optTelnetChange(Sender: TObject);
begin
  Ocultar;
  lblIP.Visible:=true;
  cmbIP.Visible:=true;
  lblPort.Visible:=true;
  txtPort.Visible:=true;
  txtPort.Text:='23';
  optLF.Checked:=true;  //por defecto
end;
procedure TfraConexion.optSSHChange(Sender: TObject);
begin
  Ocultar;
  lblIP.Visible:=true;
  cmbIP.Visible:=true;
  lblPort.Visible:=true;
  txtPort.Visible:=true;
  txtPort.Text:='22';
  optLF.Checked:=true;  //por defecto
end;
procedure TfraConexion.optSerialChange(Sender: TObject);
begin
  Ocultar;
//  GroupBox1.Visible:=true;
end;
procedure TfraConexion.optOtroChange(Sender: TObject);
begin
  Ocultar;
  lblOtro.Visible:=true;
  txtOtro.Visible:=true;
//  GroupBox1.Visible:=true;
end;

procedure TfraConexion.UpdateChanges;
//Configura el proceso de acuerdo a los parámetros de la conexión.
begin
  proc.sendCRLF:=sendCRLF;   //configura salto de línea
  case Tipo of
  TCON_TELNET: begin
      if Port='' then begin
        proc.progPath:='plink -telnet ' + IP;
        proc.progParam:='';
      end else begin
        proc.progPath:='plink -telnet ' + ' -P '+ Port + ' ' + IP;
        proc.progParam:='';
      end;
    end;
  TCON_SSH: begin
      if Port='' then begin
        proc.progPath:='plink -ssh ' + IP;
        proc.progParam:='';
      end else begin
        proc.progPath:='plink -ssh '+' -P '+ Port + ' ' + IP;
        proc.progParam:='';
      end;
    end;
//  TCON_SERIAL: begin
//      proc.Open('plink -serial ' + IP,'');
//      edTerm.Lines[0] := 'Opening Serial ...';
//    end;
  TCON_OTHER: begin
      proc.progPath:=Other;
      proc.progParam:='';
//      edTerm.Lines[0] := 'Opening Process ...';
    end;
  end;
end;

procedure TfraConexion.PropToWindow;
begin
  //carga las IP's recientes
  cmbIP.Clear;
  cmbIP.Items.AddStrings(ConRecientes);
  inherited;
end;

procedure TfraConexion.WindowToProp;
begin
  //Aquí podemos validar antes de grabar
  if cmbIP.Text = '' then begin
    MsjErr:='No se ha definido al dirección IP de la conexión.';
    exit;
  end;
  if not MatchesMask(cmbIP.Text, '*.*.*.*') then begin
    MsjErr:='Error en IP';
    exit;
  end;
  //solo si no hay errores
  inherited WindowToProp;
end;

end.

