// Programa   : COMGRIDSETCARACT
// Fecha/Hora : 16/08/2023 16:02:31
// Propósito  : Presenta lista de Opciones para Características
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
   LOCAL oDoc,oCol,cWhere,aNomCar,cSql,aItem

   IF oGrid=NIL
      RETURN .F.
   ENDIF

   cWhere:="INC_CODPRO"+GetWhere("=",oDoc:DOC_CODIGO )+" AND "+;
           "INC_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)+" AND "+;
           "INC_TIPO  "+GetWhere("=",oGrid:MOV_TIPCAR)

   cSql :=" SELECT INC_DESCRI FROM DPINVCARACTERISTICAS "+;
          " WHERE "+cWhere+;
          " GROUP BY INC_DESCRI "

   aItem:=ATABLE(cSql)

   IF Empty(aItem)

      cWhere:="INC_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)+" AND "+;
              "INC_TIPO  "+GetWhere("=",oGrid:MOV_TIPCAR)

      cSql:=" SELECT INC_DESCRI FROM DPINVCARACTERISTICAS "+;
            " WHERE "+cWhere+;
            " GROUP BY INC_DESCRI "

      aItem:=ATABLE(cSql)

   ENDIF

   oCol:=EJECUTAR("GRIDSETITEM",oGrid,"MOV_NOMCAR",aItem)

RETURN .T.
// EOF
