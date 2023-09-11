// Programa   : DPDOCPRORMUPRN
// Fecha/Hora : 10/11/2015 14:41:07
// Propósito  : Imprimir Retención Municipal
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero)
  LOCAL cTipRet:="RMU",cWhere,oDocRmu,aData:={},cEstado:="",cRif,cWhereOrg:="",oDocOrg,aData:={},cCodAct:="",cNomAct:=""
  LOCAL cEstadoRmu:="",cDocOrg:=""
  LOCAL oFontB,oFont2,oFont3,oBrw,oCol,aHead:={}
  LOCAL cTitle,nFilMai
  LOCAL cDocPro :=oDp:cPathCrp+"DPDOCPRO.DBF"
  LOCAL cDocRmu :=oDp:cPathCrp+"DPDOCPRORMU.DBF"
  LOCAL cFile   :=oDp:cPathCrp+"DPDOCPRORMU_.DBF"
  LOCAL cFileRpt:=lower(oDp:cPathCrp+"DPDOCPRORMU_"+ALLTRIM(oDp:cRmu_cModelo)+".RPT")
  LOCAL cTitle,cTipRmu:="RMU"

  LOCAL cFileHead,aHead:={}
  LOCAL nSalida:=1,cFileMem:=""
  LOCAL cFileEdit

  PRIVATE cRpt_Title,cRpt_Out,cRpt_Path,cRpt_Dll,cRpt_Rpt

  IF !FILE(cFileRpt) .AND. !("%"$cFileRpt)
    MsgMemo("Formato Crystal "+CRLF+""+cFileRpt+CRLF+" no existe para definición "+oDp:cRmu_cModelo+CRLF+;
            "Sera Utilizado formato por defecto [DPDOCPRORMU.RPT]")
  ENDIF

  IF !FILE(cFileRpt) .OR. "%"$cFileRpt
    cFileRpt:=oDp:cPathCrp+"DPDOCPRORMU.RPT"
  ENDIF

  DEFAULT cCodSuc:=oDp:cSucursal,;
          cTipDoc:="FAC",;
          cCodigo:=SQLGET("DPDOCPRO","DOC_CODIGO,DOC_NUMERO,DOC_FECHA,DOC_BASNET","DOC_TIPDOC"+GetWhere("=",cTipDoc)),;
          cNumero:=DPSQLROW(2)

  cWhere :="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "DOC_TIPAFE"+GetWhere("=",cTipDoc)+" AND "+;
           "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
           "DOC_FACAFE"+GetWhere("=",cNumero)+" AND "+;
           "DOC_TIPTRA"+GetWhere("=","D")


  IF COUNT("DPDOCPRO",cWhere)=0 
     MsgMemo("Documento no posee retención Municipal")
     RETURN .F.
  ENDIF


  oDocRmu:=OpenTable("SELECT * FROM DPDOCPRO WHERE "+cWhere,.T.)
  cEstado:=SAYOPTIONS("DPDOCPRO","DOC_ESTADO",oDocRmu:DOC_ESTADO)
  oDocRmu:Replace("DOC_ESTADO",cEstado)
  oDocRmu:CTODBF(cDocRmu)
  oDocRmu:End()

  cWhereOrg:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
             "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
             "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
             "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
             "DOC_TIPTRA"+GetWhere("=","D")

  oDocOrg   :=OpenTable("SELECT * FROM DPDOCPRO "+;
                        " INNER JOIN VIEW_DOCPRORMU ON RMU_CODSUC=DOC_CODSUC AND "+;
                        "                              RMU_TIPDOC=DOC_TIPDOC AND "+;
                        "                              RMU_CODIGO=DOC_CODIGO AND "+;
                        "                              RMU_NUMDOC=DOC_NUMERO "+;
                        " INNER JOIN DPPROVEEDOR    ON DOC_CODIGO=PRO_CODIGO "+;
                        " LEFT  JOIN DPACTIVIDAD_E  ON PRO_ACTIVI=ACT_CODIGO "+;
                        " LEFT  JOIN DPRETMUNTARIFA ON PRO_CODRMU=TRM_CODIGO "+;
                        " WHERE "+cWhereOrg,.T.)


  cTitle    :=ALLTRIM(SQLGET("DPTIPDOCPRO","TDC_DESCRI","TDC_TIPO"+GetWhere("=",cTipRmu)))+" # "+ALLTRIM(oDocOrg:RMU_NUMERO)+;
              " ["+oDocOrg:DOC_TIPDOC+"-"+ALLTRIM(oDocOrg:DOC_NUMERO)+"-"+ALLTRIM(oDocOrg:PRO_NOMBRE)+"]"
            
  cEstado   :=SAYOPTIONS("DPDOCPRO","DOC_ESTADO",oDocOrg:DOC_ESTADO)
  oDocOrg:CTODBF(cDocPro)
//  oDocOrg:Browse()
  oDocOrg:End()

  EJECUTAR("CREATEHEAD",cFile,aHead,"Retención Municipal") // Genera los Datos del Encabezado

  IF !FILE(cFileRpt)
     MsgMemo("Archivo "+cFileRpt+" no Existe")
     RETURN .F.
  ENDIF

  DEFAULT oDp:lCrystalExe:=.T.

  IF oDp:lCrystalExe

     cRpt_Title  :=ALLTRIM(cTitle)
     cRpt_Out    :=nSalida
     cRpt_Path   :="CRYSTAL\"
     cRpt_Dll    :=oDp:cFileDll
     cRpt_Rpt    :=cFileRpt
     cFileMem    :="CRYSTAL\CRYSTAL.MEM"

     SAVE TO (cFileMem) ALL LIKE cRpt*

     WINEXEC("BIN\DPCRPE.EXE",0)

   ELSE

      RunRpt(cFileRpt,{cFileDbf,cFileHead},nSalida,ALLTRIM(cTitle))

   ENDIF


RETURN .T.
