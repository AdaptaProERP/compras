// Programa   : COMGRIDCOSTO  
// Fecha/Hora : 08/10/2005 20:40:33
// Propósito  : Determinar el Costo del Producto
// Creado Por : Juan Navas
// Llamado por: COMGRIDVALCOS
// Aplicación : Compras
// Tabla      : DPMOVINV

#INCLUDE "DPXBASE.CH"

/*
// Asigna el Precio de Venta
*/
FUNCTION MAIN(oGrid,lChoice)
  LOCAL nCosto:=0.00,nAt:=0,cCliPrecio,oCol,aItems:={},aPrecios:={}
  LOCAL cCodMon,oDoc

  IF oGrid=NIL
     RETURN .F.
  ENDIF

  oDoc   :=oGrid:oHead
  cCodMon:=Left(oDoc:DOC_CODMON,3)

  DEFAULT lChoice:=.F.

/*
  oDoc:aPrecios:=PRECIOGET(oGrid:MOV_CODIGO  ,;
                           oGrid:MOV_UNDMED  ,;
                           cCodMon           ,;
                           oGrid:MOV_CANTID  ,;
                           oDoc:DOC_FECHA ,;
				   oDoc:CODCLI    ,;
                           oDoc:DOC_TIPDOC,;
                           .F. )

  IF EMPTY(oDoc:aPrecios)
    nPrecio:=0
    oGrid:Set("MOV_PRECIO",nPrecio,.T.)
    RETURN .F.
  ENDIF

  cCliPrecio:=SQLGET("DPCLIENTES","CLI_LISTA","CLI_CODIGO"+GetWhere("=",oDoc:DOC_CODIGO))
  cCliPrecio:=IIF(EMPTY(cCliPrecio),"A",cCliPrecio)

  oGrid:MOV_LISTA:=cCliPrecio

  nAt:=ASCAN(oDoc:aPrecios,{|a,n|a[1]=cCliPrecio})

  IF LEN(oDoc:aPrecios)=1 // Existe un Solo Precio 
    nAt:=1
    oGrid:Set("MOV_LISTA",oDoc:aPrecios[nAt,1])
  ENDIF

  IF nAt>0
     nPrecio:=oDoc:aPrecios[nAt,2]
  ENDIF

  IF nPrecio=0 .AND. (nAt:=ASCAN(oDoc:aPrecios,{|a,n|a[1]="*"}),nAt>0)
    oGrid:Set("MOV_LISTA","*")
    nPrecio:=oDoc:aPrecios[nAt,2]
  ENDIF

  oGrid:Set("MOV_PRECIO",nPrecio,.T.)
  oCol:=oGrid:GetCol("MOV_PRECIO")

  IF lChoice .AND. LEN(oDoc:aPrecios)>1 .AND. oDoc:lPar_SelPre

     AEVAL(oDoc:aPrecios,{|a,n|AADD(aItems  ,a[1]+":"+TRAN(a[2],oCol:cPicture)),;
                                    AADD(aPrecios,a[2])})

     oCol:aItems    :=ACLONE(aItems)
     oCol:aItemsData:=ACLONE(aPrecios) 
    
  ENDIF

*/

  nCosto:=oGrid:MOV_COSTO

  IF oGrid:nOption=1 // Ingreso de Item
    nCosto:=EJECUTAR("INVGETULTCOS",oGRID:MOV_CODIGO,oGrid:MOV_UNDMED,oDoc:DOC_CODSUC,oDoc:DOC_FECHA,oDp:cHora)
  ENDIF

  oGrid:Set("MOV_COSTO",nCosto,.T.)

  // cCodInv,cUndMed,cCodSuc,dHasta,cHoraMax

  oGrid:ColCalc("MOV_TOTAL")

  IF !oDoc:lPar_SelPre
    oCol:bWhen:={||oDoc:lPar_SelPre}
  ENDIF

RETURN .T.

FUNCTION PRECIOGET(cCodigo,cUndMed,cMoneda,nCantid,dFecha,cCodCli,cTipDoc,lMoneda)
RETURN aPrecios
// EOF


