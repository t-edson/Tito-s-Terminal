unit FormPrincipal;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, Types, Forms, Controls, ExtCtrls, LCLProc, ActnList, Menus,
  ComCtrls, Dialogs, StdCtrls, LCLType, FileUtil, MisUtils, ogDefObjGraf,
  FormIngVentas, FormConfig, frameCfgUsuarios, Globales, frameVista,
  ObjGraficos, FormRepIngresos, FormAdminProduc, FormAcercaDe, FormCalcul,
  FormContDinero, FormSelecObjetos, FormRegCompras, FormInicio, CibTramas,
  CibFacturables, CibTabProvee, CibTabProductos, CibTabInsumos, FormAdminProvee,
  CibBD, FormAdminInsum, FormCambClave, FormRepProducto, FormRepEventos,
  FormValStock, FormIngStock, CibModelo, FormOgCabinas, FormPersonal,
  UniqueInstance, CibGFacMesas, CibGFacClientes, CibGFacCabinas, CibGFacNiloM,
  ModuleBD;
type
  { TfrmPrincipal }
  TfrmPrincipal = class(TForm)
  published
    acEnvCom: TAction;
    acEnvMjeTit: TAction;
    acRefPan: TAction;
    acSisConfig: TAction;
    acArcSalir: TAction;
    acEdiInsGrMes: TAction;
    acAyuSelRapid: TAction;
    acSisRegCompras: TAction;
    acSisIngStock: TAction;
    acSisValStock: TAction;
    acSisTransProd: TAction;
    acSisPerson: TAction;
    acVerRepEve: TAction;
    acVerRepPro: TAction;
    acUsuCamCla: TAction;
    acUsuCerSes: TAction;
    acSisAdmInsum: TAction;
    acSisAdmProvee: TAction;
    acSisAdmProd: TAction;
    acEdiInsEnrut: TAction;
    acEdiInsGrCab: TAction;
    acEdiElimGru: TAction;
    acArcRutTrab: TAction;
    acAyuAcerca: TAction;
    acAyuCalcul: TAction;
    acAyuBlocNot: TAction;
    acAyuContDin: TAction;
    acEdiInsGrCli: TAction;
    acEdiAlinHor: TAction;
    acEdiAlinVer: TAction;
    acEdiEspHor: TAction;
    acEdiEspVer: TAction;
    acVerRepIng: TAction;
    ActionList1: TActionList;
    acVerPant: TAction;
    Button1: TButton;
    Edit1: TEdit;
    ImageList32: TImageList;
    ImageList16: TImageList;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem24: TMenuItem;
    MenuItem25: TMenuItem;
    MenuItem26: TMenuItem;
    MenuItem27: TMenuItem;
    MenuItem28: TMenuItem;
    MenuItem29: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem30: TMenuItem;
    MenuItem31: TMenuItem;
    MenuItem32: TMenuItem;
    MenuItem33: TMenuItem;
    MenuItem34: TMenuItem;
    MenuItem35: TMenuItem;
    MenuItem36: TMenuItem;
    MenuItem37: TMenuItem;
    MenuItem38: TMenuItem;
    MenuItem39: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem40: TMenuItem;
    MenuItem41: TMenuItem;
    MenuItem42: TMenuItem;
    MenuItem43: TMenuItem;
    MenuItem44: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem61: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    panLLam: TPanel;
    panBolet: TPanel;
    PopupFac: TPopupMenu;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    Splitter1: TSplitter;
    splPanLlam: TSplitter;
    splPanBolet: TSplitter;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    UniqueInstance1: TUniqueInstance;
    procedure acArcRutTrabExecute(Sender: TObject);
    procedure acArcSalirExecute(Sender: TObject);
    procedure acAyuAcercaExecute(Sender: TObject);
    procedure acAyuBlocNotExecute(Sender: TObject);
    procedure acAyuCalculExecute(Sender: TObject);
    procedure acAyuContDinExecute(Sender: TObject);
    procedure acAyuSelRapidExecute(Sender: TObject);
    procedure acEdiInsGrMesExecute(Sender: TObject);
    procedure acSisIngStockExecute(Sender: TObject);
    procedure acSisRegComprasExecute(Sender: TObject);
    procedure acSisTransProdExecute(Sender: TObject);
    procedure acSisPersonExecute(Sender: TObject);
    procedure acSisValStockExecute(Sender: TObject);
    procedure acUsuCamClaExecute(Sender: TObject);
    procedure acUsuCerSesExecute(Sender: TObject);
    procedure acSisAdmInsumExecute(Sender: TObject);
    procedure acSisAdmProdExecute(Sender: TObject);
    procedure acEdiAlinHorExecute(Sender: TObject);
    procedure acEdiAlinVerExecute(Sender: TObject);
    procedure acEdiEspHorExecute(Sender: TObject);
    procedure acEdiEspVerExecute(Sender: TObject);
    procedure acEdiInsGrCliExecute(Sender: TObject);
    procedure acEdiElimGruExecute(Sender: TObject);
    procedure acEdiInsEnrutExecute(Sender: TObject);
    procedure acEdiInsGrCabExecute(Sender: TObject);
    procedure acSisConfigExecute(Sender: TObject);
    procedure acSisAdmProveeExecute(Sender: TObject);
    procedure acVerRepEveExecute(Sender: TObject);
    procedure acVerRepIngExecute(Sender: TObject);
    procedure acVerRepProExecute(Sender: TObject);
    procedure ConfigfcVistaUpdateChanges;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure Modelo_CambiaPropied;
    procedure Timer1Timer(Sender: TObject);
  private
    Modelo: TCibModelo;    //El modelo de la aplicaicón
    log   : TCibTablaHist;
    tabPro: TCibTabProduc;
    tabPrv: TCibTabProvee;
    tabIns: TCibTabInsumo;
    Visor : TfraVista;  //Visor de cabinas
    TramaTmp   : TCPTrama; //Trama temporal
    fallasesion: boolean;  //indica si se cancela el inicio de sesión
    tic : integer;
    procedure CerrarSesion;
    procedure frmAdminInsum_Grabar;
    procedure frmAdminProvee_Grabar;
    procedure frmIngStock_Grabar(Manual: boolean);
    function ModeloLogIngre2(FECHA_VENTA: TDateTime; usu, CAT, SUBCAT, IDPROD,
      DESCR: string; CANT, PCOSTO, PUNIT, PUNITR, SUBTOT: Single; ID_BOL: integer;
      FRAGMEN, ESTADO, COMENT: string; STKINI: Single): integer;
    function ModeloLogVenta2(USU, TIPO, CAT, SUBCAT, IDPROD, DESCR: string;
      CANT, PUNIT, PUNITR, SUBTOT: Single): integer;
    function PLogErr(usu, mensaje: String): integer;
    function PLogInf(usu, mensaje: String): integer;
    function PLogVenta(identif: char; mensaje: String; dCosto: Double): integer;
    procedure Modelo_SolicEjecCom(comando: TCPTipCom; ParamX, ParamY: word;
      cad: string);
    procedure frmValStockGrabado;
    procedure IniciarSesion(usuIni: string='');
    procedure RefrescarEncabezado;
    procedure VerificarCargaInsumos(ActulizRemota: boolean);
    procedure VerificarCargaProductos(ActulizRemota: boolean);
    procedure ActualizarMensajes;
    procedure frmAdminProduc_Grabar;
    procedure Modelo_ArchCambRemot(ruta, nombre: string);
    function Modelo_ModifTablaBD(NombTabla: string; tipModif: integer;
      const datos: string): string;
    procedure Modelo_ReqConfigUsu(out Usuario: string);
    procedure LLenarToolBar(PopUp: TPopupMenu);
    procedure Modelo_RespComando(idVista: string; comando: TCPTipCom;
      ParamX, ParamY: word; cad: string);
    procedure VerificarCargaProveedores(ActulizRemota: boolean);
    procedure Visor2_AgrVentaProducto(idFac: string);
    procedure Visor_DobleClickFac(ogFac: TogFac; X, Y: Integer);
    function Modelo_LogIngre(ident: char; msje: string; dCosto: Double
      ): integer;
    function Modelo_LogError(msj: string): integer;
    function Modelo_LogVenta(ident:char; msje:string; dCosto:Double): integer;
    procedure Modelo_ActualizStock(const codPro: string;
      const Ctdad: double);
    procedure Modelo_ReqConfigGen(out NombProg, NombLocal: string; out ModDiseno: boolean);
    procedure frmIngVentas_AgregarVenta(CibFac: TCibFac; itBol: string);
    function Modelo_LogInfo(msj: string): integer;
    procedure Modelo_EstadoArchivo;
    procedure LeerEstadoDeArchivo;
    procedure NiloM_RegMsjError(NomObj: string; msj: string);
    procedure PonerComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
    procedure Visor_ObjectsMoved;
  public
    { public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation
{$R *.lfm}
function TfrmPrincipal.PLogInf(usu, mensaje: String): integer;
begin
  Result := ModBD.LogInf(usu, mensaje);
  Result := log.PLogInf(usu, mensaje);
end;
function TfrmPrincipal.PLogErr(usu, mensaje: String): integer;
begin
  Result := ModBD.LogErr(usu, mensaje);
  Result := log.PLogErr(usu, mensaje);
end;
function TfrmPrincipal.PLogVenta(identif: char; mensaje : String; dCosto : Double): integer;
begin
  //Result := ModBD.LogErr(usu, mensaje);
  Result := log.PLogVenta(identif, mensaje, dCosto);
end;
procedure TfrmPrincipal.LLenarToolBar(PopUp: TPopupMenu);
var
  i: Integer;
  it: TMenuItem;
  MyToolButton: TToolButton;
begin
  //Limpia Toolbar
  for i := ToolBar1.ButtonCount - 1 downto 0 do
    ToolBar1.Buttons[i].Free;
  for i := PopUp.Items.Count-1 downto 0 do begin
    it := PopUp.Items[i];
    MyToolButton:=TToolButton.Create(ToolBar1);
    MyToolButton.Caption:= it.Caption;
    MyToolButton.Hint:=it.Caption;
    MyToolButton.ImageIndex:=it.ImageIndex;
    MyToolButton.Parent:=ToolBar1;
    MyToolButton.Enabled:=it.Enabled;
    MyToolButton.OnClick:=it.OnClick;
    if it.Caption = '-' then begin
      MyToolButton.Style := tbsDivider;
      MyToolButton.Height:=8;
    end;
  end;
end;
procedure TfrmPrincipal.ActualizarMensajes;
//Actualiza le panel de mensajes
begin
  if not FileExists(arcMensaj) then begin
    Memo1.Text:='<<Sin mensaje>>';
    exit;
  end;
  //Hay mensajes
  Memo1.Lines.LoadFromFile(arcMensaj);
end;
procedure TfrmPrincipal.VerificarCargaProductos(ActulizRemota: boolean);
{Verifica si hubo errores, depsués de actualizar la tabla de productos.}
begin
  if ActulizRemota then begin
    //Se ha actualizado remotamente
    if tabPro.msjError <> '' then begin
      //Esto no debería pasar si se maneja bien la tabla
      PLogErr(usuario, tabPro.msjError);
      MsgErr('Error cargando tabla de productos.');
      MsgErr(tabPro.msjError);
    end else begin
      //Se cargó correctamente la tabla de productos
      if frmAdminProduc.Visible then begin
        //Estaba abierta
        MsgExc('Ha habido cambios en la tabla de productos' + LineEnding +
               'Se recomienda volver a abrir este formulario.'    );
      end;
    end;
  end else begin
    //La actualización es local
    if tabPro.msjError <> '' then begin
      //Esto no debería pasar si se maneja bien la tabla
      PLogErr(usuario, tabPro.msjError);
      MsgErr('Error cargando tabla de productos:' + tabPro.msjError);
    end;
  end;
end;
procedure TfrmPrincipal.VerificarCargaProveedores(ActulizRemota: boolean);
{Verifica si hubo errores, depsués de actualizar la tabla de proveedores.}
begin
  if ActulizRemota then begin
    //Se ha actualizado remotamente
    if tabPrv.msjError <> '' then begin
      //Esto no debería pasar si se maneja bien la tabla
      PLogErr(usuario, tabPrv.msjError);
      MsgErr('Error cargando tabla de proveedores.');
      MsgErr(tabPrv.msjError);
    end else begin
      //Se cargó correctamente la tabla de proveedores
      if frmAdminProvee.Visible then begin
        //Estaba abierta
        MsgExc('Ha habido cambios en la tabla de proveedores' + LineEnding +
               'Se recomienda volver a abrir este formulario.'    );
      end;
    end;
  end else begin
    //La actualización es local
    if tabPrv.msjError <> '' then begin
      //Esto no debería pasar si se maneja bien la tabla
      PLogErr(usuario, tabPrv.msjError);
      MsgErr('Error cargando tabla de proveedores.');
      MsgErr(tabPrv.msjError);
    end;
  end;
end;
procedure TfrmPrincipal.VerificarCargaInsumos(ActulizRemota: boolean);
{Verifica si hubo errores, depsués de actualizar la tabla de insumos.}
begin
  if ActulizRemota then begin
    //Se ha actualizado remotamente
    if tabIns.msjError <> '' then begin
      //Esto no debería pasar si se maneja bien la tabla
      PLogErr(usuario, tabIns.msjError);
      MsgErr('Error cargando tabla de insumos.');
      MsgErr(tabIns.msjError);
    end else begin
      //Se cargó correctamente la tabla de insumos
      if frmAdminInsum.Visible then begin
        //Estaba abierta
        MsgExc('Ha habido cambios en la tabla de insumos' + LineEnding +
               'Se recomienda volver a abrir este formulario.'    );
      end;
    end;
  end else begin
    //La actualización es local
    if tabIns.msjError <> '' then begin
      //Esto no debería pasar si se maneja bien la tabla
      PLogErr(usuario, tabIns.msjError);
      MsgErr('Error cargando tabla de insumos.');
      MsgErr(tabIns.msjError);
    end;
  end;
end;
procedure TfrmPrincipal.frmAdminProduc_Grabar;
{Se pide grabar el contenido de la grilla.}
var
  res: String;
begin
  //Graba en disco en modo MODTAB_NOSTCK
  res := tabPro.ActualizarTabNoStock(frmAdminProduc.fraGri.GetString);
  VerificarCargaProductos(false);
  MsgBox(res);
  //Tal vez sería mejor que se usara PonerComando(), como lo hace
  //TfrmPrincipal.frmIngStock_Grabar() para centralizar mejor las acciones.
end;
procedure TfrmPrincipal.frmAdminProvee_Grabar;
begin
  //Graba en disco en modo MODTAB_TOTAL
  tabPrv.UpdateAll(frmAdminProvee.fraGri.GetString);
  VerificarCargaProveedores(false);
  MsgBox(tabPrv.msgUpdate);
  frmAdminProvee.Modificado := false;
end;
procedure TfrmPrincipal.frmIngStock_Grabar(Manual: boolean);
{Se pide grabar los ingresos de stock}
var
  getIngSTock, str, filName, getIngSTockInv: String;
  tipModif: Integer;
begin
  getIngSTock := frmIngStock.GetIngStock;
  getIngSTockInv := frmIngStock.GetIngStock(True);
  //Mande el comando al modelo.
  tipModif := MODTAB_INGSTCK;   //tipo de modificación
  PonerComando(CVIS_ACTPROD, 0, tipModif, getIngSTock);
  //Verifica si genera archivo de transferencia
  if Manual then begin
    {Solo si se graba manualmente se pregunta. De otra forma se asume que se está
    haciendo automáticamente y no se exportarán los cambios.}
    if MsgYesNo('¿Generar archivo de transferencia?') <> 1 then exit;
    DateTimeToString(str, 'yyyy-mm-dd', now);
    SaveDialog1.FileName := 'productos.' + Config.Local + '.' + str + '.ing';
    if not SaveDialog1.Execute then exit;
    filName := SaveDialog1.FileName;
    if FileExists(filName) then begin
      if MsgYesNo('Archivo existe. ¿Sobreescribir?') <> 1 then exit;
      //¿Y si se cancela, se pierde la transferencia?
    end;
    StringToFile(getIngSTockInv, filName);
  end;
end;
procedure TfrmPrincipal.frmValStockGrabado;
{Se pide grabar las validaciones del stock}
var
  res, lin, id, nuevo, TabIngSTock, desc, difer, stock, tmp: String;
  lineas: TStringList;
  a: TStringDynArray;
  prod: TCibRegProduc;
  difMonto: double;
begin
  TabIngSTock := frmValStock.TabValStock(difMonto);
  res := tabPro.ActualizarTabIngStock(TabIngSTock);
  VerificarCargaProductos(false);
  MsgBox(res);
  //frmIngStock.Modificado := false;
  //Genera información en el registro
  lineas := TStringList.Create;
  lineas.Text := TabIngSTock;
  for lin in lineas do begin
    a := Explode(#9, lin);
    id := a[0];
    difer := trim(a[1]);
    stock := trim(a[2]);
    nuevo := trim(a[3]);
    prod := tabPro.BuscarProd(id);
    if prod<>nil then desc := prod.Desc else desc := '';
    PLogInf(usuario, 'Stock de ' + id + '('+ desc +')' +
                         ' corregido de ' + stock + ' a ' + nuevo + ' con dif=' +
                         difer);  //registra el mensaje
  end;
  //Mensaje final
  if difMonto < 0 then begin
    tmp := FloatToStr(difMonto) + ' faltantes.';
  end else if difMonto > 0 then begin
    tmp := FloatToStr(difMonto) + ' sobrantes.';
  end else begin
    tmp := FloatToStr(difMonto);
  end;
  //registra el mensaje
  PLogInf(usuario, '**Fin de corrección de stock. Monto de diferencia = ' + tmp);
  lineas.Destroy;
end;
procedure TfrmPrincipal.frmAdminInsum_Grabar;
begin
  //Graba en disco en modo MODTAB_TOTAL
  tabIns.UpdateAll(frmAdminInsum.fraGri.GetString);
  VerificarCargaInsumos(false);
  MsgBox(tabIns.msgUpdate);
  frmAdminInsum.Modificado := false;
end;
procedure TfrmPrincipal.Modelo_CambiaPropied;
{Se produjo un cambio en alguna de las propiedades de alguna de las cabinas.}
begin
  debugln('** Cambio de propiedades: ');
  Config.ModeloStr := Modelo.CadPropiedades;    //Actualiza Modelo
  Config.escribirArchivoIni;  //guarda cambios
  Visor.ActualizarPropiedades(Modelo.CadPropiedades);
end;
function TfrmPrincipal.Modelo_LogInfo(msj: string): integer;
begin
  Result := PLogInf(usuario, msj);
end;
function TfrmPrincipal.Modelo_LogVenta(ident: char; msje: string; dCosto: Double
  ): integer;
begin
  Result := PLogVenta(ident, msje, dCosto);
end;
function TfrmPrincipal.ModeloLogVenta2(USU, TIPO, CAT, SUBCAT, IDPROD,
  DESCR: string; CANT, PUNIT, PUNITR, SUBTOT: Single): integer;
{Finalmente este evento debería ser el que quede.}
begin
  Result := ModBD.LogVenta(usu, TIPO, CAT, SUBCAT, IDPROD, DESCR, CANT,
    PUNIT, PUNITR, SUBTOT);
end;
function TfrmPrincipal.Modelo_LogIngre(ident: char; msje: string;
  dCosto: Double): integer;
begin
  Result := log.PLogIngre(ident, msje, dCosto);
end;
function TfrmPrincipal.ModeloLogIngre2(FECHA_VENTA: TDateTime; usu, CAT,
  SUBCAT, IDPROD, DESCR: string; CANT, PCOSTO, PUNIT, PUNITR, SUBTOT: Single;
  ID_BOL: integer; FRAGMEN, ESTADO, COMENT: string; STKINI: Single): integer;
begin
  Result := ModBD.LogIngre(FECHA_VENTA, usu, CAT, SUBCAT, IDPROD, DESCR,
    CANT, PCOSTO, PUNIT, PUNITR, SUBTOT, ID_BOL, FRAGMEN, ESTADO, COMENT, STKINI);
end;
function TfrmPrincipal.Modelo_LogError(msj: string): integer;
begin
  Result := PLogErr(usuario, msj);
end;
procedure TfrmPrincipal.Modelo_EstadoArchivo;
{Guarda el estado de los objetos al archivo de estado}
var
  lest: TStringList;
  arcEstadoTmp: String;
begin
  lest:= TSTringList.Create;
  lest.Text := Modelo.CadEstado;
  arcEstadoTmp := arcEstado + '.tmp';   //Nombre de archivo temporal
  if FileExists(arcEstadoTmp) then DeleteFile(arcEstadoTmp);
  CopyFile(arcEstado, arcEstadoTmp);  //Crea una copia antes de escribir
  lest.SaveToFile(arcEstado);  //Finalmente escribe
  lest.Destroy;
end;
procedure TfrmPrincipal.Modelo_ReqConfigGen(out NombProg, NombLocal: string;
  out ModDiseno: boolean);
begin
  NombProg  := NOM_PROG;
  NombLocal := Config.Local;
  ModDiseno := Config.modDiseno;
end;
procedure TfrmPrincipal.Modelo_ReqConfigUsu(out Usuario: string);
begin
  Usuario := FormInicio.usuario;
end;
procedure TfrmPrincipal.Modelo_ActualizStock(const codPro: string;
  const Ctdad: double);
{Se está solicitando actualizar el stock. Esta petición usualmente viene desde una
boleta.}
begin
  tabPro.IncrementarStock(codPro, Ctdad);
  if msjError <> '' Then begin
      //Se muestra aquí porque no se va a detener el flujo del programa por
      //un error, porque es prioritario registrar la venta.
      MsgBox(msjError);
  end;
end;
procedure TfrmPrincipal.Modelo_RespComando(idVista: string; comando: TCPTipCom;
  ParamX, ParamY: word; cad: string);
{El modelo está solitando responder un comando, a una vista}
var
  fac: TCibFac;
  cab: TCibFacCabina;
begin
  if idVista = '$' then begin
    //La respuesta es para la vista local
    {De seguro que esta no es la mejor forma de responder a un comando.
    Habría que definir mejor cómo se envían las respuestas a la vista o
    elemento que soplicitó el comando. Revisar el código de:
    Visor.EjecRespuesta() porque ya no se usa.
    Por ahora solo ejecutamos, de esta forma }
    Modelo.EjecRespuesta(comando, ParamX, ParamY, cad);
  end else begin
    //La respuesta es para una vista en una PC de la red.
    //Para enviar a una PC remota, se debe hacer a través del propio modelo
    fac := Modelo.BuscarPorID(idVista);  //Se ubica a quien responder, con "idVista".
    if fac = nil then
      exit;  //No debería pasar. ¿Habrá desaparecido?
    if not (fac is TCibFacCabina) then begin
      exit;  {No es PC. ¿Qué raro?. Se supone que, por ahora, solo las PC
              CIBERPLEX-PVenta, CIBERPLEX-Admin), son capaces de generar comandos.}
    end;
    cab := TCibFacCabina(FAC);
    cab.TCP_envComando(comando, ParamX, ParamY, cad);
  end;
end;
procedure TfrmPrincipal.Modelo_ArchCambRemot(ruta, nombre: string);
var
  nombArc: String;
begin
  //Reconstruye nombre de archivo
  if pos(':', nombre)<>0 then begin
    //Hay información de ruta en el nombre
    nombArc := nombre;
  end else begin
    if ruta = '' then ruta := rutApp;  //puede pasar
    nombArc := ruta + '\' + nombre;
  end;
  debugln('Archivo cambiado: ' + nombArc);
  if nombArc = arcProduc then begin
    debugln('Tabla de productos cambiada.');
    tabPro.UpdateFromDisk;
    VerificarCargaProductos(true);
  end;
  if nombArc = arcProvee then begin
    debugln('Tabla de proveedores cambiada.');
    tabPrv.UpdateFromDisk;
    VerificarCargaProveedores(true);
  end;
  if nombArc = arcInsumo then begin
    debugln('Tabla de insumos cambiada.');
    tabIns.UpdateFromDisk;
    VerificarCargaInsumos(true);
  end;
  if nombArc = arcMensaj then begin
    debugln('Tabla de mensajes cambiada.');
    ActualizarMensajes;
  end;
end;
function TfrmPrincipal.Modelo_ModifTablaBD(NombTabla: string;
  tipModif: integer; const datos: string): string;
var
  TabIngSTock, lin, id, incr, desc: String;
  lineas: TStringList;
  a: TStringDynArray;
  prod: TCibRegProduc;
begin
  if Upcase(trim(NombTabla)) = 'PRODUCTOS' then begin
    //Se pide modificar la tabla de productos
    case tipModif of
    MODTAB_TOTAL: begin  //Modificación total
      tabPro.UpdateAll(datos);
      Result := tabPro.msgUpdate;
      VerificarCargaProductos(true);
    end;
    MODTAB_NOSTCK: begin
      //Modificación sin tocar el stock.
      Result := tabPro.ActualizarTabNoStock(datos);
      VerificarCargaProductos(true);
    end;
    MODTAB_INGSTCK: begin
      //Modificación de ingreso de stock
      TabIngSTock := datos;
      Result := tabPro.ActualizarTabIngStock(TabIngSTock);
      VerificarCargaProductos(true);
      //Genera información en el registro
      lineas := TStringList.Create;
      lineas.Text := TabIngSTock;
      for lin in lineas do begin
        a := Explode(#9, lin);
        id := a[0];
        incr := trim(a[1]);
        prod := tabPro.BuscarProd(id);
        if prod<>nil then desc := prod.Desc else desc := '';
        PLogInf(usuario, 'Stock de ' + id + '('+ desc +')' + ' incrementado en ' + incr + ' unid.');  //registra el mensaje
      end;
      lineas.Destroy;
    end;
    else
      Result := 'No se reconoce tipo de modificación.'
    end;
  end;
  if Upcase(trim(NombTabla)) = 'PROVEEDORES' then begin
    //Se pide modificar la tabla de proveedores
    case tipModif of
    MODTAB_TOTAL: begin  //Modifiación total
      tabPrv.UpdateAll(datos);
      Result := tabPrv.msgUpdate;
      VerificarCargaProveedores(true);
    end;
    else
      Result := 'No se reconoce tipo de modificación.'
    end;
  end;
  if Upcase(trim(NombTabla)) = 'INSUMOS' then begin
    case tipModif of
    MODTAB_TOTAL: begin  //Modifiación total
      tabIns.UpdateAll(datos);
      Result := tabIns.msgUpdate;
      VerificarCargaInsumos(true);
    end;
    else
      Result := 'No se reconoce tipo de modificación.'
    end;
  end;
end;
procedure TfrmPrincipal.Modelo_SolicEjecCom(comando: TCPTipCom; ParamX,
  ParamY: word; cad: string);
{El modelo (más precisamente: algún elemento interno del modelo) también puede solicitar
ejecutar un comando al propio modelo. Como en el caso de los visores remotos.}
begin
  PonerComando(comando, ParamX, ParamY, cad);
end;
procedure TfrmPrincipal.PonerComando(comando: TCPTipCom; ParamX, ParamY: word; cad: string);
{Envía un comando al modelo, de la misma forma a como si fuera un comando remoto.
Aquí se llega por diversas vías, todas de tipo local (los comandos remotos no llegan por
aquí):
1. Un GFAC ha solicitado ejecutar un comando. Estos comandos son los que los objetos
facturables generan a través de su método TCibGFac.EjecAccion.
2. El visor ha generado un evento, como el arrastre de objetos, que requiere ejecutar
una acción sobre el modelo.
3. Acciones de frmIngVentas, frmBoleta, o de frmPrincipal.
Observar que este método es similar a PonerComando(), pero allí llegan los comandos
que se generan con acciones de FormPrincipal.}
begin
  TramaTmp.Inic(comando, ParamX, ParamY, cad); //usa trama temporal
  //Llama como evento, indicando que es una trama local.
  //No se incluye nombre del OF y GOF que generan la trama, proque es local.
  Modelo.EjecComando('$', TramaTmp);
end;
procedure TfrmPrincipal.Visor_DobleClickFac(ogFac: TogFac; X, Y: Integer);
{Se ha hecho doble click en un fcaturable. Se debe seguir el mismo esquema que
Visor_ClickDer}
begin
  //Hay objeto seleccionado
  if ogFac is TogCabina then begin
    //Abre explorador
    frmOgCabinas.ogFacCab := TogCabina(ogFac);
    frmOgCabinas.mnVerExplorad(self);
  end;
end;
procedure TfrmPrincipal.Visor_ObjectsMoved;
{Se ha producido el movimiento de objetos en el editor. Se actualiza en el modelo.}
var
  og: TObjGraf;
  Gfac: TCibGFac;
  fac: TCibFac;
begin
  //Se supone que se han movido los objetos seleccionados
  Modelo.DeshabEven:=true;   //para evitar interferencia
  for og in Visor.motEdi.seleccion do begin  //*** Debe cambairse al otro visor cuando se haga la migración
    if og.Tipo = OBJ_GRUP then begin
      //Es un grupo. Ubica el objeto
      Gfac := Modelo.ItemPorNombre(og.Name);
      if Gfac=nil then exit;
      Gfac.x := og.x;
      Gfac.y := og.y;
    end else if og.Tipo = OBJ_FACT then begin
      //Es un facturable
      Gfac := Modelo.ItemPorNombre(TogFac(og).grupo.Name);  //ubica a su grupo
      if Gfac=nil then exit;
      fac := Gfac.ItemPorNombre(og.Name);
      fac.x := og.x;
      fac.y := og.y;
    end;
  end;
  Modelo.DeshabEven:=false;   //restaura estado
  Modelo.OnCambiaPropied;
end;
procedure TfrmPrincipal.Visor2_AgrVentaProducto(idFac: string);
var
  fac: TCibFac;
begin
  fac := Modelo.BuscarPorID(idFac);
  frmIngVentas.Exec(fac);
end;
procedure TfrmPrincipal.NiloM_RegMsjError(NomObj: string; msj: string);
begin
  PLogErr(usuario, msj);
end;
procedure TfrmPrincipal.RefrescarEncabezado;
begin
  if Usuario = '' then begin
    Caption := NOM_PROG + ' ' + VER_PROG;
  end else begin
    Caption := NOM_PROG + ' ' + VER_PROG + ' Local: ' + Config.Local + ' - Usuario: ' + Usuario;
  end;
end;
procedure TfrmPrincipal.IniciarSesion(usuIni: string = '');
begin
  frmInicio.edUsu.Text := usuIni;
  frmInicio.ShowModal;
  if frmInicio.cancelo then begin
    fallasesion := True;
    Close;
  end else begin
    PLogInf(usuario, 'Sesión iniciada: ' + usuario);
  end;
  RefrescarEncabezado;
end;
procedure TfrmPrincipal.CerrarSesion;
begin
  PLogInf(usuario, 'Sesión terminada: ' + usuario);
  Config.ModeloStr := Modelo.CadPropiedades;    //Actualiza Modelo
  Config.escribirArchivoIni;  //guarda la configuración actual
  Modelo_EstadoArchivo;       //guarda estado
  Usuario := '';
  RefrescarEncabezado;
end;
procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  Modelo := TCibModelo.Create('GrupServ');  //Crea instancia del Modelo
  RefrescarEncabezado;
  //Crea un grupo de cabinas
  TramaTmp := TCPTrama.Create;
  log := TCibTablaHist.Create;
  tabPro := TCibTabProduc.Create;
  tabPrv := TCibTabProvee.Create;
  tabIns := TCibTabInsumo.Create;
  {Crea un visor aquí, para que el Servidor pueda servir tambien como Punto de Venta}
  Visor := TfraVista.Create(self);
  Visor.Parent := self;
  Visor.Align := alClient;
  tic := 0;   //inicia contador
end;
procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  //Carga íconos de Modelo facturables
  Visor.CargarIconos;
  //FormOgClientes.CargarIconos(ImageList16, ImageList32);
  //FormOgNiloM.CargarIconos(ImageList16, ImageList32);
  //FormOgCabinas.CargarIconos(ImageList16, ImageList32);
  //FormOgMesas.CargarIconos(ImageList16, ImageList32);
  //Carga configuración
  Config.Iniciar('config.xml');  {Lee configuración, incluyendo datos del modelo,
                                  de modo que se crean los GFAC y FAC también. }
  Config.OnPropertiesChanges:=@ConfigfcVistaUpdateChanges;
  {Ya se tiene la configuración leída, incluyendo el contenido del modelo, pero aún
  no lo iniciamos.}
  //Inicia base de datos
  ModBD.Init(rutDatos, Config.Local);
  If ModBD.msjError <> '' then begin
     MsgErr(ModBD.msjError);
     //No tiene sentido seguir, si no se puede abrir la Base de datos
     Close;
  end;
  {Inicializa comunicación del modelo con la aplicación. Toda petición de información
  del modelo se pasan a la aplicación principal}
  Modelo.OnCambiaPropied:= @Modelo_CambiaPropied;
  Modelo.OnGuardarEstado:= @Modelo_EstadoArchivo;
  Modelo.OnActualizStock:= @Modelo_ActualizStock;
  Modelo.OnRespComando  := @Modelo_RespComando;
  Modelo.OnModifTablaBD := @Modelo_ModifTablaBD;

  Modelo.OnLogInfo      := @Modelo_LogInfo;
  Modelo.OnLogVenta     := @Modelo_LogVenta;
Modelo.OnLogVenta2 := @ModeloLogVenta2;
  Modelo.OnLogIngre     := @Modelo_LogIngre;
Modelo.OnLogIngre2 := @ModeloLogIngre2;

  Modelo.OnLogError     := @Modelo_LogError;

  Modelo.OnReqConfigGen := @Modelo_ReqConfigGen;
  Modelo.OnReqConfigUsu := @Modelo_ReqConfigUsu;
  Modelo.OnReqCadMoneda := @Config.ReqCadMon;

  Modelo.OnArchCambRemot:= @Modelo_ArchCambRemot;
  Modelo.OnSolicEjecCom := @Modelo_SolicEjecCom;  {El modelo solicita acciones cuando algún
                        elemento interno (por ahora solo una cabina), genera un comadno
                        dirigido al modelo.}
  {Ya se tiene configurado al modelo, ahora se le Inicia con todos los objetos leídos
  de la configuración.}
  Modelo.CadPropiedades := Config.ModeloStr;   //actualiza después de leer
  LeerEstadoDeArchivo;   //Actualiza el estado de los objetos

  //Configura Visor para comunicar sus eventos
  Visor.OnReqCadMoneda  := @Config.ReqCadMon;   //Para que pueda mostrar monedas
  Visor.OnAgrVentaProd := @Visor2_AgrVentaProducto;
  Visor.OnDobleClickFac := @Visor_DobleClickFac;
  Visor.OnObjectsMoved  := @Visor_ObjectsMoved;
  Visor.OnSolicEjecCom  := @PonerComando;  //Necesario para procesar las acciones que se hacen sobre la vista
  //Crea los objetos gráficos del visor de acuerdo al archivo INI.
  Visor.ActualizarPropiedades(Modelo.CadPropiedades);
  {Actualzar Vista. Se debe hacer después de agregar los objetos, porque dependiendo
   de "ModoDiseño" se debe cambiar el modo de bloqueo de lso objetos existentes}
  ConfigfcVistaUpdateChanges;
  //Verifica si se puede abrir el archivo de registro principal
  log.AbrirPLog(rutDatos, Config.Local, 'GENERAL');
  If msjError <> '' then begin
     MsgErr(msjError);
     //No tiene sentido seguir, si no se puede abrir registro
     Close;
  end;

  //verifica si hay información de usuarios
  if usuarios.Count = 0 Then begin
    //crea usuarios por defecto
    CreaUsuario('admin', '', PER_ADMIN);  //Usuario por defecto
    CreaUsuario('oper', '', PER_OPER);    //Usuario por defecto
  end;

  PLogInf(usuario, '----------------- Inicio de Programa ---------------');
  tabPro.SetTable(arcProduc);
  tabPro.UpdateFromDisk;
  VerificarCargaProductos(false);

  tabPrv.SetTable(arcProvee);
  tabPrv.UpdateFromDisk;
  if tabPrv.msjError <> '' then begin
    //Esto no debería pasar si se maneja bien la tabla
    PLogErr(usuario, tabPrv.msjError);
    MsgErr('Error cargando tabla de proveedores. ' + tabPrv.msjError);
  end;
  tabIns.SetTable(arcInsumo);
  tabIns.UpdateFromDisk;
  if tabIns.msjError <> '' then begin
    //Esto no debería pasar si se maneja bien la tabla
    PLogErr(usuario, tabIns.msjError);
    MsgErr('Error cargando tabla de Insumos.' + tabIns.msjError);
  end;
  //Carga mensajes
  ActualizarMensajes;
  //Configura formulario de ingreso de ventas
  frmIngVentas.TabPro := tabPro;
//  frmIngVentas.LeerDatos;
  frmIngVentas.OnAgregarVenta:=@frmIngVentas_AgregarVenta;

  PLogInf(usuario, IntToStr(tabPro.Productos.Count) + ' productos cargados.');
  PLogInf(usuario, IntToStr(tabPrv.Proveedores.Count) + ' proveedores cargados.');
  PLogInf(usuario, IntToStr(tabIns.Insumos.Count) + ' insumos cargados.');
  IniciarSesion(Config.UsuaDef);
  self.Activate;
  self.SetFocus;
  //self.Show;
  //Para permitir grabar cambios
  frmAdminProduc.OnGrabado:=@frmAdminProduc_Grabar;
  frmAdminProvee.OnGrabado:=@frmAdminProvee_Grabar;
  frmAdminInsum.OnGrabado:=@frmAdminInsum_Grabar;

  frmIngStock.OnGrabado := @frmIngStock_Grabar;
  frmValStock.OnGrabado := @frmValStockGrabado;

  frmRepIngresos.OnReqCadMoneda:=@Config.ReqCadMon;
  If ModBD.msjError <> '' then begin
     MsgErr(ModBD.msjError);
     //No tiene sentido seguir, si no se puede abrir la Base de datos
     Close;
  end;
end;
procedure TfrmPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CerrarSesion;
  PLogInf(usuario, '----------------- Fin de Programa ---------------');
end;
procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  Debugln('Terminando ... ');
  tabIns.Destroy;
  tabPrv.Destroy;
  tabPro.Destroy;
  log.Destroy;
  TramaTmp.Destroy;
  //Matar a los hilos de ejecución, puede tomar tiempo
  Modelo.Destroy;
end;
procedure TfrmPrincipal.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ADD) and (Visor.Seleccionado<>nil) then begin
    //Se asume que la tecla +, debe funcionar siempre que haya selección
    Visor.SetFocus;
  end;
  if Visor.Focused then begin
    if Key IN [VK_APPS, VK_ADD]  then begin   //Menú contextual o '+' del teclado numérico.
      Visor.MenuContextual;
      exit;
    end else if Key = VK_F2 then begin
      //Acceso rápido para agregar boleta al facturable por defecto.
      //if not Visor.SeleccionarFac(Config.FactDef) then exit;
      //acFacAgrVenExecute(self);
    end;
    //Pasa el control de teclado al visor
    Visor.KeyDown(Sender, Key, Shift);
  end;
end;
procedure TfrmPrincipal.FormKeyPress(Sender: TObject; var Key: char);
{El formulario, intercepta el teclado}
var
  res: Integer;
  ogFac: TogFac;
  fac: TCibFac;
begin
  if Key = ' ' then begin
    //Orden directa para el visor
    Visor.SetFocus;
  end;
  if Visor.Focused or Memo1.Focused then begin
      if Key in ['0'..'9'] then begin
        if frmCalcul.Visible then begin
          //Si ya es visible, solo actualizamos
          frmCalcul.Edit1.Text:=Key;
          frmCalcul.Edit1.SelStart:=1;
          frmCalcul.Edit1.SelLength:=0;
          frmCalcul.Show;   //por si estaba sin enfoque
        end else begin
          frmCalcul.txtIni:=Key;
          frmCalcul.Show;
        end;
      end else if Key = ' ' then begin
        //Seleciona al facturable por defecto
        Visor.SeleccionarFac(Config.FactDef);
      end else if Key = '.' then begin
        //Acceso rápido a la ventana de selección
        res := frmSelecObjetos.Exec(Modelo, Visor, '.');
        if res = mrYes then begin
          //Interpretamos como que se quiere abrir el menú contextual
          Visor.MenuContextual;
        end;
      end else if Key in ['A'..'Z','a'..'z'] then begin
        //Ingreso directo de una venta
//        acFacAgrVenExecute(self);
        ogFac := Visor.FacSeleccionado;
        if ogFac = nil then begin
          frmIngVentas.Exec(nil,Key)
        end else begin
          fac := Modelo.BuscarPorID(ogFac.IdFac);
          frmIngVentas.Exec(fac, Key);
        end;
      end else if Key = #13 then begin
        //if Visor.FacSeleccionado<>nil then begin
        //  acFacVerBolExecute(self);
        //end;
      end;
  end;
end;
procedure TfrmPrincipal.LeerEstadoDeArchivo;
{Lee el estado de los objetos del archivo de estado}
var
  cad: string;
begin
  if not FileExists(arcEstado) then begin
    msgErr('No se encuentra archivo de estado: ' + arcEstado);
    exit;
  end;
  cad := StringFromFile(arcEstado);
  Modelo.CadEstado := cad;
end;
procedure TfrmPrincipal.Timer1Timer(Sender: TObject);
{Como esta rutina se ejecuta cada 0.5 segundos, no es necesario actualizarla por eventos.}
begin
//  debugln(tmp);
  Visor.ActualizarEstado(Modelo.CadEstado);
  //Aprovecha para refrescar los exploradores de archivos
  Inc(tic);
//  if tic mod 2 = 0 then begin  //cada 1 seg
//    for
//  end;
  //Guarda en disco, por si acaso.
  if tic mod 60 = 0 then begin  //para evitar escribir muchas veces en disco
    Modelo_EstadoArchivo; //Por si ha habido cambios
  end;
end;
procedure TfrmPrincipal.ConfigfcVistaUpdateChanges;
//Cambios en vista
begin
  panLLam.Visible := Config.verPanLlam;
  panBolet.Visible:= Config.verPanBol;
  Visor.ModDiseno := Config.modDiseno;
  case Config.StyleToolbar of
  stb_SmallIcon: begin
    ToolBar1.ButtonHeight:=22;
    ToolBar1.ButtonWidth:=22;
    ToolBar1.Height:=26;
    ToolBar1.Images:=ImageList16;
  end;
  stb_BigIcon: begin
    ToolBar1.ButtonHeight:=38;
    ToolBar1.ButtonWidth:=38;
    ToolBar1.Height:=40;
    ToolBar1.Images:=ImageList32;
  end;
  end;
end;
procedure TfrmPrincipal.frmIngVentas_AgregarVenta(CibFac: TCibFac; itBol: string
  );
{Este evento se genera cuando se solicita ingresar una venta a la boleta de un objeto.}
var
  txt: string;
begin
  txt := CibFac.IdFac + #9 + itBol;
  PonerComando(CVIS_ACBOLET, ACCITM_AGR, 0, txt);  //envía con tamaño en Y
end;

//////////////// Acciones //////////////////////
procedure TfrmPrincipal.acArcRutTrabExecute(Sender: TObject);
begin
  Exec('explorer', rutApp);
end;
procedure TfrmPrincipal.acArcSalirExecute(Sender: TObject);   //Salir
begin
  Close;
end;
//Acciones Editar
procedure TfrmPrincipal.acEdiInsGrCliExecute(Sender: TObject);
var
  nom: String;
  grupClientes: TCibGFacClientes;
begin
  nom :=  Modelo.BuscaNombreItem('Clientes');  //Busca nombre distinto
  grupClientes := TCibGFacClientes.Create(nom);  //crea grupo
  Modelo.Agregar(grupClientes);  //agrega el grupo}
end;
procedure TfrmPrincipal.acEdiInsGrCabExecute(Sender: TObject);  //Inserta Grupo de cabinas
var
  ncabTxt, nom: String;
  ncab: Longint;
  grupCabinas: TCibGFacCabinas;
begin
  ncabTxt := InputBox('', 'Número de cabinas', '5');
  if not TryStrToInt(ncabTxt, ncab) then exit;
  nom := Modelo.BuscaNombreItem('Cabinas');  //Busca nombre distinto
  grupCabinas := TCibGFacCabinas.Create(nom);  //crea grupo
  Modelo.Agregar(grupCabinas);  //agrega el grupo}
end;
procedure TfrmPrincipal.acEdiInsEnrutExecute(Sender: TObject); //Inserta Enrutador
var
  grupNILOm: TCibGFacNiloM;
  nom: String;
begin
  nom := InputBox('', 'Nombre: ', 'NILO-m');
  if trim(nom)='' then begin
    msgExc('Nombre no válido.');
    exit;
  end;
  if Modelo.ItemPorNombre(nom) <> nil then begin
    msgExc('Nombre ya existe.');
    exit;
  end;
  grupNILOm := TCibGFacNiloM.Create(nom);
  //Inicializa Nilo-m
  //grupNILOm.OnRegMsjError:=@NiloM_RegMsjError;
  //grupNILOm.Conectar;
  //if grupNILOm.MsjError<>'' then self.Close;  //Error grave
  Modelo.Agregar(grupNILOm);  //agrega el grupo
end;
procedure TfrmPrincipal.acEdiInsGrMesExecute(Sender: TObject);
var
  nom: String;
  grupMesas: TCibGFacMesas;
begin
  nom :=  Modelo.BuscaNombreItem('Mesas');  //Busca nombre distinto
  grupMesas := TCibGFacMesas.Create(nom);  //crea grupo
  Modelo.Agregar(grupMesas);  //agrega el grupo}
end;
procedure TfrmPrincipal.acEdiElimGruExecute(Sender: TObject);  //Eliminar grupo
var
  gFac: TCibGFac;
  ogGFac: TogGFac;
begin
  ogGFac := Visor.GFacSeleccionado;
  if ogGFac = nil then exit;
  gFac := Modelo.ItemPorNombre(ogGFac.Name);  //Busca grupo en el modelo
  if gFac=nil then exit;
  if MsgYesNo('¿Eliminar grupo: ' +gFac.Nombre + '?')<>1 then exit;
  Modelo.Eliminar(gFac);
end;
procedure TfrmPrincipal.acEdiAlinHorExecute(Sender: TObject);
begin
  Visor.AlinearSelecHor;
end;
procedure TfrmPrincipal.acEdiAlinVerExecute(Sender: TObject);
begin
  Visor.AlinearSelecVer;
end;
procedure TfrmPrincipal.acEdiEspHorExecute(Sender: TObject);
begin
  Visor.EspaciarSelecHor;
end;
procedure TfrmPrincipal.acEdiEspVerExecute(Sender: TObject);
begin
  Visor.EspaciarSelecVer;
end;
// Acciones Ver
procedure TfrmPrincipal.acVerRepIngExecute(Sender: TObject);
begin
  frmRepIngresos.Exec(Config.Local);
end;
procedure TfrmPrincipal.acVerRepProExecute(Sender: TObject);
begin
  frmRepProducto.Exec(Config.Local, tabPro);
end;
procedure TfrmPrincipal.acVerRepEveExecute(Sender: TObject);
begin
  frmRepEventos.Exec(Config.Local);
end;
// Acciones del sistema
procedure TfrmPrincipal.acSisAdmProdExecute(Sender: TObject);
begin
  frmAdminProduc.Exec(tabPro, FormatMon, perfil = PER_ADMIN);
end;
procedure TfrmPrincipal.acSisAdmProveeExecute(Sender: TObject);
begin
  frmAdminProvee.Exec(tabPrv, FormatMon);
end;
procedure TfrmPrincipal.acSisAdmInsumExecute(Sender: TObject);
begin
  frmAdminInsum.Exec(tabIns, FormatMon);
end;
procedure TfrmPrincipal.acSisRegComprasExecute(Sender: TObject);
begin
  //Carga primero tabla de proveedores, para que se puedan usar sus datos en las compras
  frmAdminProvee.Exec(tabPrv, FormatMon);
  frmAdminProvee.Hide;
  frmRegCompras.Exec(tabPro, FormatMon);
end;
procedure TfrmPrincipal.acSisTransProdExecute(Sender: TObject);
{Realiza la trasferenca de un producto desde archivo.}
var
  tipModif: Integer;
  str, filName, err, lstTmp: String;
begin
  OpenDialog1.FileName := '*.ing';
  if not OpenDialog1.Execute then exit;
  filName := OpenDialog1.FileName;
  if not FileExists(filName) then begin
    MsgExc('No se encuentra archivo: ' + filName); exit;
  end;
  //Validación
  str := StringFromFile(filName);
  frmIngStock.Exec(tabPro, FormatMon);
  frmIngStock.ValidarStrIngStock(str, err, lstTmp);
  frmIngStock.Close;
  if err<>'' then begin
    MsgErr(err); exit;
  end;
  //Ingreso
  if MsgYesNo('¿Registrar imgreso de productos?' + LineEnding +
              lstTmp) <> 1 then exit;
  //Mande el comando al modelo.
  tipModif := MODTAB_INGSTCK;   //tipo de modificación
  PonerComando(CVIS_ACTPROD, 0, tipModif, str);
end;
procedure TfrmPrincipal.acSisPersonExecute(Sender: TObject);
begin
  frmPersonal.Show;
end;
procedure TfrmPrincipal.acSisIngStockExecute(Sender: TObject);
begin
  frmIngStock.Exec(tabPro, FormatMon);
end;
procedure TfrmPrincipal.acSisValStockExecute(Sender: TObject);
begin
  frmValStock.Exec(tabPro, FormatMon);
end;
procedure TfrmPrincipal.acSisConfigExecute(Sender: TObject);
begin
  Config.Mostrar;
end;
// Acciones del Usuario
procedure TfrmPrincipal.acUsuCerSesExecute(Sender: TObject);
begin
  if MsgYesNo('¿Cerrar Sesión actual?')<>1 then exit;
  CerrarSesion;
  IniciarSesion;
end;
procedure TfrmPrincipal.acUsuCamClaExecute(Sender: TObject);
begin
  frmCambClave.ShowModal;
end;
//Acciones de Ayuda
procedure TfrmPrincipal.acAyuCalculExecute(Sender: TObject);
begin
  frmCalcul.Show;
end;
procedure TfrmPrincipal.acAyuContDinExecute(Sender: TObject);
begin
  frmContDinero.Show;
end;
procedure TfrmPrincipal.acAyuSelRapidExecute(Sender: TObject);
begin
  frmSelecObjetos.Exec(Modelo, Visor, '');
end;
procedure TfrmPrincipal.acAyuAcercaExecute(Sender: TObject);
begin
  frmAcercaDe.ShowModal;
end;
procedure TfrmPrincipal.acAyuBlocNotExecute(Sender: TObject);
begin
  MisUtils.Exec('CMD', '/C start "TITULO" "notepad"');
end;

end.
//1441
