program TTerm;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, FormPrincipal, UnTerminal, FormConexRapida, FormConfig, globales,
  frameCfgDetPrompt, FrameCfgConex, SynFacilHighlighter, TermVT, uResaltTerm,
  FrameCfgEdit, FormSelFuente, frameCfgPantTerm, ConfigFrame, FormEditMacros,
  FrameCfgGener, XpresBas, XPresParser, FrameExpRemoto, FormExpRemoto,
  frameConfExpRem, FrameConfMacros, FormEditRemoto, FormAbrirRemoto,
  SynFacilCompletion, MisUtils, SynFacilUtils, FrameCfgComandRec, 
FrameCfgRutasCnx, FrameCfgPanCom;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmConexRap, frmConexRap);
  Application.CreateForm(TConfig, Config);
  Application.CreateForm(TfrmSelFuente, frmSelFuente);
  Application.CreateForm(TfrmExpRemoto, frmExpRemoto);
  Application.CreateForm(TfrmEditRemoto, frmEditRemoto);
  Application.CreateForm(TfrmAbrirRemoto, frmAbrirRemoto);
  Application.CreateForm(TfrmEditMacros, frmEditMacros);
  Application.Run ;
end.

