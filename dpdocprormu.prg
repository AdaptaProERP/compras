// Programa   : DPDOCPRORMU
// Fecha/Hora : 29/10/2015 12:47:55
// Propósito  : Retención Municipal
// Creado Por : Juan Navas
// Llamado por: DPDOCPRO. Su numero se Genera según DOC_TIPAFE Y DOC_FACAFE el mismo tipo de Documento del Proveedor, asi permite su búsqueda
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero)
  LOCAL nPorcen,cCodAct,aData:={},cNombre,cNomAct:="",dFecha,nBasNet
  LOCAL aSize,nAlto,nDataLines,aCols,lMsg,oObj,oDocOrg,nMonto,oData,oDocRet
  LOCAL cTipRet:="RMU",cWhere,cNumRet:="",lZero,nLen

  DEFAULT cCodSuc:=oDp:cSucursal,;
          cTipDoc:="FAC",;
          cCodigo:=SQLGET("DPDOCPRO","DOC_CODIGO,DOC_NUMERO,DOC_FECHA,DOC_BASNET","DOC_TIPDOC"+GetWhere("=",cTipDoc)+" LIMIT 1"),;
          cNumero:=DPSQLROW(2)


  nLen :=SQLGET("DPTIPDOCPRO","TDC_LEN,TDC_ZERO","TDC_TIPO"+GetWhere("=",cTipRet))
  lZero:=DPSQLROW(2)

  oDocOrg:=OpenTable("SELECT * FROM DPDOCPRO WHERE DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                  " DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
                  " DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                  " DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
                  " DOC_TIPTRA"+GetWhere("=","D"    ),.T.)

//oDocOrg:Browse()
  oDocOrg:End()

  cCodAct:=SQLGET("DPPROVEEDOR","PRO_CODRMU,PRO_NOMBRE","PRO_CODIGO"+GetWhere("=",cCodigo))
  cNombre:=DPSQLROW(2)

  IF Empty(cCodAct) 
    MsgMemo("Proveedor "+cCodigo+" No tiene Actividad Económica Asociada")
    RETURN .F.
  ENDIF

// nPorcen:=SQLGET("DPACTIVIDAD_E","ACT_PORRTM,ACT_DESCRI","ACT_CODIGO"+GetWhere("=",cCodAct))
  nPorcen:=SQLGET("DPRETMUNTARIFA","TRM_PORCEN,TRM_DESCRI","TRM_CODIGO"+GetWhere("=",cCodAct))
  nMonto :=PORCEN(oDocOrg:DOC_BASNET,nPorcen)
  cNomAct:=DPSQLROW(2)

  AADD(aData,{"Proveedor",cCodigo})
  AADD(aData,{"Nombre"   ,cNombre})
  AADD(aData,{"Cód. Act" ,cCodAct})
  AADD(aData,{"Actividad",cNomAct})
  AADD(aData,{"Tasa"     ,FDP(nPorcen,"99.99")+"%"})
  AADD(aData,{"Documento",cTipDoc+"-"+cNumero})
  AADD(aData,{"Fecha"    ,oDocOrg:DOC_FECHA})
  AADD(aData,{"Base Imponible",FDP(oDocOrg:DOC_BASNET,"999,999,999.99")})
  AADD(aData,{"Retención"     ,FDP(nMonto         ,"999,999,999.99")})

  IF !EJECUTAR("MSGBROWSE",aData,"Aplicar Retención Municipal",aSize,nAlto,nDataLines,aCols,lMsg,oObj)
    RETURN .F.
  ENDIF

  cWhere :="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "DOC_TIPAFE"+GetWhere("=",cTipDoc)+" AND "+;
           "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
           "DOC_FACAFE"+GetWhere("=",cNumero)+" AND "+;
           "DOC_TIPTRA"+GetWhere("=","D")

  oDocRet:=OpenTable("SELECT * FROM DPDOCPRO WHERE "+cWhere,.T.)

  IF oDocRet:RecCount()=0

      oData:=DATASET("SUC_C"+oDp:cSucursal,"ALL")
      cNumero:=oData:Get("RMUNumero",SPACE(10))
      cNumero:=IIF(cNumero=REPLI("0",10),STRZERO(1,10),cNumero)
      oData:End(.F.)

/*
      cNumRet:=SQLINCREMENTAL("DPDOCPRO","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                      "DOC_TIPDOC"+GetWhere("=",cTipRet)+" AND "+;
                                                      "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                                                      "DOC_TIPTRA"+GetWhere("=","D"))
*/

      cNumRet:=SQLINCREMENTAL("DPDOCPRO","DOC_NUMERO","DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                                      "DOC_TIPDOC"+GetWhere("=",cTipRet)+" AND "+;
                                                      "DOC_TIPTRA"+GetWhere("=","D"))

      cNumRet:=IF( Empty(cNumero) , cNumRet , IIF( cNumRet>cNumero , cNumRet , cNumero ))
  
      IF lZero .AND. nLen>1 .AND. ISALLDIGIT(cNumRet)
        cNumRet:=STRZERO(VAL(cNumRet),nLen)
      ENDIF

      oDocRet:AppendBlank()
      // Pasa todos los Datos del Documento Origen

      AEVAL(oDocOrg:aFields,{|a,n| oDocRet:FieldPut(n,oDocOrg:FieldGet(n))})

      oDocRet:cWhere:=""

      oDocRet:Replace("DOC_TIPDOC",cTipRet)
      oDocRet:Replace("DOC_NUMERO",cNumRet)
      oDocRet:Replace("DOC_FACAFE",oDocOrg:DOC_NUMERO)
      oDocRet:Replace("DOC_TIPAFE",oDocOrg:DOC_TIPDOC)
      oDocRet:Replace("DOC_FECHA" ,oDp:dFecha        )
      oDocRet:Replace("DOC_FCHDEC",oDp:dFecha        )

  ENDIF

  oDocRet:Replace("DOC_DOCORG","D"    )
  oDocRet:Replace("DOC_BASNET",0      )
  oDocRet:Replace("DOC_MTOIVA",0      )
  oDocRet:Replace("DOC_MTOEXE",0      ) 
  oDocRet:Replace("DOC_CXP"   ,oDocOrg:DOC_CXP*-1)
  oDocRet:Replace("DOC_NETO"  ,nMonto )
  oDocRet:Replace("DOC_ACT"   ,1      )
  oDocRet:Replace("DOC_ESTADO","AC"   )
  oDocRet:Replace("DOC_DCTO"  ,nPorcen)
  oDocRet:Commit(oDocRet:cWhere)
  oDocRet:End()

//? cCodAct,nPorcen,CLPCOPY(oDp:cSQL)
//? cCodSuc,cTipDoc,cCodigo,cNumero,"cCodSuc,cTipDoc,cCodigo,cNumero"

RETURN .T.
// EOF
