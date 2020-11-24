unit FrameCfgConex;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, Buttons,
  globales, Masks, UnTerminal, MisUtils, Graphics, Dialogs, ExtCtrls,
  ConfigFrame;

type

  { TfraConexion }

  TfraConexion = class(TCfgFrame)
    cmbIP: TComboBox;
    cmbSerPort: TComboBox;
    lblIP: TLabel;
    lblOtro: TLabel;
    lblPort: TLabel;
    lblSerCfg: TLabel;
    lblSerPort: TLabel;
    optOtro: TRadioButton;
    optSerial: TRadioButton;
    optSSH: TRadioButton;
    optTelnet: TRadioButton;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    txtOtro: TEdit;
    txtPort: TEdit;
    txtSerCfg: TEdit;
    procedure UpdateChanges;
    procedure optOtroChange(Sender: TObject);
    procedure optSerialChange(Sender: TObject);
    procedure optSSHChange(Sender: TObject);
    procedure optTelnetChange(Sender: TObject);
  private
    proc: TConsoleProc;
    procedure Ocultar;
  public
    //parámetros
    Tipo      : TTipCon;  //tipo de conexión
    IP        : String;   //Direción IP (solo válido con el tipo TCON_TELNET Y TCON_SSH)
    Port      : String;   //Puerto (solo válido con el tipo TCON_TELNET Y TCON_SSH)
    Command   : string;   //comando a ejecutar en el proceso
    Other     : String;   //Ruta del aplicativo (solo válido con el tipo TCON_OTHER)
    LineDelimSend : TUtLineDelSend;  //Tipo de delimitaodr de línea a enviar
    LineDelimRecv : TUtLineDelRecv;  //Tipo de delimitaodr de línea a recibir
    ConRecientes: TStringList;  //Lista de conexiones recientes
    procedure AgregIPReciente(arch: string);
    procedure GrabarIP;
    procedure PropToWindow; override;
    procedure WindowToProp; override;
    procedure Iniciar(secINI0: string; proc0: TConsoleProc);
    procedure SetLanguage(lang: string);
    constructor Create(AOwner: TComponent) ; override;
    destructor Destroy; override;
  end;

implementation
{$R *.lfm}
const MAX_ARC_REC = 5;  //si se cambia, actualizar ActualMenusReciente()

{ TfraConexion }
procedure TfraConexion.Iniciar(secINI0: string; proc0: TConsoleProc);
begin
  secINI := secINI0;  //sección INI
  proc := proc0;
  OnUpdateChanges:=@UpdateChanges;
  //crea las relaciones variable-control
  Asoc_Str_TEdit(@Port, txtPort, 'Port', '23');
  Asoc_Str_TEdit(@Other, txtOtro, 'Other', '');
  Asoc_Enum_TRadBut(@Tipo, SizeOf(TTipCon), [optTelnet,optSSH,optSerial,optOtro],'Tipo', 0);
  Asoc_Str_TCmbBox(@IP, cmbIP,'IP','192.168.1.1');
  Asoc_StrList(@ConRecientes, 'Recient');
  Asoc_Enum_TRadGroup(@LineDelimSend, SizeOf(LineDelimSend), RadioGroup1, 'LineDelimSnd', 0);
  Asoc_Enum_TRadGroup(@LineDelimRecv, SizeOf(LineDelimRecv), RadioGroup2, 'LineDelimRcv', 2);
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
  lblSerPort.Visible:=false;
  cmbSerPort.Visible:=false;
  lblSerCfg.Visible:=false;
  txtSerCfg.Visible:=false;
end;

constructor TfraConexion.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ConRecientes := TStringList.Create;  //crea lista
  //valores por defecto de la conexión actual
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
  RadioGroup1.ItemIndex:=2;
end;
procedure TfraConexion.optSSHChange(Sender: TObject);
begin
  Ocultar;
  lblIP.Visible:=true;
  cmbIP.Visible:=true;
  lblPort.Visible:=true;
  txtPort.Visible:=true;
  txtPort.Text:='22';
  RadioGroup1.ItemIndex:=2;
end;
procedure TfraConexion.optSerialChange(Sender: TObject);
begin
  Ocultar;
  lblSerPort.Visible:=true;
  cmbSerPort.Visible:=true;
  lblSerCfg.Visible:=true;
  txtSerCfg.Visible:=true;
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
  case Tipo of
  TCON_TELNET: begin
      if Port='' then begin
        Command:='plink -telnet ' + IP;
      end else begin
        Command:='plink -telnet ' + ' -P '+ Port + ' ' + IP;
      end;
    end;
  TCON_SSH: begin
      if Port='' then begin
        Command:='plink -ssh ' + IP;
      end else begin
        Command:='plink -ssh '+' -P '+ Port + ' ' + IP;
      end;
    end;
  TCON_SERIAL: begin
      Command:='plink -serial ' + cmbSerPort.Text + ' -sercfg '+txtSerCfg.Text;
//      edTerm.Lines[0] := 'Opening Serial ...';
    end;
  TCON_OTHER: begin
      Command:=Other;
//      edTerm.Lines[0] := 'Opening Process ...';
    end;
  end;
  proc.LineDelimSend := LineDelimSend;   //configura salto de línea
  proc.LineDelimRecv := LineDelimRecv;
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
    MsjErr:=dic('No se ha definido al dirección IP de la conexión.');
    exit;
  end;
  if not MatchesMask(cmbIP.Text, '*.*.*.*') then begin
    MsjErr:=dic('Error en IP');
    exit;
  end;
  //solo si no hay errores
  inherited WindowToProp;
end;

procedure TfraConexion.SetLanguage(lang: string);
//Rutina de traducción
begin
  case lowerCase(lang) of
  'es': begin
      optOtro.Caption:='Otro';
      lblPort.Caption:='Puerto';
      lblOtro.Caption:='Aplicativo:';
      RadioGroup1.Caption:='Salto de Línea (A enviar)';
      RadioGroup2.Caption:='Salto de Línea (A recibir)';
      lblSerPort.Caption:='Puerto Serial:';
      lblSerCfg.Caption:='Configuración';
      dicClear;  //ya está en español
    end;
  'en': begin
      optOtro.Caption:='Other';
      lblPort.Caption:='Port';
      lblOtro.Caption:='Program:';
      RadioGroup1.Caption:='Line Delimiter (To Send)';
      RadioGroup2.Caption:='Line Delimiter (To Receive)';
      lblSerPort.Caption:='Serial Port:';
      lblSerCfg.Caption:='Configuration';
      //diccionario
      dicSet('No se ha definido al dirección IP de la conexión.','No IP address has been defined');
      dicSet('Error en IP','IP error');
    end;
  end;
end;


end.

