unit FormSelecObjetos;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Buttons, StdCtrls, LCLType, LCLProc, CibModelo, CibFacturables, frameVista;

type

  { TfrmSelecObjetos }

  TfrmSelecObjetos = class(TForm)
    BitBtn1: TBitBtn;
    Edit1: TEdit;
    ImageList1: TImageList;
    Label1: TLabel;
    Label2: TLabel;
    TreeView1: TTreeView;
    procedure Edit1Change(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    modelo: TCibModelo;
    visor: TfraVista;
    nodRaiz: TTreeNode;
    function BuscarNodGrupoPorIndice(nodPadre: TTreeNode; indice: integer
      ): TTreeNode;
    function TomarNumero(var cad: string; out num: integer): boolean;
    procedure Seleccionar(var cadSel: string);
  public
    function Exec(modelo0: TCibModelo; Visor0: TfraVista; TxtIni: string
      ): integer;
  end;

var
  frmSelecObjetos: TfrmSelecObjetos;

implementation

{$R *.lfm}

{ TfrmSelecObjetos }

procedure TfrmSelecObjetos.FormShow(Sender: TObject);
begin
  Edit1.SetFocus;
  frmSelecObjetos.Edit1.SelStart:=length(Edit1.Text);
end;
function TfrmSelecObjetos.TomarNumero(var cad: string; out num: integer): boolean;
//Coge un número de una cadena. Si encuentra algún error, devuelve FALSE.
var
  numStr: String;
begin
  if cad='' then exit(false);
  numStr := '';
  while (cad<>'') and (cad[1] in ['0'..'9']) do begin
    numStr := numStr + cad[1];
    delete(cad,1,1);
  end;
  if numStr = '' then exit;   //no hay número
  if not TryStrToInt(numStr, num) then
    exit(false);  //por si es un número muy grande
  exit(true);  //todo bien.
end;
function TfrmSelecObjetos.BuscarNodGrupoPorIndice(nodPadre: TTreeNode; indice: integer): TTreeNode;
var
  idx: Integer;
  nod: TTreeNode;
begin
  idx := 0;
  for nod in TreeView1.Items do if nod.Parent = nodPadre then begin
    inc(idx);
    if idx = indice then begin
      exit(nod);
    end;
  end;
  exit(nil);
end;
procedure TfrmSelecObjetos.Seleccionar(var cadSel: string);
{Selecciona un elemento, de aceurdo a la cadena indicada}
var
  nodGru, nodFac: TTreeNode;
  num, numFac, numGru: integer;
  numStr: String;
begin
  if cadSel = '' then exit;
  if cadSel[1] = '.' then begin
    //Forma resumida de selección
    numFac := -1;  //inicia bandera
    if TreeView1.Items.Count=0 then exit;
    TreeView1.Items[0].Selected:=true;  //nodo raiz
    TreeView1.Items[0].Expanded:=true;
    delete(cadSel,1,1);
    //Extrae número
    if not TomarNumero(cadSel, num) then exit;
    //Hay número, elige el grupo que corresponde
    nodGru := BuscarNodGrupoPorIndice(nodRaiz, num);
    if nodGru = nil then begin
      //El número no corresponde a un grupo
      if (modelo.items.Count<10) and (num>10) then begin
        //Hay menos de 10 grupos, es posible que sea una forma resumida, como:
        // .<1><2>  o .<2><10> , en donde se omite el punto.
        numStr := IntToStr(num);
        numGru := StrtoInt(numStr[1]); //No debería dar error nuca
        numFac := StrToInt(copy(numStr, 2, Length(numStr)));  //No debería dar error nuca
        //Intentamos ahora para vr si se puede seleccionar el grupo
        nodGru := BuscarNodGrupoPorIndice(nodRaiz, numGru);
        if nodGru = nil then exit;  //No funciona así tampoco
        //Al dejar valor en "numFac", indicamos que hay número de facturable, pendiente.
      end else begin
        //Ni modo. No selecciona a un grupo.
        exit;
      end;
    end;
    nodGru.Selected := true;
    //Se ha seleccionado un grupo.
    //Ahora hay que ver si se puede seleccionar un facturable
    if numFac > 0 then begin
      //Hay número de facturable pendiente
      nodFac := BuscarNodGrupoPorIndice(nodGru, numFac);
      if nodFac = nil then exit;
      nodFac.Selected := true;
      //Hay factuable seleccionado
      visor.SeleccionarFac(nodGru.Text + ':' + nodFac.Text);
      exit;
    end;
    if cadSel='' then begin
      //No hay facturable
      visor.SeleccionarGru(nodGru.Text);  //selecciona grupo
      exit;
    end;
    if cadSel[1]<>'.' then exit;
    delete(cadSel,1,1);  //elimina punto
    //Debería seguir un número
    if not TomarNumero(cadSel, num) then exit;
    //Sigue un número, debe ser identificador de facturable
    nodFac := BuscarNodGrupoPorIndice(nodGru, num);
    if nodFac = nil then exit;
    nodFac.Selected := true;
    //Hay factuable seleccionado
    visor.SeleccionarFac(nodGru.Text + ':' + nodFac.Text);
  end else begin
    //Debe ser el nombre de un objeto

  end;
end;
procedure TfrmSelecObjetos.Edit1Change(Sender: TObject);
var
  cad: TCaption;
begin
  cad := Edit1.Text;
  Seleccionar(cad);
  if (cad = '.') or (cad = '+') then begin
    //Este comando se asume como que se quiere terminar la selección y pasar al menú
    //contextual.
    ModalResult := mrYes;   //Sale
  end else if cad = '-' then begin
    Edit1.Text:='';
  end;
end;
procedure TfrmSelecObjetos.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then begin
    Self.Close;
  end;
  if Key = VK_ESCAPE then begin
    Self.Close;
  end;
end;
function TfrmSelecObjetos.Exec(modelo0: TCibModelo; Visor0: TfraVista;
  TxtIni: string): integer;
{Muestra el formulario de selección.}
var
  gr : TCibGFac;
  fac: TCibFac;
  nodFac, nodGru: TTreeNode;
begin
  modelo := modelo0;
  visor := Visor0;
  //Llena árbol
  TreeView1.BeginUpdate;
  TreeView1.Items.Clear;
  nodRaiz := TreeView1.Items.AddChild(nil, 'Todos');
  nodRaiz.ImageIndex := -1;
  nodRaiz.SelectedIndex := -1;
  for gr in modelo.items do begin
    nodGru := TreeView1.Items.AddChild(nodRaiz, gr.Nombre);
    nodGru.ImageIndex := 0;
    nodGru.SelectedIndex := 0;
    for fac in gr.items do begin
      nodFac := TreeView1.Items.AddChild(nodGru, fac.Nombre);
      nodFac.ImageIndex := 1;
      nodFac.SelectedIndex := 1;
    end;
    nodGru.Expanded:=true;
  end;
  TreeView1.EndUpdate;
  Edit1.Text:=TxtIni;
  Result := self.ShowModal;
end;

end.

