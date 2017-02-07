program TTerm;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, FormPrincipal, FormConexRapida, FormConfig, globales,
  uResaltTerm, FormEditMacros, FormExpRemoto, FormEditRemoto,
  FormAbrirRemoto, GenCod;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmConexRap, frmConexRap);
  Application.CreateForm(TConfig, Config);
  Application.CreateForm(TfrmExpRemoto, frmExpRemoto);
  Application.CreateForm(TfrmEditRemoto, frmEditRemoto);
  Application.CreateForm(TfrmAbrirRemoto, frmAbrirRemoto);
  Application.CreateForm(TfrmEditMacros, frmEditMacros);
  Application.Run ;
end.

