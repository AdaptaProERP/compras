// Programa   : COMGRIDSETTIPCAR
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

   IF oGrid:nOption=0 .OR. Empty(oGrid:INV_CODCAR)
      RETURN {}
   ENDIF

   oGrid:lLeeInvCar:=.T.  // busca en INVCARACTERISTICAS

   cWhere:="INC_CODPRO"+GetWhere("=",oDoc:DOC_CODIGO )+" AND "+;
           "INC_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)

   cSql:=" SELECT INC_TIPO FROM DPINVCARACTERISTICAS "+;
         " WHERE "+cWhere+;
         " GROUP BY INC_TIPO "

   aItem:=ATABLE(cSql)

   IF Empty(aItem)
      // Busca sin Proveedor

      cWhere:="INC_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)
 
      cSql:=" SELECT INC_TIPO FROM DPINVCARACTERISTICAS "+;
            " WHERE "+cWhere+;
            " GROUP BY INC_TIPO "

      aItem:=ATABLE(cSql)

   ENDIF

   IF Empty(aItem)

      cWhere:="INC_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)

      cSql:=" SELECT INC_TIPO FROM DPINVCARACTERISTICAS "+;
            " WHERE "+cWhere+;
            " GROUP BY INC_DESCRI "

      aItem:=ATABLE(cSql)

   ENDIF

   IF Empty(aItem)

      // Busca en Grupo de Características por Grupo

      cWhere:="GCD_CODGRU"+GetWhere("=",oGrid:INV_CODCAR)
             
      cSql  :=" SELECT GCD_TIPO FROM DPGRUCARACTDET "+;
              " WHERE "+cWhere+;
              " GROUP BY GCD_TIPO "

      aItem:=ATABLE(cSql)

      oGrid:lLeeInvCar:=.F.

   ENDIF

   IF !Empty(aItem)
      AADD(aItem,"-Agregar")
   ENDIF

   oGrid:aItems_tipcar:=ACLONE(aItem)

   IF !Empty(aItem)
     oCol:=EJECUTAR("GRIDSETITEM",oGrid,"MOV_TIPCAR",aItem)
   ENDIF

   EJECUTAR("COMGRIDSETCARACT",oGrid)

RETURN .T.
// EOF
