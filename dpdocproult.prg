// Programa   : DPDOCPROULT
// Fecha/Hora : 09/06/2005 23:08:00
// Propósito  : Busca Ultimo Documento del Cliente
// Creado Por : Juan Navas
// Llamado por: DPDOCPRO
// Aplicación : Compras
// Tabla      : DPDOCPRO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDoc,cCodSuc,cTipDoc,cCodPro)
  LOCAL cWhere,oTable,cNumDoc:=""

  DEFAULT cCodPro:=STRZERO(1,10),;
          cTipDoc:="CTZ",;
          cCodSuc:=oDp:cSucursal

  cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
          "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
          "DOC_CODIGO"+GetWhere("=",cCodPro)+" AND "+;
          "DOC_TIPTRA='D'"

  cNumDoc:=SQLGETMAX("DPDOCPRO","DOC_NUMERO",cWhere)
 
  IF Empty(cNumDoc)
     oDp:aUltDoc:={}
     RETURN .F.
  ENDIF

  oTable :=OpenTable("SELECT DOC_CODMON,DOC_PLAZO,DOC_CONDIC FROM DPDOCPRO WHERE "+cWhere+;
                      " AND DOC_NUMERO"+GetWhere("=",cNumDoc))

  IF oTable:Recno()>0

    oDp:aUltDoc:={oTable:DOC_CODMON,;
                  oTable:DOC_PLAZO ,;
                  oTable:DOC_CONDIC,;
                  NIL}


    oDoc:oDOC_CODMON:VARPUT(oDp:aUltDoc[1],.T.)
    oDoc:DOC_CODMON:=oDp:aUltDoc[1]

    oDoc:oDOC_PLAZO:VARPUT(oDp:aUltDoc[2],.T.)
    oDoc:DOC_PLAZO:=oDp:aUltDoc[2]

    oDoc:oDOC_CONDIC:VARPUT(oDp:aUltDoc[3],.T.)
    oDoc:DOC_CONDIC:=oDp:aUltDoc[3]

  ENDIF

  oTable:End()

RETURN .T.
// EOF

