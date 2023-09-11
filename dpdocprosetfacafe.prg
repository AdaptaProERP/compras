// Programa   : DPDOCPROSETFACAFE
// Fecha/Hora : 30/05/2022 05:26:51
// Propósito  : Asignar Factuara Afectada en Documentos del Proveedor
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cTipDoc)
  LOCAL oTable,cSql,oRet,cTipDoc,cNumOrg,cWhere:="",cTipOrg,cNumero,cNumFis

  IF !Empty(cTipDoc)
     cWhere:=" AND DOC_TIPDOC"+GetWhere("=",cTipDoc)
  ENDIF

  cSql:="SELECT * FROM DPDOCPRO INNER JOIN DPTIPDOCPRO ON DOC_TIPDOC=TDC_TIPO AND (TDC_TRIBUT=1 OR TDC_LIBCOM=1) WHERE DOC_TIPDOC"+GetWhere("<>","FAC")+" AND DOC_FACAFE"+GetWhere("=","")+" "+cWhere

//  cSql:="SELECT * FROM DPDOCPRO INNER JOIN DPTIPDOCPRO ON DOC_TIPDOC=TDC_TIPO AND (TDC_TRIBUT=1 OR TDC_LIBCOM=1) WHERE DOC_TIPDOC"+GetWhere("<>","FAC")
//+" AND DOC_FACAFE"+GetWhere("=","")+" "+cWhere

  oTable:=OpenTable(cSql,.T.)
  WHILE !oTable:Eof()

     cTipOrg:=""
     cNumero:=""
     cNumFis:=""

     IF oTable:DOC_TIPDOC="RET"
       cTipOrg:=SQLGET("DPDOCPROISLR","RXP_TIPDOC,RXP_NUMDOC","RXP_DOCTIP"+GetWhere("=",oTable:DOC_TIPDOC)+" AND RXP_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+" AND RXP_DOCNUM"+GetWhere("=",oTable:DOC_NUMERO))
       cNumOrg:=DPSQLROW(2,"")
     ENDIF

     IF !Empty(cTipOrg) .AND. !Empty(cNumOrg)

        cWhere:="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                "DOC_TIPDOC"+GetWhere("=",cTipDoc          )+" AND "+;
                "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+" AND "+;
                "DOC_NUMERO"+GetWhere("=",cNumOrg          )

        cNumFis:=SQLGET("DPDOCPRO","DOC_NUMFIS",cWhere)

        cWhere:="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
                "DOC_TIPDOC"+GetWhere("=",oTable:DOC_TIPDOC)+" AND "+;
                "DOC_CODIGO"+GetWhere("=",oTable:DOC_CODIGO)+" AND "+;
                "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)

        SQLUPDATE("DPDOCPRO","DOC_FACAFE",cNumOrg,cWhere)

     ENDIF

     oTable:DbSkip()

  ENDDO

//  oTable:Browse()
  oTable:End()

RETURN .T.
// EOF
