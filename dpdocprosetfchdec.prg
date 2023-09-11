// Programa   : DPDOCPROSETFCHDEC
// Fecha/Hora : 29/07/2022 13:24:28
// Propósito  : Cambiar la Fecha de Declaración de la Factura de Compra Según la Retención de IVA
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cCodSuc,cTipDoc,cCodigo,cNumero,dFchDec)
   LOCAL cWhere,cWhereRti,cWhereM,oDocRti,cTipRti,dFchDecD,cActual:="",cNumCbt,cTipTra:="D",dFecha

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cTipDoc:="FAC",;
           cCodigo:=SQLGET("DPDOCPRO","DOC_CODIGO","DOC_TIPDOC"+GetWhere("=",cTipDoc)),;
           cNumero:=SQLGET("DPDOCPRO","DOC_NUMERO","DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND DOC_CODIGO"+GetWhere("=",cCodigo))

   cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
           "DOC_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
           "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
           "DOC_NUMERO"+GetWhere("=",cNumero)+" AND "+;
           "DOC_TIPTRA"+GetWhere("=","D"    )


   dFchDecD :=SQLGET("DPDOCPRO","DOC_FCHDEC,DOC_CBTNUM,DOC_FECHA",cWhere)
   cNumCbt  :=DPSQLROW(2,"")
   dFecha   :=DPSQLROW(3,CTOD(""))

   IF !Empty(cNumCbt)

     cWhereM:="MOC_CODSUC"+GetWhere("=",cCodSuc )+" AND "+;
              "MOC_NUMCBT"+GetWhere("=",cNumCbt )+" AND "+;
              "MOC_FECHA "+GetWhere("=",dFchDecD)+" AND "+;
              "MOC_TIPO  "+GetWhere("=",cTipDoc )+" AND "+;
              "MOC_DOCUME"+GetWhere("=",cNumero )+" AND "+;
              "MOC_CODAUX"+GetWhere("=",cCodigo )+" AND "+;
              "MOC_TIPTRA"+GetWhere("=",cTipTra )

     cActual:=SQLGET("DPASIENTOS","MOC_ACTUAL",cWhereM)

   ENDIF

   cTipRti  :=IF(cTipDoc="FAC","RTI","RVI")

   cWhereRti:="RTI_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
              "RTI_DOCTIP"+GetWhere("=",cTipRti)+" AND "+;
              "RTI_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
              "RTI_NUMERO"+GetWhere("=",cNumero)

   oDocRti:=OpenTable("SELECT * FROM DPDOCPRORTI WHERE "+cWhereRti,.T.)

   DEFAULT dFchDec:=oDocRti:RTI_FCHDEC

// oDocRti:Browse()
   oDocRti:End()
   cNumRti:=oDocRti:RTI_DOCNUM

   // Cambia la Fecha del documento, igualmente debe cambiar la fecha del comprobante contable
   IF dFchDec<>dFchDecD .or. .t.
      EJECUTAR("DPCBTECREA",cCodSuc,dFchDecD,cNumero,cActual,"Cambio de Fecha Declaración Según RTI")
      SQLUPDATE("DPDOCPRO"  ,"DOC_FCHDEC",dFchDecD,cWhere)
      
      IF !Empty(cWhereM)
        SQLUPDATE("DPASIENTOS","MOC_FECHA",dFchDecD,cWhereM)
      ENDIF
   
   ENDIF

// ? cWhere,dFchDec,dFchDecD,"Declaracion",cNumCbt,"cNumCbt",cActual,"cActual"

RETURN .T.
// EOF
