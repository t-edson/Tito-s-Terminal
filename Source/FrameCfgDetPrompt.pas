unit frameCfgDetPrompt;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, IniFiles, uResaltTerm,
  SynEdit, SynEditHighlighter, UnTerminal
  ,ConfigFrame;   //para interceptar TFrame

type
  { TfraDetPrompt }

  TfraDetPrompt = class(TFrame)
    chkDetParcial: TCheckBox;
    chkDetecPrompt: TCheckBox;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    txtCadFin: TEdit;
    txtCadIni: TEdit;
    procedure chkDetecPromptChange(Sender: TObject);
  private
    ed: TSynEdit;
    proc: TConexProc;
  public
    //parámetros de detección de prompt
    detecPrompt: boolean;
    prIni     : string;
    prFin     : string;
    DetParcial : boolean;
    procedure Iniciar(secINI0: string; ed0: TSynEdit; proc0: TConexProc); //Inicia el frame
    procedure ConfigCambios;
  end;

implementation

{$R *.lfm}

{ TfraDetPrompt }

procedure TfraDetPrompt.Iniciar(secINI0: string; ed0: TSynEdit; proc0: TConexProc);
//necesita referencias al editor y al terminal para actualizar la detección de prompt
begin
  secINI := secINI0;  //sección INI
  //asigna referencia necesarias
  ed := ed0;
  proc := proc0;
  OnUpdateChanges := @ConfigCambios;  //manejador de cambios
  //crea las relaciones variable-control
  Asoc_Bol_TChkB(@detecPrompt, chkDetecPrompt,'DetecPrompt', false);
  Asoc_Str_TEdit(@prIni,txtCadIni,'cadIni','');
  Asoc_Str_TEdit(@prFin,txtCadFin,'cadFin','');
  Asoc_Bol_TChkB(@DetParcial, chkDetParcial,'DetParcial', false);
end;

procedure TfraDetPrompt.chkDetecPromptChange(Sender: TObject);
begin
  GroupBox1.Enabled:=chkDetecPrompt.Checked;
  chkDetecPrompt.Enabled:=true;  //porque también se deshabilitaría
end;

procedure TfraDetPrompt.ConfigCambios;
{Configura al resaltador con la detección de prompt indicada}
var
  hlTerm: TResaltTerm;
begin
  //configura el resaltador con la detección del prompt
  if ed.Highlighter.ClassName='TResaltTerm' then begin
    //Solo se aplica, a 'TResaltTerm'
    hlTerm := TResaltTerm(ed.Highlighter);
    if DetecPrompt then begin  //hay detección
      hlTerm.detecPrompt:=true;
      hlTerm.prIni:=prIni;
      hlTerm.prFin:=prFin;
    end else begin //sin detección
      hlTerm.detecPrompt:=false;
    end;
    ed.Invalidate;  //para actualizar
  end;
  //configura detección en proceso
  if DetecPrompt then begin  //hay detección
    proc.detecPrompt:=true;
    proc.prIni:= prIni;
    proc.prFin:= prFin;
    proc.detParcial:= detParcial;
  end else begin //sin detección
    proc.detecPrompt:=false;
  end;
end;
end.

