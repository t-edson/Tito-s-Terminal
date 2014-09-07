{Modificado por Tito Hinostroza 04/09/2014
 Define a un terminal tipo VT100, como una matriz de caracteres. Solo se implementan las
 secuencias de escape básicas. No se implementa opción de coloreado o atributos de texto.
 Los caracteres de pantalla se almacenan en el arreglo de cadenas buf[] y se trata como
 si fuera una matriz de cracteres. No se almacena más que la pantalla actual.

 El terminal se debe crear instanciando la clase TTermVT100.
 Los datos se esperan que lleguen en bloques, a través de AddData().

 Para mostrar el contenido del terminal, se puede leer el arreglo buf[], de forma periódica,
 o usando el evento OnRefreshAll(), que se llama cada vez que se agregan datos con
 AddData().

 Para controlar mejor el refresco de la pantalla se deben usar los eventos: OnRefreshLine()
 y OnRefreshLines(), que sirven para refrescar lineas individuales o rangos de líneas,
 cuando hay cambios. También debe controlarse el evento OnAddLine(), que se genera cuando
 hay un desplazamiento del contenido del terminal.

                                                   Por Tito Hinostroza 27/06/2014 }
unit TermVT;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LCLProc;
const
  MAX_HEIGHT_TS = 100;   //cantidad máxima de filas
  MAX_WIDTH_TS = 32767;    //cantidad máxima de columnas

type
  Ttslin = string;   //línea
  TtsGrid = array[1..MAX_HEIGHT_TS] of Ttslin;

  //tipo de secuencia de escape actual
  tEscSequence = (EscSeqOpenBrk,  //secuencia ESC[
                  EscSeqCharSet,  //secuencias ESC( ESC) ESC* ESC+
                  EscSeqCommand   //secuencia ESC]
                     );
  //tipos para eventos
  TtsRecSysComm = procedure(info: string) of object;
  TtsRefScreen = procedure(linesAdded: integer) of object;
  TtsRefreshLine = procedure(fil: integer) of object;
  TtsRefreshLines = procedure(fIni, fFin: integer) of object;
  TtsAddLine = procedure of object;
//  TCursorEvent = procedure(x,y: integer);

  { TTermVT100 }

  TTermVT100 = class
  public
    height: integer;       //alto real de pantalla
    width : integer;       //ancho real de pantalla
    buf : TtsGrid;         //grilla de pantalla
    OnRecSysComm  : TtsRecSysComm;    //Se ha recibido imformación del sistema
    OnRefreshAll  : TtsRefScreen;     //Para refrescar toda la pantalla
    OnRefreshLine : TtsRefreshLine;   //Solicita refrescar una línea
    OnRefreshLines: TtsRefreshLines;  //Solicita refrescar un rango de líneas
    OnAddLine     : TtsAddLine;       //Indica que se ha agregado una línea al terminal
    ProcEscape    : boolean;          //Indica si se debe reconocer las secuencias de escape
//    OnChangeCursor: TCursorEvent;   //Cambia posición del cursor
    procedure SetCurX(AValue: integer);
    procedure SetCurY(AValue: integer);
    procedure SetCursor(x, y: integer);
    procedure Clear;   //Limpia pantalla actual
    function AddData(const cad: PChar): string;
    constructor Create;     //Constructor
    destructor Destroy; override;   //Limpia los buffers
  private
    fCurX, fCurY : integer;  //posición del cursor
    SavecurX, SavecurY: integer;  //para guardar el cursor
    EscString : string;      //para almacenar la secuencia de escape
    //banderas de estado
    InEscape  : boolean;     //en una secuencia de escape
    CurEscSeq : tEscSequence; //tipo de secuencia de escape actual
    Busy      : boolean;     //bandera de ocupado
    linesAdded: Integer;     //contador para líneas agregadas
    minModified: Integer;    //CurY mínimo que se modifica
    maxModified: Integer;    //CurY máximo que se modifica
    procedure eraseChar(const n: integer);
    procedure eraseBack;
    procedure eraseBOL;
    procedure eraseBOS;
    procedure eraseEOL;
    procedure eraseEOS;
    procedure eraseLINE;
    procedure ExecSeqCharSet(c: char);
    procedure ExecSeqCommand(c: char);
    procedure ExecSeqOpenBrk(c: char);
    procedure escapeProcess(c: char);
    procedure Scroll;  //Desplaza la pantalla, dejando la última línea en blanco
    procedure CursorRet;
    procedure CursorDown;
    procedure CursorRight;
//    p       : TProcess;
  public
    function CurXY: TPoint;
    property CurX: integer read FCurX;
    property CurY: integer read FCurY;
  end;

implementation

{ TTermVT100 }

function TTermVT100.CurXY: TPoint;
//Devuelve las coordenadas del cursor.
begin
  Result.x:=CurX;
  Result.y:=CurY;
end;
procedure TTermVT100.SetCurX(AValue: integer);
begin
  if Avalue<1 then Avalue:=1;  //protección
  if fCurX=AValue then Exit;   //sin cambio
  fCurX:=AValue;
  //dispara evento
 //  if OnChangeCursor<>nil then OnChangeCursor(CurX,CurY);
end;
procedure TTermVT100.SetCurY(AValue: integer);
begin
  if Avalue<1 then Avalue:=1;  //protección
  if fCurY=AValue then Exit;  //sin cambio
  fCurY:=AValue;
  //dispara evento
 //  if OnChangeCursor<>nil then OnChangeCursor(CurX,CurY);
end;
procedure TTermVT100.SetCursor(x,y:integer);
//Fija las coordenadas del cursor
begin
  if x<1 then x:=1;  //protección
  if y<1 then y:=1;  //protección
  if (CurX = x) and (CurY = y) then exit;
  //hubo cambio
  fCurX := x;
  fCurY := y;
 //dispara evento
//  if OnChangeCursor<>nil then OnChangeCursor(CurX,CurY);
end;
procedure TTermVT100.eraseLINE;
//Borra la línea actual
begin
  buf[CurY] := '';
End;
procedure TTermVT100.Clear;
//Llena las celdas con espacios en blanco
var
  i: Integer;
begin
  for i := 1 to height do
    buf[i] := '';
  SetCursor(1,1);  //Fija cursor
end;
procedure TTermVT100.eraseBOL;
//Borra desde el inicio de la línea hasta la posición actual del cursor
var
  i: Integer;
begin
  //llena con espacios
  for i:=1 to fCurX do
    buf[CurY][i] := ' ';
End;
procedure TTermVT100.eraseEOL;
//Borra desde el cursor hasta el fin de la línea
begin
  //llena con espacios
  setlength(buf[CurY],CurX-1);  //trunca
End;
procedure TTermVT100.eraseBack;
//Borra desde el cursor un carcteres hacia atrás.
begin
  if fCurX<2 then exit;  //no se puede eliminar
  dec(fCurX);
  delete(buf[CurY],fCurX, 1);
End;
procedure TTermVT100.eraseChar(const n: integer);
//Borra desde el cursor un "n" hacia adelante.
begin
  if fCurX<2 then exit;  //no se puede eliminar
  delete(buf[CurY],fCurX, n);
End;
procedure TTermVT100.eraseBOS;
//Borra desde el inicio de la pantalla hasta la posición actual del cursor.
var i: Integer;
begin
  eraseBOL;   //borra en línea actual
  If (CurY > 1) Then begin
      For i := 1 To CurY do
        buf[i] := '';
  End;
End;
procedure TTermVT100.eraseEOS;
//Borra desde el cursor hasta el fin de la pantalla
var i : Integer;
begin
  //caso especial
  If (curX = 1) And (curY = 1) Then  begin
    Clear; exit;
  end;
  //caso normal
  eraseEOL;  //borra en línea actual
  If (CurY <> height) Then begin
    For i := CurY + 1 To height do
      buf[i] := '';
  End;
End;
procedure TTermVT100.Scroll;
var
  i: Integer;
begin
  if minModified = 1 then begin
    //Este es un caso extremo porque se va a perder la línea 1, que ha sido modificada.
    //Primero deberíamos actualizarla en la salida, por si la desea registrar.
    OnRefreshLine(1);
    //ahora ya podemos desplazar
  end;
  //mueve las líneas
  for i := 1 to height-1 do
    buf[i] := buf[i+1];
  //Mueve cursor
//  Dec(CurY);
  //limpia la línea final
  buf[height] := '';
  inc(linesAdded);
  //dispara evento
//  if OnChangeCursor<>nil then OnChangeCursor(CurX,CurY);
  if OnAddLine <> nil then begin
    OnAddLine;  //para que se agregue una línea
  end;
  //actualiza las variables de modificación
  dec(minModified);
  if minModified<1 then begin  //protección
    minModified := 1;
  end;
  maxModified := height;   //para que considere la línea agregada
end;
procedure TTermVT100.CursorRet;
//Salta a la siguiente línea
begin
  if CurY>=height then begin
    //está en la línea final
    Scroll;
    SetCursor(1,height)
  end else begin
    SetCursor(1,CurY+1)
  end;
end;
procedure TTermVT100.CursorDown;
//Desplaza el cursor abajo
begin
  if CurY>=height then begin
    //Está en la línea final
    Scroll;
    SetCurY(height);
  end else begin
    //caso normal
    SetCurY(CurY+1);
  end;
end;
procedure TTermVT100.CursorRight;
//Desplaza el cursor abajo
begin
  if CurX>=width then begin
    CursorRet;
  end else begin
    SetCurX(CurX+1);
  end;
end;
function TTermVT100.AddData(const cad: PChar): string;
//Recibe una serie de caracteres y los agrega a la pantalla en la posición actual
//del terminal hasta encontrar el caracter #0. Reconoce algunas secuencias de escape,
//pero ignora las que cambian la apriencia del texto.
var
  i: Integer;
  largo: Integer;
begin
  i:=0;
  Busy := true;
  linesAdded := 0;     //iniica bandera
  minModified := CurY;  //inicia
  maxModified := CurY;  //inicia
  while cad[i]<>#0 do begin
    if ProcEscape  and InEscape then begin  //en modo escape
      escapeProcess(cad[i]);
      inc(i);
    end else begin
      if cad[i]=#13 then begin  //salto de línea
        CursorRet;
        inc(i);
//        if CurY>maxModified then maxModified := CurY;
        continue;
      end else if cad[i]=#10 then begin  //salto
        inc(i);   //ignora
        continue;
      end else if cad[i]=#7 then begin  //bell
        beep;
        inc(i);
        continue;
      end else if cad[i]=#8 then begin  //bacspace
//debugln('#8');
        eraseBack;
        inc(i);
        continue;
      end else if cad[i]=#27 then begin  //secuencia de escape
        InEscape := true;
        inc(i);   //pasa al siguiente caracter
        continue;
      end else begin  //caracter normal
//debugln(cad[i]);
        //procesa
        if CurX = length(buf[CurY])+1 then begin
          //este es el caso más común, escribir en siguiente caracter
          setlength(buf[CurY],curX);  //hace crecer la cadena
          buf[CurY][CurX] := cad[i];  //escribe caracter
        end else if CurX <= length(buf[CurY]) then begin
          //esta antes del final de la cadena
          buf[CurY][CurX] := cad[i];  //escribe caracter sin temor
        end else begin
          //está más allá del final de la cadena + 1
          largo := length(buf[CurY]);
          buf[CurY]+= space(CurX-largo-1);  //agrega espacios
          setlength(buf[CurY],curX);  //hace crecer la cadena
          buf[CurY][CurX] := cad[i];  //escribe caracter
        end;
//        CursorRight;   //mueve cursor
        if CurX>=width then begin
          CursorRet;
        end else begin
          SetCurX(CurX+1);
        end;

        inc(i);
        //actualiza la primera y última fila modificada
        if CurY<minModified then minModified := CurY;
        if CurY>maxModified then maxModified := CurY;
      end;
    end;
  end;
  //llama a evento para refrescar toda pantalla
  if OnRefreshAll<>nil then OnRefreshAll(linesAdded);
  //Llama a eventos más selectivos de refresco de pantalla
  if minModified = maxModified then begin  //solo se modificó una línea
    if OnRefreshLine<>nil then OnRefreshLine(minModified);
  end else begin //se modificó un rango de líneas
    if OnRefreshLines<>nil then OnRefreshLines(minModified, maxModified);
  end;
  Busy := false;
end;
procedure TTermVT100.escapeProcess(c: char);
begin
   If EscString = '' Then begin
      //Es el primer caracter (después de ESC). Se ejecuta solo una vez por secuencia.
      CurEscSeq := EscSeqOpenBrk;   //por defecto termina en alfabético
      Case c of
      //Verifica si es una secuencia de escape corta (de dos caracteres)
      #8: begin          //embedded backspace
          SetCurX(curX - 1);
          InEscape := False;
         end;
      '7': begin         //save cursor
          SavecurX := CurX;
          SavecurY := CurY;
          InEscape := False;
         end;
      '8': begin         //restore cursor
          SetCursor(SavecurX, SavecurY);
          InEscape := False;
         end;
      'c':;         //look at VSIreset()
      'D': begin         //cursor down
          SetCurY(CurY+1);
          InEscape := False;
         end;
      'E': begin         //next line
          SetCursor(1, curY + 1);
          InEscape := False;
         end;
      'H': begin         //set tab
Debugln('Secuencia no soportada ESC-H');
          InEscape := False;
         end;
      'I': begin          //look at bp_ESC_I()
          InEscape := False;
         end;
      'M': begin         //cursor up
          SetCurY(CurY-1);
          InEscape := False;
         end;
      'Z': begin         //send ident
          InEscape := False;
        end;
      //Secuencias que terminan con otros caracteres
      '[':begin
          CurEscSeq := EscSeqOpenBrk;   //termina en alfabético
        end;
      '(',')','*','+': begin
          CurEscSeq := EscSeqCharSet; //termina con cualquier caracter alfanumérico
        end;
      ']':begin
          CurEscSeq := EscSeqCommand;   //termina con #7
        end;
      Else
         //Invalid start of escape sequence
         Debugln('Secuencia desconocida: ' + c);
         InEscape := False;
         Exit;
      End;
   End;

   //Verifica si la secuencia de escape actual temina
   If (CurEscSeq = EscSeqOpenBrk) and (c in ['a'..'z','A'..'Z']) Then begin  //termina en alfabético
     //Se completó la secuencia de escape.
     ExecSeqOpenBrk(c);
     InEscape := False;
     EscString := '';
   end else If (CurEscSeq = EscSeqCharSet) and (c in ['a'..'z','A'..'Z','0'..'9']) Then begin
     //Se completó la secuencia de escape.
     ExecSeqCharSet(c);
     InEscape := False;
     EscString := '';
   end else If (CurEscSeq = EscSeqCommand) and (c = #7) Then begin  //termina con #7
     //Se completó la secuencia de escape.
     ExecSeqCommand(c);
     InEscape := False;
     EscString := '';
   end else begin  //no termina la secuencia aún
     EscString += c;   //acumula secuencia
     exit;
   End;
end;
procedure TTermVT100.ExecSeqCharSet(c: char);
//Ejecuta las secuencias de escape ESC( ESC) ESC* ESC+.
//"c" es el último caracter capturado.
begin
//Debugln('ESC:' + EscString + c);

end;
procedure TTermVT100.ExecSeqCommand(c: char);
//Ejecuta las secuencias de escape ESC].
//"c" es el último caracter capturado.
var
  EscString0: String;
begin
//Debugln('ESC:' + EscString + c);
  EscString0 := copy(EscString,2,length(EscString));  //quita primer caracter
  if copy(EscString0,1,2) = '0;' then begin  //ESC ] 0;
    if OnRecSysComm<> nil then OnRecSysComm(copy(EscString0,3,100));
  end;
end;
procedure TTermVT100.ExecSeqOpenBrk(c: char);
//Ejecuta la secuencia de escape ESC[. "c" es el último caracter capturado.
var
   EscString0: string;     //para almacenar la secuencia de escape
   yDiff: Integer;
   xDiff: Integer;
   cY: Integer;
   cX: Integer;

   function GetParamN(var s: string): integer;
   //Extrae un parámetro numérico de la cadena
   var
     i: SizeInt;
   begin
     if s='' then exit(0);  //caso cadena nula
     i := Pos(';', s);
     if i = 0 then begin
        Result := StrToInt(s);
        s := '';
     end else begin
       Result := StrToInt(copy(s, 1, i - 1));
       s := copy(s, i + 1, length(s));
     end;
   end;

begin
//Debugln('ESC:' + EscString + c);
  EscString0 := copy(EscString,2,length(EscString));  //quita primer caracter
  //El último caracter, indicará el tipo de comando.
  Case c of
  'A': begin    // A ==> move cursor up
        yDiff := GetParamN(EscString0);
        If yDiff = 0 Then  yDiff := 1;
        SetCurY(curY - yDiff);
       end;
  'B': begin    // B ==> move cursor down
        yDiff := GetParamN(EscString0);
        If yDiff = 0 Then  yDiff := 1;
        SetCurY(curY + yDiff);
       end;
  'C': begin    // C ==> move cursor right
        xDiff := GetParamN(EscString0);
        If xDiff = 0 Then  xDiff := 1;
        SetCurX(curX + xDiff);
       end;
  'D': begin    // D ==> move cursor left
        xDiff := GetParamN(EscString0);
        If xDiff = 0 Then  xDiff := 1;
        SetCurX(curX - xDiff);
       end;
  'H','f': begin    //Goto cursor position indicated by escape sequence
        if (EscString0='') or (EscString0=';') then begin
          SetCursor(1, 1);
        end else begin  //coordinates indicated
          cY := GetParamN(EscString0);
          cX := StrToInt(EscString0);
          SetCursor(cX, cY);
        end;
       end;
  'J': begin    //Erase screen
         if EscString0='' then begin
           eraseEOS;
         end else begin
           Case StrToInt(EscString0) of
           0: eraseEOS; //Borrar hasta el final de la pantalla
           1: eraseBOS; //Borra pantalla antes del cursor
           2: Clear;
           End;
         end;
       end;
  'K': begin    //Erase line
         if EscString0='' then begin
           eraseEOL;
         end else begin
           Case STrToInt(EscString0) of
           0: eraseEOL; //borra hasta el final de la línea
           1: eraseBOL; //borra hasta el cursor
           2: eraseLINE;
           End;
         end;
        end;
  'P': begin    //ESC[ Pn P   Delete Pn characters, to left
//Debugln(EscString+c);
        yDiff := GetParamN(EscString0);
        eraseChar(yDiff);
       end;
  'g': begin    //clear tabs
//            Dim tY As Integer
Debugln('Secuencia no soportada ESC-g');
//        For tY = 0 To 19
//          tab_table(tY) = 0
//        Next tY
       end;
  'h': begin    //Set mode
       end;
  'i': begin    // print mode
       end;
  'l': begin    //Reset mode
       end;
  'm': begin    //text attributes sequence
       end;
  'r': begin    //scrolling region
Debugln('Secuencia no soportada ESC-r');
       end;
  's': begin        //Save cursor position
        SavecurX := CurX;
        SavecurY := CurY;
       end;
  'u': begin        //restore cursor position
        SetCursor(SavecurX, SavecurY);
       end;
  Else
        Debugln(EscString+c);
  End;
end;
constructor TTermVT100.Create;
var
  i: Integer;
begin
  //limpia las líneas
  for i := 1 to MAX_HEIGHT_TS do
    buf[i] := '';
  SetCursor(1,1);
  EscString := '';
  //tamaño por defecto
  width := 120;
  height := 25;
  Clear;  //limpia
  ProcEscape := true; //para que reconozca (no necesariamente ejecutarlas) las secuencias de escape
  //inicia bandera de ocupado
  Busy := false;
end;
destructor TTermVT100.Destroy;
begin
  inherited Destroy;
end;

end.

