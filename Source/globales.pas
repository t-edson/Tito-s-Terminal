{
Unidad con declaraciones globales del proyecto
                 Creado por Tito Hinostroza - 01/08/2014
}
unit Globales; {$mode objfpc}{$H+}
interface
uses  Classes, SysUtils, Forms, SynEdit, SynEditKeyCmds, MisUtils,
      SynEditTypes, StrUtils, lclType, FileUtil,
      types, LazLogger, Menus ;

const
  NOM_PROG = 'Tito''s Terminal 0.2b';   //nombre de programa

var
   //Variables globales
   MsjError    : String;    //Bandera - Mensaje de error

   rutApp     : string;      //ruta de la aplicación
   rutMacros  : string;      //ruta de la carpeta de macros
   rutScripts : string;      //ruta de la carpeta de scripts
   rutLenguajes: string;     //ruta para guardar las sintaxis
   rutSesiones: string;     //ruta para guardar las sesiones

   archivoEnt  : string;    //archivo de entrada
   MostrarError: Boolean;   //Bandera para mostrar mensajesde error.
   ActConsSeg  : Boolean;   //Activa consultas en segundo plano

//Funciones para control del editor
procedure SubirCursorBloque(ed: TSynEdit; Shift: TShiftState);
procedure BajarCursorBloque(ed: TSynEdit; Shift: TShiftState);
procedure InsertaColumnasBloque(ed: TsynEdit; var key: TUTF8Char);

function LeerParametros: boolean;
function NombDifArc(nomBase: String): String;
procedure LeeArchEnMenu(arc: string; mn: TMenuItem; accion: TNotifyEvent);
procedure CopiarMemu(menOrig, menDest: TMenuItem);

implementation

//Funciones para control del editor
procedure EdSubirCursor(ed: TSynEdit; Shift: TShiftState);
//Sube el cursor del SynEdit, una psoición, considerando el estado de <Shift>
{ TODO : Es muy lento para varias líneas (>100) }
begin
  if ed.SelectionMode = smColumn then  //en modo columna
     ed.ExecuteCommand(ecColSelUp, #0, nil)  //solo se puede mover con selección
  else         //en modo normal
     if ssShift in Shift then
        ed.ExecuteCommand(ecSelUp, #0, nil)   //sube
     else
        ed.ExecuteCommand(ecUp, #0, nil);   //sube
end;
procedure EdBajarCursor(ed: TSynEdit; Shift: TShiftState);
//Baja el cursor del SynEdit, una psoición, considerando el estado de <Shift>
begin
  if ed.SelectionMode = smColumn then  //en modo columna
     ed.ExecuteCommand(ecColSelDown, #0, nil)  //solo se puede mover con selección
  else         //en modo normal
     if ssShift in Shift then
        ed.ExecuteCommand(ecSelDown, #0, nil)   //sube
     else
        ed.ExecuteCommand(ecDown, #0, nil);   //sube
end;
procedure SubirCursorBloque(ed: TSynEdit; Shift: TShiftState);
//Sube el cursor hasta encontrar una línea en blanco (si estaba en una diferente de blanco)
//o hasta encontrar una línea diferente de blanco (si estaba en una línea en blanco)
var
  curY : longint;
begin
  CurY := ed.CaretY;    //Lee posición de cursor
  if CurY = 1 then exit;   //no se puede subir más
  if CurY = 2 then begin
     EdSubirCursor(ed, Shift);   //solo puede subir una posición.
     exit;
  end;
  if trim(ed.lines[CurY-2]) = '' then begin
     //busca línea diferente de blanco
     while CurY > 1 do begin
        if trim(ed.lines[Cury-2]) <> '' then Exit;    //pone y sale
        Dec(CurY);
        EdSubirCursor(ed, Shift);
     end;
  end else begin
     //busca línea en blanco hacia abajo
     while CurY > 1 do begin
        if trim(ed.lines[CurY-2]) = '' then Exit;    //pone y sale
        Dec(CurY);
        EdSubirCursor(ed, Shift);
     end;
  end;
end;
procedure BajarCursorBloque(ed: TSynEdit; Shift: TShiftState);
//Baja el cursor hasta encontrar una línea en blanco (si estaba en una diferente de blanco)
//o hasta encontrar una línea diferente de blanco (si estaba en una línea en blanco)
var
  curY : longint;
begin
   CurY := ed.CaretY;    //Lee posición de cursor
   if CurY = ed.Lines.Count then exit; //no se puede bajar más
   if CurY = ed.Lines.Count - 1 then begin
      EdBajarCursor(ed, Shift);   //solo puede bajar una posición.
      exit;
   end;
   if trim(ed.lines[CurY-1]) = '' then begin
     //busca línea diferente de blanco
     while CurY < ed.Lines.Count do begin
        if trim(ed.lines[CurY-1]) <> '' then Exit;    //pone y sale
        Inc(CurY);
        EdBajarCursor(ed, Shift);
     end;
   end else begin
      //busca línea en blanco hacia abajo
      while CurY < ed.Lines.Count do begin
         if trim(ed.lines[CurY-1]) = '' then Exit;    //pone y sale
         Inc(CurY);
         EdBajarCursor(ed, Shift);
      end;
   end;
end;
procedure InsertaColumnasBloque(ed: TsynEdit; var key: TUTF8Char);
//Inserta un caracter en un bloque de selección en modo columna.
//El editor debe estar en modo columna con un bloque de selección activo.
//El texto se insertará en todas las filas de la selección.
{ TODO : Verificar funcionamiento en líneas con tabulaciones.}
var
   curX,curY : longint;
   p1,p2:TPoint;
   tmp: pchar;
begin
   (*Verifica el caso particular en que se tiene solo una fila de selección en modo columna*)
    if ed.BlockBegin.y = ed.BlockEnd.y then begin
      //no hay mucho que procesar en modo columna
      ed.ExecuteCommand(ecChar,key,nil);
      //cancela procesamiento, para que no procese de nuevo el caracter
      key := #0;
      Exit;
    end;
   (*Verifica ancho de selección. Debe dejarse en ancho nulo, antes de pegar el caracter en
    la selección *)
   if ed.SelAvail then begin  //se podría haber usado  "if BlockBegin.x <> BlockEnd.x", pero se
                              //se tendría problemas porque las posiciones físicas pueden
                              //coincidir aún cuando las posiciones lógcas, no.
       p2 := ed.BlockEnd;  //Lee final de selección
       //hay selección de por lo menos un caracter de ancho
       ed.ExecuteCommand(ecDeleteChar, #0, nil);  //limpia selección
       //Ahora el bloque de selección tiene ancho cero, alto 1 y el cursor está dentro.
       //Ahora se debe restaurar la altura del bloque, modificando BlockEnd.
       //Se usa la posición horizontal del cursor, que coincide con el bloque

       //Se usa transformación, porque BlockEnd, trabaja en coordenada lógica
       p2.x:=ed.PhysicalToLogicalCol(ed.Lines[p2.y-1],p2.y-1,ed.CaretX);
       ed.BlockEnd:=p2;  //restaura también, la altura original del bloque
       ed.SelectionMode := smColumn;    //restaura el modo columna
   end;
   //El bloque de selección tiene ahora ancho cero y alto original.

   (* la idea aquí es poner en el portapapeles, una estructura con varias filas (tantas cono haya
   seleccionada) del caracter que se quiera insertar. *)
   //Guarda cursor
   curX := ed.CaretX;
   curY := ed.CaretY;
   //Lee coordenadas del bloque nulo
   p1 := ed.BlockBegin;
   p2 := ed.BlockEnd;

   tmp := PChar(DupeString(key+#13#10,p2.y-p1.y)+key);  //construye texto
   ed.DoCopyToClipboard(tmp,'');                        //pone en portapapeles

   (*Aquí ya se tiene en el portapapeles, la estructura repetida del caracter a insertar*)
   //pega la selección modificada
   ed.CaretY := p1.y;  //pone cursor arriba para pegar
   //   ed.SelectionMode := smNormal;  //debería poder trabajar en Normal
   //Si la estructura en el portapapeles, es correcta, se copiará correctamente en columnas.
   ed.ExecuteCommand(ecPaste,#0,nil);

   //desplaza Cursor y bloque, para escribir siguiente caracter a la derecha
   curX += 1;
//   p1.x += 1;
//   p2.x += 1;
   p1.x := ed.PhysicalToLogicalCol(ed.Lines[p1.y-1],p1.y-1,curX);
   p2.x := ed.PhysicalToLogicalCol(ed.Lines[p2.y-1],p2.y-1,curX);
   //calcula nuevamente la posición física del cursor,  para evitar que el cursor
   //pueda caer en medio de una tabulación.
   CurX := ed.LogicalToPhysicalCol(ed.Lines[p1.y-1],p1.y-1,p1.x);

   //restaura posición de cursor
   ed.CaretX := curX;
   ed.CaretY := curY;

   //restaura  bloque de selección, debe hacerse después de posicionar el cursor
   ed.BlockBegin := p1;
   ed.BlockEnd := p2;

   ed.SelectionMode := smColumn;       //mantiene modo de columna
   key := #0;        //cancela procesamiento de teclado
end;

function  LeerParametros: boolean;
{lee la linea de comandos
 Si hay error devuelve TRUE}
var
   par : String;
   i   : Integer;
begin
   Result := false;    //valor por defecto
   //valores por defecto
   archivoEnt := '';
   MostrarError := True;
   ActConsSeg := False;
   //Lee parámetros de entrada
   par := ParamStr(1);
   if par = '' then begin
     MsgErr('Nombre de archivo vacío.');
     Result := true;
     exit;  //sale con error
   end;
   if par[1] = '/' then begin  //es parámetro
      i := 1;  //para que explore desde el principio
   end else begin  //es archivo
      archivoEnt := par;  //el primer elemento es el archivo de entrada
      i := 2;  //explora siguientes
   end;
   while i <= ParamCount do begin
      par := ParamStr(i);
      If par[1] = '/' Then begin
         Case UpCase(par) of
            '/NOERROR': MostrarError := False;
            '/ERROR': MostrarError := True;
            '/CONSEG': ActConsSeg := True;
            '/NOCONSEG': ActConsSeg := False;
         Else begin
                MsgErr('Error. Parámetro desconocido: ' + par);
                Result := true;
                exit;  //sale con error
              End
         End
      end Else begin
//         archivoSal := par;
      End;
      inc(i);  //pasa al siguiente
   end;
End;
function NombDifArc(nomBase: String): String;
{Genera un nombre diferente de archivo, tomando el nombre dado como raiz.}
const MAX_ARCH = 10;
var i : Integer;    //Número de intentos con el nombre de archivo de salida
    cadBase : String;   //Cadena base del nombre base
    extArc: string;    //extensión

  function NombArchivo(i: integer): string;
  begin
    Result := cadBase + '-' + IntToStr(i) + extArc;
  end;

begin
   Result := nomBase;  //nombre por defecto
   extArc := ExtractFileExt(nomBase);
   if ExtractFilePath(nomBase) = '' then exit;  //protección
   //quita ruta y cambia extensión
   cadBase := ChangeFileExt(nomBase,'');
   //busca archivo libre
   for i := 0 to MAX_ARCH-1 do begin
      If not FileExists(NombArchivo(i)) then begin
        //Se encontró nombre libre
        Exit(NombArchivo(i));  //Sale con nombre
      end;
   end;
   //todos los nombres estaban ocupados. Sale con el mismo nombre
End;
procedure LeeArchEnMenu(arc: string; mn: TMenuItem; accion: TNotifyEvent);
//Lee la carpeta de macros y actualiza un menú con el nombre de los archivos
//Devuelve la cantidad de ítems leidos
var
    Hay: Boolean;
    SR: TSearchRec;
    item: TMenuItem;
    n : integer;
begin
//  mn.Clear;
  // Crear la lista de ficheos en el dir. StartDir (no directorios!)
  n := 0;  //contador
  Hay := FindFirst(arc,faAnyFile - faDirectory, SR) = 0;
  while Hay do begin
     //encontró. Crea entrada
     item := TMenuItem.Create(nil);
     item.Caption:= SysToUTF8(SR.Name);  //nombre
     item.OnClick:=accion;
     mn.Add(item);
     //busca siguiente
     Hay := FindNext(SR) = 0;
     inc(n);
  end;
  if n = 0 then begin  //no encontró
     //encontró. Crea entrada
     item := TMenuItem.Create(nil);
     item.Caption:= 'vacío';  //nombre
     item.Enabled := false;
     mn.Add(item);
  end;
//  Result := n;
end;
procedure CopiarMemu(menOrig, menDest: TMenuItem);
//Copìa los ítems de un menú a otro
var
  it: TMenuItem;
  i: Integer;
begin
  menDest.Caption:=menOrig.Caption;
  menDest.Clear;
  for i := 0 To menOrig.Count - 1 do begin
    it := TMenuItem.Create(nil);
    it.Caption:= menOrig[i].Caption;
    it.OnClick:=menOrig[i].OnClick;
    it.Checked:=menOrig[i].Checked;
    menDest.Add(it);
  end;

end;

initialization
  //inicia directorios de la aplicación
  rutApp :=  ExtractFilePath(Application.ExeName);  //incluye el '\' final
  rutMacros := rutApp + 'macros';
  rutScripts := rutApp + 'scripts';
  rutLenguajes := rutApp + 'lenguajes';
  rutSesiones := rutApp + 'sesiones';
  archivoEnt := '';    //archivo de entrada
  //verifica existencia de carpetas de trabajo
  try
    if not DirectoryExists(rutScripts) then begin
      msgexc('No se encuentra carpeta /scripts. Se creará.');
      CreateDir(rutScripts);
    end;
    if not DirectoryExists(rutMacros) then begin
      msgexc('No se encuentra carpeta /macros. Se creará.');
      CreateDir(rutMacros);
    end;
    if not DirectoryExists(rutLenguajes) then begin
      msgexc('No se encuentra carpeta /lenguajes. Se creará.');
      CreateDir(rutLenguajes);
    end;
    if not DirectoryExists(rutSesiones) then begin
      msgexc('No se encuentra carpeta /sesiones. Se creará.');
      CreateDir(rutSesiones);
    end;
    if not FileExists(rutApp+'plink.exe') then begin
      msgErr('No se encuentra archivo plink.exe');
    end;
  except
    msgErr('Error. No se puede leer o crear directorios.');
  end;

finalization
  //Por algún motivo, la unidad HeapTrc indica que hay gotera de memoria si no se liberan
  //estas cadenas:
  rutApp :=  '';
  rutMacros := '';
  rutScripts := '';
  rutLenguajes := '';
  rutSesiones := '';
end.

