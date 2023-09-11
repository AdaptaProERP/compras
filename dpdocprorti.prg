// Programa   : DPDOCPRORTI
// Fecha/Hora : 10/05/2012 18:25:46
// Propósito  : Aplicar Retenciones de IVA
// Creado Por : Juan Navas
// Llamado por: DPDOCPRO
// Aplicación : Compras 
// Tabla      : DPDOCPRORTI

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero,cNomDoc,nOption,cDocOrg,lChkRif,lEdit,cNumMrt,lAsk,lMsg)
   LOCAL cTipRti.,lAnula:=.F.,lPrint,cTipRti:="RTI",lOk,cWhereDoc:="",cWhereRti,cNumRti,cEstado:=""

   DEFAULT cTipDoc:="FAC" , cCodSuc:=oDp:cSucursal , cCodigo:=STRZERO(1,10), cNumero:=STRZERO(1,10),;
           cNomDoc:="Factura",nOption:=1,cDocOrg:="C",lEdit:=.T.,lChkRif:=.T.


   DEFAULT oDp:aRti:={},;
           lMsg    :=.F.

   cTipRti:=IF(cTipDoc="FAC","RTI","RVI")

   cWhereRti:="RTI_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
              "RTI_DOCTIP"+GetWhere("=",cTipRti)+" AND "+;
              "RTI_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
              "RTI_NUMERO"+GetWhere("=",cNumero)

   cNumRti:=SQLGET("DPDOCPRORTI","RTI_DOCNUM",cWhereRti)

   cWhereDoc:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",cTipRti)+" AND "+;
              "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",cNumRti)+" AND "+;
              "DOC_TIPTRA"+GetWhere("=","D"    )

   cEstado :=SQLGET("DPDOCPRO","DOC_ESTADO",cWhereDoc)
   lAnula  :=("NU"$cEstado)

   lOK:=EJECUTAR("DPDOCPRORTISAV",cCodSuc,cTipDoc,cCodigo,cNumero,cTipRti,lEdit,lAnula,lPrint,lChkRif,lMsg,.F. ,NIL ,cNumMrt)

RETURN lOK

// eof
