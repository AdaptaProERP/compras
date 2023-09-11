// Programa   : DPDOCPROUNIQUE
// Fecha/Hora : 19/01/2007 15:05:56
// Propósito  : Busca Facturas de Compras Duplicadas
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oTable)
  LOCAL cSql,oTable,cDatos,cFile,aTablas:={}

  cSql:=" SELECT DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO,DOC_PAGNUM,DOC_TIPTRA,COUNT(*) AS CUANTOS FROM DPDOCPRO "+;
        " WHERE DOC_TIPTRA='D' "+;
        " GROUP BY DOC_CODSUC,DOC_TIPDOC,DOC_CODIGO,DOC_NUMERO,DOC_PAGNUM,DOC_TIPTRA "+;
        " HAVING CUANTOS > 1 "


  oTable:=OpenTable(cSql)
  cFile :="EJEMPLO\DPDOCPRO"+DTOS(oDp:dFecha)+"_"+STRTRAN(HORA_AP(),":","")+".DBF"

  IF oTable:RecCount()>0 
    oTable:CTODBF(cFile)
  ENDIF

  WHILE !oTable:Eof()

    cSql:="DOC_CODSUC"+GetWhere("=",oTable:DOC_CODSUC)+" AND "+;
          "DOC_TIPDOC"+GetWhere("=",otable:DOC_TIPDOC)+" AND "+;
          "DOC_CODIGO"+GetWhere("=",otable:DOC_CODIGO)+" AND "+;
          "DOC_NUMERO"+GetWhere("=",oTable:DOC_NUMERO)+" AND DOC_TIPTRA='D' "+GetWhere("LIMIT ",CTOO(oTable:CUANTOS,"N")-1)

    SQLDELETE("DPDOCPRO",cSql)

    oTable:DbSkip()

  ENDDO

//  oTable:Browse()
  oTable:End()

  AADD(aTablas,{"DPCBTEPAG"  ,"PAG_CODSUC,PAG_NUMERO"})
  AADD(aTablas,{"DPDOCPROCTA","CCD_CODSUC,CCD_TIPDOC,CCD_CODIGO,CCD_NUMERO,CCD_TIPTRA,CCD_ITEM"})

  AEVAL(aTablas,{|a,n| EJECUTAR("UNIQUETABLAS",a[1],a[2])})




RETURN NIL
// EOF
