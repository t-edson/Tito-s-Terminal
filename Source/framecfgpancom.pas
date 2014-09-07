unit FrameCfgPanCom;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, EditBtn
  ,ConfigFrame;   //para interceptar TFrame

type

  { TfraPanCom }

  TfraPanCom = class(TFrame)
    chkUsarPrep: TCheckBox;
    chkSaveBefSend: TCheckBox;
    chkCompletCode: TCheckBox;
    chkCodFolding: TCheckBox;
    txtLinCom: TEdit;
    txtArcEnviar: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    procedure chkUsarPrepChange(Sender: TObject);
  private
    { private declarations }
  public
    CompletCode: boolean;  //habilita el completado de código
    CodFolding : boolean;  //habilita el plegado de código
    SaveBefSend: boolean;  //permite guardar antes de enviar el texto
    UsarPrep   : boolean;  //usar preprocesador
    LinCom     : string;   //línea de comando para preporcesador
    ArcEnviar  : string;   //tetxo a enviar
    procedure Iniciar(secINI0: string); //Inicia el frame
    procedure PropToWindow; override;
  end;

implementation

{$R *.lfm}

{ TfraPanCom }

procedure TfraPanCom.chkUsarPrepChange(Sender: TObject);
begin
  Label1.Enabled:=chkUsarPrep.Checked;
  Label2.Enabled:=chkUsarPrep.Checked;
  txtLinCom.Enabled:=chkUsarPrep.Checked;
  txtArcEnviar.Enabled:=chkUsarPrep.Checked;
end;

procedure TfraPanCom.Iniciar(secINI0: string);
begin
  secINI := secINI0;  //sección INI
  Asoc_Bol_TChkB(@CompletCode,chkCompletCode,'CompletCode',true);
  Asoc_Bol_TChkB(@CodFolding , chkCodFolding,'CodFolding',true);
  Asoc_Bol_TChkB(@SaveBefSend,chkSaveBefSend,'SaveBefSend',false);
  Asoc_Bol_TChkB(@UsarPrep  , chkUsarPrep ,'UsarPrep',false);
  Asoc_Str_TEdit(@LinCom    , txtLinCom   ,'RutPrep','');
  Asoc_Str_TEdit(@ArcEnviar , txtArcEnviar,'ArcEnviar','');
end;

procedure TfraPanCom.PropToWindow;
begin
  inherited PropToWindow;
  chkUsarPrepChange(Self);
end;

end.

