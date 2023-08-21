// Programa   : COMGRIDPRESAVE 
// Fecha/Hora : 08/10/2005 22:04:16
// Propósito  : Pregrabar GRID de DPDOCPRO
// Creado Por : Juan Navas
// Llamado por: DPDOCPRO
// Aplicación : Ventas
// Tabla      : DPDOCPRO

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(oGrid)

   LOCAL cTipIva:="",cZonaNL:="",nCol,nPvpOrg,nPorPvp,oTable,lResp,oDoc
   LOCAL aData  :={}

   CursorWait()

   IF oGrid=NIL
      RETURN .F.
   ENDIF

   oDoc:=oGrid:oHead

   // Cambio de Numero
   EJECUTAR("DPDOCPROALTER",oDoc )

   // Se agrego para que no deje cargar items con costo y Total en cero TJ
   IF oGrid:MOV_TOTAL=0
       oGrid:MensajeErr("El Costo del Producto NO puede ser Cero")
      RETURN .F.
   ENDIF 
 
   // Modificar Documento
   IF oGrid:oHead:nOption=3

      oGrid:MOV_CODIGO_:=IIF( oGrid:nOption=1 ,  oGrid:MOV_CODIGO , oGrid:MOV_CODIGO_ )
      nCol:=ASCAN(oGrid:aCodReco,oGrid:MOV_CODIGO_)

      IIF( nCol=0 , AADD(oGrid:aCodReco,oGrid:MOV_CODIGO_) , NIL)

   ENDIF

   IF Empty(oDoc:DOC_NUMERO) .AND. !Empty(oDoc:nPar_CxP)
       oGrid:MensajeErr(oDoc:cNomDoc+" Requiere Número")
       DpFocus(oDoc:oDOC_NUMERO)
       RETURN .F.
   ENDIF

   IF Empty(oDoc:cZonaNL)
      oDoc:cZonaNl:=SQLGET("DPPROVEEDOR","PRO_ZONANL","PRO_CODIGO"+GetWhere("=",oDoc:DOC_CODIGO))
      oDoc:cZonaNl:=IF(Empty(oDoc:cZonaNl),"N",oDoc:cZonaNl)
   ENDIF

   cZonaNL:=oDoc:cZonaNL // SQLGET("DPCLIENTES","CLI_ZONANL","CLI_CODIGO"+GetWhere("=",oDoc:DOC_CODIGO))

   cTipIva:=SQLGET("DPINV","INV_IVA,INV_PVPORG,INV_IMPPVP","INV_CODIGO"+GetWhere("=",oGRID:MOV_CODIGO))
   nPvpOrg:=oDp:aRow[2]
   nPorPvp:=oDp:aRow[3]      

// oTable:=OpenTable("SELECT INV_IVA,INV_PVPORG,INV_IMPPVP FROM DPINV WHERE INV_CODIGO='"+oGRID:MOV_CODIGO+"'",.T.)
// cTipIva:=oTable:INV_IVA
// nPvpOrg:=oTable:INV_PVPORG
// nPorPvp:=oTable:INV_IMPPVP
// oTable:End()
// oGrid:MOV_INVACT:=-1 // Neutro, Ajuste de Costo

   oGrid:MOV_FECHA :=oDoc:DOC_FECHA
   oGrid:MOV_TIPDOC:=oDoc:DOC_TIPDOC   // Documento de Inventario

   oGrid:MOV_CXUND :=EJECUTAR("INVGETCXUND",oGrid:MOV_CODIGO,oGrid:MOV_UNDMED)
   oGrid:MOV_TIPO  :="I"      // Producto Individual
   oGrid:MOV_USUARI:=oDp:cUsuario
   oGrid:MOV_CODTRA:=IIF(oGrid:MOV_FISICO<0 .OR. oGrid:MOV_LOGICO<0 .OR. oGrid:MOV_CONTAB<0,"E000","S000")
   oGrid:MOV_CODSUC:=oDoc:DOC_CODSUC
   oGrid:MOV_CENCOS:=oDoc:DOC_CENCOS
   IF Empty(oGrid:MOV_CODALM)
      oGrid:MOV_CODALM:=oDp:cAlmacen
   ENDIF
   oGrid:MOV_CODCTA:=oDoc:DOC_CODIGO
   oGrid:MOV_TIPIVA:=cTipIva // Tipo de IVA
// oGrid:MOV_LOGICO:=oDoc:nPar_InvLog    // Descuenta Lógico
// oGrid:MOV_FISICO:=oDoc:nPar_InvFis    // Descuento Físico
// oGrid:MOV_CONTAB:=oDoc:nPar_InvCon    // Descuento Físico
   oGrid:MOV_INVACT:=1                   // oDoc:nPar_InvAct    // Tipo de transacción Activa, Para Anular

   IF Empty(oGrid:MOV_ASODOC)            
     oGrid:MOV_LOGICO:=oDoc:nPar_InvLog    // Descuenta Lógico
     oGrid:MOV_FISICO:=oDoc:nPar_InvFis    // Descuento Fisico
     oGrid:MOV_CONTAB:=oDoc:nPar_InvCon    // Descuento Contable
   ENDIF

// JN: 08/04/2009
// Solo Items Importados desde Otro Documento
// Opción, Incluir
//
   IF !Empty(oGrid:MOV_ASODOC) .AND. oGrid:nOption=1

    // JN 08/12/2010 (OGrid, Perdia estos valores en parámetros)
    oGrid:nPar_InvLog:=oDoc:nPar_InvLog    // Descuenta Lógico
    oGrid:nPar_InvFis:=oDoc:nPar_InvFis    // Descuento Fisico
    oGrid:nPar_InvCon:=oDoc:nPar_InvCon    // Descuento Contable

    aData:=EJECUTAR("DPMOVINVITEMIMP",NIL,oGrid:MOV_ASOTIP,oGrid:MOV_ASODOC,oGrid:MOV_CODCTA,oGrid:MOV_ITEM_A,"C")

//  IF (oDoc:nPar_InvLog==oGrid:MOV_LOGICO) .OR. (LEN(aData)>1 .AND. ASCAN(aData,{|a,n| a[6]=oGrid:MOV_LOGICO})>0)
    IF (oDoc:nPar_InvLog==oGrid:MOV_LOGICO) .OR. (LEN(aData)>1 .AND. ASCAN(aData,{|a,n| a[6]=oDoc:nPar_InvLog})>0)
      oGrid:MOV_LOGICO:=0
    ELSE
      oGrid:MOV_LOGICO:=oDoc:nPar_InvLog
    ENDIF

    // Físicamente ya Afectó el Inventario no puede hacerlo dos Veces
//  IF (oDoc:nPar_InvFis==oGrid:MOV_FISICO) .OR. (LEN(aData)>1 .AND. ASCAN(aData,{|a,n| a[7]=oGrid:MOV_FISICO})>0)
    IF (oDoc:nPar_InvFis==oGrid:MOV_FISICO) .OR. (LEN(aData)>1 .AND. ASCAN(aData,{|a,n| a[7]=oDoc:nPar_InvFis})>0)
       oGrid:MOV_FISICO:=0
    ELSE
       oGrid:MOV_FISICO:=oDoc:nPar_InvFis
    ENDIF

    // Contablemente ya Afectó el Inventario no puede hacerlo dos Veces

// ? oDoc:nPar_InvCon,oGrid:MOV_CONTAB,LEN(aData),CLPCOPY(CTOO(aData,"C")),;
//  ,oDoc:nPar_InvCon==oGrid:MOV_CONTAB,ASCAN(aData,{|a,n| a[8]==oGrid:MOV_CONTAB})>0

//  IF (oDoc:nPar_InvCon==oGrid:MOV_CONTAB) .OR. (LEN(aData)>1 .AND. ASCAN(aData,{|a,n| a[8]==oGrid:MOV_CONTAB})>0)
    IF (oDoc:nPar_InvCon==oGrid:MOV_CONTAB) .OR. (LEN(aData)>1 .AND. ASCAN(aData,{|a,n| a[8]==oDoc:nPar_InvCon})>0)
        oGrid:MOV_CONTAB:=0
    ELSE
        oGrid:MOV_CONTAB:=oDoc:nPar_InvCon
    ENDIF

   ENDIF

   nCol:=IIF(!cZonaNL="N",5,3) // Col=3 (Compras)

   // Para todos los casos se calcula IVA, Importación no Calcula IVA
   IF oDoc:lPar_IVA .AND. LEFT(oDOC:DOC_ORIGEN,1)="N" // Indica si el Documento Calcula IVA
     oGrid:MOV_IVA   :=EJECUTAR("IVACAL",cTipIva,nCol,oDoc:DOC_FECHA) // IVA (Nacional o Zona Libre
     oGrid:MOV_IMPOTR:=EJECUTAR("IVACAL",cTipIva,6   ,oDoc:DOC_FECHA) // OTROS IMPUESTOS
   ENDIF

   //
   // Las Ordenes de Compra Importación, Documentos sin IVA, No calcula IVA
   //

   IF !oDoc:lPar_IVA .OR. (LEFT(oDOC:DOC_ORIGEN,1)="I" .AND. oDoc:nPar_CxP<>0)
     oGrid:MOV_IVA   :=0
     oGrid:MOV_IMPOTR:=0
   ENDIF

   // Otro Impuesto Calculado desde la Ficha del producto
   IF !Empty(nPvpOrg) .AND. !Empty(nPorPvp)
      oGrid:MOV_IMPOTR:=PORCEN(nPvpOrg,nPorPvp)
   ELSE
      oGrid:MOV_IMPOTR:=PORCEN(nPvpOrg,oGrid:MOV_IMPOTR)
   ENDIF
   // Otros Impuestos por Unidades IMPPVP se Graba por Unidad
   oGrid:MOV_IMPOTR:=oGrid:MOV_IMPOTR*(oGrid:MOV_CXUND*oGrid:MOV_CANTID)

/*
 //Desactivado momentaneamente ya que produce error al importar documentos TJ

   IF ALLTRIM(oGrid:cInvDescri)<>ALLTRIM(oGrid:INV_DESCRI)

      oGRID:MOV_NUMMEM:=EJECUTAR("DPMEMOGET",oGRID:INV_DESCRI,oGRID:MOV_NUMMEM)

      IF EMPTY(oGrid:aMemo[7])
         oGrid:aMemo[7]:=0
         oGrid:aMemo[8]:=""
         oGrid:aMemo[9]:=oGrid:INV_DESCRI
      ENDIF

   ENDIF
*/

   // sustituido TJ
   IF !(ALLTRIM(oGrid:INV_DESCRI)==ALLTRIM(SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))))

      oGRID:MOV_NUMMEM:=EJECUTAR("DPMEMOGET",oGRID:INV_DESCRI,oGRID:MOV_NUMMEM,oGRID:MOV_CODIGO)

      MYSQLGET("DPINV","INV_NUMMEM","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))

      oGrid:aMemo[9]:=oGrid:INV_DESCRI

   ENDIF


   IF oGrid:nOption=1
      oGrid:MOV_HORA  :=TIME() // oDoc:DOC_HORA 
   ENDIF

   // Cambio del Código del Proveedor
   IF !Empty(oDoc:cCodigo) .AND. oDoc:cCodigo<>oDoc:DOC_CODIGO

      lResp:=EJECUTAR("DPDOCPROPRO",oDoc:DOC_CODSUC,oDoc:DOC_TIPDOC,oDoc:cNumero,oDoc:cCodigo,;
                                    oDoc:DOC_CODIGO,oDoc:DOC_NUMERO)
      IF lResp
        oDoc:cCodCli:=""
      ENDIF

   ENDIF

//  JN 04/01/2016
//  Remplazado por Capas de Precios en FIFO
//  oGrid:MOV_CAPAP:=EJECUTAR("DPINVCAPAPRECIO",oGrid:MOV_CODIGO,oGrid:MOV_PRECIO,oGrid:MOV_FCHVEN,oGrid:MOV_CAPAP,oGrid)
//? oGrid:MOV_CAPAP,"oGrid:MOV_CAPAC"

   // Capas en FIFO, Entrada Contable
   IF oGrid:cMetodo="F" .AND. oGrid:MOV_CONTAB=1
     oGrid:MOV_LOTE:=EJECUTAR("FIFOGETCAPA",oGrid:MOV_CODIGO,oGrid:MOV_COSTO*oGrid:MOV_CXUND,oGrid:MOV_FECHA,oGrid:MOV_PRECIO)
   ENDIF

RETURN .T.
// EOF



