// Programa   : DPDOCPROVALNUM
// Fecha/Hora : 01/11/2005 06:42:20
// Propósito  : Validar Número del Documento del Proveedor
// Creado Por : Juan Navas
// Llamado por: DPDOCPRO
// Aplicación : Ventas
// Tabla      : DPDOCPRO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDoc)
   LOCAL lResp:=.T.


   // Busca no Coloca ceros hacia la Izquierda que permita Buscar Varios Documentos
   IF oDoc:nOption=5
      RETURN .F.
   ENDIF

   IF oDoc:lPar_Zero .AND. oDoc:nPar_Len>1 .AND. ISALLDIGIT(oDoc:DOC_NUMERO)
      oDoc:DOC_NUMERO:=STRZERO(VAL(oDoc:DOC_NUMERO),oDoc:nPar_Len)
      oDoc:oDOC_NUMERO:VarPut(oDoc:DOC_NUMERO,.T.)
   ENDIF

   IF oDoc:nOption!=5 .AND. !oDoc:ValUnique(oDoc:DOC_CODIGO+oDoc:DOC_NUMERO,NIL,.F.)
      lResp:=.F.
      MensajeErr(ALLTRIM(oDoc:cNomDoc)+" ["+oDoc:DOC_NUMERO+"]"+CRLF+"ya Existe")
   ENDIF

//  ? oDp:cSql

RETURN lResp
// EOF

