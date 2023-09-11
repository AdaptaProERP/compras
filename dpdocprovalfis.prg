// Programa   : DPDOCPROVALFIS
// Fecha/Hora : 161/05/2017 06:42:20
// Propósito  : Validar Número Fiscal el Documento de Compra
// Creado Por : Juan Navas
// Llamado por: DPDOCPRO
// Aplicación : Ventas
// Tabla      : DPDOCPRO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDoc,cCodSuc,cCodigo,cNumFis,nOption,cNumero)
   LOCAL lResp:=.T.,cNumFis_:="",cNumero_:="",cTipDoc_
   LOCAL cWhere,oTable

   // Busca no Coloca ceros hacia la Izquierda que permita Buscar Varios Documentos
   IF oDoc:nOption=5
      RETURN .F.
   ENDIF

   DEFAULT cCodSuc:=oDoc:DOC_CODSUC,;
           cCodigo:=oDoc:DOC_CODIGO,;
           cNumFis:=ALLTRIM(oDoc:DOC_NUMFIS),;
           cNumero:=ALLTRIM(oDoc:DOC_NUMERO)


   // Numero Fiscal se Introduce como esta Impreso
   cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
           "DOC_NUMFIS"+GetWhere("=",cNumFis)+" AND "+;
           "DOC_TIPTRA"+GetWhere("=","D")

/*
   RELEASETABLES()
   LOADDSN(),"LOADDSN"
   LOADTABLAS(.T.)
*/  
   oTable:=OpenTable("SELECT DOC_NUMERO,DOC_NUMFIS,DOC_TIPDOC FROM DPDOCPRO WHERE "+cWhere,.T.)
   cNumFis_:=ALLTRIM(oTable:DOC_NUMFIS)
   cNumero_:=ALLTRIM(oTable:DOC_NUMERO)
   cTipDoc_:=oTable:DOC_TIPDOC

//,DOC_NUMFIS,DOC_TIPDOC",cWhere))
// cNumero_:=ALLTRIM(DPSQLROW(2))
// cTipDoc_:=DPSQLROW(3)
   oTable:End()

/*
   cNumFis_:=ALLTRIM(SQLGET("DPDOCPRO","DOC_NUMERO,DOC_NUMFIS,DOC_TIPDOC",cWhere))
   cNumero_:=ALLTRIM(DPSQLROW(2))
   cTipDoc_:=DPSQLROW(3)
*/
   // Numero Fiscal es Igual en 
   IF !Empty(cNumFis_) .AND. (cNumFis_=cNumFis) .AND. !(cNumero_=cNumero)
      oDoc:oDOC_NUMFIS:MsgErr("Numero Fiscal esta registrado"+CRLF+"en documento "+cTipDoc_+"-"+cNumero_,"Número Fiscal ya Existe ")
      oDoc:oDOC_NUMFIS:VarPut(oDoc:DOC_NUMERO,.T.)
      lResp:=.f.
   ENDIF

RETURN lResp
// EOF


