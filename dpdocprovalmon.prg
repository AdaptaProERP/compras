// Programa   : DPDOCPROVALMON
// Fecha/Hora : 09/10/2005 13:12:24
// Propósito  : Validar Control Cambiario
// Creado Por : Juan Navas
// Llamado por: DPDOCPROVALCAM
// Aplicación : Compras
// Tabla      : DPDOCPRO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oDoc)
   //  FUNCTION GetValCam()

   IF oDoc=NIL
     RETURN .F.
   ENDIF

   oDoc:DOC_VALCAM:=EJECUTAR("DPGETVALCAM",Left(oDoc:DOC_CODMON,3),oDoc:DOC_FECHA,oDoc:DOC_HORA)

   oDoc:oDOC_VALCAM:VarPut(oDoc:DOC_VALCAM,.T.)

RETURN .T.
// EOF

