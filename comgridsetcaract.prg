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

   IF oGrid=NIL .OR. oGrid:nOption=0 .OR. Empty(oGrid:INV_CODCAR)
      RETURN {}
   ENDIF

   // No tiene características por producto, esto fue leido en COMGRIDSETTIPCAR

   IF !oGrid:lLeeInvCar

      // Busca en Grupo de Características por Grupo

      cWhere:="GCD_CODGRU"+GetWhere("=",oGrid:INV_CODCAR)+" AND "+;
              "GCD_TIPO  "+GetWhere("=",oGrid:MOV_TIPCAR)

      cSql  :=" SELECT GCD_DESCRI FROM DPGRUCARACTDET "+;
              " WHERE "+cWhere+;
              " GROUP BY GCD_DESCRI "

      aItem:=ATABLE(cSql)

   ELSE

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

        cSql  :=" SELECT INC_DESCRI FROM DPINVCARACTERISTICAS "+;
                " WHERE "+cWhere+;
                " GROUP BY INC_DESCRI "

        aItem:=ATABLE(cSql)

       ENDIF

    ENDIF

    // Busca los Items, INV_CODCAR // Codigo de Características
    IF !Empty(aItem) .AND. ISTABINC("DPINVCARACTERISTICAS")
       AADD(aItem,"-Agregar")
    ENDIF

    oGrid:aItems_nomcar:=ACLONE(aItem)
    oCol:=EJECUTAR("GRIDSETITEM",oGrid,"MOV_NOMCAR",aItem)

RETURN .T.
// EOF
