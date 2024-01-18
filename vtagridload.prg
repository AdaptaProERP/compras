// Programa   : VTAGRIDLOAD
// Fecha/Hora : 09/10/2005 11:45:43
// Propósito  : Carga Inicial de Grid para la factura
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación : Ventas
// Tabla      : DPDOCCLI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
  LOCAL cItem,cWhere,oColL

  oGrid:XMOV_CANTID:=0
  oGrid:aSeriales  :={}
  oGrid:nMaxDesc   :=0 // Descuento Maximo Obtenido de Precios
  oGrid:MOV_TIPDOC :=oDoc:cTipDoc
  oGrid:MOV_APLORG :=IIF(oGrid:oHead:lVenta,"V","C") // Todas son Operaciones de Venta
  oGrid:nCostoLote :=0 // Costo del lote
  oGrid:nLotes     :=0 // Existencia del Lote 
  oGrid:nPrecioLote:=0
  oGrid:nPrecioMod :=0  // Modificar Precio
  oGrid:lComent    :=.F.
  oGrid:aEsquema   :={}
  oGrid:lImport    :=.F.
  oGrid:lPresave   :=.F.  
  oGrid:aItems_nomcar :={}
  oGrid:aItems_tipcar :={}
  oGrid:lNewCaract    :=.F.  // No incluye
  oGrid:INV_CODCAR    :=""   // Características
  oGrid:lLeeInvCar    :=.T.
  

  oCol:=EJECUTAR("GRIDSETITEM",oGrid,"MOV_TIPCAR",{})
  oCol:=EJECUTAR("GRIDSETITEM",oGrid,"MOV_NOMCAR",{})

  oColL:=oGrid:GetCol("MOV_LOTE"  ,.F.)

  // Objetivo, obtener los datos del producto desde el objeto GRID
  oGrid:oDpLbxInv:="" // Objeto LBX
  oGrid:cDpLbxSql:="" // Consulta SQL del formulario LBX

  IF oGrid:nOption=1

     cWhere:="MOV_CODSUC"+GetWhere("=",oGrid:oHead:DOC_CODSUC)+" AND "+;
             "MOV_TIPDOC"+GetWhere("=",oGrid:oHead:DOC_TIPDOC)+" AND "+;
             "MOV_CODCTA"+GetWhere("=",oGrid:oHead:DOC_CODIGO)+" AND "+;
             "MOV_DOCUME"+GetWhere("=",oGrid:oHead:DOC_NUMERO)

     cItem  :=SQLINCREMENTAL("DPMOVINV","MOV_ITEM",cWhere)

     cItem  :=IF(Empty(cItem),"1",cItem)
     cItem  :=STRZERO(VAL(cItem),5)

     oGrid:MOV_ASODOC:=""
     oGrid:Set("MOV_ITEM"   , cItem,.T.)
     oGrid:Set("MOV_CANTID" , 1    ,.T.)
     oGrid:Set("MOV_CODALM" , oGrid:oHead:cCodAlm , .T.) // 12/08/2021 oDoc:lPar_Almace .AND.  oDoc:lPar_DocAlm .AND. oDp:nAlmacen>1)
     // Iniciciación de Campos Memos
     oGrid:Set("MOV_NUMMEM" , 0  )
     oGrid:aMemo[7]:=0
     oGrid:aMemo[8]:=""
     oGrid:aMemo[9]:=""

     oGrid:Set("MOV_LOTE"   , "" ) // OEMPTY(oGrid:MOV_LOTE))
     oGrid:Set("MOV_PRECIO" , 0  )
     oGrid:Set("MOV_FCHVEN" , CTOD(""))
     oGrid:Set("MOV_ASOTIP" , "" )
     oGrid:Set("MOV_ASODOC" , "" )
     oGrid:Set("MOV_ITEM_A" , "" )
     oGrid:Set("MOV_TIPCAR" , SPACE(20),.T.)
     oGrid:Set("MOV_NOMCAR" , SPACE(20),.T.)
     oGrid:Set("MOV_CAPAP"  , 0  )

     IF !Empty(oGrid:oHead:cTipOrg)
        oGrid:Set("MOV_ASOTIP",oGrid:oHead:cTipOrg,.T.)
     ENDIF

     IF !Empty(oGrid:oHead:cNumOrg)
        oGrid:Set("MOV_ASODOC",oGrid:oHead:cNumOrg,.T.)
     ENDIF

     oGrid:nPrecio   :=0
     oGrid:nCxUnd    :=0               // Cantidad por Unidad

     IF(oDoc:oScroll=NIL,NIL,oDoc:oScroll:oBrw:Gotop())

  ELSE

     oGrid:nPrecioMod:=oGrid:MOV_PRECIO
     oGrid:nCxUnd    :=oGrid:MOV_CXUND // Cantidad por Unidad

  ENDIF

  // Licencias no se podia modificar porque este campo es para release.

  IF oGrid:nOption=3 .AND. !Empty(oGrid:MOV_ITEM_A) .AND. ISSQLFIND("DPTIPDOCCLI","TDC_TIPO"+GetWhere("=",oGrid:MOV_ITEM_A))

     MensajeErr("Renglón ha sido Importado desde el Item "+oGrid:MOV_ITEM_A+" de "+oGrid:MOV_ASOTIP+" "+oGrid:MOV_ASODOC)
     // Aqui no se debe permitir su Modificación
     // oGrid:CancelEdit(.T.)
     RETURN .F.
  ENDIF

  IF oGrid:nOption=0
     oGrid:CancelEdit()
  ENDIF

RETURN .T.
// EOF
