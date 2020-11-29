{Formulario que se compartirá para poder editar las propiedades de una sesión.}
unit FormSesProperty;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ComCtrls, StdCtrls,
  ExtCtrls, Buttons, Spin, Globales, SynEdit, Types;

type
  TTipEnvio = (teComando, teArchivo);

  { TfrmSesProperty }

  TfrmSesProperty = class(TForm)
    bitOK: TBitBtn;
    bitOK_conn: TBitBtn;
    bitCancel: TBitBtn;
    cbutBackCol: TColorButton;
    cbutBackCol1: TColorButton;
    cbutFonPan: TColorButton;
    cbutFonPan1: TColorButton;
    cbutLinAct: TColorButton;
    cbutLinAct1: TColorButton;
    cbutResPal: TColorButton;
    cbutResPal1: TColorButton;
    cbutTexto: TColorButton;
    cbutTexto1: TColorButton;
    cbutTxtPan: TColorButton;
    cbutTxtPan1: TColorButton;
    chkShowTerm: TCheckBox;
    chkShowPCom: TCheckBox;
    chkHLCurWord1: TCheckBox;
    chkMarLinAct1: TCheckBox;
    chkSendRecCom: TCheckBox;
    chkCodFolding: TCheckBox;
    chkCompletCode: TCheckBox;
    chkCurSigPrmpt: TCheckBox;
    chkDetecPrompt: TCheckBox;
    chkInterDirec: TCheckBox;
    chkMarLinAct: TCheckBox;
    chkHLCurWord: TCheckBox;
    chkSendLnCtrEnter: TCheckBox;
    chkSendLnEnter: TCheckBox;
    chkUsarPrep: TCheckBox;
    chkVerBarDesH: TCheckBox;
    chkVerBarDesH1: TCheckBox;
    chkVerBarDesV: TCheckBox;
    chkVerBarDesV1: TCheckBox;
    chkVerMarPle: TCheckBox;
    chkVerMarPle1: TCheckBox;
    chkVerNumLin: TCheckBox;
    chkVerNumLin1: TCheckBox;
    chkVerPanVer: TCheckBox;
    chkVerPanVer1: TCheckBox;
    cmbIP: TComboBox;
    cmbSerPort: TComboBox;
    cmbTipoLetra: TComboBox;
    cmbTipoLetra1: TComboBox;
    cmdTestComm: TButton;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    GroupBox1: TGroupBox;
    grpVertPan: TGroupBox;
    GroupBox3: TGroupBox;
    grpVertPan1: TGroupBox;
    Label1: TLabel;
    lblBackCol: TLabel;
    lblBackCol1: TLabel;
    lblCLinAct1: TLabel;
    lblCurWordCol1: TLabel;
    lblFontName1: TLabel;
    lblFontSize1: TLabel;
    lblTextCol: TLabel;
    lblTextCol1: TLabel;
    lblVPbckCol: TLabel;
    lblVPbckCol1: TLabel;
    lblVPtxtCol: TLabel;
    lblCurWordCol: TLabel;
    Label15: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lblCLinAct: TLabel;
    lblFontName: TLabel;
    lblFontSize: TLabel;
    lblIP: TLabel;
    lblOtro: TLabel;
    lblPort: TLabel;
    lblSerCfg: TLabel;
    lblSerPort: TLabel;
    lblVPtxtCol1: TLabel;
    optComando: TRadioButton;
    optOtro: TRadioButton;
    optScript: TRadioButton;
    optSerial: TRadioButton;
    optSSH: TRadioButton;
    optTelnet: TRadioButton;
    PageControl1: TPageControl;
    Panel1: TPanel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioGroup1: TRadioGroup;
    RadioGroup2: TRadioGroup;
    speTempo: TSpinEdit;
    spFontSize: TSpinEdit;
    spFontSize1: TSpinEdit;
    TabGeneral: TTabSheet;
    TabPromptDet: TTabSheet;
    TabPComSet: TTabSheet;
    TabGenAppear: TTabSheet;
    TabTermCRec: TTabSheet;
    TabPComEdit: TTabSheet;
    TabTermEdit: TTabSheet;
    TabTermPant: TTabSheet;
    TreeView1: TTreeView;
    txtArchivo: TEdit;
    txtCadFin: TEdit;
    txtCadIni: TEdit;
    txtComando: TEdit;
    txtMaxColT: TEdit;
    txtMaxLinT: TEdit;
    txtOtro: TEdit;
    txtPort: TEdit;
    txtSerCfg: TEdit;
    procedure bitOKClick(Sender: TObject);
    procedure bitCancelClick(Sender: TObject);
    procedure chkSendRecComChange(Sender: TObject);
    procedure chkDetecPromptChange(Sender: TObject);
    procedure chkMarLinActChange(Sender: TObject);
    procedure chkHLCurWordChange(Sender: TObject);
    procedure chkVerPanVerChange(Sender: TObject);
    procedure cmdTestCommClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure optOtroChange(Sender: TObject);
    procedure optSerialChange(Sender: TObject);
    procedure optSSHChange(Sender: TObject);
    procedure optTelnetChange(Sender: TObject);
    procedure TabTermEditContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure TreeView1Click(Sender: TObject);
  private
    procedure Ocultar;
  public
    OnTest : procedure of object;
    procedure Exec(connected: boolean);
  end;

var
  frmSesProperty: TfrmSesProperty;

implementation
{$R *.lfm}

procedure TfrmSesProperty.Ocultar;
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
procedure TfrmSesProperty.optTelnetChange(Sender: TObject);
begin
  Ocultar;
  lblIP.Visible:=true;
  cmbIP.Visible:=true;
  lblPort.Visible:=true;
  txtPort.Visible:=true;
  txtPort.Text:='23';
  RadioGroup1.ItemIndex:=2;
end;

procedure TfrmSesProperty.TabTermEditContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin

end;

procedure TfrmSesProperty.TreeView1Click(Sender: TObject);
begin
  if TreeView1.Selected = nil then exit;
  //hay ítem seleccionado
  case IdFromTTreeNode(TreeView1.Selected) of
  '1',
  '1.1'  : TabGeneral.Show;
  '1.2'  : TabPromptDet.Show;
  '1.3'  : TabGenAppear.Show;
  '2',
  '2.1'  : TabPComEdit.Show;
  '2.2'  : TabPComSet.Show;
  '3',
  '3.1'  : TabTermPant.Show;
  '3.2'  : TabTermEdit.Show;
  '3.3'  : TabTermCRec.Show;
  end;
  //Visibilidad de botón
  bitOK_conn.Visible := (PageControl1.TabIndex = 0);
end;

procedure TfrmSesProperty.optSSHChange(Sender: TObject);
begin
  Ocultar;
  lblIP.Visible:=true;
  cmbIP.Visible:=true;
  lblPort.Visible:=true;
  txtPort.Visible:=true;
  txtPort.Text:='22';
  RadioGroup1.ItemIndex:=2;
end;
procedure TfrmSesProperty.optSerialChange(Sender: TObject);
begin
  Ocultar;
  lblSerPort.Visible:=true;
  cmbSerPort.Visible:=true;
  lblSerCfg.Visible:=true;
  txtSerCfg.Visible:=true;
end;
procedure TfrmSesProperty.optOtroChange(Sender: TObject);
begin
  Ocultar;
  lblOtro.Visible:=true;
  txtOtro.Visible:=true;
//  GroupBox1.Visible:=true;
end;
procedure TfrmSesProperty.bitOKClick(Sender: TObject);
begin
  //Devolverá el ModalResult que esté configurado.

  //bitAplicarClick(Self);
  //if fraError<>nil then exit;  //hubo error
  //fcConex.GrabarIP;
  //self.Close;   //porque es modal
end;
procedure TfrmSesProperty.bitCancelClick(Sender: TObject);
begin
  //Devolverá el ModalResult que esté configurado.
  self.Hide;
end;

procedure TfrmSesProperty.chkSendRecComChange(Sender: TObject);
begin
  speTempo.Enabled:=chkSendRecCom.checked;
  label15.Enabled:=chkSendRecCom.checked;
  GroupBox3.Enabled:=chkSendRecCom.checked;
  cmdTestComm.Enabled:=chkSendRecCom.checked;
end;

procedure TfrmSesProperty.chkDetecPromptChange(Sender: TObject);
begin
  GroupBox1.Enabled:=chkDetecPrompt.Checked;
end;

procedure TfrmSesProperty.chkMarLinActChange(Sender: TObject);
begin
  lblCLinAct.Enabled:=chkMarLinAct.Checked;
  cbutLinAct.Enabled:=chkMarLinAct.Checked;
end;

procedure TfrmSesProperty.chkHLCurWordChange(Sender: TObject);
begin
  lblCurWordCol.Enabled:=chkHLCurWord.Checked;
  cbutResPal.Enabled:=chkHLCurWord.Checked;
end;

procedure TfrmSesProperty.chkVerPanVerChange(Sender: TObject);
begin
  chkVerNumLin.Enabled:=chkVerPanVer.Checked;
  chkVerMarPle.Enabled:=chkVerPanVer.Checked;
  cbutFonPan.Enabled:=chkVerPanVer.Checked;
  cbutTxtPan.Enabled:=chkVerPanVer.Checked;
  label2.Enabled:=chkVerPanVer.Checked;
  label3.Enabled:=chkVerPanVer.Checked;
end;

procedure TfrmSesProperty.cmdTestCommClick(Sender: TObject);
begin
  //lama al evento para probar la temporización
  OnTest;
end;

procedure TfrmSesProperty.FormCreate(Sender: TObject);
begin
  PageControl1.ShowTabs := false;
  cmbTipoLetra.Items.Clear;
  cmbTipoLetra.Items.Add('Courier New');
  cmbTipoLetra.Items.Add('Fixedsys');
  cmbTipoLetra.Items.Add('Lucida Console');
  cmbTipoLetra.Items.Add('Consolas');
  cmbTipoLetra.Items.Add('Cambria');

  cmbTipoLetra1.Items.Clear;
  cmbTipoLetra1.Items.Add('Courier New');
  cmbTipoLetra1.Items.Add('Fixedsys');
  cmbTipoLetra1.Items.Add('Lucida Console');
  cmbTipoLetra1.Items.Add('Consolas');
  cmbTipoLetra1.Items.Add('Cambria');

end;

procedure TfrmSesProperty.Exec(connected: boolean);
{Muestra el formulario actual.}
begin
  //Selecciona primera opción.
  TreeView1.Items[0].Selected:=true;
  TreeView1Click(self);
  if connected then begin
    TabGeneral.Enabled := false;
  end else begin
    TabGeneral.Enabled := true;
  end;

  self.ShowModal;
end;

end.

