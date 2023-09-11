// Programa   : DPDOCPRORTIDEL
// Fecha/Hora : 29/09/2012 00:42:08
// Propósito  : Anular Retención de IVA (RTI/RVI) y Anula la CxP, Elimina Asientos Contables
//              Tambien Anula Retenciones de IVA
// Creado Por : Juan Navas
// Llamado por: DPDOCPROPREDEL 
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

FUNCTION MAIN(cCodSuc,cTipDoc,cCodigo,cDocNum,nInv,cNumCbt,dFecha,lDelRti,lDelIslr)
   LOCAL cWhere,cTipRti,cNumRti,cNumDoc,cDocTip,dFecha,cEstado,cNumRet

   DEFAULT cCodSuc:=oDp:cSucursal,;
           cTipDoc:="FAC"        ,;
           cCodigo:="J312344202" ,;
           cDocNum:=STRZERO(0,10),;
           nInv   :=0   ,;
           lDelRti :=.T.,;
           lDelIslr:=.T. 

   cTipRti:=IF(cTipDoc="FAC","RTI","RVI")
   cTipRti:=IF(cTipDoc="DEB","RDI",cTipDoc)
   cEstado:=IF(nInv   =0    ,"NU" ,"AC" )

   // Anular Asientos Contables
  //? cCodSuc,cTipDoc,cCodigo,cDocNum,nInv,cNumCbt,dFecha,lDelRti,lDelIslr,"cCodSuc,cTipDoc,cCodigo,cDocNum,nInv,cNumCbt,dFecha,lDelRti,lDelIslr"

   IF nInv=0 .AND. !Empty(cNumCbt)

        SQLDELETE("DPASIENTOS","MOC_NUMCBT"+GetWhere("=",cNumCbt)+" AND "+;
                               "MOC_FECHA "+GetWhere("=",cFecha )+" AND "+;
                               "MOC_TIPO  "+GetWhere("=",cTipDoc)+" AND "+;
                               "MOC_DOCUME"+GetWhere("=",cDocNom)+" AND "+;
                               "MOC_CODSUC"+GetWhere("=",cCodDoc)+" AND "+;
                               "MOC_ACTUAL"+GetWhere("=","N"    )+" AND "+;       
                               "MOC_TIPTRA"+GetWhere("=","D"    )+" AND "+;
                               "MOC_ORIGEN"+GetWhere("=","COM"  )) 

   ENDIF

   // Buscamos la Retencion
  
   cWhere:="RTI_CODSUC"+GetWhere("=",cCodSuc        )+" AND "+;
           "RTI_TIPDOC"+GetWhere("=",cTipDoc        )+" AND "+;
           "RTI_CODIGO"+GetWhere("=",cCodigo        )+" AND "+;
           "RTI_NUMERO"+GetWhere("=",cDocNum        )

    cNumRti:=SQLGET("DPDOCPRORTI","RTI_DOCNUM,RTI_DOCTIP",cWhere)
    cDocTip:=IF( Empty(oDp:aRow),"",oDp:aRow[2])


   // Borra los Asientos de los Documentos Diferentes a Retencion

    IF  lDelRti .AND. !Empty(cNumRti)

      cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
              "DOC_TIPDOC"+GetWhere("=",cDocTip)+" AND "+;
              "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
              "DOC_NUMERO"+GetWhere("=",cNumRti)+" AND DOC_TIPTRA='D'"

      SQLUPDATE("DPDOCPRO",{"DOC_ESTADO","DOC_ACT"},{cEstado,nInv},cWhere)

      cNumCbt:=SQLGET("DPDOCPRO","DOC_CBTNUM,DOC_FECHA",cWhere)
 
      IF (nInv=0 .AND. !Empty(cNumCbt))

        dFecha:=oDp:aRow[2]

        SQLDELETE("DPASIENTOS","MOC_NUMCBT"+GetWhere("=",cNumCbt)+" AND "+;
                               "MOC_FECHA "+GetWhere("=",dFecha )+" AND "+;
                               "MOC_TIPO  "+GetWhere("=",cDocTip)+" AND "+;
                               "MOC_DOCUME"+GetWhere("=",cNumRti)+" AND "+;
                               "MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                               "MOC_ACTUAL"+GetWhere("=","N"    )+" AND "+;       
                               "MOC_TIPTRA"+GetWhere("=","D"    )+" AND "+;
                               "MOC_ORIGEN"+GetWhere("=","COM"  )) 

       ENDIF

     ENDIF
 
     // Aqui debe Buscar las retenciones ISLR Asociadas

     cWhere:="RXP_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
             "RXP_TIPDOC"+GetWhere("=",cTipDoc)+" AND "+;
             "RXP_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
             "RXP_NUMDOC"+GetWhere("=",cDocNum)

      cNumRet:=SQLGET("DPDOCPROISLR","RXP_DOCNUM,RXP_DOCTIP",cWhere)
      // Borra los Asientos de los Documentos Diferentes a Retenciones

      IF lDelIslr .AND. !Empty(cNumRet) 

        cDocTip:=oDp:aRow[2]

        cWhere:="DOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                "DOC_TIPDOC"+GetWhere("=",cDocTip)+" AND "+;
                "DOC_CODIGO"+GetWhere("=",cCodigo)+" AND "+;
                "DOC_NUMERO"+GetWhere("=",cNumRet)+" AND DOC_TIPTRA='D'"

        SQLUPDATE("DPDOCPRO",{"DOC_ESTADO","DOC_ACT"},{cEstado,nInv},cWhere)

        cNumCbt:=SQLGET("DPDOCPRO","DOC_CBTNUM,DOC_FECHA",cWhere)

        IF (nInv=0 .AND. !Empty(cNumCbt))

           dFecha:=oDp:aRow[2]

           SQLDELETE("DPASIENTOS","MOC_NUMCBT"+GetWhere("=",cNumCbt)+" AND "+;
                                  "MOC_FECHA "+GetWhere("=",dFecha )+" AND "+;
                                  "MOC_TIPO  "+GetWhere("=",cDocTip)+" AND "+;
                                  "MOC_DOCUME"+GetWhere("=",cNumRet)+" AND "+;
                                  "MOC_CODSUC"+GetWhere("=",cCodSuc)+" AND "+;
                                  "MOC_ACTUAL"+GetWhere("=","N"    )+" AND "+;       
                                  "MOC_TIPTRA"+GetWhere("=","D"    )+" AND "+;
                                  "MOC_ORIGEN"+GetWhere("=","COM"  )) 

        ENDIF

     ENDIF

RETURN .T.
// EOF
