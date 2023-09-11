// Programa   : DPDOCPRORETSETFCHDEC
// Fecha/Hora : 05/05/2019 05:20:59
// Propósito  : Asignar Fecha de Declaración en Retenciones de ISLR
// Creado Por : Juan Navas
// Llamado por: Proceso de Contabilización
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cWhere)
   LOCAL cSql,oTable

   EJECUTAR("DPCAMPOSADD","DPDOCPRORTI" ,"RTI_DOCTIP","C",3,0,"Tipo de documento RTI")


   cSql:=[ SELECT DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO,DOC_FCHDEC,RET_FCHDEC ]+;
         [ FROM VIEW_DOCPROISLR ]+;
         [ INNER JOIN DPDOCPRO ON RET_CODSUC=DOC_CODSUC AND RET_DOCTIP=DOC_TIPDOC AND RET_CODIGO=DOC_CODIGO AND RET_DOCNUM=DOC_NUMERO AND DOC_TIPTRA="D" ]+;
         [ WHERE ]+IF(Empty(cWhere),"",cWhere+" AND ")+[ DOC_FCHDEC<>RET_FCHDEC ]
  
    oTable:=OpenTable(cSql,.T.)
  
//  oTable:Browse()
    oTable:GoTop()

    WHILE !oTable:EOF()

        cWhere:="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
                "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+" AND "+;
                "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)
    
        SQLUPDATE("DPDOCPRO","DOC_FCHDEC",oTable:RET_FCHDEC,cWhere)

        oTable:DbSkip()

    ENDDO

    oTable:End()

RETURN .T.
// EOF
