// Programa   : DPDOCPRORMUEDIT
// Fecha/Hora : 29/10/2015 12:47:55
// Propósito  : Retención Municipal
// Creado Por : Juan Navas
// Llamado por: DPDOCPRO. Su numero se Genera según DOC_TIPAFE Y DOC_FACAFE el mismo tipo de Documento del Proveedor, asi permite su búsqueda
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero,lView)
  LOCAL cTipRet:="RMU",cWhere,oDocRmu,aData:={},cEstado:="",cRif,cWhereOrg:="",oDocOrg,aData:={},cCodRmu:="",cNomAct:=""
  LOCAL cEstadoRmu:="",cDocOrg:=""
  LOCAL oFontB,oFont2,oFont3,oBrw,oCol
  LOCAL cTitle,nFilMai

  DEFAULT cCodSuc:=oDp:cSucursal,;
          cTipDoc:="FAC",;
          cCodigo:=SQLGET("DPDOCPRO","DOC_CODIGO,DOC_NUMERO,DOC_FECHA,DOC_BASNET","DOC_TIPDOC"+GetWhere("=",cTipDoc)),;
          cNumero:=DPSQLROW(2),;
          lView  :=.F.

  cWhere :="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "DOC_TIPAFE"+GetWhere("=",cTipDoc)+" AND "+;
           "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
           "DOC_FACAFE"+GetWhere("=",cNumero)+" AND "+;
           "DOC_TIPTRA"+GetWhere("=","D")


  IF COUNT("DPDOCPRO",cWhere)=0 .AND. lView
     MsgMemo("Documento no posee retención Municipal")
     RETURN .F.
  ENDIF


  IF COUNT("DPDOCPRO",cWhere)=0 .AND. !EJECUTAR("DPDOCPRORMU",cCodSuc,cTipDoc,cCodigo,cNumero)
     RETURN .F.
  ENDIF

  oDocRmu:=OpenTable("SELECT * FROM DPDOCPRO WHERE "+cWhere,.T.)
  cEstado:=SAYOPTIONS("DPDOCPRO","DOC_ESTADO",oDocRmu:DOC_ESTADO)

  oDocRmu:End()

  cWhereOrg:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
             "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
             "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
             "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
             "DOC_TIPTRA"+GetWhere("=","D")


  oDocOrg   :=OpenTable("SELECT * FROM DPDOCPRO WHERE "+cWhereOrg,.T.)
  cEstadoRmu:=SAYOPTIONS("DPDOCPRO","DOC_ESTADO",oDocOrg:DOC_ESTADO)

  // Obtiene los datos de la factura de compra
  EJECUTAR("DPDOCCLIIMP",cCodSuc,cTipDoc,cCodigo,cNumero,.F.,oDocOrg:DOC_DCTO,oDocOrg:DOC_RECARG,oDocOrg:DOC_OTROS,"C") // ,cDocOrg)


//oDocOrg:Browse()
  oDocOrg:End()

  cEstado:=SAYOPTIONS("DPDOCPRO","DOC_ESTADO",oDocRmu:DOC_ESTADO)
  cRif   :=SQLGET("DPPROVEEDOR" ,"PRO_RIF,PRO_CODRMU","PRO_CODIGO"+GetWhere("=",oDocRmu:DOC_CODIGO))
  cCodRmu:=DPSQLROW(2)
//cNomAct:=SQLGET("DPACTIVIDAD_E","ACT_DESCRI","ACT_CODIGO"+GetWhere("=",cCodRmu))
  cNomAct:=SQLGET("DPRETMUNTARIFA","TRM_DESCRI","TRM_CODIGO"+GetWhere("=",cCodRmu))

  AADD(aData,{"Estado:"           ,cEstado                      })
  AADD(aData,{"RIF:"              ,cRif                         })
  AADD(aData,{"Actividad:"+cCodRmu,cNomAct                      })
  AADD(aData,{"Documento "+cTipDoc+": ",cNumero                 })
  AADD(aData,{"Fecha:"                       ,oDocOrg:DOC_FECHA })
  AADD(aData,{"Numero de Retención "+cTipRet ,oDocRmu:DOC_NUMERO}) 
  AADD(aData,{"Estado "+cTipRet              ,cEstadoRmu        }) 

  AADD(aData,{"Neto:"            ,FDP(oDocOrg:DOC_NETO ,"999,999,999,999.99") })
  AADD(aData,{"Exento:"          ,FDP(oDp:nMontoEx     ,"999,999,999,999.99") })
  AADD(aData,{"Base Imponible:"  ,FDP(oDp:nBaseNet     ,"999,999,999,999.99") })
  AADD(aData,{"I.V.A.:"          ,FDP(oDp:nIva         ,"999,999,999,999.99") })
  AADD(aData,{"% Retención:"     ,FDP(oDocRmu:DOC_DCTO ,"999.99") })
  AADD(aData,{"Monto Retención :",FDP(oDocRmu:DOC_NETO ,"999,999,999,999.99") })

  DEFINE FONT oFontB   NAME "Courier New" SIZE 0, -12 BOLD
  DEFINE FONT oFont2   NAME "Tahoma"     SIZE 0, -12 BOLD 
  DEFINE FONT oFont3   NAME "Tahoma"     SIZE 0, -14 BOLD 

  oFrmRmu:=DPEDIT():New("Retención Municipal","DPDOCPRORMU.EDT","oFrmRmu",.T.)
  oFrmRmu:CreateWindow()

  oFrmRmu:SetTable(oDocRmu,NIL)
  oFrmRmu:oTable:cPrimary:="DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO"
  oFrmRmu:cNumTit   :=oFrmRmu:cTitle
  oFrmRmu:oDocOrg   :=oDocOrg

  oFrmRmu:nOption  :=0
  oFrmRmu:oPagos   :=NIL
  oFrmRmu:nCxP     :=oDocOrg:DOC_CXP
  oFrmRmu:cRif     :=cRif
  oFrmRmu:nMtoRMU  :=SQLGET("DPDOCPRO","DOC_NETO",cWhere)
  oFrmRmu:cNombre  :=SQLGET("DPPROVEEDOR","PRO_NOMBRE,PRO_RETIVA","PRO_CODIGO"+GetWhere("=",cCodigo))
  oFrmRmu:nPorcen  :=IF (Empty(oDp:aRow),oDp:aRow[2])
  oFrmRmu:cWhereDoc:=cWhere
//oFrmRmu:cWhereRMU:=cWhereRMU
  oFrmRmu:cNumRmu  :=oDocRmu:DOC_NUMERO
  oFrmRmu:cCodigo  :=cCodigo
  oFrmRmu:cNumero  :=cNumero
  oFrmRmu:cTipDoc  :=cTipDoc
  oFrmRmu:cTipRet  :=cTipRet
  oFrmRmu:cCodSuc  :=cCodSuc
  oFrmRmu:nFilMai  :=nFilMai
  oFrmRmu:lNulo    :=ALLTRIM(UPPE(cEstadoRmu))="NULO"
  oFrmRmu:cClaveDoc:=cCodSuc+"-"+cTipDoc+"-"+cCodigo+"-"+cNumero
  oFrmRmu:lView    :=lView

//   cNumComp:= GETNUMCOMP()

   @ 1,.5 GROUP oFrmRmu:oGrupo1 TO 4, 21.5 PROMPT GetFromVar("{oDp:xDPPROVEEDOR}")+":"+cCodigo
   @ 1,.5 GROUP oFrmRmu:oGrupo1 TO 4, 21.5 PROMPT " Retención del Proveedor "

  @ 1,1 SAY oFrmRmu:oNombre PROMPT oFrmRmu:cNombre

   oBrw:=TXBrowse():New(oFrmRmu:oDlg )

   oBrw:SetArray( aData ,.F.)
   oBrw:lHScroll:=.F.
   oBrw:lVScroll:=.F.
   oBrw:l3D     :=.F.
   oBrw:lRecordSelector:=.F.
   oFrmRmu:oBrw:=oBrw

   oBrw:oFont   :=oFontB

   oCol:=oBrw:aCols[1]
   oCol:cHeader      := "Campo"
   oCol:nWidth       := 190
   oCol:oHeaderFont  := oFont2
   oCol:oDataFont    := oFont2
   oCol:nDataStrAlign:= AL_RIGHT
   oCol:bClrStd      := {|oBrw|oBrw:=oFrmRmu:oBrw,{CLR_BLUE, iif( oBrw:nArrayAt%2=0,oDp:nClrPane1,oDp:nClrPane2 ) } }
//   oCol:bClrHeader   := {|oBrw|oBrw:=oFrmRmu:oBrw,{CLR_BLUE,12582911}}

   oCol:=oBrw:aCols[2]
   oCol:cHeader      := "Descripción"
   oCol:nWidth       := 430-30
   oCol:oHeaderFont  := oFontB
   oBrw:bClrStd      := {|oBrw|oBrw:=oFrmRmu:oBrw,{CLR_BLACK, iif( oBrw:nArrayAt%2=0,oDp:nClrPane1,oDp:nClrPane2 ) } }
// oCol:bClrStd      := {|oBrw|oBrw:=oFrmRmu:oBrw,{CLR_BLUE, iif( oBrw:nArrayAt%2=0,oDp:nClrPane1,oDp:nClrPane2 ) } }
// oCol:bClrHeader   := {|oBrw|oBrw:=oFrmRmu:oBrw,{CLR_BLUE,12582911}}

   oBrw:bClrHeader          := {|| { oDp:nLbxClrHeaderText, oDp:nLbxClrHeaderPane}}

   oBrw:CreateFromCode()

   @ 13,1 SAY "Fecha :" RIGHT
   @ 14,1 SAY "Declaración:" RIGHT

   @ 15,10 BMPGET oFrmRmu:oDOC_FECHA VAR oFrmRmu:DOC_FECHA;
           NAME "BITMAPS\Calendar.bmp";
           ACTION LbxDate(oFrmRmu:oDOC_FECHA ,oFrmRmu:DOC_FECHA) ;
           VALID (EJECUTAR("DPVALFECHA",oFrmRmu:DOC_FECHA,.T.,.T.)) .AND. oFrmRmu:SETFCHDEC();
           WHEN (AccessField("DPDOCPRO","DOC_FECHA",oFrmRmu:nOption);
                 .AND. oFrmRmu:nOption!=0);
           SIZE 41,10

   @ 16,10 BMPGET oFrmRmu:oDOC_FCHDEC VAR oFrmRmu:DOC_FCHDEC;
                  NAME "BITMAPS\Calendar.bmp";
                  ACTION LbxDate(oFrmRmu:oDOC_FCHDEC ,oFrmRmu:DOC_FCHDEC);
                  VALID (EJECUTAR("DPVALFECHA",oFrmRmu:DOC_FCHDEC,.T.,.T.));
                         .AND. oFrmRmu:DOC_FCHDEC>=oFrmRmu:DOC_FECHA;
                  WHEN (AccessField("DPDOCCLI","DOC_FCHDEC",oFrmRmu:nOption);
                       .AND. oFrmRmu:nOption!=0 );
                  SIZE 41,10
  
   oFrmRmu:oDOC_FCHDEC:cMsg    :="Fecha de la Retención"
   oFrmRmu:oDOC_FCHDEC:cToolTip:="Fecha de la Retención"

   oFrmRmu:Activate({|| oFrmRmu:ButtonBar() })

RETURN .T.

FUNCTION ButtonBar()

   LOCAL oCursor,oBtn

   DEFINE CURSOR oCursor HAND

   DEFINE BUTTONBAR oFrmRmu:oBar SIZE 40,40 OF oFrmRmu:oDlg 3D CURSOR oCursor

   IF !oFrmRmu:lView 

     DEFINE BUTTON oBtn;
            OF oFrmRmu:oBar;
            NOBORDER;
            FILE "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
            ACTION (oFrmRmu:RMUACEPTAR());
            WHEN oFrmRmu:nOption=3 
  
     oBtn:cToolTip:="Grabar"


     DEFINE BUTTON oBtn;
            OF oFrmRmu:oBar;
            NOBORDER;
            FILE "BITMAPS\VIEW.BMP",NIL,"BITMAPS\VIEWG.BMP";
            ACTION oFrmRmu:VIEW();
            WHEN oFrmRmu:nOption=0 
  
     oBtn:cToolTip:="Consultar"


     DEFINE BUTTON oBtn;
            OF oFrmRmu:oBar;
            NOBORDER;
            FILE "BITMAPS\MENU.BMP",NIL,"BITMAPS\MENUG.BMP";
            ACTION oFrmRmu:MENURMU();
            WHEN oFrmRmu:nOption=0 
  
     oBtn:cToolTip:="Menú de Retenciones"
 

     DEFINE BUTTON oBtn;
            OF oFrmRmu:oBar;
            NOBORDER;	
            FILE "BITMAPS\XEDIT2.BMP",NIL,"BITMAPS\XEDITG.BMP";
            ACTION oFrmRmu:MODIFICARX();
            WHEN ISTABMOD("DPDOCPRORMU") .AND. oFrmRmu:nOption=0 .AND. !oFrmRmu:lNulo

     oBtn:cToolTip:="Modificar"


     DEFINE BUTTON oBtn;
            OF oFrmRmu:oBar;
            NOBORDER;	
            FILE "BITMAPS\XCANCEL.BMP",NIL,"BITMAPS\XCANCELG.BMP";
            ACTION (oFrmRmu:nOption:=0,oFrmRmu:oDOC_FECHA:ForWhen(.T.));
            WHEN oFrmRmu:nOption=3

     oBtn:cToolTip:="Cancelar"


     DEFINE BUTTON oBtn;
            OF oFrmRmu:oBar;
            NOBORDER;
            FILE "BITMAPS\XDELETE2.BMP",NIL,"BITMAPS\XDELETEG.BMP";
            ACTION oFrmRmu:RMUANULAR();
            WHEN ISTABELI("DPDOCPRORMU") .AND. oFrmRmu:nOption=0

     oBtn:cToolTip:="Anular"


   ELSE

     DEFINE BUTTON oBtn;
            OF oFrmRmu:oBar;
            NOBORDER;
            FILE "BITMAPS\VIEW.BMP",NIL,"BITMAPS\VIEWG.BMP";
            ACTION oFrmRmu:VIEW();
            WHEN oFrmRmu:nOption=0 
  
     oBtn:cToolTip:="Consultar"


     DEFINE BUTTON oBtn;
            OF oFrmRmu:oBar;
            NOBORDER;
            FILE "BITMAPS\MENU.BMP",NIL,"BITMAPS\MENUG.BMP";
            ACTION oFrmRmu:MENURMU();
            WHEN oFrmRmu:nOption=0 
  
     oBtn:cToolTip:="Menú de Retenciones"
 

   ENDIF


   DEFINE BUTTON oBtn;
          OF oFrmRmu:oBar;
          NOBORDER;
          FILE "BITMAPS\XPRINT.BMP" ;
          PROMPT "Imprimir Retención" ;
          ACTION oFrmRmu:RMUPRINTER()

   oBtn:cToolTip:="Visualizar Auditoria"


   DEFINE BUTTON oBtn;
          OF oFrmRmu:oBar;
          NOBORDER;
          FILE "BITMAPS\AUDITORIA.BMP" ;
          PROMPT "Auditoria del Registro" ;
          ACTION (oFrmRmu:cClaveDoc:=oFrmRmu:oTable:GetDataKey(NIL,oFrmRmu:oTable:cPrimary),;
                  EJECUTAR("VIEWAUDITOR","DPDOCPRORMU",oFrmRmu:cClaveDoc))

   oBtn:cToolTip:="Visualizar Auditoria"


   DEFINE BUTTON oBtn;
          OF oFrmRmu:oBar;
          NOBORDER;
          FILE "BITMAPS\XSALIR.BMP";
          ACTION oFrmRmu:Close()

  oBtn:cToolTip:="Salir del Formulario"

  oFrmRmu:oBar:SetColor(CLR_BLACK,oDp:nGris)

  AEVAL(oFrmRmu:oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})

  oFrmRmu:oBrw:SetColor(0,oDp:nClrPane1)

RETURN .T.

FUNCION RMUACEPTAR()

  CursorWait()

  SQLUPDATE("DPDOCPRO"   ,{"DOC_FECHA","DOC_FCHDEC","DOC_NETO"},{oFrmRmu:DOC_FECHA,oFrmRmu:DOC_FCHDEC,oFrmRmu:nMtoRMU },oFrmRmu:cWhereDoc)

  oFrmRmu:RMUPRINTER()
  oFrmRmu:Close()

RETURN NIL

FUNCTION MODIFICARX()

     IF ALLTRIM(UPPE(oFrmRmu:oBrw:aArrayData[9,2]))="NULO"
       oFrmRmu:RMUANULAR()
     ENDIF


    IF oFrmRmu:ISCONTABRET(.F.)
       RETURN .F.
    ENDIF

   IF MsgNoYes("Numero: "+oFrmRmu:DOC_NUMERO,"Desea Modificar Retención")

        IF .T. // oFrmRmu:nIva>0

          oFrmRmu:nOption:=3

          oFrmRmu:oDOC_FECHA :ForWhen(.T.)
          oFrmRmu:oDOC_FCHDEC:ForWhen(.T.)
          oFrmRmu:oWnd:SetText("Modificar "+oFrmRmu:cNumTit)

          oFrmRmu:oDOC_FECHA:SetFocus()

	   ENDIF

     ENDIF

RETURN 

FUNCTION SETFCHDEC()

  IF Empty(oFrmRmu:DOC_FCHDEC)
    oFrmRmu:oDOC_FCHDEC:VarPut(oFrmRmu:DOC_FECHA,.T.)
  ENDIF

  IF oFrmRmu:DOC_FECHA>oFrmRmu:DOC_FCHDEC
     oFrmRmu:oDOC_FCHDEC:MsgErr("Fecha de Retención no puede ser Inferior que la Fecha de Declaración")
     oFrmRmu:oDOC_FCHDEC:VarPut(oFrmRmu:DOC_FECHA,.T.)
     RETURN .F.
  ENDIF

RETURN .T.


FUNCTION RMUPRINTER()

  LOCAL cCodSuc:=oFrmRmu:cCodSuc,;
        cCodigo:=oFrmRmu:cCodigo,;
        cNumero:=oFrmRmu:cNumero,;
        cTipDoc:=oFrmRmu:cTipDoc

  EJECUTAR("DPDOCPRORMUPRN",cCodSuc,cTipDoc,cCodigo,cNumero)

RETURN .T.

FUNCTION RMUANULAR()

   IF oFrmRmu:ISCONTABRET(.F.)
      RETURN .F.
   ENDIF

   IF "NU"$UPPER(ALLTRIM(UPPE(oFrmRmu:oBrw:aArrayData[9,2])))
   
      IF MsgYesNo("Retención Anulada, Desea Reactivarla?","Seleccione Una Opción")

         EJECUTAR("DPDOCPRORMUSAV",oFrmRmu:cCodSuc,oFrmRmu:cTipDoc,oFrmRmu:cCodigo,oFrmRmu:cNumero,oFrmRmu:cTipRet,.F.,.F.,NIL)

         oFrmRmu:lNulo:=.F.
         oFrmRmu:oBrw:aArrayData[9,2]:="Activo"
         oFrmRmu:oBrw:Refresh(.T.)

      ENDIF

   ELSE

     IF MsgYesNo("Eliminar Retencion Municipal?","Seleccione Una Opción")

        EJECUTAR("DPDOCPRORMUSAV",oFrmRmu:cCodSuc,oFrmRmu:cTipDoc,oFrmRmu:cCodigo,oFrmRmu:cNumero,oFrmRmu:cTipRet,.F.,.T.,NIL)

        oFrmRmu:lNulo:=.T.
        oFrmRmu:oBrw:aArrayData[9,2]:="Nulo"
        oFrmRmu:oBrw:Refresh(.T.)

     ENDIF

   ENDIF

RETURN NIL

// Consulta del Documento
FUNCTION VIEW()
  LOCAL cCodSuc:=oFrmRmu:cCodSuc,;
        cTipDoc:=oFrmRmu:cTipDoc,;
        cCodigo:=oFrmRmu:cCodigo,;
        cNumero:=oFrmRmu:cNumRmu,;
        cTipRet:=oFrmRmu:cTipRet

  EJECUTAR("DPDOCPROFACCON",NIL,cCodSuc,cTipRet,cNumero,cCodigo)

RETURN NIL

FUNCTION MENURMU()
  LOCAL cCodSuc:=oFrmRmu:cCodSuc,;
        cTipDoc:=oFrmRmu:cTipDoc,;
        cCodigo:=oFrmRmu:cCodigo,;
        cNumero:=oFrmRmu:cNumRmu,;
        cTipRet:=oFrmRmu:cTipRet

  EJECUTAR("DPPRODOCMNU",cCodSuc,cTipRet,cNumero,cCodigo,NIL,NIL)

RETURN NIL

FUNCTION ISCONTABRET(lDelete)

   LOCAL cNumDoc:=oFrmRmu:cNumRmu
   LOCAL cTipDoc:=oFrmRmu:cTipRet
   LOCAL cOrg   :="COM",cTipTra:="D",cDocPag:=NIL
   LOCAL cCodigo:=oFrmRmu:cCodigo
   LOCAL cWhere :="DOC_CODSUC"+GetWhere("=",oFrmRmu:cCodSuc)+" AND "+;
                  "DOC_TIPDOC"+GetWhere("=",cTipDoc        )+" AND "+;
                  "DOC_CODIGO"+GetWhere("=",oFrmRmu:cCodigo)+" AND "+;
                  "DOC_NUMERO"+GetWhere("=",cNumDoc        )+" AND "+;
                  "DOC_TIPTRA='D'"
   LOCAL cNumCbt:=SQLGET("DPDOCPRO","DOC_CBTNUM,DOC_FECHA",cWhere)
   LOCAL dFecha :=DPSQLROW(2)
   LOCAL oObj:=oFrmRmu:oNombre  

   DEFAULT lDelete:=.F.

   IF !Empty(cNumCbt) 
       EJECUTAR("ISCONTAB_ACT",cNumCbt,dFecha,cTipDoc,cNumDoc,cCodigo,cTipTra,cDocPag,cOrg,lDelete,oObj)
       RETURN lDelete
   ENDIF

RETURN .F.
// EOF
