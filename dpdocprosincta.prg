// Programa   : DPDOCPROSINCTA
// Fecha/Hora : 10/03/2023 10:12:09
// Propósito  : Documentos de Compras no asociadas con Cuentas DPDOCPROCTA
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Gerencia 
// Tabla      : DPDOCPRO/DPDOCPRORTI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,nPeriodo,dDesde,dHasta)
   LOCAL aData,cTitle,cWhere,aFechas,cWhere

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=oDp:nIndefinida

   IF Type("oDocSinC")="O" .AND. oDocSinC:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oDocSinC,GetScript())
   ENDIF
   cTitle:="Documentos de Compras (CXP) sin Vinculos con Cuentas "

   IF .T.
     aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
     dDesde :=aFechas[1]
     dHasta :=aFechas[2]
   ENDIF

   aData :=LEERDOCPRO(GetWhereAnd("DOC_FCHDEC",dDesde,dHasta))

   IF Empty(aData)
      MensajeErr("no hay "+cTitle,"Información no Encontrada")
      RETURN .F.
   ENDIF

   ViewData(aData,cTitle)
            
RETURN .T.

FUNCTION ViewData(aData,cTitle)
   LOCAL oBrw,oCol,aTotal:=ATOTALES(aData)
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0
   LOCAL aPeriodos:=ACLONE(oDp:aPeriodos)

//{"Diario","Semanal","Quincenal","Mensual","Bimestral","Trimestral","Semestral","Anual","Indicada"}

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

   // oDocSinC:=DPEDIT():New(cTitle,"DPDOCPROSINCTA.EDT","oDocSinC",.T.)

   DpMdi(cTitle,"oDocSinC"," DPDOCPROSINCTA.EDT")
   oDocSinC:Windows(0,0 ,oDp: aCoors[3]-160,oDp:aCoors[4]- 10,.T.) // Maximizado

   oDocSinC:cCodSuc :=oDp:cSucursal
   oDocSinC:lMsgBar :=.F.
   oDocSinC:cPeriodo:=aPeriodos[nPeriodo]
   oDocSinC:cCodSuc :=cCodSuc
   oDocSinC:nPeriodo:=nPeriodo

//   oDocSinC:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
   oDocSinC:dDesde  :=dDesde
   oDocSinC:dHasta  :=dHasta

   oDocSinC:oBrw:=TXBrowse():New( oDocSinC:oDlg )
   oDocSinC:oBrw:SetArray( aData, .T. )
   oDocSinC:oBrw:SetFont(oFont)

   oDocSinC:oBrw:lFooter     := .T.
   oDocSinC:oBrw:lHScroll    := .T.
   oDocSinC:oBrw:nHeaderLines:= 3
   oDocSinC:oBrw:lFooter     :=.T.

   oDocSinC:aData            :=ACLONE(aData)
  oDocSinC:nClrText :=0
  oDocSinC:nClrPane1:=16773862
  oDocSinC:nClrPane2:=16771538

   AEVAL(oDocSinC:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oDocSinC:oBrw:aCols[1]   
   oCol:cHeader      :="Ti"+CRLF+"po"
   oCol:nWidth       :=042

   oCol:=oDocSinC:oBrw:aCols[2]
   oCol:cHeader      :="Código"
   oCol:nWidth       :=76

   oCol:=oDocSinC:oBrw:aCols[3]
   oCol:cHeader      :="Numero"
   oCol:nWidth       :=70
   oCol:cFooter      :=LSTR(LEN(aData))+" Reg"


   oCol:=oDocSinC:oBrw:aCols[4]
   oCol:cHeader      :="Nombre "+oDp:xDPPROVEEDOR
   oCol:nWidth       :=250

   oCol:=oDocSinC:oBrw:aCols[5]
   oCol:cHeader      :="Fecha"+CRLF+"Decl."
   oCol:nWidth       :=70

   oCol:=oDocSinC:oBrw:aCols[6]
   oCol:cHeader      :="Estado"
   oCol:nWidth       :=70

   oCol:=oDocSinC:oBrw:aCols[7]   
   oCol:cHeader      :="Monto"+CRLF+"Neto"
   oCol:nWidth       :=105
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oDocSinC:oBrw:aArrayData[oDocSinC:oBrw:nArrayAt,7],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[7],"999,999,999,999.99")


   oCol:=oDocSinC:oBrw:aCols[8]   
   oCol:cHeader      :="Monto"+CRLF+"IVA"
   oCol:nWidth       :=95
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oDocSinC:oBrw:aArrayData[oDocSinC:oBrw:nArrayAt,8],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[8],"999,999,999,999.99")


   oCol:=oDocSinC:oBrw:aCols[9]   
   oCol:cHeader      :="Monto"+CRLF+"Neto"
   oCol:nWidth       :=95
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oDocSinC:oBrw:aArrayData[oDocSinC:oBrw:nArrayAt,9],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[9],"999,999,999,999.99")



   oDocSinC:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oDocSinC:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oDocSinC:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oDocSinC:nClrPane1, oDocSinC:nClrPane2 ) } }

   oDocSinC:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDocSinC:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oDocSinC:oBrw:bLDblClick:={|oBrw|oDocSinC:oRep:=oDocSinC:VERPROVEEDOR() }

   oDocSinC:oBrw:CreateFromCode()
    oDocSinC:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDocSinC)}
    oDocSinC:BRWRESTOREPAR()

   oDocSinC:oWnd:oClient := oDocSinC:oBrw

   oDocSinC:Activate({||oDocSinC:ViewDatBar(oDocSinC)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oDocSinC)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oDocSinC:oDlg,oBtnCal

   oDocSinC:oBrw:GoBottom(.T.)
   oDocSinC:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RETIVA.BMP",NIL,"BITMAPS\RETIVAG.BMP";
          ACTION oDocSinC:oRep:=oDocSinC:HACERRTI();
          WHEN !Empty(oDocSinC:oBrw:aArrayData[1,1])
               
   oBtn:cToolTip:="Hacer Retención "


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PROVEEDORES.BMP",NIL,"BITMAPS\PROVEEDORESG.BMP";
          ACTION oDocSinC:oRep:=oDocSinC:VERPROVEEDOR();
          WHEN !Empty(oDocSinC:oBrw:aArrayData[1,1])
               
   oBtn:cToolTip:="Ver "+oDp:DPCLIENTES

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oDocSinC:oBrw,oDocSinC:cTitle,oDocSinC:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDocSinC:Close()

  oDocSinC:oBrw:SetColor(0,oDocSinC:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})


  //
  // Campo : Periodo
  //

  @ 1.0, (084-30.0+5)+8 COMBOBOX oDocSinC:oPeriodo  VAR oDocSinC:cPeriodo ITEMS aPeriodos;
               SIZE 100,NIL;
               OF oBar;
               FONT oFont;
               ON CHANGE oDocSinC:LEEFECHAS()

  @ oDocSinC:oPeriodo:nTop,080 SAY "Periodo:" OF oBar BORDER SIZE 34,24

  ComboIni(oDocSinC:oPeriodo )

  @ 0.75, (126-36+6)+10 BUTTON oDocSinC:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDocSinC:oPeriodo:nAt,oDocSinC:oDesde,oDocSinC:oHasta,-1),;
                         EVAL(oDocSinC:oBtn:bAction))



  @ 0.75, (126-31.5+6)+10 BUTTON oDocSinC:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDocSinC:oPeriodo:nAt,oDocSinC:oDesde,oDocSinC:oHasta,+1),;
                         EVAL(oDocSinC:oBtn:bAction))


  @ 1.15, (078-3+6)+8 BMPGET oDocSinC:oDesde  VAR oDocSinC:dDesde;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDocSinC:oDesde ,oDocSinC:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oDocSinC:oPeriodo:nAt=LEN(oDocSinC:oPeriodo:aItems);
                FONT oFont

   oDocSinC:oDesde:cToolTip:="F6: Calendario"

  @ 1.15, (088-3+6)+08 BMPGET oDocSinC:oHasta  VAR oDocSinC:dHasta;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDocSinC:oHasta,oDocSinC:dHasta);
                SIZE 80,23;
                WHEN oDocSinC:oPeriodo:nAt=LEN(oDocSinC:oPeriodo:aItems);
                OF oBar;
                FONT oFont

   oDocSinC:oHasta:cToolTip:="F6: Calendario"

   @ 0.75, (126+10)+10 BUTTON oDocSinC:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               WHEN oDocSinC:oPeriodo:nAt=LEN(oDocSinC:oPeriodo:aItems);
               ACTION oDocSinC:LEERDOCPRO(GetWhereAnd("DOC_FCHDEC",oDocSinC:dDesde,oDocSinC:dHasta),oDocSinC:oBrw)


   oDocSinC:oDesde:ForWhen(.T.)
   oDocSinC:oBtn:Refresh(.T.)

   oDocSinC:oBar:=oBar
   oBtnCal:bWhen:={|| !Empty(oDocSinC:oBrw:aArrayData[1,1]) .AND. ;
                      !(oDocSinC:oPeriodo:nAt=LEN(oDocSinC:oPeriodo:aItems)) }


RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR(cCodInv)
  LOCAL oRep

  oRep:=REPORTE("INVCOSULT")
  oRep:SetRango(1,oDocSinC:cCodInv,oDocSinC:cCodInv)

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oDocSinC:oPeriodo:nAt,cWhere

  oDocSinC:nPeriodo:=nPeriodo

  IF oDocSinC:oPeriodo:nAt=LEN(oDocSinC:oPeriodo:aItems)

     oDocSinC:oDesde:ForWhen(.T.)
     oDocSinC:oHasta:ForWhen(.T.)
     oDocSinC:oBtn  :ForWhen(.T.)

     DPFOCUS(oDocSinC:oDesde)

  ELSE

     oDocSinC:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oDocSinC:oDesde:VarPut(oDocSinC:aFechas[1] , .T. )
     oDocSinC:oHasta:VarPut(oDocSinC:aFechas[2] , .T. )

     oDocSinC:dDesde:=oDocSinC:aFechas[1]
     oDocSinC:dHasta:=oDocSinC:aFechas[2]

     cWhere:=GETWHEREAND("DOC_FCHDEC",oDocSinC:aFechas[1],oDocSinC:aFechas[2])

     oDocSinC:LEERDOCPRO(cWhere,oDocSinC:oBrw)

  ENDIF

RETURN .T.

FUNCTION LEERDOCPRO(cWhere,oBrw)
   LOCAL aData:={},aTotal:={},oDb
   LOCAL cSql,cCodSuc:=oDp:cSucursal

   cSql:=[ SELECT DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO,PRO_NOMBRE,DOC_FCHDEC,DOC_ESTADO,DOC_BASNET,DOC_MTOIVA,DOC_NETO ]+;
         [ FROM DPDOCPRO ]+;
         [ INNER JOIN DPTIPDOCPRO ON DOC_TIPDOC=TDC_TIPO AND TDC_LIBCOM=1]+;
         [ LEFT JOIN DPPROVEEDOR ON DOC_CODIGO=PRO_CODIGO ]+;
         [ LEFT JOIN DPDOCPROCTA ON CCD_CODSUC=DOC_CODSUC AND CCD_TIPDOC=DOC_TIPDOC AND CCD_CODIGO=DOC_CODIGO AND CCD_NUMERO=DOC_NUMERO AND CCD_TIPTRA=DOC_TIPTRA ]+;
         [ WHERE DOC_CODSUC]+GetWhere("=",oDp:cSucursal)+;
         [   AND DOC_TIPTRA="D" AND DOC_DOCORG='D' AND CCD_CODSUC IS NULL ]+;
         [  ]+IIF( Empty(cWhere),[],[ AND ])+cWhere

   aData:=ASQL(cSql)

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
   ENDIF

   AEVAL(aData,{|a,n| aData[n,06]:=SAYOPTIONS("DPDOCPRO","DOC_ESTADO",a[6]) })

   IF ValType(oBrw)="O"
      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      oBrw:aCols[04]:cFooter      :=LSTR(LEN(aData))+" Reg"
      oBrw:aCols[07]:cFooter     :=TRAN( aTotal[07],"999,999,999,999.99")
      oBrw:aCols[08]:cFooter     :=TRAN( aTotal[08],"999,999,999,999.99")
//    oBrw:aCols[10]:cFooter     :=TRAN( aTotal[10],"999,999,999,999.99")

      oBrw:Refresh(.T.)
      AEVAL(oDocSinC:oBar:aControls,{|o,n| o:ForWhen(.T.)})
   ENDIF

RETURN aData

FUNCTION HACERRTI()
    LOCAL aLine:=oDocSinC:oBrw:aArrayData[oDocSinC:oBrw:nArrayAt]
    LOCAL cTipDoc:=aLine[1]
    LOCAL cCodigo:=aLine[2]
    LOCAL cNumero:=aLine[3]

    EJECUTAR("DPDOCPRORTISAV",oDp:cSucursal,cTipDoc,cCodigo,cNumero,NIL,ISTABMOD("DPDOCPRORTI"),NIL,NIL,NIL,.F.,.T.,"oDocSinC:RTIRELOAD()")

RETURN NIL

FUNCTION RTIRELOAD()

   CursorWait()
   EVAL(oDocSinC:oBtn:bAction)

RETURN NIL



 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oDocSinC)
// EOF
