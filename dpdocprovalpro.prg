// Programa   : DPDOCPROVALPRO
// Fecha/Hora : 08/10/2005 21:36:19
// Propósito  : Valida Código del Proveedor
// Creado Por : Juan Navas
// Llamado por: DPPRODOC
// Aplicación : Ventas
// Tabla      : DPDOCPRO

#INCLUDE "DPXBASE.CH"

PROCE MAIN(oGet,oDoc)

   LOCAL lZero:=.F.,lChange:=.F.,cWhere 
   LOCAL oDatPro

   IF (!oDoc:DOC_CODIGO_=oDoc:DOC_CODIGO) .AND. oDoc:DOC_CODIGO_=STRZERO(0,10)
      oDoc:BtnPaint() // Proveedor Zero fué Cambiado
      lChange  :=.T.
   ENDIF

   IF oDoc:DOC_CODIGO=STRZERO(0,10)

      lZero:=.T.
      oDoc:oProNombre:Refresh(.T.)
      oDoc:BtnPaint()

      IF !EJECUTAR("DPPROVEEDORCERO",oDoc:nOption,oDoc:oDOC_CODIGO)
         RETURN .F.
      ENDIF

      // Forza el Nuevo acceder al siguiente Control
      oDoc:oProNombre:Refresh(.T.)
      oDoc:oDOC_CODIGO:oWnd:nLastKey == VK_TAB
      oDoc:oDOC_CODIGO:oWnd:GoNextCtrl( oDoc:oDOC_CODIGO:hWnd )
      lChange:=.F.

   ELSE

      IF !EJECUTAR("DOCPROVALID",oDoc:DOC_CODIGO) // Valida Código del Proveedor
         RETURN .F.
      ENDIF

   ENDIF

/*
   IF oDoc:nOption=1 .AND. Empty(oDoc:DOC_CODVEN) .AND. !lZero

      EJECUTAR("DPDOCCLIULT",oDoc,oDoc:DOC_CODSUC,oDoc:DOC_TIPDOC,oDoc:DOC_CODIGO)

   ENDIF
*/

   oDatPro:=OpenTable("SELECT PRO_DESCUE,PRO_DIAS,PRO_CONDIC,PRO_ZONANL,PRO_RESIDE,PRO_ENOTRA,PRO_CODMON FROM DPPROVEEDOR WHERE PRO_CODIGO"+GetWhere("=", oDoc:DOC_CODIGO),.T.)
   oDoc:cZonaNL    :=IF(Empty(oDatPro:PRO_ZONANL),"N",oDatPro:PRO_ZONANL) // JN 27/09/2016
   oDoc:cReside    :=oDatPro:PRO_RESIDE
   oDoc:DOC_CODMON :=oDatPro:PRO_CODMON
   oDoc:lPar_Moneda:=UPPE(oDatPro:PRO_ENOTRA)="S"
   oDatPro:End()

   IF oDoc:nOption=1 .AND. oDoc:cReside="N"

      oDoc:oScroll:Put("DOC_ORIGEN","I")
      oDoc:Set("DOC_ORIGEN","I") 

   ENDIF

   IF oDoc:nOption=1 .AND. Empty(oDoc:DOC_DCTO)

     oDoc:DOC_DCTO  :=oDatPro:PRO_DESCUE
     oDoc:DOC_CONDIC:=oDatPro:PRO_CONDIC
     oDoc:DOC_PLAZO :=oDatPro:PRO_DIAS
     oDoc:oDOC_DCTO:VarPut(oDoc:DOC_DCTO,.T.)

   ENDIF

   // Requiere el Ultimo Precio de Venta
   oDoc:CODCLI    :=""   
  
// IF oDatPro:CLI_PRECIO="S"
//   oDoc:CODCLI:=oDoc:DOC_CODIGO
// ENDIF

    IF (oDoc:nOption=3 .OR. oDoc:lSaved) .AND. !oDoc:DOC_CODIGO_=oDoc:DOC_CODIGO

      cWhere:="MOV_CODSUC"+GetWhere("=",oDoc:DOC_CODSUC )+" AND "+;
              "MOV_TIPDOC"+GetWhere("=",oDoc:DOC_TIPDOC )+" AND "+;
              "MOV_CODCTA"+GetWhere("=",oDoc:DOC_CODIGO_)+" AND "+;
              "MOV_DOCUME"+GetWhere("=",oDoc:DOC_NUMERO )+" AND MOV_INVACT=1 AND MOV_APLORG='C' "

      SQLUPDATE("DPMOVINV","MOV_CODCTA",oDoc:DOC_CODIGO,cWhere)

    ENDIF

    oDoc:DOC_CODIGO_:=oDoc:DOC_CODIGO // Proveedor Validado

   IF lChange
      oDoc:BtnPaint()
      oDoc:oBar:Refresh(.T.)
   ENDIF

   EJECUTAR("DPDOCPROVALCAM",oDoc)

  //  DPFOCUS(oGet)

   SysRefresh(.T.)

RETURN .T.
// EOF




