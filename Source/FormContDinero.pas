{Formulario que funciona como utilidad para contar dinero.}
unit FormContDinero;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, ExtCtrls, LCLType;

type

  { TfrmContDinero }

  TfrmContDinero = class(TForm)
    btnLimp: TButton;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Image10: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Image7: TImage;
    Image8: TImage;
    Image9: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    SpinEdit1: TSpinEdit;
    SpinEdit10: TSpinEdit;
    SpinEdit11: TSpinEdit;
    SpinEdit12: TSpinEdit;
    SpinEdit13: TSpinEdit;
    SpinEdit2: TSpinEdit;
    SpinEdit3: TSpinEdit;
    SpinEdit4: TSpinEdit;
    SpinEdit5: TSpinEdit;
    SpinEdit6: TSpinEdit;
    procedure btnLimpClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SpinEdit10Change(Sender: TObject);
    procedure SpinEdit10KeyPress(Sender: TObject; var Key: char);
    procedure SpinEdit11Change(Sender: TObject);
    procedure SpinEdit11KeyPress(Sender: TObject; var Key: char);
    procedure SpinEdit12Change(Sender: TObject);
    procedure SpinEdit12KeyPress(Sender: TObject; var Key: char);
    procedure SpinEdit13Change(Sender: TObject);
    procedure SpinEdit13KeyPress(Sender: TObject; var Key: char);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit1KeyPress(Sender: TObject; var Key: char);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit2KeyPress(Sender: TObject; var Key: char);
    procedure SpinEdit3Change(Sender: TObject);
    procedure SpinEdit3KeyPress(Sender: TObject; var Key: char);
    procedure SpinEdit4Change(Sender: TObject);
    procedure SpinEdit4KeyPress(Sender: TObject; var Key: char);
    procedure SpinEdit5Change(Sender: TObject);
    procedure SpinEdit5KeyPress(Sender: TObject; var Key: char);
    procedure SpinEdit6Change(Sender: TObject);
    procedure SpinEdit6KeyPress(Sender: TObject; var Key: char);
  private
    { private declarations }
  public
    procedure Contar;
  end;

var
  frmContDinero: TfrmContDinero;

implementation

{$R *.lfm}

{ TfrmContDinero }

procedure TfrmContDinero.SpinEdit1Change(Sender: TObject);
begin
  Contar;
end;
procedure TfrmContDinero.SpinEdit2Change(Sender: TObject);
begin
  Contar;
end;
procedure TfrmContDinero.SpinEdit3Change(Sender: TObject);
begin
  Contar;
end;
procedure TfrmContDinero.SpinEdit4Change(Sender: TObject);
begin
  Contar;
end;
procedure TfrmContDinero.SpinEdit5Change(Sender: TObject);
begin
  Contar;
end;
procedure TfrmContDinero.SpinEdit6Change(Sender: TObject);
begin
  Contar;
end;
procedure TfrmContDinero.SpinEdit10Change(Sender: TObject);
begin
  Contar;
end;
procedure TfrmContDinero.SpinEdit11Change(Sender: TObject);
begin
  Contar;
end;
procedure TfrmContDinero.SpinEdit12Change(Sender: TObject);
begin
  Contar;
end;
procedure TfrmContDinero.SpinEdit13Change(Sender: TObject);
begin
  Contar;
end;

procedure TfrmContDinero.SpinEdit1KeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then SpinEdit2.SetFocus;
end;
procedure TfrmContDinero.SpinEdit2KeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then SpinEdit3.SetFocus;
end;
procedure TfrmContDinero.SpinEdit3KeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then SpinEdit4.SetFocus;
end;
procedure TfrmContDinero.SpinEdit4KeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then SpinEdit5.SetFocus;
end;
procedure TfrmContDinero.SpinEdit5KeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then SpinEdit6.SetFocus;
end;
procedure TfrmContDinero.SpinEdit6KeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then SpinEdit10.SetFocus;
end;
procedure TfrmContDinero.SpinEdit10KeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then SpinEdit11.SetFocus;
end;
procedure TfrmContDinero.SpinEdit11KeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then SpinEdit12.SetFocus;
end;
procedure TfrmContDinero.SpinEdit12KeyPress(Sender: TObject; var Key: char);
begin
  if Key = '.' then SpinEdit13.SetFocus;
end;
procedure TfrmContDinero.SpinEdit13KeyPress(Sender: TObject; var Key: char);
begin

end;

procedure TfrmContDinero.btnLimpClick(Sender: TObject);
begin
  SpinEdit1.Value  := 0;
  SpinEdit2.Value  := 0;
  SpinEdit3.Value  := 0;
  SpinEdit4.Value  := 0;
  SpinEdit5.Value  := 0;
  SpinEdit6.Value  := 0;
  SpinEdit10.Value := 0;
  SpinEdit11.Value := 0;
  SpinEdit12.Value := 0;
  SpinEdit13.Value := 0;
end;

procedure TfrmContDinero.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then close;
end;

procedure TfrmContDinero.Contar;
begin
  Edit1.Text:=FloatToStr(SpinEdit1.Value*0.1+
                         SpinEdit2.Value*0.2+
                         SpinEdit3.Value*0.5+
                         SpinEdit4.Value*1+
                         SpinEdit5.Value*2+
                         SpinEdit6.Value*5+
                         SpinEdit10.Value*10+
                         SpinEdit11.Value*20+
                         SpinEdit12.Value*50+
                         SpinEdit13.Value*100
                         );
end;

end.

