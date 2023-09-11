// Programa   : DPDOCPROVIEWPAG
// Fecha/Hora : 16/02/2004 16:39:12
// Propósito  : Consultar los Pagos de una Factura
// Creado Por : Juan Navas
// Llamado por: DPDOCPRO
// Aplicación : Ventas
// Tabla      : DPDOCPRO

#INCLUDE "INCLUDE\DPXBASE.CH"
#INCLUDE "SAYREF.CH"


PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero,cMemo)
  LOCAL oBrw,oFontBrw,oFontB,oCol,nTotal:=0,oSayRef,oBtn,dFchVen
  LOCAL cWhere,aData,cSql,oTable,cNombre,dFecha,dFchVen,nNeto
  LOCAL cTitle:="Pagos de "

  DEFAULT cCodSuc:=oDp:cSucursal,;
          cTipDoc:="FAV",;
          cNumero:=STRZERO(1,10),;
          cCodigo:=STRZERO(1,10)

  cTitle:=cTitle+ALLTRIM(MySQLGET("DPTIPDOCPRO","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipDoc)))+;
          " "+cNumero

  nNeto :=MySqlget("DPDOCPRO","DOC_NETO,DOC_FCHVEN","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                         "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                         "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                                         "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                         "DOC_TIPTRA"+GetWhere("=","D"    )+" AND "+;
                                         "DOC_ACT   =1")



  dFchVen:= IIF( Empty(oDp:aRow) , CTOD("") , oDp:aRow[2] )

  oTable:=OpenTable(" SELECT DOC_PAGNUM,DOC_FECHA,DOC_HORA,PAG_CBTNUM,DOC_NETO,0 AS RATA,0 AS SALDO,0 AS DIAS,DOC_FECHA FROM DPDOCPRO "+;
                    " INNER JOIN DPCBTEPAGO ON DOC_PAGNUM=PAG_NUMERO AND DOC_CODSUC=PAG_CODSUC "+;
                    " WHERE DOC_CODSUC"+GetWhere("=",cCodSuc)+;
                    "  AND DOC_TIPDOC"+GetWhere("=",cTipDoc)+;
                    "  AND DOC_CODIGO"+GetWhere("=",cCodigo)+;
                    "  AND DOC_NUMERO"+GetWhere("=",cNumero)+;
                    "  AND DOC_TIPTRA"+GetWhere("=","P"    )+;
                    "  AND DOC_ACT   =1" +;
                    "  ORDER BY DOC_FECHA,DOC_HORA ",.T.)

  
  oTable:Replace("RATA" ,0)
  oTable:Replace("SALDO",0)
  oTable:Replace("DIAS" ,0)

  WHILE !oTable:Eof()
    nNeto:=nNeto-oTable:DOC_NETO
    oTable:Replace("SALDO",nNeto)
    oTable:Replace("DIAS" ,oTable:DOC_FECHA-dFchVen)
    oTable:Replace("RATA" ,RATA(oTable:DOC_NETO,nNeto))
    oTable:DbSkip()
  ENDDO

  aData:=ACLONE(oTable:aDataFill)

  IF Empty(aData)
     MensajeErr("Información no Fué Encontrada")
     RETURN .F.
  ENDIF

  ViewData(aData,cCodigo,cTitle)
              
RETURN .T.

FUNCTION ViewData(aData,cCodigo,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData),cNombre:="ASADFA"
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   cNombre:=MYSQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",cCodigo))

   oPagView:=DPEDIT():New(cTitle,"DPDOCPROVIEWPAG.EDT","oPagView",.T.)
   oPagView:cCodigo :=cCodigo
   oPagView:cNombre :=cNombre
   oPagView:cNumero :=cNumero
   oPagView:cTipDoc :=cTipDoc
   oPagView:cCodSuc :=cCodSuc
   oPagView:lMsgBar :=.F.

   oPagView:oBrw:=TXBrowse():New( oPagView:oDlg )
   oPagView:oBrw:SetArray( aData, .F. )
   oPagView:oBrw:SetFont(oFont)
   oPagView:oBrw:lFooter     := .T.
   oPagView:oBrw:lHScroll    := .F.
   oPagView:oBrw:nHeaderLines:= 2
   oPagView:oBrw:lFooter     :=.T.

   oPagView:cCodigo  :=cCodigo
   oPagView:cNombre  :=cNombre
   oPagView:aData    :=ACLONE(aData)

   AEVAL(oPagView:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oPagView:oBrw:aCols[1]   
   oCol:cHeader      :="Cbte."+CRLF+"Pago"
   oCol:nWidth       :=065

   oCol:=oPagView:oBrw:aCols[2]
   oCol:cHeader      :="Fecha"
   oCol:nWidth       :=70

   oCol:=oPagView:oBrw:aCols[3]
   oCol:cHeader      :="Hora"
   oCol:nWidth       :=60

   oCol:=oPagView:oBrw:aCols[4]
   oCol:cHeader      :="Cbte."+CRLF+"Contab"
   oCol:nWidth       :=60

   oCol:=oPagView:oBrw:aCols[5]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Pago"
   oCol:nWidth       :=120
   oCol:bStrData     :={|nMonto|nMonto:=oPagView:oBrw:aArrayData[oPagView:oBrw:nArrayAt,5],;
                                TRAN(nMonto,"99,999,999,999.99")}

   oCol:cFooter      :=TRAN(aTotal[5],"99,999,999,999.99")

   oCol:=oPagView:oBrw:aCols[6]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="%"
   oCol:nWidth       :=090
   oCol:bStrData     :={|nMonto|nMonto:=oPagView:oBrw:aArrayData[oPagView:oBrw:nArrayAt,6],;
                                TRAN(nMonto,"999.99")}

   oCol:cFooter       :=TRAN(aTotal[6],"999.99")


   oCol:=oPagView:oBrw:aCols[7]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Saldo"
   oCol:nWidth       :=120
   oCol:bStrData     :={|nMonto|nMonto:=oPagView:oBrw:aArrayData[oPagView:oBrw:nArrayAt,7],;
                                TRAN(nMonto,"99,999,999,999.99")}


   oCol:=oPagView:oBrw:aCols[8]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Días"+CRLF+"Mora"
   oCol:nWidth       :=040
   oCol:bStrData     :={|nMonto|nMonto:=oPagView:oBrw:aArrayData[oPagView:oBrw:nArrayAt,8],;
                                TRAN(nMonto,"9999")}


   oPagView:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oPagView:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           nClrText:=0,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, 15138815, 12189695 ) } }

   oPagView:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oPagView:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


/*
   oCol:bLClickFooter:={|oBrw|oBrw:=oPagView:oBrw,;
                              EJECUTAR("DPDOCPROVIEW",;
                              oPagView:cCodigo,;
                              NIL,;
                              NIL,;
                              oPagView:aData[oBrw:nArrayAt,2],,,,,"Estado de Cuenta")}

*/  
   FOR I=1 TO LEN(oPagView:oBrw:aCols)
       oPagView:oBrw:aCols[I]:bLClickFooter:=oCol:bLClickFooter
   NEXT I
/*

   oPagView:oBrw:bLDblClick:={|oBrw|oBrw:=oPagView:oBrw,;
                                   EJECUTAR("DPDOCPROVIEW",;
                                   oPagView:cCodigo,;
                                   oPagView:aData[oBrw:nArrayAt,1],;
                                   oPagView:aData[oBrw:nArrayAt,2],;
                                   oPagView:aData[oBrw:nArrayAt,2],,,,,"Estado de Cuenta")}

*/
   oPagView:oBrw:CreateFromCode()

   oPagView:Activate({||oPagView:ViewDatBar(oPagView)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oPagView)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oPagView:oDlg

   oPagView:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\TESORERIA.BMP";
          ACTION oPagView:DPCBTEPAGO()

  oBtn:cToolTip:="Comprobante de Pago"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oDp:oRep:=REPORTE("DOCPROPAG"),;
                  oDp:oRep:SetRango(1,oPagView:cCodigo,oPagView:cCodigo),;
                  oDp:oRep:SetRango(2,oPagView:cNumero,oPagView:cNumero),;
                  oDp:oRep:SetCriterio(1,oPagView:cCodSuc),;
                  oDp:oRep:SetCriterio(2,oPagView:cTipDoc))

   oBtn:cToolTip:="Listado de Pagos"



   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oPagView:oBrw,oPagView:cTitle,oPagView:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oPagView:oBrw:GoTop(),oPagView:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oPagView:oBrw:PageDown(),oPagView:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oPagView:oBrw:PageUp(),oPagView:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oPagView:oBrw:GoBottom(),oPagView:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oPagView:Close()

  oPagView:oBrw:SetColor(0,15138815)

  @ 0.1,50+3 SAY "Código: "+oPagView:cCodigo OF oBar BORDER SIZE 345,18
  @ 1.4,50+3 SAY "Nombre: "+oPagView:cNombre OF oBar BORDER SIZE 345,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.


FUNCTION DPCBTEPAGO()
  LOCAL aLine:=oPagView:oBrw:aArrayData[oPagView:oBrw:nArrayAt]
  LOCAL lAuto:=.T.,cTipPag:=NIL,cCodSuc:=oDp:cSucursal,cRecord:=aLine[1],lView:=.T.

  IF Empty(cRecord)
     MensajeErr("Registro sin Comprobante de Pago")
     RETURN .F.
  ENDIF

  cRecord:="PAG_NUMERO"+GetWhere("=",cRecord)
  
//? cRecord,"cRecord"

RETURN EJECUTAR("DPCBTEPAGO",.F.,NIL,NIL,"",cRecord,lView)
// "PAG_NUMERO"+GetWhere("=",cNumero))
//  EJECUTAR("DPCBTEPAGO",lAuto,cTipPag,cCodSuc,oPagView:cCodigo,cRecord,lView)
// RETURN 
