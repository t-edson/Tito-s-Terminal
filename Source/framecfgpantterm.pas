unit frameCfgPantTerm;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, StdCtrls, SynEdit,
  UnTerminal, globales
  ,ConfigFrame;   //para interceptar TFrame
const MAX_LIN_TER = 32000;
type

  { TfraPantTerm }

  TfraPantTerm = class(TFrame)
    chkCurSigPrmpt: TCheckBox;
    chkInterDirec: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    txtMaxLinT: TEdit;
    txtMaxColT: TEdit;
  private
    p: TConsoleProc;   //referencia a proceso telnet
    procedure ConfigTerminal;
  public
    maxLinTer : integer;  //máxima cantidad de líneas que se nantienen en el terminal
    maxColTer : integer;  //máxima cantidad de columnas que se muestran en el terminal
    interDirec: boolean;  //interceptar teclas direccionales
    curSigPrm : boolean;  //cursor sigue a prompt
    procedure Iniciar(secINI0: string; p0: TConsoleProc ); //Inicia el frame
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
  //crea las relaciones variable-control
  Asoc_Int_TEdit(@maxLinTer ,txtMaxLinT,'maxLinTer',5000, 200,MAX_LIN_TER);  {menos de 200 líneas
                  puede causar problemas con la rutina de limitación de tamaño}
  Asoc_Int_TEdit(@maxColTer ,txtMaxColT,'maxColTer',1000, 80,10000);
  Asoc_Bol_TChkB(@interDirec,chkInterDirec,'interDirec',true);
  Asoc_Bol_TChkB(@curSigPrm,chkCurSigPrmpt,'curSigPrm',true);
end;

procedure TfraPantTerm.ConfigTerminal;
//Configura el terminal de acuerdo a las variables de estado
begin
  p.TerminalWidth:=maxColTer;
end;

end.

