// Programa   : DPDOCPRORTISETVALCAM
// Fecha/Hora : 05/05/2023 10:45:30
// Propósito  : Asigna Valor de la Divisa desde la Factura Original de Compra
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere)
   LOCAL cSql,oDb:=OpenOdbc(oDp:cDsnData)

   cSql:=[ UPDATE DPDOCPRO ]+;
         [ INNER JOIN view_docprorti    ON DOC_CODSUC=RTI_CODSUC AND DOC_CODIGO=RTI_CODIGO AND DOC_NUMERO=RTI_NUMERO   ]+;
         [ INNER JOIN VIEW_DOCPRODESORG ON RTI_CODSUC=DOR_CODSUC AND DOR_TIPORG=RTI_TIPDOC AND RTI_CODIGO=DOR_CODIGO AND RTI_NUMDOC=DOR_DOCORG   AND DOR_VALCAM>1 ]+;
         [ SET DOC_VALCAM=DOR_VALCAM ]+;
         [ WHERE DOC_TIPDOC]+GetWhere("=","RTI")+" AND (DOC_VALCAM<=1 OR DOC_VALCAM IS NULL)"+IF(Empty(cWhere),""," AND "+cWhere)

   oDb:Execute(cSql)

// ? CLPCOPY(cSql)

   cSql:=[ UPDATE DPDOCCLI ]+;
         [ INNER JOIN view_docclirti    ON DOC_CODSUC=RTI_CODSUC AND DOC_NUMERO=RTI_NUMERO   ]+;
         [ INNER JOIN VIEW_DOCCLIDESORG ON RTI_CODSUC=DOR_CODSUC AND DOR_TIPORG=RTI_TIPDOC AND RTI_NUMDOC=DOR_DOCORG   AND DOR_VALCAM>1 ]+;
         [ SET DOC_VALCAM=DOR_VALCAM ]+;
         [ WHERE DOC_TIPDOC]+GetWhere("=","RTI")+" AND (DOC_VALCAM<=1 OR DOC_VALCAM IS NULL)"+IF(Empty(cWhere),""," AND "+cWhere)

   oDb:Execute(cSql)

// ? CLPCOPY(cSql)

RETURN .T.
// EOF
