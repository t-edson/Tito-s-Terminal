unit FrameCfgPanCom;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, SynFacilCompletion
  ,ConfigFrame;

type

  { TfraPanCom }

  TfraPanCom = class(TCfgFrame)
    chkCodFolding: TCheckBox;
    chkCompletCode: TCheckBox;
    chkSaveBefSend: TCheckBox;
    chkUsarPrep: TCheckBox;
    procedure ConfigResalt;
  private
    hl    : TSynFacilComplet;  //referencia al resaltador
  public
    CompletCode: boolean;  //habilita el completado de código
    CodFolding : boolean;  //habilita el plegado de código
    SaveBefSend: boolean;  //permite guardar antes de enviar el texto
    UsarPrep   : boolean;  //usar preprocesador
    LinCom     : string;   //línea de comando para preporcesador
    ArcEnviar  : string;   //tetxo a enviar
    procedure Iniciar(secINI0: string; hl0: TSynFacilComplet); //Inicia el frame
    procedure PropToWindow; override;
    procedure SetLanguage(lang: string);
  end;

implementation

{$R *.lfm}

{ TfraPanCom }

procedure TfraPanCom.ConfigResalt;
begin
  hl.OpenOnKeyUp := CompletCode;
  //no se puede configurar plegado de código
end;

procedure TfraPanCom.Iniciar(secINI0: string; hl0: TSynFacilComplet);
begin
  secINI := secINI0;  //sección INI
  hl := hl0;
  OnUpdateChanges:=@ConfigResalt;
  //manejador de cambios
  Asoc_Bol_TChkBox(@CompletCode,chkCompletCode,'CompletCode',true);
  Asoc_Bol_TChkBox(@CodFolding , chkCodFolding,'CodFolding',true);
  Asoc_Bol_TChkBox(@SaveBefSend,chkSaveBefSend,'SaveBefSend',false);
  Asoc_Bol_TChkBox(@UsarPrep  , chkUsarPrep ,'UsarPrep',false);
end;

procedure TfraPanCom.PropToWindow;
begin
  inherited PropToWindow;
//  chkUsarPrepChange(Self);
end;

procedure TfraPanCom.SetLanguage(lang: string);
//Rutina de traducción
begin
  case lowerCase(lang) of
  'es': begin
      chkCompletCode.Caption:='Completado Automático de Código';
      chkCodFolding.Caption:='&Plegado de Código';
      chkSaveBefSend.Caption:='Guardar antes de enviar contenido';
      chkUsarPrep.Caption:='Usar Preprocesador PreSQL';
    end;
  'en': begin
      chkCompletCode.Caption:='Automatic Code Completion';
      chkCodFolding.Caption:='Code &Folding';
      chkSaveBefSend.Caption:='Save before of send Content';
      chkUsarPrep.Caption:='Use PreSQL Preprocessor';
    end;
  end;
end;

end.

