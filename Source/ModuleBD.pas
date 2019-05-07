{Data module para acceso a la base de datos SQLite base de datos}
unit ModuleBD;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, sqldb, sqlite3conn, Dialogs, CibFacturables;
type

  { TModBD }
  TModBD = class(TDataModule)
    query: TSQLQuery;
    SQLite3Connection1: TSQLite3Connection;
    SQLTransaction1: TSQLTransaction;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    nSer    : integer;     //Número de serie para escritura de registros
  public
    msjError: string;   //Mensaje de error
    procedure Init(rutaBD: string; nomLocal: string);
    procedure ExecuteInsert(sql: string);
    function LogInf(usu, mensaje: String): integer;
    function LogErr(usu, mensaje: String): integer;
    function LogVenta(usu, TIPO, CAT, SUBCAT, IDPROD, DESCR: string;
                      CANT, PUNIT, PUNITR, SUBTOT: Single): integer;
    function LogIngre(FECHA_VENTA: TDateTime; usu, CAT, SUBCAT, IDPROD,
      DESCR: string; CANT, PCOSTO, PUNIT, PUNITR, SUBTOT: Single;
  ID_BOL: integer; FRAGMEN, ESTADO, COMENT: string; STKINI: Single): integer;
  end;

var
  ModBD: TModBD;

implementation

{$R *.lfm}

{ TModBD }

procedure TModBD.DataModuleCreate(Sender: TObject);
begin
end;

procedure TModBD.DataModuleDestroy(Sender: TObject);
begin

end;

procedure TModBD.Init(rutaBD: string; nomLocal: string);
//Inicia la conexión a la base de datos
var
  DataBaseFullName: String;
  DataBaseName, mes: String;
begin
  SQLite3Connection1.Close();  //Por si estaba abierta
  mes := FormatDateTime('yyyy_mm', now);  //año-mes
  DataBaseName := nomLocal + '.' + mes + '.db';
  DataBaseFullName := rutaBD  + DirectorySeparator + DataBaseName;
  SQLite3Connection1.DatabaseName := DataBaseFullName;
  if not fileexists(DataBaseFullName) then begin
    ShowMessage('No existe base de datos: ' + DataBaseFullName + '. Se intentará crear una.');
    // Crear la base de datos y las tablas.
    try
      SQLite3Connection1.Open;  // Abrimos la conexión
      SQLTransaction1.Active := true; // Establecemos activa la transacción.
      { Crea tabla de tranasacción de ventas. La idea es que esta tabla almacene todas
      las acciones de ventas que se realicen, como el ingreo de un producto, la devolución,
      la fragmentación, ...}
      SQLite3Connection1.ExecuteDirect(
      'CREATE TABLE "TRANS_VENTAS"('+
      ' "ID_VEN" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'+
      ',"VSER" INTEGER NOT NULL'    +  {Número de serie de la venta. Se usa para control.
                                        Se reinicia cada vez que el programa inicia.
                                        Viene desde la primeras versiones de NILOTER.}
      ',"FECHA_VENTA" DateTime NOT NULL'+ //Fecha-hora en que se produce la transacción.
      ',"USUARIO" VARCHAR(20) NOT NULL'+  //Usuario actual
      ',"TIPO"    Char(3) '         +  //Tipo de registro
      ',"CAT"    VARCHAR(32) NOT NULL'+ //Categoría del producto
      ',"SUBCAT" VARCHAR(32) NOT NULL'+ //Subcategoría del producto
      ',"IDPROD" Char(32) NOT NULL' +  //Id del producto
      ',"DESCR" Char(128) '         +  //Descripción
      ',"CANT"  REAL NOT NULL'      +  //Cantidad
      ',"PUNIT" REAL NOT NULL'      +  //Precio unitario
      ',"PUNITR" REAL NOT NULL'     +  //Precio unitario real (el que cambia el operador)
      ',"SUBTOT" REAL NOT NULL'     +  //Subtotal (Puede ser negativo si es devolución)
      ');');
      { Crea la tabla de ingresos. Esta tabla es la que se usa para calcular los
      ingresos por concepto de venta}
      SQLite3Connection1.ExecuteDirect(
      'CREATE TABLE "INGRESOS"('+
      ' "ID_ING" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'+
      ',"VSER" INTEGER NOT NULL' +    {Número de serie del ingreso. Se usa para control.
                                       Se reincia cada vez que el programa inicia. }
      ',"FECHA_VENTA" DateTime NOT NULL'+ //Fecha-hora en que se produce la transacción.
      ',"FECHA_GRAB" DateTime NOT NULL'+  //Fecha-hora en que se graba el ingreso
      ',"USUARIO" VARCHAR(20) NOT NULL'+  //Usuario actual
      ',"CAT"    VARCHAR(32) NOT NULL'+   //Categoría del producto
      ',"SUBCAT" VARCHAR(32) NOT NULL'+   //Subcategoría del producto
      ',"IDPROD" Char(32) NOT NULL' +  //Id del producto
      ',"DESCR"  Char(128) '        +  //Descripción
      ',"CANT"   REAL NOT NULL'     +  //Cantidad
      ',"PCOSTO"  REAL NOT NULL'    +  //Precio de costo.
      ',"PUNIT"  REAL NOT NULL'     +  //Precio unitario
      ',"PUNITR" REAL NOT NULL'     +  //Precio unitario real (el que cambia el operador)
      ',"SUBTOT" REAL NOT NULL'     +  //Subtotal (Puede ser negativo si es devolución)
      ',"ID_BOL" INTEGER NOT NULL'  +  //Boleta Asociada
      ',"FRAGMEN" CHAR(1)'          +  //Fragmentación de ítem. Cuando es fragmentado.
      ',"ESTADO" CHAR(1)'           +  //Estado del ítem
      ',"COMENT" Char(128) '        +  //Comentario
      ',"STKINI" REAL '             +  //Stock Inicial
      ');');

      { Crea la tabla de boletas. Esta tabla  almacena informaciónm asociada a cada
      boleta/factura del sistema. Sus ítems se guardan en la tabla INGRESOS.}
      SQLite3Connection1.ExecuteDirect(
      'CREATE TABLE "BOLETAS"('+
      ' "ID_BOL" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'+
      ',"FECHA_CREAC" DateTime NOT NULL'+ //Fecha-hora en que se crea la boleta.
      ',"FECHA_GRAB" DateTime NOT NULL'+  //Fecha-hora en que se graba la boleta.
      ',"USUARIO" VARCHAR(20) NOT NULL'+  //Usuario actual
      ',"NITEMS"  Integer NOT NULL' +  //Número de ítems de la boleta
      ',"NOMBRE"  Char(64) '        +  //Nombre de cliente
      ',"DIRECCION" Char(128) '     +  //Dirección
      ',"RUC"      Char(16) '       +  //Registro de contribuyente
      ',"SUBTOT"   REAL NOT NULL'   +  //Subtotal (Puede ser negativo si es devolución)
      ',"IMPUESTO" REAL NOT NULL'   +  //Fragmentación de ítem. Cuando es fragmentado.
      ',"TOTAL"    REAL NOT NULL'   +  //Subtotal (Puede ser negativo si es devolución)
      ');');

      { Tabla de eventos. Almacena información, mensajes, errores y eventos importantes
      del sistema.}
      SQLite3Connection1.ExecuteDirect(
      'CREATE TABLE "EVENTOS"('     +
      ' "ID_EVE" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'+
      ',"NSER"    INTEGER NOT NULL' +  //Número de serie del evento
      ',"FECHA_CREAC" DateTime NOT NULL'+ //Fecha-hora del evento.
      ',"USUARIO" VARCHAR(20) NOT NULL'+  //Usuario actual
      ',"TIPO"     Char(3) '        +  //Tipo de evento
      ',"TEXTO"    TEXT'            +  //Contenido del evento.
      ');');

      { Tabla para almacenar acciones del stock.}
      SQLite3Connection1.ExecuteDirect(
      'CREATE TABLE "STOCK"('+
      ' "ID_STK" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'+
      ',"FECHA_CREAC" DateTime NOT NULL'+ //Fecha-hora del evento.
      ',"USUARIO" VARCHAR(20) NOT NULL'+  //Usuario actual
      ',"TIP_ACC" VARCHAR(20) NOT NULL'+  //Tipo de acción sobre el stock
      ',"CAT"      TEXT'            +  //Categoría de la acción
      ',"TEXTO"    TEXT'            +  //Texto de la acción
      ',"VALOR1"   REAL'            +  //Valor numérico 1
      ',"VALOR2"   REAL'            +  //Valor numérico 2
      ');');

      // Crea índice UNICO
      //SQLite3Connection1.ExecuteDirect('CREATE UNIQUE INDEX "Data_id_idx" ON "AAA"( "id" );');

      SQLTransaction1.Commit; // Enviamos y hacemos efectivo lo anterior.
      ShowMessage('Base de datos Creada Correctamente.');
    except
      on E: Exception do begin
          msjError := 'Error al crear Base de Datos (' + DataBaseName + '): ' + E.message;
//        SQLite3Connection1.Close();
          exit;  //No puede seguir
      end;
    end;
  end;
end;
procedure TModBD.ExecuteInsert(sql: string);
{Ejecuta una sentencia INSERT. "sql" es de la forma:
'INSERT INTO EVENTOS VALUES(NULL, 1, ''2019-01-31'');'
}
begin
  try
    query.SQL.Text := sql;
    query.ExecSQL;
    SQLTransaction1.Commit;
  except
    on E: Exception do begin
      msjError := 'Error al insertar en Base de Datos (' +
           SQLite3Connection1.DatabaseName + '): ' + E.message;
    end;
  end;
end;
function TModBD.LogInf(usu, mensaje: String): integer;
begin
  //Faltaría reemplazar "mensaje" cuadno contiene apóstrofos
  inc(nSer);
  ExecuteInsert('INSERT INTO EVENTOS ' +
     'VALUES(NULL, ' + nSer.ToString + ',' +
     'datetime(''now''),' +
     '''' + usu + '''' + ',' +
     '''' + IDE_REG_INF +''''  + ',' +
     '''' + mensaje + '''' +
  ');');
  Result := nSer;
end;
function TModBD.LogErr(usu, mensaje: String): integer;
begin
  //Faltaría reemplazar "mensaje" cuadno contiene apóstrofos
  inc(nSer);
  ExecuteInsert('INSERT INTO EVENTOS ' +
     'VALUES(NULL, ' + nSer.ToString + ',' +
     'datetime(''now''),' +
     '''' + usu + '''' + ',' +
     '''' + IDE_REG_ERR +''''  + ',' +
     '''' + mensaje + '''' +
  ');');
  Result := nSer;
end;
function TModBD.LogVenta(usu, TIPO, CAT, SUBCAT, IDPROD, DESCR: string; CANT,
  PUNIT, PUNITR, SUBTOT: Single): integer;
begin
  inc(nSer);
  ExecuteInsert('INSERT INTO TRANS_VENTAS (ID_VEN, VSER, FECHA_VENTA, USUARIO, TIPO,'+
                        'CAT, SUBCAT, IDPROD, DESCR, CANT, PUNIT, PUNITR, SUBTOT) ' +
     'VALUES(NULL, ' + nSer.ToString +
     ',' + 'datetime(''now'')' +
     ',' + '''' + usu + '''' +
     ',' + '''' + TIPO +''''  +
     ',' + '''' + CAT + '''' +
     ',' + '''' + SUBCAT + '''' +
     ',' + '''' + IDPROD + '''' +
     ',' + '''' + DESCR + '''' +
     ',' + CANT.ToString  +
     ',' + PUNIT.ToString  +
     ',' + PUNITR.ToString  +
     ',' + SUBTOT.ToString  +
     ');');
  Result := nSer;
end;
function TModBD.LogIngre(FECHA_VENTA: TDateTime; usu, CAT, SUBCAT, IDPROD, DESCR: string;
  CANT, PCOSTO, PUNIT, PUNITR, SUBTOT: Single;
  ID_BOL: integer; FRAGMEN, ESTADO, COMENT: string; STKINI: Single): integer;
begin
  inc(nSer);
  ExecuteInsert('INSERT INTO INGRESOS (ID_ING, VSER, FECHA_VENTA, FECHA_GRAB, USUARIO,' +
                         'CAT, SUBCAT, IDPROD, DESCR, CANT, PCOSTO, PUNIT, PUNITR, SUBTOT,'+
                         'ID_BOL, FRAGMEN, ESTADO, COMENT, STKINI) ' +
     'VALUES(NULL, ' + nSer.ToString +
     ',' + '''' + FormatDateTime('YYYY-MM-DD hh:nn:ss',FECHA_VENTA) + '''' +
     ',' + 'datetime(''now'')' +
     ',' + '''' + usu + '''' +
//     ',' + '''' + TIPO +''''  +
     ',' + '''' + CAT + '''' +
     ',' + '''' + SUBCAT + '''' +
     ',' + '''' + IDPROD + '''' +
     ',' + '''' + DESCR + '''' +
     ',' + CANT.ToString  +
     ',' + PCOSTO.ToString +
     ',' + PUNIT.ToString  +
     ',' + PUNITR.ToString  +
     ',' + SUBTOT.ToString  +
     ',' + ID_BOL.ToString  +
     ',' + '''' + FRAGMEN + '''' +
     ',' + '''' + ESTADO + '''' +
     ',' + '''' + COMENT + '''' +
     ',' + STKINI.ToString  +
     ');');
  Result := nSer;
end;

end.

