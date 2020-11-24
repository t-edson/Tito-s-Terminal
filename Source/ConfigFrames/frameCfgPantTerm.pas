unit frameCfgPantTerm;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, SynEdit,
  UnTerminal, globales
  ,ConfigFrame;
const MAX_LIN_TER = 32000;
type

  { TfraPantTerm }

  TfraPantTerm = class(TCfgFrame)
    chkCurSigPrmpt: TCheckBox;
    chkInterDirec: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    txtMaxColT: TEdit;
    txtMaxLinT: TEdit;
  private
    p: TConsoleProc;   //referencia a proceso telnet
    procedure ConfigTerminal;
  public
    maxLinTer : integer;  //máxima cantidad de líneas que se nantienen en el terminal
    maxColTer : integer;  //máxima cantidad de columnas que se muestran en el terminal
    interDirec: boolean;  //interceptar teclas direccionales
    curSigPrm : boolean;  //cursor sigue a prompt
    procedure Iniciar(secINI0: string; p0: TConsoleProc ); //Inicia el frame
    procedure SetLanguage(lang: string);
  end;

implementation

{$R *.lfm}

{ TfraPantTerm }
procedure TfraPantTerm.Iniciar(secINI0: string; p0: TConsoleProc);
begin
  secINI := secINI0;  //sección INI
  //asigna referencia necesarias
  p := p0;
  OnUpdateChanges := @ConfigTerminal;  //manejador de cambios
  //Crea las relaciones variable-control
  Asoc_Int_TEdit(@maxLinTer ,txtMaxLinT,'maxLinTer',5000, 200,MAX_LIN_TER);  {menos de 200 líneas
                  puede causar problemas con la rutina de limitación de tamaño}
  Asoc_Int_TEdit(@maxColTer ,txtMaxColT,'maxColTer',1000, 80,10000);
  Asoc_Bol_TChkBox(@interDirec,chkInterDirec,'interDirec',true);
  Asoc_Bol_TChkBox(@curSigPrm,chkCurSigPrmpt,'curSigPrm',true);
end;

procedure TfraPantTerm.ConfigTerminal;
//Configura el terminal de acuerdo a las variables de estado
begin
  p.TerminalWidth:=maxColTer;
end;

procedure TfraPantTerm.SetLanguage(lang: string);
//Rutina de traducción
begin
  case lowerCase(lang) of
  'es': begin
      Label2.Caption:='&Tipo de terminal:';
      Label3.Caption:='Ta&maño de terminal:';
      Label4.Caption:='Máximo Núm. Columnas:';
      Label1.Caption:='Máximo Núm. Líneas :';
      chkInterDirec.Caption:='&Interceptar teclas direccionales';
      chkCurSigPrmpt.Caption:='Cursor de Terminal &sigue a Prompt';
    end;
  'en': begin
      Label2.Caption:='Terminal &Type:';
      Label3.Caption:='Terminal &Size:';
      Label4.Caption:='Max Columns:';
      Label1.Caption:='Max Lines :';
      chkInterDirec.Caption:='&Intercepts directionals keys';
      chkCurSigPrmpt.Caption:='Terminal Cursor &follows Prompt';
    end;
  end;
end;

end.

