//
// Programa : DPDOCPRORTIFIXDUPLI 
// Proposito:

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN()
   LOCAL cSql,oTable,cWhere,cNumero

   oTable:=OpenTable([ SELECT DOC_CODIGO,DOC_NUMERO,DOC_TIPTRA,DOC_NETO,COUNT(*) AS CUANTOS FROM DPDOCPRO WHERE DOC_TIPDOC="RTI" AND DOC_TIPTRA="D" GROUP BY DOC_CODIGO,DOC_NUMERO,DOC_TIPTRA HAVING CUANTOS>1]) 
   oTable:End()

? CLPCOPY(oTable:cSql)

    IF oTable:RecCount()=0
      RETURN .T.
    ENDIF

    MsgRun("Renumerando Retenciones de IVA Duplicadas en Proveedore")

    cSql:=[ SELECT DOC_CODSUC,DOC_CODSUC,DOC_TIPDOC,DOC_NUMERO,DOC_CODIGO,DOC_NUMFIS,RTI_NUMRET,RTI_DOCNUM,RTI_NUMTRA ]+;
         [ FROM DPDOCPRO ]+;
         [ INNER JOIN  DPDOCPRORTI ON RTI_CODSUC=DOC_CODSUC AND RTI_DOCTIP=DOC_TIPDOC AND RTI_CODIGO=DOC_CODIGO AND RTI_DOCNUM=DOC_NUMERO AND RTI_TIPTRA=DOC_TIPTRA ]+;
         [ WHERE DOC_TIPDOC="RTI" AND DOC_TIPTRA="D" ]

   oTable:=OpenTable(cSql,.T.)

   oTable:Execute("SET FOREIGN_KEY_CHECKS=0")
 
   WHILE !oTable:EOF()

     cNumero:=ALLTRIM(oTable:RTI_NUMTRA)
     cNumero  :=REPLi("0",10-LEN(cNumero))+cNumero

  
     cWhere:="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
             "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
             "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+" AND "+;
             "DOC_NUMERO"+GetWhere("=",oTable:RTI_DOCNUM)

     SQLUPDATE("DPDOCPRO","DOC_NUMERO",cNumero,cWhere)

     cWhere:="RTI_CODSUC"+GetWhere("=",oTable:RTI_CODSUC)+" AND "+;
             "RTI_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+" AND "+;
             "RTI_DOCNUM"+GetWhere("=",oTable:RTI_DOCNUM)

     SQLUPDATE("DPDOCPRORTI","RTI_DOCNUM",cNumero,cWhere)

     oTable:DbSkip()

     SysRefresh(.T.)

    ENDDO

    oTable:End()

    oTable:Execute("SET FOREIGN_KEY_CHECKS=1")

RETURN .F.
// EOF
