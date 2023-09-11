// Programa   : DPDOCPROSINRTI
// Fecha/Hora : 10/05/2006 10:12:09
// Propósito  : Documentos de Compras sin Retenciones de IVA
// Creado Por : Juan Navas
// Llamado por: DPMENU
// Aplicación : Gerencia 
// Tabla      : DPDOCPRO/DPDOCPRORTI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,nPeriodo,dDesde,dHasta)
   LOCAL aData,cTitle,cWhere,aFechas,cWhere

   DEFAULT cCodSuc :=oDp:cSucursal,;
           nPeriodo:=oDp:nIndefinida

   IF Type("oDocPRti")="O" .AND. oDocPRti:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oDocPRti,GetScript())
   ENDIF
   cTitle:="Documentos de Compras sin Retenciones de IVA "

   IF .T.
     aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
     dDesde :=aFechas[1]
     dHasta :=aFechas[2]
   ENDIF

/*
   IF nPeriodo=oDp:nIndefinida
      dDesde:=CTOD("")
      dHasta:=CTOD("")
   ENDIF
*/

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

   // oDocPRti:=DPEDIT():New(cTitle,"DPDOCPROSINRTI.EDT","oDocPRti",.T.)

   DpMdi(cTitle,"oDocPRti"," DPDOCPROSINRTI.EDT")
   oDocPRti:Windows(0,0 ,oDp: aCoors[3]-160,oDp:aCoors[4]- 10,.T.) // Maximizado

   oDocPRti:cCodSuc :=oDp:cSucursal
   oDocPRti:lMsgBar :=.F.
   oDocPRti:cPeriodo:=aPeriodos[nPeriodo]
   oDocPRti:cCodSuc :=cCodSuc
   oDocPRti:nPeriodo:=nPeriodo

//   oDocPRti:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)
   oDocPRti:dDesde  :=dDesde
   oDocPRti:dHasta  :=dHasta

   oDocPRti:oBrw:=TXBrowse():New( oDocPRti:oDlg )
   oDocPRti:oBrw:SetArray( aData, .T. )
   oDocPRti:oBrw:SetFont(oFont)

   oDocPRti:oBrw:lFooter     := .T.
   oDocPRti:oBrw:lHScroll    := .T.
   oDocPRti:oBrw:nHeaderLines:= 3
   oDocPRti:oBrw:lFooter     :=.T.

   oDocPRti:aData            :=ACLONE(aData)
  oDocPRti:nClrText :=0
  oDocPRti:nClrPane1:=16773862
  oDocPRti:nClrPane2:=16771538

   AEVAL(oDocPRti:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oCol:=oDocPRti:oBrw:aCols[1]   
   oCol:cHeader      :="Ti"+CRLF+"po"
   oCol:nWidth       :=042

   oCol:=oDocPRti:oBrw:aCols[2]
   oCol:cHeader      :="Código"
   oCol:nWidth       :=76

   oCol:=oDocPRti:oBrw:aCols[3]
   oCol:cHeader      :="Numero"
   oCol:nWidth       :=70
   oCol:cFooter      :=LSTR(LEN(aData))+" Reg"


   oCol:=oDocPRti:oBrw:aCols[4]
   oCol:cHeader      :="Nombre "+oDp:xDPPROVEEDOR
   oCol:nWidth       :=250

   oCol:=oDocPRti:oBrw:aCols[5]
   oCol:cHeader      :="Fecha"+CRLF+"Decl."
   oCol:nWidth       :=70

   oCol:=oDocPRti:oBrw:aCols[6]
   oCol:cHeader      :="Estado"
   oCol:nWidth       :=70

   oCol:=oDocPRti:oBrw:aCols[7]   
   oCol:cHeader      :="Monto"+CRLF+"Neto"
   oCol:nWidth       :=105
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oDocPRti:oBrw:aArrayData[oDocPRti:oBrw:nArrayAt,7],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[7],"999,999,999,999.99")


   oCol:=oDocPRti:oBrw:aCols[8]   
   oCol:cHeader      :="Monto"+CRLF+"IVA"
   oCol:nWidth       :=95
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oDocPRti:oBrw:aArrayData[oDocPRti:oBrw:nArrayAt,8],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[8],"999,999,999,999.99")


   oCol:=oDocPRti:oBrw:aCols[9]   
   oCol:cHeader      :="%"+CRLF+"Ret"
   oCol:nWidth       :=25
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oDocPRti:oBrw:aArrayData[oDocPRti:oBrw:nArrayAt,9],;
                                TRAN(nMonto,"9999")}

   oCol:=oDocPRti:oBrw:aCols[10]   
   oCol:cHeader      :="Monto"+CRLF+"Retención"+CRLF+"Calculado"
   oCol:nWidth       :=135
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:nHeadStrAlign:= AL_RIGHT
   oCol:nFootStrAlign:= AL_RIGHT
   oCol:bStrData     :={|nMonto|nMonto:=oDocPRti:oBrw:aArrayData[oDocPRti:oBrw:nArrayAt,10],;
                                TRAN(nMonto,"999,999,999,999.99")}
   oCol:cFooter      :=TRAN( aTotal[10],"999,999,999,999.99")


   oDocPRti:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oDocPRti:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                           oDocPRti:nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0, oDocPRti:nClrPane1, oDocPRti:nClrPane2 ) } }

   oDocPRti:oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oDocPRti:oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oDocPRti:oBrw:bLDblClick:={|oBrw|oDocPRti:oRep:=oDocPRti:VERPROVEEDOR() }

   oDocPRti:oBrw:CreateFromCode()
    oDocPRti:bValid   :={|| EJECUTAR("BRWSAVEPAR",oDocPRti)}
    oDocPRti:BRWRESTOREPAR()

   oDocPRti:oWnd:oClient := oDocPRti:oBrw

   oDocPRti:Activate({||oDocPRti:ViewDatBar(oDocPRti)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oDocPRti)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oDocPRti:oDlg,oBtnCal

   oDocPRti:oBrw:GoBottom(.T.)
   oDocPRti:oBrw:Refresh(.T.)

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -12 BOLD

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\RETIVA.BMP",NIL,"BITMAPS\RETIVAG.BMP";
          ACTION oDocPRti:oRep:=oDocPRti:HACERRTI();
          WHEN !Empty(oDocPRti:oBrw:aArrayData[1,1])
               
   oBtn:cToolTip:="Hacer Retención "


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\PROVEEDORES.BMP",NIL,"BITMAPS\PROVEEDORESG.BMP";
          ACTION oDocPRti:oRep:=oDocPRti:VERPROVEEDOR();
          WHEN !Empty(oDocPRti:oBrw:aArrayData[1,1])
               
   oBtn:cToolTip:="Ver "+oDp:DPCLIENTES

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oDocPRti:oBrw,oDocPRti:cTitle,oDocPRti:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oDocPRti:Close()

  oDocPRti:oBrw:SetColor(0,oDocPRti:nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})


  //
  // Campo : Periodo
  //

  @ 1.0, (084-30.0+5)+8 COMBOBOX oDocPRti:oPeriodo  VAR oDocPRti:cPeriodo ITEMS aPeriodos;
               SIZE 100,NIL;
               OF oBar;
               FONT oFont;
               ON CHANGE oDocPRti:LEEFECHAS()

  @ oDocPRti:oPeriodo:nTop,080 SAY "Periodo:" OF oBar BORDER SIZE 34,24

  ComboIni(oDocPRti:oPeriodo )

  @ 0.75, (126-36+6)+10 BUTTON oDocPRti:oBtn PROMPT " < " SIZE 27,24;
                 FONT oFont;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDocPRti:oPeriodo:nAt,oDocPRti:oDesde,oDocPRti:oHasta,-1),;
                         EVAL(oDocPRti:oBtn:bAction))



  @ 0.75, (126-31.5+6)+10 BUTTON oDocPRti:oBtn PROMPT " > " SIZE 27,24;
                 FONT oFont;
                 OF oBar;
                 ACTION (EJECUTAR("PERIODOMAS",oDocPRti:oPeriodo:nAt,oDocPRti:oDesde,oDocPRti:oHasta,+1),;
                         EVAL(oDocPRti:oBtn:bAction))


  @ 1.15, (078-3+6)+8 BMPGET oDocPRti:oDesde  VAR oDocPRti:dDesde;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDocPRti:oDesde ,oDocPRti:dDesde);
                SIZE 76,24;
                OF   oBar;
                WHEN oDocPRti:oPeriodo:nAt=LEN(oDocPRti:oPeriodo:aItems);
                FONT oFont

   oDocPRti:oDesde:cToolTip:="F6: Calendario"

  @ 1.15, (088-3+6)+08 BMPGET oDocPRti:oHasta  VAR oDocPRti:dHasta;
                PICTURE "99/99/9999";
                NAME "BITMAPS\Calendar.bmp";
                ACTION LbxDate(oDocPRti:oHasta,oDocPRti:dHasta);
                SIZE 80,23;
                WHEN oDocPRti:oPeriodo:nAt=LEN(oDocPRti:oPeriodo:aItems);
                OF oBar;
                FONT oFont

   oDocPRti:oHasta:cToolTip:="F6: Calendario"

   @ 0.75, (126+10)+10 BUTTON oDocPRti:oBtn PROMPT " > " SIZE 27,24;
               FONT oFont;
               OF oBar;
               WHEN oDocPRti:oPeriodo:nAt=LEN(oDocPRti:oPeriodo:aItems);
               ACTION oDocPRti:LEERDOCPRO(GetWhereAnd("DOC_FCHDEC",oDocPRti:dDesde,oDocPRti:dHasta),oDocPRti:oBrw)


   oDocPRti:oDesde:ForWhen(.T.)
   oDocPRti:oBtn:Refresh(.T.)

   oDocPRti:oBar:=oBar
   oBtnCal:bWhen:={|| !Empty(oDocPRti:oBrw:aArrayData[1,1]) .AND. ;
                      !(oDocPRti:oPeriodo:nAt=LEN(oDocPRti:oPeriodo:aItems)) }


RETURN .T.

/*
// Imprimir
*/
FUNCTION IMPRIMIR(cCodInv)
  LOCAL oRep

  oRep:=REPORTE("INVCOSULT")
  oRep:SetRango(1,oDocPRti:cCodInv,oDocPRti:cCodInv)

RETURN .T.

FUNCTION LEEFECHAS()
  LOCAL nPeriodo:=oDocPRti:oPeriodo:nAt,cWhere

  oDocPRti:nPeriodo:=nPeriodo

  IF oDocPRti:oPeriodo:nAt=LEN(oDocPRti:oPeriodo:aItems)

     oDocPRti:oDesde:ForWhen(.T.)
     oDocPRti:oHasta:ForWhen(.T.)
     oDocPRti:oBtn  :ForWhen(.T.)

     DPFOCUS(oDocPRti:oDesde)

  ELSE

     oDocPRti:aFechas:=EJECUTAR("DPDIARIOGET",nPeriodo)

     oDocPRti:oDesde:VarPut(oDocPRti:aFechas[1] , .T. )
     oDocPRti:oHasta:VarPut(oDocPRti:aFechas[2] , .T. )

     oDocPRti:dDesde:=oDocPRti:aFechas[1]
     oDocPRti:dHasta:=oDocPRti:aFechas[2]

     cWhere:=GETWHEREAND("DOC_FCHDEC",oDocPRti:aFechas[1],oDocPRti:aFechas[2])

     oDocPRti:LEERDOCPRO(cWhere,oDocPRti:oBrw)

  ENDIF

RETURN .T.

FUNCTION LEERDOCPRO(cWhere,oBrw)
   LOCAL aData:={},aTotal:={}
   LOCAL cSql,cCodSuc:=oDp:cSucursal

   cSql:=" SELECT DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO,PRO_NOMBRE,DOC_FCHDEC,DOC_ESTADO,DOC_BASNET,DOC_MTOIVA,PRO_RETIVA,0 AS MTORTI "+;
         " FROM DPDOCPRO "+;
         " INNER JOIN DPTIPDOCPRO ON DOC_TIPDOC=TDC_TIPO AND TDC_RETIVA=1"+;
         " LEFT JOIN DPDOCPRORTI ON RTI_CODSUC=DOC_CODSUC "+;
         "     AND RTI_TIPDOC=DOC_TIPDOC "+;
         "     AND RTI_CODIGO=DOC_CODIGO "+;
         "     AND RTI_NUMERO=DOC_NUMERO "+;
         "     AND RTI_TIPTRA=DOC_TIPTRA "+;
         " LEFT JOIN DPPROVEEDOR ON PRO_CODIGO=DOC_CODIGO "+;
         " WHERE DOC_CODSUC"+GetWhere("=",oDp:cSucursal)+;
         "   AND RTI_NUMERO IS NULL AND DOC_MTOIVA>0  "+;
         "   AND DOC_TIPTRA"+GetWhere("=","D")+;
         " "+IIF( Empty(cWhere),""," AND ")+cWhere

   aData:=ASQL(cSql)

   IF EMPTY(aData)
      aData:=EJECUTAR("SQLARRAYEMPTY",cSql,oDb)
   ENDIF

   AEVAL(aData,{|a,n| aData[n,06]:=SAYOPTIONS("DPDOCPRO","DOC_ESTADO",a[6]),;
                      aData[n,10]:=PORCEN(a[8],a[9]) })

   IF ValType(oBrw)="O"
      aTotal:=ATOTALES(aData)

      oBrw:aArrayData:=ACLONE(aData)
      oBrw:nArrayAt  :=1
      oBrw:nRowSel   :=1

      oBrw:aCols[04]:cFooter      :=LSTR(LEN(aData))+" Reg"
      oBrw:aCols[07]:cFooter     :=TRAN( aTotal[07],"999,999,999,999.99")
      oBrw:aCols[08]:cFooter     :=TRAN( aTotal[08],"999,999,999,999.99")
      oBrw:aCols[10]:cFooter     :=TRAN( aTotal[10],"999,999,999,999.99")

      oBrw:Refresh(.T.)
      AEVAL(oDocPRti:oBar:aControls,{|o,n| o:ForWhen(.T.)})
   ENDIF

RETURN aData

FUNCTION HACERRTI()
    LOCAL aLine:=oDocPRti:oBrw:aArrayData[oDocPRti:oBrw:nArrayAt]
    LOCAL cTipDoc:=aLine[1]
    LOCAL cCodigo:=aLine[2]
    LOCAL cNumero:=aLine[3]

    EJECUTAR("DPDOCPRORTISAV",oDp:cSucursal,cTipDoc,cCodigo,cNumero,NIL,ISTABMOD("DPDOCPRORTI"),NIL,NIL,NIL,.F.,.T.,"oDocPRti:RTIRELOAD()")

RETURN NIL

FUNCTION RTIRELOAD()

   CursorWait()
   EVAL(oDocPRti:oBtn:bAction)

RETURN NIL



 FUNCTION BRWRESTOREPAR()
 RETURN EJECUTAR("BRWRESTOREPAR",oDocPRti)
// EOF
