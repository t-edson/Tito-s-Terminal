{                                   ConfigFrame
 Unidad para interceptar la clase TFrame y usar un TFrame personalizado que facilite la
 administración de propiedades. Incluye el manejo de entrada y salida a archivos INI.
 Por Tito Hinostroza 10/07/2014

 Versión 0.3.1b
 ==============
 Por Tito Hinostroza 03/09/2014
 * Se cambia la definición de WindowToProp_AllFrames(), y PropToWindow_AllFrames(),
 para que devuelvan el Frame con error, en lugar de la cadena de error. Así se
 puede identificar al Frame problemático.

}
unit ConfigFrame;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, StdCtrls, Spin, IniFiles, Dialogs, Graphics, Variants;

const
{  MSG_NO_INI_FOUND = 'No se encuentra archivo de configuración: ';
  MSG_ERR_WRIT_INI = 'Error leyendo de archivo de configuración: ';
  MSG_ERR_READ_INI = 'Error escribiendo en archivo de configuración: ';
  MSG_INI_ONLY_READ = 'Error. Archivo de configuración es de solo lectura';
  MSG_FLD_HAV_VAL = 'Campo debe contener un valor.';
  MSG_ONLY_NUM_VAL ='Solo se permiten valores numéricos.';
  MSG_NUM_TOO_LONG = 'Valor numérico muy grande.';
  MSG_MAX_VAL_IS  = 'El mayor valor permitido es: ';
  MSG_MIN_VAL_IS  = 'El menor valor permitido es: ';
  MSG_DESIGN_ERROR = 'Error de diseño.';
  MSG_NO_IMP_ENUM_T = 'Tipo enumerado no manejable.';}

  MSG_NO_INI_FOUND = 'No INI file found: ';
  MSG_ERR_WRIT_INI = 'Error writing to INI file: ';
  MSG_ERR_READ_INI = 'Error reading from INI file: ';
  MSG_INI_ONLY_READ = 'Error. INI file is only read';
  MSG_FLD_HAV_VAL = 'Filed must contain a value.';
  MSG_ONLY_NUM_VAL ='Only numeric values are allowed.';
  MSG_NUM_TOO_LONG = 'Numeric value is too large.';
  MSG_MAX_VAL_IS  = 'The maximun allowed value is: ';
  MSG_MIN_VAL_IS  = 'The minimun allowed value is: ';
  MSG_DESIGN_ERROR = 'Design error.';
  MSG_NO_IMP_ENUM_T = 'Enumerated type no handled.';

type
  //Tipos de asociaciones
  TTipPar = (
   tp_Int_TEdit     //entero asociado a TEdit
  ,tp_Int_TSpnEdit  //entero asociado a TSpinEdit
  ,tp_Str_TEdit     //string asociado a TEdit
  ,tp_Str_TCmbBox   //string asociado a TComboBox
  ,tp_StrList_TListBox   //StringList asociado a TListBox
  ,tp_Bol_TChkB     //booleano asociado a CheckBox
  ,tp_TCol_TColBut  //TColor asociado a TColorButton
  ,tp_Enum_TRadBut  //Enumerado asociado a TRadioButton
  ,tp_Bol_TRadBut  //Booleano asociado a TRadioButton
  ,tp_Int           //Entero sin asociación
  ,tp_Bol           //Boleano sin asociación
  ,tp_Str           //String sin asociación
  ,tp_StrList       //TStringList sin asociación
  );

  //Para variable, elemento
  TParElem = record
    pVar: pointer;     //referencia a la variable
    lVar: integer;     //tamaño de variable. (Cuando no sea conocido)
    pCtl: TComponent;  //referencia al control
    radButs: array of TRadioButton;  //referencia a controles TRadioButton (se usan en conjunto)
    tipPar: TTipPar;   //tipo de par agregado
    etiqVar: string;   //etiqueta usada para grabar la variable en archivo INI
    minEnt, maxEnt: integer;  //valores máximos y mínimos para variables enteras
    //valores por defecto
    defEnt: integer;   //valor entero por defecto al leer de archivo INI
    defStr: string;    //valor string por defecto al leer de archivo INI
    defBol: boolean;   //valor booleano por defecto al leer de archivo INI
    defCol: TColor;    //valor TColor por defecto al leer de archivo INI
  end;

  { TFrame }

  TFrame = class(Forms.Tframe)   //TFrame personalizado
//  TFrame = class(TcustomFrame)   //TFrame personalizado
  private
    listParElem : array of TParElem;
  protected
    valInt: integer;  //valor entero de salida
  public
    secINI: string;   //sección donde se guardaran los datos en un archivo INI
    MsjErr: string;   //mensaje de error
    OnUpdateChanges: procedure of object;
    procedure ShowPos(x, y: integer); virtual;
    function EditValidateInt(edit: TEdit; min: integer=MaxInt; max: integer=-MaxInt): boolean;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure PropToWindow; virtual;
    procedure WindowToProp; virtual;
    procedure ReadFileToProp(var arcINI: TIniFile); virtual;
    procedure SavePropToFile(var arcINI: TIniFile); virtual;
    //métodos para agregar pares- variable-control
    procedure Asoc_Int_TEdit(ptrInt: pointer; edit: TEdit; etiq: string;
                             defVal: integer; minVal, maxVal: integer);
    procedure Asoc_Int_TSpnEdi(ptrInt: pointer; spEdit: TSpinEdit; etiq: string;
                             defVal, minVal, maxVal: integer);
    procedure Asoc_Str_TEdit(ptrStr: pointer; edit: TCustomEdit; etiq: string;
                             defVal: string);
    procedure Asoc_Str_TCmbBox(ptrStr: pointer; cmbBox: TComboBox; etiq: string;
                             defVal: string);
    procedure Asoc_StrList_TListBox(ptrStrList: pointer; lstBox: TlistBox; etiq: string);
    procedure Asoc_Bol_TChkB(ptrBol: pointer; chk: TCheckBox; etiq: string;
                             defVal: boolean);
    procedure Asoc_Col_TColBut(ptrInt: pointer; colBut: TColorButton; etiq: string;
                             defVal: TColor);
    procedure Asoc_Enum_TRadBut(ptrEnum: pointer; EnumSize: integer;
                    radButs: array of TRadioButton; etiq: string; defVal: integer);
    procedure Asoc_Bol_TRadBut(ptrBol: pointer;
                    radButs: array of TRadioButton; etiq: string; defVal: boolean);
    //métodos para agregar valores sin asociación a controles
    procedure Asoc_Int(ptrInt: pointer; etiq: string; defVal: integer);
    procedure Asoc_Bol(ptrBol: pointer; etiq: string; defVal: boolean);
    procedure Asoc_Str(ptrStr: pointer; etiq: string; defVal: string);
    procedure Asoc_StrList(ptrStrList: pointer; etiq: string);
  end;

  TlistFrames = array of Tframe;

  //Utilidades para el formulario de configuración
  function IsFrameProperty(c: TComponent): boolean;
  function ListOfFrames(form: TForm): TlistFrames;
  function GetIniName(ext: string = 'ini'): string;
  procedure Free_AllConfigFrames(form: TForm);
  procedure Hide_AllConfigFrames(form: TForm);
  function ReadFileToProp_AllFrames(form: TForm; arIni: string): string;
  function SavePropToFile_AllFrames(form: TForm; arIni: string): string;
  function WindowToProp_AllFrames(form: TForm): TFrame;
  function PropToWindow_AllFrames(form: TForm): TFrame;


implementation
//Utilidades para el formulario de configuración
function IsFrameProperty(c: TComponent): boolean;
//Permite identificar si un componente es un Frame creado a partir de TFrame de
//esta unidad.
begin
  if (c.ClassParent.ClassName='TFrame') and
     (UpCase(c.ClassParent.UnitName) = UpCase('ConfigFrame')) then
     Result := true
  else
     Result := false;
end;
function ListOfFrames(form: TForm): Tlistframes;
//Devuelve la lista de frames del tipo TFrame declarado aquí
var
  i: Integer;
  n : integer;
  f: TFrame;
begin
  SetLength(Result,0);
  for i:= 0 to form.ComponentCount-1 do begin
    if IsFrameProperty(form.Components[i]) then begin
      f:=TFrame(form.Components[i]);  //obtiene referencia
      n := high(Result)+1;    //número de elementos
      setlength(Result, n+1);  //hace espacio
      Result[n] := f;          //agrega
    end;
  end;
end;
function GetIniName(ext: string = 'ini'): string;
//Devuelve el nombre del archivo INI, creándolo si no existiera
var F:textfile;
begin
  Result := ChangeFileExt(Application.ExeName,'.'+ext);
  if not FileExists(Result) then begin
    ShowMessage(MSG_NO_INI_FOUND +Result);
    //crea uno vacío para leer las opciones por defecto
    AssignFile(F, Result);
    Rewrite(F);
    CloseFile(F);
  end;
end;
procedure Free_AllConfigFrames(form: TForm);
//Libera los frames de configuración
var
  f: TFrame;
begin
  for f in ListOfFrames(form) do f.Free;
end;
procedure Hide_AllConfigFrames(form: TForm);
//oculta todos los frames de configuración
var
  f: TFrame;
begin
  for f in ListOfFrames(form) do
    f.visible := false;
end;
function ReadFileToProp_AllFrames(form: TForm; arIni: string): string;
//Lee de disco, todas las propiedades de todos los frames de configuración.
//Si encuentra error devuelve el mensaje.
var
  appINI : TIniFile;
  f: Tframe;
begin
  Result := '';
  if not FileExists(arIni) then exit;  //para que no intente leer
  Result := MSG_ERR_READ_INI + arIni;  //valor por defecto
  try
     appINI := TIniFile.Create(arIni);
     //lee propiedades de los Frame de configuración
     for f in ListOfFrames(form) do begin
       f.ReadFileToProp(appINI);
     end;
     Result := '';  //Limpia
  finally
     appIni.Free;                   //libera
  end;
end;
function SavePropToFile_AllFrames(form: TForm; arIni: string): string;
//Escribe a disco, todas las propiedades de todos los frames de configuración.
//Si encuentra error devuelve el mensaje.
var
   appINI : TIniFile;
   f: Tframe;
begin
  Result := MSG_ERR_WRIT_INI + arIni;  //valor por defecto
  try
    If FileExists(arIni)  Then  begin  //ve si existe
       If FileIsReadOnly(arIni) Then begin
          Result := MSG_INI_ONLY_READ;
          Exit;
       End;
    End;
    appINI := TIniFile.Create(arIni);
    //escribe propiedades de los Frame de configuración
    for f in ListOfFrames(form) do begin
      f.SavePropToFile(appINI);
    end;
    Result := '';  //Limpia
  finally
    appIni.Free;                   //libera
  end;
end;
function WindowToProp_AllFrames(form: TForm): TFrame;
//Llama al método WindowToProp de todos los frames de configuración.
//Si encuentra error devuelve el Frame que produjo el error.
var
  f: TFrame;
begin
  Result := nil;
  //Fija propiedades de los controles
  for f in ListOfFrames(form) do begin
    f.WindowToProp;
    if f.MsjErr<>'' then exit(f);
  end;
end;
function PropToWindow_AllFrames(form: TForm): TFrame;
//Llama al método PropToWindow de todos los frames de configuración.
//Si encuentra error devuelve el Frame que produjo el error.
var
  f: TFrame;
begin
  Result := nil;
  //llama a PropToWindow() de todos los PropertyFrame.Frames
  for f in ListOfFrames(form) do begin
    f.PropToWindow;
    if f.MsjErr<>'' then exit(f);
  end;
end;

function WriteStr(s:string): string;
//Protege a una cadena para que no pierda los espacios laterales si es que los tiene,
//porque el el archivo INI se pierden.
begin
  Result:='.'+s+'.';
end;
function ReadStr(s:string): string;
//Quita la protección a una cadena que ha sido guardada en un archivo INI
begin
  Result:=copy(s,2,length(s)-2);
end;
constructor TFrame.Create(TheOwner: TComponent);
begin
  inherited;
  setlength(listParElem, 0)
end;
destructor TFrame.Destroy;
begin

  inherited Destroy;
end;

procedure TFrame.PropToWindow;
//Muestra en los controles, las variables asociadas
var
  i,j:integer;
  r: TParElem;
  n: integer;
  b: boolean;
  s: string;
  c: TColor;
  list: TStringList;
begin
  msjErr := '';
  for i:=0 to high(listParElem) do begin
    r := listParElem[i];
    case r.tipPar of
    tp_Int_TEdit:  begin  //entero en TEdit
          //carga entero
          n:= Integer(r.Pvar^);
          TEdit(r.pCtl).Text:=IntToStr(n);
       end;
    tp_Int_TSpnEdit: begin  //entero en TSpinEdit
          //carga entero
          n:= Integer(r.Pvar^);
          TSpinEdit(r.pCtl).Value:=n;
       end;
    tp_Str_TEdit:  begin  //cadena en TEdit
          //carga cadena
          s:= String(r.Pvar^);
          TEdit(r.pCtl).Text:=s;
       end;
    tp_Str_TCmbBox: begin  //cadena en TComboBox
          //carga cadena
          s:= String(r.Pvar^);
          TComboBox(r.pCtl).Text:=s;
       end;
    tp_StrList_TListBox: begin  //lista en TlistBox
         //carga lista
         list := TStringList(r.Pvar^);
         TListBox(r.pCtl).Clear;
         for j:=0 to list.Count-1 do
           TListBox(r.pCtl).AddItem(list[j],nil);
      end;
    tp_Bol_TChkB: begin //boolean a TCheckBox
          b := boolean(r.Pvar^);
          TCheckBox(r.pCtl).Checked := b;
       end;
    tp_TCol_TColBut: begin //Tcolor a TColorButton
          c := Tcolor(r.Pvar^);
          TColorButton(r.pCtl).ButtonColor := c;
       end;
    tp_Enum_TRadBut: begin //Enumerado a TRadioButtons
          if r.lVar = 4 then begin  //enumerado de 4 bytes
            n:= Int32(r.Pvar^);  //convierte a entero
            if n<=High(r.radButs) then
              r.radButs[n].checked := true;  //lo activa
          end else begin  //tamño no implementado
            msjErr := MSG_NO_IMP_ENUM_T;
            exit;
          end;
       end;
    tp_Bol_TRadBut: begin //Enumerado a TRadioButtons
          b:= boolean(r.Pvar^);  //convierte a entero
          if 1<=High(r.radButs) then
            if b then r.radButs[1].checked := true  //activa primero
            else r.radButs[0].checked := true  //activa segundo
       end;
    tp_Int:; //no tiene control asociado
    tp_Bol:; //no tiene control asociado
    tp_Str:; //no tiene control asociado
    tp_StrList:; //no tiene control asociado
    else  //no se ha implementado bien
      msjErr := MSG_DESIGN_ERROR;
      exit;
    end;
  end;
end;
procedure TFrame.WindowToProp;
//Lee en las variables asociadas, los valores de loc controles
var
  i,j: integer;
  spEd: TSpinEdit;
  r: TParElem;
  list: TStringList;
begin
  msjErr := '';
  for i:=0 to high(listParElem) do begin
    r := listParElem[i];
    case r.tipPar of
    tp_Int_TEdit:  begin  //entero de TEdit
          if not EditValidateInt(TEdit(r.pCtl),r.minEnt, r.MaxEnt) then
            exit;   //hubo error. con mensaje en "msjErr"
          Integer(r.Pvar^) := valInt;  //guarda
       end;
    tp_Int_TSpnEdit: begin   //entero de TSpinEdit
          spEd := TSpinEdit(r.pCtl);
          if spEd.Value < r.minEnt then begin
            MsjErr:=MSG_MIN_VAL_IS+IntToStr(r.minEnt);
            if spEd.visible and spEd.enabled and self.visible then spEd.SetFocus;
            exit;
          end;
          if spEd.Value > r.maxEnt then begin
            MsjErr:=MSG_MAX_VAL_IS+IntToStr(r.maxEnt);
            if spEd.visible and spEd.enabled and self.visible then spEd.SetFocus;
            exit;
          end;
          Integer(r.Pvar^) := spEd.Value;
       end;
    tp_Str_TEdit: begin  //cadena de TEdit
          String(r.Pvar^) := TEdit(r.pCtl).Text;
       end;
    tp_Str_TCmbBox: begin //cadena de TComboBox
          String(r.Pvar^) := TComboBox(r.pCtl).Text;
       end;
    tp_StrList_TListBox: begin //carga a TStringList
          list := TStringList(r.Pvar^);
          list.Clear;
          for j:= 0 to TListBox(r.pCtl).Count-1 do
            list.Add(TListBox(r.pCtl).Items[j]);
       end;
    tp_Bol_TChkB: begin  //boolean de  CheckBox
          boolean(r.Pvar^) := TCheckBox(r.pCtl).Checked;
       end;
    tp_TCol_TColBut: begin //TColor a TColorButton
          TColor(r.Pvar^) := TColorButton(r.pCtl).ButtonColor;
       end;
    tp_Enum_TRadBut: begin //TRadioButtons a Enumerado
          //busca el que está marcado
          for j:=0 to high(r.radButs) do begin
             if r.radButs[j].checked then begin
               //debe fijar el valor del enumerado
               if r.lVar = 4 then begin  //se puede manejar como entero
                 Int32(r.Pvar^) := j;  //guarda
                 break;
               end else begin  //tamaño no implementado
                 msjErr := MSG_NO_IMP_ENUM_T;
                 exit;
               end;
             end;
          end;
       end;
    tp_Bol_TRadBut: begin //TRadioButtons a Enumerado
          //busca el que está marcado
          if high(r.radButs)>=1 then begin
             if r.radButs[1].checked then boolean(r.Pvar^) := true
             else boolean(r.Pvar^) := false;
          end;
       end;
    tp_Int:; //no tiene control asociado
    tp_Bol:; //no tiene control asociado
    tp_Str:; //no tiene control asociado
    tp_StrList:; //no tiene control asociado
    else  //no se ha implementado bien
      msjErr := MSG_DESIGN_ERROR;
      exit;
    end;
  end;
  //Terminó con éxito. Actualiza los cambios
  if OnUpdateChanges<>nil then OnUpdateChanges;
end;
procedure TFrame.ReadFileToProp(var arcINI: TIniFile);
//Lee de disco las variables registradas
var
  i: integer;
  r: TParElem;
begin
  for i:=0 to high(listParElem) do begin
    r := listParElem[i];
    case r.tipPar of
    tp_Int_TEdit:  begin  //lee entero
         Integer(r.Pvar^) := arcINI.ReadInteger(secINI, r.etiqVar, r.defEnt);
       end;
    tp_Int_TSpnEdit: begin  //lee entero
         Integer(r.Pvar^) := arcINI.ReadInteger(secINI, r.etiqVar, r.defEnt);
       end;
    tp_Str_TEdit: begin  //lee cadena
         String(r.Pvar^) := ReadStr(arcINI.ReadString(secINI, r.etiqVar, '.'+r.defStr+'.'));
       end;
    tp_Str_TCmbBox: begin  //lee cadena
         String(r.Pvar^) := ReadStr(arcINI.ReadString(secINI, r.etiqVar, '.'+r.defStr+'.'));
       end;
    tp_StrList_TListBox: begin //lee TStringList
         arcINI.ReadSection(secINI+'_'+r.etiqVar,TStringList(r.Pvar^));
       end;
    tp_Bol_TChkB: begin  //lee booleano
         boolean(r.Pvar^) := arcINI.ReadBool(secINI, r.etiqVar, r.defBol);
       end;
    tp_TCol_TColBut: begin  //lee TColor
         TColor(r.Pvar^) := arcINI.ReadInteger(secINI, r.etiqVar, r.defCol);
       end;
    tp_Enum_TRadBut: begin  //lee enumerado como entero
         if r.lVar = 4 then begin
           Int32(r.Pvar^) := arcINI.ReadInteger(secINI, r.etiqVar, r.defEnt);
         end else begin  //tamaño no implementado
           msjErr := MSG_NO_IMP_ENUM_T;
           exit;
         end;
       end;
    tp_Bol_TRadBut: begin  //lee booleano
         boolean(r.Pvar^) := arcINI.ReadBool(secINI, r.etiqVar, r.defBol);
       end;
    tp_Int: begin  //lee entero
         Integer(r.Pvar^) := arcINI.ReadInteger(secINI, r.etiqVar, r.defEnt);
       end;
    tp_Bol: begin  //lee booleano
         boolean(r.Pvar^) := arcINI.ReadBool(secINI, r.etiqVar, r.defBol);
       end;
    tp_Str: begin  //lee cadena
         String(r.Pvar^) := ReadStr(arcINI.ReadString(secINI, r.etiqVar, '.'+r.defStr+'.'));
       end;
    tp_StrList: begin //lee TStringList
         arcINI.ReadSection(secINI+'_'+r.etiqVar,TStringList(r.Pvar^));
       end;
    else  //no se ha implementado bien
      msjErr := MSG_DESIGN_ERROR;
      exit;
    end;
  end;
  //Terminó con éxito. Actualiza los cambios
  if OnUpdateChanges<>nil then OnUpdateChanges;
end;
procedure TFrame.SavePropToFile(var arcINI: TIniFile);
//Guarda en disco las variables registradas
var
  i,j: integer;
  r: TParElem;
  n: integer;
  b: boolean;
  s: string;
  c: TColor;
  strlst: TStringList;
begin
  for i:=0 to high(listParElem) do begin
    r := listParElem[i];
    case r.tipPar of
    tp_Int_TEdit:  begin  //escribe entero
         n := Integer(r.Pvar^);
         arcINI.WriteInteger(secINI, r.etiqVar, n);
       end;
    tp_Int_TSpnEdit: begin //escribe entero
         n := Integer(r.Pvar^);
         arcINI.WriteInteger(secINI, r.etiqVar, n);
       end;
    tp_Str_TEdit: begin //escribe cadena
         s := String(r.Pvar^);
         arcINI.WriteString(secINI, r.etiqVar,WriteStr(s));
       end;
    tp_Str_TCmbBox: begin //escribe cadena
         s := String(r.Pvar^);
         arcINI.WriteString(secINI, r.etiqVar,WriteStr(s));
       end;
    tp_StrList_TListBox: begin  //escribe TStringList
          strlst := TStringList(r.Pvar^);
          arcINI.EraseSection(secINI+'_'+r.etiqVar);
          for j:= 0 to strlst.Count-1 do
            arcINI.WriteString(secINI+'_'+r.etiqVar,strlst[j],'');
       end;
    tp_Bol_TChkB: begin  //escribe booleano
         b := boolean(r.Pvar^);
         arcINI.WriteBool(secINI, r.etiqVar, b);
       end;
    tp_TCol_TColBut: begin  //escribe TColor
         c := Tcolor(r.Pvar^);
         arcINI.WriteInteger(secINI, r.etiqVar, c);
       end;
    tp_Enum_TRadBut: begin  //escribe enumerado
       if r.lVar = 4 then begin
         n := Int32(r.Pvar^);   //lo guarda como entero
         arcINI.WriteInteger(secINI, r.etiqVar, n);
       end else begin  //tamaño no implementado
         msjErr := MSG_NO_IMP_ENUM_T;
         exit;
       end;
    end;
    tp_Bol_TRadBut: begin  //escribe booleano
         b := boolean(r.Pvar^);
         arcINI.WriteBool(secINI, r.etiqVar, b);
       end;
    tp_Int: begin //escribe entero
         n := Integer(r.Pvar^);
         arcINI.WriteInteger(secINI, r.etiqVar, n);
       end;
    tp_Bol: begin  //escribe booleano
         b := boolean(r.Pvar^);
         arcINI.WriteBool(secINI, r.etiqVar, b);
       end;
    tp_Str: begin //escribe cadena
         s := String(r.Pvar^);
         arcINI.WriteString(secINI, r.etiqVar,WriteStr(s));
       end;
    tp_StrList: begin  //escribe TStringList
          strlst := TStringList(r.Pvar^);
          arcINI.EraseSection(secINI+'_'+r.etiqVar);
          for j:= 0 to strlst.Count-1 do
            arcINI.WriteString(secINI+'_'+r.etiqVar,strlst[j],'');
       end;
    else  //no se ha implementado bien
      msjErr := MSG_DESIGN_ERROR;
      exit;
    end;
  end;
end;
procedure TFrame.Asoc_Int_TEdit(ptrInt: pointer; edit: TEdit; etiq: string;
  defVal: integer; minVal, maxVal: integer);
//Agrega un para variable entera - Control TEdit
var n: integer;
  r: TParElem;
begin
  r.pVar   := ptrInt;  //toma referencia
  r.pCtl   := edit;    //toma referencia
  r.tipPar := tp_Int_TEdit;  //tipo de par
  r.etiqVar:= etiq;
  r.defEnt := defVal;
  r.minEnt := minVal;    //protección de rango
  r.maxEnt := maxVal;    //protección de rango
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;
procedure TFrame.Asoc_Int_TSpnEdi(ptrInt: pointer; spEdit: TSpinEdit;
  etiq: string; defVal, minVal, maxVal: integer);
//Agrega un para variable entera - Control TSpinEdit
var n: integer;
  r: TParElem;
begin
  r.pVar   := ptrInt;  //toma referencia
  r.pCtl   := spEdit;    //toma referencia
  r.tipPar := tp_Int_TSpnEdit;  //tipo de par
  r.etiqVar:= etiq;
  r.defEnt := defVal;
  r.minEnt := minVal;    //protección de rango
  r.maxEnt := maxVal;    //protección de rango
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;
procedure TFrame.Asoc_Str_TEdit(ptrStr: pointer; edit: TCustomEdit;
  etiq: string; defVal: string);
//Agrega un par variable string - Control TEdit
var n: integer;
  r: TParElem;
begin
  r.pVar   := ptrStr;  //toma referencia
  r.pCtl   := edit;    //toma referencia
  r.tipPar := tp_Str_TEdit;  //tipo de par
  r.etiqVar:= etiq;
  r.defStr := defVal;
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;
procedure TFrame.Asoc_Str_TCmbBox(ptrStr: pointer; cmbBox: TComboBox; etiq: string;
  defVal: string);
//Agrega un par variable string - Control TEdit
var n: integer;
  r: TParElem;
begin
  r.pVar   := ptrStr;     //toma referencia
  r.pCtl   := cmbBox;   //toma referencia
  r.tipPar := tp_Str_TCmbBox;  //tipo de par
  r.etiqVar:= etiq;
  r.defStr := defVal;
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;

procedure TFrame.Asoc_StrList_TListBox(ptrStrList: pointer; lstBox: TlistBox;
  etiq: string);
var n: integer;
  r: TParElem;
begin
  r.pVar   := ptrStrList;  //toma referencia
  r.pCtl   := lstBox;    //toma referencia
  r.tipPar := tp_StrList_TlistBox;  //tipo de par
  r.etiqVar:= etiq;
//  r.defCol := defVal;
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;

procedure TFrame.Asoc_Bol_TChkB(ptrBol: pointer; chk: TCheckBox; etiq: string;
  defVal: boolean);
//Agrega un para variable booleana - Control TCheckBox
var n: integer;
  r: TParElem;
begin
  r.pVar   := ptrBol;  //toma referencia
  r.pCtl   := chk;    //toma referencia
  r.tipPar := tp_Bol_TChkB;  //tipo de par
  r.etiqVar:= etiq;
  r.defBol := defVal;
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;
procedure TFrame.Asoc_Col_TColBut(ptrInt: pointer; colBut: TColorButton; etiq: string;
  defVal: TColor);
//Agrega un par variable TColor - Control TColorButton
var n: integer;
  r: TParElem;
begin
  r.pVar   := ptrInt;  //toma referencia
  r.pCtl   := colBut;    //toma referencia
  r.tipPar := tp_TCol_TColBut;  //tipo de par
  r.etiqVar:= etiq;
  r.defCol := defVal;
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;
procedure TFrame.Asoc_Enum_TRadBut(ptrEnum: pointer; EnumSize: integer;
  radButs: array of TRadioButton; etiq: string; defVal: integer);
//Agrega un par variable Enumerated - Controles TRadioButton
//Solo se permiten enumerados de hasta 32 bits de tamaño
var n: integer;
  r: TParElem;
  i: Integer;
begin
  r.pVar   := ptrEnum;  //toma referencia
  r.lVar   :=EnumSize;  //necesita el tamaño para modificarlo luego
//  r.pCtl   := ;    //toma referencia
  r.tipPar := tp_Enum_TRadBut;  //tipo de par
  r.etiqVar:= etiq;
  r.defEnt := defVal;   //se maneja como entero
  //guarda lista de controles
  setlength(r.radButs,high(radButs)+1);  //hace espacio
  for i:=0 to high(radButs) do
    r.radButs[i]:= radButs[i];

  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;

procedure TFrame.Asoc_Bol_TRadBut(ptrBol: pointer;
  radButs: array of TRadioButton; etiq: string; defVal: boolean);
//Agrega un par variable Enumerated - Controles TRadioButton
//Solo se permiten enumerados de hasta 32 bits de tamaño
var n: integer;
  r: TParElem;
  i: Integer;
begin
  r.pVar   := ptrBol;  //toma referencia
//  r.pCtl   := ;    //toma referencia
  r.tipPar := tp_Bol_TRadBut;  //tipo de par
  r.etiqVar:= etiq;
  r.defBol := defVal;   //se maneja como entero
  //guarda lista de controles
  setlength(r.radButs,high(radButs)+1);  //hace espacio
  for i:=0 to high(radButs) do
    r.radButs[i]:= radButs[i];
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;

procedure TFrame.Asoc_Int(ptrInt: pointer; etiq: string; defVal: integer);
//Agrega una variable Entera para guardarla en el archivo INI.
var n: integer;
  r: TParElem;
begin
  r.pVar   := ptrInt;  //toma referencia
//  r.pCtl   := colBut;    //toma referencia
  r.tipPar := tp_Int;  //tipo de par
  r.etiqVar:= etiq;
  r.defEnt := defVal;
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;
procedure TFrame.Asoc_Bol(ptrBol: pointer; etiq: string; defVal: boolean);
//Agrega una variable String para guardarla en el archivo INI.
var n: integer;
  r: TParElem;
begin
  r.pVar   := ptrBol;  //toma referencia
//  r.pCtl   := colBut;    //toma referencia
  r.tipPar := tp_Bol;  //tipo de par
  r.etiqVar:= etiq;
  r.defBol := defVal;
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;
procedure TFrame.Asoc_Str(ptrStr: pointer; etiq: string; defVal: string);
//Agrega una variable String para guardarla en el archivo INI.
var n: integer;
  r: TParElem;
begin
  r.pVar   := ptrStr;  //toma referencia
//  r.pCtl   := colBut;    //toma referencia
  r.tipPar := tp_Str;  //tipo de par
  r.etiqVar:= etiq;
  r.defStr := defVal;
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;
procedure TFrame.Asoc_StrList(ptrStrList: pointer; etiq: string);
//Agrega una variable TStringList para guardarla en el archivo INI. El StrinList, debe estar
//ya creado, sino dará error.
var n: integer;
  r: TParElem;
begin
  r.pVar   := ptrStrList;  //toma referencia
//  r.pCtl   := colBut;    //toma referencia
  r.tipPar := tp_StrList;  //tipo de par
  r.etiqVar:= etiq;
//  r.defCol := defVal;
  //agrega
  n := high(listParElem)+1;    //número de elementos
  setlength(listParElem, n+1);  //hace espacio
  listParElem[n] := r;          //agrega
end;

procedure TFrame.ShowPos(x, y: integer);
//Muestra el frame en la posición indicada
begin
  Self.left:= x;
  Self.Top := y;
  Self.Visible:=true;
end;
function TFrame.EditValidateInt(edit: TEdit; min: integer; max: integer): boolean;
//Velida el contenido de un TEdit, para ver si se peude convertir a un valor entero.
//Si no se puede convertir, devuelve FALSE, devuelve el mensaje de error en "MsjErr", y
//pone el TEdit con enfoque.
//Si se puede convertir, devuelve TRUE, y el valor convertido en "valEnt".
var
  tmp : string;
  c : char;
  v: int64;
  signo: string;
  larMaxInt: Integer;
  n: Int64;
begin
  Result := false;
  //validaciones previas
  larMaxInt := length(IntToStr(MaxInt));
  tmp := trim(edit.Text);
  if tmp = '' then begin
    MsjErr:= MSG_FLD_HAV_VAL;
    if edit.visible and edit.enabled and self.visible then edit.SetFocus;
    exit;
  end;
  if tmp[1] = '-' then begin  //es negativo
    signo := '-';  //guarda signo
    tmp := copy(tmp, 2, length(tmp));   //quita signo
  end;
  for c in tmp do begin
    if not (c in ['0'..'9']) then begin
      MsjErr:= MSG_ONLY_NUM_VAL;
      if edit.visible and edit.enabled and self.visible then edit.SetFocus;
      exit;
    end;
  end;
  if length(tmp) > larMaxInt then begin
    MsjErr:= MSG_NUM_TOO_LONG;
    if edit.visible and edit.enabled and self.visible then edit.SetFocus;
    exit;
  end;
  //lo leemos en Int64 por seguridad y validamos
  n := StrToInt64(signo + tmp);
  if n>max then begin
    MsjErr:= MSG_MAX_VAL_IS + IntToStr(max);
    if edit.visible and edit.enabled and self.visible then edit.SetFocus;
    exit;
  end;
  if n<min then begin
    MsjErr:= MSG_MIN_VAL_IS + IntToStr(min);
    if edit.visible and edit.enabled and self.visible then edit.SetFocus;
    exit;
  end;
  //pasó las validaciones
  valInt:=n;  //actualiza valor
  Result := true;   //tuvo éxito
end;

end.

