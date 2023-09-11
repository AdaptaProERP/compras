// Programa   : DPDOCPRORTIPRN
// Fecha/Hora : 23/02/2013 15:04:30
// Propósito  : Imprimir Retencion de IVA
// Creado Por : Juan Navas 
// Llamado por: DPDOCPRORTI
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero)
   LOCAL oRep,bBlq,cWhere

   DEFAULT cCodSuc:=oDp:cSucursal
   
   cWhere:="RTI_CODSUC"+GetWhere("=",cCodSuc)

   oRep:=REPORTE("DOCPRORTI",cWhere)

   oRep:SetRango(1,cNumero,cNumero) // Número de la Factura
   oRep:SetRango(2,cCodigo,cCodigo) // Código
   oRep:SetCriterio(1,cTipDoc,"= Igual"," And ")      // Puede ser un Reverso de IVA

   oRep:aCargo:=cTipDoc

   cWhere:="RTI_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "RTI_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
           "RTI_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
           "RTI_NUMERO"+GetWhere("=",cNumero)

   bBlq:=[SQLUPDATE("DPDOCPRORTI","RTI_IMPRES",.T.,"]+cWhere+[")]

   oRep:bPostRun:=BLOQUECOD(bBlq) 

RETURN .T.
