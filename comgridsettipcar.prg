// Programa   : GRIDSETITEM
// Fecha/Hora : 16/08/2023 09:40:38
// Propósito  : Asigna ComboBox al Tipo de Características
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
   LOCAL oDoc,oCol,oColC,cWhere,cSql,cVacio
   LOCAL aItem

   cWhere:="INC_CODPRO"+GetWhere("=",oDoc:DOC_CODIGO )+" AND "+;
           "INC_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)

   cSql:=" SELECT INC_TIPO FROM DPINVCARACTERISTICAS "+;
         " WHERE "+cWhere+;
         " GROUP BY INC_TIPO "

   aItem:=ATABLE(cSql)

   IF Empty(aTipCar)
      // Busca sin Proveedor
      cWhere:="INC_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)
 
      cSql:=" SELECT INC_TIPO FROM DPINVCARACTERISTICAS "+;
            " WHERE "+cWhere+;
            " GROUP BY INC_TIPO "

      aItem:=ATABLE(cSql)

   ENDIF

   oCol:=EJECUTAR("GRIDSETITEM",oGrid,"MOV_TIPCAR",aItem)

   EJECUTAR("COMGRIDSETCARACT",oGrid)

RETURN .T.
// EOF
