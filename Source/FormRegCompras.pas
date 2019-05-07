unit FormRegCompras;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, ExtCtrls, Buttons, FormAdminProvee, FrameEditGrilla,
  CibTabProductos, BasicGrilla, UtilsGrilla, MisUtils;
type

  { TfrmRegCompras }

  TfrmRegCompras = class(TForm)
    btnGuardar: TBitBtn;
    btnCancelar: TBitBtn;
    datTecCompra: TDateEdit;
    txtTotal: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    txtProveed: TEdit;
    Label3: TLabel;
    txtID: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    txtNumDocum: TEdit;
    txtCateg: TEdit;
    procedure btnCancelarClick(Sender: TObject);
    procedure btnGuardarClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    TabPro: TCibTabProduc;
    completProv: TListaCompletado;
    FormatMon: string;
    fraGri   : TfraEditGrilla;
    colCantidad: TugGrillaCol;
    colDescripc: TugGrillaCol;
    colPrecUnit: TugGrillaCol;
    colSubTotal: TugGrillaCol;

    procedure fraGriLlenarLista(lstGrilla: TListBox; fil, col: integer;
      editTxt: string);
    procedure fraGriModificado(TipModif: TugTipModif; filAfec: integer);
    procedure Proveed_EditChange;
    procedure Proveed_Seleccionado;
    function Validar: boolean;
  public
    procedure Limpiar;
    procedure Exec(TabPro0: TCibTabProduc; FormatMoneda: string);
  end;

var
  frmRegCompras: TfrmRegCompras;

implementation
{$R *.lfm}

{ TfrmRegCompras }
procedure TfrmRegCompras.Limpiar;
//Limpia el formulario
begin
  //txtID.Text := '';
  datTecCompra.Date := now;
  txtProveed.Text := '';
  txtNumDocum.Text := '';
  //fraGri.Clear.
end;
procedure TfrmRegCompras.Proveed_Seleccionado;
begin
  txtCateg.SetFocus;
end;
procedure TfrmRegCompras.Proveed_EditChange;
begin

end;

procedure TfrmRegCompras.fraGriLlenarLista(lstGrilla: TListBox; fil, col: integer;
                                           editTxt: string);
var
  reg: TCibRegProduc;
begin
  if col = 2 then begin
    //Productos o insumos
    lstGrilla.Items.BeginUpdate;
    lstGrilla.Clear;
    for reg in TabPro.Productos do begin
      if CumpleFiltro(reg.Desc, editTxt) then begin
        lstGrilla.AddItem(reg.Desc, nil);
      end;
//      grilla.Cells[0, f] := IntToStr(f);
//      RegAGrilla(reg, f);
//      f := f + 1;
    end;
    lstGrilla.Items.EndUpdate;
  end;
end;
procedure TfrmRegCompras.fraGriModificado(TipModif: TugTipModif;
  filAfec: integer);
var
  f: Integer;
  tot: Double;
  txtSubTotal: String;
begin
  MsgBox('Modificado');
  //Calcula el total de la compra.
  tot := 0;
  for f:=1 to fraGri.RowCount-1 do begin
    txtSubTotal := fraGri.grilla.Cells[colSubTotal.idx, f];
    if trim(txtSubTotal) = '' then continue;
    tot := tot + colSubTotal.ValNum[f];
  end;
  txtTotal.Text := FloatToStr(tot);
end;
procedure TfrmRegCompras.Exec(TabPro0: TCibTabProduc; FormatMoneda: string);
begin
  TabPro := TabPro0;
  Limpiar;
  //TabIns := TabPro0;
  FormatMon := FormatMoneda;
  //ListaAGrilla;  //Hace el llenado inicial de productos
  //fraFiltArbol1.LeerCategorias;
  //RefrescarFiltros;   //Para actualizar mensajes y variables de estado.
  self.Show;
  //Carga grilla de proveedores

  //Inicia ID de la compra.
  //Usa Fecha-hora en segundos, por lo lo que no se puede registrar dos compras en el mismo segundo
  txtID.Text := IntToStr(trunc(now * 86400));
  //Fecha de compra
  datTecCompra.Date := now;
  //Completado para Proveedor
  completProv.Inic(txtProveed, frmAdminProvee.fraGri.grilla, 4);
  completProv.OnSelect := @Proveed_Seleccionado;
  completProv.OnEditChange := @Proveed_EditChange;

end;

function TfrmRegCompras.Validar: boolean;
{Valida el contenido de la compra. Si hay error, muestra mensaje y devuelve FALSE.}
var
  f: Integer;
begin
  Result := true;
  if trim(txtProveed.Text) = '' then begin
    MsgErr('Campo de proveedor vacío.');
    if txtProveed.Visible then txtProveed.SetFocus;
    exit(false);
  end;
  if trim(txtNumDocum.Text) = '' then begin
    MsgErr('Número de documento vacío.');
    if txtNumDocum.Visible then txtNumDocum.SetFocus;
    exit(false);
  end;
  fraGri.ValidarGrilla;
  if fraGri.MsjError<>'' then exit(false);
  for f:=1 to fraGri.RowCount-1 do begin
    if fraGri.FilaVacia(f) then continue;
    //Hay valores en las filas
    if fraGri.grilla.Cells[1, f] = '' then begin
      MsgErr('Campo de cantidad vacío.');
      if fraGri.Visible then fraGri.SetFocus;
      fraGri.grilla.Row := f;
      exit(false);
    end;
  end;
end;

procedure TfrmRegCompras.btnGuardarClick(Sender: TObject);
begin
  if not Validar then exit;

end;

procedure TfrmRegCompras.btnCancelarClick(Sender: TObject);
{Limpia los campos y cierra la ventana, sin guardar.}
begin
  self.Hide;
end;

procedure TfrmRegCompras.FormCreate(Sender: TObject);
begin
  completProv   := TListaCompletado.Create;
  fraGri        := TfraEditGrilla.Create(self);
  fraGri.Parent := Panel2;
  fraGri.Align  := alClient;
  fraGri.AddRowEnd:= true;
  fraGri.IniEncab;
                 fraGri.AgrEncabNum  ('N°'          , 30);
  colCantidad := fraGri.AgrEncabNum  ('CANTIDAD'    , 40);
  colDescripc := fraGri.AgrEncabTxt  ('DESCRIPCIÓN' , 160);
  colPrecUnit := fraGri.AgrEncabNum  ('P.UNITARIO'  , 80);
  colSubTotal := fraGri.AgrEncabNum  ('SUBTOTAL'    , 80);

  fraGri.FinEncab;
  fraGri.OnGrillaModif := @fraGriModificado;
//  fraGri.OnReqNuevoReg:=@fraGri_ReqNuevoReg;
  fraGri.OnLlenarLista := @fraGriLlenarLista;
end;

procedure TfrmRegCompras.FormDestroy(Sender: TObject);
begin
  completProv.Destroy;
end;
end.
