// Programa   : DPDOCPRORTICHKNUM
// Fecha/Hora : 08/10/2022 01:49:56
// Propósito  : Asegurar la secuencia de la numeración de Retenciones de IVA
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(lSay)
   LOCAL cSql:=" SELECT RTI_DOCNUM,COUNT(*) AS CUANTOS FROM dpdocprorti GROUP BY RTI_DOCNUM HAVING CUANTOS>1"
   LOCAL oTable,cUrl:="www.adaptaproerp.com/retencion-de-iva/"


RETURN .T.

   cSql:=[ SELECT DPDOCPRORTI.RTI_CODSUC,DPDOCPRORTI.RTI_DOCNUM,COUNT(*) AS CUANTOS ]+;
         [ FROM  DPDOCPRORTI  ]+;
         [ INNER JOIN DPDOCPRO       ON DPDOCPRORTI.RTI_CODSUC=DOC_CODSUC AND  ]+;
         [                              DPDOCPRORTI.RTI_TIPDOC=DOC_TIPDOC AND  ]+;
         [                              DPDOCPRORTI.RTI_CODIGO=DOC_CODIGO AND  ]+;
         [                              DPDOCPRORTI.RTI_NUMERO=DOC_NUMERO AND  ]+;
         [                              DOC_TIPTRA]+GetWhere("=","D")+[ AND DOC_ACT=1 ]+;
         [ INNER JOIN VIEW_DOCPRORTI ON DPDOCPRORTI.RTI_CODSUC=VIEW_DOCPRORTI.RTI_CODSUC AND ]+;
         [                              DPDOCPRORTI.RTI_TIPDOC=VIEW_DOCPRORTI.RTI_TIPDOC AND ]+;
         [                              DPDOCPRORTI.RTI_CODIGO=VIEW_DOCPRORTI.RTI_CODIGO AND ]+;
         [                              DPDOCPRORTI.RTI_NUMERO=VIEW_DOCPRORTI.RTI_NUMDOC ]+;
         [ GROUP BY DPDOCPRORTI.RTI_CODSUC,DPDOCPRORTI.RTI_DOCNUM HAVING CUANTOS>1 ]

         
    DEFAULT lSay:=.T.

    oTable:=OpenTable(cSql,.T.)

    IF oTable:RecCount()>0 

      IF lSay
         EJECUTAR("WEBRUN",cUrl,.f.)
         MsgMemo("Detectado "+LSTR(oTable:RecCount())+" Registros Repetidos en Número General"+CRLF+"Será renumerada Automáticamente"+CRLF+"Mayor información en "+cUrl,"Retenciones de IVA")
      ENDIF

      MsgRun("Renumerando Retenciones de IVA")
      CursorWait()

      EJECUTAR("DOCPRORTISETNUM",NIL,NIL,.F.)
   
    ENDIF

    oTable:End()
  
RETURN .T.
// EOF
