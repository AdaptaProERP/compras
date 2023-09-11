// Programa   : DPDOCPRORTIEDIT
// Fecha/Hora : 06/05/2012 02:54:26
// Propósito  : Edtar Retención de IVA
// Creado Por : Juan Navas
// Llamado por: DPDOCPRO
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero,cTipRti,lView,cRun)
   LOCAL nPorIva:=0,cRif,lOk:=.F.,nMtoRet:=0,dFecha,dFchDec,dFchDoc
   LOCAL cNumRti,cNumAAMM,cWhereRti,cWhereDoc
   LOCAL cNumTra,cNumAM,cAAMM,cNumMes,cMsg,nFilMai,cNumMrt:="",cNumMesM:=""
   LOCAL oDocRti,oDpDocPro,oCol,oBrw
   LOCAL cTitle:="Retención de IVA en Compras y CxP ",nSaldo,aData:={},nSaldo:=0,cDocOrg:=""
   LOCAL oFontB,oFont2,oFont3
   LOCAL cEstado:="Pendiente de Pago",cAAMM,cEstadoRti:="AC",cClaveDoc
   LOCAL cNumComp,cWhereDoc
   LOCAL oCursor,oBtn,oFontB

   DEFINE CURSOR oCursor HAND
   DEFINE FONT oFontB   NAME "Tahoma" SIZE 0, -12 BOLD 

   DEFAULT oDp:lAutoSeniat:=.F.

   IF Type("oFrmRti")="O" .AND. oFrmRti:oWnd:hWnd>0
      RETURN EJECUTAR("BRRUNNEW",oFrmRti,GetScript())
   ENDIF

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cTipDoc:="FAC"        ,;
           cCodigo:=SQLGET("DPDOCPRO","DOC_CODIGO","DOC_TIPDOC"+GetWhere("=","FAC")+" AND DOC_NETO>0"),;
           cNumero:=SQLGET("DPDOCPRO","DOC_NUMERO","DOC_TIPDOC"+GetWhere("=","FAC")+" AND DOC_NETO>0"),;
           cTipRti:=IF(cTipDoc="FAC","RTI","RVI"),;
           lView  :=.F.   

  cTitle:=ALLTRIM(SQLGET("DPTIPDOCPRO","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipRti)))

  oDpDocPro:=OpenTable("SELECT * FROM DPDOCPRO WHERE "+;
                       "DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                       "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                       "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                       "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                       "DOC_TIPTRA"+GetWhere("=","D"    ),.T.)

  cWhereDoc:=oDpDocPro:cWhere

  IF oDpDocPro:RecCount()=0

        MensajeErr("Documeto "+cTipDoc+" Codigo: "+cCodigo+" Número: "+cNumero+" no Existe")

        RETURN .F.

  ENDIF


  nSaldo:=SQLGET("DPDOCPRO","SUM(DOC_NETO*DOC_CXP)","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                    "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                                                    "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                                                    "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                                                    "DOC_ACT   "+GetWhere("=",1      ))


   // Tomamos los Datos del Documento

   dFchDoc:=oDpDocPro:DOC_FECHA

   cRif:=SQLGET("DPPROVEEDOR","PRO_RIF,PRO_FILMAI","PRO_CODIGO"+GetWhere("=",cCodigo))

   IF Empty(cRif)
      MensajeErr(oDp:xDPPROVEEDOR+" "+cCodigo+" no posee Rif "+cRif)
      RETURN .F.
   ENDIF
   
   nFilMai:=oDp:aRow[2]

   /*
   // Condición para Buscar el Documento
   */   


   cWhereRti:="RTI_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
              "RTI_DOCTIP"+GetWhere("=",cTipRti)+" AND "+;
              "RTI_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
              "RTI_NUMERO"+GetWhere("=",cNumero)

   oDocRti:=OpenTable("SELECT * FROM DPDOCPRORTI WHERE "+cWhereRti,.T.)
   oDocRti:End()
   cNumRti:=oDocRti:RTI_DOCNUM

   cWhereDoc:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",cTipRti)+" AND "+;
              "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",cNumRti)+" AND "+;
              "DOC_TIPTRA"+GetWhere("=","D"    )

   /*
   // Si la Retencion fue Declara no debe Permitir Ningun Cambio, Verifica en Registro de la Forma 30
   */


   cEstadoRti:=SQLGET("DPDOCPRO","DOC_ESTADO",cWhereDoc)
   cEstadoRti:=SAYOPTIONS("DPDOCPRO","DOC_ESTADO",cEstadoRti)

   cMsg     :=IIF(oDpDocPro:DOC_CXP=0,"Anulado",cEstado)

// 03/12/2020
// EJECUTAR("DPDOCCLIIMP",cCodSuc,cTipDoc,cCodigo,cNumero,.F.,oDpDocPro:DOC_DCTO,oDpDocPro:DOC_RECARG,oDpDocPro:DOC_OTROS,"C",cDocOrg)
// ? cDocOrg,"cDocOrg"

   EJECUTAR("DPDOCCLIIMP",cCodSuc,cTipDoc,cCodigo,cNumero,.F.,oDpDocPro:DOC_DCTO,oDpDocPro:DOC_RECARG,oDpDocPro:DOC_OTROS,"C")


   DEFINE FONT oFontB   NAME "Tahoma" SIZE 0, -12 BOLD
   DEFINE FONT oFont2   NAME "Tahoma" SIZE 0, -12 BOLD 
   DEFINE FONT oFont3   NAME "Tahoma" SIZE 0, -14 BOLD 


   oFrmRti:=DPEDIT():New(cTitle,"DPDOCPRORTI.EDT","oFrmRti",.T.)
   oFrmRti:CreateWindow()

   oFrmRti:SetTable(oDocRti,NIL)
   oFrmRti:oTable:cPrimary:="RTI_CODSUC,RTI_TIPDOC,RTI_CODIGO,RTI_NUMERO"
   oFrmRti:cNumTit   :=oFrmRti:cTitle

   oFrmRti:nOption  :=0
   oFrmRti:oPagos   :=NIL
   oFrmRti:nCxP     :=oDpDocPro:DOC_CXP
   oFrmRti:cRif     :=cRif
   oFrmRti:nMtoRti  :=SQLGET("DPDOCPRO","DOC_NETO",cWhereDoc)
   oFrmRti:cNombre  :=SQLGET("DPPROVEEDOR","PRO_NOMBRE,PRO_RETIVA","PRO_CODIGO"+GetWhere("=",cCodigo))
   oFrmRti:nPorcen  :=IF (Empty(oDp:aRow),oDp:aRow[2])
   oFrmRti:cWhereDoc:=cWhereDoc
   oFrmRti:cWhereRti:=cWhereRti
   oFrmRti:cNumRti  :=cNumRti
   oFrmRti:cCodigo  :=cCodigo
   oFrmRti:cNumero  :=cNumero
   oFrmRti:cTipDoc  :=cTipDoc
   oFrmRti:cTipRti  :=cTipRti
   oFrmRti:cCodSuc  :=cCodSuc
   oFrmRti:nFilMai  :=nFilMai
   oFrmRti:lNulo    :=ALLTRIM(UPPE(cEstadoRti))="NULO"
   oFrmRti:cClaveDoc:=cCodSuc+"-"+cTipDoc+"-"+cCodigo+"-"+cNumero
   oFrmRti:lView    :=lView
   oFrmRti:cNEWTRA  :="" // Nuevo Número de la retención
   oFrmRti:SetScript("DPDOCPRORTIEDIT")
   oFrmRti:cWhereDoc:=cWhereDoc

   cAAMM:=oDocRti:RTI_AAMM

   IF Empty(oDocRti:RTI_NUMTRA)
      oDocRti:RTI_NUMTRA:="No posee"
   ENDIF

   cNumComp:= GETNUMCOMP()

   AADD(aData,{"Estado:"           ,cEstado           })
   AADD(aData,{"RIF:"              ,oFrmRti:cRif      })
   AADD(aData,{"Documento "+oDpDocPro:DOC_TIPDOC+": ",oDpDocPro:DOC_NUMERO})
   AADD(aData,{"# Control Fiscal:" ,oDpDocPro:DOC_NUMFIS}) 
   AADD(aData,{"Fecha:"            ,oDpDocPro:DOC_FECHA })
   AADD(aData,{"Numero de Retención "+cTipRti,cNumComp}) 
   AADD(aData,{"Ret. Proveedor "+cCodigo,oDocRti:RTI_DOCNUM}) 
   AADD(aData,{"Retención Año/Mes ("+cAAMM+")"  ,oDocRti:RTI_NUMRET}) 
   AADD(aData,{"Estado "+cTipRti   ,cEstadoRti}) 
   AADD(aData,{"Neto:"            ,TRAN(oDpDocPro:DOC_NETO*oFrmRti:nCxP,"999,999,999,999.99") })
   AADD(aData,{"Saldo:"           ,TRAN(nSaldo          *oFrmRti:nCxP,"999,999,999,999.99") }) 
   AADD(aData,{"Exento:"          ,TRAN(oDp:nMontoEx     *oFrmRti:nCxP,"999,999,999,999.99") })
   AADD(aData,{"Base Imponible:"  ,TRAN(oDp:nBaseNet     *oFrmRti:nCxP,"999,999,999,999.99") })
   AADD(aData,{"I.V.A.:"          ,TRAN(oDp:nIva          ,"999,999,999,999.99") })
   AADD(aData,{"% Retención:"     ,TRAN(oDocRti:RTI_PORCEN,"999.99") })
   AADD(aData,{"Monto Retención :",TRAN(oFrmRti:nMtoRti   ,"999,999,999,999.99") })

// oFrmRti:CreateWindow()

// @ 1,.5 GROUP oFrmRti:oGrupo1 TO 4, 21.5 PROMPT GetFromVar("{oDp:xDPPROVEEDOR}")+":"+cCodigo
   @ 1,.5 GROUP oFrmRti:oGrupo1 TO 4, 21.5 PROMPT " Retención del Proveedor "

//  @ 1,1 SAY oFrmRti:oNombre PROMPT oFrmRti:cNombre

   oBrw:=TXBrowse():New(oFrmRti:oDlg )

   oBrw:SetArray( aData ,.F.)
   oBrw:lHScroll:=.F.
   oBrw:lVScroll:=.F.
   oBrw:l3D     :=.F.
   oBrw:lRecordSelector:=.F.
   oFrmRti:oBrw:=oBrw

   oBrw:oFont   :=oFontB

   oCol:=oBrw:aCols[1]
   oCol:cHeader      := "Campo"
   oCol:nWidth       := 190
   oCol:oHeaderFont  := oFont2
   oCol:oDataFont    := oFont2
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:bClrStd      := {|oBrw|oBrw:=oFrmRti:oBrw,{CLR_BLUE, iif( oBrw:nArrayAt%2=0,16770764,16774636 ) } }
//   oCol:bClrHeader   := {|oBrw|oBrw:=oFrmRti:oBrw,{CLR_BLUE,12582911}}

   oCol:=oBrw:aCols[2]
   oCol:cHeader      := "Descripción"
   oCol:nWidth       := 430-200+30
   oCol:oHeaderFont  := oFontB
   oBrw:bClrStd      := {|oBrw|oBrw:=oFrmRti:oBrw,{CLR_BLACK, iif( oBrw:nArrayAt%2=0,16770764,16774636 ) } }
   //oCol:bClrHeader   := {|oBrw|oBrw:=oFrmRti:oBrw,{CLR_BLUE,12582911}}
   oCol:bOnPostEdit  := {|oCol,uValue|oFrmRti:RTIPUTDATOS(oCol,uValue)}


   oBrw:bClrHeader            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}
   oBrw:bClrFooter            := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}


   oBrw:CreateFromCode()

   oBrw:bLDblClick   :={||oFrmRti:RUNCLICK() }
   oBrw:bChange      :={||oFrmRti:BRWCHANGE()}


   @ 13,1 SAY "Fecha:"       RIGHT
   @ 14,1 SAY "Declaración:" RIGHT

   @ 15,10 BMPGET oFrmRti:oRTI_FECHA VAR oFrmRti:RTI_FECHA;
           NAME "BITMAPS\Calendar.bmp";
           ACTION LbxDate(oFrmRti:oRTI_FECHA ,oFrmRti:RTI_FECHA) ;
           VALID (EJECUTAR("DPVALFECHA",oFrmRti:RTI_FECHA,.T.,.T.)) .AND. oFrmRti:SETFCHDEC();
           WHEN (AccessField("DPDOCPRO","DOC_FECHA",oFrmRti:nOption);
                 .AND. oFrmRti:nOption!=0);
           SIZE 41,10

   @ 16,10 BMPGET oFrmRti:oRTI_FCHDEC VAR oFrmRti:RTI_FCHDEC;
                  NAME "BITMAPS\Calendar.bmp";
                  ACTION LbxDate(oFrmRti:oRTI_FCHDEC ,oFrmRti:RTI_FCHDEC);
                  VALID (EJECUTAR("DPVALFECHA",oFrmRti:RTI_FCHDEC,.T.,.T.));
                         .AND. oFrmRti:RTI_FCHDEC>=oFrmRti:RTI_FECHA;
                  WHEN (AccessField("DPDOCCLI","RTI_FCHDEC",oFrmRti:nOption);
                       .AND. oFrmRti:nOption!=0 );
                  SIZE 41,10
  
   oFrmRti:oRTI_FCHDEC:cMsg    :="Fecha de la Retención"
   oFrmRti:oRTI_FCHDEC:cToolTip:="Fecha de la Retención"

   oFrmRti:Activate({||oFrmRti:oBar:=SETBOTBAR(oFrmRti:oDlg)})
// oFrmRti:oBar:ClassName()

/*
   oFrmRti:Activate({|| oFrmRti:RTIButtonBar() })

RETURN .T.

FUNCTION RTIButtonBar()
   LOCAL oCursor,oBtn,oFontB

   DEFINE CURSOR oCursor HAND

   DEFINE FONT oFontB   NAME "Tahoma" SIZE 0, -12 BOLD 

   DEFINE BUTTONBAR oFrmRti:oBar SIZE 40,40 OF oFrmRti:oDlg 3D CURSOR oCursor
*/
   IF !oFrmRti:lView 

    DEFINE BUTTON oBtn;
           OF oFrmRti:oBar;
           NOBORDER;
           FILE "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
           ACTION (oFrmRti:RTIACEPTAR());
           WHEN oFrmRti:nOption=3 
  
     oBtn:cToolTip:="Grabar"


     DEFINE BUTTON oBtn;
            OF oFrmRti:oBar;
            NOBORDER;
            FILE "BITMAPS\VIEW.BMP",NIL,"BITMAPS\VIEWG.BMP";
            ACTION oFrmRti:VIEW();
            WHEN oFrmRti:nOption=0 
  
     oBtn:cToolTip:="Consultar"


     DEFINE BUTTON oBtn;
            OF oFrmRti:oBar;
            NOBORDER;
            FILE "BITMAPS\MENU.BMP",NIL,"BITMAPS\MENUG.BMP";
            ACTION oFrmRti:MENURTI();
            WHEN oFrmRti:nOption=0 
  
     oBtn:cToolTip:="Menú de Retenciones"
 

     DEFINE BUTTON oBtn;
            OF oFrmRti:oBar;
            NOBORDER;	
            FILE "BITMAPS\XEDIT2.BMP",NIL,"BITMAPS\XEDITG.BMP";
            ACTION oFrmRti:MODIFICARX();
            WHEN ISTABMOD("DPDOCPRORTI") .AND. oFrmRti:nOption=0 .AND. !oFrmRti:lNulo


    oBtn:cToolTip:="Modificar"


    DEFINE BUTTON oBtn;
           OF oFrmRti:oBar;
           NOBORDER;	
           FILE "BITMAPS\XCANCEL.BMP",NIL,"BITMAPS\XCANCELG.BMP";
           ACTION (oFrmRti:nOption:=0,oFrmRti:oRTI_FECHA:ForWhen(.T.));
           WHEN oFrmRti:nOption=3

  oBtn:cToolTip:="Cancelar"


  DEFINE BUTTON oBtn;
          OF oFrmRti:oBar;
          NOBORDER;
          FILE "BITMAPS\XDELETE2.BMP",NIL,"BITMAPS\XDELETEG.BMP";
          ACTION oFrmRti:RTIANULAR();
          WHEN ISTABELI("DPDOCPRORTI") .AND. oFrmRti:nOption=0


  oBtn:cToolTip:="Anular"

   DEFINE BUTTON oBtn;
          OF oFrmRti:oBar;
          NOBORDER;
          FILE "BITMAPS\RETIVA.BMP",NIL,"BITMAPS\RETIVAG.BMP";
          ACTION oFrmRti:VALRIF();
          WHEN oFrmRti:nOption=0

   oBtn:cToolTip:="Verificar RIF"

 ELSE

     DEFINE BUTTON oBtn;
            OF oFrmRti:oBar;
            NOBORDER;
            FILE "BITMAPS\VIEW.BMP",NIL,"BITMAPS\VIEWG.BMP";
            ACTION oFrmRti:VIEW();
            WHEN oFrmRti:nOption=0 
  
     oBtn:cToolTip:="Consultar"


     DEFINE BUTTON oBtn;
            OF oFrmRti:oBar;
            NOBORDER;
            FILE "BITMAPS\MENU.BMP",NIL,"BITMAPS\MENUG.BMP";
            ACTION oFrmRti:MENURTI();
            WHEN oFrmRti:nOption=0 
  
     oBtn:cToolTip:="Menú de Retenciones"
 

 ENDIF

   DEFINE BUTTON oBtn;
          OF oFrmRti:oBar;
          NOBORDER;	
          FILE "BITMAPS\SENIAT.BMP";
          ACTION EJECUTAR("VIEWRIFSENIAT",oFrmRti:cRif,"DPPROVEEDOR",oFrmRti:nFilMai)

   oBtn:cToolTip:="Consultar RIF en www.Seniat.gob.ve"

   DEFINE BUTTON oBtn;
          OF oFrmRti:oBar;
          NOBORDER;
          FILE "BITMAPS\CRYSTAL.BMP";
          ACTION (CursorWait(),oFrmRti:EDITCRYSTAL())

   oBtn:cToolTip  :="Abrir Formato crystal\docprorti.rpt"


   DEFINE BUTTON oBtn;
          OF oFrmRti:oBar;
          NOBORDER;
          FILE "BITMAPS\AUDITORIA.BMP" ;
          PROMPT "Auditoria del Registro" ;
          ACTION (oFrmRti:cClaveDoc:=oFrmRti:oTable:GetDataKey(NIL,oFrmRti:oTable:cPrimary),;
                  EJECUTAR("VIEWAUDITOR","DPDOCPRORTI",oFrmRti:cClaveDoc))

   oBtn:cToolTip:="Visualizar Auditoria"


   IF !Empty(oDocRti:RTI_NUMRET)

     DEFINE BUTTON oBtn;
            OF oFrmRti:oBar;
            NOBORDER;
            FILE "BITMAPS\XPRINT.BMP";
            ACTION oFrmRti:RTIPRINTER()
 
     oBtn:cToolTip:="Imprimir"

   ENDIF

   DEFINE BUTTON oBtn;
          OF oFrmRti:oBar;
          NOBORDER;
          FILE "BITMAPS\XSALIR.BMP";
          ACTION oFrmRti:Close()

  oBtn:cToolTip:="Salir del Formulario"

  oFrmRti:oBar:SetSize(NIL,070,.t.)
  oFrmRti:oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oFrmRti:oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  @ 44,15 SAY oFrmRti:oNombre PROMPT oFrmRti:cNombre OF oFrmRti:oBar BORDER PIXEL BORDER FONT oFontB SIZE 420,20 COLOR oDp:nClrYellowText,oDp:nClrYellow

  // oFrmRti:Activate() 
  // {|| oFrmRti:RTIButtonBar() })


RETURN .T.

FUNCION RTIACEPTAR()

  CursorWait()

  SQLUPDATE("DPDOCPRO"   ,{"DOC_FECHA","DOC_FCHDEC","DOC_NETO"},{oFrmRti:RTI_FECHA,oFrmRti:RTI_FCHDEC,oFrmRti:nMtoRti },oFrmRti:cWhereDoc)
  SQLUPDATE("DPDOCPRORTI",{"RTI_FECHA","RTI_FCHDEC"},{oFrmRti:RTI_FECHA,oFrmRti:RTI_FCHDEC},oFrmRti:cWhereRti)

  IF oDp:lRTIFCHVEN
    EJECUTAR("DPDOCPROSETFCHDEC",oDp:cSucursal,oFrmRti:cTipDoc,oFrmRti:cCodigo,oFrmRti:cNumero,oFrmRti:RTI_FECHA)
  ENDIF

//? oFrmRti:cWhereDoc,"oFrmRti:cWhereDoc"

  // Nuevo Número de Retención
  IF !Empty(oFrmRti:cNEWTRA)
    SQLUPDATE("DPDOCPRORTI","RTI_NUMTRA",oFrmRti:cNEWTRA,oFrmRti:cWhereRti)
  ENDIF

  oFrmRti:RTIPRINTER()

  oFrmRti:Close()

RETURN NIL

FUNCTION MODIFICARX()

     IF ALLTRIM(UPPE(oFrmRti:oBrw:aArrayData[9,2]))="NULO"
       oFrmRti:RTIANULAR()
     ENDIF


    IF oFrmRti:ISCONTABRET(.F.)
       RETURN .F.
    ENDIF

   IF MsgNoYes("Numero: "+oFrmRti:RTI_NUMTRA,"Desea Modificar Retención")

        IF .T. // oFrmRti:nIva>0

          oFrmRti:nOption:=3

          oFrmRti:oRTI_FECHA :ForWhen(.T.)
          oFrmRti:oRTI_FCHDEC:ForWhen(.T.)
          oFrmRti:oWnd:SetText("Modificar "+oFrmRti:cNumTit)

          oFrmRti:oRTI_FECHA:SetFocus()

	   ENDIF

     ENDIF

RETURN 

FUNCTION SETFCHDEC()

  IF Empty(oFrmRti:RTI_FCHDEC)
    oFrmRti:oRTI_FCHDEC:VarPut(oFrmRti:RTI_FECHA,.T.)
  ENDIF

  IF oFrmRti:RTI_FECHA>oFrmRti:RTI_FCHDEC
     MensajeErr("Fecha de Retención no puede ser Inferior que la Fecha de Emisión")
     oFrmRti:oRTI_FCHDEC:VarPut(oFrmRti:RTI_FECHA,.T.)
     RETURN .F.
  ENDIF

RETURN .T.


FUNCTION RTIPRINTER()

   EJECUTAR("DPDOCPRORTIPRN",oFrmRti:RTI_CODSUC,oFrmRti:RTI_TIPDOC,oFrmRti:RTI_CODIGO,oFrmRti:RTI_NUMERO)

RETURN .T.

FUNCTION RTIANULAR()

   IF oFrmRti:ISCONTABRET(.F.)
      RETURN .F.
   ENDIF

   IF "NU"$UPPER(ALLTRIM(UPPE(oFrmRti:oBrw:aArrayData[9,2])))
   
      IF MsgYesNo("Retención Anulada, Desea Reactivarla?","Seleccione Una Opción")

         EJECUTAR("DPDOCPRORTISAV",oFrmRti:cCodSuc,oFrmRti:cTipDoc,oFrmRti:cCodigo,oFrmRti:cNumero,oFrmRti:cTipRti,.F.,.F.,NIL)

         oFrmRti:lNulo:=.F.
         oFrmRti:oBrw:aArrayData[9,2]:="Activo"
         oFrmRti:oBrw:Refresh(.T.)

      ENDIF

   ELSE

     IF MsgYesNo("Eliminar Retencion?","Seleccione Una Opción")

        EJECUTAR("DPDOCPRORTISAV",oFrmRti:cCodSuc,oFrmRti:cTipDoc,oFrmRti:cCodigo,oFrmRti:cNumero,oFrmRti:cTipRti,.F.,.T.,NIL)

        oFrmRti:lNulo:=.T.
        oFrmRti:oBrw:aArrayData[9,2]:="Nulo"
        oFrmRti:oBrw:Refresh(.T.)

     ENDIF

   ENDIF

RETURN NIL

/*
// Validación de RIF
*/
FUNCTION  VALRIF()

  LOCAL oDp:aRif:={},lOk:=.T.,cRif:="",nPorRti:=0
  LOCAL cCodSuc:=oFrmRti:cCodSuc,;
        cTipDoc:=oFrmRti:cTipDoc,;
        cCodigo:=oFrmRti:cCodigo,;
        cNumero:=oFrmRti:cNumero,;
        cTipRti:=oFrmRti:cTipRti


//? cTipDoc,cTipRti,"cTipDoc,cTipRti OTRO 4"

  IF ISDIGIT(oFrmRti:cRif)
    oFrmRti:cRif:=STRZERO(VAL(oFrmRti:cRif),8)
  ENDIF

  // QUITAR ESPACIOS
  oFrmRti:cRif:=PADR(STRTRAN(oFrmRti:cRif," ",""),LEN(oFrmRti:cRif))

  IF !MsgYesNo("Desea Verificar el RIF "+cRif,"Seleccione una Opción")
     RETURN .F.
  ENDIF

  EJECUTAR("DPDOCPRORTISAV",cCodSuc,cTipDoc,cCodigo,cNumero,cTipRti,.F.,.F.,NIL,.T.)

  // Lee nuevamente los Valores
  nPorRti:=SQLGET("DPDOCPRORTI","RTI_PORCEN",oFrmRti:cWhereRti)

  oFrmRti:nMtoRti:=SQLGET("DPDOCPRO"   ,"DOC_NETO"  ,OFrmRti:cWhereDoc)

  oFrmRti:oBrw:aArrayData[15,2]:=TRAN(nPorRti,"999.99")
  oFrmRti:oBrw:aArrayData[16,2]:=TRAN(oFrmRti:nMtoRti,"999,999,999,999.99")

  oFrmRti:oBrw:Refresh(.T.)

RETURN .F.

FUNCTION GETNUMCOMP()
LOCAL cNumComp


 IF !oDp:lRetIvaMul

  IF oDp:lRetIva_M=.F. 
     cNumComp:=oDocRti:RTI_NUMTRA
  ELSE
     cNumComp:=oDocRti:RTI_NUMCRR
  ENDIF

 ELSE

  // IF !oDp:lRetIva_M 

  IF oDp:lRetIvaMul=.F.
     cNumComp:=oDocRti:RTI_NUMTRA
  ELSE
     cNumComp:=oDocRti:RTI_NUMMRT
  ENDIF

 ENDIF
 
RETURN cNumComp

// Consulta del Documento
FUNCTION VIEW()
  LOCAL cCodSuc:=oFrmRti:cCodSuc,;
        cTipDoc:=oFrmRti:cTipDoc,;
        cCodigo:=oFrmRti:cCodigo,;
        cNumero:=oFrmRti:cNumRti,;
        cTipRti:=oFrmRti:cTipRti

  EJECUTAR("DPDOCPROFACCON",NIL,cCodSuc,cTipRti,cNumero,cCodigo)

RETURN NIL

FUNCTION MENURTI()
  LOCAL cCodSuc:=oFrmRti:cCodSuc,;
        cTipDoc:=oFrmRti:cTipDoc,;
        cCodigo:=oFrmRti:cCodigo,;
        cNumero:=oFrmRti:cNumRti,;
        cTipRti:=oFrmRti:cTipRti

  EJECUTAR("DPPRODOCMNU",cCodSuc,cTipRti,cNumero,cCodigo,NIL,NIL)

RETURN NIL

FUNCTION ISCONTABRET(lDelete)

   LOCAL cNumDoc:=oFrmRti:cNumRti
   LOCAL cTipDoc:=oFrmRti:cTipRti
   LOCAL cOrg   :="COM",cTipTra:="D",cDocPag:=NIL
   LOCAL cCodigo:=oFrmRti:cCodigo
   LOCAL cWhere :="DOC_CODSUC"+GetWhere("=",oFrmRti:cCodSuc)+" AND "+;
                  "DOC_TIPDOC"+GetWhere("=",cTipDoc        )+" AND "+;
                  "DOC_CODIGO"+GetWhere("=",oFrmRti:cCodigo)+" AND "+;
                  "DOC_NUMERO"+GetWhere("=",cNumDoc        )+" AND "+;
                  "DOC_TIPTRA='D'"
   LOCAL cNumCbt:=SQLGET("DPDOCPRO","DOC_CBTNUM,DOC_FECHA",cWhere)
   LOCAL dFecha :=DPSQLROW(2)
   LOCAL oObj:=oFrmRti:oNombre  

   DEFAULT lDelete:=.F.

   IF !Empty(cNumCbt) 
       EJECUTAR("ISCONTAB_ACT",cNumCbt,dFecha,cTipDoc,cNumDoc,cCodigo,cTipTra,cDocPag,cOrg,lDelete,oObj)
       RETURN lDelete
   ENDIF

RETURN .F.

FUNCTION BRWCHANGE()

   oFrmRti:oBrw:aCols[2]:nEditType:=0

   IF oFrmRti:oBrw:nArrayAt=6 .AND. oFrmRti:nOption=3 .AND. AccessField("DPDOCPRORTI","RTI_NUMTRA",3)
     oFrmRti:oBrw:aCols[2]:nEditType:=1
     oFrmRti:oBrw:aCols[2]:cEditPicture:="99999999"
     oFrmRti:oBrw:DrawLine(.T.)
   ENDIF

RETURN NIL

FUNCTION RUNCLICK()
   LOCAL nAt:=oFrmRti:oBrw:nArrayAt

    
RETURN NIL

FUNCTION RTIPUTDATOS(oCol,uValue)
   LOCAL nAt:=oFrmRti:oBrw:nArrayAt
  
   IF nAt=6
     oFrmRti:VALNUMRTI(uValue)
   ENDIF

RETURN NIL

/*
// 16/08/2016 Modificar Número
*/
FUNCTION VALNUMRTI(cNumero)
   LOCAL lFound,cExiste,cWhere

   cNumero:=STRZERO(VAL(cNumero),8)

   /*
   // Buscamos que no este repetida 
   */

   cWhere :="RTI_CODSUC"+GetWhere("=",oDp:cSucursal  )+" AND "+;
            "RTI_TIPDOC"+GetWhere("=",oFrmRti:cTipDoc)+" AND "+;
            "RTI_NUMTRA"+GetWhere("=",cNumero        )

   cExiste:=SQLGET("DPDOCPRORTI","RTI_NUMTRA",cWhere)

   IF !Empty(cExiste) .AND. !(oFrmRti:RTI_NUMTRA=cExiste)
      MsgMemo("Número de Retención "+cExiste+" ya Existe")
      RETURN .F.
   ENDIF

   oFrmRti:oBrw:aArrayData[oFrmRti:oBrw:nArrayAt,2]:=cNumero
   oFrmRti:oBrw:DrawLine(.t.)

/*
   cWhere :="RTI_CODSUC"+GetWhere("=",oDp:cSucursal     )+" AND "+;
            "RTI_TIPDOC"+GetWhere("=",oFrmRti:cTipDoc   )+" AND "+;
            "RTI_NUMTRA"+GetWhere("=",oFrmRti:RTI_NUMTRA)
*/
   oFrmRti:cNEWTRA:=cNumero

// SQLUPDATE("DPDOCPRORTI","RTI_NUMTRA",cNumero,cWhere)
// oFrmRti:RTI_NUMTRA:=cNumero  

RETURN .T.


FUNCTION EDITCRYSTAL()
  LOCAL cFileRpt:="crystal\docprorti.rpt"
  LOCAL cFileDbf:="crystal\docprorti.dbf"

  IF !FILE(cFileDbf)
     MsgMemo("Es Necesario Crear las Tablas de Datos","Será ejecutado el Report")
     RETURN oFrmRti:RTIPRINTER()
  ENDIF

  SHELLEXECUTE(oDp:oFrameDp:hWND,"open",cFileRpt)

RETURN .T.
// EOF
