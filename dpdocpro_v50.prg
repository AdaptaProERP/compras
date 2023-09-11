// Programa   : DPDOCPRO_V50
// Fecha/Hora : 28/10/2022 03:12:23
// Propósito  : importar anticipos desde la tabla DPDOCPRO_V50
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL cTable:="DPDOCPRO_V50"
  LOCAL dFecha
  LOCAL oDb:=OpenOdbc(oDp:cDsnData)
  LOCAL cTableD:="DPDOCPRO_V60"+DTOS(oDp:dFecha),cSql
  LOCAL oTableO,oTableD

  IF !EJECUTAR("DBISTABLE",oDp:cDsnData,cTable,.F.)
     RETURN .F.
  ENDIF

  IF !EJECUTAR("DBISTABLE",oDp:cDsnData,cTableD,.F.)
     cSql:=" CREATE TABLE "+cTableD+" SELECT * FROM DPDOCPRO"
     oDb:EXECUTE(cSql)
  ENDIF

  oTableD:=OpenTable("SELECT * FROM DPDOCPRO",.F.)
  oTableO:=OpenTable("SELECT * FROM "+cTable+" WHERE DOC_TIPDOC"+GetWhere("=","ANT")+" ORDER BY DOC_FECHA DESC",.T.,oDb,.F.)
  dFecha:=oTableO:DOC_FECHA
//oTableO:Browse()

  SQLDELETE("DPDOCPRO","DOC_TIPDOC"+GetWhere("=","ANT")+" AND DOC_FECHA"+GetWhere("<=",dFecha))

  oTableO:GoTop()

  WHILE !oTableO:Eof()
     oTableD:AppendBlank()
     AEVAL(oTableO:aFields,{|a,n| oTableD:Replace(a[1],oTableO:FieldGet(a[1]))})
     oTableD:Commit("")
     oTableO:DbSkip()
  ENDDO
  
  oTableO:END()
  oTableD:END()

//EJECUTAR("DPDOCPROANTFIX")
// ? cTable,dFecha,oDp:cSql

RETURN .T.
// EOF
