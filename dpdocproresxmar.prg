// Programa   : DPDOCPRORESXMAR
// Fecha/Hora : 29/05/2006 13:54:04
// Propósito  : Resumen del Documento por Marca
// Creado Por : Juan Navas
// Llamado por: DPDOCCLI
// Aplicación : Conpras
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero)
    LOCAL oMovi,cSql,cTitle:=" Resumen por Marca ",aTotal

    DEFAULT cCodSuc:=oDp:cSucursal,;
            cTipDoc:="FAC",;
            cCodigo:=STRZERO(1,10),;
            cNumero:=STRZERO(1,10)

    cSql :=" SELECT INV_CODMAR,MAR_DESCRI,SUM(MOV_TOTAL) AS MOV_TOTAL,SUM(MOV_CANTID*MOV_CXUND) AS MOV_CANTID FROM DPMOVINV "+;
           " INNER JOIN DPINV    ON MOV_CODIGO=INV_CODIGO "+;
           " INNER JOIN DPMARCAS ON INV_CODMAR=MAR_CODIGO "+;
           " WHERE "+;
           " MOV_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           " MOV_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
           " MOV_CODCTA"+GetWhere("=",cCodigo)+" AND "+;
           " MOV_DOCUME"+GetWhere("=",cNumero)+;
           " GROUP BY INV_CODMAR,MAR_DESCRI"

    oMovi:=OpenTable(cSql , .T. )
    oMovi:Replace("PROXMTO",0,19,2)
    oMovi:Replace("PROXCAN" ,0,06,2)

    aTotal:=ATOTALES(oMovi:aDataFill)

    WHILE !oMovi:Eof()
       oMovi:Replace("PROXMTO", RATA( oMovi:MOV_TOTAL  , aTotal[3]) )
       oMovi:Replace("PROXCAN" ,RATA( oMovi:MOV_CANTID , aTotal[4]) )
       oMovi:DbSkip()
    ENDDO

    oMovi:End()

    IF Empty(oMovi:aDataFill)
       MensajeErr("Información no Encontrada")
       RETURN .F.
    ENDIF

    ViewData(oMovi:aDataFill,cTitle)

RETURN .T.

FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0

   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Arial"   SIZE 0, -12 BOLD

   oRxMarP:=DPEDIT():New(cTitle,"DPDOCPRORESXMA.EDT","oRxMarP",.T.)

   oRxMarP:cCodSuc:=cCodSuc
   oRxMarP:cNombre:=MYSQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",cCodigo))
   oRxMarP:cField :=cField
   oRxMarP:lMsgBar:=.F.
   oRxMarP:cTipDoc:=cTipDoc
   oRxMarP:cNumero:=cNumero
   oRxMarP:cCodigo:=cCodigo

   oRxMarP:oBrw:=TXBrowse():New( oRxMarP:oDlg )
   oRxMarP:oBrw:SetArray( aData, .F. )
   oRxMarP:oBrw:SetFont(oFont)
   oRxMarP:oBrw:lFooter     := .T.
   oRxMarP:oBrw:lHScroll    := .F.
   oRxMarP:oBrw:nHeaderLines:= 1
   oRxMarP:oBrw:lFooter     :=.T.

  // oRxMarP:cCodInv  :=cCodInv
  // oRxMarP:cNombre  :=cNombre

   oRxMarP:aData    :=ACLONE(aData)

   AEVAL(oRxMarP:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oRxMarP:oBrw:aCols[1]   
   oCol:cHeader      :="Código"
   oCol:nWidth       :=110

   oCol:=oRxMarP:oBrw:aCols[2]
   oCol:cHeader      :="Descripción"
   oCol:nWidth       :=250

   oCol:=oRxMarP:oBrw:aCols[3]  
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="Costo"
   oCol:nWidth       :=105
   oCol:bStrData     :={|nMonto|nMonto:=oRxMarP:oBrw:aArrayData[oRxMarP:oBrw:nArrayAt,3],;
                                TRAN(nMonto,"9,999,999,999.99")}

   oCol:cFooter      :=TRAN(aTotal[3],"9,999,999,999.99")


   oCol:=oRxMarP:oBrw:aCols[4]   
   oCol:cHeader      :="Unidades"
   oCol:nWidth       :=105
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oRxMarP:oBrw:aArrayData[oRxMarP:oBrw:nArrayAt,4],;
                                TRAN(nMonto,"9,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[4],"9,999,999,999.99")


   oCol:=oRxMarP:oBrw:aCols[5]   
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="% Costo"
   oCol:nWidth       :=75
   oCol:bStrData     :={|nMonto|nMonto:=oRxMarP:oBrw:aArrayData[oRxMarP:oBrw:nArrayAt,5],;
                                TRAN(nMonto,"9,999,999,999.99")}

   oCol:cFooter      :=TRAN( aTotal[5],"9,999,999,999.99")

   oCol:=oRxMarP:oBrw:aCols[6]   
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:cHeader      :="% Cantidad"
   oCol:nWidth       :=75
   oCol:bStrData     :={|nMonto|nMonto:=oRxMarP:oBrw:aArrayData[oRxMarP:oBrw:nArrayAt,6],;
                                TRAN(nMonto,"999.99")}


   oRxMarP:oBrw:bClrStd    := {|oBrw,nClrText,aData|oBrw:=oRxMarP:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                nClrText:=0,;
                               {nClrText,iif( oBrw:nArrayAt%2=0, 16773862, 16771538 ) } }


   oRxMarP:oBrw:bClrHeader := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oRxMarP:oBrw:bClrFooter := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   FOR I=1 TO LEN(oRxMarP:oBrw:aCols)
       oRxMarP:oBrw:aCols[I]:bLClickFooter:=oCol:bLClickFooter
   NEXT I

/*
   oRxMarP:oBrw:bLDblClick:={|oBrw|oBrw:=oRxMarP:oBrw,;
                                    EJECUTAR("DPMOVINVVIEW",;
                                    oRxMarP:cCodInv,;
                                    oRxMarP:aData[oBrw:nArrayAt,1],;
                                    oRxMarP:aData[oBrw:nArrayAt,2],;
                                    oRxMarP:aData[oBrw:nArrayAt,2],,,, oRxMarP:cCodSuc ,"Transacciones",oRxMarP:cField)}
*/

   oRxMarP:oBrw:CreateFromCode()

   oRxMarP:Activate({||oRxMarP:ViewDatBar(oRxMarP)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oRxMarP)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oRxMarP:oDlg

   oRxMarP:oBrw:GoBottom(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oRxMarP:oRep:=REPORTE(oRxMarP:cRep),;
                  oRxMarP:oRep:SetRango(1,oRxMarP:cCodInv,oRxMarP:cCodInv))

   oBtn:cToolTip:="Imprimir Utilidad"
*/

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oRxMarP:oBrw,oRxMarP:cTitle,oRxMarP:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oRxMarP:oBrw:GoTop(),oRxMarP:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oRxMarP:oBrw:PageDown(),oRxMarP:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oRxMarP:oBrw:PageUp(),oRxMarP:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oRxMarP:oBrw:GoBottom(),oRxMarP:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oRxMarP:Close()

  oRxMarP:oBrw:SetColor(0,16773862)

   @ 0.1,60 SAY " "+ALLTRIM(MYSQLGET("DPTIPDOCPRO","TDC_DESCRI","TDC_TIPO"+GetWhere("=",oRxMarP:cTipDoc)))+;
                ": "+oRxMarP:cNumero;
                OF oBar BORDER SIZE 365,18

   @ 1.4,60 SAY " "+GetFromVar("{oDp:xDPPROVEEDOR}")+": "+oRxMarP:cCodigo+;
                oRxMarP:cNombre;
                OF oBar BORDER SIZE 365,18

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR(cCodInv)
  LOCAL oRep

  oRep:=REPORTE("INVCOSULT")
  oRep:SetRango(1,oRxMarP:cCodInv,oRxMarP:cCodInv)

RETURN .T.

// EOF
