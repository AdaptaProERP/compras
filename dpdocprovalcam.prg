// Programa   : DPDOCPROVALCAM
// Fecha/Hora : 31/10/2005 19:53:39
// Propósito  : Validar Valor Cambiario en Documentos CXP
// Creado Por : Juan Navas
// Llamado por: DPDOCPRO
// Aplicación : Compras
// Tabla      : DPDOCPRO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDoc,cField)

   IF oDoc=NIL
     RETURN .F.
   ENDIF

   oDoc:cMonedaSigno:=MYSQLGET("DPTABMON","MON_APLICA","MON_CODIGO"+GetWhere("=",Left(oDoc:DOC_CODMON,3)))

   oDoc:DOC_VALCAM:=EJECUTAR("DPGETVALCAM",Left(oDoc:DOC_CODMON,3),oDoc:DOC_FECHA,oDoc:DOC_HORA)

   // 21/12/2022
   IF oDoc:nOption=1 .AND. oDoc:lPar_LibCom
      oDoc:DOC_FCHDEC:=EJECUTAR("GETVALFCHDEC",oDoc:DOC_FECHA)
      oDoc:SetValue("DOC_FCHDEC",oDoc:DOC_FCHDEC)
   ENDIF

RETURN .T.
// EOF
