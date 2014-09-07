//Parte del código de XpresParser, que se espera que se mantenga fija aún con
//diversas implementaciones.
var
  cIn       : TContexts;   //entrada de datos
  types: TTypes;   //lista de tipos
//    oper: string;      //indica el operador actual
  //tipos de tokens
  vars  : array of Tvar;  //lista de variables
  funcs : array of Tfunc; //lista de funciones
  cons  : array of Tvar;  //lista de constantes
  nIntVar : integer;   //número de variables internas
  nIntFun : integer;   //número de funciones internas
  nIntCon : integer;   //número de constantes internas

//////////////// implementación de métodos  //////////////////
{ TOperator }

function TOperator.CreateOperation(OperadType: Ttype; proc: TProcExecOperat): TxOperation;
var
  r: TxOperation;
begin
  //agrega
  r := TxOperation.Create;
  r.OperatType:=OperadType;
//  r.CodForConst:=codCons;
//  r.CodForVar:=codVar;
//  r.CodForExpr:=codExp;
  r.proc:=proc;
  //agrega
  operations.Add(r);
  Result := r;
end;
function TOperator.FindOperation(typ0: Ttype): TxOperation;
{Busca, si encuentra definida, alguna operación, de este operador con el tipo indicado.
Si no lo encuentra devuelve NIL}
var
  r: TxOperation;
begin
  Result := nil;
  for r in Operations do begin
    if r.OperatType = typ0 then begin
      exit(r);
    end;
  end;
end;
constructor TOperator.Create;
begin
  Operations := TOperations.Create(true);
end;
destructor TOperator.Destroy;
begin
  Operations.Free;
  inherited Destroy;
end;

{ TType }

procedure TType.DefineLoadOperand(codLoad0: string);
begin

end;
function TType.CreateOperator(txt0: string; jer0: byte; name0: string): TOperator;
{Permite crear un nuevo ooperador soportado por este tipo de datos. Si hubo error,
devuelve NIL. En caso normal devuelve una referencia al operador creado}
var
  r: TOperator;  //operador
begin
  //verifica nombre
  if FindOperator(txt0)<>nullOper then begin
    Result := nil;  //indica que hubo error
    exit;
  end;
  //inicia
  r := TOperator.Create;
  r.txt:=txt0;
  r.jer:=jer0;
  r.nom:=name0;
  r.idx:=Operators.Count;
  //agrega
  Operators.Add(r);
  Result := r;
end;
function TType.FindOperator(const Opr: string): TOperator;
//Recibe la cadena de un operador y devuelve una referencia a un objeto Toperator, del
//tipo. Si no está definido el operador para este tipo, devuelve nullOper.
var
  i: Integer;
begin
  Result := nullOper;   //valor por defecto
  for i:=0 to Operators.Count-1 do begin
    if Operators[i].txt = upCase(Opr) then begin
      exit(Operators[i]); //está definido
    end;
  end;
  //no encontró
  Result.txt := Opr;    //para que sepa el operador leído
end;
constructor TType.Create;
begin
  Operators := TOperators.Create(true);  //crea contenedor de Contextos, con control de objetos.
end;
destructor TType.Destroy;
begin
  Operators.Free;
  inherited Destroy;
end;

{ TOperand }

procedure TOperand.Load;
begin
  //llama al evento de carga
  if typ.procLoad <> nil then typ.procLoad(self);
end;
function TOperand.FindOperator(const oper: string): TOperator;
//Recibe la cadena de un operador y devuelve una referencia a un objeto Toperator, del
//operando. Si no está definido el operador para este operando, devuelve nullOper.
begin
  Result := typ.FindOperator(oper);
end;
function TOperand.GetOperator: Toperator;
//Lee del contexto de entrada y toma un operador. Si no encuentra un operador, devuelve NIL.
//Si el operador encontrado no se aplica al operando, devuelve nullOper.
begin
//  cIn.SkipWhites;  No se debe usar "SkipWhites" aquí, porque el lenguaje podría requerir "SkipWhitesNOEOL"
  if cIn.tokType <> tkOperator then exit(nil);
  //hay un operador
  Result := typ.FindOperator(cIn.tok);
  cIn.Next;   //toma el token
end;

//////////////// Funciones Básicas del Parser  //////////////////

function GenError(msg: string): boolean;
{Función de acceso rápido para Perr.GenError(). Pasa como posición a la posición
del contexto actual.
Se declara como función para poder usarla directamente en el exit() de una función}
begin
  if cIn = nil then
    Perr.GenError(msg,'',1)
  else
    Perr.GenError(msg, cIn.PosAct);
end;
function HayError: boolean;
begin
  Result := PErr.HayError;
end;

{function FindVar(varName:string): integer;
//Busca el nombre dado para ver si se trata de una variable definida
//Si encuentra devuelve el índice, sino devuelve -1
var
  tmp: String;
  i: Integer;
begin
  Result := -1;
  tmp := upCase(varName);
  for i:=0 to high(vars) do begin
    if Upcase(vars[i].nom)=tmp then begin
      exit(i);
    end;
  end;
end;}
function FindVar(const varName:string; out idx: integer): boolean;
//Busca el nombre dado para ver si se trata de una variable definida
//Si encuentra devuelve TRUE y actualiza el índice.
var
  tmp: String;
  i: Integer;
begin
  Result := false;
  tmp := upCase(varName);
  for i:=0 to high(vars) do begin
    if Upcase(vars[i].nom)=tmp then begin
      idx := i;
      exit(true);
    end;
  end;
end;
{function FindFunc(funName:string): integer;
//Busca el nombre dado para ver si se trata de una función definida
//Si encuentra devuelve el índice, sino devuelve -1
var
  tmp: String;
  i: Integer;
begin
  Result := -1;
  tmp := upCase(funName);
  for i:=0 to high(funcs) do begin
    if Upcase(funcs[i].name)=tmp then begin
      exit(i);
    end;
  end;
end;}
function FindFunc(const funName:string; out idx: integer): boolean;
//Busca el nombre dado para ver si se trata de una función definida
//Si encuentra devuelve TRUE y actualiza el índice.
var
  tmp: String;
  i: Integer;
begin
  Result := false;
  tmp := upCase(funName);
  for i:=0 to high(funcs) do begin
    if Upcase(funcs[i].name)=tmp then begin
      idx := i;
      exit(true);
    end;
  end;
end;
{function FindCons(conName:string): integer;
//Busca el nombre dado para ver si se trata de una constante definida
//Si encuentra devuelve el índice, sino devuelve -1
var
  tmp: String;
  i: Integer;
begin
  Result := -1;
  tmp := upCase(conName);
  for i:=0 to high(cons) do begin
    if Upcase(cons[i].nom)=tmp then begin
      exit(i);
    end;
  end;
end;}
function FindCons(const conName:string; out idx: integer): boolean;
//Busca el nombre dado para ver si se trata de una constante definida
//Si encuentra devuelve TRUE y actualiza el índice.
var
  tmp: String;
  i: Integer;
begin
  Result := false;
  tmp := upCase(conName);
  for i:=0 to high(cons) do begin
    if Upcase(cons[i].nom)=tmp then begin
      idx := i;
      exit(true);
    end;
  end;
end;
function FindPredefName(name: string): TIdentifType;
//Busca un identificador e indica si ya existe el nombre, sea como variable,
//función o constante.
var i: integer;
begin
  //busca como variable
  if FindVar(name,i) then begin
     exit(idtVar);
  end;
  //busca como función
  if FindFunc(name,i) then begin
     exit(idtFunc);
  end;
  //busca como constante
  if FindCons(name,i) then begin
     exit(idtCons);
  end;
  //no lo encuentra
  exit(idtNone);
end;

//Manejo de tipos
function CreateType(nom0: string; cat0: TtipDato; siz0: smallint): TType;
//Crea una nueva definición de tipo en el compilador. Devuelve referencia al tipo recien creado
var r: TType;
  i: Integer;
begin
  //verifica nombre
  for i:=0 to types.Count-1 do begin
    if types[i].name = nom0 then begin
      GenError('Identificador de tipo duplicado.');
      exit;
    end;
  end;
  //configura nuevo tipo
  r := TType.Create;
  r.name:=nom0;
  r.cat:=cat0;
  r.size:=siz0;
  r.idx:=types.Count;  //toma ubicación
//  r.amb:=;  //debe leer el bloque actual
  //agrega
  types.Add(r);
  Result:=r;   //devuelve índice al tipo
end;
procedure ClearTypes;  //Limpia los tipos
begin
  types.Clear;
end;
procedure ClearVars;
//Limpia todas las variables creadas por el usuario.
begin
  setlength(vars, nIntVar);  //deja las del sistema
end;
procedure ClearAllVars;
//Elimina todas las variables, incluyendo las predefinidas.
begin
  nIntVar := 0;
  setlength(vars,0);
end;
procedure ClearFuncs;
//Limpia todas las funciones creadas por el usuario.
begin
  setlength(funcs,nIntFun);  //deja las del sistema
end;
procedure ClearAllFuncs;
//Elimina todas las funciones, incluyendo las predefinidas.
begin
  nIntFun := 0;
  setlength(funcs,0);
end;
procedure ClearAllConst;
//Elimina todas las funciones, incluyendo las predefinidas.
begin
  nIntCon := 0;
  setlength(cons,0);
end;

function CreateFunction(funName: string; typ: ttype; proc: TProcExecOperat): integer;
//Crea una nueva función y devuelve un índice a la función.
var
  r : Tfunc;
  i, n: Integer;
begin
  //verifica si existe como variable
  if FindVar(funName, i) then begin
    GenError('Identificador duplicado: "' + funName + '".');
    exit;
  end;
  //verifica si existe como constante
  if FindCons(funName, i)then begin
    GenError('Identificador duplicado: "' + funName + '".');
    exit;
  end;
  //puede existir como función, no importa (sobrecarga)
  //registra la función en la tabla
  r.name:= funName;
  r.typ := typ;
  r.proc:= proc;
  setlength(r.pars,0);  //inicia arreglo
  //agrega
  n := high(funcs)+1;
  setlength(funcs, n+1);
  funcs[n] := r;
  Result := n;
end;
function CreateSysFunction(funName: string; typ: ttype; proc: TProcExecOperat): integer;
//Crea una función del sistema o interna. Estas funciones estan siempre disponibles.
//Las funciones internas deben crearse todas al inicio.
begin
  Result := CreateFunction(funName, typ, proc);
  Inc(nIntFun);  //leva la cuenta
end;
procedure CreateFunction(funName, varType: string);
//Define una nueva función en memoria.
var t: ttype;
  hay: Boolean;
begin
  //Verifica el tipo
  hay := false;
  for t in types do begin
    if t.name=varType then begin
       hay:=true; break;
    end;
  end;
  if not hay then begin
    GenError('Tipo "' + varType + '" no definido.');
    exit;
  end;
  CreateFunction(funName, t, nil);
  //Ya encontró tipo, llama a evento
//  if t.procDefine<>nil then t.procDefine(funName, '');
end;
procedure ClearParamsFunc(ifun: integer);  inline;
//Elimina los parámetros de una función
begin
  setlength(funcs[ifun].pars,0);
end;
procedure CreateParam(ifun: integer; name: string; typ: ttype);
//Crea un parámetro para una función
var
  n: Integer;
begin
  //agrega
  n := high(funcs[ifun].pars)+1;
  setlength(funcs[ifun].pars, n+1);
  funcs[ifun].pars[n] := typ;  //agrega referencia
end;
function SameParamsFunctions(iFun1, iFun2: integer): boolean;
//Compara los parámetros de dos funciones. Si tienen el mismo número de
//parámetros y el mismo tipo, devuelve TRUE.
var
  i: Integer;
begin
  Result:=true;  //se asume que son iguales
  if High(funcs[iFun1].pars) <> High(funcs[iFun2].pars) then
    exit(false);   //distinto número de parámetros
  //hay igual número de parámetros, verifica
  for i := 0 to High(funcs[iFun1].pars) do begin
    if funcs[iFun1].pars[i] <> funcs[iFun2].pars[i] then begin
      exit(false);
    end;
  end;
  //si llegó hasta aquí, hay coincidencia, sale con TRUE
end;
type TFindFuncResult = (TFF_NONE, TFF_PARTIAL, TFF_FULL);
function FindFuncWithParams0(const funName: string; var idx: integer;
  idx0 : integer = 1): TFindFuncResult;
{Busca una función que coincida con el nombre "funName" y con los parámetros de funcs[0]
El resultado puede ser:
 TFF_NONE   -> No se encuentra.
 TFF_PARTIAL-> Se encuentra solo el nombre.
 TFF_FULL   -> Se encuentra y coninciden sus parámetros, actualiza "idx".
"i0", es el índice inicial desde donde debe buscar. Permite acelerar las búsquedas, cuando
ya se ha explorado antes.
}
var
  tmp: String;
  i: Integer;
  hayFunc: Boolean;
begin
  Result := TFF_NONE;   //por defecto
  hayFunc := false;
  tmp := UpCase(funName);
  for i:=idx0 to high(funcs) do begin  //no debe empezar 1n 0, porque allí está func[0]
    if Upcase(funcs[i].name)= tmp then begin
      //coincidencia, compara
      hayFunc := true;  //para indicar que encontró el nombre
      if SameParamsFunctions(i,0) then begin
        idx := i;    //devuelve ubicación
        Result := TFF_FULL; //encontró
        exit;
      end;
    end;
  end;
  //si llego hasta aquí es porque no encontró coincidencia
  if hayFunc then begin
    Result := TFF_PARTIAL; //encontró el nombre de la función
  end;
end;
function FindDuplicFunction: boolean;
//Verifica si la última función agregada, está duplicada con alguna de las
//funciones existentes. Permite la sobrecarga. Si encuentra la misma
//función definida 2 o más veces, genera error y devuelve TRUE.
//DEbe llamarse siempre, después de definir una función nueva.
var
  ufun : String;
  i,j,n: Integer;
  tmp: String;
begin
  Result := false;
  n := high(funcs);  //última función
  ufun := funcs[n].name;
  //busca sobrecargadas en las funciones anteriores
  for i:=0 to n-1 do begin
    if funcs[i].name = ufun then begin
      //hay una sobrecargada, verifica tipos de parámetros
      if not SameParamsFunctions(i,n) then break;
      //Tiene igual cantidad de parámetros y del mismo tipo. Genera Error
      tmp := '';
      for j := 0 to High(funcs[i].pars) do begin
        tmp += funcs[n].pars[j].name+', ';
      end;
      if length(tmp)>0 then tmp := copy(tmp,1,length(tmp)-2); //quita coma final
      GenError('Función '+ufun+'( '+tmp+' ) duplicada.');
      exit(true);
    end;
  end;
end;

function CategName(cat: TtipDato): string;
begin
   case cat of
   t_integer: Result := 'Numérico';
   t_uinteger: Result := 'Numérico sin signo';
   t_float: Result := 'Flotante';
   t_string: Result := 'Cadena';
   t_boolean: Result := 'Booleano';
   t_enum: Result := 'Enumerado';
   else Result := 'Desconocido';
   end;
end;

procedure TipDefecNumber(var Op: TOperand; toknum: string);
//Devuelve el tipo de número entero o fltante más sencillo que le corresponde a un token
//que representa a una constante numérica.
//Su forma de trabajo es buscar el tipo numérico más pequeño que permita alojar a la
//constante numérica indicada.

var
  n: int64;   //para almacenar a los enteros
  f: extended;  //para almacenar a reales
  i: Integer;
  menor: Integer;
  imen: integer;
begin
  if pos('.',toknum) <> 0 then begin  //es flotante
    Op.catTyp := t_float;   //es flotante
    try
      f := StrToFloat(toknum);  //carga con la mayor precisión posible
    except
      Op.typ := nil;
      GenError('Número decimal no válido.');
      exit;
    end;
    //busca el tipo numérico más pequeño que pueda albergar a este número
    Op.size := 4;   //se asume que con 4 bytes bastará
    {Aquí se puede decidir el tamaño de acuerdo a la cantidad de decimales indicados}

    Op.cons.valFloat := f;  //debe devolver un extended
    menor := 1000;
    for i:=0 to types.Count-1 do begin
      { TODO : Se debería tener una lista adicional TFloatTypes, para acelerar la
      búsqueda}
      if (types[i].cat = t_float) and (types[i].size>=Op.size) then begin
        //guarda el menor
        if types[i].size < menor then  begin
           imen := i;   //guarda referencia
           menor := types[i].size;
        end;
      end;
    end;
    if menor = 1000 then  //no hubo tipo
      Op.typ := nil
    else  //encontró
      Op.typ:=types[imen];

  end else begin     //es entero
    Op.catTyp := t_integer;   //es entero
    //verificación de longitud de entero
    if length(toknum)>=19 then begin  //solo aquí puede haber problemas
      if toknum[1] = '-' then begin  //es negativo
        if length(toknum)>20 then begin
          GenError('Número muy grande. No se puede procesar. ');
          exit
        end else if (length(toknum) = 20) and  (toknum > '-9223372036854775808') then begin
          GenError('Número muy grande. No se puede procesar. ');
          exit
        end;
      end else begin  //es positivo
        if length(toknum)>19 then begin
          GenError('Número muy grande. No se puede procesar. ');
          exit
        end else if (length(toknum) = 19) and  (toknum > '9223372036854775807') then begin
          GenError('Número muy grande. No se puede procesar. ');
          exit
        end;
      end;
    end;
    //conversión. aquí ya no debe haber posibilidad de error
    n := StrToInt64(toknum);
    if (n>= -128) and  (n<=127) then
        Op.size := 1
    else if (n>= -32768) and (n<=32767) then
        Op.size := 2
    else if (n>= -2147483648) and (n<=2147483647) then
        Op.size := 4
    else if (n>= -9223372036854775808) and (n<=9223372036854775807) then
        Op.size := 8;
    Op.cons.valInt := n;   //copia valor de constante entera
    //busca si hay tipo numérico que soporte esta constante
{      Op.typ:=nil;
    for i:=0 to types.Count-1 do begin
      { TODO : Se debería tener una lista adicional  TIntegerTypes, para acelerar la
      búsqueda}
      if (types[i].cat = t_integer) and (types[i].size=Op.size) then
        Op.typ:=types[i];  //encontró
    end;}
    //busca el tipo numérico más pequeño que pueda albergar a este número
    menor := 1000;
    for i:=0 to types.Count-1 do begin
      { TODO : Se debería tener una lista adicional  TIntegerTypes, para acelerar la
      búsqueda}
      if (types[i].cat = t_integer) and (types[i].size>=Op.size) then begin
        //guarda el menor
        if types[i].size < menor then  begin
           imen := i;   //guarda referencia
           menor := types[i].size;
        end;
      end;
    end;
    if menor = 1000 then  //no hubo tipo
      Op.typ := nil
    else  //encontró
      Op.typ:=types[imen];
  end;
end;

