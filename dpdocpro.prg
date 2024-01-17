// Programa   : DPDOCPRO
// Fecha/Hora : 22/11/2004 23:10:42
// Propósito  : Factura de Venta
// Creado Por : Juan Navas
// Llamado por: Ventas y Cuentas por Pagar
// Aplicación : COMPRAS
// Tabla      : DPDOCCLI
// Se Agrego Funcion CARGCAMP que Carga los Campos CONDICION y DIAS PLAZO del Proveedor

#INCLUDE "DPXBASE.CH" 
#include "Constant.ch"
#INCLUDE "SAYREF.CH"

PROCE MAIN(cTipDoc,cCodigo,cNumero,lView,cCenCos,cCodAlm,cCodSuc)
  LOCAL I,aData:={},oGrid,oCol,cSql,cScope,aMonedas:={},T1:=SECONDS()
  LOCAL cTitle:="",cExcluye:=""
  LOCAL oFont,oFontG,oFontB,oSayRef
  LOCAL aExt:={".EDT",".SCG",".BRW"}
  LOCAL cFileEdt,cFileScg,cFileBrw,cFile
  LOCAL cPrimary:="DOC_CODIGO,DOC_NUMERO",lEditNum:=.F.
  LOCAL cOrderBy:="DOC_FECHA,DOC_HORA,DOC_CODIGO,DOC_NUMERO"
  LOCAL dFechaS :=NIL  // Necesario para DPINV/INV_FCHACT/GRIDPOST
  LOCAL lPesado :=.T. // IF(ISFIELD("DPUNDMED","UND_VARIA"),COUNT("DPUNDMED","UND_VARIA=1")>0,.F.)
  LOCAL lIslr,oDefCol,nWidth
  LOCAL aCoors    :=GetCoors( GetDesktopWindow() ),nTotCol:=0,nWidth:=0,nPos
  LOCAL oData,nFontSize

// ? cTipDoc,cCodigo,cNumero,lView,cCenCos,cCodAlm,"cTipDoc,cCodigo,cNumero,lView,cCenCos,cCodAlm"

  IF Type("oDocPro")="O" .AND. oDocPro:oWnd:hWnd>0
     RETURN EJECUTAR("BRRUNNEW",oDocPro,GetScript())
  ENDIF

  DEFAULT cCodSuc:=oDp:cSucursal

//  oDp:lTracer:=.T.

  dFechaS :=EJECUTAR("DPFECHASRV") // Necesario para DPINV/INV_FCHACT/GRIDPOST

  // lPesado:=IF(ValType(lPesado)<>"L",.F.,lPesado)
 

  lPesado:=.T.

  DEFAULT cTipDoc:="FAC",;
          lView  :=.T.  ,;
          cCodAlm:=oDp:cAlmacen

  oData    :=DATASET("DPTIPDOCPRO","USER")
  nFontSize:=oData:Get(cTipDoc,IF(Empty(oDp:cModeVideo),12,18))  
  oData:End()

  DEFAULT oDp:nInvLotes:=COUNT("DPINV","INV_METCOS"+GetWhere("=","L")+" OR INV_METCOS"+GetWhere("=","C"))

 cTipDoc:=ALLTRIM(cTipDoc)

//? cTipDoc,cCodigo,cNumero,lView,cCenCos,"cTipDoc,cCodigo,cNumero,lView,cCenCos",oDocPro:GET(cTipDoc+"RETISR"),[<oDp:Get(cTipDoc+"RETISR")]

  IF Empty(oDp:aMonedas)
     MsgMemo("No hay monedas definidas")
     RETURN .F.
  ENDIF

// EJECUTAR("INSPECT",oDp)
// RETURN .T.
  EJECUTAR("SETIVAPE")

  oDp:nAlmacen:=COUNT("DPALMACEN","ALM_ACTIVO=1")

  // ? oDp:nAlmacen,"oDp:nAlmacen"
  // Lee los Privilegios del Usuario
  IF !EJECUTAR("DPPRIVCOMLEE",cTipDoc,.T.) // Lee los Privilegios del Usuario
     RETURN .F.
  ENDIF

//lEditNum:=SQLGET("DPTIPDOCPRO","TDC_NUMEDT","TDC_TIPO"+GetWhere("=",cTipDoc))
  cTitle  :=ALLTRIM(SQLGET("DPTIPDOCPRO","TDC_DESCRI,TDC_NUMEDT","TDC_TIPO"+GetWhere("=",cTipDoc)))
  lEditNum:=DPSQLROW(2,.T.)  

 // Documentos (Orden de Compra) Ordenado por Numero
  IF !lEditNum
     cPrimary:="DOC_NUMERO,DOC_CODIGO"
     cOrderBy:=cPrimary
  ENDIF

  IF !Empty(cCenCos)
     cTitle:=cTitle+" ["+oDp:DPCENCOS+" "+cCenCos+" "+ALLTRIM(SQLGET("DPCENCOS","CEN_DESCRI","CEN_CODIGO"+GetWhere("=",cCenCos)))+"]"
  ENDIF

  // Font Para el Browse
/*
  IF Empty(oDp:cModeVideo)
    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -12
    DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -12 BOLD
  ELSE
    DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, -15
    DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, -15 BOLD
  ENDIF
*/

  DEFINE FONT oFont  NAME "Tahoma"   SIZE 0, nFontSize
  DEFINE FONT oFontB NAME "Tahoma"   SIZE 0, nFontSize BOLD

  IF !ISDPSTD() 

    FOR I=1 TO LEN(aExt)
      cFile:="FORMS\DPDOCPRO_"+cTipDoc+aExt[I]
      IF !FILE(cFile) 
        COPY FILE ("FORMS\DPDOCPRO_FAC"+aExt[I]) TO (cFile)
      ENDIF
    NEXT I

    cFileEdt:="FORMS\DPDOCPRO_"+cTipDoc+aExt[1]
    cFileScg:="FORMS\DPDOCPRO_"+cTipDoc+aExt[2]
    cFileBrw:="FORMS\DPDOCPRO_"+cTipDoc+aExt[3]

  ELSE

    cFileEdt:="FORMS\DPDOCPRO_FAC"+aExt[1]
    cFileScg:="FORMS\DPDOCPRO_FAC"+aExt[2]
    cFileBrw:="FORMS\DPDOCPRO_FAC"+aExt[3]

    IF !ISFILESTD(cFileEdt,.T.)
       MsgMemo("Componente "+cFileEdt+" no está DPSTD")
       RETURN .F.
    ENDIF

  ENDIF

  DOCENC(cTitle,"oDocPro",cFileEdt)

  // JN 6/12/2018 // Incluye Centro de Costos

  cScope:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          "DOC_TIPDOC"+GetWhere("=",cTipDoc)+;
          IIF(Empty(cCenCos),""," AND DOC_CENCOS"+GetWhere("=",cCenCos))+;
          " AND DOC_DOCORG='C' AND DOC_TIPTRA='D' "

  IF !Empty(cCodigo) .AND. !Empty(cNumero)

     cScope:="DOC_CODSUC"+GetWhere("=",cCodSuc)+;
             " AND DOC_TIPDOC"+GetWhere("=",cTipDoc)+;
             " AND DOC_CODIGO"+GetWhere("=",cCodigo)+;
             " AND DOC_NUMERO"+GetWhere("=",cNumero)+;
             " AND DOC_DOCORG='C' AND DOC_TIPTRA='D' "

  ENDIF

  oDocPro:cCodSuc:=cCodSuc
  oDefCol:=EJECUTAR("DPTIPDOCPROCOLPAR",cTipDoc)

  oDocPro:oDefCol:=oDefCol
  oDocPro:lBar:=.T.
  oDocPro:SetScope(cScope)
  oDocPro:SetTable("DPDOCPRO",cPrimary,NIL, NIL, NIL,NIL,cOrderBy) // "DOC_CODIGO,DOC_NUMERO")
  oDocPro:cWhereRecord :=cScope
  oDocPro:cNomDoc      :=ALLTRIM(cTitle)
  oDocPro:nBruto       :=0
  oDocPro:nIVA         :=0
  oDocPro:lDocGen      :=.F.
  oDocPro:lAprob       :=.T.
  oDocPro:lCtaEgr      :=oDp:P_LCtaEgrCxP
  oDocPro:cTipDoc      :=cTipDoc
  oDocPro:cCodSuc      :=oDocPro:cCodSuc
  oDocPro:oFrmDoc      :=NIL
  oDocPro:lCodigo      :=.T.
  oDocPro:cFileBrw     :=cFileBrw
  oDocPro:cWherePro    :="(PRO_TIPO"+GetWhere("=","Proveedor")+" OR PRO_TIPO"+GetWhere("=","Prestador de Servicios")+")"                                                          
  oDocPro:cPar_EXIVAL  :="C"
  oDocPro:lDocFecha    :=.F.
  oDocPro:cScope_Update:="DOC_DOCORG='C' AND DOC_TIPTRA='D' "
  oDocPro:dFechaS      :=dFechaS
  oDocPro:DOC_MTOBRU   :=0 // Calculado por DOCTOTAL, contiene Monto Bruto
  oDocPro:DOC_BAS_GN   :=0 // Monto para Determinar el IVA de Rebaja
  oDocPro:lPELock      :=.F.
  oDocPro:cCenCos      :=cCenCos
  oDocPro:lMoneta      :=.T.
  oDocPro:cRif         :=""
  oDocPro:lView        :=lView
  oDocPro:cCodAlm      :=NIL
  oDocPro:cNumOrg      :=NIL
  oDocPro:cTipOrg      :=NIL
  oDocPro:cCodAlm      :=cCodAlm
  oDocPro:cCodSuc      :=cCodSuc
  oDocPro:lAutoSize    :=(aCoors[4]>1200)
  oDocPro:lMoneta      :=.T.
  oDocPro:lRetMun      :=.T.
  oDocPro:oDpLbx       :=NIL

  IF (ISRELEASE("19.07") .OR. DPVERSION()>=6) // AutoAjuste
    oDocPro:lAutoSize:=.T.
  ELSE
    oDocPro:lAutoSize:=.F.
  ENDIF

  EJECUTAR("DPDOCPROPAR",oDocPro,cTipDoc)

// ? oDocPro:nPar_InvFis,oDocPro:nPar_InvLog,oDocPro:nPar_InvCon,"oDocPro:nPar_InvFis,oDocPro:nPar_InvLog,oDocPro:nPar_InvCon"
// ? oDocPro:lPar_Almace,oDocPro:lPar_DocAlm,oDp:nAlmacen,oDocPro:nPar_ItemDesc,"oDocPro:lPar_Almace,oDocPro:lPar_DocAlm,oDp:nAlmacen,oDocPro:nPar_ItemDesc"

  lIslr:=oDocPro:TDC_RETISR

  IF ValType(lIslr)<>"L" .OR. ValType(oDocPro:lPar_LibCom)<>"L"
    EJECUTAR("DPDOCPROPAR",oDocPro,cTipDoc)
    lIslr:=oDocPro:TDC_RETISR
  ENDIF

//  cFileEdt:="FORMS\DPDOCPRO"+cTipDoc+oDp:cModeVideo+".EDT"

/*

  IF !(cTipDoc$"FAC,NRC")
    FERASE(cFileEdt)
  ENDIF

  IF (!FILE("FORMS\DPDOCPRO"+cTipDoc+oDp:cModeVideo+".EDT")) .AND. oDocPro:lPar_LibCom
    COPY FILE "FORMS\DPDOCPROFAC2.EDT" TO (cFileEdt)
  ENDIF

  IF (!FILE("FORMS\DPDOCPRO"+cTipDoc+oDp:cModeVideo+".EDT")) .AND. !oDocPro:lPar_LibCom
     COPY FILE "FORMS\DPDOCPROFAC2.EDT" TO (cFileEdt)
  ENDIF
*/

  oDocPro:cPrimary:="DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO"

  // IIF(Empty(oDp:cModeVideo),oDocPro:Windows(5,15,460,770)

  IF oDocPro:lAutoSize

    oDocPro:Windows(0,0,625,aCoors[4]-10)
  ELSE

    oDocPro:Windows(0,0,610,1010)

  ENDIF

  IF !Empty(cNumero) .AND. lView
    oDocPro:lMod:=.F.
    oDocPro:lInc:=.F.
    oDocPro:lEli:=.F.
  ENDIF

 oDocPro:lCon:=.T.

  IF !oDocPro:lPar_EditNum
    oDocPro:cPrimary:="DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO"
//  oDocPro:SetIncremental("DOC_NUMERO",cScope,oDocPro:GET(cTipDoc+"NUMERO"))
  ENDIF
 
  oDocPro:SetMemo("DOC_NUMMEM","Descripción Amplia")

  IF oDp:P_LDpCreaPro .OR. .T.

    oDocPro:AddBtnEdit("PROVEEDORES.bmp","Creación Rápida del Proveedor","(oDocPro:nOption=1 .OR. oDocPro:nOption=3 )",;
                   "EJECUTAR('DPCREAPROVEE',oDocPro:oDOC_CODIGO)","CLI")

  ENDIF

  IF oDp:nVersion>4
    oDocPro:SetAdjuntos("DOC_FILMAI") // Vinculo con DPFILEEMP
  ENDIF

/*
  oDocPro:AddBtnEdit("xpeople2.bmp","Cliente Genérico","(oDocPro:nOption=1 .OR. oDocPro:nOption=3) .AND. oDocPro:DOC_CODIGO=STRZERO(0,10)",;
                                     "EJECUTAR('DPCLIENTESCERO',oDoc,oDocPro:oDOC_CODIGO)",;
                                     "CLI")
*/
  oDocPro:AddBtn("xexpediente.bmp","Expedientes","(oDocPro:nOption=0)",;
                  "EJECUTAR('DPDOCPROEXP',NIL,oDocPro:DOC_CODSUC,;
                                             oDocPro:DOC_TIPDOC,;
                                             oDocPro:DOC_CODIGO,;
                                             oDocPro:DOC_NUMERO,;
                                             'Expedientes '+oDocPro:cTitle,'GRABAR')","PRO")

  oDocPro:AddBtn("MENU.bmp","Menú de Opciones","(oDocPro:nOption=0)",;
                    "EJECUTAR('DPDOCPROMNU',oDocPro:DOC_CODSUC ,;
                                            oDocPro:DOC_NUMERO ,;
                                            oDocPro:DOC_CODIGO ,;
                                            oDocPro:cNomDoc , oDocPro:DOC_TIPDOC , oDoc  )","PRO")

   IF oDocPro:TDC_RETISR

     oDocPro:AddBtn("RETISLR.bmp","Retención ISLR","(oDocPro:nOption=0)",;
                    "EJECUTAR('DPDOCISLR',oDocPro:DOC_CODSUC,;
                                          oDocPro:DOC_TIPDOC,;
                                          oDocPro:DOC_CODIGO,;
                                          oDocPro:DOC_NUMERO,;
                                          oDocPro:cNomDoc , 'C'    )","PRO")
   ENDIF

   // Si es Contribuyente Especial o Ente Publico

// ? oDocPro:TDC_RETIVA,"oDocPro:TDC_RETIVA "

   IF oDocPro:TDC_RETIVA .AND. LEFT(oDp:cTipCon,1)="E"

/*
     oDocPro:AddBtn("RETIVA.bmp","Retención de IVA","(oDocPro:nOption=0)",;
                     "EJECUTAR('DPDOCPRORTI' ,oDocPro:DOC_CODSUC,;
                                              oDocPro:DOC_TIPDOC,;
                                              oDocPro:DOC_CODIGO,;
                                              oDocPro:DOC_NUMERO,;
                                              oDocPro:cNomDoc , 'C'    )","PRO")
*/

     oDocPro:AddBtn("RETIVA.bmp","Retención de IVA","(oDocPro:nOption=0)",;
                     "oDocPro:DOCRTI()","PRO")

  ENDIF

  IF oDocPro:TDC_RETMUN .AND. ISRELEASE("16.08") .AND. oDp:lRet_Mun

     oDocPro:AddBtn("RETMUN.bmp","Retención Municipal","(oDocPro:nOption=0)",;
                     "EJECUTAR('DPDOCPRORMUEDIT' ,oDocPro:DOC_CODSUC,;
                                                  oDocPro:DOC_TIPDOC,;
                                                  oDocPro:DOC_CODIGO,;
                                                  oDocPro:DOC_NUMERO,;
                                                  ,.F.,oDocPro:cNomDoc , 'C'    )","PRO")
  ENDIF

  IF oDocPro:TDC_REQDIG .AND. oDp:nVersion>=5

     oDocPro:AddBtn("ADJUNTAR.BMP","Digitalización","(oDocPro:nOption=0)",;
                    "EJECUTAR([DPDOCPRODIG],oDocPro:DOC_CODSUC,oDocPro:DOC_TIPDOC,oDocPro:DOC_CODIGO,oDocPro:DOC_NUMERO,.F.)","PRO")

  ENDIF

  IF oDocPro:DOC_CXP<>0 .AND. (oDp:dFecha>=oDp:dDesdePE .AND. oDp:dFecha<=oDp:dHastaPE)

     EJECUTAR("DPDOCPRO10IVA",oDocPro)

     oDocPro:AddBtnEdit("iva10%.bmp","Pago Electrónico","(oDocPro:nOption=1 .OR. oDocPro:nOption=3) .AND. !oDocPro:lPELock",;
                        "oDocPro:SETIVA10()","PRO")


  ENDIF

  oDocPro:cList:=NIL // AG20080401

  @ 1.35,0 FOLDER oDocPro:oFolder ITEMS cTitle,"Otros Valores" OF oDocPro:oDlg SIZE 390,61

  SETFOLDER( 1)

  // Nombre del Proveedor
  @ 0.1,0.1 SAY oSayRef PROMPT oDocPro:cNamePro+":" RIGHT SIZE 42,20

  SayAction(oSayRef,{||oDocPro:CONPROVEEDOR()})

  // Moneda
  @ 1.5,.1 SAY oSayRef PROMPT oDocPro:cNameMon+":" RIGHT SIZE 42,20

  SayAction(oSayRef,{||DpLbx("DPTABMON.LBX")})

  // Descuento
  @ 1.0,0 SAY oSayRef PROMPT "Descuento:" SIZE 42,12 FONT oFontB RIGHT COLORS CLR_HBLUE,oDp:nGris

  SayAction(oSayRef,{||oDocPro:RUNDESC()})

  @ 2.2,10 SAY "Condición:" RIGHT SIZE 42,20
  @ 2.2,28 SAY "Plazo:"     RIGHT SIZE 42,20
  @ 0.1,50 SAY "Número:" RIGHT
  @ 0.8,50 SAY "Fecha:"  RIGHT
  @ 1.5,50 SAY "Estado:" RIGHT
  @ 1.5,20 SAY "Cambio:" RIGHT

/*
  @ 0.1,6 BMPGET oDocPro:oDOC_CODIGO VAR oDocPro:DOC_CODIGO;
                 VALID oDocPro:VALCODPRO(oDocPro:DOC_CODIGO);
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION oDocPro:LBXPROVEEDOR();
                 ON CHANGE(oDocPro:CARGCAMP());   
                 WHEN (AccessField("DPDOCPRO","DOC_CODIGO",oDocPro:nOption);
                      .AND. oDocPro:nOption!=0 .AND. oDocPro:lEditPro  ;
                      .AND. IIF(oDocPro:nOption=3 .AND. !oDocPro:lPar_CamCodPro,.F.,.T.));
                 SIZE 48,10
*/

  @ 0.1,6 BMPGET oDocPro:oDOC_CODIGO VAR oDocPro:DOC_CODIGO;
                 VALID oDocPro:VALCODPRO(oDocPro:DOC_CODIGO);
                 NAME "BITMAPS\FIND.BMP"; 
                 ACTION oDocPro:LBXPROVEEDOR();
                 WHEN (AccessField("DPDOCPRO","DOC_CODIGO",oDocPro:nOption);
                      .AND. oDocPro:nOption!=0 .AND. oDocPro:lEditPro  ;
                      .AND. IIF(oDocPro:nOption=3 .AND. !oDocPro:lPar_CamCodPro,.F.,.T.));
                 SIZE 48,10



//  oDocPro:oDOC_CODIGO:bLostFocus:={||IF(oDocPro:oDpLbx=NIL,EVAL(oDocPro:oDOC_CODIGO:bValid),NIL)}

  //oDocPro:oDOC_CODIGO:OnKeyDown:={|o,n| oDocPro:lCodigo:=(n=13),oDocPro:RunWhen()}

  // Campo : DOC_CODMON
  // Uso   : Moneda                                  
  @ 1.6, 06.0 COMBOBOX oDocPro:oDOC_CODMON VAR oDocPro:DOC_CODMON ITEMS oDp:aMonedas;
              VALID EJECUTAR("DPDOCPROVALMON",oDoc);
              WHEN (AccessField("DPDOCPRO","DOC_CODMON",oDocPro:nOption);
                   .AND. oDocPro:nOption!=0 .AND. oDocPro:lPar_SelMon .AND. LEN(oDp:aMonedas)>1 .AND. !Empty(oDocPro:DOC_NUMERO)) SIZE 100,NIL
                   
                  // antes .AND. oDocPro:nOption!=0 .AND. oDocPro:lPar_SelMon) SIZE 100,NIL

  ComboIni(oDocPro:oDOC_CODMON)

  @ 2.6,6  GET oDocPro:oDOC_VALCAM VAR oDocPro:DOC_VALCAM PICTURE oDp:cPictValCam;
           VALID oDocPro:DOCVALCAM();
           WHEN (AccessField("DPDOCPRO","DOC_VALCAM",oDocPro:nOption);
                .AND. oDocPro:nOption!=0);
                .AND. !(LEFT(oDocPro:DOC_CODMON,3)=oDp:cMoneda);
           SIZE 20,10 RIGHT

   oDocPro:oDOC_VALCAM:bKeyDown:={|nKey| IF(nKey=13, oDocPro:DOCVALCAM(.T.) ,NIL )}

/*
  @ 2.6,6  GET oDocPro:oDOC_VALCAM VAR oDocPro:DOC_VALCAM PICTURE oDp:cPictValCam;
           VALID MensajeErr("Valor Debe ser Diferente que 0.00","Valor Inválido",{||oDocPro:DOC_VALCAM<>0});
           WHEN (AccessField("DPDOCPRO","DOC_VALCAM",oDocPro:nOption);
                .AND. oDocPro:nOption!=0);
                .AND. !(LEFT(oDocPro:DOC_CODMON,3)=oDp:cMoneda);
           SIZE 20,10 RIGHT

*/
oDocPro:nPar_Desc:=100
// ANTES          VALID EJECUTAR("DPDOCPROVALCAM",oDocPro:DOC_VALCAM,oDoc);

  @ 2.6,6 GET oDocPro:oDOC_DCTO VAR oDocPro:DOC_DCTO PICTURE "999.99";
          VALID EJECUTAR("DPDOCCLIVALDES",oDocPro:DOC_DCTO,oDoc);
          WHEN (AccessField("DPDOCPRO","DOC_DCTO",oDocPro:nOption);
                .AND. oDocPro:nOption!=0.AND. oDocPro:nPar_Desc>0 .AND. EMPTY(oDocPro:DOC_DESCCO));
          SIZE 20,10 RIGHT

  @ 2.6,13 GET oDocPro:oDOC_CONDIC VAR oDocPro:DOC_CONDIC VALID .T.;
           WHEN (AccessField("DPDOCPRO","DOC_CONDIC",oDocPro:nOption);
                .AND. oDocPro:nOption!=0 .AND. oDocPro:lPar_Cond);
           SIZE 80,10 

  @ 2.6,26.5 GET oDocPro:oDOC_PLAZO  VAR oDocPro:DOC_PLAZO PICT "999";
             VALID MensajeErr("Plazo no Permitido",NIL,{||oDocPro:DOC_PLAZO<=oDocPro:nPar_MaxDias});
             WHEN (AccessField("DPDOCPRO","DOC_PLAZO",oDocPro:nOption);
                  .AND. oDocPro:nOption!=0 .AND. oDocPro:nPar_MaxDias>0);
             SIZE 18,10 RIGHT

  @ 0,17 SAY oDocPro:oProNombre;
         PROMPT SQLGET("DPPROVEEDOR","PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",oDocPro:DOC_CODIGO))

  @ 0,43 GET oDocPro:oDOC_NUMERO VAR oDocPro:DOC_NUMERO;
         VALID oDocPro:VALNUMERO();
         WHEN (AccessField("DPDOCPRO","DOC_NUMERO",oDocPro:nOption);
              .AND. oDocPro:nOption!=0  .AND. oDocPro:lPar_EditNum .AND. oDocPro:lCodigo);
               SIZE 35,10

 // se inactivo ya que al darle enter en DOC_NUMERO se copiaba el mismo en DOC_PLAZO TJ
 // oDocPro:oDOC_NUMERO:bLostFocus:={||EVAL(oDocPro:oDOC_NUMERO:bValid)} 

/*
  @ 0.9,43 BMPGET oDocPro:oDOC_FECHA  VAR oDocPro:DOC_FECHA  PICTURE "99/99/9999";
           NAME "BITMAPS\Calendar.bmp";
           ACTION LbxDate(oDocPro:oDOC_FECHA ,oDocPro:DOC_FECHA);
           VALID (oDocPro:ISLIBINV() .AND. ;
                  EJECUTAR("DPVALFECHA",oDocPro:DOC_FECHA,.T.,.T.) .AND. ;
                  EJECUTAR("DPDOCPROVALCAM",oDoc));
            WHEN (AccessField("DPDOCMOV","DOC_FECHA",oDocPro:nOption);
                .AND. oDocPro:nOption!=0.AND. oDocPro:lPar_Fecha .AND. oDocPro:lCodigo);
           SIZE 41,10
*/

  @ 0.9,43 BMPGET oDocPro:oDOC_FECHA  VAR oDocPro:DOC_FECHA  PICTURE "99/99/9999";
           NAME "BITMAPS\Calendar.bmp";
           ACTION LbxDate(oDocPro:oDOC_FECHA ,oDocPro:DOC_FECHA);
           VALID (oDocPro:DOCFECHA(.T.),oDocPro:lDocFecha);
           WHEN (AccessField("DPDOCMOV","DOC_FECHA",oDocPro:nOption);
                .AND. oDocPro:nOption!=0.AND. oDocPro:lPar_Fecha .AND. oDocPro:lCodigo);
           SIZE 41,10

  // oDocPro:oDOC_FECHA:bLostFocus:={|| oDocPro:DOCFECHA(.T.) }
  // Solo Documentos Fiscales

  @ 0.0,43 GET oDocPro:oDOC_NUMFIS VAR oDocPro:DOC_NUMFIS;
           VALID oDocPro:DOCNUMFIS();
           WHEN (AccessField("DPDOCPRO","DOC_NUMFIS",oDocPro:nOption);
                  .AND. oDocPro:nOption!=0 .AND. oDocPro:lPar_LibCom .AND. oDocPro:DOC_ORIGEN<>"I" .AND. oDocPro:lCodigo);
           SIZE 35,10
//ENDIF

  @ 1.5,57 SAY oDocPro:oEstado PROMPT EJECUTAR("DPDOCPROEDO",oDocPro:DOC_CODSUC,oDocPro:cTipDoc,oDocPro:DOC_CODIGO,;
                                      oDocPro:DOC_NUMERO,;
                                      NIL,oDocPro:DOC_CXP,oDocPro:DOC_NETO,oDoc)

  @ 0.1,50 SAY oDocPro:oSayFiscal PROMPT "#Fiscal:" RIGHT
  @ 2.5,20 SAY ""   RIGHT
  @ 2.5,20 SAY ""   RIGHT

  SETFOLDER( 2)

  oDocPro:oScroll:=oDocPro:SCROLLGET("DPDOCPRO",cFileScg,cExcluye)

  IF oDocPro:IsDef("oScroll")
    oDocPro:oScroll:SetEdit(.F.)
  ENDIF

  //IIF(Empty(oDp:cModeVideo),oDocPro:oScroll:SetColSize(180,250,298),
  //oDocPro:oScroll:SetColSize(230,290,320))

//  oDocPro:oScroll:SetColorHead(16384 ,11266812,oFontB) 
  oDocPro:oScroll:SetColorHead(CLR_BLACK ,oDp:nGrid_ClrPaneH,oFontB) 
  oDocPro:oScroll:SetColSize(200,250,290+186)
  oDocPro:oScroll:SetColor(oDp:nClrPane1,CLR_GREEN,1,oDp:nClrPane2,oFontB) 
  oDocPro:oScroll:SetColor(oDp:nClrPane1,0,2,oDp:nClrPane2,oFont) 
  oDocPro:oScroll:SetColor(oDp:nClrPane1,0,3,oDp:nClrPane2,oFontB)

  SETFOLDER( 0)

  @ 0,50 SAY oDocPro:oProducto PROMPT SPACE(40)
//  @ 1, 1.0 GROUP oDocPro:oGroup TO 10,10 PROMPT "Totales"

  @ 12,50 SAY oDocPro:oNeto PROMPT TRAN(oDocPro:DOC_NETO,"999,999,999,999,999.99") RIGHT

  @ 1,1 SAY oDocPro:oIVATEXT PROMPT "I.V.A."+IF(oDocPro:DOC_IVAREB>0,"-"+LSTR(oDocPro:DOC_IVAREB)+"%","") RIGHT SIZE 80,12

  @ 12,50 SAY oDocPro:oIVA      PROMPT TRAN(oDocPro:nIva  ,"99,999,999,999.99") RIGHT

  @ 14,0 SAY oSayRef PROMPT "Neto" RIGHT SIZE 42,12 FONT oFontB RIGHT

  @ 14,50 SAY oDocPro:oDOCBASNET PROMPT TRAN(oDocPro:DOC_BASNET ,"99,999,999,999.99") RIGHT


  SayAction(oSayRef,{||oDocPro:TOTALIZAR()})

  @ 14,0 SAY oSayRef PROMPT "Bruto" RIGHT SIZE 42,12 FONT oFontB RIGHT

  cSql :=" SELECT "+SELECTFROM("DPMOVINV",.F.)+;
         " ,IF(MOV_NUMMEM>0 AND MEM_DESCRI<>'',MEM_DESCRI,INV_DESCRI) AS INV_DESCRI, "+;
         " MOV_PRECIO-(MOV_PRECIO*(MOV_DESCUE/100)) AS MOV_MTODES, "+;
         " MOV_COSTO/DOC_VALCAM AS MOV_COSDIV,MOV_MTODIV "+;
         " FROM DPMOVINV "+;
         " INNER JOIN DPDOCPRO  ON MOV_CODSUC=DOC_CODSUC AND MOV_TIPDOC=DOC_TIPDOC AND MOV_CODCTA=DOC_CODIGO AND MOV_DOCUME=DOC_NUMERO AND DOC_TIPTRA"+GetWhere("=","D")+;
         " INNER JOIN DPINV     ON MOV_CODIGO=INV_CODIGO "+;
         " LEFT  JOIN DPMEMO    ON MOV_NUMMEM=MEM_NUMERO "

  cScope:="MOV_TIPDOC"+GetWhere("=",cTipDoc)+" AND MOV_APLORG='C' AND MOV_INVACT=1"

  oGrid:=oDocPro:GridEdit("DPMOVINV" ,"DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO" , "MOV_CODSUC,MOV_TIPDOC,MOV_CODCTA,MOV_DOCUME",cSql,cScope," GROUP BY MOV_ITEM ORDER BY MOV_ITEM " ) 

//oGrid:=oDocPro:GridEdit( "DPMOVINV" ,"DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO" , "MOV_CODSUC,MOV_TIPDOC,MOV_DOCUME" , cSql , cScope ," GROUP BY MOV_ITEM ORDER BY MOV_ITEM " )

  oGrid:cMetodo :="P"
  oGrid:cScript := "DPDOCPRO"
  oGrid:aSize   := {177+10,4,890+100,230+60}

  IF oDocPro:lAutoSize
     oGrid:aSize      := {177+10,4,aCoors[4]-30,330-34}
  ENDIF

  oGrid:lPesado :=lPesado 

//  oGrid:nClrPane2:=14612478
//  oGrid:nClrPane1:=15399935
//  oGrid:oItem    :=NIL
  oGrid:lViewArray:=.F. // JN 18/05/2016 Visualizar Arreglo
  oGrid:lMulti     :=.F. // Unidad de Medida Variable

  oGrid:nClrPane1   :=oDp:nClrPane1 // 16775408
  oGrid:nClrPane2   :=oDp:nClrPane2 // 16770764
  oGrid:nClrPaneH   :=oDp:nGrid_ClrPaneH
  oGrid:nClrTextH   :=0
  oGrid:nRecSelColor:=oDp:nRecSelColor  // oDp:nLbxClrHeaderPane // 12578047 // 16763283
  oGrid:cItem       :="MOV_ITEM"
  oGrid:cPrimary    :=oGrid:cLinkGrid+","+oGrid:cItem
  oGrid:cKeyAudita  :=oGrid:cPrimary

  oGrid:oFont      :=oFont
  oGrid:oFontH     :=oFontB
  oGrid:bWhen      :="!EMPTY(oDocPro:DOC_CODIGO).AND.!EMPTY(oDocPro:DOC_NUMERO) .AND.  oDocPro:lCodigo "
  oGrid:bValid     :="!EMPTY(oDocPro:DOC_NUMERO)"

  IF cTipDoc="ORC"
    oGrid:bWhen      :="!EMPTY(oDocPro:DOC_CODIGO).AND.!EMPTY(oDocPro:DOC_NUMERO)"
    oGrid:bValid     :=".T."
  ENDIF

  oGrid:cItem      :="MOV_ITEM"
  oGrid:cLoad      :="GRIDLOAD"
  oGrid:cPresave   :="GRIDPRESAVE"
  oGrid:cPostSave  :="GRIDPOSTSAVE" 
  oGrid:cPreDelete :="GRIDPREDELETE"
  oGrid:cPostDelete:="GRIDPOSTDELETE" 
  oGrid:nHeaderLines:=2



  oGrid:SetMemo("MOV_NUMMEM","Descripción Amplia",1,1,100,200)

  IF oDp:nVersion>=5
    oGrid:SetAdjuntos("MOV_FILMAI")
  ENDIF

  oGrid:lHScroll    :=.T.
  oGrid:lTallas     :=.F.
  oGrid:cTallas     :=""
  oGrid:lTotal      :=.T.
  oGrid:aComponentes:={}
  oGrid:cUtiliz     :=""
  oGrid:cRegulado   :="" // Indica si el precio es Regulado
  oGrid:cTipCom     :="" // Tipo de Componente
  oGrid:nPrecio     :=0  // Precio
  oGrid:cFieldAud   :="MOV_REGAUD" // Genera Auditoria de Registros Anulados o Modificados
  oGrid:lUnd_Peso   :=.F.          // Peso es calculado Cant*CxUnd=Peso



//? oGrid:cRegulado,"oGrid:cRegulado"

  oGrid:nLotes      :=0 // Cantidad del Lote
  oGrid:nCostoLote  :=0 // Costo de Lotes
  oGrid:nPrecioLote :=0 // Precio del Lote

  oGrid:AddBtn("IMPORTAR.BMP","Importar","oGrid:nOption=1",;
               [EJECUTAR("DPDOCPROMNUIMP",oDoc)],"IMP")

  oGrid:AddBtn("GRUPOS2.BMP","Grupos","oGrid:nOption=1",;
               [EJECUTAR("GRIDGRUPOS",oGrid)],"GRU")

  oGrid:AddBtn("MARCA2.BMP","Marcas","oGrid:nOption=1",;
               [EJECUTAR("GRIDMARCAS",oGrid)],"MAR")

  oGrid:AddBtn("XFIND2.BMP","Buscar","oGrid:nOption=1",;
               [EJECUTAR("GRIDBUSCAINV",oGrid)],"BUS")


  IF COUNT("DPSUSTITUTOS")>0

     oGrid:AddBtn("SUSTITUTOS2.BMP","Sustitutos","oGrid:nOption=1 .OR. oGrid:nOption=3",;
                  [oGrid:BRSUSTITUTOS()],"SUS",NIL)

  ENDIF


  oGrid:AddBtn("DESCUENTO2.BMP","Descuentos","oGrid:nOption=1 .OR. oGrid:nOption=3 ",;
               [EJECUTAR("DPDOCDESCITEM",oGrid,oGRID:MOV_CANTID*oGRID:MOV_COSTO,oGrid:MOV_CDESC,!oGrid:nOption=0)],"OTR")


  oGrid:cMetodo     :="P"
  oGrid:cAlmacen    :=""
  oGrid:bChange     :='oDocPro:oProducto:SetText(oDocPro:cNameInv+": "+oGrid:INV_DESCRI)'
  oGrid:nMaxDesc    :=0 // Descuento Máximo Según Precios de Venta
  oGrid:cInvDescri  :=SPACE(40)
  oDp:oGrid         :=oGrid
//  oGrid:nClrPaneH   := 11266812 // 4511739
//  oGrid:nRecSelColor:= 11266812 // 4511739
  oGrid:aCodReco    :={}   // decasa
  oGrid:lValExi     :=.T.

  oGrid:nClrPane1   :=16775408
  oGrid:nClrPane2   :=16770764
  oGrid:nClrPaneH   :=oDp:nGrid_ClrPaneH
  oGrid:nClrTextH   :=0
  oGrid:nRecSelColor:=oDp:nRecSelColor  // oDp:nLbxClrHeaderPane // 12578047 // 16763283


  oGrid:lUnd_Peso  :=.F.
  oGrid:nUnd_Margen:=0
  oGrid:nCxUnd     :=0 // Para Multiplicar por Unidad y Obtener el Peso

  // 16384 ,11266812,oFontB

  IF oDefCol:MOV_ITEM_ACTIVO
    oCol:=oGrid:AddCol("MOV_ITEM")
    oCol:cTitle   :="#"+CRLF+"Item"
    oCol:bWhen    :=".F."
    oCol:nWidth   :=50
  ENDIF



  // Renglon Almacen
  IF oDocPro:lPar_Almace .AND. oDocPro:lPar_DocAlm .AND. oDp:nAlmacen>1 .AND. oDefCol:MOV_CODALM_ACTIVO

    oCol:=oGrid:AddCol("MOV_CODALM")
//  oCol:cTitle   :="Alm."
    oCol:cTitle   :=oDefCol:MOV_CODALM_TITLE // "Cód"+CRLF+"Alm."
    oCol:bValid   :={||oGrid:VMOV_CODALM(oGrid:MOV_CODALM)}
    oCol:cMsgValid:="Almacén no Existe"
    oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),34,40)
    oCol:cListBox :="DPALMACEN.LBX"
    oCol:nEditType:=EDIT_GET_BUTTON
  ENDIF

  // Campo Código
  oCol:=oGrid:AddCol("MOV_CODIGO")
  oCol:cTitle   :="Código"
  oCol:bValid   :={||oGrid:VMOV_CODIGO(oGrid:MOV_CODIGO)}
  oCol:cMsgValid:="Producto no Existe"
  oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),110,120)
  oCol:cListBox :="DPINV.LBX"
  oCol:lItems   :=.T.
  oCol:cWhereListBox:="LEFT(INV_APLICA,1)"+GetWhere("=","C")+" OR LEFT(INV_APLICA,1)"+GetWhere("=","T")
  oCol:bPostEdit:='oGrid:ColCalc("INV_DESCRI")' 
  oCol:nEditType:=EDIT_GET_BUTTON
  oCol:bRunOff  :={||EJECUTAR("DPINV",0,oGrid:MOV_CODIGO)}

  IF oDefCol:MOV_ASOTIP_ACTIVO

    oCol:=oGrid:AddCol("MOV_ASOTIP")
    oCol:cTitle   :=oDefCol:MOV_ASOTIP_TITLE // "Org"
    oCol:bWhen    :=".F."
    oCol:nWidth   :=40
    oCol:bRunOff  :={||oGrid:VERDOCORG()}
    oCol:bRunOff  :={||oGrid:VERDOCORG()}

  ENDIF

  IF oDefCol:MOV_ASODOC_ACTIVO

    oCol:=oGrid:AddCol("MOV_ASODOC")
    oCol:cTitle   :=oDefCol:MOV_ASODOC_TITLE // "Número"+CRLF+"Doc/Org"
    oCol:bWhen    :=".F."
    oCol:nWidth   :=75
    
  ENDIF

  // Renglon Descripción
  oCol:=oGrid:AddCol("INV_DESCRI")
  oCol:cTitle:="Descripción"
//oCol:bCalc :={||SQLGET("DPINV","INV_DESCRI","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))}
  oCol:bCalc :={||oGrid:cInvDescri}
  oCol:bWhen :=".F."
  oCol:nWidth:=IIF(Empty(oDp:cModeVideo),243,257)+IIF(oDocPro:lPar_Almace .AND. oDocPro:lPar_DocAlm .AND. oDp:nAlmacen>1,-4,34)+IIF(oDocPro:nPar_ItemDesc >0,0,30)
  oCol:bValid:={||oGrid:VINV_DESCRI(oGrid:INV_DESCRI)}

//  IF oGrid:lPesado
//     oCol:nWidth:=oCol:nWidth-60
//  ENDIF

  // Renglon Medida


  oCol:=oGrid:AddCol("MOV_UNDMED")
  oCol:cTitle    :=FIELDLABEL("DPMOVINV","MOV_UNDMED")
  oCol:nWidth    :=IIF(Empty(oDp:cModeVideo),50,60)
  oCol:aItems    :={||oGrid:BuildUndMed(.T.)}
  oCol:aItemsData:={||oGrid:BuildUndMed(.F.)}
  oCol:bValid    :={||oGrid:VMOV_UNDMED(oGrid:MOV_UNDMED)}
  oCol:bWhen    :="!EMPTY(oGrid:MOV_CODIGO) .AND. oGrid:cMetodo<>'S' .AND. !oGrid:lTallas"
  oCol:bPostEdit:={|| oGrid:SET("MOV_UNDMED" , oGrid:MOV_UNDMED ,.T.) } 


  // 15/08/2023
  IF oDefCol:MOV_TIPCAR_ACTIVO

     oCol:=oGrid:AddCol("MOV_TIPCAR")
     oCol:cTitle    :=oDefCol:MOV_TIPCAR_TITLE 
     oCol:nWidth    :=90
     oCol:bWhen     :=".T." // [(oGrid:cMetodo="L" .OR. oGrid:cMetodo="C")]
     oCol:bValid    :={||oGrid:VMOV_TIPCAR()}
     oCol:lRepeat   :=.F.

  ENDIF

  // 15/08/2023
  IF oDefCol:MOV_NOMCAR_ACTIVO

     oCol:=oGrid:AddCol("MOV_NOMCAR")
     oCol:cTitle    :=oDefCol:MOV_NOMCAR_TITLE 
     oCol:nWidth    :=90
     oCol:bWhen     :=".T." 
     oCol:lRepeat   :=.F.
     oCol:bValid    :={||oGrid:VMOV_NOMCAR()}

  ENDIF


  // 15/08/2023
  IF oDp:nInvLotes>0 .AND. (oDoc:nPar_InvFis<>0 .OR. oDoc:nPar_InvLog<>0 .OR. oDoc:nPar_InvCon<>0) .AND. oDefCol:MOV_LOTE_ACTIVO

    // Informativo
    oCol:=oGrid:AddCol("MOV_LOTE")
    oCol:cTitle    :=oDefCol:MOV_LOTE_TITLE // FIELDLABEL("DPMOVINV","MOV_LOTE")
    oCol:nWidth    :=80
    //  oCol:bWhen     :=".F."
    oCol:bWhen    :=[(oGrid:cMetodo="L" .OR. oGrid:cMetodo="C")]
 
  ELSE

    // 15/08/2023
    IF oDefCol:MOV_LOTE_ACTIVO

      oCol:=oGrid:AddCol("MOV_LOTE")
      oCol:cTitle    :=oDefCol:MOV_LOTE_TITLE 
      oCol:nWidth    :=80
      //  oCol:bWhen     :=".F."
      oCol:bWhen    :=[(oGrid:cMetodo="L" .OR. oGrid:cMetodo="C")]

    ENDIF

  ENDIF

  // 27/12/2023 fFECHA DEL LOTE
  IF oDefCol:MOV_FCHVEN_ACTIVO

    oCol:=oGrid:AddCol("MOV_FCHVEN")
    oCol:cTitle:=oDefCol:MOV_FCHVEN_TITLE
    oCol:bWhen :=".T."
    oCol:nWidth:=70
    oCol:bValid:={||.T.}
    oCol:nEditType:=EDIT_GET_BUTTON
    oCol:bAction  :={||EJECUTAR("GRIDFECHA",oGrid)}

  ENDIF


  IF oDefCol:MOV_PESO_ACTIVO
     oGrid:lPesado:=.T.
  ENDIF

  IF lPesado .AND. oDocPro:lMoneta .AND. oDefCol:MOV_PESO_ACTIVO .AND. oDefCol:PESO_PRIMERO

    // Valida si la Unidad de Medida es Variable (Utiliza Peso)
    oCol:=oGrid:AddCol("MOV_PESO")
    oCol:cTitle    :=oDefCol:MOV_PESO_TITLE
    oCol:cPicture  := oDp:cPictPeso
    oCol:nWidth    :=80
    oCol:bValid   :={||oGrid:VMOV_PESO()}


    IF !Empty(oDefCol:MOV_PESO_PICTURE)
      oCol:cPicture:=oDefCol:MOV_PESO_PICTURE
    ENDIF

    // oCol:bRunOff  :={|| oGrid:BRDETMOVSERDOC()}
    oCol:lTotal   :=.T.

  ENDIF


  // Renglon Cantidad
  oCol:=oGrid:AddCol("MOV_CANTID")
  oCol:cTitle    :=FIELDLABEL("DPMOVINV","MOV_CANTID")


  IF oDocPro:nPar_InvFis<>0
    oCol:bWhen:="!EMPTY(oGrid:MOV_CODIGO) .AND. oGrid:cMetodo<>'S' .AND. !oGrid:lTallas"
  ELSE
    oCol:bWhen:="!EMPTY(oGrid:MOV_CODIGO) .AND. !oGrid:lTallas"
  ENDIF
  oCol:bValid   :={||oGrid:VMOV_CANTID()}
  oCol:cMsgValid:="Cantidad debe ser Mayor que Cero"
  oCol:cPicture := oDp:cPictCanUnd  // FIELDPICTURE("DPMOVINV","MOV_CANTID",.T.)
  oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")' 
  oCol:nWidth:=IIF(Empty(oDp:cModeVideo),55,70)

  // CantxUnd
  IF lPesado .AND. oDefCol:MOV_CXUND_ACTIVO

    oCol:=oGrid:AddCol("MOV_CXUND")
    //oCol:cTitle :=FIELDLABEL("DPMOVINV","MOV_CXUND")
    oCol:cTitle    :=oDefCol:MOV_CXUND_TITLE
    oCol:nWidth :=60
    oCol:bWhen  :="oGrid:lPesado"
    oCol:bValid   :={||oGrid:VMOV_CXUND()}

    IF !Empty(oDefCol:MOV_CXUND_PICTURE)
      oCol:cPicture:=oDefCol:MOV_CXUND_PICTURE
    ENDIF

  ENDIF

  IF lPesado .AND. oDocPro:lMoneta .AND. oDefCol:MOV_PESO_ACTIVO .AND. !oDefCol:PESO_PRIMERO

    // Valida si la Unidad de Medida es Variable (Utiliza Peso)
    oCol:=oGrid:AddCol("MOV_PESO")
    oCol:cTitle    :=oDefCol:MOV_PESO_TITLE
    oCol:cPicture  := oDp:cPictPeso
    oCol:nWidth    :=80
    oCol:bValid   :={||oGrid:VMOV_PESO()}


    IF !Empty(oDefCol:MOV_PESO_PICTURE)
      oCol:cPicture:=oDefCol:MOV_PESO_PICTURE
    ENDIF

    // oCol:bRunOff  :={|| oGrid:BRDETMOVSERDOC()}
    oCol:lTotal   :=.T.

  ENDIF

/*
  // 15/08/2023 debe solicitarse despues de la unidad de medida
  IF oDp:nInvLotes>0 .AND. (oDoc:nPar_InvFis<>0 .OR. oDoc:nPar_InvLog<>0 .OR. oDoc:nPar_InvCon<>0) .AND. oDefCol:MOV_LOTE_ACTIVO

    // Informativo
    oCol:=oGrid:AddCol("MOV_LOTE")
    oCol:cTitle    :=oDefCol:MOV_LOTE_TITLE // FIELDLABEL("DPMOVINV","MOV_LOTE")
    oCol:nWidth    :=80
    //  oCol:bWhen     :=".F."
    oCol:bWhen    :=[(oGrid:cMetodo="L" .OR. oGrid:cMetodo="C")]
 
  ELSE

    // 15/08/2023
    IF oDefCol:MOV_LOTE_ACTIVO

      oCol:=oGrid:AddCol("MOV_LOTE")
      oCol:cTitle    :=oDefCol:MOV_LOTE_TITLE 
      oCol:nWidth    :=80
      //  oCol:bWhen     :=".F."
      oCol:bWhen    :=[(oGrid:cMetodo="L" .OR. oGrid:cMetodo="C")]

    ENDIF

  ENDIF
*/
 
  // Renglon Costo
  oCol:=oGrid:AddCol("MOV_COSTO")
  oCol:cTitle    :=FIELDLABEL("DPMOVINV","MOV_COSTO")

  oCol:bWhen    :="!EMPTY(oGrid:MOV_CANTID) .AND. oDocPro:lPar_Precio .AND. oGrid:nCostoLote=0"
  oCol:bValid   :="oGrid:VMOV_COSTO()"
  oCol:cPicture :=oDp:cPictCosto
  oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")' 
  oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),85,110)

  IF !Empty(oDefCol:MOV_COSTO_PICTURE)
     oCol:cPicture:=oDefCol:MOV_COSTO_PICTURE
  ENDIF

  IF oDefCol:MOV_DESCUE_ACTIVO

    oCol:=oGrid:AddCol("MOV_DESCUE")
    oCol:cTitle   :="%D."
    //oCol:bWhen    :="!EMPTY(oGrid:MOV_CODIGO).AND. oDocPro:nPar_ItemDesc>0 .AND. EMPTY(oGrid:MOV_CDESC)"
    // 11/07/2022
    oCol:bWhen    :=".T." // !EMPTY(oGrid:MOV_CODIGO).AND. oDocPro:nPar_ItemDesc>0 .AND. EMPTY(oGrid:MOV_CDESC)"
    oCol:bValid   :={||oGrid:VMOV_DESCUE()}
    oCol:cMsgValid:="Descuento Debe ser Positivo"
    oCol:cPicture :="999.99"
    oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")' 
    oCol:nWidth:=IIF(Empty(oDp:cModeVideo),40,50)

  ENDIF

  nWidth:=oGrid:CalcWidth(30,0)

  IF nWidth>100 .AND. oDefCol:MOV_MTODES_ACTIVO
     oCol:=oGrid:InsertCol("MOV_MTODES",NIL,NIL,"MOV_DESCUE")
     oCol:cTitle   :="Costo con"+CRLF+"Descuento"
     oCol:cPicture :="999,999,999,999.99"
     oCol:bWhen    :=".F."
     oCol:nWidth   :=100
  ENDIF

  nWidth:=oGrid:CalcWidth(80,0)

  IF nWidth>=80 .AND. !Empty(oGrid:GetCol("MOV_MTODES",.F.)) .AND. oDefCol:MOV_TIPIVA_ACTIVO
      oCol:=oGrid:InsertCol("MOV_TIPIVA",NIL,NIL,"MOV_DESCUE")
      oCol:cTitle   :="Tipo"+CRLF+"IVA"
      oCol:bWhen    :=".F."
      oCol:nWidth   :=40
  ENDIF

  nWidth:=oGrid:CalcWidth(80,0)

  IF nWidth>=80 .AND. !Empty(oGrid:GetCol("MOV_TIPIVA",.F.)) .AND. oDefCol:MOV_TIPIVA_ACTIVO
     oCol:=oGrid:InsertCol("MOV_IVA",NIL,NIL,"MOV_TIPIVA")
     oCol:cTitle   :="%"+CRLF+"IVA"
     oCol:bWhen    :=".F."
     oCol:nWidth   :=60
  ENDIF



// Precio en Divisas
  IF oDefCol:MOV_COSDIV_ACTIVO

    oCol:=oGrid:AddCol("MOV_COSDIV")
    oCol:cTitle   :=oDefCol:MOV_COSDIV_TITLE 
    oCol:bWhen    :="!EMPTY(oGrid:MOV_CANTID) .AND. oDocPro:lPar_Precio .AND. oGrid:nCostoLote=0"
    oCol:bValid   :="oGrid:VMOV_COSDIV()"
    oCol:cPicture :=oDp:cPictPrecio
    oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")'
    oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),85,105+5)

    IF !Empty(oDefCol:MOV_COSDIV_PICTURE)
       oCol:cPicture:=oDefCol:MOV_COSDIV_PICTURE
    ENDIF

  ENDIF

 
  //Se cambio oCol:bWhen:="!EMPTY(oGrid:cRegulado)" por oCol:bWhen    :="oGrid:cRegulado='S'"
  //ya que como estaba era indistinto el valor que tuviese INV_PREREG requiere precio regulado S o N. TJ
  
  // Renglon Precio de Venta
  //

  IF oDefCol:MOV_PRECIO_ACTIVO
    oCol:=oGrid:AddCol("MOV_PRECIO")
    oCol:cTitle    :=FIELDLABEL("DPMOVINV","MOV_PRECIO")
    oCol:bWhen    :=".T." //  oGrid:cRegulado='S'"
    oCol:bValid   :="oGrid:VMOV_PRECIO()"
    oCol:cPicture :=oDp:cPictCosto
    oCol:bPostEdit:='oGrid:ColCalc("MOV_TOTAL")' 
    oCol:nWidth   :=110

    IF !Empty(oDefCol:MOV_PRECIO_PICTURE)
     oCol:cPicture:=oDefCol:MOV_PRECIO_PICTURE
    ENDIF

  ENDIF



  // Renglon Total
  oCol:=oGrid:AddCol("MOV_TOTAL")
  oCol:cTitle    :=FIELDLABEL("DPMOVINV","MOV_TOTAL")
  oCol:cPicture :=oDp:cPictTotRen // FIELDPICTURE("DPMOVINV","MOV_TOTAL",.T.)
//oCol:bCalc    :={|nTotal|nTotal:=IF(oGrid:lPesado,oGRID:MOV_CXUND,oGRID:MOV_CANTID*IIF(!oGrid:lMulti,1,oGRID:MOV_CXUND))*oGRID:MOV_COSTO,nTotal-PORCEN(nTotal,oGrid:MOV_DESCUE)}
  oCol:bCalc    :={|nTotal|nTotal:=IF(oGrid:lPesado,oGRID:MOV_PESO,oGRID:MOV_CANTID*IIF(!oGrid:lMulti,1,oGRID:MOV_PESO))*oGRID:MOV_COSTO,nTotal-PORCEN(nTotal,oGrid:MOV_DESCUE)}


  oCol:bWhen    :={||oDocPro:lPar_TotRen .AND. !EMPTY(oGrid:MOV_COSTO)}
  oCol:lTotal   :=.T.
  oCol:nWidth   :=IIF(Empty(oDp:cModeVideo),96,117)+IIF(oDocPro:nPar_ItemDesc >0,0,12)
  oCol:bValid   :={||oGrid:VMOV_TOTAL(oGrid:MOV_TOTAL)}

  oGrid:oSayOpc   :=oDocPro:oProducto

  /*
  // Total Divisa
  */

  IF oDefCol:MOV_MTODIV_ACTIVO

    oCol:bPostEdit:='oGrid:ColCalc("MOV_MTODIV")'

    oCol:=oGrid:AddCol("MOV_MTODIV")

    oCol:cTitle   :=oDefCol:MOV_MTODIV_TITLE
    oCol:cPicture :=oDp:cPictTotRen // FIELDPICTURE("DPMOVINV","MOV_MTODIV",.T.)

    // oCol:bCalc    :={|nTotal|nTotal:=oGRID:MOV_TOTAL/oDocPro:DOC_VALCAM}
    oCol:bCalc    :={|nTotal|nTotal:=IF(oGrid:lPesado,oGRID:MOV_PESO,oGRID:MOV_CANTID*IIF(!oGrid:lMulti,1,oGRID:MOV_PESO))*oGRID:MOV_COSDIV,nTotal-PORCEN(nTotal,oGrid:MOV_DESCUE)}
    oCol:bWhen    :={||.F.} //  oDocPro:lPar_TotRen .OR. (ALLTRIM(oGrid:MOV_CODIGO)==[-] .AND. oGrid:MOV_DESCUE=0)}

    // JN 8/11/2016 .AND. !EMPTY(oGrid:MOV_PRECIO)) .OR. (oGrid:lDcto .AND. oGrid:MOV_DESCUE=0) .OR. oGrid:lTransp .OR. oGrid:lComent}
    oCol:lTotal   :=.T.
    oCol:nWidth   :=120
    oCol:bValid   :={||oGrid:VMOV_MTODIV(oGrid:MOV_MTODIV)}

    IF !Empty(oDefCol:MOV_MTODIV_PICTURE)
      oCol:cPicture:=oDefCol:MOV_MTODIV_PICTURE
    ENDIF

  ENDIF

  oDocPro:Activate({||oDocPro:DOCPROINI()})

  IF !oDocPro:lPar_LibCom
    oDocPro:oDOC_NUMFIS:Hide()
    oDocPro:oSayFiscal:Hide()
  ENDIF
 
  EJECUTAR("FRMMOVEDOWN",oDocPro:oIVA,oDocPro,{oGrid:oBrw})

RETURN .T.

FUNCTION DOCPROINI()
  LOCAL nClrBlink := CLR_YELLOW   // blinking color
  LOCAL nInterval := 500-100      // blinking interval in milliseconds
  LOCAL nStop     := 0            // blinking limit to stop in milliseconds
  LOCAL oFontB

  DEFINE FONT oFontB NAME "Times New Roman"   SIZE 0, -14 BOLD

  @360, 1 STSAY oDocPro:oSayMsgErr PROMPT oDocPro:cSayMsgErr  OF oDocPro:oDlg PIXEL ;
          COLORS CLR_HRED SIZE 250, 19 FONT oFontB ;
          SHADED;
          BLINK nClrBlink, nInterval, nStop  

  oDocPro:oScroll:oBrw:Gotop()

  oDocPro:oSayMsgErr:Hide()

RETURN .T.

FUNCTION PREDELETE(oForm,lDelete)
   Local lResp:=.T.

   IF !oDocPro:ISLIBINV()
      RETURN .F.
   ENDIF

   EJECUTAR("DPDOCPROPREDEL",oForm,lDelete)
   oForm:cNumDoc:=oForm:cNumero

RETURN .F.

FUNCTION PREGRABAR(oForm,lSave)

   LOCAL lResp:=.T.

   IF !oDocPro:ISLIBINV()
      RETURN .F.
   ENDIF

   IF EVAL(oDocPro:oDOC_NUMERO:bWhen) .AND. !EVAL(oDocPro:oDOC_NUMERO:bValid)
      RETURN .F.
   ENDIF

   IF !Empty(oDocPro:cCenCos)
       oDocPro:SET("DOC_CENCOS",oDocPro:cCenCos,.T.)
   ENDIF

   IF !Empty(oDocPro:DOC_CENCOS)
       oDocPro:SET("DOC_CENCOS",oDp:cCenCos,.T.)
   ENDIF

   // Asume la Fecha del Sistema en el Caso de estar Vacia
   IF Empty(oDocPro:DOC_FCHDEC)
      oDocPro:SET("DOC_FCHDEC",oDp:dFecha)
   ENDIF

   oDocPro:SET("DOC_MTODIV",ROUND(oDocPro:DOC_NETO/oDocPro:DOC_VALCAM,2))

   IF !EJECUTAR("DPDOCPROPREGRA",oForm,lSave)
      Return .F.
   ENDIF

// 08/04/2022 falta IVA en el Disparador
//   IF Empty(oDocPro:DOC_NETO)
//      oDocPro:DOC_NETO:=oGrid:MOV_TOTAL
//   ENDIF
//  ? "pregrabar",oDocPro:DOC_NETO,"NETO"
// oGrid:CancelEdit()
//? "CALCELA GRID EDICION"

RETURN lResp


// PosBorrar
//FUNCTION POSTDELETE()
//RETURN EJECUTAR("DPDOCPROPOSDEL",oDoc)

FUNCTION POSTGRABAR()
   LOCAL oDb:=OpenOdbc(oDp:cDsnData),cWhere

   oDocPro:nMtoIva := oDocPro:nIva
   
   cWhere:="MOV_CODSUC"+GetWhere("=",oDocPro:DOC_CODSUC)+" AND "+;
           "MOV_TIPDOC"+GetWhere("=",oDocPro:DOC_TIPDOC)+" AND "+;
           "MOV_CODCTA"+GetWhere("=",oDocPro:DOC_CODIGO)+" AND "+;
           "MOV_DOCUME"+GetWhere("=",oDocPro:DOC_NUMERO)+" AND MOV_INVACT=1 AND MOV_APLORG"+GetWhere("=","C")

   oDb:Execute("UPDATE DPMOVINV SET MOV_MTODIV=ROUND(MOV_TOTAL/"+LSTR(oDocPro:DOC_VALCAM)+",2) WHERE "+cWhere)

   IF oDocPro:DOC_TIPDOC="FAC" .AND. oDocPro:nOption=1 .AND. oDp:lRTIFCHVEN
      // Fecha de declaración estará vacia y no se puede contabilizar

      cWhere:="DOC_CODSUC"+GetWhere("=",oDocPro:DOC_CODSUC)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",oDocPro:DOC_TIPDOC)+" AND "+;
              "DOC_CODIGO"+GetWhere("=",oDocPro:DOC_CODIGO)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",oDocPro:DOC_NUMERO)+" AND DOC_TIPTRA"+GetWhere("=","D")

      oDocPro:DOC_FCHDEC:=CTOD("")
	 SQLUPDATE("DPDOCPRO","DOC_FCHDEC",oDocPro:DOC_FCHDEC,cWhere)

   ENDIF
   
   EJECUTAR("DPDOCPROPOSGRA",oDoc,oGrid,"GRABAR")

   IF oDocPro:lPar_Presup .AND. oDocPro:lPar_ReqApr

      EJECUTAR("DPDOCPROEXP",NIL,oDocPro:cCodSuc,;
                                 oDocPro:cTipDoc,;
                                 oDocPro:DOC_CODIGO,;
                                 oDocPro:DOC_NUMERO,;
                                 oDocPro:cNomDoc,;
                                 "GRABAR")
   ENDIF

RETURN .T.



// Cancelar
FUNCTION CANCEL()
RETURN EJECUTAR("DPDOCCLICANCEL",oDoc)

// Carga los Datos
FUNCTION LOAD()

   oDocPro:lPELock:=.F.

   IF  oDocPro:nOption=1

     oDocPro:DOC_CENCOS:=oDp:cCenCos
     oDocPro:lCodigo:=.F.
     oDocPro:DOC_IVAREB:=0
     oDocPro:DOC_IVABAS:=0

     IF !Empty(oDocPro:cCenCos)
         oDocPro:SET("DOC_CENCOS",oDocPro:cCenCos,.T.)
     ENDIF

//ViewArray(oDocPro:oScroll:aData)
//  oDocPro:oScroll:PutData( NIL , "uValue", 2 , "DOC_CENCOS",1)
//  oDocPro:oScroll:PutData( NIL , "uValue", 2l ,"DOC_CENCOS",1 , NIL , .F.)




//     oDocPro:lPagEle   :=.F.
   ENDIF

   oDocPro:lPagEle:=(oDocPro:DOC_IVAREB>0)

   oDocPro:oIVATEXT:SetSize(80,14,.T.)
   oDocPro:oIVATEXT:Refresh(.T.)

   IF oDocPro:nOption=3 .AND. !oDocPro:ISLIBINV()
      RETURN .F.
   ENDIF

   oDocPro:RunWhen()

   IF oDocPro:nOption=3 .OR. oDocPro:nOption=1
      AEVAL(oDocPro:oFolder:aDialogs[1]:aControls,{|o,n,c| c:=o:ClassName(),IF("GET"$c,o:SetColor(0,CLR_WHITE),NIL)})
   ENDIF

   IF oDocPro:nOption=3
      oDocPro:lCodigo:=.T.
      EVAL(oDocPro:oDOC_CODIGO:bValid)
   ENDIF

RETURN EJECUTAR("DPDOCPROLOAD",oDoc)

FUNCTION GRIDLOAD()
RETURN EJECUTAR("VTAGRIDLOAD",oGrid)

// Pregrabar
FUNCTION GRIDPRESAVE()
RETURN EJECUTAR("COMGRIDPRESAVE",oGrid)

// Grabación del Item
FUNCTION GRIDPOSTSAVE()
RETURN EJECUTAR("VTAGRIDPOSSAV",oGrid)

// Ejecución Antes de Eliminar el Item
FUNCTION GRIDPREDELETE()
RETURN EJECUTAR("VTAGRIDPREDEL",oGrid)

// PostGrabar
FUNCTION GRIDPOSTDELETE()
  LOCAL lResp:=EJECUTAR("VTAGRIDPOSDEL",oGrid)

  IF lResp .AND. oDocPro:DOC_NETO>0 .AND. oDocPro:lPagEle
     oDocPro:SETIVA10(.T.)
  ENDIF

RETURN lResp

// Código de Almacen
FUNCTION VMOV_CODALM(cCodAlm)
RETURN EJECUTAR("VTAGRIDVALALM",oGrid)

// Valida Código del Producto
FUNCTION VMOV_CODIGO(cCodInv)
  LOCAL lResp

  lResp:=EJECUTAR("COMGRIDVALCOD",oGrid)

  IF lResp
     EJECUTAR("COMGRIDSETTIPCAR",oGrid) // Colocará las Características
  ENDIF

RETURN lResp


// Valida Descripci¢n del Producto
FUNCTION VINV_DESCRI(cCodInv)
RETURN  EJECUTAR("VTAGRIDVALTEX",oGrid)

// Unidad de Medida
FUNCTION VMOV_UNDMED(cUndMed)
RETURN EJECUTAR("VTAGRIDVALUND",oGrid)

// Valida Cantidad
FUNCTION VMOV_CANTID()
  LOCAL lResp

  IF oDocPro:nPar_InvFis<1
    RETURN EJECUTAR("VTAGRIDVALCAN",oGrid)
  ENDIF

RETURN EJECUTAR("COMGRIDVALCAN",oGrid)

// Valida Descuento
FUNCTION VMOV_COSTO()

  oGrid:Set("MOV_COSDIV",oGrid:MOV_COSTO/oDocPro:DOC_VALCAM,.T.)
  oGrid:ColCalc("MOV_TOTAL")
  oGrid:ColCalc("MOV_MTODIV")

RETURN EJECUTAR("COMGRIVALCOS",oGrid)

// Valida Descuento
FUNCTION VMOV_DESCUE()
RETURN EJECUTAR("VTAGRIDVALDES",oGrid)

// Valida Descuento
FUNCTION VMOV_TOTAL()
  Local lResp
  lResp:=EJECUTAR("VTAGRIDVALTOT",oGrid)
RETURN lResp


// Construye las Opciones
FUNCTION BuildUndMed(lData)
  LOCAL aItem:={}

  aItem:=EJECUTAR("INVGETUNDMED",oGrid:MOV_CODIGO,NIL,NIL,oGrid)

  IF (EMPTY(oGrid:MOV_UNDMED).AND.!Empty(aItem)) .OR. LEN(aItem)=1
     oGrid:Set("MOV_UNDMED",aItem[1],.T.)
  ENDIF

RETURN aItem

// Realiza el Trabajo de Depuración
FUNCTION DOCMOVDEPURA()
RETURN .T.

// Debe Generar el Número del Documento
FUNCTION BUILDNUMDOC()
RETURN .T.

FUNCTION PRINTER()
  oDp:cDocNumIni:=oDocPro:DOC_NUMERO
  oDp:cDocNumFin:=oDocPro:DOC_NUMERO

  oDp:cDocCodIni:=oDocPro:DOC_CODIGO
  oDp:cDocCodFin:=oDocPro:DOC_CODIGO

  REPORTE("DOCPRO"+oDocPro:DOC_TIPDOC,"DOC_TIPDOC"+GetWhere("=",oDocPro:DOC_TIPDOC))
  oDp:oGenRep:aCargo:=oDocPro:DOC_TIPDOC
RETURN .T.

// Consulta del Documento
FUNCTION VIEW()
  LOCAL cFile:="DPXBASE\DPDOCPRO"+oDocPro:cTipDoc+"CON"

  IF FILE(cFile+".DXB")
    EJECUTAR("DPDOCPRO"+oDocPro:cTipDoc+"CON",oDocPro)
  ELSE
    EJECUTAR("DPDOCPROFACCON",oDocPro)
  ENDIF

RETURN 

// Consultar Proveedor
FUNCTION CONPROVEEDOR()
  LOCAL lFound:=.F.

  lFound:=!Empty(oDocPro:DOC_CODIGO) .AND. SQLGET("DPPROVEEDOR","PRO_CODIGO","PRO_CODIGO"+GetWhere("=",oDocPro:DOC_CODIGO))=oDocPro:DOC_CODIGO

  IF lFound  
    EJECUTAR("DPPROVEEDORCON",oDoc,oDocPro:DOC_CODIGO)
  ENDIF

  IF !lFound .AND. oDocPro:nOption<>0
    EVAL(oDocPro:oDOC_CODIGO:bAction) // Lista los Clientes
  ENDIF
RETURN .T.

FUNCTION RUNDESC()
  LOCAL nBruto:=0,nDesc

  nBruto:=oDocPro:aGrids[1]:GetTotal("MOV_TOTAL")

  nDesc :=EJECUTAR("DPDOCDESC",oDoc,nBruto,oDocPro:DOC_DESCCO,!oDocPro:nOption=0)
RETURN .T.

// Totalizar
FUNCTION TOTALIZAR(lEdit)
  IF oDocPro:DOC_NETO=0 
    RETURN .F.
  ENDIF

  EJECUTAR("DOCTOTAL",oDoc , .T. ,NIL , NIL , .F.,oDocPro:nOption>0)
RETURN .T.

FUNCTION VALNUMERO()
  LOCAL lResp:=.F.

  IF EMPTY(oDocPro:DOC_NUMERO)
    RETURN .F.
    oDocPro:oDOC_NUMERO:MsgErr("Indique Número, no puede ser Vacio","Número Documento")
    RETURN .F.
  ENDIF

  lResp:=EJECUTAR("DPDOCPROVALNUM",oDoc)

  IF oDocPro:nOption=1 .AND. Empty(oDocPro:DOC_NUMFIS) .AND. lResp
    oDocPro:oDOC_NUMFIS:VarPut(oDocPro:DOC_NUMERO,.T.)
  ENDIF

RETURN lResp

// Se ejecuta desde Comprobante de Pago
FUNCTION UPDATEPAGO()
  IF oDocPro:nOption!=1
    oDocPro:DOC_ESTADO:=MYSQLGET("DPDOCPRO","DOC_ESTADO",oDocPro:cWhere)
  ENDIF

  oDocPro:oEstado:Refresh(.T.)  
RETURN .T.


//-----------------------------------DA----------------------------------------------------------------------
FUNCTION CARGCAMP()

  LOCAL oTable

    oTable:=OpenTable("SELECT PRO_CONDIC, PRO_DIAS FROM DPPROVEEDOR WHERE PRO_CODIGO"+GetWhere("=",oDocPro:DOC_CODIGO))
    
    oDocPro:DOC_CONDIC:=oTable:PRO_CONDIC
    oDocPro:oDOC_CONDIC:Refresh(.T.)
    oDocPro:DOC_PLAZO:=oTable:PRO_DIAS
    oDocPro:oDOC_PLAZO:Refresh(.T.)
    oTable:End()

RETURN .T.
//-----------------------------------DA----------------------------------------------------------------------

/*
// AG20080401. Browser con filtro de fechas
*/
FUNCTION LIST()
  LOCAL cWhere:="",dDesde,dHasta,cTitle
  LOCAL nAt:=ASCAN(oDocPro:aBtn,{|a,n| a[7]="BROWSE"}),oBtnBrw:=IF(nAt>0,oDocPro:aBtn[nAt,1],NIL)

  
  cWhere:="DOC_CODSUC"+GetWhere("=",oDocPro:cCodSuc)+;
          " AND DOC_TIPDOC"+GetWhere("=",oDocPro:DOC_TIPDOC)+;
          " AND DOC_TIPTRA='D' AND DOC_DOCORG='C' "

  dHasta:=SQLGETMAX(oDocPro:cTable,"DOC_FECHA",oDocPro:cScope)
  dDesde:=FCHINIMES(dHasta)

  IF EJECUTAR("CSRANGOFCH","DPDOCPRO",cWhere,"DOC_FECHA",dDesde,dHasta,oBtnBrw,"DOC_FECHA",oDocPro:cTitle)


    cWhere:="DOC_CODSUC"+GetWhere("=",oDocPro:cCodSuc)+;
        " AND DOC_TIPDOC"+GetWhere("=",oDocPro:DOC_TIPDOC)+;
        " AND DOC_TIPTRA='D' AND DOC_DOCORG='C' "+;
        " AND (DOC_FECHA"+GetWhere(">=",oDp:dFchIniDoc)+;
        " AND DOC_FECHA"+GetWhere("<=",oDp:dFchFinDoc)+")"

    cTitle:="<"+DTOC(oDp:dFchIniDoc)+" - "+DTOC(oDp:dFchFinDoc)+">"

//  oDocPro:ListBrw(cWhere,"DPDOCPRO"+oDocPro:DOC_TIPDOC+oDp:cModeVideo+".BRW")
    oDocPro:ListBrw(cWhere,oDocPro:cFileBrw,"Listado de "+oDocPro:cTitle+" "+cTitle)

  ENDIF

RETURN .F.

FUNCTION VALCODPRO(cCodigo)
  LOCAL bLostFocus:=oDocPro:oDOC_CODIGO:bLostFocus
  LOCAL cWherePro,nCant,cCodigo

  oDocPro:lCodigo:=.T.

  IF .T. 

      cWherePro:="PRO_CODIGO LIKE "+GetWhere("","%"+ALLTRIM(oDocPro:DOC_CODIGO)+"%")
      cWherePro:=cWherePro+" OR "+EJECUTAR("GETWHERELIKE","DPPROVEEDOR","PRO_NOMBRE",oDocPro:DOC_CODIGO,"PRO_CODIGO")

      nCant  := COUNT("DPPROVEEDOR",cWherePro)
      cCodigo:=""

      IF nCant=1

         cCodigo:=SQLGET("DPPROVEEDOR","PRO_CODIGO",cWherePro)
         oDocPro:oDOC_CODIGO:VarPut(cCodigo,.T.)
         oDocPro:DOC_CODIGO:=cCodigo
         oDocPro:oDOC_CODIGO:KeyBoard(13)

      ENDIF

      IF Empty(cCodigo) .AND. nCant>1

         cCodigo:=EJECUTAR("REPBDLIST","DPPROVEEDOR","PRO_CODIGO,PRO_NOMBRE",.F.,cWherePro,NIL,NIL,oDocPro:DOC_CODIGO,NIL,NIL,"PRO_CODIGO",oDocPro:oDOC_CODIGO)

         IF !Empty(cCodigo) .AND. ISSQLFIND("DPPROVEEDOR","PRO_CODIGO"+GetWhere("=",cCodigo))
           oDocPro:oDOC_CODIGO:VarPut(cCodigo,.T.)
           oDocPro:DOC_CODIGO:=cCodigo
         ENDIF

      ELSE

         cRif:=cCodigo

      ENDIF

      IF Empty(cCodigo) .AND. !EJECUTAR("DPCREAPROVEE",oDocPro:oDOC_CODIGO,oDocPro:DOC_CODIGO)
         RETURN .F.
      ENDIF

      IF !ISSQLFIND("DPPROVEEDOR","PRO_CODIGO"+GetWhere("=",oDocPro:DOC_CODIGO))
         RETURN .F.
      ENDIF

   ENDIF




  oDocPro:oProNombre:Refresh(.T.)

  IF !ISSQLFIND("DPPROVEEDOR","PRO_CODIGO"+GetWhere("=",oDocPro:DOC_CODIGO))

//    ? oDocPro:oDpLbx:ClassName(),"VALCODPRO"

    IF ValType(oDocPro:oDpLbx)="O" .AND. oDocPro:oDpLbx:oWnd:hWnd=0 
      oDocPro:oDpLbx:=NIL
    ENDIF

    IF oDocPro:oDpLbx=NIL
       oDocPro:oDOC_CODIGO:KeyBoard(VK_F6)
    ENDIF

    RETURN .F.

  ENDIF

  oDocPro:bLostFocus:={||NIL}


  // Toma los datos del proveedor
  EJECUTAR("DPDOCPROVALPRO",oDocPro:oDOC_CODIGO,oDoc)

  COMBOINI(oDoc:oDOC_CODMON)         // 11/11/2022
  EVAL(oDoc:oDOC_CODMON:bValid)
  EJECUTAR("DPDOCPROVALCAM",oDocPro) // 11/11/2022 Asigna el valor cambiario

  IF !EJECUTAR("DPCEROPROV",oDocPro:DOC_CODIGO,oDocPro:oDOC_CODIGO) .AND.;
               oDocPro:SeekTable("DPPROVEEDOR",oDocPro:oDOC_CODIGO,"PRO_CODIGO",NIL,"PRO_NOMBRE",oDocPro:oProNombre);
               .AND. EJECUTAR("DPDOCPROVALPRO",oDocPro:oDOC_CODIGO,oDoc)

     oDocPro:lCodigo:=.F.

  ENDIF

  oDocPro:lCodigo:=.T.
  oDocPro:oProNombre:Refresh(.T.)

//  oDocPro:RUNWHEN()

  // Compras con Derecho a Credito Fiscal, según proveedor JN 29/02/2016, 
  oDocPro:DOC_CREFIS:=(SQLGET("DPPROVEEDOR","PRO_CREFIS","PRO_CODIGO"+GetWhere("=",oDocPro:DOC_CODIGO))="S")

  CursorArrow()
  IF oDocPro:lCodigo
     DPFOCUS(oDocPro:oDOC_NUMERO)
  ENDIF


  oDocPro:oDOC_CODIGO:oJump:=oDocPro:oDOC_NUMERO
  oDocPro:oDOC_NUMERO:ForWhen(.T.)
 
  oDocPro:RUNWHEN()

  // SysRefresh(.T.)
  oDocPro:oDOC_CODIGO:bLostFocus:=bLostFocus // {||EVAL(oDocPro:oDOC_CODIGO:bValid)}

RETURN oDocPro:lCodigo

/*
// Refrescar los Controles
*/
FUNCTION RUNWHEN()
  LOCAL aControl:={oDocPro:oDOC_NUMERO,oDocPro:oDOC_FECHA,oDocPro:oDOC_NUMFIS}

  IF !oDocPro:lView
     AEVAL(aControl,{|o| o:ForWhen(.T.)})
  ENDIF

RETURN .T.

/*
// Valida el Precio de Venta no debe ser menor al costo
*/
FUNCTION VMOV_PRECIO()
RETURN .T.

FUNCTION DOCNUMFIS()
   LOCAL lResp:=.F.

   IF oDoc:lPar_Zero .AND. oDoc:nPar_Len>1 .AND. ISALLDIGIT(oDoc:DOC_NUMFIS)
      oDoc:DOC_NUMFIS:=STRZERO(VAL(oDoc:DOC_NUMFIS),oDoc:nPar_Len)
      oDoc:oDOC_NUMFIS:VarPut(oDoc:DOC_NUMFIS,.T.)
   ENDIF

   lResp:=EJECUTAR("DPDOCPROVALFIS",oDoc)

RETURN .T.

/*
// Valida libron de Inventarios JN 26/07/2016
*/
FUNCTION ISLIBINV()
    LOCAL lIsLib:=.F.
    LOCAL cText:=""

    // Documento no utiliza inventario Contable
    IF oDocPro:nPar_InvCon=0
       RETURN .T.
    ENDIF

    cText:=IF(oDocPro:nOption=1,oDocPro:cIncluir  ,cText)
    cText:=IF(oDocPro:nOption=2,oDocPro:cConsultar,cText)
    cText:=IF(oDocPro:nOption=3,oDocPro:cModificar,cText)
    cText:=IF(oDocPro:nOption=0,oDocPro:cEliminar ,cText)

    lIsLib:=EJECUTAR("ISLIBINV",oDocPro:DOC_FECHA)

    IF lIsLib .AND. .F.
       oDocPro:oDOC_FECHA:MsgErr("Libro de Inventario ya Registrado en Fecha "+DTOC(FCHFINMES(oDocPro:DOC_FECHA)),"Operación ["+cText+"] No Permitida")
       RETURN .F.
    ENDIF

RETURN .T.

/*
// 17/09/2016 LBX proveedor con Opcion Buscar Enlace con Documento de CxP
*/

FUNCTION LBXPROVEEDOR()
   LOCAL cWhere:="(LEFT(PRO_SITUAC,1)='A' OR LEFT(PRO_SITUAC,1)='C') "+IF(Empty(oDocPro:cWherePro),""," AND "+oDocPro:cWherePro)
   LOCAL cTitle,oDpLbx

//   LOCAL cFile :=EJECUTAR("LBXTIPPROVEEDOR",oTIPPROVEEDORMNU:cCodigo)
//   DPLBX(cFile,oTIPPROVEEDORMNU:cCodigo,"PRO_TIPO"+GetWhere("=",oTIPPROVEEDORMNU:cCodigo))

   IF oDocPro:nOption=5

      IF ISDPSTD()
        IniGetLbx(GETFILESTD(cFileLbx))
      ELSE
        IniGetLbx(MEMOREAD(cFileLbx))
      ENDIF

      cTitle  :=ALLTRIM(GetFromVar(GetLbx("TITLE"))) +" [ Sólo con Documentos] "

      IF RELEASE("16.08")

         cWhere:=" INNER JOIN DPDOCPRO ON PRO_CODIGO=DOC_CODIGO AND "+oDocPro:cScope+;
                 " WHERE "+cWhere

      ENDIF

   ENDIF

   IF ValType(oDocPro:oDpLbx)="O" .AND. oDocPro:oDpLbx:oWnd:hWnd=0 
//? oDocPro:oDpLbx:oWnd,"oDocPro:oDpLbx:oWnd",ValType(oDocPro:oDpLbx:oWnd),"<-VALTYPE"
      oDocPro:oDpLbx:=NIL
   ENDIF

//   ? oDocPro:oDpLbx:ClassName()

   IF oDocPro:oDpLbx=NIL
     oDpLbx:=DpLbx("DPPROVEEDOR",cTitle,cWhere,NIL,NIL,NIL,NIL,NIL,NIL,oDocPro:oDOC_CODIGO)
     oDocPro:oDpLbx:=oDpLbx
     oDpLbx:GetValue("PRO_CODIGO",oDocPro:oDOC_CODIGO)
   ENDIF

RETURN .T.

/*
// Validar Fechas
*/
FUNCTION DOCFECHA(lValid)
  LOCAL lResp:=.F.
  LOCAL bLost :=oDocPro:oDOC_FECHA:bLostFocus
  LOCAL bValid:=oDocPro:oDOC_FECHA:bValid

  DEFAULT lValid:=.F.

  oDocPro:lDocFecha:=.T.

//  oDp:oFrameDp:Settext(IF(lValid,".T.",".F."))

  IF Empty(oDocPro:DOC_FECHA)
    oDocPro:oDOC_FECHA:VarPut(oDp:dFecha,.T.)
    RETURN .F.
  ENDIF

//  oDocPro:oDOC_FECHA:bLostFocus:=NIL
//  oDocPro:oDOC_FECHA:bValid    :={||.T.}

  lResp:=(oDocPro:ISLIBINV() .AND. ;
            EJECUTAR("DPVALFECHA",oDocPro:DOC_FECHA,!oDp:P_LDpFchEjer,.T.,oDocPro:oDOC_FECHA) .AND. ;
            EJECUTAR("DPDOCPROVALCAM",oDocPro))

  // oDp:oFrameDp:SetText("aqui vuelve a validar")
  // Debe Activarse el blink del Control

  IF !lResp
     DpFocus(oDocPro:oDOC_NUMERO)
     oDocPro:oDOC_NUMERO:KeyBoard(VK_TAB)
   ENDIF

   oDocPro:lDocFecha:=lResp
   oDocPro:oDOC_FECHA:bLostFocus:=bLost
   oDocPro:oDOC_FECHA:bValid    :=bValid
   oDocPro:oDOC_FECHA:ForWhen(.T.)
   oDocPro:oDOC_FECHA:SetColor(oDp:GetnCltText,oDp:GetnClrPane)

RETURN .T.

/*
// Asignar IVA Menos 3% o 5% Beneficio Tributario
*/
FUNCTION SETIVA10(lCalc)
RETURN EJECUTAR("SETIVA10FAC",lCalc)
FUNCTION GRIDVIEW()
RETURN .T.

FUNCTION DOCRTI()

  EJECUTAR('DPDOCPRORTI' ,oDocPro:DOC_CODSUC,;
                          oDocPro:DOC_TIPDOC,;
                          oDocPro:DOC_CODIGO,;
                          oDocPro:DOC_NUMERO,;
                          oDocPro:cNomDoc , 'C'    )
  IF !Empty(oDp:cMsgRetIva)
     MsgMemo(oDp:cMsgRetIva)
  ENDIF

RETURN .T.

// Valida Cantidad
FUNCTION VMOV_PESO()
RETURN EJECUTAR("VTAGRIDVALPESO",oGrid)

FUNCTION VERDOCORG()

  IF Empty(oGrid:MOV_ASOTIP)
     RETURN NIL
  ENDIF

  CursorWait()

  EJECUTAR("DPDOCPRO",oGrid:MOV_ASOTIP,oGrid:MOV_ASODOC)

RETURN .T.

/*
// Validar Precio en Divisas
*/
FUNCTION VMOV_COSDIV()
  LOCAL nCosto:=oGrid:MOV_COSDIV*oDocPro:DOC_VALCAM

  IF nCosto>0
    oGrid:Set("MOV_COSTO",nCosto,.T.)
  ENDIF
 
  oGrid:ColCalc("MOV_TOTAL")
  oGrid:ColCalc("MOV_MTODIV")

RETURN .T.

FUNCTION VMOV_MTODIV()
RETURN .T.

FUNCTION VMOV_CXUND()
RETURN EJECUTAR("VTAGRIDVALCXUND",oGrid)

/*
// Validar Divisa
*/
FUNCTION DOCVALCAM()
   LOCAL lResp:=EJECUTAR("DPDOCPROVALCAM",oDocPro:DOC_VALCAM,oDoc)
   LOCAL oCol

   IF oDocPro:DOC_VALCAM<=0
      oDocPro:oDOC_VALCAM:MsgErr("Valor debe ser mayor que CERO")
      RETURN .F.
   ENDIF

   IF !Empty(oDocPro:DOC_NUMERO) .AND. oGrid:nOption=1
     oDocPro:oDOC_VALCAM:oJump:=oGrid:oBrw
     oCol:=oGrid:GetCol("MOV_CODIGO",.F.)
     oGrid:oBrw:nColSel:=oCol:nPos
     DPFOCUS(oGrid:oBrw)
     oGrid:oBrw:KeyBoard(13)
   ENDIF

RETURN .T.
/*
// Crear ComboBox en MOV_LOTE por Caracteristicas por Proveedor
*/
FUNCTION BUILDTIPCAR()
   EJECUTAR("COMGRIDSETCARACT",oGrid)
RETURN .T.

/*
// Tipo de Caracteristicas
*/
FUNCTION VMOV_TIPCAR()
   LOCAL oCol:=NIL

   oGrid:lNewCaract:=.F.

   IF ALLTRIM(oGrid:MOV_TIPCAR)="-Agregar"

      oCol:=oGrid:GetCol("MOV_TIPCAR",.T.)
      oCol:SetEditType(1)
      oGrid:SET("MOV_TIPCAR",SPACE(20),.T.)

      oCol:=oGrid:GetCol("MOV_NOMCAR")
      oCol:SetEditType(1)
      oGrid:SET("MOV_NOMCAR",SPACE(20),.T.)
      oGrid:lNewCaract:=.T.

      RETURN .F.

   ELSE

     // EJECUTAR("COMGRIDBUILDCAR",oGrid)

     EJECUTAR("COMGRIDSETCARACT",oGrid)

   ENDIF

RETURN .T.


/*
// Nombre de la Caracteristicas
*/
FUNCTION VMOV_NOMCAR()
   LOCAL oCol:=NIL

   IF ALLTRIM(oGrid:MOV_NOMCAR)="-Agregar"

      oCol:=oGrid:GetCol("MOV_NOMCAR")
      oCol:SetEditType(1)
      oGrid:SET("MOV_NOMCAR",SPACE(20),.T.)
      oGrid:lNewCaract:=.T.

      RETURN .F.

   ENDIF

RETURN .T.


FUNCTION BRSUSTITUTOS()
  EJECUTAR("GRIDSUSTITUTOS",oGrid)
RETURN .T.


// EOF
