// Programa   : DPDOCPROVIEW
// Fecha/Hora : 19/09/2005 13:45:04
// Propósito  : Visualizar Documentos del Proveedor
// Creado Por : Juan Navas
// Llamado por: DPPROVEEDOR (Consulta)
// Aplicación : Compras
// Tabla      : DPDOCPRO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodPro,cAno,dDesde,dHasta,cTipDoc,cTipTra,lCxP,cCodSuc,cTitle,lPendiente)
  LOCAL oTable,aLine
  LOCAL aMes:={"ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"}
  LOCAL cSql,cWhere,nAt,nSaldo:=0,nSaldoAnt:=0
  LOCAL lSelect,dFecha,nMonto

  IF Type("oAutPag")="O" .AND. oAutPag:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oAutPag,GetScript())
  ENDIF

  DEFAULT cAno      :=STRZERO(YEAR(oDp:dFecha),4),cTitle:="Documentos por Pagar",;
          cCodSuc   :=oDp:cSucursal,;
          lPendiente:=.F.

  DEFAULT cCodPro:=SQLGET("DPDOCPRO","DOC_CODIGO","DOC_CXP<>0 LIMIT 1")

// ? lPendiente,VALTYPE(lPendiente)
// ? cCodPro,cAno,dDesde,dHasta,cTipDoc,cTipTra,lCxP,cCodSuc,cTitle,lPendiente,"cCodPro,cAno,dDesde,dHasta,cTipDoc,cTipTra,lCxP,cCodSuc,cTitle,lPendiente"

  EJECUTAR("DPPRIGENLEE")

  cAno:=IIF( ValType(cAno)="C" , cAno , STRZERO(cAno,4) )

// EJECUTAR("DPPRIGENLEE")
// ? cCodPro,cAno,dDesde,dHasta,cTipDoc,cTipTra,lCxP,cCodSuc,cTitle

  IF ValType(dDesde)="C"

     nAt:=ASCAN(aMes,{|a,n|a=UPPE(LEFT(dDesde,3))})

     IF nAt>0
      
       // ? ValType(nAt),ValTycAno
       dDesde:=CTOD("01/"+STRZERO(nAt,2)+"/"+cAno)
       dHasta:=FCHFINMES(dDesde)

       cTitle:=cTitle +" ["+DTOC(dDesde)+" "+DTOC(dHasta)+"]"

     ENDIF

     IF nAt=0 .AND. VAL(cAno)>0

       dDesde:=CTOD("01/01/"+cAno)
       dHasta:=CTOD("31/12/"+cAno)

     ENDIF

     IF ValType(dDesde)="C" .AND. dDesde="TOTAL"
        dDesde:=CTOD("")
        dHasta:=CTOD("")
     ENDIF

  ENDIF

//? cAno,"cAno",dDesde,dHasta

  DEFAULT cCodPro:=SQLGET("DPDOCPRO","DOC_CODIGO","DOC_TIPDOC"+GetWhere("=","FAC")+" AND DOC_CXP=1 AND DOC_ACT=1"),;
          lCxP   :=.T.,;
          dHasta:=dDesde

  cWhere:="DOC_CODSUC"+GetWhere("=" ,cCodSuc)+" AND "+;
          "DOC_CODIGO"+GetWhere("=" ,cCodPro)
        
  IF !Empty(cTipDoc)
     cWhere:=cWhere+" AND DOC_TIPDOC"+GetWhere("=",cTipDoc)
  ENDIF

  IF lCxP
     cWhere:=cWhere+" AND DOC_CXP<>0 "
  ENDIF

  IF !EMPTY(dDesde)

     nSaldoAnt:=SQLGET("DPDOCPRO","SUM(DOC_NETO*DOC_CXP)",cWhere+" AND DOC_ACT=1 AND DOC_FECHA"+GetWhere("<",dDesde))

  ENDIF


  IF !Empty(dDesde)

     cWhere:=cWhere+" AND ("+;
            "DOC_FECHA" +GetWhere(">=",dDesde )+" AND "+;
            "DOC_FECHA" +GetWhere("<=",dHasta )+")"
           

  ENDIF

  cSql:=" SELECT DOC_TIPDOC,TDC_DESCRI,DOC_NUMERO,DOC_FECHA,IF(DOC_CXP=1,DOC_NETO,0) AS DEBE,"+;
        " IF(DOC_CXP<0,DOC_NETO,0) AS HABER,0 AS SALDO,DOC_TIPTRA "+;
        " FROM DPDOCPRO "+;
        " LEFT JOIN DPTIPDOCPRO ON DOC_TIPDOC=TDC_TIPO "+;
        IIF(lPendiente," INNER JOIN VIEW_DOCPROCXPDIV ON DOC_CODSUC=CXD_CODSUC AND DOC_TIPDOC=CXD_TIPDOC AND DOC_CODIGO=CXD_CODIGO AND DOC_NUMERO=CXD_NUMERO ","")+;
        " WHERE  "+cWhere+" AND DOC_ACT=1 "+;
        " ORDER BY DOC_FECHA,DOC_HORA,DOC_TIPTRA "

  oTable:=OpenTable(cSql,.T.)

  IF oTable:RecCount()=0
     oTable:AddRecord(.T.)
  ENDIF

  oTable:Replace("SALDO",nSaldoAnt)

  IF nSaldoAnt<>0

     aLine:=ACLONE(oTable:aDataFill[1])
     AEVAL(aLine,{|a,n|aLine[n]:=CTOEMPTY(a)})
     aLine[3]:="ANTERIOR"
     aLine[4]:=dDesde-1
     aLine[7]:=0 // nSaldoAnt
     AADD(oTable:aDataFill,NIL)
     AINS(oTable:aDataFill,1)
     oTable:aDataFill[1]:=ACLONE(aLine)
     oTable:Gotop()
     oTable:Replace("SALDO",0)
     oTable:Replace("DEBE" ,0)
     oTable:Replace("HABER",0)

  ENDIF

  oTable:Gotop()
  nSaldo:=nSaldoAnt

  oTable:Replace("DOC_AUTORI",.F.     )
  oTable:Replace("DOC_FCHAUT",CTOD(""))
  oTable:Replace("DOC_MONTO" ,0       )

  WHILE !oTable:Eof()

    nSaldo:=nSaldo+oTable:DEBE-oTable:HABER

    oTable:Replace("DOC_AUTORI",.F.     )
    oTable:Replace("DOC_TIPTRA",IIF(oTable:DOC_TIPTRA="D","Doc",oTable:DOC_TIPTRA))
    oTable:Replace("DOC_TIPTRA",IIF(oTable:DOC_TIPTRA="P","Pag",oTable:DOC_TIPTRA))
    oTable:Replace("SALDO",nSaldo)

    cWhere:="AUP_CODSUC"+GetWhere("=",oDp:cSucursal    )+" AND "+;
            "AUP_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
            "AUP_CODPRO"+GetWhere("=",cCodPro          )+" AND "+;
            "AUP_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)

    lSelect:=SQLGET("DPDOCPROAUT","AUP_ACTIVO,AUP_FECHA,AUP_MONTO",cWhere)

    dFecha:=CTOD("")
    nMonto:=0
  
    IF !Empty(oDp:aRow)
      dFecha:=oDp:aRow[2]
      nMonto:=oDp:aRow[3]
    ENDIF

    oTable:Replace("DOC_AUTORI",lSelect)
    oTable:Replace("DOC_FCHAUT",dFecha )
    oTable:Replace("DOC_MONTO" ,nMonto )

    oTable:DbSkip()

  ENDDO

  oTable:End()

// ViewArray(oTable:aDataFill)

  IF Empty(oTable:aDataFill)
     RETURN .F.
  ENDIF

  ViewData(oTable:aDataFill,cCodPro,cTitle)

RETURN .T.
 
FUNCTION ViewData(aData,cCodPro,cTitle)
   LOCAL oBrw,oCol
   LOCAL I,nMonto:=0
   LOCAL cSql,oTable,cNombre:=""
   LOCAL oFont,oFontB
   LOCAL nDebe:=0,nHaber:=0,aTotal:=ATOTALES(aData)
   LOCAL aCoors:=GetCoors( GetDesktopWindow() )

   cNombre:=SQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",cCodPro))

   AEVAL(aData,{|a|nDebe:=nDebe+a[5],nHaber:=nHaber+a[6]})

   DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12 
   DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD

//  oAutPag:=DPEDIT():New(cTitle+", [Autorización de Pagos] ","DPDOCPROVIEWDET.EDT","oAutPag",.T.)

   DpMdi(cTitle+", [Autorización de Pagos] ","oAutPag","BRREIDET.EDT")
   oAutPag:Windows(0,0,aCoors[3]-160,MIN(aCoors[4]-10,980),.T.) // Maximizado


   oAutPag:cCodPro:=cCodPro
   oAutPag:cNombre:=cNombre
   oAutPag:dDesde :=dDesde
   oAutPag:dHasta :=dHasta
   oAutPag:lMsgBar:=.F.

   oAutPag:nClrPane1:=16773087
   oAutPag:nClrPane2:=16767411
   oAutPag:nClrText :=0

   oAutPag:oBrw:=TXBrowse():New( oAutPag:oDlg )
   oAutPag:oBrw:SetArray( aData, .F. )
   oAutPag:oBrw:SetFont(oFont)
   oAutPag:oBrw:lFooter := .T.
   oAutPag:oBrw:lHScroll:= .F.
   oAutPag:oBrw:nHeaderLines:= 2

   oAutPag:cCodTra  :=cCodPro
   oAutPag:cNombre  :=cNombre

   AEVAL(oAutPag:oBrw:aCols,{|oCol|oCol:oHeaderFont:=oFontB})

   oAutPag:oBrw:aCols[1]:cHeader      :="Tipo"
   oAutPag:oBrw:aCols[1]:nWidth       :=030

   oAutPag:oBrw:aCols[2]:cHeader      :="Tran"+CRLF+"Descripción"
   oAutPag:oBrw:aCols[2]:nWidth       :=032+140

   oAutPag:oBrw:aCols[3]:cHeader      :="Número"
   oAutPag:oBrw:aCols[3]:nWidth       :=080

   oAutPag:oBrw:aCols[4]:cHeader      :="Fecha"
   oAutPag:oBrw:aCols[4]:nWidth       :=70+2

   oAutPag:oBrw:aCols[5]:cHeader      :="Debe"
   oAutPag:oBrw:aCols[5]:nWidth       :=150
   oAutPag:oBrw:aCols[5]:nDataStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[5]:nHeadStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[5]:nFootStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[5]:bStrData     :={|nMonto|nMonto:=oAutPag:oBrw:aArrayData[oAutPag:oBrw:nArrayAt,5],;
                                                 IF(nMonto<=0,"",TRAN(nMonto,"999,999,999,999,999.99"))}


   oAutPag:oBrw:aCols[5]:cFooter      :=TRAN(nDebe,"9,999,999,999,999.99")
   oAutPag:oBrw:aCols[5]:bClrStd      := {|oBrw,nClrText|oBrw:=oAutPag:oBrw,;
                                           nClrText:=CLR_HBLUE,;
                                         {nClrText,iif( oBrw:nArrayAt%2=0,  oAutPag:nClrPane1,  oAutPag :nClrPane2 ) } }

   oAutPag:oBrw:aCols[6]:cHeader      :="Haber"
   oAutPag:oBrw:aCols[6]:nWidth       :=150
   oAutPag:oBrw:aCols[6]:nDataStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[6]:nHeadStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[6]:nFootStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[6]:bStrData     :={|nMonto|nMonto:=oAutPag:oBrw:aArrayData[oAutPag:oBrw:nArrayAt,6],;
                                                 IF(nMonto<=0,"",TRAN(nMonto,"999,999,999,999,999.99"))}

   oAutPag:oBrw:aCols[6]:cFooter      :=TRAN(nHaber,"999,999,999,999,999,999.99")
   oAutPag:oBrw:aCols[6]:bClrStd      := {|oBrw,nClrText|oBrw:=oAutPag:oBrw,;
                                           nClrText:=CLR_HRED,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0,   oAutPag :nClrPane1,  oAutPag :nClrPane2 ) } }


   oAutPag:oBrw:aCols[7]:cHeader      :="Saldo"
   oAutPag:oBrw:aCols[7]:nWidth       :=150
   oAutPag:oBrw:aCols[7]:nDataStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[7]:nHeadStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[7]:nFootStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[7]:bStrData     :={|oBrw|oBrw:=oAutPag:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,7],"99,999,999,999,999.99")}
   oAutPag:oBrw:aCols[7]:cFooter      :=TRAN(nSaldo,"9,999,999,999,999,999.99")


   oAutPag:oBrw:aCols[8]:cHeader      :="Tipo"+CRLF+"Trans."
   oAutPag:oBrw:aCols[8]:nWidth       :=70+2


   oCol:=oAutPag:oBrw:aCols[9]
   oCol:cHeader      := "Auto-"+CRLF+"rizado"
   oCol:nWidth       := 25
   oCol:AddBmpFile("BITMAPS\checkverde.bmp")
   oCol:AddBmpFile("BITMAPS\checkrojo.bmp")
   oCol:bBmpData    := { |oBrw|IIF(oAutPag:oBrw:aArrayData[oAutPag:oBrw:nArrayAt,9],1,2) }
   oCol:nDataStyle  := oCol:DefStyle( AL_LEFT, .F.)
   oCol:bStrData    :={||""}

   IF oDp:P_LAutRegPag

     oCol:bLDClickData:={||oAutPag:PrgSelect(oAutPag)}
     oCol:bLClickHeader:={|nRow,nCol,nKey,oCol|oAutPag:ChangeAllImp(oAutPag,nRow,nCol,nKey,oCol,.T.)}

   ENDIF

   oAutPag:oBrw:aCols[10]:cHeader      :="Fecha"+CRLF+"Pago"
   oAutPag:oBrw:aCols[10]:cPictEdit    :="99/99/9999"
   oAutPag:oBrw:aCols[10]:nEditType    :=1
   oAutPag:oBrw:aCols[10]:nWidth       :=80

   IF oDp:P_LAutRegPag
     oAutPag:oBrw:aCols[10]:bOnPostEdit  :={|oCol,uValue|oAutPag:VALFECHAAUT(oCol,uValue)}
   ENDIF

   oAutPag:oBrw:aCols[11]:cHeader      :="Monto"+CRLF+"Autorizado"
   oAutPag:oBrw:aCols[11]:cPictEdit    :="99,999,999,999.99"
   oAutPag:oBrw:aCols[11]:nEditType    :=1
   oAutPag:oBrw:aCols[11]:nWidth       :=120
   oAutPag:oBrw:aCols[11]:nDataStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[11]:nHeadStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[11]:nFootStrAlign:= AL_RIGHT
   oAutPag:oBrw:aCols[11]:bStrData     :={|oBrw|oBrw:=oAutPag:oBrw,TRAN(oBrw:aArrayData[oBrw:nArrayAt,11],"999,999,999,999,999.99")}
   oAutPag:oBrw:aCols[11]:cFooter      :=TRAN(aTotal[11],"999,999,999,999,999.99")

   IF oDp:P_LAutRegPag
     oAutPag:oBrw:aCols[11]:bOnPostEdit  :={|oCol,uValue|oAutPag:VALMONTO(oCol,uValue)}
   ENDIF



   oAutPag:oBrw:bClrStd               := {|oBrw,nClrText,aData|oBrw:=oAutPag:oBrw,aData:=oBrw:aArrayData[oBrw:nArrayAt],;
                                            oAutPag :nClrText,;
                                          {nClrText,iif( oBrw:nArrayAt%2=0,  oAutPag :nClrPane1,  oAutPag :nClrPane2 ) } }


//   oAutPag:oBrw:bClrHeader            := {|| {0,16769476 }}
//   oAutPag:oBrw:bClrFooter            := {|| {0,16769476 }}

   oAutPag:oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oAutPag:oBrw:CreateFromCode()

   oAutPag:bValid   :={|| EJECUTAR("BRWSAVEPAR", oAutPag )}
   oAutPag:BRWRESTOREPAR()

   oAutPag:oWnd:oClient := oAutPag:oBrw


   oAutPag:Activate({||oAutPag:ViewDatBar(oAutPag)})

RETURN .T.

/*
// Barra de Botones
*/
FUNCTION ViewDatBar(oAutPag)
   LOCAL oCursor,oBar,oBtn,oFont,oCol,nDif
   LOCAL nWidth :=0 // Ancho Calculado seg£n Columnas
   LOCAL nHeight:=0 // Alto
   LOCAL nLines :=0 // Lineas
   LOCAL oDlg:=oAutPag:oDlg

   DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -12 BOLD

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FORM.BMP";
          ACTION oAutPag:VERDOCPRO()

   oBtn:cToolTip:="Ver Formulario"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XPRINT.BMP";
          ACTION (oDp:oRep:=REPORTE("EDOCTAPRO"),;
                  oDp:oRep:SetRango(1,oAutPag:cCodPro,oAutPag:cCodPro),;
                  oDp:oRep:SetRango(2,oAutPag:dDesde ,oAutPag:dHasta ))

   oBtn:cToolTip:="Imprimir Estado de Cuenta"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\FILTRAR.BMP";
          MENU EJECUTAR("BRBTNMENUFILTER",oAutPag:oBrw,oAutPag);
          ACTION EJECUTAR("BRWSETFILTER",oAutPag:oBrw)

   oBtn:cToolTip:="Filtrar Registros"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\OPTIONS.BMP",NIL,"BITMAPS\OPTIONSG.BMP";
          ACTION EJECUTAR("BRWSETOPTIONS",oAutPag:oBrw);
          WHEN LEN(oAutPag:oBrw:aArrayData)>1

   oBtn:cToolTip:="Filtrar según Valores Comunes"


   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\html.BMP";
          ACTION (oAutPag:HTMLHEAD(),EJECUTAR("BRWTOHTML",oAutPag:oBrw,NIL,oAutPag:cTitle,oAutPag:aHead))

   oBtn:cToolTip:="Generar Archivo html"

   oAutPag:oBtnHtml:=oBtn




   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\EXCEL.BMP";
          ACTION (EJECUTAR("BRWTOEXCEL",oAutPag:oBrw,oAutPag:cTitle,oAutPag:cNombre))

   oBtn:cToolTip:="Exportar hacia Excel"

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xTOP.BMP";
          ACTION (oAutPag:oBrw:GoTop(),oAutPag:oBrw:Setfocus())
/*
   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xSIG.BMP";
          ACTION (oAutPag:oBrw:PageDown(),oAutPag:oBrw:Setfocus())

  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xANT.BMP";
          ACTION (oAutPag:oBrw:PageUp(),oAutPag:oBrw:Setfocus())
*/	
  DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\xFIN.BMP";
          ACTION (oAutPag:oBrw:GoBottom(),oAutPag:oBrw:Setfocus())

   DEFINE BUTTON oBtn;
          OF oBar;
          NOBORDER;
          FONT oFont;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION oAutPag:Close()

  oAutPag:oBrw:SetColor(0, oAutPag :nClrPane1)

  oBar:SetColor(CLR_BLACK,oDp:nGris)
  AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  @ 0.1,50+8+8  SAY " "+oAutPag:cCodPro OF oBar BORDER SIZE 120,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
  @ 1.4,50+8+8  SAY " "+oAutPag:cNombre OF oBar BORDER SIZE 365,18 COLOR oDp:nClrYellowText,oDp:nClrYellow FONT oFont
  @ 0.1,115+8 SAY " Usuario "+IF(oDp:P_LAutRegPag,"SI","NO")+" Autorizado "  OF oBar BORDER SIZE 200,18 FONT oFont;
    COLOR oDp:nClrLabelText,oDp:nClrLabelPane


RETURN .T.

/*
// Seleccionar Concepto
*/
FUNCTION PrgSelect(oAutPag,lRefresh)
  LOCAL oBrw:=oAutPag:oBrw,dFecha,aTotal:={}
  LOCAL nArrayAt,nRowSel,nAt:=0,nCuantos:=0
  LOCAL lSelect
  LOCAL nCol:=8
  LOCAL lSelect
  LOCAL cWhere

  DEFAULT lRefresh:=.T.

  IF !DPVERSION()>4.0
     EJECUTAR("DPREQVERSION",4.1)
  ENDIF

  IF ValType(oBrw)!="O"
     RETURN .F.
  ENDIF

  nArrayAt:=oBrw:nArrayAt
  nRowSel :=oBrw:nRowSel
  lSelect :=oBrw:aArrayData[nArrayAt,nCol]

  oBrw:aArrayData[oBrw:nArrayAt,nCol]:=!lSelect

  IF oBrw:aArrayData[oBrw:nArrayAt,nCol]

     dFecha:=SQLGET("DPDOCPRO","DOC_FCHVEN","DOC_CODSUC"+GetWhere("=",oDp:cSucursal  )+" AND "+;
                                            "DOC_TIPDOC"+GetWhere("=",oBrw:aArrayData[oBrw:nArrayAt,1])+" AND "+;
                                            "DOC_CODIGO"+GetWhere("=",oAutPag:cCodPro)+" AND "+;
                                            "DOC_NUMERO"+GetWhere("=",oBrw:aArrayData[oBrw:nArrayAt,3]))

     oBrw:aArrayData[oBrw:nArrayAt,10]:=oAutPag:oBrw:aArrayData[oAutPag:oBrw:nArrayAt,5]

     IF Empty(oBrw:aArrayData[oBrw:nArrayAt,10])
       oBrw:aArrayData[oBrw:nArrayAt,10]:=oAutPag:oBrw:aArrayData[oAutPag:oBrw:nArrayAt,6]*-1
     ENDIF

     oBrw:aArrayData[oBrw:nArrayAt,09]:=dFecha

  ELSE

     oBrw:aArrayData[oBrw:nArrayAt,10]:=0
     oBrw:aArrayData[oBrw:nArrayAt,09]:=CTOD("")

  ENDIF

  oAutPag:SAVEREGPAGO()

  IF lRefresh

    oBrw:RefreshCurrent()

    aTotal:=ATOTALES(oBrw:aArrayData)

    oAutPag:oBrw:aCols[10]:cFooter      :=TRAN(aTotal[10],"99,999,999,999.99")

    oBrw:Refresh(.F.)

  ENDIF

/*
  // Busca en la Lista General)
  nAt:=ASCAN(oAutPag:aTodos,{|a,n|a[1]=oBrw:aArrayData[oBrw:nArrayAt,1]})

  IF nAt>0
    oAutPag:aTodos[nAt,nCol]:=!lSelect
  ENDIF
*/

//  AEVAL(oAutPag:aTodos,{|a,n|nCuantos:=nCuantos+IIF(a[3],1,0)})
//  oAutPag:nCuantos:=nCuantos
//  oAutPag:oCuantos:Refresh(.T.)

RETURN .T.

/*
// Selecciona o Desmarca a Todos
*/
FUNCTION ChangeAllImp(oFrmSelTab)
   LOCAL oBrw:=oFrmSelTab:oBrw,I
   LOCAL lSelect:=!oBrw:aArrayData[1,3],aTotal:={}

   IF !DPVERSION()>4.0
     EJECUTAR("DPREQVERSION",4.1)
   ENDIF

   AEVAL(oBrw:aArrayData,{|a,n|oBrw:nArrayAt:=n,oAutPag:PrgSelect(oAutPag,.F.)})

   aTotal:=ATOTALES(oBrw:aArrayData)
/*

   FOR I=1 TO LEN(oFrmSelPrg:aTodos)
     IF  LEFT(oFrmSelTab:cModulo,2)=oFrmSelPrg:aTodos[I,5] .OR. oFrmSelTab:cModulo="00"
       oFrmSelPrg:aTodos[I,3]:=lSelect
     ENDIF
   NEXT I

   IF LEFT(oFrmSelTab:cModulo,2)="00"
      AEVAL(oFrmSelTab:aTodos,{|a,n|oFrmSelTab:aTodos[n,3]:=lSelect})
   ENDIF

   oFrmSelTab:nCuantos:=IIF(lSelect,LEN(oBrw:aArrayData),0)
   oFrmSelTab:oCuantos:Refresh(.T.)
*/

   oAutPag:oBrw:aCols[10]:cFooter      :=TRAN(aTotal[10],"99,999,999,999.99")

   oBrw:Refresh(.T.)


RETURN .T.

FUNCTION SAVEREGPAGO()
     LOCAL oBrw:=oAutPag:oBrw,oTable,cItem:=STRZERO(1,5)

     LOCAL cWhere:="AUP_CODSUC"+GetWhere("=",oDp:cSucursal  )+" AND "+;
                   "AUP_TIPDOC"+GetWhere("=",oBrw:aArrayData[oBrw:nArrayAt,1])+" AND "+;
                   "AUP_CODPRO"+GetWhere("=",oAutPag:cCodPro)+" AND "+;
                   "AUP_NUMERO"+GetWhere("=",oBrw:aArrayData[oBrw:nArrayAt,3])

/*
 C001=AUP_CODSUC,'C',008,0,'','Sucursal',0
 C002=AUP_TIPDOC,'C',003,0,'','Tipo de Documento',0
 C003=AUP_CODPRO,'C',010,0,'','Proveedor',1
 C004=AUP_NUMERO,'C',010,0,'','Numero Documento',0
 C005=AUP_FECHA ,'D',008,0,'','Fecha',0
 C006=AUP_MONTO ,'N',014,2,'','Monto',0
 C007=AUP_ITEM  ,'C',005,0,'','Item',0
 C008=AUP_APLICA,'L',001,0,'','Aplicado',0
*/


    oTable:=OpenTable("SELECT * FROM DPDOCPROAUT WHERE "+cWhere,.T.)

    IF oTable:RecCount()=0
       cWhere:=""
       oTable:AppendBlank()
    ENDIF

    oTable:Replace("AUP_CODSUC",oDp:cSucursal  )
    oTable:Replace("AUP_TIPDOC",oBrw:aArrayData[oBrw:nArrayAt,01])
    oTable:Replace("AUP_CODPRO",oAutPag:cCodPro)
    oTable:Replace("AUP_NUMERO",oBrw:aArrayData[oBrw:nArrayAt,03])
    oTable:Replace("AUP_FECHA" ,oBrw:aArrayData[oBrw:nArrayAt,09])
    oTable:Replace("AUP_MONTO" ,oBrw:aArrayData[oBrw:nArrayAt,10])
    oTable:Replace("AUP_APLICA",.F.)
    oTable:Replace("AUP_ACTIVO",oBrw:aArrayData[oBrw:nArrayAt,08])
    oTable:Replace("AUP_ITEM"  ,cItem)

    oTable:Commit(cWhere)

    oTable:End()

RETURN NIL

FUNCTION VALMONTO(oCol,uValue)   
    LOCAL nMonto:=0
    LOCAL oBrw:=oAutPag:oBrw

    nMonto:=MAX(oBrw:aArrayData[oBrw:nArrayAt,5],oBrw:aArrayData[oBrw:nArrayAt,6])

    IF uValue>nMonto
        MensajeErr("Monto Autorizado no puede superar Monto del Documento")
        RETURN .F.
    ENDIF

    oBrw:aArrayData[oBrw:nArrayAt,10]:=uValue

    oAutPag:SAVEREGPAGO()
     
RETURN .T.

FUNCTION VALFECHAAUT(oCol,uValue)
    LOCAL oBrw:=oAutPag:oBrw

    IF uValue<oBrw:aArrayData[oBrw:nArrayAt,04]
       oBrw:aArrayData[oBrw:nArrayAt,09]:=oBrw:aArrayData[oBrw:nArrayAt,04]
       MensajeErr("Fecha no puede ser Menor a la Fecha de Emisión")
       RETURN .F.
    ENDIF

    oBrw:aArrayData[oBrw:nArrayAt,09]:=uValue

    oAutPag:SAVEREGPAGO()
  

RETURN .T.


FUNCTION HTMLHEAD()

   oAutPag:aHead:=EJECUTAR("HTMLHEAD",oAutPag)

RETURN

FUNCTION VERDOCPRO()
  LOCAL oBrw   :=oAutPag:oBrw
  LOCAL cNumero:=oBrw:aArrayData[oBrw:nArrayAt,03]
  LOCAL cTipDoc:=oBrw:aArrayData[oBrw:nArrayAt,01]
  LOCAL cTipTra:="D" 

  IF Empty(cNumero)
     RETURN .T.
  ENDIF

RETURN EJECUTAR("VERDOCPRO",oDp:cSucursal,cTipDoc,oAutPag:cCodPro,cNumero,cTipTra)


FUNCTION BRWRESTOREPAR()
RETURN EJECUTAR("BRWRESTOREPAR", oAutPag )
// EOF
