// Programa   : VTAGRIDPOSSAV
// Fecha/Hora : 09/10/2005 11:50:33
// Propósito  : Ejecución Post-Grabar
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación : Ventas
// Tabla      : DPMOVINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
 LOCAL nNeto,oDoc,cWhere,oTable,nExport:=0,oTable,aLote:={},I,oPrecio,cPeso

 IF oGrid=NIL
   RETURN .F.
 ENDIF

 oDoc :=oGrid:oHead
 nNeto:=oDoc:DOC_NETO

 IIF(oDp:nVersion<5.1,EJECUTAR("DOCBTNCANCELOFF",oDoc),NIL) // No es necesario en Version 5.1

 oDoc:DOC_NETO :=EJECUTAR("DOCTOTAL",oDoc,.T.,.T.,NIL,oDoc:lVenta)
 oDoc:nBruto:=oDp:nBruto
 oDoc:nIVA  :=oDp:nIva

 oDoc:oNeto:Refresh(.T.)
 oDoc:oDOC_CODMON:ForWhen()
 oDoc:oIVA:Refresh(.T.)

 IF oGrid:cMetodo="S" .AND. !Empty(oGrid:aSeriales)

   // 14/08/2023 solo Guarda los Seriales Marcados
   IF ValType(oGrid:aSeriales[1])="A" .AND. "Concesionario Automotriz"$oDp:cForInv 
      ADEPURA(oGrid:aSeriales,{|a,n| !a[6]})
   ENDIF

   EJECUTAR("SERGRABAR",oGrid)

 ENDIF

 IF !Empty(oGrid:aComponentes) .AND. !oGrid:lComent
   EJECUTAR("VTAGRIDSAVCOMP",oGrid)
 ENDIF

 IF !Empty(oGrid:aEsquema) .AND. !oGrid:lComent
   EJECUTAR("VTAGRIDSAVEESQ",oGrid)
 ENDIF

 IF oGrid:nOption=1 .AND. !Empty(oGrid:MOV_ASODOC)

/*
   cWhere:="MOV_DOCUME"+GetWhere("=",oGrid:MOV_ASODOC)+" AND "+;
           "MOV_TIPDOC"+GetWhere("=",oGrid:MOV_ASOTIP)+" AND "+;
           "MOV_ITEM"  +GetWhere("=",oGrid:MOV_ITEM_A)+" AND "+;
           "MOV_CODSUC"+GetWhere("=",oGrid:oHead:DOC_CODSUC)
*/
   cWhere:="MOV_CODSUC"+GetWhere("=",oGrid:oHead:DOC_CODSUC)+" AND "+;
           "MOV_TIPDOC"+GetWhere("=",oGrid:MOV_ASOTIP      )+" AND "+;
           "MOV_DOCUME"+GetWhere("=",oGrid:MOV_ASODOC)

   IF !Empty(oGrid:MOV_ITEM_A)

       cWhere:=cWhere+" AND MOV_ITEM"  +GetWhere("=",oGrid:MOV_ITEM_A)

   ELSE

       cWhere:=cWhere+" AND MOV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)+" AND MOV_INVACT=1"

       cPeso:=SQLGET("DPINV","INV_REQPES","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))

       oGrid:MOV_IMPORT:=IF(cPeso="S",oGrid:MOV_PESO,oGrid:MOV_CANTID)

   ENDIF
           

   oTable:=OpenTable("SELECT MOV_EXPORT,MOV_CXUNDE FROM DPMOVINV WHERE "+cWhere,.T.)
   oTable:Replace("MOV_EXPORT",oTable:MOV_EXPORT+oGrid:MOV_IMPORT)
   // JN 11/06/2012
   oTable:Replace("MOV_CXUNDE",oTable:MOV_CXUNDE+oGrid:MOV_CXUNDE)
// ? "AQUI DESCUENTA",oTable:MOV_CXUNDE,oGrid:MOV_CXUNDE,"oGrid:MOV_CXUNDE"
   oTable:Commit(cWhere)

//oTable:Browse()
   oTable:End(.T.)

 ENDIF

 IF oDoc:lVenta
   // Obtengo la Cantidad de Items

/*
   16/01/2024, innecesariom replazado por COUNT()
   
   oTable:=OpenTable("SELECT COUNT(*) AS MOV_ITEMS FROM DPMOVINV "+;
                     "WHERE MOV_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+" AND "+;
                     "MOV_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+" AND "+;
                     "MOV_CODCTA"+GetWhere("=",oDoc:DOC_CODIGO)+" AND "+;
                     "MOV_DOCUME"+GetWhere("=",oDoc:DOC_NUMERO)+" AND "+;
                     "MOV_APLORG"+GetWhere("=", "V")+" AND "+;
                     "MOV_INVACT"+GetWhere("=",1),.T.)

   oDoc:nItems:=oTable:MOV_ITEMS
   oTable:End()
*/

  oDoc:nItems:=COUNT("DPMOVINV","MOV_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC)+" AND "+;
                                "MOV_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC)+" AND "+;
                                "MOV_CODCTA"+GetWhere("=",oDoc:DOC_CODIGO)+" AND "+;
                                "MOV_DOCUME"+GetWhere("=",oDoc:DOC_NUMERO)+" AND "+;
                                "MOV_APLORG"+GetWhere("=", "V"           )+" AND "+;
                                "MOV_INVACT"+GetWhere("=",1))

//    oDoc:oItems:Refresh(.T.)

 ENDIF

 /*
 // Guardar Horarios
 */
 IF oGrid:cUtiliz="H" .AND. oGrid:oItem="O"

    oGrid:oItem:cItem  :=oGrid:MOV_ITEM
    oGrid:oItem:cNumero:=oGrid:MOV_DOCUME

    EJECUTAR("GRIDHORASAVE",oGrid:oItem,oGrid)

    oGrid:oItem:=NIL

 ENDIF

 //
 // Si el Memo esta Vacio
 // Elimina el Campo Memo
 //

 IF oGrid:nOption=3 .AND. !Empty(oGrid:aMemo) .AND. !Empty(oGrid:aMemo[7]) .AND. Empty(oGrid:aMemo[8]+oGrid:aMemo[9])

   SQLUPDATE(oDp:cDpMemo,"MEM_NUMERO"+GetWhere("=",oGrid:aMemo[7])+" AND MEM_ID"+GetWhere("=",oGrid:cIdMemo))


 ENDIF

/*
// Cristian Abreu 24/10/2008
// Ya viene importado no puede afectar a los proximos Items
// Codigo Restaura por JN, es Necesario para Items Importados
*/

 IF !Empty(oGrid:MOV_ASODOC) .AND. oGrid:nOption=1
    oGrid:MOV_ASODOC:=""
    oGrid:MOV_ASOTIP:=""
    oGrid:MOV_ITEM_A:=""
    oGrid:MOV_IMPORT:=0
 ENDIF

/*
 IF !oDoc:lVenta
   EJECUTAR("DPCAPASINV",oGrid:MOV_CODIGO,oGrid:MOV_COSTO,oGrid:MOV_PRECIO)
 ENDIF
*/


 // 27-05-2012 Se agrego oGrid:cRegulado='S', para que solo haga el calculo cuando en la ficha
 // INV_PREREG='S' de lo contrario no lo tomara en cuenta, es decir no se editara. TJ
 IF !oDoc:lVenta .AND. oGrid:cRegulado='S'

   cWhere:="PRE_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)+ " AND "+;
           "PRE_UNDMED"+GetWhere("=",oDp:cUndMed     )+ " AND "+;
           "PRE_LISTA" +GetWhere("=",oDp:cPrecio     )+ " AND "+;
           "PRE_CODMON"+GetWhere("=",oDp:cMoneda     )

   IF (oGrid:MOV_PRECIO<>SQLGET("DPPRECIOS", "PRE_PRECIO", cWhere))

   
     oPrecio:=OpenTable("SELECT * FROM DPPRECIOS WHERE  "+cWhere,.T.)

     IF oPrecio:RecCount()=0
        oPrecio:AppendBlank()
        cWhere :=""
     ENDIF

     EJECUTAR("DPPRECIOSHIS"  ,oGrid:MOV_CODIGO,oDp:cUndMed,oDp:cPrecio,oDp:cMoneda)
     EJECUTAR("DPPRECIOPRECIO",oGrid:MOV_CODIGO,oDp:cUndMed,oDp:cPrecio,oDp:cMoneda,.T.)

     oPrecio:Replace("PRE_CODIGO",oGrid:MOV_CODIGO)
     oPrecio:Replace("PRE_UNDMED",oDp:cUndMed     )
     oPrecio:Replace("PRE_LISTA" ,oDp:cPrecio     )
     oPrecio:Replace("PRE_PRECIO",oGrid:MOV_PRECIO)
     oPrecio:Replace("PRE_CODMON",oDp:cMoneda     )
     oPrecio:Replace("PRE_FECHA" ,oDp:dFecha      )
     oPrecio:Replace("PRE_HORA"  ,TIME()          )
     oPrecio:Replace("PRE_USUARI",oDp:cUsuario    )
     oPrecio:Replace("PRE_ORIGEN","F"             )
     oPrecio:Replace("PRE_IP"    ,GETHOSTBYNAME() )

     oPrecio:Commit(cWhere)
     oPrecio:End(.T.)

   ENDIF

 ENDIF

 // ? oGrid:MOV_CODALM,Grid:oHead:cCodAlm,"POST-GRABAR"
 // 16/01/2024, Creará el registro en tabla DPINVCARACTERISTICAS, CASO QUE NO EXISTE Y SEA INCLUIDO POR EL USUARIO

 IF !Empty(oGrid:MOV_NOMCAR+oGrid:MOV_TIPCAR) .AND.  !ISSQLFIND("DPINVCARACTERISTICAS","INC_TIPO"+GetWhere("=",oGrid:MOV_TIPCAR)+" AND INC_DESCRI"+GetWhere("=",oGrid:MOV_NOMCAR))

    oTable:=OpenTable("SELECT * FROM DPINVCARACTERISTICAS",.F.)
    oTable:AppendBlank()
    oTable:Replace("INC_CODIGO",oGrid:MOV_CODIGO)
    oTable:Replace("INC_CODMON",oGrid:oHead:DOC_CODMON)
    oTable:Replace("INC_DESCRI",oGrid:MOV_NOMCAR)
    oTable:Replace("INC_TIPO"  ,oGrid:MOV_TIPCAR)
    oTable:Commit("")
    oTable:End()

 ENDIF

 CursorArrow()

RETURN .T.

// EOF
