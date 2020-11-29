{
uPreProces
Modificado por Tito Hinostroza 03/11/2014
Unidad que define la sintaxis del PreSQL 2.0. Adaptado de la versión 1.3 de VB.
Se define esta unidad para implementar el procesamiento de un texto o archivo.
No se incluyen mensajes de tipo writeln(), o ShowMessage(), para evitar hacer a
la unidad dependiente del tipo de aplicación.
}
unit uPreProces; {$mode objfpc}{$H+}

interface
uses
  Classes, SysUtils, Fgl, FileUtil, DateUtils, uPreBasicos;

procedure PreProcesar(arc: String; txt: String; var cadcon0: string);

implementation

//---------Manejo de definiciones------------
Const MAX_DEFINICIONES = 500;
Const MAX_INCLUSIONES = 50;

//Tipos de definiciones
Const TD_CON = 0;    //Definición de contexto
Const TD_DIR = 1;    //Definición directaD

Type

{ Tdefinicion }

Tdefinicion  = class   //estructura de definicion
   //Notar que esta clase accede a los objetos globales PProc y PErr
   nom: String;       //nombre de la definicion
   tip: Integer;      //Tipo de definición
   con: TPosCont;     //Ubicación donde está el texto de la definicion
   txt: String;       //Texto de la definición (Solo las de Tipo directo)
   procedure Expandir;  //espande la definición y escribe en la salida
   function ValTxt: string;  //devuelve la defición expandida
   procedure FijTxt(t: string); //fija un valor de texto a la definición
   procedure LeeElementos(elem: TStringList);  //lee definición como lista
End;

Tinclusion = class
   arc: string;  //archivo incluido
   pad: string;  //archivo padre
end;

//Define una lista de definiciones
TListaDef = specialize TFPGObjectList<Tdefinicion>;
TListaInc = specialize TFPGObjectList<Tinclusion>;
//----------Manejo de inclusiones-------------

var
  cad_con: string;    //variable interna para cadena de conexión.
  definiciones: TListaDef;   //Lista de definiciones
  inclusiones: TListaInc;  //Lista de inclusiones
  arcEnt : string;    //archivo de entrada

procedure decodificar_PARA; forward;
procedure preProcesarCad(txt: String; archivo: String); forward;
procedure preProcesarArc(archivo: String); forward;
procedure decodificar_INCLUIR(IncluirMult: Boolean = False); forward;
Function CogExpresion(jerar: Integer): Texpre; forward;
Function definido(ident: String): Tdefinicion; forward;
Function preProcFuncion(identif: String): Boolean; forward;
/////////////////////// Funciones para evaluación de expresiones ///////////////////////
Function CogOperando: Texpre;
//Coge un operando en la posición actual del contenido
var c : String;
    cad : String;
    num : single;
    exp : Texpre;
    def : Tdefinicion;
begin
    PPro.CapBlancos;   //quita blancos iniciales
    c := UpCase(PPro.VerCar);

    {If EsFuncion() Then   //Sólo funciones predefinidas
        CogOperando := CogFuncion;
    Else} If PPro.CogNumero(num) then begin
       CogOperando.txt := '#';   //indica número
       CogOperando.valNum := num;   //fija tipo a número
       CogOperando.cat := COP_CONST;
    end Else If PPro.CogCadena(cad) Then begin   //Constante cadena
       CogOperando.txt := '?';   //indica cadena
       CogOperando.valTxt := cad;    //fija tipo a número
       CogOperando.cat := COP_CONST;
    end Else If c = '(' Then begin
       PPro.CogCar;         //coge paréntesis
       exp := CogExpresion(0);
       if PErr.HayError then exit;
       CogOperando := exp;
       If PPro.Capturar(')') Then begin
           Exit;
       end Else begin
          PErr.GenError('Error en expresión. Se esperaba ")"', PPro.PosAct);
          Exit;       //error
       end;
    end else If PPro.CogIdentificador(cad) Then begin
        //puede ser definición o identificador desconocido
        def := definido(cad);
        if def = nil then begin
           PErr.GenError('Identificador desconocido: ' + cad, PPro.PosAct);
           Exit;
        end;
        //es definición, se considera como una variable
        CogOperando.txt := 'd';  //indica definición
        CogOperando.valTxt := def.ValTxt;  //expande directamente
//        CogOperando.def := def;   //guarda la referencia a la definición
        CogOperando.cat := COP_DEFINIC;
    end  Else
        Exit;  //no devuelve nada
End;
Function CogExpresion(jerar: Integer): Texpre;
//Toma una expresión completa, en la posición actual del contenido
var Op1, Op2 : Texpre;
    opr, opr2 : String;
    jerOpr, jerOpr2: Integer;
    pos1, pos2 : TPosCont;
begin
    PPro.CapBlancos;  //quita blancos iniciales
    Op1 := CogOperando;  //error
    If Op1.txt = '' Then
        Exit;
    opr := PPro.cogOperador;
    If opr = '' Then begin
        CogExpresion := Op1;
        Exit
    End;
    jerOpr := PPro.jerOp(opr);     //Hay operador, tomar su jerarquía
    //-------------------------- ¿Delimitada por jerarquía? ---------------------
    If jerOpr <= jerar Then begin  //es menor que la que sigue, expres.
        CogExpresion := Op1;  //solo devuelve el único operando que leyó
        Exit;
    End;
    While opr <> '' do begin
        pos1 := PPro.PosAct;    //Guarda por si lo necesita
        Op2 := CogOperando;
        If Op2.txt = '' Then   begin //error
           PErr.GenError('Error en expresión. Se esperaba operando.', PPro.PosAct);
           Exit;
        end;
        pos2 := PPro.PosAct;    //Guarda por si lo necesita
        opr2 := PPro.cogOperador;
        If opr2 <> '' Then begin  //Hay otro operador
            jerOpr2 := PPro.jerOp(opr2);
            //¿Delimitado por jerarquía de operador?
            If jerOpr2 <= jerar Then begin  //sigue uno de menor jerarquía, hay que salir
                PPro.PosAct := pos2;   //antes de coger el operador
                CogExpresion := PPro.Evaluar(Op1, opr, Op2);
                Exit;
            End;
            If jerOpr2 > jerOpr Then begin    //y es de mayor jerarquía, retrocede
                PPro.PosAct := pos1;        //retrocede
                Op2 := CogExpresion(jerOpr);        //evalua primero
                opr2 := PPro.cogOperador;    //actualiza el siguiente operador
            End;
        End;

        Op1 := PPro.Evaluar(Op1, opr, Op2);    //evalua resultado
        if PErr.HayError then exit;
        opr := opr2;
        jerOpr := PPro.jerOp(opr);    //actualiza operador anterior
    end;
    CogExpresion := Op1;
    CogExpresion.cat := COP_EXPRESION;
End;

Function incluido(arc0: String): Tinclusion;
//Devuelve la referencia a una inclusión. Si no esta incluido devuelve NIL.
var s: Tinclusion;
begin
   Result := nil;   //valor por defecto
   For s in inclusiones do
      If UpCase(arc0) = s.arc Then  begin  //encontro
         Result := s;
         Exit;
      End;
End;
Function definido(ident: String): Tdefinicion;
//devuelve la referencia a una definición. Si no esta definido devuelve NIL.
var s: Tdefinicion;
begin
   Result := nil;   //valor por defecto
   For s in definiciones do
      If UpCase(ident) = s.nom Then  begin  //encontró
         Result := s;
         Exit;
      End;
End;

//************************************************************************************
//**************************** MANEJO DE DEFINICIONES ********************************
Function CreaDefinicionCon(nom: String; def: Tdefinicion = nil): Tdefinicion;
//Ceea la nueva definición de contexto. El contenido debe leerse luego.
//Si se especifica el índice se sobreescriben los datos.
//Devuelve la definición creada.
begin
    If def = nil Then begin   //Se debe crear nueva definición
        If definiciones.Count >= MAX_DEFINICIONES Then begin
            PErr.GenError('Demasiadas definiciones.', PPro.PosAct);
            Exit;
        End;
        def := Tdefinicion.Create;   //crea una nueva
        definiciones.Add(def);   //la agrega a la lista
    End;
    //Se actualizan los datos
    def.nom := UpCase(nom);   //guarda mayuscula
    def.tip := TD_CON    ;   //de tipo contexto
    def.txt := '';
    //Se guarda la posición donde empieza el cuerpo, tiene que ser después de la palabra COMO
    def.con := PPro.PosAct;
    Result := def;
End;
Function CreaDefinicionDir(nom: String; txt: String; def: Tdefinicion = nil): Tdefinicion;
{Crea una definición directa. Si se especifica  "def", se sobreescriben los datos
 de la definición. Si no se especifica se genera una definición nueva.
 Devuelve la definición directa creada.}
begin
    If def = nil Then begin   //Se debe crear nueva definición
        If definiciones.Count >= MAX_DEFINICIONES Then begin
            PErr.GenError('Demasiadas definiciones.', PPro.PosAct);
            Exit;
        End;
        def := Tdefinicion.Create;  //crea una nueva
        definiciones.Add(def);     //la agrega a la lista
    End;
    //Se actualizan los datos
    def.nom := UpCase(nom);   //guarda mayuscula
    def.tip := TD_DIR ;       //de tipo directo
    def.txt := txt;
    //Se guarda la posición donde empieza el cuerpo, tiene que ser después de la palabra IGUAL
    def.con := PPro.PosAct;
    Result := def;
End;
procedure EliminaDefinicion(ind: Tdefinicion);
//Elimina una definición de la memoria. Se le debe proporcionar la referencia.
begin
    If ind = nil Then Exit;
    definiciones.Remove(ind);
End;

procedure ProcCaracter(escribir: boolean = true);
//Procesa un caracter del contexto de entrada.
//Devuelve el caracter procesado.
var uc: char;
    com: string[2];
begin
    com := PPro.VerCarN(2);
    If com = '--' Then begin  //es comentario de línea
       PPro.CogerHastaFinLinea;
       if escribir then PPro.EscribeSalto;     //Escribe el salto quitado
    end Else if com = '/*' then begin //comentario de bloque
       PPro.CogerComent;   //toma todo el comentario
    end Else begin
       uc := PPro.CogCar;   //último caracter
       if escribir then PPro.PonCar(uc);   //escribe siguiente caracter, si no hay error
    End;
End;

function ExpandirDefinido(nom: string): boolean;
{Verifica si el identificador es una definición y de ser así lo expande y devuelve
 TRUE. De otra forma devuelve FALSE.}
var def: Tdefinicion;   //numero de definicion
begin
    def := definido(nom);
    If def = nil Then begin
       Result := false;  //no lo encuentra, devuelve falso
    end else begin  //lo expande
       def.Expandir;   //si hay errores se devuelven
       Result := true;
    End;
End;
procedure BuscaFINDEFINIR(posDef: TPosCont; nomDef: string);
{Busca el delimitador FINDEFINIR en el contexto actual. Termina al encontrar el
 delimitador, o al encontrar algún error}
var
   idenM: String;
begin
   nomDef := UpCase(nomDef);   //pasa a mayúscula
   //busca final de bloque $DEFINIR o $REDEF, sin escribir en salida.
   While Not PPro.FinCont do begin
      If PPro.CogIdentificador(idenM) Then begin
         If idenM = nomDef Then begin    //verificación de llamada a la definiicón
            PErr.GenError('Llamada recursiva a "' + nomDef + '" en definición.', PPro.PosAct);
            Exit;
         End else If idenM = 'FINDEFINIR' Then begin
            PPro.CogIdentificador;   //coge el "FINDEFINIR"
            PPro.CapBlancos;      //quita blancos hasta siguiente identificador
            exit;
         end else If idenM = '$DEFINIR' Then begin     //encontró otro definir
            PErr.GenError('Se esperaba "FINDEFINIR" de definición. ', posDef);
            Exit;
         end else If idenM = '$REDEF' Then begin     //encontró otro definir
            PErr.GenError('Se esperaba "FINDEFINIR" de definición. ', posDef);
            Exit;
         End;
         //hay identificador pero no es reconocido. Lo ignora.
      end Else begin
         ProcCaracter(false);   //va leyendo sin escribir
      end;
   end;
   //se ha llegado al fin de archivo, sin encontrar delimitador
   PErr.GenError('Inesperado fin de archivo. No se encontro "FINDEFINIR" de definición. ', posDef);
end;
procedure decodificar_DEFINIR;
//Decodifica la instruccion      $DEFINIR var COMO <bloque> FINDEFINIR
var defi : String;
    temp : String;
    posDef: TPosCont;         //posición temporal del contexto
begin
    PErr.IniError;
    PPro.CapBlancos;   //coge espacios después de "$DEFINIR"
    posDef := PPro.PosAct;  //guarda posición
    defi := PPro.CogIdentificador;   //coge nombre de la variable
    If defi = '' Then begin
      PErr.GenError('Se esperaba identificador después de $DEFINIR', PPro.PosAct);
      Exit;
    end;
    If definido(defi) <> nil Then begin    //ya esta definida esa variable
        PErr.GenError('Ya esta definido el identificador ' + defi, PPro.PosAct);
        Exit;
    End;
    PPro.CapBlancos;   //quita blancos iniciales
    If PPro.VerCar = '=' Then  begin //Definición directa
        PPro.CogCar;   //coge el "="
//        If UpCase(VerIdentificador) = '$CONSULTAR' Then begin
//            temp := decodificar_CONSULTAR(True);
//            If HayError Then Exit;
//            CreaDefinicionDir(UpCase(defi), temp);
//        end Else begin   //Definición directa normal
            temp := PPro.CogerHastaComent;
            CreaDefinicionDir(defi, temp);
//        End;
        Exit;
    end Else If PPro.VerIdentifM = 'COMO' Then
        PPro.CogIdentificador
    Else begin
        PErr.GenError('Se esperaba "COMO" o "=" después de ' + defi, PPro.PosAct);
        Exit;
    End;
    //Crea la nueva definición y empieza lectura de contenido
    CreaDefinicionCon(defi);
    If PErr.HayError Then Exit;
    BuscaFINDEFINIR(posDef, defi);   //Actualiza Error
End;
procedure decodificar_REDEF;
//Decodifica la instruccion      $REDEF var COMO <bloque> FINDEFINIR
var defi : String; def: Tdefinicion;
    temp : String;
    posDef: TPosCont;         //posición temporal del contexto
begin
   PErr.IniError;
   PPro.CapBlancos;   //coge espacios después de "$DEFINIR"
   posDef := PPro.PosAct;  //guarda posición
   defi := PPro.CogIdentificador;   //coge nombre de la variable
    If defi = '' Then begin
      PErr.GenError('Se esperaba identificador después de $REDEF', PPro.PosAct);
      Exit;
    end;
    def := definido(defi);  //toma definición
    PPro.CapBlancos;     //quita blancos iniciales
    If PPro.VerCar = '=' Then  begin //Definición directa
        PPro.CogCar;   //coge el "="{ TODO : No se guarda información del archivo donde se lee esta definición  }
//        If UpCase(VerIdentificador) = '$CONSULTAR' Then begin
//            temp := decodificar_CONSULTAR(True);
//            If HayError Then Exit;
//            CreaDefinicionDir(UpCase(defi), temp);
//        end Else begin   //Definición directa normal
            temp := PPro.CogerHastaComent;
            CreaDefinicionDir(defi, temp, def);
//        End;
        Exit;
    end Else If PPro.VerIdentifM = 'COMO' Then
        PPro.CogIdentificador
    Else begin
        PErr.GenError('Se esperaba "COMO" o "=" después de ' + defi, PPro.PosAct);
        Exit;
    End;
    //Crea o actualiza la definición y empieza lectura de contenido
    CreaDefinicionCon(defi, def);
    If PErr.HayError Then Exit;
    BuscaFINDEFINIR(posDef, defi);   //Actualiza Error
End;
function procesarHastaDelim(delims: String): string;
{Procesa el contexto actual hasta encontrar uno de los delimitadores, el fin del contexto
 o se genere algún error. Si termina por encontrar alguno de los delimitadores, coge el
 identificador y devuelve el delimitador encontrado (en mayúscula). La lista de
 delimitadores se debe dar separada por comas.  La comparación con los identificadores
 se hace ignorando la caja.}
var l_delims : TstringList;
    iden, idenM: String;
    uc : char;  //último caracter
begin
    Result := '';  //inicia
    l_delims := TStringList.Create;  //crea lista
    //convierete lista de cadena en TSTringList
    l_delims.Delimiter:=',';
    l_delims.DelimitedText:=delims;
    //explora el contexto
    While Not PPRo.FinCont And Not PErr.HayError do begin
        If PPro.CogIdentificador(iden, idenM, uc) Then begin
           //-------------aqui se procesa el comando identificador
           If idenM = '$INCLUIR' Then  //palabra reservada
              decodificar_INCLUIR
//           Else If idenM = '$CONSULTAR' Then  //palabra reservada
//              decodificar_CONSULTAR
           Else If idenM = '$PARA' Then  //palabra reservada
              decodificar_PARA
           Else If preProcFuncion(idenM) Then   //preprocesa función
               //no hace nada porque ya se hizo
           else if ExpandirDefinido(idenM) then
              //no hace nada porque ya lo expandió
           else If l_delims.IndexOf(idenM) <> -1 Then begin  //busca delimitador
              If uc = ' ' Then PPro.SacCar; //si último caracter fue espacio, retrocede.
              Result:= idenM; break  end    //encontro delimitador, sale.
           else //hay identificador pero no es reconocido
              PPro.Escribe(iden);    //escribe identificador
        End Else    //no es inicio de identificador
           ProcCaracter;
    end;
    //aquí puede haber llegado por error, por fin de contexto o por haber encontrado
    //algún delimitador.
    l_delims.Free;
End;

function procesarCuerpoPARA(vari: String; con: String;
           lPar: TStringList; lCon: TStringList; n1, n2: Integer; delims: string): string;
{Procesa el cuerpo del $PARA para el caso "PRIMERO ... " O "HACER ...".
 Lee el lazao iterando en lPar y lCon, desde n1 hasta n2 hasta encontrar algúno de los
 delimitadores indicados. Devuelve el demimitador encontrado si no hubo error.}
var i: Integer;
    posinic: TPosCont;
    npa, nco: Tdefinicion;   //para manejar el reemplazo
begin
    posinic := PPro.PosAct;       //Guarda posición
    npa := nil; nco := nil;  //inicia índices
    For i := n1 To n2 do begin
        PPro.PosAct := posinic;   //Mueve al inicio
        //crea las variables para esta vuelta del lazo
        npa := CreaDefinicionDir(vari, lPar[i], npa);
        If lCon.Count > 0 Then nco := CreaDefinicionDir(con, lCon[i], nco);
        Result := procesarHastaDelim(delims);  //Guarda delimitador
        if Result <> '' then continue; //encontró el final del bloque, pasa al siguiente
        If PErr.HayError Then break;    //Hubo error, salir
        If PPro.FinCont Then begin     //Se ha llegado al fin de archivo.
            PErr.GenError('Inesperado fin de archivo. No se encontró "FINPARA" del "PARA"', posinic);
            break;
        End;
    end;
    //aquí llega por error o por haber encontrado al delimitador
    EliminaDefinicion(npa); //limpia la memoria
    EliminaDefinicion(nco); //limpia la memoria
End;

procedure decodificar_PARA;
{Decodifica la instruccion      PARA var EN var1,var2,...varn [CON cond EN cond1,cond2,...condN] HACER
                                   <bloque>
                               FINPARA}
var vari : String;       //variable "vari"
    con : String ;       // variable "con"
    lPar : TStringList;   //lista de ítems de para
    lCon : TStringList;   //lista de ítems de con
    tmp : String;

  procedure VerificSiDefLista(var lst : TStringList);
  //Verifica si la lista de elementos es un lista definición, y si lo es, la expande.
  var def: Tdefinicion;
  begin
     If (lst.Count = 1) then begin   //un solo elemento
        //puede ser definición lista
        def := definido(lst[0]);  //la busca
        if def <> nil Then begin    //es una definición lista
           lst.Clear;   //la limpia
           def.LeeElementos(lst);
           If PErr.HayError Then Exit;
           If lst.Count = 0 Then begin      //esta vacía
              PErr.GenError('La lista del $PARA no contiene elementos.', PPro.PosAct);
              Exit;
           end;
        End;
     End;
  End;

begin
  lPar := TStringList.Create;
  lCon := TStringList.Create;
  try
    PErr.IniError;
    PPro.CapBlancos;  //quita blancos después de $PARA
    //---------------------- coge la lista del "EN" -------------------------------
    vari := PPro.CogIdentificador;     //coge nombre de la variable
    If vari = '' Then begin
        PErr.GenError('Se esperaba variable después del PARA', PPro.PosAct);
        Exit;
    End;
    PPro.CapBlancos;  //quita blancos después de $PARA
    If UpCase(PPro.CogIdentificador()) <> 'EN' Then begin
        Perr.GenError('Se esperaba palabra "EN" después de ' + vari, PPro.PosAct);
        Exit;
    End;
    tmp := PPro.CogerLista(lPar,'HACER,CON,PRIMERO');  //toma lista de elementos EN ...
    If lPar.Count = 0 Then begin
        PErr.GenError('Se esperaba lista de elementos después del "EN"', PPro.PosAct);
        Exit;
    End;
    If PPro.FinCont Then begin
        PErr.GenError('Inesperado fin de archivo. Se esperaba fin de sentencia PARA..EN..HACER.', PPro.PosAct);
        Exit;
    End;
    VerificSiDefLista(lPar);
    If PErr.HayError Then Exit;
    //-------------------------- coge secuencia CON ----------------------------------------
    //CON cond EN cond1,cond2,...condN,  si es que existe
    If tmp = 'CON' Then begin
        PPro.CapBlancos;          //quita blancos
        con := PPro.CogIdentificador;     //coge nombre de la variable cond
        If con = '' Then begin
            PErr.GenError('Se esperaba variable después del CON', PPro.PosAct);
            Exit;
        End;
        PPro.CapBlancos;          //quita blancos
        If UpCase(PPro.CogIdentificador) <> 'EN' Then begin
            PErr.GenError('Se esperaba palabra "EN" después de ' + con, PPro.PosAct);
            Exit;
        End;
        tmp := PPro.CogerLista(lCon,'HACER,PRIMERO');  //toma lista de elementos EN ...
        If lCon.Count = 0 Then begin
            PErr.GenError('Se esperaba lista de elementos después de "CON ... EN"', PPro.PosAct);
            Exit;
        End;
        If PPro.FinCont Then begin
            PErr.GenError('Inesperado fin de archivo. Se esperaba fin de sentencia PARA..EN..CON..EN..HACER.', PPro.PosAct);
            Exit;
        End;
        VerificSiDefLista(lCon);
        If PErr.HayError Then Exit;
        If lCon.Count < lPar.Count Then begin
            PErr.GenError('Se esperaban ' + IntToStr(lPar.count) + ' variables en sentencia ..CON..EN..HACER.', PPro.PosAct);
            Exit;
        End;
    End;
    //-------------------------------continua con el cuerpo del HACER---------------------------------
    If tmp = 'HACER' Then begin   //tmp debe tener el último delimitador
        //Expande lazo
        procesarCuerpoPARA(vari, con, lPar, lCon, 0, lPar.Count-1,'FINPARA');
        //Puede terminar con Error
        PPro.CapBlancos;  //quita blancos hasta siguiente identificador
    end Else If tmp = 'PRIMERO' Then begin //sentencia con "PRIMERO"
        //Expande lazo
        tmp := procesarCuerpoPARA(vari, con, lPar, lCon, 0, 0,'FINPARA,HACER');
        If PErr.HayError Then Exit;   //sale
        If tmp = 'HACER' Then begin  //terminó con HACER
            //procesa sin considerar el primer elemento
            procesarCuerpoPARA(vari, con, lPar, lCon, 1, lPar.Count-1,'FINPARA');
            If PErr.HayError Then Exit;
        End;
        //se supone que terminó con FINPARA
        PPro.CapBlancos;  //quita blancos hasta siguiente identificador
    end Else begin
        PErr.GenError('Se esperaba palabra reservada "HACER"', PPro.PosAct);
        Exit;
    End;
  finally
    lPar.Free; lCon.Free;  //libera listas
  end;
End;
procedure decodificar_INCLUIR(IncluirMult: Boolean = False);
{Decodifica la instruccion      INCLUIR <archivo>
 que incluye un archivo dentro del archivo principal
 "IncluirMult" indica que se puede incluir múltiples veces el mismo
 archivo.}
var arch : String;
    inc : Tinclusion;
begin
    PErr.IniError;
    arch := PPRo.coger_ruta;
    arch := Trim(arch);
//    PPro.quitar_comentario(arch);    //quita si hay comentarios "--"
    If arch = '' Then begin
        PErr.GenError('Se esperaba nombre de archivo en INCLUIR', PPRo.PosAct);
        Exit;
    End;
    If Pos('\', arch) = 0 Then begin    //si no se especifica camino
        //le agrega camino de archivo de entrada
        If Pos('\', PPro.PosAct.arc) <> 0 Then  //Si es que tiene ruta
            arch := ExtractFilePath(PPro.PosAct.arc) + arch;
    End;
    //se verifica si ya se ha incluido el archivo
    If (incluido(arch)<>nil) And Not IncluirMult Then begin
        //Ya esta incluido el archivo
        Exit; //sale, no lo vuelve a incluir
    End;
    //Verifica si existe
    If not FIleExists(arch) Then begin
        PErr.GenError('No Existe Archivo a INCLUIR: ' + arch, PPRo.PosAct);
        Exit;
    End;
    //Finalmente lo incluye
    If inclusiones.Count > MAX_INCLUSIONES Then begin
        PErr.GenError('Demasiados Archivos Incluidos.', PPRo.PosAct);
        Exit;
    End;
    inc := Tinclusion.Create;
    inc.arc := UpCase(arch);     //guarda nombre mayuscula
    inc.pad := PPro.PosAct.arc;  //guarda mnombre de padre
    inclusiones.Add(inc);        //lo agrega

    preProcesarArc(arch);        //preprocesa
    //se ha llegado al fin de archivo incluido, puede haber habido Error.
End;

procedure decodificar_FECHA_ACTUAL;
//Decodifica la función fecha_actual(desplazamiento, formato)
var desplaz : single;       //desplazamiento de fecha
    formato, temp : String;
    nsem : byte;
    e : Texpre;
begin
    If PPro.Capturar('(') = False Then begin
        PErr.GenError('Se esperaba "(" después de la función $FECHA_ACTUAL()', PPro.PosAct);
        Exit;
    End;
    e := CogExpresion(0);
    If PErr.HayError Then Exit;

    desplaz := e.valNum;
    If PPro.Capturar(',') = False Then begin
        PErr.GenError('Se esperaba ","', PPro.PosAct);
        Exit;
    End;
    formato := PPRo.CogCadena;
    If PErr.HayError Then Exit;
    If PPro.Capturar(')') = False Then begin
        PErr.GenError('Se esperaba ")"', PPro.PosAct);
        Exit;
    End;
    //verifica si hay "ww" en formato y lo reemplaza
    temp := Format('%2d',[WeekOfTheYear(Now + desplaz)]);
    formato := StringReplace(formato, 'ww', temp, [rfReplaceAll, rfIgnoreCase]);
    //escribe fecha actual
    DateTimeToString(temp, formato, Now + desplaz );
    PPro.Escribe(temp);
End;
procedure decodificar_EXPR;
//Decodifica la función $expr(expresion)
var
    e : Texpre;
begin
    If PPro.Capturar('(') = False Then begin
       PErr.GenError('Se esperaba "(" después de la función $EXPR()', PPro.PosAct);
       Exit;
    End;
    e := CogExpresion(0);
    If PErr.HayError Then Exit;
    If PPro.Capturar(')') = False Then begin
        PErr.GenError('Se esperaba ")" después de la función $EXPR()', PPro.PosAct);
        Exit;
    End;
    PPro.Escribe(e.valTxt);
End;
procedure decodificar_FORMATO;
//Decodifica la función $formato(expresion, formato)
var e: Texpre;
//    expresion_cad: String; //expresion de cadena
    expresion_num: Single; //expresion numerica
    expresion_fec: TDateTime;
    formato : String;
    temp: string;

   function LeeFecha(e: Texpre): TDateTime;
   //procesa el caso en el que la expresión es de tipo "ww99/9999". Se supone que "e" es cadena.
   var cad: string;
       sem, ano : Integer;
   begin
      cad := e.valTxt;
      If (length(cad) = 8) and (cad[1] = 'w') and (cad[4] = '/') Then begin
         //debe ser formato de semana: "ww99/9999" verifica
         If not TryStrToInt(copy(cad, 2, 2),sem) or
            not TryStrToInt(copy(cad, 5, 4),ano) Then begin
             PErr.GenError('Error en formato de semana. El formato es: w##/####', PPro.PosAct);
             Exit;
         End;
         //devuvelve la fecha solicitada
         Result := EncodeDateWeek(ano, sem);
      end else begin  //debe ser un formato de fecha normal
         result := e.valFec;  //Puede dar error
         if Perr.HayError then begin   //precisa el error
            PErr.GenError('Fecha inválida', PPro.PosAct);
            Exit;
         end;
      end;
   end;

begin
    If PPro.Capturar('(') = False then begin
       PErr.GenError('Se esperaba "(" después de la función $FORMATO()', PPro.PosAct);
       Exit;
    End;
    //lee primer parámetro
    e := CogExpresion(0);   //puede ser constante o definición
    If PErr.HayError Then Exit;

    if e.tip = TIP_CAD then begin
       //la cadena debe ser una fecha
       //Aquí se tiene siempre una cadena
       expresion_fec := LeeFecha(e);   //toma fecha
       if PErr.HayError then exit;     //puede dar error
       If PPro.Capturar(',') = False Then begin
           PErr.GenError('Se esperaba ","', PPro.PosAct);
           Exit;
       End;
       //toma segundo parámetro
       formato := PPro.CogCadena;  //toma el formato
       If PErr.HayError Then Exit;
       If PPro.Capturar(')') = False Then begin
           PErr.GenError('Se esperaba ")"', PPro.PosAct);
           Exit;
       End;
       //verifica si hay "ww" en formato y lo reemplaza
       temp := Format('%2d',[WeekOfTheYear(expresion_fec)]);
       formato := StringReplace(formato, 'ww', temp, [rfReplaceAll, rfIgnoreCase]);
       //escribe la fecha
       DateTimeToString(temp, formato, expresion_fec);
       PPro.Escribe(temp);   //escribe fecha actual
    end else if e.tip =  TIP_NUM then begin

    end else begin
      //Solo se maneja tipos de dato de cadena (fecha) { TODO : Incluir formato para números }
      PErr.GenError('Se esperaba expresión de tipo cadena-fecha', PPro.PosAct);
      Exit;
    end;
End;

Function preProcFuncion(identif: String): Boolean;
//Hace el preprocesamiento de una función
//Si no era una función válida, devuleve falso
var temp: String;
begin
    preProcFuncion := True;   //se asume que es función
    If identif = '$FECHA_ACTUAL' Then     //funcion fecha_actual()
        decodificar_FECHA_ACTUAL
    Else If identif = '$FORMATO' Then     //funcion formato()
        decodificar_FORMATO
    Else {If identif = '$INTERVALO_SEMANA' Then    //funcion intervalo_semana()
        decodificar_INTERVALO_SEMANA
    Else If identif = '$PSQL_REINIC' Then     //funcion psql_reinic()
        decodificar_PSQL_REINIC
    Else If identif = '$COLUMNAS' Then     //funcion columna()
        decodificar_COLUMNAS
    Else If identif = '$INDICES' Then     //funcion indices()
        decodificar_INDICES
    Else If identif = '$INFOVISTA' Then     //funcion infovista()
        decodificar_INFOVISTA
    Else If identif = '$INFOTABLA' Then     //funcion infotabla()
        decodificar_INFOTABLA
    Else }If identif = '$NOM_ACTUAL' Then begin  //variable de nombre actual de archivo
        If PPRo.VerCarN(2) = '()' Then
           begin PPro.CogCar; PPro.CogCar end;   //para facilitar el uso de esta función
        temp := ChangeFileExt(ExtractFileName(arcEnt),'');  //usa siempre el archivo de entrada
        PPro.Escribe(temp);   //escribe solo el nombre de archivo
    end
    Else If identif = '$DIR_ACTUAL' Then begin   //variable de nombre actual del directorio
        If PPro.VerCarN(2) = '()' Then
           begin PPro.CogCar; PPro.CogCar end;   //para facilitar el uso de esta función
        temp := ExtractFilePath(arcEnt);   //usa siempre el archivo de entrada
        if temp = '' then exit;  //no hay ruta, sale
        If temp[length(temp)] = '\' Then temp := copy(temp, 1, Length(temp) - 1);
        PPro.Escribe(temp);     //escribe solo el camino sin "\"
    end Else If identif = '$EXPR' Then     //funcion expresión()
        decodificar_EXPR
//    Else If identif = '$LEE_CADENA' Then     //funcion expresión()
//        decodificar_LEECADENA
    Else
        //No era función
        preProcFuncion := False;

End;
{procedure decodificar_CONNECT;
//Procesa la sentecnia CONNECT para determinar la cadena de conexión que se usará en la
//consulta
begin
  If cad_con = '' Then begin  //Es la primera cadena de conexión de la consulta
     //No se escribe, sólo se lee para usarla en la llamada al SQLPLUS
     cad_con := Trim(PPro.CogerHastaComent);
     if cad_con = '' then begin
        PErr.GenError('Se esperaba cadena de conexión.', PPro.PosAct);
        exit;
     end;
     //quita punto y coma final si existe
     If cad_con[length(cad_con)] = ';' Then
        cad_con := copy(cad_con, 1, Length(cad_con) - 1);
  end else   //no es la primera cadena de conexión
     PPro.Escribe('CONNECT');    //escribe CONNECT
end;}
procedure preProcesarAct;
//Realiza el preprocesamiento del Contenido actual
var iden, idenM: String;
    uc : char;
begin
   //-----------------------------------------
   While Not PPro.FinCont do begin
      If PErr.HayError Then break;
      If PPro.CogIdentificador(iden, idenM, uc) Then begin
         //-------------aqui se procesa el identificadorencontrado
         {If idenM = 'CONNECT' Then
            decodificar_CONNECT
         Else }If idenM = '$DEFINIR' Then  //palabra reservada
            decodificar_DEFINIR
         Else If idenM = '$REDEF' Then  //palabra reservada
            decodificar_REDEF
         Else If idenM = '$INCLUIR' Then  //palabra reservada
            decodificar_INCLUIR
//           ElseIf idenM = '$CONSULTAR' Then  //palabra reservada
//               decodificar_CONSULTAR
         Else If idenM = '$PARA' Then  //palabra reservada
            decodificar_PARA
         Else If preProcFuncion(idenM) Then   //preprocesa función
            //no hace nada porque ya se hizo
         else if ExpandirDefinido(idenM) then
            //no hace nada porque ya lo expandió
         else //hay identificador pero no es reconocido
            PPro.Escribe(iden);    //escribe identificador
      end else
         ProcCaracter;
   end;
End;
procedure preProcesarCad(txt: String; archivo: String);
//Preprocesa una cadena de texto. No modifica la posición ni el contenido actual
//Escribe su salida en el dispositivo de salida actual.
var con: TPosCont;
begin
    PErr.IniError;
    con := PPro.PosAct;   //Guarda posición y contenido actual
    PPro.NuevoContexEntTxt(txt, trim(archivo));   //Crea nuevo contenido
    If PErr.HayError Then Exit;
    preProcesarAct;
    PPro.PosAct := con;   //recupera el contenido actual
End;
procedure preProcesarArc(archivo: String);
//Preprocesa un archivo de texto. No modifica la posición ni el contenido actual
//Escribe su salida en el dispositivo de salida actual.
var con: TPosCont;
begin
    PErr.IniError;
    con := PPro.PosAct;   //Guarda posición y contenido actual
    PPro.NuevoContexEntArc(Trim(archivo));   //Crea nuevo contenido
    If PErr.HayError Then  Exit;
    preProcesarAct;
    PPro.PosAct := con;   //recupera el contenido actual
    //¿¿¿Y no destruye el contexto actual???
End;
procedure InicPreproc;
//Inicia el preprocesamiento
begin
  Perr.IniError;
  //preprocesa
  cad_con := '';       //Inicia la primera cadena de conexión de la consulta
  definiciones.Clear;  //inicializa el numero de definiciones "$DEFINIR"
  inclusiones.Clear;   //inicializa el numero de inclusiones "$INCLUIR"
  PPro.Iniciar;        //Inicia contextos para trabajo
  PPro.NuevoContexSal;  //Crea contexto de salida
  //variable predefinida
  CreaDefinicionDir('$horas', '00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23');
  CreaDefinicionDir('$meses', '01 02 03 04 05 06 07 08 09 10 11 12');
end;
procedure PreProcesar(arc: String; txt: String; var cadcon0: string);
{Realiza el preprocesamiento de un archivo o un texto. Si "txt" <> "", se procesa "txt",
 de otra forma, procesa el archivo "arc". La salida preprocesada se debe extraer de
 PPro.
 Si se encuentra una sentencia de tip CONNECT en la consulta, se devolverá la cadena
 de conexión, en "cadcon0", de otra forma se devolverá una cadena vacía.
 Punto de entrada único para el preprocesamiento.}
begin
  cadcon0 := '';
  arcEnt := Arc;  //Guarda el nombre del archivo de entrada para el procesamiento.
  InicPreproc;
  If txt = '' Then     //Procesa archivo
    preProcesarArc(arcEnt)
  Else                 //Procesa cadena
    preProcesarCad(txt,arcEnt);  {indica archivo de entrada para poder procesar las funciones
                                  $Dir_actual y $Nom_actual}
  //Si hubo error, sale actualizando variables de error
  if PErr.HayError then exit;
  if cad_con <> '' then cadcon0 := cad_con;  //la cadena de conexión de la consulta prevalece
End;

{ Tdefinicion }

procedure Tdefinicion.Expandir;
var con0: TPosCont;   //Posición de contenido
    iden, idenM: String;
    uc : char;  //último caracter
begin
   If tip = TD_DIR Then begin
        //Es de tipo directo, lo expande
        PPro.Escribe(txt);
        Exit;       //Sale no más
   End;
   //Expande definición de tipo contexto
   con0 := PPro.PosAct;   //guarda contenido actual
   PPro.PosAct := con;   //fija a contenido de la definicion
   //expande hasta el bloque DEFINIDO
   If PPro.VerCar = ' ' Then PPro.CogCar;   //ignora el primer espacio si lo hay
   While Not PPro.FinCont do begin
      If PErr.HayError Then break;
      If PPro.CogIdentificador(iden, idenM, uc) Then begin
          //-------------aqui se procesa el comando encontrado
          If idenM = '$INCLUIR' Then    //palabra definida
             decodificar_INCLUIR(True)
//          ElseIf iden = '$CONSULTAR' Then     //palabra reservada
//             Call decodificar_CONSULTAR
          Else If idenM = '$PARA' Then     //palabra reservada
             decodificar_PARA
          Else If preProcFuncion(idenM) Then   //preprocesa función
              //no hace nada porque ya se hizo
          else if ExpandirDefinido(idenM) then
              //no hace nada porque ya lo expandió
          else if idenM = 'FINDEFINIR' Then begin
              If uc = ' ' Then PPro.SacCar; //si último caracter fue espacio, retrocede.
              break;    //terminó su trabajo
          end else //hay identificador pero no es reconocido
              PPro.Escribe(iden);    //escribe identificador
      end Else     //no es inicio de identificador
         ProcCaracter;
   end;
   if PPro.FinCont then begin;
     //este error no deberia producirse ya que se ha examinado anteriormente
     //el archivo y se encontro el FINDEFINIR de otra forma no se habria llegado aqui
     PErr.GenError('Sorpresa!!!. No se encontro "FINDEFINIR" del "$DEFINIR"', PPro.PosAct);
     exit;
   end;
   PPro.PosAct := con0;  //Devuelve al contenido de trabajo
end;
function Tdefinicion.ValTxt: string;
//Devuelve la definición expandida como una cadena.
begin
  If tip = TD_DIR Then
     Result := txt
  else begin   //es de contexto
     PPro.NuevoContexSal;   //crea nuevo contexto de salida
     Expandir;              //expande en nuevo contexto
     //Puede devolver error
     Result := Ppro.cadenaSal;  //copia resultado
 { TODO : Ver y corregir, por qué una definición de tipo
 COMO .. FINDEFINIR de una sola linea, se expande con un salto al final }
     PPro.QuitaContexSal;   //Elimina contexto creado
  end;
end;

procedure Tdefinicion.FijTxt(t: string);
begin
  tip := TD_DIR;   //la fuerza a definición directa, o de otra forma no tiene sentido
                   //cambiar su valor
  txt := t;        //cambia su valor
end;

procedure Tdefinicion.LeeElementos(elem: TStringList);
{Lee los elementos de la definición, y los agrega al areglo "elem". Se debe usar con
 definiciones de tipo lista. Los eleemntos están separados por blancos. }
begin
   PPro.NuevoContexEntTxt(ValTxt, con.arc); //Pone expansión de definición en nuevo contexto
   while not PPro.FinCont do begin       //explora expansión
     elem.Add(Ppro.CogElemento);
   end;
   PPro.QuitaContexEnt;   //elimina el contexto
end;

initialization
   //crea objetos
   definiciones := TListaDef.Create(true);
   inclusiones := TListaInc.Create(true);
   arcEnt := '';  //inicia archivo de entrada

finalization
   definiciones.Free;
   inclusiones.Free;
end.

