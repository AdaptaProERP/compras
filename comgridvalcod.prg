// Programa   : COMGRIDVALCOD
// Fecha/Hora : 09/10/2005 12:27:09
// Propósito  : Valida Código del Producto
// Creado Por : Juan Navas
// Llamado por: DPFACTURAV
// Aplicación : Ventas
// Tabla      : DPMOVINV

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGrid)
   LOCAL nExi,nPrecio:=0,oCol,cEquiv:="",dFecha,cHora:="",oCol,nCosto:=0,cWhere,cWhereI
   LOCAL lSerial:=.T.
   LOCAL nCant  := 0
   LOCAL cCod   :=""
   LOCAL lRet   :=.F.
   LOCAL oColL  :=NIL
  

   DEFAULT oDp:lColorLotes:=.T.	

   // oDp:lColorLotes:=.T.	

   IF oGrid=NIL
      RETURN .F.
   ENDIF
 
/*
   oColL:=oGrid:GetCol("MOV_NOMCAR",.F.)
   
   // Apaga el COMBOBOX
   IF ValType(oColL)="O"
     oGrid:oBrw:aCols[oColL:nCol]:aEditListTxt  :=NIL
     oGrid:oBrw:aCols[oColL:nCol]:aEditListBound:=NIL
     oGrid:oBrw:aCols[oColL:nCol]:nEditType     :=1
     oColL:bWhen:={||.T.}
     oGrid:SET("MOV_NOMCAR",SPACE(LEN(oGrid:MOV_NOMCAR)),.T.)
   ENDIF

   oColL:=oGrid:GetCol("MOV_TIPCAR",.F.)
   
   // Apaga el COMBOBOX
   IF ValType(oColL)="O"
     oGrid:oBrw:aCols[oColL:nCol]:aEditListTxt  :=NIL
     oGrid:oBrw:aCols[oColL:nCol]:aEditListBound:=NIL
     oGrid:oBrw:aCols[oColL:nCol]:nEditType     :=1
     oColL:bWhen:={||.T.}
     oGrid:SET("MOV_TIPCAR",SPACE(LEN(oGrid:MOV_TIPCAR)),.T.)
   ENDIF
*/

   cCod:=ALLTRIM(oGrid:MOV_CODIGO)

   IF !VTAGRIDCODINV(oGrid)

     lRet   :=.F.
     cWhereI:=EJECUTAR("GETWHERELIKE","DPINV","INV_DESCRI",cCod,"")

     IF !Empty(cWhereI)

        cWhere :="("+oGrid:GetCol("MOV_CODIGO"):cWhereListBox+") AND "+cWhereI
        nCant  := COUNT("DPINV",cWhere)
        cCod   :=""

        IF nCant=1
           cCod:=SQLGET("DPINV","INV_CODIGO",cWhere)
        ELSE
           cCod:=EJECUTAR("REPBDLIST","DPINV","INV_CODIGO,INV_DESCRI",.F.,cWhere,NIL,NIL,cCod,NIL,NIL,"INV_CODIGO") // oDocCli:oDOC_CODIGO)
        ENDIF

        IF !Empty(cCod) .AND. ISSQLFIND("DPINV","INV_CODIGO"+GetWhere("=",cCod))

           oGrid:Set("MOV_CODIGO",cCod,.T.)
           oGrid:GetCol("MOV_CODIGO"):Edit()

           IF VTAGRIDCODINV(oGrid)
              lRet:=.T.
           ENDIF

         ENDIF

     ENDIF
    
     IF !lRet
       RETURN lRet
     ENDIF

   ENDIF

   IF !VTAGRIDCODINV(oGrid)
     RETURN .F.
   ENDIF

   EJECUTAR("VTAGRIDEXISTE",oGrid,.T.)

// EJECUTAR("VTAGRIDPRECIO",oGrid)

   IF oGrid:nOption=1

     dFecha :=SQLGET("DPMOVINV","MOV_FECHA,MOV_HORA,MOV_PRECIO,MOV_COSTO",;
                                "MOV_CODSUC"+GetWhere("=",oGrid:MOV_CODSUC)+" AND "+;
                                "MOV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)+" AND "+;
                                "MOV_INVACT =1 AND MOV_APLORG"+GetWhere("=","C")+" ORDER BY CONCAT(MOV_FECHA,MOV_HORA) DESC LIMIT 1 ")

/*
     cHora  :=SQLGET("DPMOVINV","MAX(MOV_HORA)","MOV_CODSUC"+GetWhere("=",oGrid:MOV_CODSUC)+" AND "+;
                                                "MOV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)+" AND "+;
                                                "MOV_INVACT =1 AND MOV_PRECIO>0 AND "+;
                                                "MOV_FECHA"+GetWhere("=",dFecha))

     nPrecio:=SQLGET("DPMOVINV","MOV_PRECIO,MOV_COSTO","MOV_CODSUC"+GetWhere("=",oGrid:MOV_CODSUC)+" AND "+;
                                             "MOV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)+" AND "+;
                                             "MOV_INVACT =1 AND MOV_PRECIO>0 AND  "+;
                                             "MOV_FECHA"+GetWhere("=",dFecha)+ " AND "+;
                                             "MOV_HORA" +GetWhere("=",cHora ))
*/
     nCosto :=IF(Empty(oDp:aRow),nCosto ,oDp:aRow[4])
     nPrecio:=IF(Empty(oDp:aRow),nPrecio,oDp:aRow[3])

     IF nPrecio>0
       oGrid:Set("MOV_PRECIO",nPrecio,.T.)
     ENDIF

     IF nCosto>0
       oGrid:Set("MOV_COSTO",nCosto,.T.)
     ENDIF

     IF nCosto>0 .AND. oGrid:oHead:DOC_VALCAM>=1
       oGrid:Set("MOV_COSDIV",nCosto/oGrid:oHead:DOC_VALCAM,.T.)
     ENDIF


   ENDIF

   IF oGrid:cMetodo="S" .AND. oDoc:nPar_InvFis<>0 // Descuento Físico

      IF "Concesionario Automotriz"$oDp:cForInv 
         EJECUTAR(IIF(oDoc:nPar_InvFis=1,"SERENTSERIALA","ERSALSERIALA"),oGrid)
      ELSE
         EJECUTAR(IIF(oDoc:nPar_InvFis=1,"SERENTRADA","SERSALIDA"),oGrid)
      ENDIF
      
      IF Empty(oGrid:aSeriales)
        oGrid:GetCol("MOV_CODIGO"):lListBox:=.F.
        RETURN .F.
      ENDIF

      // oGrid:GetCol("MOV_CANTID"):VarPut(LEN(oGrid:aSeriales)) 10/03/2023
      oGrid:GetCol("MOV_CODIGO"):GoNextCol() // 10/08/2023
      // oGrid:GetCol("MOV_CODIGO"):lValid:=.T. // 10/08/2023
      // ? oGrid:oBrw:nColSel,"COMGRIDVALCOD"

   ENDIF

   IF oGrid:cMetodo="C" .AND. oDoc:nPar_InvFis<>0 // Descarga Física de LOTES

      IF !EJECUTAR( IIF(oDoc:nPar_InvFis>0,"DPLOTE_ENT","DPLOTE_SAL"),oGrid)
         oGrid:GetCol("MOV_CODIGO"):lListBox:=.F.
         RETURN .F.
      ELSE
         RETURN .T.
      ENDIF

   ENDIF

// ? oDp:lColorLotes,"oDp:lColorLotes",oGrid:cMetodo

   IF (oGrid:cMetodo="C" .OR. oGrid:cMetodo="L") .AND. oDp:lColorLotes

     oCol:=oGrid:GetCol("MOV_LOTE",.F.)

     IF ValType(oCol)="O"
       oCol:aItems:=ATABLE("SELECT COL_CODIGO FROM DPCOLORES ORDER BY COL_CODIGO")
     ENDIF

   ENDIF

   IF oGrid:lTallas

     EJECUTAR("DPTALLASGET", oGrid , ( oDoc:nPar_InvFis=1 .OR. oDoc:nPar_InvLog=1 ) ,  oDoc:nPar_InvFis=0 )

     IF Empty(oGrid:aTallas)
        RETURN .F.
     ENDIF

     VTAGRIDCODINV(oGrid)

// ? oGrid:ClassName()

     EJECUTAR("VTAGRIDPRECIO",oGrid,.T.)

   ENDIF

   SysRefresh(.T.)

RETURN .T.

FUNCTION VTAGRIDCODINV(oGrid)
   LOCAL nExi,nPrecio:=0,oCol,cEquiv:="",cCodInv:="",aRow:={},aUndMed:={}
   LOCAL oDoc   :=oGrid:oHead
   LOCAL cZonaNL:=oDoc:cZonaNL
   LOCAL nCol   :=3 // IIF(!cZonaNL="N",5,3) // Col=3 (Compras)
   LOCAL cTipIva

// ? oDoc:cZonaNL,"oDoc:cZonaNL"

   IF EMPTY(oGrid:MOV_CODIGO)
      RETURN .F.
   ENDIF

   oGrid:cEditar:="N"

   cCodInv:=SQLGET("DPINV","INV_CODIGO,INV_METCOS,INV_EDITAR,INV_DESCRI,INV_TALLAS,INV_PREREG,INV_PVPORG,INV_IVA","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))
   aRow   :=ACLONE(oDp:aRow)

// IF !(SQLGET("DPINV","INV_CODIGO","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))==oGrid:MOV_CODIGO)

   IF Empty(cCodInv) 

      // BUSCA EL EQUIVALENTE
      cEquiv:=SQLGET("DPEQUIV","EQUI_CODIG,EQUI_MED","EQUI_BARRA"+GetWhere("=",oGrid:MOV_CODIGO))

      IF Empty(cEquiv)
         RETURN .F.
      ENDIF

      oGrid:Set("MOV_UNDMED",oDp:aRow[2],.T.)
      oGrid:GetCol("MOV_CODIGO"):lListBox:=.F.  
      oGrid:Set("MOV_CODIGO",cEquiv,.T.)
      oGrid:GetCol("MOV_CODIGO"):lTry:=.T. // Repite el Valid  

      RETURN .F.

   ENDIF

   /*
   // Debe buscar las Unidades de Medidas para Compras
   */
   IF oGrid:nOption=1

     aUndMed:=ASQL("SELECT IME_UNDMED,IME_CANTID FROM DPINVMED WHERE IME_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)+" AND "+;
                                                       "IME_COMPRA='S' ORDER BY IME_CANTID DESC")
     IF LEN(aUndMed)>0
       oGrid:Set("MOV_UNDMED",aUndMed[1,1],.T.)
     ENDIF

   ENDIF

   EJECUTAR("VTAGRIDVALUND",oGrid)

   IF EMPTY(oGrid:MOV_NUMMEM) 
      oGrid:NewMemo(SQLGET("DPINV","INV_NUMMEM","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO)))
   ELSE
      oGrid:INV_DESCRI:=aRow[4] // INV_DESCRI
   ENDIF

   oGrid:cMetodo   :=aRow[2] // INV_METCOS
   oGrid:cEditar   :=aRow[3] // INV_EDITAR
   oGrid:cInvDescri:=aRow[4] // INV_DESCRI
   oGrid:cTallas   :=aRow[5]
   oGrid:lTallas   :=!Empty(oGrid:cTallas)
   oGrid:cRegulado :=aRow[6]

   // Asume Precio de Venta Regulado
   IF oGrid:nOption=1 .AND. oGrid:cRegulado="S"
     oGrid:Set("MOV_PRECIO",aRow[7],.T.)
   ENDIF

   oGrid:Set("MOV_TIPIVA",aRow[8],.T.)
   cTipIva:=aRow[8]

   // Si no es Regulado el Precio es Borrado
   IF oGrid:cRegulado="N"
     oGrid:Set("MOV_PRECIO",0,.T.)
   ENDIF

// oGrid:cMetodo:=SQLGET("DPINV","INV_METCOS","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))
   oCol:=oGrid:GetCol("INV_DESCRI")
   oCol:RunCalc()
// oCol:bWhen :=IIF(SQLGET("DPINV","INV_EDITAR","INV_CODIGO"+GetWhere("=",oGrid:MOV_CODIGO))="S",".T.",".F.")

   oCol:bWhen :=IIF(oGrid:cEditar="S",".T.",".F.")

// ? oGrid:oHead:DOC_ORIGEN,"oGrid:oHead:DOC_ORIGEN"

   IF LEFT(oGrid:oHead:DOC_ORIGEN,1)="N" // Indica si el Documento Calcula IVA
     oGrid:MOV_IVA   :=EJECUTAR("IVACAL",cTipIva,nCol,oDoc:DOC_FECHA) // IVA (Nacional o Zona Libre
     oGrid:MOV_IMPOTR:=EJECUTAR("IVACAL",cTipIva,6   ,oDoc:DOC_FECHA) // OTROS IMPUESTOS

// ? oGrid:MOV_IVA,"oGrid:MOV_IVA",cTipIva,nCol,oDoc:DOC_FECHA

     oGrid:Set("MOV_IVA",oGrid:MOV_IVA,.T.)
   ENDIF

  // EJECUTAR("VTAGRIDCOSTO" ,oGrid) // Determina el Costo

RETURN .T.
// EOF


