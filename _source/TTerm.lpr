program TTerm;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, FormPrincipal, FormQuickConnect, FormConfig, globales,
  uResaltTerm, FormEditMacros, FormRemoteExplor, FormRemoteEditor,
  FormRemoteOpenDial, GenCod, FrameTabSession, FormSesProperty, Comandos;

{$R *.res}

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TfrmQuickConnect, frmQuickConnect);
  Application.CreateForm(TConfig, Config);
  Application.CreateForm(TfrmRemoteExplor, frmRemoteExplor);
  Application.CreateForm(TfrmRemoteEditor, frmRemoteEditor);
  Application.CreateForm(TfrmRemoteOpenDial, frmRemoteOpenDial);
  Application.CreateForm(TfrmEditMacros, frmEditMacros);
  Application.CreateForm(TfrmSesProperty, frmSesProperty);
  Application.Run ;
end.

